#!/bin/bash

# Auto-add Missing Resources Script
# Adds a batch of missing resources found by enhanced sync

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_success() { echo -e "${GREEN}SUCCESS${NC}: $1"; }
log_warning() { echo -e "${YELLOW}WARNING${NC}: $1"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              Auto-Add Missing Resources Tool                 ║"
echo "║                                                              ║"
echo "║        Adding prioritized missing resources automatically    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if we have a recent enhanced sync report
latest_report=$(ls -t "$SCRIPT_DIR"/enhanced_sync_report_*.md 2>/dev/null | head -1)

if [ -z "$latest_report" ]; then
    log_warning "No recent enhanced sync report found. Running sync first..."
    if ! "$SCRIPT_DIR/sync_official_resources.sh"; then
        echo "Failed to run sync. Exiting."
        exit 1
    fi
    latest_report=$(ls -t "$SCRIPT_DIR"/enhanced_sync_report_*.md 2>/dev/null | head -1)
fi

log_info "Using sync report: $(basename "$latest_report")"

# Extract missing resources from the report
missing_file="$SCRIPT_DIR/temp_missing_resources.txt"
sed -n '/### Missing Resources Found/,/## Detailed Analysis/p' "$latest_report" | \
    grep '^- `azurerm_' | \
    sed 's/^- `//;s/`$//' > "$missing_file"

total_missing=$(wc -l < "$missing_file" 2>/dev/null || echo "0")
log_info "Found $total_missing missing resources"

if [ "$total_missing" -eq 0 ]; then
    log_success "No missing resources to add!"
    rm -f "$missing_file"
    exit 0
fi

# Prioritize resources by category
priority_resources="$SCRIPT_DIR/priority_resources.txt"

# High priority: AI, security, networking, core services
grep -E "(ai_|security_|network_|key_vault|storage_|compute_)" "$missing_file" > "$priority_resources" 2>/dev/null || true

# Medium priority: API management, monitoring
grep -E "(api_management|monitor|log_|analytics|insights)" "$missing_file" >> "$priority_resources" 2>/dev/null || true

# Add some general resources if we don't have enough priority ones
if [ $(wc -l < "$priority_resources" 2>/dev/null || echo "0") -lt 20 ]; then
    head -30 "$missing_file" >> "$priority_resources"
fi

# Remove duplicates and limit to reasonable batch size
sort -u "$priority_resources" | head -50 > "$SCRIPT_DIR/batch_add_resources.txt"

batch_count=$(wc -l < "$SCRIPT_DIR/batch_add_resources.txt")
log_info "Selected $batch_count high-priority resources for addition"

echo ""
log_info "Preview of resources to be added:"
head -10 "$SCRIPT_DIR/batch_add_resources.txt" | while read -r resource; do
    echo "  → $resource"
done
if [ "$batch_count" -gt 10 ]; then
    echo "  ... and $((batch_count - 10)) more"
fi

echo ""
read -p "Add these $batch_count resources? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Addition cancelled"
    rm -f "$missing_file" "$priority_resources" "$SCRIPT_DIR/batch_add_resources.txt"
    exit 0
fi

# Add the resources
log_info "🚀 Adding prioritized resources..."

if "$SCRIPT_DIR/add_azure_resources.sh" "$SCRIPT_DIR/batch_add_resources.txt"; then
    log_success "Successfully added resources!"
    
    # Update README
    log_info "📝 Updating README..."
    "$SCRIPT_DIR/update_resource_status.sh"
    
    # Generate new documentation
    log_info "📚 Updating documentation..."
    "$SCRIPT_DIR/generate_documentation.sh" --all
    
    # Show final stats
    current_count=$(jq length "$SCRIPT_DIR/../resourceDefinition.json")
    log_success "🎉 Process completed!"
    log_success "Total resources now: $current_count"
    
else
    log_warning "Some resources may have failed to add. Check the output above."
fi

# Cleanup
rm -f "$missing_file" "$priority_resources" "$SCRIPT_DIR/batch_add_resources.txt"

log_info "Run sync again to see remaining missing resources"
