#!/usr/bin/env python3
"""
Script final para eliminar duplicados restantes después de implementar estándares Microsoft CAF,
manteniendo consistencia en familias de recursos relacionados.
"""

import json
import sys
from collections import Counter

def fix_final_caf_duplicates():
    """Elimina duplicados finales manteniendo consistencia CAF"""
    
    try:
        # Cargar resourceDefinition.json
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            resources = json.load(f)
        
        corrections = []
        
        # Correcciones específicas manteniendo consistencia CAF
        specific_fixes = {
            # PostgreSQL family - usar base 'psql' + sufijo descriptivo
            'azurerm_postgresql_active_directory_administrator': 'psqlad',
            'azurerm_postgresql_configuration': 'psqlcfg',
            'azurerm_postgresql_database': 'psqldb',
            'azurerm_postgresql_firewall_rule': 'psqlfw',
            'azurerm_postgresql_flexible_server_active_directory_administrator': 'psqlflexad',
            'azurerm_postgresql_flexible_server_configuration': 'psqlflexcfg',
            'azurerm_postgresql_flexible_server_database': 'psqlflexdb',
            'azurerm_postgresql_flexible_server_firewall_rule': 'psqlflexfw',
            'azurerm_postgresql_flexible_server_virtual_endpoint': 'psqlflexvep',
            'azurerm_postgresql_server_key': 'psqlkey',
            'azurerm_postgresql_virtual_network_rule': 'psqlvnetr',
            'azurerm_data_protection_backup_instance_postgresql': 'psqlbkp',
            'azurerm_data_protection_backup_instance_postgresql_flexible_server': 'psqlflexbkp',
            
            # MySQL family - usar base 'mysql' + sufijo descriptivo
            'azurerm_mysql_active_directory_administrator': 'mysqladmin',
            'azurerm_mysql_configuration': 'mysqlcfg',
            'azurerm_mysql_database': 'mysqldb',
            'azurerm_mysql_firewall_rule': 'mysqlfw',
            'azurerm_mysql_flexible_database': 'mysqlflexdb',
            'azurerm_mysql_flexible_server_active_directory_administrator': 'mysqlflexad',
            'azurerm_mysql_flexible_server_configuration': 'mysqlflexcfg',
            'azurerm_mysql_flexible_server_database': 'mysqlflexdba',
            'azurerm_mysql_flexible_server_firewall_rule': 'mysqlflexfw',
            'azurerm_mysql_server_key': 'mysqlkey',
            'azurerm_mysql_virtual_network_rule': 'mysqlvnetr',
            
            # Bot channels - usar base 'bot' + sufijo específico del canal
            'azurerm_bot_channel_Email': 'botemail',  # Mantener el original corregido
            'azurerm_bot_channel_alexa': 'botalexa',
            'azurerm_bot_channel_direct_line_speech': 'botdls',
            'azurerm_bot_channel_directline': 'botdl',
            'azurerm_bot_channel_email': 'botmail',  # Diferente del Email con mayúscula
            'azurerm_bot_channel_facebook': 'botfb',
            'azurerm_bot_channel_line': 'botline',
            'azurerm_bot_channel_ms_teams': 'botteams',
            'azurerm_bot_channel_slack': 'botslack',
            'azurerm_bot_channel_sms': 'botsms',
            'azurerm_bot_channel_web_chat': 'botweb',
            
            # EventHub namespace family
            'azurerm_eventhub_namespace_authorization_rule': 'evhnsauth',
            'azurerm_eventhub_namespace_customer_managed_key': 'evhnscmk',
            'azurerm_eventhub_namespace_disaster_recovery_config': 'evhnsdr',
            'azurerm_eventhub_namespace_schema_group': 'evhnssg',
            
            # EventHub family
            'azurerm_eventhub_authorization_rule': 'evhauth',
            'azurerm_eventhub_cluster': 'evhcluster',
            'azurerm_eventhub_consumer_group': 'evhcg',
            
            # ServiceBus namespace family
            'azurerm_servicebus_namespace_authorization_rule': 'sbnsauth',
            'azurerm_servicebus_namespace_customer_managed_key': 'sbnscmk',
            'azurerm_servicebus_namespace_disaster_recovery_config': 'sbnsdr',
            'azurerm_servicebus_namespace_network_rule_set': 'sbnsnetr',
            
            # ServiceBus queue/topic/subscription family
            'azurerm_servicebus_queue_authorization_rule': 'sbqauth',
            'azurerm_servicebus_subscription_rule': 'sbsubr',
            'azurerm_servicebus_topic_authorization_rule': 'sbtauth',
            
            # API Management Identity Providers
            'azurerm_api_management_identity_provider_aadb2c': 'apimidpb2c',
            'azurerm_api_management_identity_provider_facebook': 'apimidpfb',
            'azurerm_api_management_identity_provider_google': 'apimidpg',
            'azurerm_api_management_identity_provider_microsoft': 'apimidpms',
            'azurerm_api_management_identity_provider_twitter': 'apimidptw',
            
            # API Management policies (distinguir entre operación y API)
            'azurerm_api_management_api_operation_policy': 'apimopopol',
            'azurerm_api_management_api_policy': 'apimapipol',
            
            # Virtual machines - mantener 'vm' base pero diferenciar tipos específicos
            # azurerm_virtual_machine mantiene 'vm' (base legacy)
            # azurerm_linux_virtual_machine -> 'vmlinux'
            # azurerm_windows_virtual_machine -> 'vmwin'
            'azurerm_linux_virtual_machine': 'vmlinux',
            'azurerm_windows_virtual_machine': 'vmwin',
            
            # VMSS - similar approach
            'azurerm_linux_virtual_machine_scale_set': 'vmsslinux',
            'azurerm_windows_virtual_machine_scale_set': 'vmsswin',
            
            # SQL Server family - mantener 'sql' base pero diferenciar versiones
            'azurerm_mssql_virtual_machine': 'sqlvm',
            # azurerm_mssql_server mantiene 'sql' (principal)
            # azurerm_sql_server mantiene 'sql' (legacy, mismo propósito)
            
            # App Service Environments - mantener mismo slug ya que son versiones
            # Both mantienen 'ase' (versiones del mismo servicio)
            
            # AI Services - diferenciar tipos específicos
            'azurerm_ai_services': 'aiservices',
            # azurerm_cognitive_account mantiene 'ais' (Azure AI Services oficial)
            
            # DNS zones - mantener mismo slug ya que son tipos del mismo servicio
            # Both mantienen 'dns' (tipos del mismo servicio)
            
            # Logic Apps - mantener mismo slug ya que son versiones
            # Both mantienen 'logic' (versiones del mismo servicio)
            
            # SQL DBs y Elastic Pools - mantener mismo slug ya que son versiones
            # Both mantienen 'sqldb' y 'sqlep' respectivamente (versiones)
            
            # Snapshots - diferenciar
            'azurerm_snapshots': 'snapshots',  # Plural form
            
            # SQL VNet rules - diferenciar versiones
            'azurerm_mssql_virtual_network_rule': 'sqlmsvnetr',
            'azurerm_sql_virtual_network_rule': 'sqlvnetr',
            
            # Monitor autoscale - cambiar para evitar conflicto con Analysis Services
            'azurerm_monitor_autoscale_setting': 'autosc',
        }
        
        # Aplicar correcciones específicas
        for resource in resources:
            resource_name = resource.get('name', '')
            current_slug = resource.get('slug', '')
            
            if resource_name in specific_fixes:
                new_slug = specific_fixes[resource_name]
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (eliminando duplicado)")
        
        # Guardar cambios
        if corrections:
            with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
                json.dump(resources, f, indent=2, ensure_ascii=False)
            
            print("🎯 CORRECCIÓN FINAL DE DUPLICADOS CAF:")
            print("=" * 50)
            for correction in corrections:
                print(correction)
            print(f"\n✅ Corregidos {len(corrections)} duplicados finales")
            
            # Verificar estado final
            slugs = [r.get('slug', '') for r in resources]
            slug_counts = Counter(slugs)
            duplicated = sum(1 for count in slug_counts.values() if count > 1)
            
            print(f"\n📊 ESTADO FINAL DESPUÉS DE CORRECCIÓN:")
            print(f"   • Total recursos: {len(resources)}")
            print(f"   • Slugs únicos: {len(set(slugs))}")
            print(f"   • Slugs duplicados: {duplicated}")
            
            if duplicated == 0:
                print("\n🎉 ¡ÉXITO TOTAL! - Todos los duplicados eliminados manteniendo estándares CAF")
            else:
                print(f"\n⚠️  Quedan {duplicated} duplicados por resolver")
            
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
    success = fix_final_caf_duplicates()
    sys.exit(0 if success else 1)
