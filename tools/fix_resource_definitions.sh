#!/bin/bash

# Fix Resource Definitions Script
# Fixes incomplete resource definitions that cause Go compilation errors

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_success() { echo -e "${GREEN}SUCCESS${NC}: $1"; }
log_warning() { echo -e "${YELLOW}WARNING${NC}: $1"; }
log_error() { echo -e "${RED}ERROR${NC}: $1"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                Fix Resource Definitions                      ║"
echo "║                                                              ║"
echo "║          Fixing incomplete resource definitions              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Create backup
backup_file="${RESDEF}.backup.$(date +%Y%m%d_%H%M%S)"
log_info "Creating backup: $(basename "$backup_file")"
cp "$RESDEF" "$backup_file"

# Create temporary file for processing
temp_file=$(mktemp)

# Step 1: Fix resources that have "regex" instead of "validation_regex"
log_info "Step 1: Converting 'regex' fields to 'validation_regex'..."

cat > "$temp_file" << 'EOF'
#!/usr/bin/env python3
import json
import sys
import re

def fix_resource_definitions(filename):
    with open(filename, 'r') as f:
        resources = json.load(f)
    
    fixed_count = 0
    incomplete_count = 0
    
    for resource in resources:
        # Fix 1: Convert "regex" to "validation_regex" if it looks like a validation pattern
        if "regex" in resource and "validation_regex" not in resource:
            regex_value = resource["regex"]
            # If regex looks like a validation pattern (starts with ^), use it as validation_regex
            if regex_value.startswith('"^') or regex_value.startswith('`^'):
                resource["validation_regex"] = regex_value
                # Convert regex to invalidation pattern
                if regex_value.startswith('"^'):
                    # Extract the character class from validation pattern
                    match = re.search(r'\[([^\]]+)\]', regex_value)
                    if match:
                        char_class = match.group(1)
                        # Convert to invalidation pattern
                        if char_class.startswith('^'):
                            resource["regex"] = f'"[{char_class[1:]}]"'
                        else:
                            resource["regex"] = f'"[^{char_class}]"'
                    fixed_count += 1
            elif not regex_value.startswith('"[^') and not regex_value.startswith('`[^'):
                # This regex field is actually a validation pattern, move it
                resource["validation_regex"] = regex_value
                # Generate appropriate invalidation regex
                resource["regex"] = '"[^a-zA-Z0-9._-]"'  # Default safe pattern
                fixed_count += 1
        
        # Fix 2: Add missing validation_regex for resources that have regex but no validation_regex
        if "regex" in resource and "validation_regex" not in resource:
            regex_value = resource["regex"]
            if regex_value.startswith('"[^') or regex_value.startswith('`[^'):
                # Generate validation_regex from invalidation regex
                min_len = resource.get("min_length", 1)
                max_len = resource.get("max_length", 80)
                
                # Extract allowed characters from invalidation pattern
                if '[^a-zA-Z0-9._-]' in regex_value:
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9._-]{{{min_len-1},{max_len-1}}}[a-zA-Z0-9]$"'
                elif '[^0-9A-Za-z_-]' in regex_value:
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9_-]{{{min_len-1},{max_len-1}}}[a-zA-Z0-9]$"'
                elif '[^0-9A-Za-z-]' in regex_value:
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9-]{{{min_len-1},{max_len-1}}}[a-zA-Z0-9]$"'
                elif '[^0-9A-Za-z_]' in regex_value:
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9_]{{{min_len-1},{max_len-1}}}[a-zA-Z0-9]$"'
                else:
                    # Default pattern
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9._-]{{0,{max_len-2}}}[a-zA-Z0-9]$"'
                
                resource["validation_regex"] = validation
                fixed_count += 1
        
        # Fix 3: Handle special cases like azurerm_bot_service
        if resource.get("name") == "azurerm_bot_service":
            if "validation_regex" not in resource:
                # Generate from the existing regex pattern
                resource["validation_regex"] = '"^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$"'
                # Fix regex to be invalidation pattern
                resource["regex"] = '"[^a-zA-Z0-9-_]"'
                fixed_count += 1
    
    # Write fixed JSON
    with open(filename, 'w') as f:
        json.dump(resources, f, indent=2)
    
    print(f"Fixed {fixed_count} resource definitions")
    return fixed_count

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: fix_resources.py <resourceDefinition.json>")
        sys.exit(1)
    
    fixed = fix_resource_definitions(sys.argv[1])
    sys.exit(0)
EOF

python3 "$temp_file" "$RESDEF"
rm "$temp_file"

# Validate JSON syntax
log_info "Step 2: Validating JSON syntax..."
if ! jq empty "$RESDEF" 2>/dev/null; then
    log_error "JSON validation failed! Restoring backup..."
    cp "$backup_file" "$RESDEF"
    exit 1
fi

# Check for remaining issues
log_info "Step 3: Checking for remaining incomplete resources..."
incomplete_resources=$(jq -r '.[] | select(has("validation_regex") | not) | .name' "$RESDEF" 2>/dev/null || true)

if [ -n "$incomplete_resources" ]; then
    log_warning "Found resources still missing validation_regex:"
    echo "$incomplete_resources" | while read -r resource; do
        echo "  - $resource"
    done
    
    # Fix remaining incomplete resources
    log_info "Step 4: Adding default validation_regex to remaining resources..."
    
    cat > "$temp_file" << 'EOF'
#!/usr/bin/env python3
import json
import sys

def add_missing_validation_regex(filename):
    with open(filename, 'r') as f:
        resources = json.load(f)
    
    fixed_count = 0
    
    for resource in resources:
        if "validation_regex" not in resource:
            min_len = resource.get("min_length", 1)
            max_len = resource.get("max_length", 80)
            
            # Generate appropriate validation regex based on existing regex
            regex_value = resource.get("regex", "")
            
            if "validation_regex" not in resource:
                if max_len <= 2:
                    validation = f'"^[a-zA-Z0-9]{{1,{max_len}}}$"'
                else:
                    validation = f'"^[a-zA-Z0-9][a-zA-Z0-9._-]{{0,{max_len-2}}}[a-zA-Z0-9]$"'
                
                resource["validation_regex"] = validation
                fixed_count += 1
            
            # Ensure regex field exists as invalidation pattern
            if "regex" not in resource:
                resource["regex"] = '"[^a-zA-Z0-9._-]"'
    
    with open(filename, 'w') as f:
        json.dump(resources, f, indent=2)
    
    print(f"Added validation_regex to {fixed_count} more resources")
    return fixed_count

if __name__ == "__main__":
    add_missing_validation_regex(sys.argv[1])
EOF

    python3 "$temp_file" "$RESDEF"
    rm "$temp_file"
fi

# Final validation
log_info "Step 5: Final validation..."
if ! jq empty "$RESDEF" 2>/dev/null; then
    log_error "Final validation failed! Restoring backup..."
    cp "$backup_file" "$RESDEF"
    exit 1
fi

# Count resources and show summary
total_resources=$(jq length "$RESDEF")
resources_with_validation=$(jq '[.[] | select(has("validation_regex"))] | length' "$RESDEF")

log_success "✅ Resource definition fixes completed!"
echo ""
log_info "📊 Summary:"
echo "  - Total resources: $total_resources"
echo "  - Resources with validation_regex: $resources_with_validation"
echo "  - Backup saved: $(basename "$backup_file")"

if [ "$resources_with_validation" -eq "$total_resources" ]; then
    log_success "🎯 All resources now have complete definitions!"
else
    remaining=$((total_resources - resources_with_validation))
    log_warning "⚠️  $remaining resources still need manual review"
fi

echo ""
log_info "🔄 Next steps:"
echo "1. Run 'go generate' to regenerate Go code"
echo "2. Run 'make build' to verify compilation"
echo "3. Run 'make test_all_resources' to verify tests pass"

# Cleanup
rm -f "$temp_file"
