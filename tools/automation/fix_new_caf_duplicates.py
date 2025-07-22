#!/usr/bin/env python3
"""
Script para resolver duplicados generados después de añadir recursos CAF oficiales
"""

import json
import sys
from collections import defaultdict

def load_resource_definitions():
    """Cargar definiciones de recursos desde resourceDefinition.json"""
    try:
        with open('resourceDefinition.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        # El JSON es un array directo
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

def resolve_duplicates(duplicates):
    """Resolver duplicados con patrones inteligentes"""
    fixes = []
    
    for slug, resources in duplicates.items():
        print(f"\n🔧 Resolviendo duplicado para slug '{slug}':")
        for i, resource in enumerate(resources):
            print(f"   {i+1}. {resource['name']} (actual: '{resource['slug']}')")
        
        # Aplicar estrategias de resolución específicas
        if slug == 'proj':
            # Para 'proj' - distinguir entre AI Foundry y ML Workspace
            for resource in resources:
                if 'ai_foundry' in resource['name']:
                    new_slug = 'aifp'  # AI Foundry Project
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'AI Foundry project - aifp'
                    })
                elif 'workspace_project' in resource['name']:
                    new_slug = 'mlwp'  # ML Workspace Project
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'ML Workspace project - mlwp'
                    })
        
        elif slug == 'hub':
            # Para 'hub' - distinguir entre diferentes tipos de hub
            for resource in resources:
                if 'workspace_hub' in resource['name']:
                    new_slug = 'mlwh'  # ML Workspace Hub
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'ML Workspace hub - mlwh'
                    })
                elif 'notification' in resource['name']:
                    new_slug = 'ntfhub'  # Notification Hub
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Notification hub - ntfhub'
                    })
        
        elif slug == 'asa':
            # Para 'asa' - distinguir entre Stream Analytics
            for resource in resources:
                if 'cluster' in resource['name']:
                    new_slug = 'asacl'  # Stream Analytics Cluster
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Stream Analytics cluster - asacl'
                    })
                # Mantener 'asa' para el stream analytics job principal
        
        elif slug == 'lt':
            # Para 'lt' - distinguir entre Logic App y Load Test
            for resource in resources:
                if 'load_test' in resource['name']:
                    new_slug = 'ltest'  # Load Test
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Load test - ltest'
                    })
                # Mantener 'lt' para Logic App
        
        elif slug == 'arck':
            # Para 'arck' - distinguir entre Arc Kubernetes recursos
            for resource in resources:
                if 'cluster_extension' in resource['name']:
                    new_slug = 'arckext'  # Arc Kubernetes Extension
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Arc Kubernetes extension - arckext'
                    })
                # Mantener 'arck' para el cluster principal
        
        elif slug == 'pls':
            # Para 'pls' - distinguir entre Private Link Scope tipos
            for resource in resources:
                if 'arc_private_link_scope' in resource['name']:
                    new_slug = 'arcpls'  # Arc Private Link Scope
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Arc private link scope - arcpls'
                    })
                # Mantener 'pls' para el private link scope general
        
        elif slug == 'np':
            # Para 'np' - distinguir entre diferentes tipos de node pools
            for resource in resources:
                if 'system' in resource['name']:
                    new_slug = 'npsys'  # System Node Pool
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'System node pool - npsys'
                    })
                # Mantener 'np' para node pool general
        
        elif slug == 'cospos':
            # Para 'cospos' - Cosmos PostgreSQL
            for resource in resources:
                if 'cluster' in resource['name']:
                    new_slug = 'cosposcl'  # Cosmos PostgreSQL Cluster
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Cosmos PostgreSQL cluster - cosposcl'
                    })
        
        elif slug == 'mysql':
            # Para 'mysql' - distinguir entre tipos
            for resource in resources:
                if 'flexible_server' in resource['name']:
                    new_slug = 'mysqlfs'  # MySQL Flexible Server
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'MySQL flexible server - mysqlfs'
                    })
                # Mantener 'mysql' para el server general
        
        elif slug == 'psql':
            # Para 'psql' - distinguir entre tipos
            for resource in resources:
                if 'flexible_server' in resource['name']:
                    new_slug = 'psqlfs'  # PostgreSQL Flexible Server
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'PostgreSQL flexible server - psqlfs'
                    })
                # Mantener 'psql' para el server general
        
        elif slug == 'wps':
            # Para 'wps' - Web PubSub
            # Si hay duplicados, añadir sufijo específico
            for i, resource in enumerate(resources[1:], 1):
                new_slug = f'wps{i}'
                fixes.append({
                    'resource': resource,
                    'old_slug': resource['slug'],
                    'new_slug': new_slug,
                    'reason': f'Web PubSub variant - {new_slug}'
                })
        
        elif slug == 'dns':
            # Para 'dns' - distinguir entre tipos de DNS
            for resource in resources:
                if 'private' in resource['name']:
                    new_slug = 'pdns'  # Private DNS
                    fixes.append({
                        'resource': resource,
                        'old_slug': resource['slug'],
                        'new_slug': new_slug,
                        'reason': 'Private DNS zone - pdns'
                    })
                # Mantener 'dns' para DNS zone general
    
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
        # Guardar como array directo
        with open('resourceDefinition.json', 'w', encoding='utf-8') as f:
            json.dump(resources, f, indent=2, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"❌ Error guardando archivo: {e}")
        return False

def main():
    print("🔧 RESOLUCIÓN DE DUPLICADOS POST-CAF:")
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
    fixes = resolve_duplicates(duplicates)
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
            print("🎉 ¡Todos los duplicados han sido resueltos!")
            
        print(f"\n📊 ESTADO FINAL:")
        print(f"   • Total recursos: {len(updated_resources)}")
        print(f"   • Slugs únicos: {len(set(r['slug'] for r in updated_resources if r.get('slug')))}")
        print(f"   • Duplicados restantes: {len(final_duplicates)}")
    else:
        print("❌ Error guardando los cambios")
        sys.exit(1)

if __name__ == "__main__":
    main()
