#!/bin/bash

# Debug script para probar las correcciones CAF

set -e

# Crear un archivo JSON de prueba con algunos recursos problemáticos
cat > test_resources.json << 'JSON'
[
  {
    "name": "azurerm_mysql_server",
    "slug": "server",
    "official": {
      "slug": "mysql"
    }
  },
  {
    "name": "azurerm_postgresql_server", 
    "slug": "server",
    "official": {
      "slug": "psql"
    }
  },
  {
    "name": "azurerm_storage_account",
    "slug": "sa",
    "official": {
      "slug": "st"
    }
  }
]
JSON

# Crear el script JQ de correcciones CAF
cat > caf_corrections.jq << 'CAF_JQ'
# Official Microsoft CAF mappings - estos toman prioridad absoluta
def caf_mapping:
{
    "azurerm_mysql_server": "mysql",
    "azurerm_postgresql_server": "psql",
    "azurerm_storage_account": "st"
};

# Aplicar correcciones CAF
map(
    if has("name") and has("slug") then
        if caf_mapping[.name] then
            .slug = caf_mapping[.name] |
            .official.slug = caf_mapping[.name] |
            . + {caf_corrected: true}
        else
            .
        end
    else
        .
    end
)
CAF_JQ

echo "=== ANTES de las correcciones CAF ==="
jq '.' test_resources.json

echo ""
echo "=== DESPUÉS de las correcciones CAF ==="
jq -f caf_corrections.jq test_resources.json

# Limpiar archivos temporales
rm -f test_resources.json caf_corrections.jq
