# Localization Validation

This directory contains the localization files for the HowAI app and validation tools to ensure translation quality across all supported languages.

## 📁 File Structure

- `app_en.arb` - English reference file (master)
- `app_zh.arb` - Chinese Simplified
- `app_zh_TW.arb` - Chinese Traditional  
- `app_*.arb` - Other language files
- `check_translations.py` - Validation script
- `missing_keys_*.json` - Generated templates for missing translations

## 🛠️ Validation Script

### Basic Usage

Run complete validation for all languages:
```bash
python3 check_translations.py
```

### Template Generation

Generate a template file with missing keys for a specific language:
```bash
python3 check_translations.py template <language_code>
```

Examples:
```bash
python3 check_translations.py template de    # German
python3 check_translations.py template es    # Spanish
python3 check_translations.py template fr    # French
```

## 📊 Current Status

Based on the latest validation run:

### ✅ Complete (100%)
- Chinese Simplified (zh)
- Chinese Traditional (zh_TW)

### ❌ Needs Attention
- Portuguese (pt) - Only 22% complete
- All other languages - Missing ~240+ keys from recent updates

## 🔧 How to Fix Missing Translations

1. **Generate a template:**
   ```bash
   python3 check_translations.py template <lang_code>
   ```

2. **Review the generated `missing_keys_<lang>.json` file**

3. **Add missing keys to the appropriate `app_<lang>.arb` file**

4. **Validate your changes:**
   ```bash
   python3 check_translations.py
   ```

## 📝 Translation Guidelines

### What NOT to Translate
- App name: "HowAI"
- Brand names: "Uber", "Lyft", "Google Maps", "Apple Maps" 
- Language names in their native scripts: "English", "中文", "Français", etc.
- Email addresses and URLs
- Technical identifiers

### Best Practices
- Maintain consistent terminology across the app
- Keep placeholder formats intact: `{count}`, `{error}`, etc.
- Preserve emoji and special characters
- Consider cultural context and local conventions
- Test text length in UI to avoid overflow

## 🚨 Critical Issues Found

The validation script revealed several critical issues:

1. **Massive Missing Content**: Most languages are missing 240+ keys
2. **Untranslated Content**: Several languages have English text that should be translated
3. **Incomplete Files**: Portuguese (pt) file is severely incomplete

## 🎯 Priority Actions

1. **Immediate**: Fix Portuguese (pt) - only 22% complete
2. **High**: Complete missing premium/subscription features for all languages
3. **Medium**: Fix untranslated simple words like "OK", "Chat", "Stop"
4. **Low**: Add missing advanced features (maps, premium features)

## 🔄 Continuous Integration

Consider adding this validation script to your CI/CD pipeline:

```yaml
# Example GitHub Action step
- name: Validate Translations
  run: |
    cd lib/l10n
    python3 check_translations.py
    # Fail if any language has < 95% completion
```

## 📈 Metrics Tracking

The script provides these key metrics:
- **Completion Percentage**: Keys present vs total keys
- **Missing Keys**: Essential translations not yet added
- **Untranslated Content**: Text that should be translated but isn't
- **Extra Keys**: Keys that exist in translation but not in English (rare)

## 🤝 Contributing

When adding new features:
1. Add English strings to `app_en.arb`
2. Run validation script to see impact
3. Generate templates for priority languages
4. Coordinate with translation team for updates

---

💡 **Tip**: Run the validation script regularly during development to catch translation gaps early! 