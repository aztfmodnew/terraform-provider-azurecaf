#!/usr/bin/env python3
"""
Script para agregar TODOS los recursos oficiales de Microsoft CAF que faltan.
Basado en la documentación oficial: 
https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
"""

import json
import sys
from collections import Counter

def add_all_missing_caf_resources():
    """Agrega todos los recursos oficiales de Microsoft CAF que faltan"""
    
    try:
        # Cargar resourceDefinition.json
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            resources = json.load(f)
        
        # Mapeo COMPLETO de recursos oficiales Microsoft CAF
        # Cada entrada incluye: nombre del recurso terraform, slug CAF, descripción
        official_caf_resources = {
            # AI + Machine Learning
            'azurerm_search_service': {
                'slug': 'srch',
                'description': 'AI Search',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account': {
                'slug': 'ais',
                'description': 'Azure AI services (multi-service account)',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_ai_foundry': {
                'slug': 'aif',
                'description': 'Azure AI Foundry account',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_ai_foundry_project': {
                'slug': 'proj',
                'description': 'Azure AI Foundry account project',
                'category': 'AI + Machine Learning'
            },
            'azurerm_machine_learning_workspace_hub': {
                'slug': 'hub',
                'description': 'Azure AI Foundry hub',
                'category': 'AI + Machine Learning'
            },
            'azurerm_machine_learning_workspace_project': {
                'slug': 'proj',
                'description': 'Azure AI Foundry hub project',
                'category': 'AI + Machine Learning'
            },
            'azurerm_video_indexer_account': {
                'slug': 'avi',
                'description': 'Azure AI Video Indexer',
                'category': 'AI + Machine Learning'
            },
            'azurerm_machine_learning_workspace': {
                'slug': 'mlw',
                'description': 'Azure Machine Learning workspace',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_openai': {
                'slug': 'oai',
                'description': 'Azure OpenAI Service',
                'category': 'AI + Machine Learning'
            },
            'azurerm_bot_service': {
                'slug': 'bot',
                'description': 'Bot service',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_computer_vision': {
                'slug': 'cv',
                'description': 'Computer vision',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_content_moderator': {
                'slug': 'cm',
                'description': 'Content moderator',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_content_safety': {
                'slug': 'cs',
                'description': 'Content safety',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_custom_vision_prediction': {
                'slug': 'cstv',
                'description': 'Custom vision (prediction)',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_custom_vision_training': {
                'slug': 'cstvt',
                'description': 'Custom vision (training)',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_form_recognizer': {
                'slug': 'di',
                'description': 'Document intelligence',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_face': {
                'slug': 'face',
                'description': 'Face API',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_health_insights': {
                'slug': 'hi',
                'description': 'Health Insights',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_immersive_reader': {
                'slug': 'ir',
                'description': 'Immersive reader',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_text_analytics': {
                'slug': 'lang',
                'description': 'Language service',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_speech_services': {
                'slug': 'spch',
                'description': 'Speech service',
                'category': 'AI + Machine Learning'
            },
            'azurerm_cognitive_account_text_translation': {
                'slug': 'trsl',
                'description': 'Translator',
                'category': 'AI + Machine Learning'
            },
            
            # Analytics and IoT
            'azurerm_analysis_services_server': {
                'slug': 'as',
                'description': 'Azure Analysis Services server',
                'category': 'Analytics and IoT'
            },
            'azurerm_databricks_access_connector': {
                'slug': 'dbac',
                'description': 'Azure Databricks Access Connector',
                'category': 'Analytics and IoT'
            },
            'azurerm_databricks_workspace': {
                'slug': 'dbw',
                'description': 'Azure Databricks workspace',
                'category': 'Analytics and IoT'
            },
            'azurerm_kusto_cluster': {
                'slug': 'dec',
                'description': 'Azure Data Explorer cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_kusto_database': {
                'slug': 'dedb',
                'description': 'Azure Data Explorer cluster database',
                'category': 'Analytics and IoT'
            },
            'azurerm_data_factory': {
                'slug': 'adf',
                'description': 'Azure Data Factory',
                'category': 'Analytics and IoT'
            },
            'azurerm_digital_twins_instance': {
                'slug': 'dt',
                'description': 'Azure Digital Twin instance',
                'category': 'Analytics and IoT'
            },
            'azurerm_stream_analytics_cluster': {
                'slug': 'asa',
                'description': 'Azure Stream Analytics',
                'category': 'Analytics and IoT'
            },
            'azurerm_synapse_private_link_hub': {
                'slug': 'synplh',
                'description': 'Azure Synapse Analytics private link hub',
                'category': 'Analytics and IoT'
            },
            'azurerm_synapse_sql_pool': {
                'slug': 'syndp',
                'description': 'Azure Synapse Analytics SQL Dedicated Pool',
                'category': 'Analytics and IoT'
            },
            'azurerm_synapse_spark_pool': {
                'slug': 'synsp',
                'description': 'Azure Synapse Analytics Spark Pool',
                'category': 'Analytics and IoT'
            },
            'azurerm_synapse_workspace': {
                'slug': 'synw',
                'description': 'Azure Synapse Analytics workspaces',
                'category': 'Analytics and IoT'
            },
            'azurerm_data_lake_store': {
                'slug': 'dls',
                'description': 'Data Lake Store account',
                'category': 'Analytics and IoT'
            },
            'azurerm_data_lake_analytics_account': {
                'slug': 'dla',
                'description': 'Data Lake Analytics account',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventhub_namespace': {
                'slug': 'evhns',
                'description': 'Event Hubs namespace',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventhub': {
                'slug': 'evh',
                'description': 'Event hub',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventgrid_domain': {
                'slug': 'evgd',
                'description': 'Event Grid domain',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventgrid_namespace': {
                'slug': 'evgns',
                'description': 'Event Grid namespace',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventgrid_subscription': {
                'slug': 'evgs',
                'description': 'Event Grid subscriptions',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventgrid_topic': {
                'slug': 'evgt',
                'description': 'Event Grid topic',
                'category': 'Analytics and IoT'
            },
            'azurerm_eventgrid_system_topic': {
                'slug': 'egst',
                'description': 'Event Grid system topic',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_hadoop_cluster': {
                'slug': 'hadoop',
                'description': 'HDInsight - Hadoop cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_hbase_cluster': {
                'slug': 'hbase',
                'description': 'HDInsight - HBase cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_kafka_cluster': {
                'slug': 'kafka',
                'description': 'HDInsight - Kafka cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_spark_cluster': {
                'slug': 'spark',
                'description': 'HDInsight - Spark cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_storm_cluster': {
                'slug': 'storm',
                'description': 'HDInsight - Storm cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_hdinsight_ml_services_cluster': {
                'slug': 'mls',
                'description': 'HDInsight - ML Services cluster',
                'category': 'Analytics and IoT'
            },
            'azurerm_iothub': {
                'slug': 'iot',
                'description': 'IoT hub',
                'category': 'Analytics and IoT'
            },
            'azurerm_iot_dps': {
                'slug': 'provs',
                'description': 'Provisioning services',
                'category': 'Analytics and IoT'
            },
            'azurerm_iot_dps_certificate': {
                'slug': 'pcert',
                'description': 'Provisioning services certificate',
                'category': 'Analytics and IoT'
            },
            'azurerm_powerbi_embedded': {
                'slug': 'pbi',
                'description': 'Power BI Embedded',
                'category': 'Analytics and IoT'
            },
            'azurerm_time_series_insights_environment': {
                'slug': 'tsi',
                'description': 'Time Series Insights environment',
                'category': 'Analytics and IoT'
            },
            
            # Compute and Web
            'azurerm_app_service_environment': {
                'slug': 'ase',
                'description': 'App Service environment',
                'category': 'Compute and Web'
            },
            'azurerm_app_service_plan': {
                'slug': 'asp',
                'description': 'App Service plan',
                'category': 'Compute and Web'
            },
            'azurerm_load_test': {
                'slug': 'lt',
                'description': 'Azure Load Testing instance',
                'category': 'Compute and Web'
            },
            'azurerm_availability_set': {
                'slug': 'avail',
                'description': 'Availability set',
                'category': 'Compute and Web'
            },
            'azurerm_arc_machine': {
                'slug': 'arcs',
                'description': 'Azure Arc enabled server',
                'category': 'Compute and Web'
            },
            'azurerm_arc_kubernetes_cluster': {
                'slug': 'arck',
                'description': 'Azure Arc enabled Kubernetes cluster',
                'category': 'Compute and Web'
            },
            'azurerm_arc_private_link_scope': {
                'slug': 'pls',
                'description': 'Azure Arc private link scope',
                'category': 'Compute and Web'
            },
            'azurerm_arc_gateway': {
                'slug': 'arcgw',
                'description': 'Azure Arc gateway',
                'category': 'Compute and Web'
            },
            'azurerm_batch_account': {
                'slug': 'ba',
                'description': 'Batch accounts',
                'category': 'Compute and Web'
            },
            'azurerm_cloud_service': {
                'slug': 'cld',
                'description': 'Cloud service',
                'category': 'Compute and Web'
            },
            'azurerm_communication_service': {
                'slug': 'acs',
                'description': 'Communication Services',
                'category': 'Compute and Web'
            },
            'azurerm_disk_encryption_set': {
                'slug': 'des',
                'description': 'Disk encryption set',
                'category': 'Compute and Web'
            },
            'azurerm_function_app': {
                'slug': 'func',
                'description': 'Function app',
                'category': 'Compute and Web'
            },
            'azurerm_shared_image_gallery': {
                'slug': 'gal',
                'description': 'Gallery',
                'category': 'Compute and Web'
            },
            'azurerm_app_service_environment_hosting': {
                'slug': 'host',
                'description': 'Hosting environment',
                'category': 'Compute and Web'
            },
            'azurerm_image_template': {
                'slug': 'it',
                'description': 'Image template',
                'category': 'Compute and Web'
            },
            'azurerm_managed_disk_os': {
                'slug': 'osdisk',
                'description': 'Managed disk (OS)',
                'category': 'Compute and Web'
            },
            'azurerm_managed_disk': {
                'slug': 'disk',
                'description': 'Managed disk (data)',
                'category': 'Compute and Web'
            },
            'azurerm_notification_hub': {
                'slug': 'ntf',
                'description': 'Notification Hubs',
                'category': 'Compute and Web'
            },
            'azurerm_notification_hub_namespace': {
                'slug': 'ntfns',
                'description': 'Notification Hubs namespace',
                'category': 'Compute and Web'
            },
            'azurerm_proximity_placement_group': {
                'slug': 'ppg',
                'description': 'Proximity placement group',
                'category': 'Compute and Web'
            },
            'azurerm_restore_point_collection': {
                'slug': 'rpc',
                'description': 'Restore point collection',
                'category': 'Compute and Web'
            },
            'azurerm_snapshot': {
                'slug': 'snap',
                'description': 'Snapshot',
                'category': 'Compute and Web'
            },
            'azurerm_virtual_machine': {
                'slug': 'vm',
                'description': 'Virtual machine',
                'category': 'Compute and Web'
            },
            'azurerm_virtual_machine_scale_set': {
                'slug': 'vmss',
                'description': 'Virtual machine scale set',
                'category': 'Compute and Web'
            },
            'azurerm_maintenance_configuration': {
                'slug': 'mc',
                'description': 'Virtual machine maintenance configuration',
                'category': 'Compute and Web'
            },
            'azurerm_storage_account_vm': {
                'slug': 'stvm',
                'description': 'VM storage account',
                'category': 'Compute and Web'
            },
            'azurerm_app_service': {
                'slug': 'app',
                'description': 'Web app',
                'category': 'Compute and Web'
            },
            
            # Containers
            'azurerm_kubernetes_cluster': {
                'slug': 'aks',
                'description': 'AKS cluster',
                'category': 'Containers'
            },
            'azurerm_kubernetes_cluster_node_pool_system': {
                'slug': 'npsystem',
                'description': 'AKS system node pool',
                'category': 'Containers'
            },
            'azurerm_kubernetes_cluster_node_pool': {
                'slug': 'np',
                'description': 'AKS user node pool',
                'category': 'Containers'
            },
            'azurerm_container_app': {
                'slug': 'ca',
                'description': 'Container apps',
                'category': 'Containers'
            },
            'azurerm_container_app_environment': {
                'slug': 'cae',
                'description': 'Container apps environment',
                'category': 'Containers'
            },
            'azurerm_container_registry': {
                'slug': 'cr',
                'description': 'Container registry',
                'category': 'Containers'
            },
            'azurerm_container_group': {
                'slug': 'ci',
                'description': 'Container instance',
                'category': 'Containers'
            },
            'azurerm_service_fabric_cluster': {
                'slug': 'sf',
                'description': 'Service Fabric cluster',
                'category': 'Containers'
            },
            'azurerm_service_fabric_managed_cluster': {
                'slug': 'sfmc',
                'description': 'Service Fabric managed cluster',
                'category': 'Containers'
            },
            
            # Databases
            'azurerm_cosmosdb_account': {
                'slug': 'cosmos',
                'description': 'Azure Cosmos DB database',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_cassandra_cluster': {
                'slug': 'coscas',
                'description': 'Azure Cosmos DB for Apache Cassandra account',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_mongo_database': {
                'slug': 'cosmon',
                'description': 'Azure Cosmos DB for MongoDB account',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_sql_database': {
                'slug': 'cosno',
                'description': 'Azure Cosmos DB for NoSQL account',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_table': {
                'slug': 'costab',
                'description': 'Azure Cosmos DB for Table account',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_gremlin_database': {
                'slug': 'cosgrm',
                'description': 'Azure Cosmos DB for Apache Gremlin account',
                'category': 'Databases'
            },
            'azurerm_cosmosdb_postgresql_cluster': {
                'slug': 'cospos',
                'description': 'Azure Cosmos DB PostgreSQL cluster',
                'category': 'Databases'
            },
            'azurerm_redis_cache': {
                'slug': 'redis',
                'description': 'Azure Cache for Redis instance',
                'category': 'Databases'
            },
            'azurerm_mssql_server': {
                'slug': 'sql',
                'description': 'Azure SQL Database server',
                'category': 'Databases'
            },
            'azurerm_mssql_database': {
                'slug': 'sqldb',
                'description': 'Azure SQL database',
                'category': 'Databases'
            },
            'azurerm_mssql_job_agent': {
                'slug': 'sqlja',
                'description': 'Azure SQL Elastic Job agent',
                'category': 'Databases'
            },
            'azurerm_mssql_elasticpool': {
                'slug': 'sqlep',
                'description': 'Azure SQL Elastic Pool',
                'category': 'Databases'
            },
            'azurerm_mysql_server': {
                'slug': 'mysql',
                'description': 'MySQL database',
                'category': 'Databases'
            },
            'azurerm_postgresql_server': {
                'slug': 'psql',
                'description': 'PostgreSQL database',
                'category': 'Databases'
            },
            'azurerm_sql_database_stretch': {
                'slug': 'sqlstrdb',
                'description': 'SQL Server Stretch Database',
                'category': 'Databases'
            },
            'azurerm_mssql_managed_instance': {
                'slug': 'sqlmi',
                'description': 'SQL Managed Instance',
                'category': 'Databases'
            },
            
            # Developer Tools
            'azurerm_app_configuration': {
                'slug': 'appcs',
                'description': 'App Configuration store',
                'category': 'Developer Tools'
            },
            'azurerm_maps_account': {
                'slug': 'map',
                'description': 'Maps account',
                'category': 'Developer Tools'
            },
            'azurerm_signalr_service': {
                'slug': 'sigr',
                'description': 'SignalR',
                'category': 'Developer Tools'
            },
            'azurerm_web_pubsub': {
                'slug': 'wps',
                'description': 'WebPubSub',
                'category': 'Developer Tools'
            },
            
            # DevOps
            'azurerm_dashboard_grafana': {
                'slug': 'amg',
                'description': 'Azure Managed Grafana',
                'category': 'DevOps'
            },
            
            # Integration
            'azurerm_api_management': {
                'slug': 'apim',
                'description': 'API management service instance',
                'category': 'Integration'
            },
            'azurerm_logic_app_integration_account': {
                'slug': 'ia',
                'description': 'Integration account',
                'category': 'Integration'
            },
            'azurerm_logic_app_workflow': {
                'slug': 'logic',
                'description': 'Logic app',
                'category': 'Integration'
            },
            'azurerm_servicebus_namespace': {
                'slug': 'sbns',
                'description': 'Service Bus namespace',
                'category': 'Integration'
            },
            'azurerm_servicebus_queue': {
                'slug': 'sbq',
                'description': 'Service Bus queue',
                'category': 'Integration'
            },
            'azurerm_servicebus_topic': {
                'slug': 'sbt',
                'description': 'Service Bus topic',
                'category': 'Integration'
            },
            'azurerm_servicebus_subscription': {
                'slug': 'sbts',
                'description': 'Service Bus topic subscription',
                'category': 'Integration'
            },
            
            # Management and Governance
            'azurerm_automation_account': {
                'slug': 'aa',
                'description': 'Automation account',
                'category': 'Management and Governance'
            },
            'azurerm_policy_definition': {
                'slug': 'policy',
                'description': 'Azure Policy definition',
                'category': 'Management and Governance'
            },
            'azurerm_application_insights': {
                'slug': 'appi',
                'description': 'Application Insights',
                'category': 'Management and Governance'
            },
            'azurerm_monitor_action_group': {
                'slug': 'ag',
                'description': 'Azure Monitor action group',
                'category': 'Management and Governance'
            },
            'azurerm_monitor_data_collection_rule': {
                'slug': 'dcr',
                'description': 'Azure Monitor data collection rule',
                'category': 'Management and Governance'
            },
            'azurerm_monitor_alert_processing_rule_action_group': {
                'slug': 'apr',
                'description': 'Azure Monitor alert processing rule',
                'category': 'Management and Governance'
            },
            'azurerm_blueprint_definition': {
                'slug': 'bp',
                'description': 'Blueprint (planned for deprecation)',
                'category': 'Management and Governance'
            },
            'azurerm_blueprint_assignment': {
                'slug': 'bpa',
                'description': 'Blueprint assignment (planned for deprecation)',
                'category': 'Management and Governance'
            },
            'azurerm_monitor_data_collection_endpoint': {
                'slug': 'dce',
                'description': 'Data collection endpoint',
                'category': 'Management and Governance'
            },
            'azurerm_resource_deployment_script_azure_cli': {
                'slug': 'script',
                'description': 'Deployment scripts',
                'category': 'Management and Governance'
            },
            'azurerm_log_analytics_workspace': {
                'slug': 'log',
                'description': 'Log Analytics workspace',
                'category': 'Management and Governance'
            },
            'azurerm_log_analytics_query_pack': {
                'slug': 'pack',
                'description': 'Log Analytics query packs',
                'category': 'Management and Governance'
            },
            'azurerm_management_group': {
                'slug': 'mg',
                'description': 'Management group',
                'category': 'Management and Governance'
            },
            'azurerm_purview_account': {
                'slug': 'pview',
                'description': 'Microsoft Purview instance',
                'category': 'Management and Governance'
            },
            'azurerm_resource_group': {
                'slug': 'rg',
                'description': 'Resource group',
                'category': 'Management and Governance'
            },
            'azurerm_template_spec': {
                'slug': 'ts',
                'description': 'Template specs name',
                'category': 'Management and Governance'
            },
            
            # Migration
            'azurerm_migrate_project': {
                'slug': 'migr',
                'description': 'Azure Migrate project',
                'category': 'Migration'
            },
            'azurerm_database_migration_service': {
                'slug': 'dms',
                'description': 'Database Migration Service instance',
                'category': 'Migration'
            },
            'azurerm_recovery_services_vault': {
                'slug': 'rsv',
                'description': 'Recovery Services vault',
                'category': 'Migration'
            },
            
            # Networking
            'azurerm_application_gateway': {
                'slug': 'agw',
                'description': 'Application gateway',
                'category': 'Networking'
            },
            'azurerm_application_security_group': {
                'slug': 'asg',
                'description': 'Application security group (ASG)',
                'category': 'Networking'
            },
            'azurerm_cdn_profile': {
                'slug': 'cdnp',
                'description': 'CDN profile',
                'category': 'Networking'
            },
            'azurerm_cdn_endpoint': {
                'slug': 'cdne',
                'description': 'CDN endpoint',
                'category': 'Networking'
            },
            'azurerm_virtual_network_gateway_connection': {
                'slug': 'con',
                'description': 'Connections',
                'category': 'Networking'
            },
            'azurerm_dns_zone': {
                'slug': 'dns',
                'description': 'DNS zone',
                'category': 'Networking'
            },
            'azurerm_dns_forwarding_ruleset': {
                'slug': 'dnsfrs',
                'description': 'DNS forwarding ruleset',
                'category': 'Networking'
            },
            'azurerm_dns_private_resolver': {
                'slug': 'dnspr',
                'description': 'DNS private resolver',
                'category': 'Networking'
            },
            'azurerm_dns_private_resolver_inbound_endpoint': {
                'slug': 'in',
                'description': 'DNS private resolver inbound endpoint',
                'category': 'Networking'
            },
            'azurerm_dns_private_resolver_outbound_endpoint': {
                'slug': 'out',
                'description': 'DNS private resolver outbound endpoint',
                'category': 'Networking'
            },
            'azurerm_private_dns_zone': {
                'slug': 'dns',
                'description': 'DNS zone',
                'category': 'Networking'
            },
            'azurerm_firewall': {
                'slug': 'afw',
                'description': 'Firewall',
                'category': 'Networking'
            },
            'azurerm_firewall_policy': {
                'slug': 'afwp',
                'description': 'Firewall policy',
                'category': 'Networking'
            },
            'azurerm_express_route_circuit': {
                'slug': 'erc',
                'description': 'ExpressRoute circuit',
                'category': 'Networking'
            },
            'azurerm_express_route_port': {
                'slug': 'erd',
                'description': 'ExpressRoute direct',
                'category': 'Networking'
            },
            'azurerm_express_route_gateway': {
                'slug': 'ergw',
                'description': 'ExpressRoute gateway',
                'category': 'Networking'
            },
            'azurerm_frontdoor_profile': {
                'slug': 'afd',
                'description': 'Front Door (Standard/Premium) profile',
                'category': 'Networking'
            },
            'azurerm_frontdoor_endpoint': {
                'slug': 'fde',
                'description': 'Front Door (Standard/Premium) endpoint',
                'category': 'Networking'
            },
            'azurerm_frontdoor_firewall_policy': {
                'slug': 'fdfp',
                'description': 'Front Door firewall policy',
                'category': 'Networking'
            },
            'azurerm_frontdoor': {
                'slug': 'afd',
                'description': 'Front Door (classic)',
                'category': 'Networking'
            },
            'azurerm_ip_group': {
                'slug': 'ipg',
                'description': 'IP group',
                'category': 'Networking'
            },
            'azurerm_lb_internal': {
                'slug': 'lbi',
                'description': 'Load balancer (internal)',
                'category': 'Networking'
            },
            'azurerm_lb': {
                'slug': 'lb',
                'description': 'Load balancer (external)',
                'category': 'Networking'
            },
            'azurerm_lb_rule': {
                'slug': 'rule',
                'description': 'Load balancer rule',
                'category': 'Networking'
            },
            'azurerm_local_network_gateway': {
                'slug': 'lgw',
                'description': 'Local network gateway',
                'category': 'Networking'
            },
            'azurerm_nat_gateway': {
                'slug': 'ng',
                'description': 'NAT gateway',
                'category': 'Networking'
            },
            'azurerm_network_interface': {
                'slug': 'nic',
                'description': 'Network interface (NIC)',
                'category': 'Networking'
            },
            'azurerm_network_security_perimeter': {
                'slug': 'nsp',
                'description': 'Network security perimeter',
                'category': 'Networking'
            },
            'azurerm_network_security_group': {
                'slug': 'nsg',
                'description': 'Network security group (NSG)',
                'category': 'Networking'
            },
            'azurerm_network_security_rule': {
                'slug': 'nsgsr',
                'description': 'Network security group (NSG) security rules',
                'category': 'Networking'
            },
            'azurerm_network_watcher': {
                'slug': 'nw',
                'description': 'Network Watcher',
                'category': 'Networking'
            },
            'azurerm_private_link_service': {
                'slug': 'pl',
                'description': 'Private Link',
                'category': 'Networking'
            },
            'azurerm_private_endpoint': {
                'slug': 'pep',
                'description': 'Private endpoint',
                'category': 'Networking'
            },
            'azurerm_public_ip': {
                'slug': 'pip',
                'description': 'Public IP address',
                'category': 'Networking'
            },
            'azurerm_public_ip_prefix': {
                'slug': 'ippre',
                'description': 'Public IP address prefix',
                'category': 'Networking'
            },
            'azurerm_route_filter': {
                'slug': 'rf',
                'description': 'Route filter',
                'category': 'Networking'
            },
            'azurerm_route_server': {
                'slug': 'rtserv',
                'description': 'Route server',
                'category': 'Networking'
            },
            'azurerm_route_table': {
                'slug': 'rt',
                'description': 'Route table',
                'category': 'Networking'
            },
            'azurerm_service_endpoint_policy': {
                'slug': 'se',
                'description': 'Service endpoint policy',
                'category': 'Networking'
            },
            'azurerm_traffic_manager_profile': {
                'slug': 'traf',
                'description': 'Traffic Manager profile',
                'category': 'Networking'
            },
            'azurerm_route': {
                'slug': 'udr',
                'description': 'User defined route (UDR)',
                'category': 'Networking'
            },
            'azurerm_virtual_network': {
                'slug': 'vnet',
                'description': 'Virtual network',
                'category': 'Networking'
            },
            'azurerm_virtual_network_gateway': {
                'slug': 'vgw',
                'description': 'Virtual network gateway',
                'category': 'Networking'
            },
            'azurerm_network_manager': {
                'slug': 'vnm',
                'description': 'Virtual network manager',
                'category': 'Networking'
            },
            'azurerm_virtual_network_peering': {
                'slug': 'peer',
                'description': 'Virtual network peering',
                'category': 'Networking'
            },
            'azurerm_subnet': {
                'slug': 'snet',
                'description': 'Virtual network subnet',
                'category': 'Networking'
            },
            'azurerm_virtual_wan': {
                'slug': 'vwan',
                'description': 'Virtual WAN',
                'category': 'Networking'
            },
            'azurerm_virtual_hub': {
                'slug': 'vhub',
                'description': 'Virtual WAN Hub',
                'category': 'Networking'
            },
            
            # Security
            'azurerm_bastion_host': {
                'slug': 'bas',
                'description': 'Azure Bastion',
                'category': 'Security'
            },
            'azurerm_key_vault': {
                'slug': 'kv',
                'description': 'Key vault',
                'category': 'Security'
            },
            'azurerm_key_vault_managed_hardware_security_module': {
                'slug': 'kvmhsm',
                'description': 'Key Vault Managed HSM',
                'category': 'Security'
            },
            'azurerm_user_assigned_identity': {
                'slug': 'id',
                'description': 'Managed identity',
                'category': 'Security'
            },
            'azurerm_ssh_public_key': {
                'slug': 'sshkey',
                'description': 'SSH key',
                'category': 'Security'
            },
            'azurerm_vpn_gateway': {
                'slug': 'vpng',
                'description': 'VPN Gateway',
                'category': 'Security'
            },
            'azurerm_vpn_gateway_connection': {
                'slug': 'vcn',
                'description': 'VPN connection',
                'category': 'Security'
            },
            'azurerm_vpn_site': {
                'slug': 'vst',
                'description': 'VPN site',
                'category': 'Security'
            },
            'azurerm_web_application_firewall_policy': {
                'slug': 'waf',
                'description': 'Web Application Firewall (WAF) policy',
                'category': 'Security'
            },
            'azurerm_web_application_firewall_policy_rule_group': {
                'slug': 'wafrg',
                'description': 'Web Application Firewall (WAF) policy rule group',
                'category': 'Security'
            },
            
            # Storage
            'azurerm_storsimple_manager': {
                'slug': 'ssimp',
                'description': 'Azure StorSimple',
                'category': 'Storage'
            },
            'azurerm_data_protection_backup_vault': {
                'slug': 'bvault',
                'description': 'Backup Vault name',
                'category': 'Storage'
            },
            'azurerm_data_protection_backup_policy': {
                'slug': 'bkpol',
                'description': 'Backup Vault policy',
                'category': 'Storage'
            },
            'azurerm_storage_share': {
                'slug': 'share',
                'description': 'File share',
                'category': 'Storage'
            },
            'azurerm_storage_account': {
                'slug': 'st',
                'description': 'Storage account',
                'category': 'Storage'
            },
            'azurerm_storage_sync': {
                'slug': 'sss',
                'description': 'Storage Sync Service name',
                'category': 'Storage'
            },
            
            # Virtual Desktop Infrastructure
            'azurerm_virtual_desktop_host_pool': {
                'slug': 'vdpool',
                'description': 'Virtual desktop host pool',
                'category': 'Virtual Desktop Infrastructure'
            },
            'azurerm_virtual_desktop_application_group': {
                'slug': 'vdag',
                'description': 'Virtual desktop application group',
                'category': 'Virtual Desktop Infrastructure'
            },
            'azurerm_virtual_desktop_workspace': {
                'slug': 'vdws',
                'description': 'Virtual desktop workspace',
                'category': 'Virtual Desktop Infrastructure'
            },
            'azurerm_virtual_desktop_scaling_plan': {
                'slug': 'vdscaling',
                'description': 'Virtual desktop scaling plan',
                'category': 'Virtual Desktop Infrastructure'
            }
        }
        
        # Obtener recursos existentes
        existing_resources = {resource.get('name', '') for resource in resources}
        
        # Identificar recursos faltantes
        missing_resources = []
        updated_resources = []
        
        for resource_name, caf_info in official_caf_resources.items():
            if resource_name not in existing_resources:
                missing_resources.append({
                    'name': resource_name,
                    'slug': caf_info['slug'],
                    'description': caf_info['description'],
                    'category': caf_info['category']
                })
            else:
                # Verificar si el slug actual coincide con CAF
                for existing_resource in resources:
                    if existing_resource.get('name') == resource_name:
                        current_slug = existing_resource.get('slug', '')
                        expected_slug = caf_info['slug']
                        if current_slug != expected_slug:
                            existing_resource['slug'] = expected_slug
                            updated_resources.append(f"  • {resource_name}: '{current_slug}' → '{expected_slug}' (CAF oficial)")
        
        # Agregar recursos faltantes con configuración estándar
        for missing in missing_resources:
            new_resource = {
                "name": missing['name'],
                "slug": missing['slug'],
                "min_length": 1,
                "max_length": 24,
                "lowercase": False,
                "regex": "^[a-zA-Z0-9][a-zA-Z0-9-_]*[a-zA-Z0-9]$",
                "scope": "resourceGroup",
                "dashes": True
            }
            resources.append(new_resource)
        
        # Guardar cambios si hay modificaciones
        if missing_resources or updated_resources:
            with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
                json.dump(resources, f, indent=2, ensure_ascii=False)
            
            print("🏷️ ADICIÓN COMPLETA DE RECURSOS OFICIALES MICROSOFT CAF:")
            print("=" * 80)
            
            if missing_resources:
                print(f"\n✅ RECURSOS AGREGADOS ({len(missing_resources)}):")
                print("-" * 50)
                current_category = ""
                for missing in missing_resources:
                    if missing['category'] != current_category:
                        current_category = missing['category']
                        print(f"\n📂 {current_category}:")
                    print(f"  • {missing['name']} → '{missing['slug']}' ({missing['description']})")
            
            if updated_resources:
                print(f"\n🔧 RECURSOS ACTUALIZADOS ({len(updated_resources)}):")
                print("-" * 50)
                for update in updated_resources:
                    print(update)
            
            # Verificar estado final
            total_resources = len(resources)
            slugs = [r.get('slug', '') for r in resources]
            unique_slugs = len(set(slugs))
            slug_counts = Counter(slugs)
            duplicates = sum(1 for count in slug_counts.values() if count > 1)
            
            print(f"\n📊 ESTADO DESPUÉS DE AGREGAR RECURSOS CAF:")
            print(f"   • Total recursos: {total_resources}")
            print(f"   • Nuevos recursos agregados: {len(missing_resources)}")
            print(f"   • Recursos actualizados: {len(updated_resources)}")
            print(f"   • Slugs únicos: {unique_slugs}")
            print(f"   • Slugs duplicados: {duplicates}")
            
            if duplicates == 0:
                print("\n🎉 ¡PERFECTO! - Todos los recursos CAF agregados sin duplicados")
            else:
                print(f"\n⚠️ Se detectaron {duplicates} duplicados que requieren atención")
            
            return True
        else:
            print("ℹ️ Todos los recursos oficiales CAF ya están presentes y actualizados")
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
    success = add_all_missing_caf_resources()
    sys.exit(0 if success else 1)
