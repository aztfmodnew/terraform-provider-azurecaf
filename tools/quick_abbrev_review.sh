#!/bin/bash

# Quick review of abbreviations against Microsoft CAF standards
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCE_DEF="$SCRIPT_DIR/../resourceDefinition.json"
REPORT="$SCRIPT_DIR/abbrev_review_$(date +%Y%m%d_%H%M%S).md"

echo "# 🔍 Azure CAF Abbreviation Review"
echo "Generated: $(date)"
echo ""

# Check for duplicate slugs (critical issue)
echo "## 🚨 Critical Issue: Duplicate Slugs"
echo ""
echo "Resources using the same slug 'st':"
jq -r '.[] | select(.slug == "st") | "- " + .name' "$RESOURCE_DEF"
echo ""

# Check AI resources against Microsoft recommendations
echo "## 🤖 AI Resources vs Microsoft CAF"
echo ""
echo "| Resource | Current Slug | MS Recommended | Status |"
echo "|----------|-------------|----------------|---------|"

# AI Services
current_ai_services=$(jq -r '.[] | select(.name == "azurerm_ai_services") | .slug' "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
echo "| azurerm_ai_services | $current_ai_services | ais | $([ "$current_ai_services" == "ais" ] && echo "✅" || echo "❌") |"

# AI Foundry
current_ai_foundry=$(jq -r '.[] | select(.name == "azurerm_ai_foundry") | .slug' "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
echo "| azurerm_ai_foundry | $current_ai_foundry | aif | $([ "$current_ai_foundry" == "aif" ] && echo "✅" || echo "❌") |"

# AI Foundry Project
current_ai_foundry_proj=$(jq -r '.[] | select(.name == "azurerm_ai_foundry_project") | .slug' "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
echo "| azurerm_ai_foundry_project | $current_ai_foundry_proj | proj | $([ "$current_ai_foundry_proj" == "proj" ] && echo "✅" || echo "❌") |"

# Container App Environment Storage (the problematic one)
current_caes=$(jq -r '.[] | select(.name == "azurerm_container_app_environment_storage") | .slug' "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
echo "| azurerm_container_app_environment_storage | $current_caes | caes (suggested) | $([ "$current_caes" != "st" ] && echo "✅" || echo "❌ CONFLICT") |"

echo ""
echo "## 📋 Container App Resources"
echo ""
echo "Current container app abbreviations:"
jq -r '.[] | select(.name | test("container_app")) | "- **" + .name + "**: `" + .slug + "`"' "$RESOURCE_DEF"

echo ""
echo "## 💡 Recommended Actions"
echo ""
echo "### 🔥 **CRITICAL - Fix Immediately:**"
echo "1. **azurerm_container_app_environment_storage**: Change slug from \`st\` to \`caes\`"
echo "   - This is causing the test failure because \`st\` should be reserved for \`azurerm_storage_account\`"
echo ""
echo "### 📊 **Medium Priority:**"
echo "2. **azurerm_ai_services**: Change slug from \`aiservic\` to \`ais\`"
echo "3. **azurerm_ai_foundry**: Change slug from \`aifoundr\` to \`aif\`"  
echo "4. **azurerm_ai_foundry_project**: Change slug from \`aifoundr\` to \`proj\`"
echo ""
echo "### 🛠️ **Implementation:**"
echo "\`\`\`bash"
echo "# Fix the critical slug conflict first"
echo "# Edit resourceDefinition.json to change azurerm_container_app_environment_storage slug to 'caes'"
echo "# Then regenerate:"
echo "go generate"
echo "make build"
echo "\`\`\`"

# Save report
{
echo "# 🔍 Azure CAF Abbreviation Review"
echo "Generated: $(date)"
echo ""
echo "## 🚨 Critical Issue: Duplicate Slugs"
echo ""
echo "Resources using the same slug 'st':"
jq -r '.[] | select(.slug == "st") | "- " + .name' "$RESOURCE_DEF"
echo ""
echo "**Problem:** Both \`azurerm_storage_account\` and \`azurerm_container_app_environment_storage\` use \`st\`"
echo "**Solution:** Change \`azurerm_container_app_environment_storage\` to use \`caes\`"
echo ""
echo "This is causing the test failure in \`TestGetResourceEdgeCases\`"
} > "$REPORT"

echo ""
echo "📄 Full report saved to: $REPORT"
echo "🎯 **Next step:** Fix the slug conflict for azurerm_container_app_environment_storage"
