#!/bin/bash

# Tools Directory Advanced Cleanup Script
# Removes obsolete, duplicate, and unnecessary files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_success() { echo -e "${GREEN}SUCCESS${NC}: $1"; }
log_warning() { echo -e "${YELLOW}WARNING${NC}: $1"; }
log_error() { echo -e "${RED}ERROR${NC}: $1"; }

echo -e "${CYAN}"
echo "================================================================"
echo "           Advanced Tools Directory Cleanup                    "
echo "                                                               "
echo "      Removing obsolete and redundant scripts/files           "
echo "================================================================"
echo -e "${NC}"

# Create cleanup timestamp
CLEANUP_TIME=$(date +%Y%m%d_%H%M%S)
CLEANUP_BACKUP="$SCRIPT_DIR/cleanup_backup_$CLEANUP_TIME"

log_info "Starting advanced cleanup process..."
echo ""

# Files to KEEP (essential tools)
declare -a KEEP_FILES=(
    "workflow.sh"                    # Master workflow orchestrator
    "sync_official_resources.sh"    # Main sync tool (enhanced version)
    "add_azure_resources.sh"        # Resource addition tool
    "analyze_azure_resources.sh"    # Analysis tool
    "generate_documentation.sh"     # Unified documentation generator
    "update_resource_status.sh"     # README updater
    "auto_add_missing.sh"          # Auto-add missing resources
    "README.md"                     # Tools documentation
)

# Files to REMOVE (obsolete/redundant)
declare -a REMOVE_FILES=(
    "enhanced_sync_official_resources.sh"    # Replaced by sync_official_resources.sh
    "sync_official_resources_v2_backup.sh"   # Backup no longer needed
    "validate_naming_rules.sh"               # Problematic version
    "validate_naming_rules_fixed.sh"         # Replaced by integrated validation
    "generate_validation_report.sh"          # Functionality integrated
    "test_ms_parsing.sh"                     # Test script no longer needed
    "new_resources_sample.txt"               # Temporary file
    "cleanup_tools.sh"                       # Old cleanup script
)

# Log files to CLEAN (keep only latest)
log_info "🧹 Cleaning old log files..."
OLD_LOGS=$(find "$SCRIPT_DIR" -name "enhanced_sync_log_*.log" -mtime +1 2>/dev/null | wc -l)
if [ "$OLD_LOGS" -gt 3 ]; then
    # Keep only 3 most recent log files
    find "$SCRIPT_DIR" -name "enhanced_sync_log_*.log" -mtime +1 -delete 2>/dev/null || true
    log_success "Cleaned $OLD_LOGS old log files (kept 3 most recent)"
fi

# Report files to CLEAN (keep only latest)
log_info "📋 Cleaning old report files..."
OLD_REPORTS=$(find "$SCRIPT_DIR" -name "enhanced_sync_report_*.md" -mtime +1 2>/dev/null | wc -l)
if [ "$OLD_REPORTS" -gt 2 ]; then
    # Keep only 2 most recent report files
    find "$SCRIPT_DIR" -name "enhanced_sync_report_*.md" -mtime +1 -delete 2>/dev/null || true
    log_success "Cleaned $OLD_REPORTS old report files (kept 2 most recent)"
fi

echo ""
log_info "🔍 Analyzing current files..."

# Create backup for files to be removed
mkdir -p "$CLEANUP_BACKUP"
backup_count=0

# Check what files exist and categorize them
echo ""
log_info "📊 File Analysis:"

for file in "${KEEP_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo "  ✅ KEEP: $file (essential tool)"
    else
        log_warning "  ⚠️  MISSING: $file (should exist)"
    fi
done

echo ""
for file in "${REMOVE_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo "  ❌ REMOVE: $file (obsolete/redundant)"
        # Backup before removal
        cp "$SCRIPT_DIR/$file" "$CLEANUP_BACKUP/" 2>/dev/null || true
        backup_count=$((backup_count + 1))
    fi
done

# Show summary
echo ""
log_info "📋 Cleanup Summary:"
echo "  Files to keep: ${#KEEP_FILES[@]}"
echo "  Files to remove: $backup_count"
echo "  Backup location: $CLEANUP_BACKUP"

if [ "$backup_count" -eq 0 ]; then
    log_success "✅ No obsolete files found - directory already clean!"
    rmdir "$CLEANUP_BACKUP" 2>/dev/null || true
    exit 0
fi

# Confirm cleanup
echo ""
read -p "Proceed with cleanup? Remove $backup_count obsolete files? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cleanup cancelled"
    rmdir "$CLEANUP_BACKUP" 2>/dev/null || true
    exit 0
fi

# Execute cleanup
echo ""
log_info "🚀 Starting cleanup..."

removed_count=0
for file in "${REMOVE_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        rm "$SCRIPT_DIR/$file"
        log_success "  ✅ Removed: $file"
        removed_count=$((removed_count + 1))
    fi
done

# Clean any remaining temporary files
find "$SCRIPT_DIR" -name "*.tmp" -delete 2>/dev/null || true
find "$SCRIPT_DIR" -name "*~" -delete 2>/dev/null || true

# Final verification
echo ""
log_success "🎉 Cleanup completed successfully!"
echo ""

log_info "📊 Final Status:"
echo "  Files removed: $removed_count"
echo "  Files backed up: $backup_count"
echo "  Backup location: $CLEANUP_BACKUP"

echo ""
log_info "✅ Current essential tools:"
for file in "${KEEP_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$file" ]; then
        echo "  📄 $file"
    fi
done

echo ""
log_success "Tools directory is now clean and optimized!"
echo ""

# Show directory size improvement
echo -e "${BLUE}Directory optimization complete!${NC}"
echo "To restore any removed files, check: $CLEANUP_BACKUP"
