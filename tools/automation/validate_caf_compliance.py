#!/usr/bin/env python3
"""
Microsoft CAF compliance validation script
Validates resource slugs against official CAF abbreviations
"""

import json
import sys
from collections import Counter

# Official Microsoft CAF abbreviations
OFFICIAL_CAF_MAPPING = {
    # From https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
    'azurerm_api_management': 'apim',
    'azurerm_application_gateway': 'agw',
    'azurerm_application_insights': 'appi',
    'azurerm_automation_account': 'aa',
    'azurerm_availability_set': 'avail',
    'azurerm_bastion_host': 'bas',
    'azurerm_container_registry': 'cr',
    'azurerm_cosmosdb_account': 'cosmos',
    'azurerm_data_factory': 'adf',
    'azurerm_databricks_workspace': 'dbw',
    'azurerm_firewall': 'afw',
    'azurerm_function_app': 'func',
    'azurerm_key_vault': 'kv',
    'azurerm_kubernetes_cluster': 'aks',
    'azurerm_lb': 'lbe',  # Load balancer external (default for generic LB)
    'azurerm_log_analytics_workspace': 'log',
    'azurerm_logic_app_workflow': 'logic',  # Official CAF recommendation
    'azurerm_managed_disk': 'disk',
    'azurerm_mysql_server': 'mysql',
    'azurerm_mssql_server': 'sql',  # Current Microsoft SQL Server
    'azurerm_network_interface': 'nic',
    'azurerm_network_security_group': 'nsg',
    'azurerm_postgresql_server': 'psql',
    'azurerm_public_ip': 'pip',
    'azurerm_redis_cache': 'redis',
    'azurerm_resource_group': 'rg',
    'azurerm_storage_account': 'st',
    'azurerm_subnet': 'snet',
    'azurerm_virtual_machine': 'vm',
    'azurerm_virtual_network': 'vnet',
    'azurerm_virtual_network_gateway': 'vgw',
    # Add more as needed...
}

def validate_compliance():
    try:
        with open('resourceDefinition.json', 'r') as f:
            resources = json.load(f)
        
        compliant = 0
        non_compliant = []
        duplicates = []
        
        # Check compliance
        for resource in resources:
            name = resource.get('name', '')
            slug = resource.get('slug', '')
            
            if name in OFFICIAL_CAF_MAPPING:
                expected = OFFICIAL_CAF_MAPPING[name]
                if slug == expected:
                    compliant += 1
                else:
                    non_compliant.append(f"{name}: '{slug}' should be '{expected}'")
        
        # Check for duplicates
        slugs = [r.get('slug', '') for r in resources if r.get('slug')]
        slug_counts = Counter(slugs)
        duplicate_slugs = {slug: count for slug, count in slug_counts.items() if count > 1}
        
        # Report results
        print(f"🏷️ CAF COMPLIANCE REPORT:")
        print("=" * 50)
        print(f"✅ Compliant resources: {compliant}")
        print(f"⚠️ Non-compliant resources: {len(non_compliant)}")
        print(f"❌ Duplicate slugs: {len(duplicate_slugs)}")
        print(f"📊 Total unique slugs: {len(set(slugs))}")
        print(f"📊 Total resources: {len(resources)}")
        
        if non_compliant:
            print("\n⚠️ NON-COMPLIANT RESOURCES:")
            for item in non_compliant[:10]:  # Show first 10
                print(f"  • {item}")
            if len(non_compliant) > 10:
                print(f"  ... and {len(non_compliant) - 10} more")
        
        if duplicate_slugs:
            print("\n❌ DUPLICATE SLUGS:")
            for slug, count in list(duplicate_slugs.items())[:5]:  # Show first 5
                print(f"  • '{slug}' used {count} times")
            if len(duplicate_slugs) > 5:
                print(f"  ... and {len(duplicate_slugs) - 5} more duplicates")
        
        if not non_compliant and not duplicate_slugs:
            print("\n🎉 PERFECT COMPLIANCE! All resources follow CAF standards.")
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ Validation error: {e}")
        return False

if __name__ == "__main__":
    success = validate_compliance()
    sys.exit(0 if success else 1)
