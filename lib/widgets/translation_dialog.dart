import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/settings_provider.dart';
import '../services/profile_translation_service.dart';
import 'package:haogpt/generated/app_localizations.dart';

class TranslationDialog extends StatefulWidget {
  final Function(String, {List<XFile>? images}) onTranslate; // Updated to handle multiple images

  const TranslationDialog({
    Key? key,
    required this.onTranslate,
  }) : super(key: key);

  @override
  _TranslationDialogState createState() => _TranslationDialogState();
}

class _TranslationDialogState extends State<TranslationDialog> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedLanguage = '';
  List<XFile> _selectedImages = []; // Changed to support multiple images

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'native': 'English'},
    {'name': 'Chinese (Simplified)', 'native': '简体中文'},
    {'name': 'Chinese (Traditional)', 'native': '繁體中文'},
    {'name': 'Spanish', 'native': 'Español'},
    {'name': 'French', 'native': 'Français'},
    {'name': 'German', 'native': 'Deutsch'},
    {'name': 'Italian', 'native': 'Italiano'},
    {'name': 'Portuguese', 'native': 'Português'},
    {'name': 'Russian', 'native': 'Русский'},
    {'name': 'Japanese', 'native': '日本語'},
    {'name': 'Korean', 'native': '한국어'},
    {'name': 'Arabic', 'native': 'العربية'},
    {'name': 'Hindi', 'native': 'हिन्दी'},
    {'name': 'Dutch', 'native': 'Nederlands'},
    {'name': 'Swedish', 'native': 'Svenska'},
    {'name': 'Norwegian', 'native': 'Norsk'},
    {'name': 'Danish', 'native': 'Dansk'},
    {'name': 'Finnish', 'native': 'Suomi'},
    {'name': 'Polish', 'native': 'Polski'},
    {'name': 'Czech', 'native': 'Čeština'},
    {'name': 'Hungarian', 'native': 'Magyar'},
    {'name': 'Romanian', 'native': 'Română'},
    {'name': 'Bulgarian', 'native': 'Български'},
    {'name': 'Greek', 'native': 'Ελληνικά'},
    {'name': 'Turkish', 'native': 'Türkçe'},
    {'name': 'Hebrew', 'native': 'עברית'},
    {'name': 'Thai', 'native': 'ไทย'},
    {'name': 'Vietnamese', 'native': 'Tiếng Việt'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'name': 'Malay', 'native': 'Bahasa Melayu'},
    {'name': 'Ukrainian', 'native': 'Українська'},
    {'name': 'Bengali', 'native': 'বাংলা'},
    {'name': 'Urdu', 'native': 'اردو'},
    {'name': 'Persian', 'native': 'فارسی'},
    {'name': 'Swahili', 'native': 'Kiswahili'},
  ];

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      setState(() {}); // Update button state
    });

    // Load saved language preference
    _loadSavedLanguage();
  }

  // Load the last selected language from SharedPreferences and user preferences
  Future<void> _loadSavedLanguage() async {
    try {
      // First, try to get user's translation history for smart default
      final userPreferences = ProfileTranslationService.getTranslationHistory(context);

      if (userPreferences.isNotEmpty) {
        // Get the most recent preference (first in list)
        final recentLanguageCode = userPreferences.first;
        final languageName = _getLanguageNameFromCode(recentLanguageCode);

        if (languageName != null) {
          setState(() {
            _selectedLanguage = languageName;
          });
          return; // Use user preference as default
        }
      }

      // Fallback to SharedPreferences if no user preference
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('preferred_translation_language');

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        // Check if the saved language still exists in our language list
        final languageExists = _languages.any((lang) => lang['name'] == savedLanguage);

        if (languageExists) {
          setState(() {
            _selectedLanguage = savedLanguage;
          });
        }
      }
    } catch (e) {
      // Handle any errors gracefully - just continue with empty selection
      // print('Error loading saved language preference: $e');
    }
  }

  // Helper method to convert language code to language name
  String? _getLanguageNameFromCode(String code) {
    // Map language codes to names used in our dialog
    final codeToName = {
      'en': 'English',
      'zh': 'Chinese (Simplified)', // Default to simplified for 'zh'
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'da': 'Danish',
      'no': 'Norwegian',
      'fi': 'Finnish',
      'pl': 'Polish',
      'tr': 'Turkish',
      'th': 'Thai',
      'vi': 'Vietnamese',
    };

    return codeToName[code];
  }

  // Save the selected language to SharedPreferences
  Future<void> _saveLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_translation_language', language);
    } catch (e) {
      // Handle errors gracefully - don't interrupt user experience
      // print('Error saving language preference: $e');
    }
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });

    // Save the user's language preference to SharedPreferences
    _saveLanguagePreference(language);

    // Also save to user's profile translation history
    _saveToUserProfile(language);
  }

  // Save language choice to user's profile translation history
  void _saveToUserProfile(String languageName) {
    try {
      // Convert language name back to code for profile storage
      final languageCode = _getLanguageCodeFromName(languageName);
      if (languageCode != null) {
        ProfileTranslationService.addTranslationChoice(context, languageCode);
      }
    } catch (e) {
      // Handle errors gracefully
      // print('Error saving to user profile: $e');
    }
  }

  // Helper method to convert language name to language code
  String? _getLanguageCodeFromName(String name) {
    final nameToCode = {
      'English': 'en',
      'Chinese (Simplified)': 'zh',
      'Chinese (Traditional)': 'zh', // Both map to 'zh' for simplicity
      'Spanish': 'es',
      'French': 'fr',
      'German': 'de',
      'Italian': 'it',
      'Portuguese': 'pt',
      'Russian': 'ru',
      'Japanese': 'ja',
      'Korean': 'ko',
      'Arabic': 'ar',
      'Hindi': 'hi',
      'Dutch': 'nl',
      'Swedish': 'sv',
      'Danish': 'da',
      'Norwegian': 'no',
      'Finnish': 'fi',
      'Polish': 'pl',
      'Turkish': 'tr',
      'Thai': 'th',
      'Vietnamese': 'vi',
    };

    return nameToCode[name];
  }

  void _dismissKeyboardAndPop() {
    // Dismiss any focused text fields before closing
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // Support multiple image selection from gallery
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images);
          });
        }
      } else {
        // Single image from camera
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          setState(() {
            _selectedImages.add(image);
          });
        }
      }
    } catch (e) {
      // print('Error picking image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'From Gallery: Select multiple images\nFrom Camera: Take one photo',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEmptyContentWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter text or add an image to translate'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF007AFF)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Language list
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final languageData = _languages[index];
                  final languageName = languageData['name']!;
                  final isSelected = languageName == _selectedLanguage;

                  return ListTile(
                    onTap: () {
                      _selectLanguage(languageName);
                      Navigator.pop(context);
                    },
                    title: Text(
                      languageData['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF007AFF) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E)),
                      ),
                    ),
                    subtitle: Text(
                      languageData['native']!,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF007AFF),
                            size: 20,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final mediaQuery = MediaQuery.of(context);
        final screenHeight = mediaQuery.size.height;
        final screenWidth = mediaQuery.size.width;
        final keyboardHeight = mediaQuery.viewInsets.bottom;
        final isKeyboardVisible = keyboardHeight > 0;
        final isSmallScreen = screenHeight < 900 || screenWidth < 400;

        // Calculate available height when keyboard is visible
        final availableHeight = screenHeight - keyboardHeight;
        final maxDialogHeight = isKeyboardVisible
            ? availableHeight * 0.85 // Use more of available space when keyboard is showing
            : screenHeight * 0.7;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : 24,
            vertical: isKeyboardVisible ? 8 : (isSmallScreen ? 40 : 60),
          ),
          child: GestureDetector(
            onTap: () {
              // Close the dialog and hide keyboard
              _dismissKeyboardAndPop();
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 450,
                maxHeight: maxDialogHeight,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF007AFF),
                          const Color(0xFF5856D6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, isKeyboardVisible ? 12 : 16, 20, isKeyboardVisible ? 12 : 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.translate,
                              color: Colors.white,
                              size: isKeyboardVisible ? 18 : 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.featureAiTranslationTitle,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(isKeyboardVisible ? 16 : 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isKeyboardVisible ? 10 : 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text input section
                          Text(
                            'Text to translate',
                            style: TextStyle(
                              fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E),
                            ),
                          ),
                          SizedBox(height: isKeyboardVisible ? 6 : 8),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: isKeyboardVisible ? 60 : 80,
                              maxHeight: isKeyboardVisible
                                  ? 80 // Much more compact when keyboard is visible
                                  : (isSmallScreen ? 100 : 120),
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _textFocusNode.hasFocus ? const Color(0xFF007AFF) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300),
                                width: _textFocusNode.hasFocus ? 2 : 1,
                              ),
                            ),
                            child: TextField(
                              controller: _textController,
                              focusNode: _textFocusNode,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                                height: isKeyboardVisible ? 1.3 : 1.4,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter text to translate...',
                                hintStyle: TextStyle(
                                  fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(isKeyboardVisible ? 10 : 12),
                              ),
                            ),
                          ),

                          SizedBox(height: isKeyboardVisible ? 6 : 10),

                          // Image attachment section
                          Row(
                            children: [
                              Text(
                                'Attachment${_selectedImages.isNotEmpty ? ' (${_selectedImages.length})' : ''}',
                                style: TextStyle(
                                  fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E),
                                ),
                              ),
                              const Spacer(),
                              if (_selectedImages.isNotEmpty) ...[
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.clear();
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.clear_all,
                                            size: 14,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Clear All',
                                            style: TextStyle(
                                              fontSize: settings.getScaledFontSize(11),
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _showImageSourceDialog,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007AFF).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 16,
                                          color: const Color(0xFF007AFF),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedImages.isEmpty ? 'Add Photos' : 'Add More',
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(12),
                                            color: const Color(0xFF007AFF),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isKeyboardVisible ? 6 : 8),

                          // Show selected images in a horizontal row (like chat input)
                          if (_selectedImages.isNotEmpty) ...[
                            Container(
                              height: 64,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (context, index) {
                                  final image = _selectedImages[index];
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: FileImage(File(image.path)),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'No images selected (optional)',
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(12),
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: isKeyboardVisible ? 6 : 8),
                        ],
                      ),
                    ),
                  ),

                  // Language selection (shared between text and image)
                  _buildLanguageSelection(settings, isKeyboardVisible, availableHeight, screenHeight),

                  // Action buttons
                  _buildActionButtons(settings, isKeyboardVisible),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelection(SettingsProvider settings, bool isKeyboardVisible, double availableHeight, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isKeyboardVisible ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translate to',
            style: TextStyle(
              fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          SizedBox(height: isKeyboardVisible ? 6 : 8),

          // Language selector button (opens modal)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLanguageSelectionModal,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(isKeyboardVisible ? 10 : 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedLanguage.isEmpty
                          ? Text(
                              isKeyboardVisible ? 'Choose target language...' : 'Search or tap to change: Chinese (Simpli...',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey[500],
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedLanguage,
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1C1C1E),
                                  ),
                                ),
                                if (!isKeyboardVisible) // Hide native name when keyboard is visible for space
                                  Text(
                                    _languages.firstWhere(
                                      (lang) => lang['name'] == _selectedLanguage,
                                      orElse: () => {'native': ''},
                                    )['native']!,
                                    style: TextStyle(
                                      fontSize: settings.getScaledFontSize(12),
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF007AFF),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: isKeyboardVisible ? 6 : 10),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SettingsProvider settings, bool isKeyboardVisible) {
    final bool hasText = _textController.text.trim().isNotEmpty;
    final bool hasImages = _selectedImages.isNotEmpty;
    final bool hasLanguage = _selectedLanguage.isNotEmpty;
    final bool canTranslate = (hasText || hasImages) && hasLanguage;

    return Container(
      padding: EdgeInsets.all(isKeyboardVisible ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _dismissKeyboardAndPop,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isKeyboardVisible ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(width: isKeyboardVisible ? 8 : 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canTranslate
                  ? () {
                      // Build the translation prompt
                      String translationPrompt;

                      if (hasText && hasImages) {
                        // Both text and images
                        translationPrompt = 'Please translate the following text to $_selectedLanguage, and also identify and translate any text in the attached images to $_selectedLanguage:\n\n${_textController.text.trim()}';
                      } else if (hasText) {
                        // Text only
                        translationPrompt = 'Please translate the following text to $_selectedLanguage:\n\n${_textController.text.trim()}';
                      } else {
                        // Images only
                        translationPrompt = 'Please identify and translate any text you can see in these images to $_selectedLanguage.';
                      }

                      // Call the unified callback with optional images
                      widget.onTranslate(translationPrompt, images: _selectedImages);
                      _dismissKeyboardAndPop();
                    }
                  : () {
                      // Show warning when validation fails
                      if (!hasLanguage) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select a target language'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        _showEmptyContentWarning();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: canTranslate ? const Color(0xFF007AFF) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300]),
                foregroundColor: canTranslate ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]),
                padding: EdgeInsets.symmetric(vertical: isKeyboardVisible ? 10 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: canTranslate ? 2 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.translate, size: isKeyboardVisible ? 16 : 18),
                  SizedBox(width: isKeyboardVisible ? 4 : 6),
                  Text(
                    'Translate',
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(isKeyboardVisible ? 13 : 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
