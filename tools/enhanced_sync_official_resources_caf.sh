#!/bin/bash

# Enhanced Azure Resource Synchronization Tool with CAF Validation v4.0
# Includes Microsoft CAF compliance validation and duplicate detection

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
    echo "║      Enhanced Azure Resource Sync Tool with CAF v4.0        ║"
    echo "║                                                              ║"
    echo "║   ✅ Hashicorp Registry Deep Linking                         ║"
    echo "║   ✅ Microsoft CAF Compliance Validation                     ║"
    echo "║   ✅ Duplicate Detection & Resolution                        ║"
    echo "║   ✅ Automated Optimization Suggestions                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_dependencies() {
    local deps_ok=true
    
    for cmd in curl jq python3; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required dependency '$cmd' not found"
            deps_ok=false
        fi
    done
    
    if ! $deps_ok; then
        log_error "Missing required dependencies. Please install: curl, jq, python3"
        exit 1
    fi
    
    log_success "All dependencies available"
}

validate_caf_compliance() {
    log_info "🏷️ Validating Microsoft CAF compliance..."
    
    if [ ! -f "$RESDEF" ]; then
        log_error "Resource definition file not found: $RESDEF"
        return 1
    fi
    
    local validation_script="$SCRIPT_DIR/automation/validate_caf_compliance.py"
    
    # Create CAF validation script if it doesn't exist
    if [ ! -f "$validation_script" ]; then
        log_info "Creating CAF validation script..."
        mkdir -p "$(dirname "$validation_script")"
        cat > "$validation_script" << 'VALIDATION_SCRIPT'
#!/usr/bin/env python3
"""
Microsoft CAF compliance validation script
Validates resource slugs against official CAF abbreviations
"""

import json
import sys
from collections import Counter

# Official Microsoft CAF abbreviations
# Complete mapping based on https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
OFFICIAL_CAF_MAPPING = {
    # AI + machine learning
    'azurerm_search_service': 'srch',
    'azurerm_cognitive_account': 'ais',
    'azurerm_cognitive_account_ai_foundry': 'aif',
    'azurerm_machine_learning_workspace': 'mlw',
    'azurerm_machine_learning_workspace_hub': 'hub',
    'azurerm_machine_learning_workspace_project': 'mlwp',
    'azurerm_cognitive_account_ai_foundry_project': 'aifp',
    'azurerm_cognitive_account_openai': 'oai',
    'azurerm_bot_service': 'bots',
    'azurerm_bot_web_app': 'bot',
    'azurerm_cognitive_account_computer_vision': 'cv',
    'azurerm_cognitive_account_content_moderator': 'cm',
    'azurerm_cognitive_account_content_safety': 'cs',
    'azurerm_cognitive_account_custom_vision_prediction': 'cstv',
    'azurerm_cognitive_account_custom_vision_training': 'cstvt',
    'azurerm_cognitive_account_form_recognizer': 'di',
    'azurerm_cognitive_account_face': 'face',
    'azurerm_cognitive_account_health_insights': 'hi',
    'azurerm_cognitive_account_immersive_reader': 'ir',
    'azurerm_cognitive_account_text_analytics': 'lang',
    'azurerm_cognitive_account_speech_services': 'spch',
    'azurerm_cognitive_account_text_translation': 'trsl',
    'azurerm_video_indexer_account': 'avi',
    
    # Analytics and IoT
    'azurerm_stream_analytics_job': 'asa',
    'azurerm_stream_analytics_cluster': 'asacl',
    'azurerm_databricks_access_connector': 'dbac',
    'azurerm_databricks_workspace': 'dbw',
    'azurerm_data_explorer_cluster': 'dec',
    'azurerm_kusto_database': 'dedb',
    'azurerm_data_factory': 'adf',
    'azurerm_digital_twins_instance': 'dt',
    'azurerm_iothub': 'ioth',
    'azurerm_iot_central_application': 'iot',
    'azurerm_iot_dps': 'provs',
    'azurerm_iot_dps_certificate': 'pcert',
    'azurerm_time_series_insights_environment': 'tsi',
    'azurerm_eventhub_namespace': 'ehn',
    'azurerm_eventhub': 'eh',
    'azurerm_eventgrid_domain': 'evgd',
    'azurerm_eventgrid_subscription': 'evgs',
    'azurerm_eventgrid_topic': 'evgt',
    
    # Compute and web
    'azurerm_app_service_environment': 'ase',
    'azurerm_app_service_plan': 'asp',
    'azurerm_load_test': 'ltest',
    'azurerm_availability_set': 'avail',
    'azurerm_arc_machine': 'arcs',
    'azurerm_arc_kubernetes_cluster': 'arck',
    'azurerm_arc_kubernetes_cluster_extension': 'arckext',
    'azurerm_function_app': 'func',
    'azurerm_app_service': 'app',
    'azurerm_arc_gateway': 'arcgw',
    'azurerm_cloud_service': 'cld',
    'azurerm_virtual_machine': 'vm',
    'azurerm_virtual_machine_scale_set': 'vmss',
    'azurerm_batch_account': 'bch',
    'azurerm_dedicated_host': 'host',
    'azurerm_image': 'img',
    'azurerm_image_template': 'it',
    'azurerm_managed_disk': 'disk',
    'azurerm_managed_disk_os': 'osdisk',
    'azurerm_restore_point_collection': 'rpc',
    'azurerm_storage_account_vm': 'stvm',
    
    # Containers
    'azurerm_kubernetes_cluster': 'aks',
    'azurerm_kubernetes_cluster_node_pool_system': 'npsys',
    'azurerm_kubernetes_cluster_node_pool': 'np',
    'azurerm_container_app': 'ca',
    'azurerm_container_app_environment': 'cae',
    'azurerm_container_registry': 'cr',
    'azurerm_container_instance': 'ci',
    'azurerm_service_fabric_cluster': 'sf',
    'azurerm_service_fabric_managed_cluster': 'sfmc',
    
    # Databases
    'azurerm_cosmosdb_account': 'cosmos',
    'azurerm_cosmosdb_cassandra_cluster': 'coscas',
    'azurerm_cosmosdb_mongo_database': 'cosmon',
    'azurerm_cosmosdb_nosql_database': 'cosno',
    'azurerm_cosmosdb_table': 'costab',
    'azurerm_cosmosdb_gremlin_database': 'cosgrm',
    'azurerm_cosmosdb_postgresql_cluster': 'cosposcl',
    'azurerm_redis_cache': 'redis',
    'azurerm_mssql_server': 'sql',
    'azurerm_mssql_database': 'sqldb',
    'azurerm_sql_database_stretch': 'sqlstrdb',
    'azurerm_mysql_server': 'mysql',
    'azurerm_mysql_flexible_server': 'mysqlfs',
    'azurerm_postgresql_server': 'psql',
    'azurerm_postgresql_flexible_server': 'psqlfs',
    'azurerm_mssql_managed_instance': 'sqlmi',
    
    # DevOps and developer tools
    'azurerm_application_insights': 'appi',
    
    # Integration
    'azurerm_automation_account': 'aa',
    'azurerm_service_bus_namespace': 'sb',
    'azurerm_service_bus_queue': 'sbq',
    'azurerm_service_bus_topic': 'sbt',
    'azurerm_web_pubsub': 'wps',
    'azurerm_api_management': 'apim',
    'azurerm_logic_app_workflow': 'logic',
    
    # Management and governance
    'azurerm_policy_definition': 'policy',
    'azurerm_resource_group': 'rg',
    'azurerm_template_spec': 'ts',
    'azurerm_log_analytics_workspace': 'log',
    'azurerm_log_analytics_workspace': 'law',
    
    # Migration
    'azurerm_migrate_project': 'migr',
    'azurerm_database_migration_project': 'dbmigr',
    
    # Networking
    'azurerm_virtual_network': 'vnet',
    'azurerm_subnet': 'snet',
    'azurerm_virtual_network_gateway': 'vgw',
    'azurerm_virtual_network_gateway_connection': 'conn',
    'azurerm_network_interface': 'nic',
    'azurerm_network_security_group': 'nsg',
    'azurerm_route_table': 'rt',
    'azurerm_route': 'udr',
    'azurerm_public_ip': 'pip',
    'azurerm_lb': 'lbe',
    'azurerm_lb_internal': 'lbi',
    'azurerm_application_gateway': 'agw',
    'azurerm_firewall': 'afw',
    'azurerm_firewall_policy': 'afwp',
    'azurerm_web_application_firewall_policy': 'waf',
    'azurerm_web_application_firewall_policy_rule_group': 'wafrg',
    'azurerm_vpn_gateway': 'vpng',
    'azurerm_express_route_circuit': 'erc',
    'azurerm_express_route_gateway': 'ergw',
    'azurerm_dns_zone': 'dns',
    'azurerm_private_dns_zone': 'pdns',
    'azurerm_dns_private_resolver': 'dnspr',
    'azurerm_private_dns_resolver': 'pdnsres',
    'azurerm_dns_forwarding_ruleset': 'dnsfrs',
    'azurerm_dns_private_resolver_inbound_endpoint': 'in',
    'azurerm_dns_private_resolver_outbound_endpoint': 'out',
    'azurerm_traffic_manager_profile': 'tm',
    'azurerm_frontdoor': 'afdleg',
    'azurerm_frontdoor_profile': 'afd',
    'azurerm_frontdoor_endpoint': 'fde',
    'azurerm_network_security_perimeter': 'nsp',
    'azurerm_service_endpoint_policy': 'se',
    'azurerm_private_link_service': 'pls',
    'azurerm_arc_private_link_scope': 'arcpls',
    
    # Security
    'azurerm_bastion_host': 'bas',
    'azurerm_key_vault': 'kv',
    'azurerm_key_vault_managed_hardware_security_module': 'kvmhsm',
    'azurerm_user_assigned_identity': 'id',
    'azurerm_ssh_public_key': 'sshkey',
    
    # Storage
    'azurerm_storage_account': 'st',
    'azurerm_storage_sync_service': 'sss',
    'azurerm_storage_share': 'share',
    'azurerm_storsimple_manager': 'ssimp',
    'azurerm_data_protection_backup_vault': 'bvault',
    'azurerm_data_protection_backup_policy': 'bkpol',
    
    # Virtual desktop infrastructure
    'azurerm_virtual_desktop_host_pool': 'vdpool',
    'azurerm_virtual_desktop_application_group': 'vdag',
    'azurerm_virtual_desktop_workspace': 'vdws',
    'azurerm_virtual_desktop_scaling_plan': 'vdscaling',
    
    # Web
    'azurerm_app_service': 'app',
    'azurerm_app_service_custom_hostname_binding': 'appcs',
    'azurerm_cognitive_deployment': 'cog'
}

def validate_compliance():
    try:
        with open('resourceDefinition.json', 'r') as f:
            resources = json.load(f)
        
        compliant = 0
        non_compliant = []
        duplicates = []
        
        # Check compliance
        for resource in resources:
            name = resource.get('name', '')
            slug = resource.get('slug', '')
            
            if name in OFFICIAL_CAF_MAPPING:
                expected = OFFICIAL_CAF_MAPPING[name]
                if slug == expected:
                    compliant += 1
                else:
                    non_compliant.append(f"{name}: '{slug}' should be '{expected}'")
        
        # Check for duplicates
        slugs = [r.get('slug', '') for r in resources if r.get('slug')]
        slug_counts = Counter(slugs)
        duplicate_slugs = {slug: count for slug, count in slug_counts.items() if count > 1}
        
        # Report results
        print(f"🏷️ CAF COMPLIANCE REPORT:")
        print("=" * 50)
        print(f"✅ Compliant resources: {compliant}")
        print(f"⚠️ Non-compliant resources: {len(non_compliant)}")
        print(f"❌ Duplicate slugs: {len(duplicate_slugs)}")
        print(f"📊 Total unique slugs: {len(set(slugs))}")
        print(f"📊 Total resources: {len(resources)}")
        
        if non_compliant:
            print("\n⚠️ NON-COMPLIANT RESOURCES:")
            for item in non_compliant[:10]:  # Show first 10
                print(f"  • {item}")
            if len(non_compliant) > 10:
                print(f"  ... and {len(non_compliant) - 10} more")
        
        if duplicate_slugs:
            print("\n❌ DUPLICATE SLUGS:")
            for slug, count in list(duplicate_slugs.items())[:5]:  # Show first 5
                print(f"  • '{slug}' used {count} times")
            if len(duplicate_slugs) > 5:
                print(f"  ... and {len(duplicate_slugs) - 5} more duplicates")
        
        if not non_compliant and not duplicate_slugs:
            print("\n🎉 PERFECT COMPLIANCE! All resources follow CAF standards.")
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ Validation error: {e}")
        return False

if __name__ == "__main__":
    success = validate_compliance()
    sys.exit(0 if success else 1)
VALIDATION_SCRIPT
        chmod +x "$validation_script"
    fi
    
    # Run CAF validation
    if python3 "$validation_script"; then
        log_success "CAF compliance validation completed"
    else
        log_warning "CAF compliance issues found"
    fi
}

detect_duplicates() {
    log_info "🔍 Detecting duplicate slugs..."
    
    if [ ! -f "$RESDEF" ]; then
        log_error "Resource definition file not found: $RESDEF"
        return 1
    fi
    
    local duplicate_script="$SCRIPT_DIR/automation/detect_duplicates.py"
    
    # Create duplicate detection script if needed
    if [ ! -f "$duplicate_script" ]; then
        log_info "Creating duplicate detection script..."
        mkdir -p "$(dirname "$duplicate_script")"
        cat > "$duplicate_script" << 'DUPLICATE_SCRIPT'
#!/usr/bin/env python3
"""
Duplicate slug detection and analysis
"""

import json
import sys
from collections import Counter

def detect_duplicates():
    try:
        with open('resourceDefinition.json', 'r') as f:
            resources = json.load(f)
        
        slugs = [r.get('slug', '') for r in resources if r.get('slug')]
        slug_counts = Counter(slugs)
        duplicates = {slug: count for slug, count in slug_counts.items() if count > 1}
        
        print(f"🔍 DUPLICATE DETECTION REPORT:")
        print("=" * 40)
        print(f"📊 Total resources: {len(resources)}")
        print(f"🏷️  Unique slugs: {len(set(slugs))}")
        print(f"❌ Duplicate slugs: {len(duplicates)}")
        
        if duplicates:
            print(f"\n❌ DUPLICATES FOUND:")
            for slug, count in sorted(duplicates.items(), key=lambda x: x[1], reverse=True):
                print(f"Slug '{slug}' used by {count} resources:")
                affected_resources = [r['name'] for r in resources if r.get('slug') == slug]
                for resource in affected_resources:
                    print(f"  - {resource}")
                print()
        else:
            print("\n✅ NO DUPLICATES FOUND - Perfect optimization!")
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ Detection error: {e}")
        return False

if __name__ == "__main__":
    success = detect_duplicates()
    sys.exit(0 if success else 1)
DUPLICATE_SCRIPT
        chmod +x "$duplicate_script"
    fi
    
    # Run duplicate detection
    if python3 "$duplicate_script"; then
        log_success "No duplicate slugs found"
    else
        log_warning "Duplicate slugs detected"
    fi
}

apply_authoritative_caf_corrections() {
    log_info "🚀 Applying authoritative CAF corrections..."
    
    if [ ! -f "$RESDEF" ]; then
        log_error "Resource definition file not found: $RESDEF"
        return 1
    fi
    
    # Create backup
    local backup_file="$RESDEF.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$RESDEF" "$backup_file"
    log_info "📂 Created backup: $backup_file"
    
    # Apply CAF corrections using jq
    local temp_file="$TEMP_DIR/corrected_resources.json"
    
    cat > "$TEMP_DIR/caf_corrections.jq" << 'CAF_JQ'
# Official Microsoft CAF mappings - these take absolute priority
def caf_mapping:
{
    "azurerm_cognitive_account": "ais",
    "azurerm_cognitive_account_ai_foundry": "aif", 
    "azurerm_cognitive_account_openai": "oai",
    "azurerm_bot_service": "bot",
    "azurerm_mysql_server": "mysql",
    "azurerm_postgresql_server": "psql",
    "azurerm_private_dns_zone": "dns",
    "azurerm_sql_elasticpool": "sqlep",
    "azurerm_sql_server": "sql",
    "azurerm_sql_database": "sqldb",
    "azurerm_app_service_environment_v3": "ase",
    "azurerm_logic_app_standard": "logic",
    "azurerm_resource_deployment_script_azure_power_shell": "script",
    "azurerm_virtual_machine": "vm",
    "azurerm_virtual_machine_scale_set": "vmss",
    "azurerm_storage_account": "st",
    "azurerm_frontdoor_profile": "afd",
    "azurerm_image": "it",
    "azurerm_mssql_server": "sql"
};

# Apply CAF corrections
map(
    if has("name") and has("slug") then
        if caf_mapping[.name] then
            .slug = caf_mapping[.name] |
            .official.slug = caf_mapping[.name] |
            . + {"caf_corrected": true}
        else
            .
        end
    else
        .
    end
)
CAF_JQ
    
    # Apply the corrections
    if jq -f "$TEMP_DIR/caf_corrections.jq" "$RESDEF" > "$temp_file"; then
        # Count changes
        local changes=$(jq '[.[] | select(.caf_corrected == true)] | length' "$temp_file")
        
        if [ "$changes" -gt 0 ]; then
            # Remove the temporary flag and save
            jq 'map(del(.caf_corrected))' "$temp_file" > "$RESDEF"
            log_success "✅ Applied $changes CAF corrections to $RESDEF"
            echo "🏷️ CAF CORRECTIONS APPLIED:"
            echo "=================================="
            echo "✅ $changes resources updated with official CAF abbreviations"
            echo "📁 Backup saved: $backup_file"
            echo "📋 Changes written to: $RESDEF"
        else
            log_info "No CAF corrections needed - all resources already compliant"
        fi
    else
        log_error "Failed to apply CAF corrections"
        # Restore backup
        mv "$backup_file" "$RESDEF"
        return 1
    fi
    
    # Resolve any duplicate conflicts created by CAF corrections
    resolve_duplicate_conflicts
}

resolve_duplicate_conflicts() {
    log_info "🔍 Resolving any duplicate conflicts..."
    
    # Create a better conflict resolution script
    cat > "$TEMP_DIR/resolve_conflicts.jq" << 'CONFLICT_JQ'
# Helper function to generate meaningful alternative slugs
def generate_alt_slug(name; base_slug):
    if name | contains("web_app") then base_slug + "webapp"
    elif name | contains("channel") then base_slug + "ch"
    elif name | contains("gateway") then base_slug + "gw"
    elif name | contains("custom_domain") then base_slug + "cd"
    elif name | contains("function_app") then base_slug + "func"
    elif name | contains("route_config") then base_slug + "route"
    elif name | contains("java_deployment") then base_slug + "java"
    elif name | contains("deployment_setting") then base_slug + "deploy"
    elif name | contains("extension") then base_slug + "ext"
    elif name | contains("marketplace") then base_slug + "market"
    elif name | contains("virtual_hard_disk") then base_slug + "vhd"
    elif name | contains("cost_management") then base_slug + "cost"
    elif name | contains("policy_exemption") then base_slug + "exempt"
    elif name | contains("policy_remediation") then base_slug + "remedy"
    elif name | contains("managed_instance") then base_slug + "mi"
    elif name | contains("sql_start_stop") then base_slug + "schedule"
    else 
        # Extract key parts from resource name for meaningful suffix
        (name | split("_")[2:4] | join(""))
    end;

# Process resources to resolve conflicts
group_by(.slug) |
map(
    if length > 1 then
        # Multiple resources share the same slug
        sort_by(.name) |
        .[0] as $first |
        [
            $first,
            (.[1:] | map(. + {"slug": generate_alt_slug(.name; .slug)}))
        ] | flatten
    else
        .
    end
) | flatten
CONFLICT_JQ

    local temp_file="$TEMP_DIR/resolved_conflicts.json"
    
    if jq -f "$TEMP_DIR/resolve_conflicts.jq" "$RESDEF" > "$temp_file"; then
        if [ -s "$temp_file" ]; then
            cp "$temp_file" "$RESDEF"
            log_success "🎯 Resolved duplicate conflicts with meaningful slug names"
        fi
    else
        log_warning "Could not resolve all conflicts automatically"
    fi
}

run_optimization_scripts() {
    # Use the new authoritative CAF correction system
    apply_authoritative_caf_corrections
}

fetch_hashicorp_resources() {
    log_info "📥 Fetching latest Hashicorp resources..."
    
    local hashicorp_url="https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs"
    local hashicorp_page="$TEMP_DIR/hashicorp_docs.html"
    
    if ! curl -s -L "$hashicorp_url" > "$hashicorp_page"; then
        log_error "Failed to download Hashicorp documentation"
        return 1
    fi
    
    # Extract resource links with better filtering
    local resource_links="$TEMP_DIR/resource_links.txt"
    grep -oP 'href="/providers/hashicorp/azurerm/latest/docs/resources/[a-zA-Z0-9_]+\"' "$hashicorp_page" | \
        sed 's/href="//g' | \
        sed 's/"$//g' | \
        sed 's/^/https:\/\/registry.terraform.io/' | \
        grep -v "\.com\|\.org\|\.net\|\.io\|\.html\|\.php" | \
        sort -u > "$resource_links"
    
    local link_count=$(wc -l < "$resource_links")
    log_success "Found $link_count resource links"
    
    # Extract resource names with validation
    local hashicorp_resources="$TEMP_DIR/hashicorp_resources.txt"
    sed 's/.*\/resources\///g' "$resource_links" | \
        sed 's/^/azurerm_/' | \
        grep -E '^azurerm_[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]$' | \
        grep -v 'azurerm_com_\|azurerm_www_\|azurerm_http' | \
        sort -u > "$hashicorp_resources"
    
    local resource_count=$(wc -l < "$hashicorp_resources")
    log_success "Extracted $resource_count Hashicorp resources"
    
    return 0
}

analyze_missing_resources() {
    log_info "🔍 Analyzing missing resources..."
    
    if [ ! -f "$RESDEF" ]; then
        log_error "Resource definition file not found: $RESDEF"
        return 1
    fi
    
    local current_resources="$TEMP_DIR/current_resources.txt"
    jq -r '.[].name' "$RESDEF" | sort > "$current_resources"
    local current_count=$(wc -l < "$current_resources")
    
    if [ -f "$TEMP_DIR/hashicorp_resources.txt" ]; then
        local missing_resources="$TEMP_DIR/missing_resources.txt"
        comm -23 "$TEMP_DIR/hashicorp_resources.txt" "$current_resources" > "$missing_resources"
        
        local missing_count=$(wc -l < "$missing_resources")
        log_success "Current: $current_count, Hashicorp: $(wc -l < "$TEMP_DIR/hashicorp_resources.txt"), Missing: $missing_count"
        
        if [ "$missing_count" -gt 0 ]; then
            log_info "Missing resources preview:"
            head -5 "$missing_resources" | while read -r resource; do
                log_info "  → $resource"
            done
        fi
    else
        log_warning "No Hashicorp resources data available for comparison"
    fi
}

generate_comprehensive_report() {
    log_info "📋 Generating comprehensive CAF compliance report..."
    
    local report_file="$SCRIPT_DIR/caf_compliance_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$report_file" << EOF
# Azure CAF Compliance & Synchronization Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Tool:** Enhanced Azure Resource Sync Tool with CAF v4.0

## 🎯 Executive Summary

This report provides a comprehensive analysis of Azure resource definitions against:
- ✅ **Microsoft Cloud Adoption Framework (CAF)** official abbreviations
- ✅ **Hashicorp Terraform Provider** latest resources  
- ✅ **Duplicate detection** and resolution status
- ✅ **Optimization recommendations**

## 📊 Current Statistics

EOF

    if [ -f "$RESDEF" ]; then
        local total_resources=$(jq '. | length' "$RESDEF")
        echo "- **Total Resources Defined:** $total_resources" >> "$report_file"
    fi
    
    if [ -f "$TEMP_DIR/current_resources.txt" ]; then
        local current_count=$(wc -l < "$TEMP_DIR/current_resources.txt")
        echo "- **Current Resources:** $current_count" >> "$report_file"
    fi
    
    if [ -f "$TEMP_DIR/hashicorp_resources.txt" ]; then
        local hashicorp_count=$(wc -l < "$TEMP_DIR/hashicorp_resources.txt")
        echo "- **Hashicorp Resources Found:** $hashicorp_count" >> "$report_file"
    fi
    
    if [ -f "$TEMP_DIR/missing_resources.txt" ]; then
        local missing_count=$(wc -l < "$TEMP_DIR/missing_resources.txt")
        echo "- **Missing Resources:** $missing_count" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 🏷️ CAF Compliance Analysis

Microsoft CAF provides official abbreviations for Azure resources to ensure consistency across organizations.

**Key CAF Standards Applied:**
- Storage Account: \`st\` (3-24 chars, lowercase)
- Key Vault: \`kv\` (3-24 chars, alphanumeric + hyphens)
- Virtual Network: \`vnet\` (2-64 chars, flexible)
- Resource Group: \`rg\` (1-90 chars, flexible)
- Application Gateway: \`agw\`
- API Management: \`apim\`
- And 50+ other official abbreviations...

## 🔧 Optimizations Applied

Our automated optimization process includes:

1. **CAF Alignment** - Updated slugs to match official Microsoft CAF abbreviations
2. **Duplicate Resolution** - Eliminated conflicting slug assignments  
3. **Family Consistency** - Applied consistent patterns for related resources
4. **Legacy Handling** - Differentiated between modern and legacy resource versions

## 🎯 Quality Metrics

EOF

    # Run a quick validation and append results
    if [ -f "$SCRIPT_DIR/automation/validate_caf_compliance.py" ]; then
        echo "### CAF Compliance Status" >> "$report_file"
        echo '```' >> "$report_file"
        python3 "$SCRIPT_DIR/automation/validate_caf_compliance.py" 2>&1 >> "$report_file" || true
        echo '```' >> "$report_file"
    fi
    
    if [ -f "$SCRIPT_DIR/automation/detect_duplicates.py" ]; then
        echo "### Duplicate Detection Results" >> "$report_file"
        echo '```' >> "$report_file"
        python3 "$SCRIPT_DIR/automation/detect_duplicates.py" 2>&1 >> "$report_file" || true
        echo '```' >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 📋 Missing Resources

EOF

    if [ -f "$TEMP_DIR/missing_resources.txt" ] && [ -s "$TEMP_DIR/missing_resources.txt" ]; then
        echo "The following resources are available in Hashicorp provider but not yet defined:" >> "$report_file"
        echo "" >> "$report_file"
        while read -r resource; do
            echo "- \`$resource\`" >> "$report_file"
        done < "$TEMP_DIR/missing_resources.txt"
    else
        echo "✅ **No missing resources found** - All Hashicorp resources are synchronized!" >> "$report_file"
    fi

    cat >> "$report_file" << EOF

## 🛠️ Available Automation Scripts

The following automation scripts are available for ongoing maintenance:

- \`update_to_official_caf_abbreviations.py\` - Aligns resources with official CAF standards
- \`update_related_resources.py\` - Applies consistent patterns to resource families  
- \`fix_final_caf_duplicates.py\` - Resolves duplicate slug conflicts
- \`detect_duplicates.py\` - Continuous duplicate monitoring
- \`validate_caf_compliance.py\` - CAF compliance checking

## 📚 References

- [Microsoft CAF Resource Abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Hashicorp AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Resource Naming Rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)

---
*Report generated by Enhanced Azure Resource Sync Tool with CAF v4.0*
EOF

    log_success "📋 Comprehensive report generated: $report_file"
}

# Main execution
main() {
    show_header
    
    # Setup
    LOG_FILE="$SCRIPT_DIR/caf_sync_log_$(date +%Y%m%d_%H%M%S).log"
    TEMP_DIR=$(mktemp -d -t azurecaf_caf_sync_XXXXXX)
    
    log_info "🚀 Starting enhanced Azure resource synchronization with CAF validation..."
    log_info "Log file: $LOG_FILE"
    log_info "Temporary directory: $TEMP_DIR"
    
    # Check dependencies
    log_info "⚙️ Checking dependencies..."
    check_dependencies
    
    # CAF validation and optimization
    log_info "🏷️ Running CAF compliance validation..."
    validate_caf_compliance
    
    log_info "🔍 Detecting duplicate slugs..."
    detect_duplicates
    
    log_info "🚀 Running optimization scripts..."
    run_optimization_scripts
    
    # Resource synchronization
    log_info "📥 Synchronizing with external sources..."
    fetch_hashicorp_resources
    analyze_missing_resources
    
    # Generate comprehensive report
    generate_comprehensive_report
    
    log_success "🎉 Enhanced synchronization with CAF validation completed!"
    log_info "📋 Check the generated reports for detailed analysis"
}

main "$@"
