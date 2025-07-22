#!/usr/bin/env python3
"""
Script para alinear todos los slugs con las abreviaciones oficiales de Microsoft CAF.
Actualiza los resources para seguir las mejores prácticas de Azure Cloud Adoption Framework.
"""

import json
import sys
from collections import Counter

def update_to_official_caf_abbreviations():
    """Actualiza slugs para usar abreviaciones oficiales de Microsoft CAF"""
    
    try:
        # Cargar resourceDefinition.json
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            resources = json.load(f)
        
        corrections = []
        
        # Mapeo oficial Microsoft CAF - usando las abreviaciones exactas de la documentación
        official_caf_mapping = {
            # AI + Machine Learning
            'azurerm_machine_learning_workspace': 'mlw',
            'azurerm_cognitive_account': 'ais',  # Azure AI services
            'azurerm_cognitive_deployment': 'oai',  # Azure OpenAI Service
            'azurerm_bot_service': 'bot',
            'azurerm_bot_channel_alexa': 'bot',
            'azurerm_bot_channel_direct_line_speech': 'bot',
            'azurerm_bot_channel_facebook': 'bot',
            'azurerm_bot_channel_line': 'bot',
            'azurerm_bot_channel_sms': 'bot',
            'azurerm_bot_channel_web_chat': 'bot',
            'azurerm_bot_channel_email': 'bot',
            'azurerm_bot_channel_Email': 'bot',
            'azurerm_bot_channel_ms_teams': 'bot',
            
            # Analytics and IoT
            'azurerm_databricks_workspace': 'dbw',
            'azurerm_databricks_access_connector': 'dbac',
            'azurerm_kusto_cluster': 'dec',
            'azurerm_kusto_database': 'dedb',
            'azurerm_data_factory': 'adf',
            'azurerm_digital_twins_instance': 'dt',
            'azurerm_stream_analytics_job': 'asa',
            'azurerm_synapse_workspace': 'synw',
            'azurerm_synapse_sql_pool': 'syndp',
            'azurerm_synapse_spark_pool': 'synsp',
            'azurerm_synapse_private_link_hub': 'synplh',
            'azurerm_data_lake_store': 'dls',
            'azurerm_data_lake_analytics_account': 'dla',
            'azurerm_eventhub_namespace': 'evhns',
            'azurerm_eventhub': 'evh',
            'azurerm_eventgrid_domain': 'evgd',
            'azurerm_eventgrid_namespace': 'evgns',
            'azurerm_eventgrid_subscription': 'evgs',
            'azurerm_eventgrid_topic': 'evgt',
            'azurerm_eventgrid_system_topic': 'egst',
            'azurerm_iothub': 'iot',
            'azurerm_iot_dps': 'provs',
            'azurerm_powerbi_embedded': 'pbi',
            'azurerm_time_series_insights_environment': 'tsi',
            
            # Compute and Web
            'azurerm_app_service_environment': 'ase',
            'azurerm_app_service_environment_v3': 'ase',
            'azurerm_app_service_plan': 'asp',
            'azurerm_availability_set': 'avail',
            'azurerm_arc_machine': 'arcs',
            'azurerm_kubernetes_cluster': 'arck',  # Arc-enabled Kubernetes
            'azurerm_batch_account': 'ba',
            'azurerm_cloud_service': 'cld',
            'azurerm_communication_service': 'acs',
            'azurerm_disk_encryption_set': 'des',
            'azurerm_function_app': 'func',
            'azurerm_shared_image_gallery': 'gal',
            'azurerm_image': 'it',
            'azurerm_managed_disk': 'disk',
            'azurerm_notification_hub': 'ntf',
            'azurerm_notification_hub_namespace': 'ntfns',
            'azurerm_proximity_placement_group': 'ppg',
            'azurerm_snapshot': 'snap',
            'azurerm_virtual_machine': 'vm',
            'azurerm_linux_virtual_machine': 'vm',
            'azurerm_windows_virtual_machine': 'vm',
            'azurerm_virtual_machine_scale_set': 'vmss',
            'azurerm_linux_virtual_machine_scale_set': 'vmss',
            'azurerm_windows_virtual_machine_scale_set': 'vmss',
            'azurerm_maintenance_configuration': 'mc',
            'azurerm_app_service': 'app',  # Web App
            
            # Containers
            'azurerm_kubernetes_cluster': 'aks',
            'azurerm_container_app': 'ca',
            'azurerm_container_app_environment': 'cae',
            'azurerm_container_registry': 'cr',
            'azurerm_container_group': 'ci',
            'azurerm_service_fabric_cluster': 'sf',
            'azurerm_service_fabric_managed_cluster': 'sfmc',
            
            # Databases
            'azurerm_cosmosdb_account': 'cosmos',
            'azurerm_cosmosdb_cassandra_cluster': 'coscas',
            'azurerm_cosmosdb_mongo_database': 'cosmon',
            'azurerm_cosmosdb_sql_database': 'cosno',
            'azurerm_cosmosdb_table': 'costab',
            'azurerm_cosmosdb_gremlin_database': 'cosgrm',
            'azurerm_postgresql_flexible_server_cluster': 'cospos',
            'azurerm_redis_cache': 'redis',
            'azurerm_mssql_server': 'sql',
            'azurerm_sql_server': 'sql',
            'azurerm_mssql_database': 'sqldb',
            'azurerm_sql_database': 'sqldb',
            'azurerm_mssql_elasticpool': 'sqlep',
            'azurerm_sql_elasticpool': 'sqlep',
            'azurerm_mysql_server': 'mysql',
            'azurerm_mysql_flexible_server': 'mysql',
            'azurerm_postgresql_server': 'psql',
            'azurerm_postgresql_flexible_server': 'psql',
            'azurerm_mssql_managed_instance': 'sqlmi',
            'azurerm_sql_managed_instance': 'sqlmi',
            
            # Developer Tools
            'azurerm_app_configuration': 'appcs',
            'azurerm_maps_account': 'map',
            'azurerm_signalr_service': 'sigr',
            
            # DevOps
            'azurerm_dashboard_grafana': 'amg',
            
            # Integration
            'azurerm_api_management': 'apim',
            'azurerm_logic_app_integration_account': 'ia',
            'azurerm_logic_app_workflow': 'logic',
            'azurerm_logic_app_standard': 'logic',
            'azurerm_servicebus_namespace': 'sbns',
            'azurerm_servicebus_queue': 'sbq',
            'azurerm_servicebus_topic': 'sbt',
            'azurerm_servicebus_subscription': 'sbts',
            
            # Management and Governance
            'azurerm_automation_account': 'aa',
            'azurerm_application_insights': 'appi',
            'azurerm_monitor_action_group': 'ag',
            'azurerm_monitor_data_collection_rule': 'dcr',
            'azurerm_monitor_alert_processing_rule_action_group': 'apr',
            'azurerm_blueprint_assignment': 'bpa',
            'azurerm_blueprint_definition': 'bp',
            'azurerm_data_collection_endpoint': 'dce',
            'azurerm_resource_deployment_script_azure_cli': 'script',
            'azurerm_resource_deployment_script_azure_power_shell': 'script',
            'azurerm_log_analytics_workspace': 'log',
            'azurerm_log_analytics_query_pack': 'pack',
            'azurerm_management_group': 'mg',
            'azurerm_resource_group': 'rg',
            'azurerm_template_spec': 'ts',
            
            # Migration
            'azurerm_migrate_project': 'migr',
            'azurerm_database_migration_service': 'dms',
            'azurerm_recovery_services_vault': 'rsv',
            
            # Networking
            'azurerm_application_gateway': 'agw',
            'azurerm_application_security_group': 'asg',
            'azurerm_cdn_profile': 'cdnp',
            'azurerm_cdn_endpoint': 'cdne',
            'azurerm_virtual_network_gateway_connection': 'con',
            'azurerm_dns_zone': 'dns',
            'azurerm_private_dns_zone': 'dns',
            'azurerm_firewall': 'afw',
            'azurerm_firewall_policy': 'afwp',
            'azurerm_express_route_circuit': 'erc',
            'azurerm_express_route_port': 'erd',
            'azurerm_express_route_gateway': 'ergw',
            'azurerm_frontdoor': 'afd',
            'azurerm_frontdoor_profile': 'afd',
            'azurerm_frontdoor_endpoint': 'fde',
            'azurerm_frontdoor_firewall_policy': 'fdfp',
            'azurerm_ip_group': 'ipg',
            'azurerm_lb': 'lbe',  # External load balancer
            'azurerm_lb_rule': 'rule',
            'azurerm_local_network_gateway': 'lgw',
            'azurerm_nat_gateway': 'ng',
            'azurerm_network_interface': 'nic',
            'azurerm_network_security_group': 'nsg',
            'azurerm_network_security_rule': 'nsgsr',
            'azurerm_network_watcher': 'nw',
            'azurerm_private_link_service': 'pl',
            'azurerm_private_endpoint': 'pep',
            'azurerm_public_ip': 'pip',
            'azurerm_public_ip_prefix': 'ippre',
            'azurerm_route_filter': 'rf',
            'azurerm_route_server': 'rtserv',
            'azurerm_route_table': 'rt',
            'azurerm_traffic_manager_profile': 'traf',
            'azurerm_route': 'udr',  # User Defined Route
            'azurerm_virtual_network': 'vnet',
            'azurerm_virtual_network_gateway': 'vgw',
            'azurerm_network_manager': 'vnm',
            'azurerm_virtual_network_peering': 'peer',
            'azurerm_subnet': 'snet',
            'azurerm_virtual_wan': 'vwan',
            'azurerm_virtual_hub': 'vhub',
            
            # Security
            'azurerm_bastion_host': 'bas',
            'azurerm_key_vault': 'kv',
            'azurerm_key_vault_managed_hardware_security_module': 'kvmhsm',
            'azurerm_user_assigned_identity': 'id',
            'azurerm_ssh_public_key': 'sshkey',
            'azurerm_vpn_gateway': 'vpng',
            'azurerm_vpn_gateway_connection': 'vcn',
            'azurerm_vpn_site': 'vst',
            'azurerm_web_application_firewall_policy': 'waf',
            
            # Storage
            'azurerm_storsimple_manager': 'ssimp',
            'azurerm_data_protection_backup_vault': 'bvault',
            'azurerm_data_protection_backup_policy': 'bkpol',
            'azurerm_storage_share': 'share',
            'azurerm_storage_account': 'st',
            'azurerm_storage_sync': 'sss',
            
            # Virtual Desktop Infrastructure
            'azurerm_virtual_desktop_host_pool': 'vdpool',
            'azurerm_virtual_desktop_application_group': 'vdag',
            'azurerm_virtual_desktop_workspace': 'vdws',
            'azurerm_virtual_desktop_scaling_plan': 'vdscaling',
        }
        
        # Aplicar correcciones basadas en nombres de recursos
        for resource in resources:
            resource_name = resource.get('name', '')
            current_slug = resource.get('slug', '')
            
            # Buscar coincidencia exacta primero
            if resource_name in official_caf_mapping:
                new_slug = official_caf_mapping[resource_name]
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (CAF oficial)")
            
            # Buscar patrones para recursos relacionados no oficiales
            elif 'azurerm_bot_channel_' in resource_name and current_slug != 'bot':
                resource['slug'] = 'bot'
                corrections.append(f"  • {resource_name}: '{current_slug}' → 'bot' (CAF bot pattern)")
            elif 'azurerm_mssql_' in resource_name and not current_slug.startswith('sql'):
                if 'database' in resource_name:
                    new_slug = 'sqldb'
                elif 'server' in resource_name:
                    new_slug = 'sql'
                elif 'elastic' in resource_name:
                    new_slug = 'sqlep'
                else:
                    new_slug = 'sql'
                
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (CAF SQL pattern)")
            elif 'azurerm_mysql_' in resource_name and current_slug != 'mysql':
                resource['slug'] = 'mysql'
                corrections.append(f"  • {resource_name}: '{current_slug}' → 'mysql' (CAF MySQL pattern)")
            elif 'azurerm_postgresql_' in resource_name and current_slug != 'psql':
                resource['slug'] = 'psql'
                corrections.append(f"  • {resource_name}: '{current_slug}' → 'psql' (CAF PostgreSQL pattern)")
            elif 'azurerm_eventhub_' in resource_name:
                if 'namespace' in resource_name:
                    new_slug = 'evhns'
                else:
                    new_slug = 'evh'
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (CAF EventHub pattern)")
            elif 'azurerm_servicebus_' in resource_name:
                if 'namespace' in resource_name:
                    new_slug = 'sbns'
                elif 'queue' in resource_name:
                    new_slug = 'sbq'
                elif 'topic' in resource_name and 'subscription' not in resource_name:
                    new_slug = 'sbt'
                elif 'subscription' in resource_name:
                    new_slug = 'sbts'
                else:
                    new_slug = 'sbns'
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (CAF ServiceBus pattern)")
        
        # Guardar cambios
        if corrections:
            with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
                json.dump(resources, f, indent=2, ensure_ascii=False)
            
            print("🏷️  ACTUALIZACIÓN A ABREVIACIONES OFICIALES MICROSOFT CAF:")
            print("=" * 70)
            for correction in corrections:
                print(correction)
            print(f"\n✅ Actualizados {len(corrections)} recursos con abreviaciones oficiales CAF")
            
            # Verificar estado final
            slugs = [r.get('slug', '') for r in resources]
            slug_counts = Counter(slugs)
            duplicated = sum(1 for count in slug_counts.values() if count > 1)
            
            print(f"\n📊 ESTADO DESPUÉS DE ACTUALIZACIÓN CAF:")
            print(f"   • Total recursos: {len(resources)}")
            print(f"   • Slugs únicos: {len(set(slugs))}")
            print(f"   • Slugs duplicados: {duplicated}")
            
            return True
        else:
            print("ℹ️  No se encontraron recursos para actualizar con CAF oficial")
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
    success = update_to_official_caf_abbreviations()
    sys.exit(0 if success else 1)
