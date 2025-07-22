#!/bin/bash

# Análisis completo de abreviaturas vs Microsoft CAF
set -e

RESOURCE_DEF="../resourceDefinition.json"
REPORT="microsoft_caf_compliance_$(date +%Y%m%d_%H%M%S).md"

echo "# 🔍 Análisis Completo de Abreviaturas vs Microsoft CAF" > "$REPORT"
echo "**Fecha:** $(date)" >> "$REPORT"
echo "**Fuente:** https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations" >> "$REPORT"
echo "" >> "$REPORT"

echo "## ❌ Recursos que NO cumplen con Microsoft CAF" >> "$REPORT"
echo "" >> "$REPORT"

# App Service Plan - Microsoft recomienda "asp", nosotros tenemos "plan"
current_asp=$(jq -r '.[] | select(.name == "azurerm_app_service_plan") | .slug' "$RESOURCE_DEF" 2>/dev/null)
if [[ "$current_asp" != "asp" ]]; then
    echo "### azurerm_app_service_plan" >> "$REPORT"
    echo "- **Actual:** \`$current_asp\`" >> "$REPORT"
    echo "- **Microsoft CAF:** \`asp\`" >> "$REPORT"
    echo "- **Acción:** Cambiar a \`asp\`" >> "$REPORT"
    echo "" >> "$REPORT"
fi

# Function App - Microsoft recomienda "func", verificar actual
current_func=$(jq -r '.[] | select(.name == "azurerm_function_app") | .slug' "$RESOURCE_DEF" 2>/dev/null)
if [[ "$current_func" != "func" ]]; then
    echo "### azurerm_function_app" >> "$REPORT"
    echo "- **Actual:** \`$current_func\`" >> "$REPORT"
    echo "- **Microsoft CAF:** \`func\`" >> "$REPORT"
    echo "- **Acción:** Cambiar a \`func\`" >> "$REPORT"
    echo "" >> "$REPORT"
fi

# Logic App - Microsoft recomienda "logic", verificar actual
current_logic=$(jq -r '.[] | select(.name == "azurerm_logic_app_workflow") | .slug' "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
if [[ "$current_logic" != "logic" && "$current_logic" != "not-found" ]]; then
    echo "### azurerm_logic_app_workflow" >> "$REPORT"
    echo "- **Actual:** \`$current_logic\`" >> "$REPORT"
    echo "- **Microsoft CAF:** \`logic\`" >> "$REPORT"
    echo "- **Acción:** Cambiar a \`logic\`" >> "$REPORT"
    echo "" >> "$REPORT"
fi

# Dashboard - No hay recomendación específica, revisar
current_dashboard=$(jq -r '.[] | select(.name == "azurerm_dashboard") | .slug' "$RESOURCE_DEF" 2>/dev/null)
echo "### azurerm_dashboard" >> "$REPORT"
echo "- **Actual:** \`$current_dashboard\`" >> "$REPORT"
echo "- **Microsoft CAF:** No especificado" >> "$REPORT"
echo "- **Recomendación:** \`dash\` (más descriptivo que \`dsb\`)" >> "$REPORT"
echo "" >> "$REPORT"

echo "## ✅ Recursos que SÍ cumplen con Microsoft CAF" >> "$REPORT"
echo "" >> "$REPORT"

# Recursos que ya están correctos
declare -A CORRECT_RESOURCES=(
    ["azurerm_app_service"]="app"
    ["azurerm_app_service_environment"]="ase"
    ["azurerm_data_factory"]="adf"
    ["azurerm_container_app"]="ca"
    ["azurerm_container_app_environment"]="cae"
    ["azurerm_ai_services"]="ais"
    ["azurerm_ai_foundry"]="aif"
    ["azurerm_ai_foundry_project"]="proj"
)

for resource in "${!CORRECT_RESOURCES[@]}"; do
    expected="${CORRECT_RESOURCES[$resource]}"
    current=$(jq -r ".[] | select(.name == \"$resource\") | .slug" "$RESOURCE_DEF" 2>/dev/null || echo "not-found")
    if [[ "$current" == "$expected" ]]; then
        echo "- ✅ **$resource** → \`$current\`" >> "$REPORT"
    fi
done

echo "" >> "$REPORT"

# Mostrar resultado en terminal
cat "$REPORT"
echo ""
echo "📄 Reporte guardado en: $REPORT"
