#!/bin/bash

# Generic Azure Resource Analysis Tool
# Analyzes Azure resources in terraform-provider-azurecaf and provides insights
# Can compare against azurerm provider or analyze current implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"
README="$SCRIPT_DIR/../README.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo "Azure Resource Analysis Tool"
    echo "============================"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -s, --stats          Show resource statistics"
    echo "  -d, --duplicates     Find duplicate slugs"
    echo "  -v, --validate       Validate resource definitions"
    echo "  -c, --coverage       Show coverage analysis"
    echo "  -m, --missing FILE   Compare against resource list in FILE"
    echo "  --by-provider        Group resources by Azure provider namespace"
    echo "  --by-category        Group resources by service category"
    echo "  --export-list FILE   Export all resource names to FILE"
    echo ""
    echo "Examples:"
    echo "  $0 -s                           # Show basic statistics"
    echo "  $0 -d                           # Find duplicate slugs"
    echo "  $0 -m azurerm_resources.txt     # Compare against external list"
    echo "  $0 --by-provider                # Group by Azure providers"
    echo "  $0 --export-list current.txt    # Export current resources"
    echo ""
}

# Function to get resource statistics
show_statistics() {
    echo -e "${BLUE}📊 Azure Resource Statistics${NC}"
    echo "============================="
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    local total_resources=$(jq length "$RESDEF")
    local resources_with_provider=$(jq '[.[] | select(.official.resource_provider_namespace != null)] | length' "$RESDEF")
    local unique_providers=$(jq -r '[.[] | select(.official.resource_provider_namespace != null) | .official.resource_provider_namespace] | unique | length' "$RESDEF")
    local unique_slugs=$(jq -r '[.[] | .slug] | unique | length' "$RESDEF")
    
    echo -e "${GREEN}✅ Total resources: $total_resources${NC}"
    echo -e "${GREEN}✅ Resources with provider namespace: $resources_with_provider${NC}"
    echo -e "${GREEN}✅ Unique Azure providers: $unique_providers${NC}"
    echo -e "${GREEN}✅ Unique slugs: $unique_slugs${NC}"
    
    # Scope analysis
    echo ""
    echo -e "${CYAN}🔍 Resource Scopes:${NC}"
    jq -r 'group_by(.scope) | .[] | "\(.[0].scope): \(length) resources"' "$RESDEF" | while read line; do
        echo -e "${CYAN}  • $line${NC}"
    done
    
    # Naming constraints analysis  
    echo ""
    echo -e "${CYAN}📏 Length Constraints:${NC}"
    local avg_min=$(jq '[.[] | .min_length] | add / length | floor' "$RESDEF")
    local avg_max=$(jq '[.[] | .max_length] | add / length | floor' "$RESDEF")
    local min_length=$(jq '[.[] | .min_length] | min' "$RESDEF")
    local max_length=$(jq '[.[] | .max_length] | max' "$RESDEF")
    
    echo -e "${CYAN}  • Average min length: $avg_min${NC}"
    echo -e "${CYAN}  • Average max length: $avg_max${NC}"
    echo -e "${CYAN}  • Shortest allowed: $min_length${NC}"
    echo -e "${CYAN}  • Longest allowed: $max_length${NC}"
    
    # Case sensitivity analysis
    echo ""
    echo -e "${CYAN}🔤 Case Requirements:${NC}"
    local lowercase_only=$(jq '[.[] | select(.lowercase == true)] | length' "$RESDEF")
    local mixed_case=$(jq '[.[] | select(.lowercase == false)] | length' "$RESDEF")
    
    echo -e "${CYAN}  • Lowercase only: $lowercase_only resources${NC}"
    echo -e "${CYAN}  • Mixed case allowed: $mixed_case resources${NC}"
}

# Function to find duplicate slugs
find_duplicates() {
    echo -e "${YELLOW}🔍 Analyzing Duplicate Slugs${NC}"
    echo "============================="
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    local duplicates_found=false
    
    # Find duplicate slugs
    jq -r 'group_by(.slug) | .[] | select(length > 1) | {slug: .[0].slug, resources: [.[] | .name]}' "$RESDEF" | \
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            duplicates_found=true
            local slug=$(echo "$line" | jq -r '.slug')
            local resources=$(echo "$line" | jq -r '.resources[]')
            
            echo -e "${RED}⚠️  Duplicate slug: '$slug'${NC}"
            echo "$resources" | while read resource; do
                echo -e "${RED}    • $resource${NC}"
            done
            echo ""
        fi
    done
    
    if ! $duplicates_found; then
        echo -e "${GREEN}✅ No duplicate slugs found!${NC}"
    else
        echo -e "${YELLOW}💡 Consider using unique slugs for better resource identification${NC}"
    fi
}

# Function to validate resource definitions
validate_resources() {
    echo -e "${BLUE}✅ Validating Resource Definitions${NC}"
    echo "=================================="
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    local errors_found=false
    
    # JSON syntax validation
    if ! jq empty "$RESDEF" 2>/dev/null; then
        echo -e "${RED}❌ JSON syntax error in resourceDefinition.json${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ JSON syntax is valid${NC}"
    
    # Required fields validation
    local missing_name=$(jq '[.[] | select(.name == null or .name == "")] | length' "$RESDEF")
    local missing_slug=$(jq '[.[] | select(.slug == null or .slug == "")] | length' "$RESDEF")
    
    if [[ $missing_name -gt 0 ]]; then
        echo -e "${RED}❌ Found $missing_name resources without names${NC}"
        errors_found=true
    else
        echo -e "${GREEN}✅ All resources have names${NC}"
    fi
    
    if [[ $missing_slug -gt 0 ]]; then
        echo -e "${RED}❌ Found $missing_slug resources without slugs${NC}"
        errors_found=true
    else
        echo -e "${GREEN}✅ All resources have slugs${NC}"
    fi
    
    # Length constraints validation
    local invalid_lengths=$(jq '[.[] | select(.min_length > .max_length)] | length' "$RESDEF")
    if [[ $invalid_lengths -gt 0 ]]; then
        echo -e "${RED}❌ Found $invalid_lengths resources with min_length > max_length${NC}"
        errors_found=true
    else
        echo -e "${GREEN}✅ All length constraints are valid${NC}"
    fi
    
    # Azure resource name validation
    local invalid_names=$(jq -r '.[] | select(.name | test("^azurerm_") | not) | .name' "$RESDEF")
    if [[ -n "$invalid_names" ]]; then
        echo -e "${YELLOW}⚠️  Found resources not starting with 'azurerm_':${NC}"
        echo "$invalid_names" | while read name; do
            echo -e "${YELLOW}    • $name${NC}"
        done
    else
        echo -e "${GREEN}✅ All resources follow azurerm_ naming convention${NC}"
    fi
    
    if ! $errors_found; then
        echo ""
        echo -e "${GREEN}🎉 All validations passed!${NC}"
    fi
}

# Function to show coverage analysis
show_coverage() {
    echo -e "${PURPLE}📈 Coverage Analysis${NC}"
    echo "===================="
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    # Provider namespace coverage
    echo -e "${CYAN}🏢 Azure Provider Coverage:${NC}"
    jq -r '[.[] | select(.official.resource_provider_namespace != null) | .official.resource_provider_namespace] | group_by(.) | .[] | "\(.[0]): \(length) resources"' "$RESDEF" | \
    sort -k2 -nr | head -10 | while read line; do
        echo -e "${CYAN}  • $line${NC}"
    done
    
    # Service category analysis
    echo ""
    echo -e "${CYAN}📊 Service Categories (Top 10):${NC}"
    jq -r '.[] | .name | split("_")[1]' "$RESDEF" | sort | uniq -c | sort -nr | head -10 | while read count service; do
        echo -e "${CYAN}  • $service: $count resources${NC}"
    done
    
    # Implementation completeness
    if [[ -f "$README" ]]; then
        echo ""
        echo -e "${CYAN}📋 README Status:${NC}"
        local readme_implemented=$(grep -c "✔" "$README" 2>/dev/null || echo "0")
        local readme_missing=$(grep -c "❌" "$README" 2>/dev/null || echo "0")
        local readme_total=$((readme_implemented + readme_missing))
        
        if [[ $readme_total -gt 0 ]]; then
            local percentage=$((readme_implemented * 100 / readme_total))
            echo -e "${CYAN}  • Implementation: $readme_implemented/$readme_total ($percentage%)${NC}"
        else
            echo -e "${YELLOW}  • No status table found in README${NC}"
        fi
    fi
}

# Function to compare against external resource list
compare_missing() {
    local external_list="$1"
    
    echo -e "${YELLOW}🔍 Comparing Against External List${NC}"
    echo "=================================="
    echo ""
    
    if [[ ! -f "$external_list" ]]; then
        echo -e "${RED}❌ External resource list not found: $external_list${NC}"
        return 1
    fi
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    # Extract current resource names
    local temp_current=$(mktemp)
    jq -r '.[].name' "$RESDEF" | sort > "$temp_current"
    
    # Process external list (remove comments and empty lines)
    local temp_external=$(mktemp)
    grep -v '^[[:space:]]*#' "$external_list" | grep -v '^[[:space:]]*$' | sort > "$temp_external"
    
    # Find missing resources
    local missing_file=$(mktemp)
    comm -23 "$temp_external" "$temp_current" > "$missing_file"
    
    local missing_count=$(wc -l < "$missing_file")
    local external_count=$(wc -l < "$temp_external")
    local current_count=$(wc -l < "$temp_current")
    
    echo -e "${BLUE}📊 Comparison Results:${NC}"
    echo -e "${BLUE}  • External list: $external_count resources${NC}"
    echo -e "${BLUE}  • Current implementation: $current_count resources${NC}"
    echo -e "${YELLOW}  • Missing: $missing_count resources${NC}"
    
    if [[ $missing_count -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}📋 Missing Resources (first 20):${NC}"
        head -20 "$missing_file" | while read resource; do
            echo -e "${YELLOW}  • $resource${NC}"
        done
        
        if [[ $missing_count -gt 20 ]]; then
            echo -e "${YELLOW}  ... and $((missing_count - 20)) more${NC}"
        fi
        
        # Offer to create missing list
        echo ""
        echo -e "${CYAN}💡 To add missing resources, run:${NC}"
        echo -e "${CYAN}   ./add_azure_resources.sh <(comm -23 $temp_external $temp_current)${NC}"
    else
        echo -e "${GREEN}🎉 All resources from external list are implemented!${NC}"
    fi
    
    # Cleanup
    rm -f "$temp_current" "$temp_external" "$missing_file"
}

# Function to group by provider
group_by_provider() {
    echo -e "${PURPLE}🏢 Resources Grouped by Azure Provider${NC}"
    echo "======================================"
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    jq -r 'group_by(.official.resource_provider_namespace // "Unknown") | .[] | {provider: (.[0].official.resource_provider_namespace // "Unknown"), count: length, resources: [.[] | .name]} | "\(.provider) (\(.count) resources):\n" + (.resources | map("  • " + .) | join("\n"))' "$RESDEF"
}

# Function to group by category
group_by_category() {
    echo -e "${CYAN}📊 Resources Grouped by Service Category${NC}"
    echo "========================================"
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    # Group by first part after azurerm_
    jq -r 'group_by(.name | split("_")[1]) | .[] | {category: (.[0].name | split("_")[1]), count: length, resources: [.[] | .name]} | "\(.category | ascii_upcase) (\(.count) resources):\n" + (.resources | map("  • " + .) | join("\n"))' "$RESDEF"
}

# Function to export resource list
export_list() {
    local output_file="$1"
    
    echo -e "${BLUE}📤 Exporting Resource List${NC}"
    echo "=========================="
    echo ""
    
    if [[ ! -f "$RESDEF" ]]; then
        echo -e "${RED}❌ resourceDefinition.json not found${NC}"
        return 1
    fi
    
    jq -r '.[].name' "$RESDEF" | sort > "$output_file"
    local count=$(wc -l < "$output_file")
    
    echo -e "${GREEN}✅ Exported $count resources to: $output_file${NC}"
}

# Main script logic
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--stats)
            show_statistics
            ;;
        -d|--duplicates)
            find_duplicates
            ;;
        -v|--validate)
            validate_resources
            ;;
        -c|--coverage)
            show_coverage
            ;;
        -m|--missing)
            if [[ -n "$2" ]]; then
                compare_missing "$2"
                shift
            else
                echo -e "${RED}❌ Missing argument for --missing${NC}"
                exit 1
            fi
            ;;
        --by-provider)
            group_by_provider
            ;;
        --by-category)
            group_by_category
            ;;
        --export-list)
            if [[ -n "$2" ]]; then
                export_list "$2"
                shift
            else
                echo -e "${RED}❌ Missing argument for --export-list${NC}"
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
    shift
done
