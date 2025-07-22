#!/usr/bin/env python3
"""
Duplicate slug detection and analysis
"""

import json
import sys
from collections import Counter

def detect_duplicates():
    try:
        with open('resourceDefinition.json', 'r') as f:
            resources = json.load(f)
        
        slugs = [r.get('slug', '') for r in resources if r.get('slug')]
        slug_counts = Counter(slugs)
        duplicates = {slug: count for slug, count in slug_counts.items() if count > 1}
        
        print(f"🔍 DUPLICATE DETECTION REPORT:")
        print("=" * 40)
        print(f"📊 Total resources: {len(resources)}")
        print(f"🏷️  Unique slugs: {len(set(slugs))}")
        print(f"❌ Duplicate slugs: {len(duplicates)}")
        
        if duplicates:
            print(f"\n❌ DUPLICATES FOUND:")
            for slug, count in sorted(duplicates.items(), key=lambda x: x[1], reverse=True):
                print(f"Slug '{slug}' used by {count} resources:")
                affected_resources = [r['name'] for r in resources if r.get('slug') == slug]
                for resource in affected_resources:
                    print(f"  - {resource}")
                print()
        else:
            print("\n✅ NO DUPLICATES FOUND - Perfect optimization!")
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ Detection error: {e}")
        return False

if __name__ == "__main__":
    success = detect_duplicates()
    sys.exit(0 if success else 1)
