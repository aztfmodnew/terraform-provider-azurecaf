#!/bin/bash

# Cleanup Tools Script for terraform-provider-azurecaf
# Removes temporary files, logs, and backup files from tools directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_success() { echo -e "${GREEN}SUCCESS${NC}: $1"; }
log_warning() { echo -e "${YELLOW}WARNING${NC}: $1"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   Tools Directory Cleanup                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

cd "$SCRIPT_DIR"

log_info "🧹 Starting cleanup of tools directory..."

# Count files before cleanup
initial_files=$(find . -type f | wc -l)

# Remove log files
if ls *.log >/dev/null 2>&1; then
    log_info "Removing log files..."
    rm -f *.log
    log_success "Log files removed"
fi

# Remove backup files
if ls *_backup_* >/dev/null 2>&1; then
    log_info "Removing backup files..."
    rm -rf *_backup_*
    log_success "Backup files removed"
fi

# Remove temporary files
if ls tmp_* >/dev/null 2>&1; then
    log_info "Removing temporary files..."
    rm -f tmp_*
    log_success "Temporary files removed"
fi

# Remove old report files (keep last 5)
if ls sync_report_*.md >/dev/null 2>&1; then
    log_info "Cleaning old sync reports (keeping last 5)..."
    ls -t sync_report_*.md | tail -n +6 | xargs rm -f
    log_success "Old sync reports cleaned"
fi

if ls enhanced_sync_report_*.md >/dev/null 2>&1; then
    log_info "Cleaning old enhanced sync reports (keeping last 5)..."
    ls -t enhanced_sync_report_*.md | tail -n +6 | xargs rm -f
    log_success "Old enhanced sync reports cleaned"
fi

if ls caf_sync_log_*.log >/dev/null 2>&1; then
    log_info "Cleaning old CAF sync logs (keeping last 3)..."
    ls -t caf_sync_log_*.log | tail -n +4 | xargs rm -f
    log_success "Old CAF sync logs cleaned"
fi

if ls caf_compliance_report_*.md >/dev/null 2>&1; then
    log_info "Cleaning old CAF compliance reports (keeping last 3)..."
    ls -t caf_compliance_report_*.md | tail -n +4 | xargs rm -f
    log_success "Old CAF compliance reports cleaned"
fi

# Remove empty scripts (0 bytes) except essential ones
essential_scripts=(
    "workflow.sh"
    "sync_official_resources.sh"
    "analyze_azure_resources.sh"
    "generate_documentation.sh"
    "auto_add_missing.sh"
    "update_resource_status.sh"
    "enhanced_sync_official_resources_caf.sh"
)

log_info "Checking for empty scripts..."
empty_removed=0
for script in *.sh; do
    if [ -f "$script" ] && [ ! -s "$script" ]; then
        # Check if it's an essential script
        is_essential=false
        for essential in "${essential_scripts[@]}"; do
            if [ "$script" = "$essential" ]; then
                is_essential=true
                break
            fi
        done
        
        if [ "$is_essential" = false ]; then
            log_warning "Removing empty script: $script"
            rm -f "$script"
            empty_removed=$((empty_removed + 1))
        fi
    fi
done

if [ $empty_removed -gt 0 ]; then
    log_success "Removed $empty_removed empty scripts"
fi

# Count files after cleanup
final_files=$(find . -type f | wc -l)
files_removed=$((initial_files - final_files))

log_success "✨ Cleanup completed!"
log_info "📊 Files before: $initial_files"
log_info "📊 Files after: $final_files"
if [ $files_removed -gt 0 ]; then
    log_success "🗑️  Removed $files_removed files"
else
    log_info "🎯 No files needed removal"
fi

echo ""
log_info "🔧 Remaining active tools:"
for script in "${essential_scripts[@]}"; do
    if [ -f "$script" ] && [ -s "$script" ]; then
        echo "  ✅ $script"
    fi
done

log_success "Tools directory is now clean and organized!"
