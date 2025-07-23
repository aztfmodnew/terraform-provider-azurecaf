#!/bin/bash

# Script para corregir los datos oficiales incorrectos de Load Balancer

set -e

RESDEF="resourceDefinition.json"

# Crear backup
cp "$RESDEF" "${RESDEF}.backup.fix_lb_$(date +%Y%m%d_%H%M%S)"

echo "🔧 Corrigiendo recursos de Load Balancer con datos oficiales incorrectos..."

# Crear script JQ para corregir los recursos problemáticos de Load Balancer
cat > fix_lb_official_data.jq << 'FIX_JQ'
map(
    if .name == "azurerm_lb_backend_address_pool" then
        .official = {
            "slug": "lbbap",
            "resource": "Load Balancer Backend Address Pool",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_backend_pool" then
        .official = {
            "slug": "lbbp", 
            "resource": "Load Balancer Backend Pool",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_nat_pool" then
        .official = {
            "slug": "lbnatp",
            "resource": "Load Balancer NAT Pool", 
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_outbound_rule" then
        .official = {
            "slug": "lbor",
            "resource": "Load Balancer Outbound Rule",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_probe" then
        .official = {
            "slug": "lbprobe",
            "resource": "Load Balancer Probe",
            "resource_provider_namespace": "Microsoft.Network/loadBalancers"
        }
    elif .name == "azurerm_lb_rule" then
        . + {
            "official": {
                "slug": "lbrule",
                "resource": "Load Balancer Rule",
                "resource_provider_namespace": "Microsoft.Network/loadBalancers"
            },
            "slug": "lbrule"  # Cambiar slug de "rule" a "lbrule" para evitar conflictos
        }
    else
        .
    end
)
FIX_JQ

# Aplicar las correcciones
if jq -f fix_lb_official_data.jq "$RESDEF" > "${RESDEF}.tmp"; then
    mv "${RESDEF}.tmp" "$RESDEF"
    echo "✅ Correcciones aplicadas exitosamente"
    
    # Contar recursos corregidos
    fixed_count=$(jq '[.[] | select(.name | startswith("azurerm_lb") and (.official.resource_provider_namespace == "Microsoft.Network/loadBalancers"))] | length' "$RESDEF")
    echo "📊 Recursos de Load Balancer corregidos: $fixed_count"
    
    # Verificar que Digital Twins solo aparezca en el recurso correcto
    dt_count=$(jq '[.[] | select(.official.resource == "Azure Digital Twins")] | length' "$RESDEF")
    echo "🔍 Recursos de Digital Twins restantes: $dt_count (debería ser 1)"
    
else
    echo "❌ Error aplicando correcciones"
    exit 1
fi

# Limpiar archivo temporal
rm -f fix_lb_official_data.jq

echo ""
echo "🎯 Verificación:"
echo "Recursos que aún tienen 'Azure Digital Twins':"
jq -r '.[] | select(.official.resource == "Azure Digital Twins") | .name' "$RESDEF"

echo ""
echo "✅ Corrección completada!"
