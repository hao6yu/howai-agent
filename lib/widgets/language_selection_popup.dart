import 'package:flutter/material.dart';

class LanguageSelectionPopup extends StatelessWidget {
  final String sourceText;
  final String detectedLanguage;
  final List<LanguageOption> suggestedLanguages;
  final Function(String targetLanguageCode, String targetLanguageName) onLanguageSelected;
  final VoidCallback onMoreLanguages;

  const LanguageSelectionPopup({
    Key? key,
    required this.sourceText,
    required this.detectedLanguage,
    required this.suggestedLanguages,
    required this.onLanguageSelected,
    required this.onMoreLanguages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Translate to:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detected: $detectedLanguage',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Language options
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ...suggestedLanguages.map((lang) => _buildLanguageOption(
                        context,
                        lang,
                        isRecommended: lang == suggestedLanguages.first,
                      )),

                  const SizedBox(height: 8),

                  // More languages option
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onMoreLanguages();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 20,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'More languages...',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageOption language, {bool isRecommended = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop();
          onLanguageSelected(language.code, language.name);
          // Add a small delay to allow the callback to complete
          await Future.delayed(Duration(milliseconds: 100));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isRecommended ? (Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50) : Colors.transparent,
            border: Border.all(
              color: isRecommended ? (Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade600 : Colors.blue.shade200) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
              width: isRecommended ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isRecommended ? FontWeight.w600 : FontWeight.w500,
                        color: isRecommended ? (Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade700) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade800),
                      ),
                    ),
                    if (language.nativeName != language.name) ...[
                      const SizedBox(height: 2),
                      Text(
                        language.nativeName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isRecommended) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade800 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Smart',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade200 : Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}
