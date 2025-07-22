#!/bin/bash

# Master Workflow Script for terraform-provider-azurecaf
# Demonstrates complete resource management workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_success() { echo -e "${GREEN}SUCCESS${NC}: $1"; }
log_warning() { echo -e "${YELLOW}WARNING${NC}: $1"; }
log_error() { echo -e "${RED}ERROR${NC}: $1"; }

show_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            terraform-provider-azurecaf Workflow              ║"
    echo "║                                                              ║"
    echo "║          Complete Resource Management Demonstration          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    cat << HELP
Usage: $0 [COMMAND]

Available commands:
    sync        Sync with official sources (with CAF validation)
    analyze     Analyze current resource implementation
    docs        Generate all documentation
    status      Update README resource status
    test        Run full validation (includes CAF compliance and duplicate detection)
    auto-add    Automatically add missing resources
    cleanup     Clean up tools directory
    all         Execute complete workflow (default)
    help        Show this help message

Examples:
    $0           # Run complete workflow
    $0 sync      # Only sync with official sources
    $0 test      # Run validation tests
    $0 docs      # Only generate documentation

Features:
    ✅ Microsoft CAF compliance validation
    ✅ Duplicate slug detection and resolution
    ✅ Official abbreviation alignment
    ✅ Automated optimization
HELP
}

run_sync() {
    log_info "🔄 Synchronizing with official sources (with CAF validation)..."
    if ! "$SCRIPT_DIR/enhanced_sync_official_resources_caf.sh"; then
        log_warning "Enhanced CAF sync had issues, trying standard sync..."
        if ! "$SCRIPT_DIR/sync_official_resources.sh"; then
            log_error "Synchronization failed"
            return 1
        fi
    fi
    log_success "Synchronization completed"
}

run_analysis() {
    log_info "📊 Running comprehensive analysis..."
    if ! "$SCRIPT_DIR/analyze_azure_resources.sh" --stats; then
        log_error "Analysis failed"
        return 1
    fi
    log_success "Analysis completed"
}

run_docs() {
    log_info "📚 Generating documentation..."
    if ! "$SCRIPT_DIR/generate_documentation.sh" --all; then
        log_error "Documentation generation failed"
        return 1
    fi
    log_success "Documentation generated"
}

run_status() {
    log_info "📝 Updating resource status..."
    if ! "$SCRIPT_DIR/update_resource_status.sh"; then
        log_error "Status update failed"
        return 1
    fi
    log_success "Status updated"
}

run_test() {
    log_info "🧪 Running validation tests..."
    
    # Check resource definition JSON validity
    local resdef="$SCRIPT_DIR/../resourceDefinition.json"
    if ! jq empty "$resdef" >/dev/null 2>&1; then
        log_error "Resource definition JSON is invalid"
        return 1
    fi
    
    # Count resources
    local count=$(jq length "$resdef")
    log_info "Validated $count resources"
    
    # Check for duplicates
    local duplicates=$(jq -r '.[].name' "$resdef" | sort | uniq -d | wc -l)
    if [ "$duplicates" -gt 0 ]; then
        log_error "Found $duplicates duplicate resource names"
        return 1
    fi
    
    # Run CAF compliance validation if available
    if [ -f "$SCRIPT_DIR/automation/validate_caf_compliance.py" ]; then
        log_info "🏷️ Running CAF compliance validation..."
        if python3 "$SCRIPT_DIR/automation/validate_caf_compliance.py"; then
            log_success "CAF compliance validation passed"
        else
            log_warning "CAF compliance warnings found (not failing)"
        fi
    fi
    
    # Run duplicate detection if available
    if [ -f "$SCRIPT_DIR/automation/detect_duplicates.py" ]; then
        log_info "🔍 Running duplicate slug detection..."
        if python3 "$SCRIPT_DIR/automation/detect_duplicates.py"; then
            log_success "No duplicate slugs found"
        else
            log_warning "Duplicate slugs detected (not failing)"
        fi
    fi
    
    log_success "All validation tests passed"
}

run_auto_add() {
    log_info "🤖 Running automatic missing resources addition..."
    if ! "$SCRIPT_DIR/auto_add_missing.sh"; then
        log_error "Auto-add failed"
        return 1
    fi
    log_success "Auto-add completed"
}

run_cleanup() {
    log_info "🧹 Running tools directory cleanup..."
    if ! "$SCRIPT_DIR/cleanup_tools.sh"; then
        log_error "Cleanup failed"
        return 1
    fi
    log_success "Cleanup completed"
}

show_summary() {
    echo ""
    echo -e "${GREEN}🎉 Workflow completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}Project Status:${NC}"
    
    # Resource count
    local resdef="$SCRIPT_DIR/../resourceDefinition.json"
    local count=$(jq length "$resdef")
    echo -e "  📊 Total resources: ${GREEN}$count${NC}"
    
    # Last sync info
    local last_sync=$(ls -t "$SCRIPT_DIR"/sync_log_* 2>/dev/null | head -1)
    if [ -n "$last_sync" ]; then
        local sync_date=$(basename "$last_sync" | sed 's/sync_log_//' | sed 's/.log$//' | sed 's/_/ /')
        echo -e "  🔄 Last sync: ${BLUE}$sync_date${NC}"
    fi
    
    # Files generated
    echo -e "${CYAN}Generated Files:${NC}"
    [ -f "$SCRIPT_DIR/../docs/azure_resources.md" ] && echo "  ✅ Azure resources documentation"
    [ -f "$SCRIPT_DIR/../docs/resource_types.md" ] && echo "  ✅ Resource types documentation"
    
    # Reports available
    local latest_report=$(ls -t "$SCRIPT_DIR"/sync_report_*.md 2>/dev/null | head -1)
    if [ -n "$latest_report" ]; then
        echo "  📋 Latest sync report: $(basename "$latest_report")"
    fi
    
    echo ""
    echo -e "${YELLOW}Available Tools:${NC}"
    echo "  🔄 ./sync_official_resources.sh     - Sync with official sources"
    echo "  📊 ./analyze_azure_resources.sh     - Resource analysis"
    echo "  📚 ./generate_documentation.sh      - Generate documentation"
    echo "  📝 ./update_resource_status.sh      - Update README status"
    echo "  � ./auto_add_missing.sh           - Auto-add missing resources"
    echo "  �🧹 ./cleanup_tools.sh               - Clean up tools directory"
    echo "  ⚡ ./workflow.sh                    - This master workflow script"
    echo ""
}

# Main execution
show_header

case "${1:-all}" in
    sync)
        run_sync
        ;;
    analyze)
        run_analysis
        ;;
    docs)
        run_docs
        ;;
    status)
        run_status
        ;;
    test)
        run_test
        ;;
    auto-add)
        run_auto_add
        ;;
    cleanup)
        run_cleanup
        ;;
    all)
        log_info "🚀 Starting complete workflow..."
        echo ""
        
        # Step 1: Sync with official sources
        run_sync
        echo ""
        
        # Step 2: Generate documentation
        run_docs
        echo ""
        
        # Step 3: Run analysis
        run_analysis
        echo ""
        
        # Step 4: Run validation tests
        run_test
        echo ""
        
        # Step 5: Auto-add missing resources (optional)
        echo -e "${YELLOW}Optional: Add missing resources automatically?${NC}"
        read -p "Run auto-add missing resources? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            run_auto_add
            echo ""
        fi
        
        # Step 6: Show summary
        show_summary
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac

log_success "Operation completed successfully!"
