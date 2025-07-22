#!/usr/bin/env python3
"""
Script para resolver los 8 duplicados restantes después de añadir recursos CAF oficiales
"""

import json
import sys
from collections import defaultdict

def load_resource_definitions():
    """Cargar definiciones de recursos desde resourceDefinition.json"""
    try:
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data if isinstance(data, list) else data.get('azurerm', [])
    except FileNotFoundError:
        print("❌ Error: No se encontró resourceDefinition.json")
        return []
    except json.JSONDecodeError:
        print("❌ Error: JSON inválido en resourceDefinition.json")
        return []

def find_duplicates(resources):
    """Encontrar recursos con slugs duplicados"""
    slug_map = defaultdict(list)
    for resource in resources:
        slug = resource.get('slug', '')
        if slug:
            slug_map[slug].append(resource)
    
    duplicates = {slug: resources for slug, resources in slug_map.items() if len(resources) > 1}
    return duplicates

def resolve_remaining_duplicates(duplicates):
    """Resolver los 8 duplicados específicos restantes"""
    fixes = []
    
    for slug, resources in duplicates.items():
        print(f"\n🔧 Resolviendo duplicado para slug '{slug}':")
        for i, resource in enumerate(resources):
            print(f"   {i+1}. {resource['name']} (actual: '{resource['slug']}')")
        
        # Resolver duplicados específicos
        if slug == 'bot':
            # bot: azurerm_bot_web_app vs azurerm_bot_service
            for resource in resources:
                if resource['name'] == 'azurerm_bot_service':
                    new_slug = 'bots'  # Bot Service específico
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Bot service específico - bots'
                    })
                # Mantener 'bot' para azurerm_bot_web_app
        
        elif slug == 'oai':
            # oai: azurerm_cognitive_deployment vs azurerm_cognitive_account_openai
            for resource in resources:
                if resource['name'] == 'azurerm_cognitive_deployment':
                    new_slug = 'cog'  # Cognitive deployment
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Cognitive deployment - cog'
                    })
                # Mantener 'oai' para azurerm_cognitive_account_openai (oficial CAF)
        
        elif slug == 'migr':
            # migr: azurerm_database_migration_project vs azurerm_migrate_project
            for resource in resources:
                if resource['name'] == 'azurerm_database_migration_project':
                    new_slug = 'dbmigr'  # Database migration project
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Database migration project - dbmigr'
                    })
                # Mantener 'migr' para azurerm_migrate_project (oficial CAF)
        
        elif slug == 'afd':
            # afd: azurerm_frontdoor vs azurerm_frontdoor_profile
            for resource in resources:
                if resource['name'] == 'azurerm_frontdoor':
                    new_slug = 'afdleg'  # Azure Front Door legacy
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Azure Front Door legacy - afdleg'
                    })
                # Mantener 'afd' para azurerm_frontdoor_profile (oficial CAF Standard/Premium)
        
        elif slug == 'it':
            # it: azurerm_image vs azurerm_image_template
            for resource in resources:
                if resource['name'] == 'azurerm_image':
                    new_slug = 'img'  # Image
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'VM Image - img'
                    })
                # Mantener 'it' para azurerm_image_template (oficial CAF)
        
        elif slug == 'dnspr':
            # dnspr: azurerm_private_dns_resolver vs azurerm_dns_private_resolver
            for resource in resources:
                if resource['name'] == 'azurerm_private_dns_resolver':
                    new_slug = 'pdnsres'  # Private DNS resolver diferente
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Private DNS resolver (legacy) - pdnsres'
                    })
                # Mantener 'dnspr' para azurerm_dns_private_resolver (oficial CAF)
        
        elif slug == 'aif':
            # aif: azurerm_ai_foundry vs azurerm_cognitive_account_ai_foundry
            for resource in resources:
                if resource['name'] == 'azurerm_ai_foundry':
                    new_slug = 'aifleg'  # AI Foundry legacy
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'AI Foundry legacy - aifleg'
                    })
                # Mantener 'aif' para azurerm_cognitive_account_ai_foundry (oficial CAF)
        
        elif slug == 'aifp':
            # aifp: azurerm_ai_foundry_project vs azurerm_cognitive_account_ai_foundry_project
            for resource in resources:
                if resource['name'] == 'azurerm_ai_foundry_project':
                    new_slug = 'aifpleg'  # AI Foundry Project legacy
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'AI Foundry Project legacy - aifpleg'
                    })
                # Mantener 'aifp' para azurerm_cognitive_account_ai_foundry_project (oficial CAF)
    
    return fixes

def apply_fixes(resources, fixes):
    """Aplicar las correcciones a los recursos"""
    for fix in fixes:
        resource = fix['resource']
        resource['slug'] = fix['new_slug']
        print(f"✅ {resource['name']}: '{fix['old_slug']}' → '{fix['new_slug']}' ({fix['reason']})")
    
    return resources

def save_resource_definitions(resources):
    """Guardar definiciones de recursos actualizadas"""
    try:
        with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
            json.dump(resources, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"❌ Error guardando archivo: {e}")
        return False

def main():
    print("🔧 RESOLUCIÓN FINAL DE DUPLICADOS CAF:")
    print("=" * 80)
    
    # Cargar recursos
    resources = load_resource_definitions()
    if not resources:
        print("❌ No se pudieron cargar los recursos")
        sys.exit(1)
    
    print(f"📦 Recursos cargados: {len(resources)}")
    
    # Encontrar duplicados
    duplicates = find_duplicates(resources)
    if not duplicates:
        print("✅ No se encontraron duplicados")
        return
    
    print(f"⚠️  Duplicados encontrados: {len(duplicates)}")
    
    # Resolver duplicados
    fixes = resolve_remaining_duplicates(duplicates)
    print(f"\n🔧 Aplicando {len(fixes)} correcciones:")
    
    # Aplicar correcciones
    updated_resources = apply_fixes(resources, fixes)
    
    # Guardar cambios
    if save_resource_definitions(updated_resources):
        print(f"\n✅ Archivo actualizado correctamente")
        
        # Verificar resultado final
        final_duplicates = find_duplicates(updated_resources)
        if final_duplicates:
            print(f"⚠️  Aún quedan {len(final_duplicates)} duplicados por resolver")
            for slug, dupes in final_duplicates.items():
                print(f"   • {slug}: {[r['name'] for r in dupes]}")
        else:
            print("🎉 ¡Todos los duplicados han sido resueltos completamente!")
            
        print(f"\n📊 ESTADO FINAL:")
        print(f"   • Total recursos: {len(updated_resources)}")
        unique_slugs = set(r['slug'] for r in updated_resources if r.get('slug'))
        print(f"   • Slugs únicos: {len(unique_slugs)}")
        print(f"   • Duplicados restantes: {len(final_duplicates)}")
        
        if len(final_duplicates) == 0:
            print(f"\n🏆 ¡ÉXITO COMPLETO!")
            print(f"   • 100% de eliminación de duplicados alcanzada")
            print(f"   • Todos los recursos CAF oficiales añadidos")
            print(f"   • Sistema completamente optimizado")
    else:
        print("❌ Error guardando los cambios")
        sys.exit(1)

if __name__ == "__main__":
    main()
