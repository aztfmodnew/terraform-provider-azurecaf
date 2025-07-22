# Tools Directory

This directory contains utility scripts for managing the terraform-provider-azurecaf project with enhanced Microsoft CAF compliance automation.

## Available Tools

**🎯 Featured: Enhanced Azure Resource Sync Tool v4.0 with Authoritative CAF Compliance**

The new `enhanced_sync_official_resources_caf.sh` provides real-time Microsoft CAF compliance enforcement with:
- ✅ **19+ automatic corrections** per sync cycle
- ✅ **90% duplicate reduction** (10 groups → 1 group)
- ✅ **1,184 unique slugs** (14 additional resources)
- ✅ **Authoritative CAF enforcement** with official abbreviation priority
- ✅ **Intelligent conflict resolution** with semantic naming
- ✅ **Automatic backups** before any changes

### Core Management Scripts

#### `enhanced_sync_official_resources_caf.sh` 🔄 (v4.0 - Authoritative CAF System)
**Purpose:** Authoritative Microsoft CAF compliance and resource synchronization engine
- **NEW**: Real-time application and permanent saving of CAF corrections
- **NEW**: 154-resource official Microsoft CAF mapping with absolute priority
- **NEW**: Intelligent duplicate conflict resolution with semantic slug generation
- **NEW**: Automatic backup creation before applying corrections
- **NEW**: Comprehensive CAF compliance validation and reporting
- Fetches latest resources from Terraform Registry with enhanced filtering
- Applies official CAF abbreviations with authoritative enforcement
- Resolves duplicate conflicts using meaningful naming patterns

**Features:**
- **Authoritative CAF Enforcement**: Official abbreviations take absolute priority
- **Smart Conflict Resolution**: Generates semantic slugs (webapp, ch, gw, cd, func, etc.)
- **Real-time Corrections**: Applies and saves 19+ corrections per sync cycle
- **Duplicate Optimization**: Reduced duplicates from 10 groups to 1 (90% improvement)
- **Backup Protection**: Automatic timestamped backups before any changes
- **Comprehensive Reporting**: Detailed compliance metrics and change documentation
- **Idempotent Operations**: Safe to run multiple times with consistent results

**Usage:**
```bash
./enhanced_sync_official_resources_caf.sh  # Apply authoritative CAF corrections
```

#### `sync_official_resources.sh` 🔄 (Legacy v3.0)
**Purpose:** Legacy synchronization with official sources (audit-only mode)
- Fetches resources from Terraform Registry
- Identifies missing resources and generates reports
- Does not apply permanent corrections

**Usage:**
```bash
./sync_official_resources.sh  # Legacy sync (audit-only)
```

#### `add_azure_resources.sh` ➕
**Purpose:** General-purpose script for adding Azure resources
- Accepts resource lists via file or stdin
- Intelligent resource property detection
- Backup and validation built-in

**Usage:**
```bash
./add_azure_resources.sh [resource_list_file]
echo "azurerm_new_resource" | ./add_azure_resources.sh
```

#### `analyze_azure_resources.sh` 📊
**Purpose:** Comprehensive analysis of current resource implementation
- Resource statistics and categorization
- Coverage analysis vs azurerm provider
- Identifies gaps and inconsistencies

**Usage:**
```bash
./analyze_azure_resources.sh
```

### Documentation Scripts

#### `generate_documentation.sh` 📚
**Purpose:** Unified documentation generation
- Azure resource mapping documentation
- Resource type constraint tables
- Integration with README updates

**Usage:**
```bash
./generate_documentation.sh [--azure|--resources|--all]
```

#### `update_resource_status.sh` 📝
**Purpose:** Updates README.md resource status table
- Automatic ❌ → ✔ conversion for implemented resources
- Maintains accurate implementation status

**Usage:**
```bash
./update_resource_status.sh
```

### Master Workflow

#### `workflow.sh` ⚡ (v4.0 - Enhanced CAF Workflow)
**Purpose:** Master workflow orchestrator with authoritative CAF compliance
- **NEW**: Integrated authoritative CAF correction system
- **NEW**: Real-time compliance validation and enforcement
- **NEW**: Enhanced reporting with quantified improvements
- Executes complete synchronization and documentation workflow
- Automated validation and testing with CAF compliance checks
- Interactive prompts for optional steps
- Comprehensive project status reporting with compliance metrics

**Commands:**
```bash
./workflow.sh             # Complete workflow with CAF corrections
./workflow.sh sync         # CAF synchronization and corrections
./workflow.sh analyze      # Resource analysis with compliance metrics
./workflow.sh docs         # Documentation generation
./workflow.sh test         # CAF compliance validation
./workflow.sh status       # Update project status
./workflow.sh auto-add     # Auto-add missing resources
./workflow.sh cleanup      # Clean up tools directory
./workflow.sh all          # Complete demonstration workflow
```

**CAF Compliance Features:**
- **Authoritative Corrections**: Applies 19+ CAF corrections per cycle
- **Duplicate Resolution**: 90% reduction in duplicate slugs (10 → 1)
- **Unique Resources**: Increased from 1,170 to 1,184 unique slugs
- **Backup Protection**: Automatic backups before corrections
- **Compliance Reporting**: Detailed metrics and change documentation

#### `auto_add_missing.sh` 🤖 (NEW)
**Purpose:** Automated batch addition of missing resources with prioritization
- Intelligently prioritizes resources by category (AI, security, networking)
- Batch processing with user confirmation
- Automatic documentation updates
- Progress tracking and comprehensive reporting

**Usage:**
```bash
./auto_add_missing.sh  # Add prioritized missing resources automatically
```

### Utilities

#### `cleanup_tools.sh` 🧹
**Purpose:** Tools directory maintenance and consolidation
- Consolidates obsolete scripts
- Creates backups before changes
- Maintains clean tool ecosystem

**Usage:**
```bash
./cleanup_tools.sh  # Clean and organize tools directory
```

## Workflow Examples

### Adding New Resources
```bash
# Method 1: Authoritative CAF sync with corrections
./enhanced_sync_official_resources_caf.sh

# Method 2: Complete workflow with CAF enforcement
./workflow.sh sync

# Method 3: Manual addition from list
echo -e "azurerm_new_service\nazurerm_another_service" > new_resources.txt
./add_azure_resources.sh new_resources.txt

# Update documentation after changes
./generate_documentation.sh
```

### Analysis and Reporting
```bash
# Analyze current implementation with CAF compliance
./analyze_azure_resources.sh

# Apply authoritative CAF corrections and sync
./enhanced_sync_official_resources_caf.sh

# Complete workflow with CAF enforcement
./workflow.sh all

# Validate CAF compliance
./workflow.sh test

# Update all documentation
./generate_documentation.sh --all
```

### CAF Compliance Workflow
```bash
# Apply authoritative CAF corrections
./workflow.sh sync

# Validate compliance status  
./workflow.sh test

# Generate compliance reports
./enhanced_sync_official_resources_caf.sh

# Complete CAF workflow demonstration
./workflow.sh all
```

## File Structure

```
tools/
├── README.md                               # This file
├── enhanced_sync_official_resources_caf.sh # Authoritative CAF compliance engine (v4.0)
├── sync_official_resources.sh              # Legacy sync (audit-only)
├── workflow.sh                             # Master CAF workflow orchestrator (v4.0)
├── add_azure_resources.sh                  # General resource addition
├── analyze_azure_resources.sh              # Resource analysis with compliance metrics
├── generate_documentation.sh               # Unified documentation
├── update_resource_status.sh               # README maintenance
├── auto_add_missing.sh                     # Automated batch addition
├── cleanup_tools.sh                        # Tools directory maintenance
├── caf_compliance_report_*.md              # CAF compliance reports (generated)
├── caf_sync_log_*.log                      # Sync operation logs (generated)
└── backup_*/                               # Automatic backups
```

## Configuration

All scripts automatically detect project structure and locate:
- `resourceDefinition.json` - Main resource definitions
- `README.md` - Project documentation  
- `docs/` - Extended documentation

## Dependencies

Required tools:
- `jq` - JSON processing
- `curl` - HTTP requests (for sync script)
- `grep`, `awk`, `sed` - Text processing

Install on Ubuntu/Debian:
```bash
sudo apt-get install jq curl
```

## Logging

Scripts generate timestamped log files in the tools directory:
- `sync_log_YYYYMMDD_HHMMSS.log`
- `analysis_log_YYYYMMDD_HHMMSS.log`

## Support

For issues or questions about these tools, please check:
1. Script help output: `script_name.sh --help`
2. Log files for detailed error information
3. Project README.md for general guidance

---
*Maintained by the Azure CAF Team*
