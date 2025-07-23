#!/bin/bash

# Enhanced Azure Resource Synchronization Tool v3.0
# Follows individual resource links from Hashicorp Registry

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"
TEMP_DIR=""
LOG_FILE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] ${level}: $message" | tee -a "$LOG_FILE"
}

log_info() { log "${BLUE}INFO${NC}" "$1"; }
log_success() { log "${GREEN}SUCCESS${NC}" "$1"; }
log_warning() { log "${YELLOW}WARNING${NC}" "$1"; }
log_error() { log "${RED}ERROR${NC}" "$1"; }

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleaned up temporary directory"
    fi
}

trap cleanup EXIT

show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║      Enhanced Azure Resource Synchronization Tool v3.0      ║"
    echo "║                                                              ║"
    echo "║    Deep-links into individual Hashicorp resource pages      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_dependencies() {
    local deps=("curl" "jq" "grep" "awk" "sed")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_error "Required dependency not found: $dep"
            exit 1
        fi
    done
    log_success "All dependencies available"
}

fetch_hashicorp_resource_list() {
    log_info "📥 Fetching Hashicorp AzureRM provider resource index..."
    
    local main_url="https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs"
    local main_page="$TEMP_DIR/hashicorp_main.html"
    
    if ! curl -s -L "$main_url" > "$main_page"; then
        log_error "Failed to download Hashicorp main page"
        return 1
    fi
    
    # Extract resource links from the main page
    local resource_links="$TEMP_DIR/resource_links.txt"
    
    # Find all resource links (those that start with /docs/resources/)
    grep -oP 'href="/providers/hashicorp/azurerm/[^"]+/docs/resources/[^"]*"' "$main_page" | \
        sed 's/href="//;s/"//' | \
        sed 's|^|https://registry.terraform.io|' > "$resource_links"
    
    # Also look for direct resource mentions
    grep -oP 'azurerm_[a-z0-9_]+' "$main_page" | sort -u >> "$TEMP_DIR/resource_names_raw.txt"
    
    local link_count=$(wc -l < "$resource_links" 2>/dev/null || echo "0")
    log_success "Found $link_count resource documentation links"
    
    return 0
}

fetch_individual_resources() {
    log_info "🔍 Fetching individual resource pages..."
    
    local resource_links="$TEMP_DIR/resource_links.txt"
    local all_resources="$TEMP_DIR/all_hashicorp_resources.txt"
    
    if [ ! -f "$resource_links" ]; then
        log_warning "No resource links file found, trying alternative method"
        return 1
    fi
    
    local processed=0
    local total=$(wc -l < "$resource_links" 2>/dev/null || echo "0")
    
    # Process each resource link
    while IFS= read -r url; do
        if [ -z "$url" ]; then continue; fi
        
        processed=$((processed + 1))
        if [ $((processed % 10)) -eq 0 ]; then
            log_info "Processed $processed/$total resource pages..."
        fi
        
        # Extract resource name from URL
        local resource_name=$(echo "$url" | grep -oP 'resources/\K[^/?]+')
        if [ -n "$resource_name" ]; then
            echo "azurerm_$resource_name" >> "$all_resources"
        fi
        
        # Download the individual page to extract additional info
        local page_file="$TEMP_DIR/resource_$(echo "$resource_name" | tr '/' '_').html"
        if curl -s -L "$url" > "$page_file"; then
            # Extract any additional resource references from this page
            grep -oP 'azurerm_[a-z0-9_]+' "$page_file" | head -5 >> "$TEMP_DIR/resource_names_raw.txt"
        fi
        
        # Rate limiting to be respectful
        sleep 0.1
        
    done < "$resource_links"
    
    # Alternative: try to get resources from the provider index API
    log_info "🔍 Trying Terraform Registry API..."
    local api_url="https://registry.terraform.io/v1/providers/hashicorp/azurerm"
    local api_response="$TEMP_DIR/api_response.json"
    
    if curl -s -L "$api_url" > "$api_response" 2>/dev/null; then
        if jq -r '.docs[]?.title // empty' "$api_response" 2>/dev/null | grep -E '^azurerm_' >> "$all_resources"; then
            log_success "Extracted additional resources from API"
        fi
    fi
    
    # Clean up and deduplicate resources
    if [ -f "$all_resources" ]; then
        sort -u "$all_resources" > "$TEMP_DIR/hashicorp_resources_final.txt"
        local count=$(wc -l < "$TEMP_DIR/hashicorp_resources_final.txt")
        log_success "Extracted $count unique resources from Hashicorp documentation"
    else
        touch "$TEMP_DIR/hashicorp_resources_final.txt"
        log_warning "No resources extracted from Hashicorp documentation"
    fi
    
    return 0
}

# Try multiple methods to get Hashicorp resources
fetch_hashicorp_resources_comprehensive() {
    log_info "📥 Comprehensive Hashicorp resource extraction..."
    
    local final_resources="$TEMP_DIR/hashicorp_resources_final.txt"
    
    # Method 1: Parse main documentation page for resource links
    fetch_hashicorp_resource_list
    fetch_individual_resources
    
    # Method 2: Try to get resources from GitHub repository
    log_info "🐙 Fetching from GitHub repository..."
    local github_url="https://api.github.com/repos/hashicorp/terraform-provider-azurerm/contents/website/docs/r"
    local github_response="$TEMP_DIR/github_resources.json"
    
    if curl -s -L "$github_url" > "$github_response" 2>/dev/null; then
        if jq -r '.[].name' "$github_response" 2>/dev/null | \
            grep '\.html\.markdown$' | \
            sed 's/\.html\.markdown$//' | \
            sed 's/^/azurerm_/' | \
            grep -E '^azurerm_[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]$' | \
            grep -v 'azurerm_com_\|azurerm_www_\|azurerm_http\|azurerm_legal\|azurerm_mscc\|azurerm_answers\|azurerm_fwlink\|azurerm_pdfstore\|azurerm_t5' >> "$final_resources"; then
            log_success "Extracted resources from GitHub repository"
        fi
    fi
    
    # Method 3: Try Terraform Registry search API
    log_info "🔍 Trying Registry search API..."
    local search_url="https://registry.terraform.io/v1/providers/hashicorp/azurerm/latest/docs"
    local search_response="$TEMP_DIR/search_response.json"
    
    if curl -s -L "$search_url" > "$search_response" 2>/dev/null; then
        if jq -r '.[] | select(.category == "resources") | .title' "$search_response" 2>/dev/null | grep -E '^azurerm_' >> "$final_resources"; then
            log_success "Extracted resources from Registry API"
        fi
    fi
    
    # Clean and finalize
    if [ -f "$final_resources" ]; then
        sort -u "$final_resources" > "$TEMP_DIR/hashicorp_clean.txt"
        mv "$TEMP_DIR/hashicorp_clean.txt" "$final_resources"
        local count=$(wc -l < "$final_resources")
        log_success "Total unique Hashicorp resources found: $count"
    else
        touch "$final_resources"
        log_warning "No Hashicorp resources found"
    fi
}

fetch_microsoft_resources() {
    log_info "📥 Fetching Microsoft Azure resource naming rules..."
    
    local ms_url="https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules"
    local ms_page="$TEMP_DIR/microsoft_naming.html"
    
    if ! curl -s -L "$ms_url" > "$ms_page"; then
        log_error "Failed to download Microsoft documentation"
        return 1
    fi
    
    log_success "Downloaded Microsoft documentation"
    
    # Extract resource types from Microsoft documentation
    local ms_resources="$TEMP_DIR/microsoft_resources.txt"
    local ms_rules="$TEMP_DIR/microsoft_rules.txt"
    
    # Look for resource patterns in the Microsoft documentation
    grep -oiP 'Microsoft\.[A-Za-z]+/[a-zA-Z0-9_]+' "$ms_page" | \
        awk '{print tolower($0)}' | \
        sed 's/microsoft\.//' | \
        sed 's/\//_/' | \
        sed 's/^/azurerm_/' | \
        sort -u > "$ms_resources"
    
    # Also extract any azurerm_ references
    grep -oP 'azurerm_[a-z0-9_]+' "$ms_page" | sort -u >> "$ms_resources"
    
    # Extract naming rules patterns for validation
    log_info "🔍 Extracting naming rules for validation..."
    
    # Look for length constraints (e.g., "3-24 characters", "1-90", etc.)
    grep -oP '\d+-\d+\s*characters?' "$ms_page" | sort -u > "$TEMP_DIR/length_patterns.txt"
    
    # Look for case requirements
    grep -i -A3 -B3 "lowercase\|uppercase\|case.*sensitive" "$ms_page" | \
        grep -v "^--$" > "$TEMP_DIR/case_patterns.txt" 2>/dev/null || true
    
    # Look for character restrictions  
    grep -i -A2 -B2 "alphanumeric\|letters\|numbers\|hyphen\|dash\|underscore" "$ms_page" | \
        grep -v "^--$" > "$TEMP_DIR/char_patterns.txt" 2>/dev/null || true
    
    # Create validation report
    cat > "$ms_rules" << EOF
Microsoft Azure Naming Rules Validation Data
============================================
Source: $ms_url
Extracted: $(date)

Length Patterns Found:
$(cat "$TEMP_DIR/length_patterns.txt" 2>/dev/null | head -10)

Case Requirements Found:  
$(cat "$TEMP_DIR/case_patterns.txt" 2>/dev/null | head -5)

Character Restrictions Found:
$(cat "$TEMP_DIR/char_patterns.txt" 2>/dev/null | head -10)

Critical Resource Rules (Known):
- Storage Account: 3-24 lowercase alphanumeric only
- Key Vault: 3-24 alphanumeric and hyphens
- Resource Group: 1-90 flexible characters
- Virtual Network: 2-64 alphanumeric, periods, underscores, hyphens
EOF
    
    # Clean up and validate our current rules
    sort -u "$ms_resources" > "$TEMP_DIR/microsoft_clean.txt"
    mv "$TEMP_DIR/microsoft_clean.txt" "$ms_resources"
    
    local count=$(wc -l < "$ms_resources")
    log_success "Extracted $count resources from Microsoft documentation"
    log_info "📋 Naming rules validation data saved to: $ms_rules"
    
    # Quick validation of critical resources
    validate_critical_resources_inline
}

validate_critical_resources_inline() {
    log_info "🔍 Quick validation of critical resource rules..."
    
    # Check Storage Account
    local st_rule=$(jq -r '.[] | select(.name == "azurerm_storage_account") | "\(.min_length)|\(.max_length)|\(.lowercase)|\(.dashes)"' "$RESDEF" 2>/dev/null)
    if [ "$st_rule" = "3|24|true|false" ]; then
        log_success "✅ azurerm_storage_account rules: CORRECT (3-24, lowercase, no dashes)"
    elif [ -n "$st_rule" ] && [ "$st_rule" != "null" ]; then
        log_warning "⚠️ azurerm_storage_account rules: CHECK NEEDED (current: $st_rule)"
    fi
    
    # Check Key Vault  
    local kv_rule=$(jq -r '.[] | select(.name == "azurerm_key_vault") | "\(.min_length)|\(.max_length)|\(.lowercase)|\(.dashes)"' "$RESDEF" 2>/dev/null)
    if [ "$kv_rule" = "3|24|false|true" ]; then
        log_success "✅ azurerm_key_vault rules: CORRECT (3-24, mixed case, dashes allowed)"
    elif [ -n "$kv_rule" ] && [ "$kv_rule" != "null" ]; then
        log_warning "⚠️ azurerm_key_vault rules: CHECK NEEDED (current: $kv_rule)"
    fi
    
    # Check Resource Group
    local rg_rule=$(jq -r '.[] | select(.name == "azurerm_resource_group") | "\(.min_length)|\(.max_length)|\(.lowercase)|\(.dashes)"' "$RESDEF" 2>/dev/null)
    if [ "$rg_rule" = "1|90|false|true" ]; then
        log_success "✅ azurerm_resource_group rules: CORRECT (1-90, mixed case, dashes allowed)"
    elif [ -n "$rg_rule" ] && [ "$rg_rule" != "null" ]; then
        log_warning "⚠️ azurerm_resource_group rules: CHECK NEEDED (current: $rg_rule)"
    fi
}

analyze_missing_resources() {
    log_info "🔍 Analyzing current resource definitions..."
    
    if [ ! -f "$RESDEF" ]; then
        log_error "Resource definition file not found: $RESDEF"
        return 1
    fi
    
    local current_resources="$TEMP_DIR/current_resources.txt"
    jq -r '.[].name' "$RESDEF" | sort > "$current_resources"
    local current_count=$(wc -l < "$current_resources")
    log_success "Found $current_count current resources"
    
    # Combine all external resources
    local all_external="$TEMP_DIR/all_external_resources.txt"
    cat "$TEMP_DIR/hashicorp_resources_final.txt" "$TEMP_DIR/microsoft_resources.txt" 2>/dev/null | sort -u > "$all_external"
    
    # Find missing resources
    local missing_resources="$TEMP_DIR/missing_resources.txt"
    comm -23 "$all_external" "$current_resources" > "$missing_resources"
    
    local missing_count=$(wc -l < "$missing_resources")
    log_success "Found $missing_count missing resources"
    
    if [ "$missing_count" -gt 0 ]; then
        log_info "Missing resources preview:"
        head -10 "$missing_resources" | while read -r resource; do
            log_info "  → $resource"
        done
        if [ "$missing_count" -gt 10 ]; then
            log_info "  ... and $((missing_count - 10)) more"
        fi
    fi
}

# Main execution
main() {
    show_header
    
    # Setup
    LOG_FILE="$SCRIPT_DIR/enhanced_sync_log_$(date +%Y%m%d_%H%M%S).log"
    TEMP_DIR=$(mktemp -d -t azurecaf_enhanced_sync_XXXXXX)
    
    log_info "🚀 Starting enhanced Azure resource synchronization..."
    log_info "Log file: $LOG_FILE"
    log_info "Created temporary directory: $TEMP_DIR"
    
    # Check dependencies
    log_info "⚙️ Checking dependencies..."
    check_dependencies
    
    # Fetch resources from all sources
    fetch_hashicorp_resources_comprehensive
    fetch_microsoft_resources
    
    # Analyze
    analyze_missing_resources
    
    # Generate report
    log_info "🔄 Generating enhanced summary report..."
    local report_file="$SCRIPT_DIR/enhanced_sync_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# Enhanced Azure Resource Synchronization Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S')

## Summary

### Enhanced Discovery Methods
- ✅ Hashicorp Registry Resource Index
- ✅ Individual Resource Page Crawling  
- ✅ GitHub Repository Analysis
- ✅ Microsoft Azure Naming Rules Documentation
- ✅ Terraform Registry API

### Statistics
- **Current Resources:** $(wc -l < "$TEMP_DIR/current_resources.txt" 2>/dev/null || echo "0")
- **Hashicorp Resources Found:** $(wc -l < "$TEMP_DIR/hashicorp_resources_final.txt" 2>/dev/null || echo "0")
- **Microsoft Resources Found:** $(wc -l < "$TEMP_DIR/microsoft_resources.txt" 2>/dev/null || echo "0")
- **Missing Resources Identified:** $(wc -l < "$TEMP_DIR/missing_resources.txt" 2>/dev/null || echo "0")

### Sources Analyzed
1. **Hashicorp Registry Main:** https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
2. **Individual Resource Pages:** Multiple deep-linked resource documentation
3. **GitHub Repository:** https://github.com/hashicorp/terraform-provider-azurerm
4. **Microsoft Naming Rules:** https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules

### Missing Resources Found

EOF

    if [ -f "$TEMP_DIR/missing_resources.txt" ] && [ -s "$TEMP_DIR/missing_resources.txt" ]; then
        echo "The following resources were found in official documentation but are missing from our definitions:" >> "$report_file"
        echo "" >> "$report_file"
        while read -r resource; do
            echo "- \`$resource\`" >> "$report_file"
        done < "$TEMP_DIR/missing_resources.txt"
    else
        echo "No missing resources found. All resources appear to be synchronized." >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## Naming Rules Validation

### Critical Resources Validation Status

Based on Microsoft Azure naming conventions:

- **Storage Account**: 3-24 characters, lowercase alphanumeric only
- **Key Vault**: 3-24 characters, alphanumeric and hyphens, start with letter  
- **Resource Group**: 1-90 characters, flexible character set

$(if [ -f "$TEMP_DIR/microsoft_rules.txt" ]; then
    echo "### Extracted Naming Rules Data"
    echo '```'
    cat "$TEMP_DIR/microsoft_rules.txt"
    echo '```'
fi)

EOF
    
    # Add validation results if available
    if command -v jq >/dev/null 2>&1 && [ -f "$RESDEF" ]; then
        echo "### Current Rules Validation" >> "$report_file"
        
        # Storage Account validation
        local st_rule=$(jq -r '.[] | select(.name == "azurerm_storage_account") | "min=\(.min_length), max=\(.max_length), lowercase=\(.lowercase), dashes=\(.dashes)"' "$RESDEF" 2>/dev/null || echo "not found")
        echo "- **azurerm_storage_account**: $st_rule" >> "$report_file"
        
        # Key Vault validation  
        local kv_rule=$(jq -r '.[] | select(.name == "azurerm_key_vault") | "min=\(.min_length), max=\(.max_length), lowercase=\(.lowercase), dashes=\(.dashes)"' "$RESDEF" 2>/dev/null || echo "not found")
        echo "- **azurerm_key_vault**: $kv_rule" >> "$report_file"
        
        # Resource Group validation
        local rg_rule=$(jq -r '.[] | select(.name == "azurerm_resource_group") | "min=\(.min_length), max=\(.max_length), lowercase=\(.lowercase), dashes=\(.dashes)"' "$RESDEF" 2>/dev/null || echo "not found")  
        echo "- **azurerm_resource_group**: $rg_rule" >> "$report_file"
        echo "" >> "$report_file"
    fi

    cat >> "$report_file" << EOF
    
    cat >> "$report_file" << EOF

## Detailed Analysis

### Hashicorp Resources Sample
$(head -10 "$TEMP_DIR/hashicorp_resources_final.txt" 2>/dev/null | while read -r line; do echo "- \`$line\`"; done)

### Microsoft Resources Sample  
$(head -10 "$TEMP_DIR/microsoft_resources.txt" 2>/dev/null | while read -r line; do echo "- \`$line\`"; done)

## Next Steps

1. Review the missing resources for relevance
2. Add missing resources using add_azure_resources.sh
3. Validate new resource definitions
4. Update documentation

---
*Generated by enhanced_sync_official_resources.sh v3.0*
EOF

    log_success "Generated report: $report_file"
    log_success "🎉 Enhanced synchronization completed!"
    
    echo ""
    echo "Summary:"
    echo "  → Log file: $LOG_FILE"
    echo "  → Report file: $report_file"
    echo "  → Current resources: $(wc -l < "$TEMP_DIR/current_resources.txt" 2>/dev/null || echo "0")"
    echo "  → Hashicorp resources found: $(wc -l < "$TEMP_DIR/hashicorp_resources_final.txt" 2>/dev/null || echo "0")"
    echo "  → Missing resources found: $(wc -l < "$TEMP_DIR/missing_resources.txt" 2>/dev/null || echo "0")"
}

# Execute main function
main "$@"
