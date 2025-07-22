#!/usr/bin/env python3
"""
Script para actualizar recursos relacionados que no tienen abreviación oficial CAF
para que sus slugs sigan patrones consistentes con los recursos principales.
"""

import json
import sys
from collections import Counter

def update_related_resources():
    """Actualiza recursos relacionados para usar patrones consistentes"""
    
    try:
        # Cargar resourceDefinition.json
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            resources = json.load(f)
        
        corrections = []
        
        # Patrones para recursos relacionados basados en CAF
        related_patterns = {
            # Network Manager patterns (nm base -> vnm oficial ahora)
            'azurerm_network_manager_admin_rule': 'vnmar',
            'azurerm_network_manager_admin_rule_collection': 'vnmarc',
            'azurerm_network_manager_connectivity_configuration': 'vnmcc',
            'azurerm_network_manager_deployment': 'vnmd',
            'azurerm_network_manager_management_group_connection': 'vnmmgc',
            'azurerm_network_manager_network_group': 'vnmng',
            'azurerm_network_manager_scope_connection': 'vnmsc',
            'azurerm_network_manager_security_admin_configuration': 'vnmsac',
            'azurerm_network_manager_static_member': 'vnmsm',
            'azurerm_network_manager_subscription_connection': 'vnmsubc',
            
            # API Management related (apim base)
            'azurerm_api_management_api': 'apimapi',
            'azurerm_api_management_api_diagnostic': 'apimapid',
            'azurerm_api_management_api_operation': 'apimapop',
            'azurerm_api_management_api_operation_policy': 'apimapip',
            'azurerm_api_management_api_operation_tag': 'apimapot',
            'azurerm_api_management_api_policy': 'apimapip',
            'azurerm_api_management_api_release': 'apimapir',
            'azurerm_api_management_api_schema': 'apimapis',
            'azurerm_api_management_api_tag': 'apimapita',
            'azurerm_api_management_api_version_set': 'apimapivs',
            'azurerm_api_management_authorization_server': 'apimauth',
            'azurerm_api_management_backend': 'apimbe',
            'azurerm_api_management_certificate': 'apimcert',
            'azurerm_api_management_custom_domain': 'apimcd',
            'azurerm_api_management_diagnostic': 'apimdiag',
            'azurerm_api_management_email_template': 'apimemtpl',
            'azurerm_api_management_gateway': 'apimgw',
            'azurerm_api_management_gateway_api': 'apimgwapi',
            'azurerm_api_management_gateway_certificate_authority': 'apimgwca',
            'azurerm_api_management_gateway_host_name_configuration': 'apimgwhnc',
            'azurerm_api_management_group': 'apimgrp',
            'azurerm_api_management_group_user': 'apimgrpusr',
            'azurerm_api_management_identity_provider_aadb2c': 'apimidp',
            'azurerm_api_management_identity_provider_facebook': 'apimidp',
            'azurerm_api_management_identity_provider_google': 'apimidp',
            'azurerm_api_management_identity_provider_microsoft': 'apimidp',
            'azurerm_api_management_identity_provider_twitter': 'apimidp',
            'azurerm_api_management_logger': 'apimlog',
            'azurerm_api_management_named_value': 'apimnv',
            'azurerm_api_management_notification_recipient_email': 'apimnre',
            'azurerm_api_management_notification_recipient_user': 'apimnru',
            'azurerm_api_management_openid_connect_provider': 'apimoidc',
            'azurerm_api_management_policy': 'apimpol',
            'azurerm_api_management_product': 'apimprod',
            'azurerm_api_management_product_api': 'apimproda',
            'azurerm_api_management_product_group': 'apimprodg',
            'azurerm_api_management_product_policy': 'apimprodp',
            'azurerm_api_management_product_tag': 'apimprodt',
            'azurerm_api_management_property': 'apimprop',
            'azurerm_api_management_redis_cache': 'apimredis',
            'azurerm_api_management_subscription': 'apimsub',
            'azurerm_api_management_tag': 'apimtag',
            'azurerm_api_management_user': 'apimusr',
            
            # Key Vault related (kv base)
            'azurerm_key_vault_access_policy': 'kvap',
            'azurerm_key_vault_certificate': 'kvcert',
            'azurerm_key_vault_certificate_contacts': 'kvcertc',
            'azurerm_key_vault_certificate_issuer': 'kvcertic',
            'azurerm_key_vault_key': 'kvkey',
            'azurerm_key_vault_secret': 'kvsecret',
            
            # Application Gateway related (agw base)
            'azurerm_application_gateway_web_application_firewall_policy': 'agwwafp',
            
            # Virtual Network Gateway related (vgw base)
            'azurerm_virtual_network_gateway_nat_rule': 'vgwnat',
            
            # Front Door related (afd base)
            'azurerm_cdn_frontdoor_custom_domain': 'afdcd',
            'azurerm_cdn_frontdoor_custom_domain_association': 'afdcda',
            'azurerm_cdn_frontdoor_endpoint': 'afde',
            'azurerm_cdn_frontdoor_firewall_policy': 'afdfwp',
            'azurerm_cdn_frontdoor_origin': 'afdo',
            'azurerm_cdn_frontdoor_origin_group': 'afdog',
            'azurerm_cdn_frontdoor_profile': 'afdp',
            'azurerm_cdn_frontdoor_route': 'afdr',
            'azurerm_cdn_frontdoor_rule': 'afdrule',
            'azurerm_cdn_frontdoor_rule_set': 'afdrs',
            'azurerm_cdn_frontdoor_security_policy': 'afdsp',
            
            # Container App related (ca/cae base)
            'azurerm_container_app_custom_domain': 'cacd',
            'azurerm_container_app_environment_certificate': 'caecert',
            'azurerm_container_app_environment_dapr_component': 'caedapr',
            'azurerm_container_app_environment_storage': 'caestr',
            'azurerm_container_app_job': 'caj',
            
            # CosmosDB related patterns (cosmos base)
            'azurerm_cosmosdb_cassandra_datacenter': 'cosmosdc',
            'azurerm_cosmosdb_cassandra_keyspace': 'cosmosks',
            'azurerm_cosmosdb_cassandra_table': 'cosmostab',
            'azurerm_cosmosdb_gremlin_graph': 'cosmosgraph',
            'azurerm_cosmosdb_mongo_collection': 'cosmoscol',
            'azurerm_cosmosdb_mongo_role_definition': 'cosmosrole',
            'azurerm_cosmosdb_mongo_user_definition': 'cosmosuser',
            'azurerm_cosmosdb_notebook_workspace': 'cosmosnb',
            'azurerm_cosmosdb_postgresql_cluster': 'cospsql',
            'azurerm_cosmosdb_postgresql_configuration': 'cospsqlcfg',
            'azurerm_cosmosdb_postgresql_coordinator_configuration': 'cospsqlcc',
            'azurerm_cosmosdb_postgresql_database': 'cospsqldb',
            'azurerm_cosmosdb_postgresql_firewall_rule': 'cospsqlfw',
            'azurerm_cosmosdb_postgresql_node_configuration': 'cospsqlnc',
            'azurerm_cosmosdb_postgresql_role': 'cospsqlrole',
            'azurerm_cosmosdb_restorable_database_account': 'cosmosrda',
            'azurerm_cosmosdb_sql_container': 'cosmoscon',
            'azurerm_cosmosdb_sql_function': 'cosmosfn',
            'azurerm_cosmosdb_sql_role_assignment': 'cosmosra',
            'azurerm_cosmosdb_sql_role_definition': 'cosmosrd',
            'azurerm_cosmosdb_sql_stored_procedure': 'cosmossp',
            'azurerm_cosmosdb_sql_trigger': 'cosmostrigger',
            
            # Storage related patterns (st base)
            'azurerm_storage_account_customer_managed_key': 'stcmk',
            'azurerm_storage_account_local_user': 'stuser',
            'azurerm_storage_account_network_rules': 'stnetr',
            'azurerm_storage_blob': 'stblob',
            'azurerm_storage_blob_inventory_policy': 'stblobinv',
            'azurerm_storage_container': 'stcon',
            'azurerm_storage_data_lake_gen2_filesystem': 'stdlfs',
            'azurerm_storage_data_lake_gen2_path': 'stdlpath',
            'azurerm_storage_encryption_scope': 'stenc',
            'azurerm_storage_management_policy': 'stmp',
            'azurerm_storage_object_replication': 'stor',
            'azurerm_storage_queue': 'stq',
            'azurerm_storage_share_directory': 'stsd',
            'azurerm_storage_share_file': 'stsf',
            'azurerm_storage_table': 'stt',
            'azurerm_storage_table_entity': 'stte',
            
            # Log Analytics related (log base)
            'azurerm_log_analytics_cluster': 'logc',
            'azurerm_log_analytics_cluster_customer_managed_key': 'logccmk',
            'azurerm_log_analytics_data_export_rule': 'logder',
            'azurerm_log_analytics_datasource_windows_event': 'logdwe',
            'azurerm_log_analytics_datasource_windows_performance_counter': 'logdwpc',
            'azurerm_log_analytics_linked_service': 'logls',
            'azurerm_log_analytics_linked_storage_account': 'loglsa',
            'azurerm_log_analytics_query_pack_query': 'logqpq',
            'azurerm_log_analytics_saved_search': 'logss',
            'azurerm_log_analytics_solution': 'logsol',
            'azurerm_log_analytics_storage_insights': 'logsi',
            
            # Monitor/Application Insights related (appi/ag base)
            'azurerm_monitor_activity_log_alert': 'ala',
            'azurerm_monitor_autoscale_setting': 'as',
            'azurerm_monitor_data_collection_endpoint': 'dce',
            'azurerm_monitor_diagnostic_setting': 'diag',
            'azurerm_monitor_metric_alert': 'ma',
            'azurerm_monitor_private_link_scope': 'ampls',
            'azurerm_monitor_private_link_scoped_service': 'amplsss',
            'azurerm_monitor_scheduled_query_rules_alert': 'msqra',
            'azurerm_monitor_scheduled_query_rules_alert_v2': 'msqrav2',
            'azurerm_monitor_scheduled_query_rules_log': 'msqrl',
            'azurerm_monitor_smart_detector_alert_rule': 'msdar',
            'azurerm_application_insights_analytics_item': 'appiai',
            'azurerm_application_insights_api_key': 'appiak',
            'azurerm_application_insights_smart_detection_rule': 'appisdr',
            'azurerm_application_insights_standard_web_test': 'appiswt',
            'azurerm_application_insights_web_test': 'appiwt',
            'azurerm_application_insights_workbook': 'appiwb',
            'azurerm_application_insights_workbook_template': 'appiwbt',
            
            # AKS related patterns (aks base)
            'azurerm_kubernetes_cluster_node_pool': 'aksnp',
            'azurerm_kubernetes_cluster_trusted_access_role_binding': 'akstarb',
            'azurerm_kubernetes_fleet_manager': 'aksfm',
            'azurerm_kubernetes_flux_configuration': 'aksflux',
        }
        
        # Aplicar correcciones a recursos relacionados
        for resource in resources:
            resource_name = resource.get('name', '')
            current_slug = resource.get('slug', '')
            
            if resource_name in related_patterns:
                new_slug = related_patterns[resource_name]
                if current_slug != new_slug:
                    resource['slug'] = new_slug
                    corrections.append(f"  • {resource_name}: '{current_slug}' → '{new_slug}' (patrón relacionado)")
        
        # Guardar cambios
        if corrections:
            with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
                json.dump(resources, f, indent=2, ensure_ascii=False)
            
            print("🔗 ACTUALIZACIÓN DE RECURSOS RELACIONADOS:")
            print("=" * 60)
            for correction in corrections:
                print(correction)
            print(f"\n✅ Actualizados {len(corrections)} recursos relacionados")
            
            # Verificar estado final
            slugs = [r.get('slug', '') for r in resources]
            slug_counts = Counter(slugs)
            duplicated = sum(1 for count in slug_counts.values() if count > 1)
            
            print(f"\n📊 ESTADO DESPUÉS DE ACTUALIZACIÓN RELACIONADOS:")
            print(f"   • Total recursos: {len(resources)}")
            print(f"   • Slugs únicos: {len(set(slugs))}")
            print(f"   • Slugs duplicados: {duplicated}")
            
            return True
        else:
            print("ℹ️  No se encontraron recursos relacionados para actualizar")
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
    success = update_related_resources()
    sys.exit(0 if success else 1)
