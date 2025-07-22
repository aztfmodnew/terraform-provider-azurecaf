#!/usr/bin/env python3
"""
Script para resolver los 10 duplicados finales restantes después de la implementación CAF.
"""

import json
import sys
from collections import Counter

def fix_last_10_duplicates():
    """Resuelve los últimos 10 duplicados restantes"""
    
    try:
        # Cargar resourceDefinition.json
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            resources = json.load(f)
        
        corrections = []
        
        # Resolución de los últimos 10 duplicados
        final_fixes = {
            # App Service Environment - diferenciar versiones
            'azurerm_app_service_environment_v3': 'asev3',  # Mantener v3 específico
            # azurerm_app_service_environment mantiene 'ase' (base CAF)
            
            # DNS zones - diferenciar público vs privado
            'azurerm_private_dns_zone': 'pdns',  # Private DNS
            # azurerm_dns_zone mantiene 'dns' (público, base CAF)
            
            # Logic Apps - diferenciar versiones
            'azurerm_logic_app_standard': 'logicstd',  # Standard version
            # azurerm_logic_app_workflow mantiene 'logic' (base CAF)
            
            # SQL Database - diferenciar versiones modernas vs legacy
            'azurerm_sql_database': 'sqldblegacy',  # Legacy version
            # azurerm_mssql_database mantiene 'sqldb' (moderna, CAF)
            
            # SQL Elastic Pool - diferenciar versiones
            'azurerm_sql_elasticpool': 'sqleplegacy',  # Legacy version
            # azurerm_mssql_elasticpool mantiene 'sqlep' (moderna, CAF)
            
            # SQL Server - diferenciar versiones
            'azurerm_sql_server': 'sqlsrvlegacy',  # Legacy version
            # azurerm_mssql_server mantiene 'sql' (moderna, CAF)
            
            # MySQL Server - diferenciar flexible vs standard
            'azurerm_mysql_server': 'mysqlsrv',  # Standard server
            # azurerm_mysql_flexible_server mantiene 'mysql' (flexible, moderno)
            
            # PostgreSQL Server - diferenciar flexible vs standard
            'azurerm_postgresql_server': 'psqlsrv',  # Standard server
            # azurerm_postgresql_flexible_server mantiene 'psql' (flexible, moderno)
            
            # General entries - estos parecen ser entries especiales del sistema
            # Buscar y manejar las entradas 'general'
            
            # Script deployments - diferenciar CLI vs PowerShell
            'azurerm_resource_deployment_script_azure_power_shell': 'scriptps',  # PowerShell
            # azurerm_resource_deployment_script_azure_cli mantiene 'script' (más común)
        }
        
        # Aplicar correcciones específicas
        for resource in resources:
            resource_name = resource.get('name', '')
            current_slug = resource.get('slug', '')
            
            if resource_name in final_fixes:
                new_slug = final_fixes[resource_name]
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (último duplicado)")
        
        # Manejar entradas 'general' especiales
        general_entries = [r for r in resources if r.get('slug') == '' and r.get('name') in ['general', 'general_safe']]
        if len(general_entries) == 2:
            for i, entry in enumerate(general_entries):
                if entry.get('name') == 'general_safe':
                    entry['slug'] = 'gensafe'
                    corrections.append(f"  • {entry.get('name')}: '' → 'gensafe' (general especial)")
                elif entry.get('name') == 'general':
                    entry['slug'] = 'gen'
                    corrections.append(f"  • {entry.get('name')}: '' → 'gen' (general especial)")
        
        # Guardar cambios
        if corrections:
            with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
                json.dump(resources, f, indent=2, ensure_ascii=False)
            
            print("🎯 RESOLUCIÓN DE LOS ÚLTIMOS 10 DUPLICADOS:")
            print("=" * 50)
            for correction in corrections:
                print(correction)
            print(f"\n✅ Corregidos {len(corrections)} duplicados finales")
            
            # Verificar estado absolutamente final
            slugs = [r.get('slug', '') for r in resources]
            slug_counts = Counter(slugs)
            duplicated = sum(1 for count in slug_counts.values() if count > 1)
            
            print(f"\n📊 ESTADO ABSOLUTAMENTE FINAL:")
            print(f"   • Total recursos: {len(resources)}")
            print(f"   • Slugs únicos: {len(set(slugs))}")
            print(f"   • Slugs duplicados: {duplicated}")
            
            if duplicated == 0:
                print("\n🎉 ¡MISIÓN CUMPLIDA! - CERO DUPLICADOS")
                print("🏆 100% de recursos optimizados con estándares Microsoft CAF")
                print("✨ Repository completamente limpio y organizado")
            else:
                remaining_dups = {slug: count for slug, count in slug_counts.items() if count > 1}
                print(f"\n📋 Duplicados restantes: {remaining_dups}")
            
            return True
        else:
            print("ℹ️  No se encontraron duplicados para corregir")
            return False
            
    except FileNotFoundError:
        print("❌ Error: No se encontró resourceDefinition.json")
        return False
    except json.JSONDecodeError:
        print("❌ Error: JSON inválido en resourceDefinition.json")
        return False
    except Exception as e:
        print(f"❌ Error inesperado: {str(e)}")
        return False

if __name__ == "__main__":
    success = fix_last_10_duplicates()
    sys.exit(0 if success else 1)
