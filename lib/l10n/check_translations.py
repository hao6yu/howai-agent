#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import sys
import os
import glob
from collections import defaultdict

def load_arb_file(filename):
    """Load an ARB file and return the keys"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            data = json.load(f)
        # Filter out metadata keys that start with @
        return {k: v for k, v in data.items() if not k.startswith('@')}
    except Exception as e:
        print(f"Error loading {filename}: {e}")
        return {}

def get_language_name(filename):
    """Extract language name from filename"""
    base = os.path.basename(filename)
    if base == 'app_en.arb':
        return 'English (Reference)'
    elif base == 'app_zh.arb':
        return 'Chinese Simplified (zh)'
    elif base == 'app_zh_TW.arb':
        return 'Chinese Traditional (zh_TW)'
    elif base == 'app_ar.arb':
        return 'Arabic (ar)'
    elif base == 'app_de.arb':
        return 'German (de)'
    elif base == 'app_es.arb':
        return 'Spanish (es)'
    elif base == 'app_fr.arb':
        return 'French (fr)'
    elif base == 'app_hi.arb':
        return 'Hindi (hi)'
    elif base == 'app_ja.arb':
        return 'Japanese (ja)'
    elif base == 'app_ko.arb':
        return 'Korean (ko)'
    elif base == 'app_pt.arb':
        return 'Portuguese (pt)'
    elif base == 'app_ru.arb':
        return 'Russian (ru)'
    elif base == 'app_tr.arb':
        return 'Turkish (tr)'
    elif base == 'app_vi.arb':
        return 'Vietnamese (vi)'
    elif base == 'app_id.arb':
        return 'Indonesian (id)'
    elif base == 'app_it.arb':
        return 'Italian (it)'
    elif base == 'app_pl.arb':
        return 'Polish (pl)'
    elif base == 'app_pt_BR.arb':
        return 'Portuguese Brazil (pt_BR)'
    else:
        return base.replace('app_', '').replace('.arb', '')

def should_not_translate(key, value):
    """Check if a key/value should not be translated (proper nouns, brand names, etc.)"""
    # App title and brand names
    if key in ['appTitle']:
        return True
    
    # Language names in their native script
    if key in ['english', 'chinese', 'japanese', 'spanish', 'french', 'hindi', 
              'arabic', 'taiwanese', 'russian', 'portuguese', 'korean', 'german',
              'indonesian', 'turkish', 'italian', 'vietnamese', 'polish']:
        return True
    
    # Email addresses and URLs
    if '@' in value or 'http' in value:
        return True
    
    # Brand names
    if value in ['Uber', 'Lyft', 'Google Maps', 'Apple Maps']:
        return True
        
    # App name in titles
    if key == 'appBarTitleHao':
        return True
    
    return False

def validate_all_translations():
    """Validate all translation files against English reference"""
    
    # Find all ARB files
    arb_files = glob.glob('app_*.arb')
    arb_files.sort()
    
    if 'app_en.arb' not in arb_files:
        print("❌ Error: English reference file (app_en.arb) not found!")
        return
    
    # Load English reference
    en_data = load_arb_file('app_en.arb')
    en_keys = set(en_data.keys())
    
    print("=" * 80)
    print("🌍 LOCALIZATION VALIDATION REPORT")
    print("=" * 80)
    print(f"📚 Reference: English with {len(en_keys)} keys")
    print()
    
    # Results summary
    results = {}
    
    # Check each language file
    for arb_file in arb_files:
        if arb_file == 'app_en.arb':
            continue
            
        lang_name = get_language_name(arb_file)
        lang_data = load_arb_file(arb_file)
        lang_keys = set(lang_data.keys())
        
        # Calculate missing and extra keys
        missing_keys = en_keys - lang_keys
        extra_keys = lang_keys - en_keys
        
        # Check for untranslated content
        common_keys = en_keys & lang_keys
        untranslated = []
        for key in common_keys:
            if (en_data[key] == lang_data[key] and 
                not should_not_translate(key, en_data[key])):
                untranslated.append(key)
        
        # Calculate completion percentage
        completion = ((len(lang_keys) - len(missing_keys)) / len(en_keys)) * 100
        
        results[arb_file] = {
            'name': lang_name,
            'total_keys': len(lang_keys),
            'missing': missing_keys,
            'extra': extra_keys,
            'untranslated': untranslated,
            'completion': completion
        }
    
    # Print summary table
    print("📊 COMPLETION SUMMARY")
    print("-" * 80)
    print(f"{'Language':<30} {'Keys':<8} {'Missing':<8} {'Untrans':<8} {'Complete':<10}")
    print("-" * 80)
    
    for arb_file in sorted(results.keys()):
        result = results[arb_file]
        name = result['name'][:29]  # Truncate if too long
        keys = result['total_keys']
        missing = len(result['missing'])
        untrans = len(result['untranslated'])
        completion = result['completion']
        
        # Color coding for completion status
        if completion >= 95:
            status = "✅"
        elif completion >= 80:
            status = "⚠️ "
        else:
            status = "❌"
            
        print(f"{name:<30} {keys:<8} {missing:<8} {untrans:<8} {status} {completion:.1f}%")
    
    print("-" * 80)
    print()
    
    # Detailed reports for problematic languages
    problematic_languages = [(f, r) for f, r in results.items() 
                           if r['completion'] < 95 or len(r['untranslated']) > 5]
    
    if problematic_languages:
        print("🚨 DETAILED ISSUES")
        print("=" * 80)
        
        for arb_file, result in problematic_languages:
            print(f"\n📝 {result['name']} ({arb_file})")
            print(f"   Completion: {result['completion']:.1f}%")
            
            if result['missing']:
                print(f"   ❌ Missing keys ({len(result['missing'])}):")
                for key in sorted(list(result['missing'])[:10]):  # Show first 10
                    print(f"      - {key}")
                if len(result['missing']) > 10:
                    print(f"      ... and {len(result['missing']) - 10} more")
            
            if result['extra']:
                print(f"   ➕ Extra keys ({len(result['extra'])}):")
                for key in sorted(result['extra']):
                    print(f"      - {key}")
            
            if result['untranslated']:
                print(f"   🔤 Untranslated content ({len(result['untranslated'])}):")
                for key in sorted(list(result['untranslated'])[:5]):  # Show first 5
                    print(f"      - {key}: \"{en_data[key][:50]}{'...' if len(en_data[key]) > 50 else ''}\"")
                if len(result['untranslated']) > 5:
                    print(f"      ... and {len(result['untranslated']) - 5} more")
    
    else:
        print("🎉 All languages are in good shape!")
    
    print("\n" + "=" * 80)
    print("📋 VALIDATION COMPLETE")
    print("=" * 80)

def generate_missing_keys_template(target_language):
    """Generate a template file with missing keys for a specific language"""
    en_data = load_arb_file('app_en.arb')
    target_file = f'app_{target_language}.arb'
    
    if not os.path.exists(target_file):
        print(f"❌ Target file {target_file} not found!")
        return
    
    target_data = load_arb_file(target_file)
    en_keys = set(en_data.keys())
    target_keys = set(target_data.keys())
    missing_keys = en_keys - target_keys
    
    if not missing_keys:
        print(f"✅ {target_file} has no missing keys!")
        return
    
    template_file = f'missing_keys_{target_language}.json'
    missing_data = {key: en_data[key] for key in sorted(missing_keys)}
    
    with open(template_file, 'w', encoding='utf-8') as f:
        json.dump(missing_data, f, ensure_ascii=False, indent=2)
    
    print(f"📄 Created template file: {template_file}")
    print(f"   Contains {len(missing_keys)} missing keys for translation")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == 'template':
        if len(sys.argv) > 2:
            generate_missing_keys_template(sys.argv[2])
        else:
            print("Usage: python3 check_translations.py template <language_code>")
            print("Example: python3 check_translations.py template zh")
    else:
        validate_all_translations() 