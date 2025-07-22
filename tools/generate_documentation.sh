#!/bin/bash

# Unified Documentation Generation Tool
# Generates all documentation for terraform-provider-azurecaf
# Usage: ./generate_documentation.sh [--azure|--resources|--all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESDEF="$SCRIPT_DIR/../resourceDefinition.json"
DOCS_DIR="$SCRIPT_DIR/../docs"

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

show_help() {
    cat << HELP
Usage: $0 [OPTIONS]

Generate documentation for terraform-provider-azurecaf

OPTIONS:
    --azure         Generate Azure-specific documentation
    --resources     Generate resource type documentation  
    --all           Generate all documentation (default)
    --help          Show this help message

EXAMPLES:
    $0                    # Generate all documentation
    $0 --azure           # Generate only Azure docs
    $0 --resources       # Generate only resource docs
HELP
}

generate_azure_docs() {
    log_info "Generating Azure-specific documentation..."
    
    # Create Azure resource mapping documentation
    local azure_doc="$DOCS_DIR/azure_resources.md"
    mkdir -p "$DOCS_DIR"
    
    cat > "$azure_doc" << 'AZUREDOC'
# Azure Resource Types Supported

This document lists all Azure resource types supported by terraform-provider-azurecaf.

## Resource Categories

AZUREDOC

    # Group resources by Azure service
    jq -r '.[].name' "$RESDEF" | sort | while read -r resource; do
        service=$(echo "$resource" | sed 's/azurerm_//' | cut -d'_' -f1)
        echo "- \`$resource\`" >> "$azure_doc.tmp"
    done
    
    # Sort and append
    sort "$azure_doc.tmp" >> "$azure_doc"
    rm -f "$azure_doc.tmp"
    
    log_success "Generated Azure documentation: $azure_doc"
}

generate_resource_docs() {
    log_info "Generating resource type documentation..."
    
    local resource_doc="$DOCS_DIR/resource_types.md"
    mkdir -p "$DOCS_DIR"
    
    cat > "$resource_doc" << 'RESOURCEDOC'
# Terraform Resource Types

Complete list of supported Terraform resource types with their naming constraints.

## Supported Resources

| Resource Type | Min Length | Max Length | Lowercase Only | Allows Dashes |
|---------------|------------|------------|----------------|---------------|
RESOURCEDOC

    # Generate table from JSON
    jq -r '.[] | "| `\(.name)` | \(.min_length) | \(.max_length) | \(.lowercase) | \(.dashes) |"' "$RESDEF" | sort >> "$resource_doc"
    
    log_success "Generated resource documentation: $resource_doc"
}

generate_all_docs() {
    log_info "Generating all documentation..."
    generate_azure_docs
    generate_resource_docs
    
    # Update README if update script exists
    if [ -f "$SCRIPT_DIR/update_resource_status.sh" ]; then
        log_info "Updating README resource status..."
        bash "$SCRIPT_DIR/update_resource_status.sh"
    fi
}

# Main execution
case "${1:---all}" in
    --azure)
        generate_azure_docs
        ;;
    --resources)
        generate_resource_docs
        ;;
    --all)
        generate_all_docs
        ;;
    --help|-h)
        show_help
        ;;
    *)
        log_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac

log_success "Documentation generation completed!"
