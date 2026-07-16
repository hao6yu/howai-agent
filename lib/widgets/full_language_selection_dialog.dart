import 'package:flutter/material.dart';
import '../utils/language_utils.dart';
import 'language_selection_popup.dart';
import '../core/theme/howai_theme.dart';

class FullLanguageSelectionDialog extends StatefulWidget {
  final String sourceText;
  final String detectedLanguage;
  final Function(String targetLanguageCode, String targetLanguageName)
      onLanguageSelected;

  const FullLanguageSelectionDialog({
    Key? key,
    required this.sourceText,
    required this.detectedLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  State<FullLanguageSelectionDialog> createState() =>
      _FullLanguageSelectionDialogState();
}

class _FullLanguageSelectionDialogState
    extends State<FullLanguageSelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<LanguageOption> get _filteredLanguages {
    final allLanguages = LanguageUtils.getAllLanguages();
    if (_searchQuery.isEmpty) {
      return allLanguages;
    }

    return allLanguages.where((lang) {
      final query = _searchQuery.toLowerCase();
      return lang.name.toLowerCase().contains(query) ||
          lang.nativeName.toLowerCase().contains(query) ||
          lang.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Select Language',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: context.howaiColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded,
                            color: context.howaiColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detected: ${widget.detectedLanguage}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.howaiColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search languages...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: context.howaiColors.textSecondary),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Language list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _filteredLanguages.length,
                itemBuilder: (context, index) {
                  final language = _filteredLanguages[index];
                  return _buildLanguageListItem(language);
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageListItem(LanguageOption language) {
    final colors = context.howaiColors;
    return InkWell(
      onTap: () async {
        Navigator.of(context).pop();
        widget.onLanguageSelected(language.code, language.name);
        // Add a small delay to allow the callback to complete
        await Future.delayed(Duration(milliseconds: 100));
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (language.nativeName != language.name) ...[
                    const SizedBox(height: 2),
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              language.code.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
