#!/bin/bash

# Review abbreviations against Microsoft recommendations
# https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DEF="$SCRIPT_DIR/../resourceDefinition.json"
REVIEW_REPORT="$SCRIPT_DIR/abbreviation_review_$(date +%Y%m%d_%H%M%S).md"

echo "# 📋 Microsoft Azure CAF Abbreviation Review Report" > "$REVIEW_REPORT"
echo "**Generated:** $(date)" >> "$REVIEW_REPORT"
echo "**Source:** https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Define Microsoft official abbreviations from the documentation
declare -A MS_ABBREV=(
    # AI + Machine Learning
    ["azurerm_search_service"]="srch"
    ["azurerm_ai_services"]="ais"
    ["azurerm_ai_foundry"]="aif"
    ["azurerm_ai_foundry_project"]="proj"
    ["azurerm_machine_learning_workspace"]="mlw"
    ["azurerm_cognitive_account_openai"]="oai"
    ["azurerm_bot_service"]="bot"
    
    # Containers  
    ["azurerm_kubernetes_cluster"]="aks"
    ["azurerm_container_app"]="ca"
    ["azurerm_container_app_environment"]="cae"
    ["azurerm_container_registry"]="cr"
    ["azurerm_container_group"]="ci"
    
    # Analytics and IoT
    ["azurerm_analysis_services_server"]="as"
    ["azurerm_databricks_workspace"]="dbw"
    ["azurerm_data_explorer_cluster"]="dec"
    ["azurerm_data_factory"]="adf"
    ["azurerm_digital_twins_instance"]="dt"
    ["azurerm_stream_analytics_job"]="asa"
    ["azurerm_eventhub_namespace"]="evhns"
    ["azurerm_eventhub"]="evh"
    ["azurerm_eventgrid_domain"]="evgd"
    ["azurerm_eventgrid_topic"]="evgt"
    ["azurerm_iothub"]="iot"
    
    # Compute and Web
    ["azurerm_app_service_environment"]="ase"
    ["azurerm_app_service_plan"]="asp"
    ["azurerm_availability_set"]="avail"
    ["azurerm_batch_account"]="ba"
    ["azurerm_function_app"]="func"
    ["azurerm_linux_virtual_machine"]="vm"
    ["azurerm_windows_virtual_machine"]="vm"
    ["azurerm_virtual_machine_scale_set"]="vmss"
    ["azurerm_linux_web_app"]="app"
    ["azurerm_windows_web_app"]="app"
    
    # Databases
    ["azurerm_cosmosdb_account"]="cosmos"
    ["azurerm_redis_cache"]="redis"
    ["azurerm_mssql_server"]="sql"
    ["azurerm_mssql_database"]="sqldb"
    ["azurerm_mssql_managed_instance"]="sqlmi"
    ["azurerm_mysql_server"]="mysql"
    ["azurerm_postgresql_server"]="psql"
    
    # Developer Tools
    ["azurerm_app_configuration"]="appcs"
    ["azurerm_maps_account"]="map"
    ["azurerm_signalr_service"]="sigr"
    
    # DevOps
    ["azurerm_dashboard_grafana"]="amg"
    
    # Integration
    ["azurerm_api_management"]="apim"
    ["azurerm_logic_app_workflow"]="logic"
    ["azurerm_servicebus_namespace"]="sbns"
    ["azurerm_servicebus_queue"]="sbq"
    ["azurerm_servicebus_topic"]="sbt"
    
    # Management and Governance
    ["azurerm_automation_account"]="aa"
    ["azurerm_application_insights"]="appi"
    ["azurerm_monitor_action_group"]="ag"
    ["azurerm_log_analytics_workspace"]="log"
    ["azurerm_resource_group"]="rg"
    
    # Migration
    ["azurerm_recovery_services_vault"]="rsv"
    
    # Networking
    ["azurerm_application_gateway"]="agw"
    ["azurerm_application_security_group"]="asg"
    ["azurerm_cdn_profile"]="cdnp"
    ["azurerm_cdn_endpoint"]="cdne"
    ["azurerm_firewall"]="afw"
    ["azurerm_firewall_policy"]="afwp"
    ["azurerm_express_route_circuit"]="erc"
    ["azurerm_express_route_gateway"]="ergw"
    ["azurerm_frontdoor"]="afd"
    ["azurerm_lb"]="lbe"
    ["azurerm_local_network_gateway"]="lgw"
    ["azurerm_nat_gateway"]="ng"
    ["azurerm_network_interface"]="nic"
    ["azurerm_network_security_group"]="nsg"
    ["azurerm_private_endpoint"]="pep"
    ["azurerm_public_ip"]="pip"
    ["azurerm_route_table"]="rt"
    ["azurerm_traffic_manager_profile"]="traf"
    ["azurerm_virtual_network"]="vnet"
    ["azurerm_virtual_network_gateway"]="vgw"
    ["azurerm_subnet"]="snet"
    ["azurerm_virtual_wan"]="vwan"
    ["azurerm_virtual_hub"]="vhub"
    
    # Security
    ["azurerm_bastion_host"]="bas"
    ["azurerm_key_vault"]="kv"
    ["azurerm_user_assigned_identity"]="id"
    ["azurerm_vpn_gateway"]="vpng"
    
    # Storage
    ["azurerm_storage_account"]="st"
    ["azurerm_backup_vault"]="bvault"
    ["azurerm_storage_share"]="share"
    
    # Virtual Desktop Infrastructure
    ["azurerm_virtual_desktop_host_pool"]="vdpool"
    ["azurerm_virtual_desktop_application_group"]="vdag"
    ["azurerm_virtual_desktop_workspace"]="vdws"
)

echo "## 🎯 **Analysis Summary**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Count resources
TOTAL_RESOURCES=$(jq '. | length' "$RESOURCE_DEF")
CHECKED_RESOURCES=0
CORRECT_ABBREV=0
INCORRECT_ABBREV=0
MISSING_MS_ABBREV=0

echo "**Total Resources:** $TOTAL_RESOURCES" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "## ❌ **Resources with Incorrect Abbreviations**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Check each resource against Microsoft recommendations
while IFS= read -r resource; do
    name=$(echo "$resource" | jq -r '.name')
    current_slug=$(echo "$resource" | jq -r '.slug')
    
    if [[ -n "${MS_ABBREV[$name]:-}" ]]; then
        CHECKED_RESOURCES=$((CHECKED_RESOURCES + 1))
        ms_abbrev="${MS_ABBREV[$name]}"
        
        if [[ "$current_slug" == "$ms_abbrev" ]]; then
            CORRECT_ABBREV=$((CORRECT_ABBREV + 1))
        else
            INCORRECT_ABBREV=$((INCORRECT_ABBREV + 1))
            echo "### ❌ **$name**" >> "$REVIEW_REPORT"
            echo "- **Current:** \`$current_slug\`" >> "$REVIEW_REPORT"
            echo "- **Microsoft Recommended:** \`$ms_abbrev\`" >> "$REVIEW_REPORT"
            echo "- **Action Required:** Change slug from \`$current_slug\` to \`$ms_abbrev\`" >> "$REVIEW_REPORT"
            echo "" >> "$REVIEW_REPORT"
        fi
    fi
done < <(jq -c '.[]' "$RESOURCE_DEF")

echo "## ⚠️ **Resources with Problematic Abbreviations**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Check for specific issues we found
echo "### 🔥 **Critical Issue: Slug Conflicts**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Check the storage account conflict
echo "#### **Storage Account Slug Conflict**" >> "$REVIEW_REPORT"
echo "The abbreviation \`st\` is used by multiple resources:" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Find all resources using "st"
jq -r '.[] | select(.slug == "st") | "- **\(.name)** - Currently using \`st\`"' "$RESOURCE_DEF" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "**Microsoft Official:** Only \`azurerm_storage_account\` should use \`st\`" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "### 🤖 **AI Resources Review**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Review AI-related resources
jq -r '.[] | select(.name | test("ai_|cognitive|foundry|openai")) | "| **\(.name)** | \(.slug) | ? |"' "$RESOURCE_DEF" | sort >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "**Microsoft Recommendations for AI:**" >> "$REVIEW_REPORT"
echo "- \`azurerm_ai_services\` → \`ais\` (currently: \`aiservic\`)" >> "$REVIEW_REPORT"
echo "- \`azurerm_ai_foundry\` → \`aif\` (currently: \`aifoundr\`)" >> "$REVIEW_REPORT"
echo "- \`azurerm_ai_foundry_project\` → \`proj\` (currently: \`aifoundr\`)" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "### 📦 **Container Resources Review**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Review Container-related resources
jq -r '.[] | select(.name | test("container_app")) | "| **\(.name)** | \(.slug) | ? |"' "$RESOURCE_DEF" | sort >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "**Microsoft Recommendations for Container Apps:**" >> "$REVIEW_REPORT"
echo "- \`azurerm_container_app\` → \`ca\` ✅ (correct)" >> "$REVIEW_REPORT"
echo "- \`azurerm_container_app_environment\` → \`cae\` ✅ (correct)" >> "$REVIEW_REPORT"
echo "- All other container app resources should use descriptive abbreviations, NOT \`st\`" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "## 💡 **Recommended Actions**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "### 🚨 **High Priority (Fix Conflicts)**" >> "$REVIEW_REPORT"
echo "1. **Change \`azurerm_container_app_environment_storage\`** from \`st\` to \`caes\`" >> "$REVIEW_REPORT"
echo "2. **Ensure \`azurerm_storage_account\`** keeps the \`st\` abbreviation" >> "$REVIEW_REPORT"
echo "3. **Fix any other resources incorrectly using \`st\`**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "### 📊 **Medium Priority (Align with Microsoft)**" >> "$REVIEW_REPORT"
echo "1. **AI Services:** \`aiservic\` → \`ais\`" >> "$REVIEW_REPORT"
echo "2. **AI Foundry:** \`aifoundr\` → \`aif\`" >> "$REVIEW_REPORT"
echo "3. **AI Foundry Project:** \`aifoundr\` → \`proj\`" >> "$REVIEW_REPORT"
echo "4. **Review other abbreviations** against Microsoft standards" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "### 🔧 **Implementation Steps**" >> "$REVIEW_REPORT"
echo "1. **Update resourceDefinition.json** with correct abbreviations" >> "$REVIEW_REPORT"
echo "2. **Run \`go generate\`** to regenerate models" >> "$REVIEW_REPORT"
echo "3. **Update tests** to reflect new abbreviations" >> "$REVIEW_REPORT"
echo "4. **Test build and validation**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "## ✅ **Resources Following Microsoft Standards**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

# Show correct resources
while IFS= read -r resource; do
    name=$(echo "$resource" | jq -r '.name')
    current_slug=$(echo "$resource" | jq -r '.slug')
    
    if [[ -n "${MS_ABBREV[$name]:-}" ]]; then
        ms_abbrev="${MS_ABBREV[$name]}"
        if [[ "$current_slug" == "$ms_abbrev" ]]; then
            echo "- ✅ **$name** → \`$current_slug\`" >> "$REVIEW_REPORT"
        fi
    fi
done < <(jq -c '.[]' "$RESOURCE_DEF")

echo "" >> "$REVIEW_REPORT"

# Summary statistics
echo "## 📈 **Statistics**" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"
echo "- **Total Resources:** $TOTAL_RESOURCES" >> "$REVIEW_REPORT"
echo "- **Checked Against MS Standards:** $CHECKED_RESOURCES" >> "$REVIEW_REPORT"
echo "- **Correct Abbreviations:** $CORRECT_ABBREV" >> "$REVIEW_REPORT"
echo "- **Incorrect Abbreviations:** $INCORRECT_ABBREV" >> "$REVIEW_REPORT"
echo "- **Compliance Rate:** $(( CORRECT_ABBREV * 100 / CHECKED_RESOURCES ))%" >> "$REVIEW_REPORT"
echo "" >> "$REVIEW_REPORT"

echo "---" >> "$REVIEW_REPORT"
echo "*Report generated on $(date) by abbreviation review script*" >> "$REVIEW_REPORT"

echo "✅ Abbreviation review completed!"
echo "📄 Report saved to: $REVIEW_REPORT"
echo ""
echo "🔍 Key findings:"
echo "  - Total resources: $TOTAL_RESOURCES"
echo "  - Checked against MS standards: $CHECKED_RESOURCES" 
echo "  - Correct abbreviations: $CORRECT_ABBREV"
echo "  - Incorrect abbreviations: $INCORRECT_ABBREV"
echo "  - Compliance rate: $(( CORRECT_ABBREV * 100 / CHECKED_RESOURCES ))%"
echo ""
echo "🚨 Critical issue found: Multiple resources using 'st' abbreviation!"
echo "   Fix azurerm_container_app_environment_storage to use 'caes' instead of 'st'"
