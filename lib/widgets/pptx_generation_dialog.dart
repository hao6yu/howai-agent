import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class PptxGenerationDialog extends StatefulWidget {
  final Function(Map<String, String>) onPptxRequest;

  const PptxGenerationDialog({
    super.key,
    required this.onPptxRequest,
  });

  @override
  State<PptxGenerationDialog> createState() => _PptxGenerationDialogState();
}

class _PptxGenerationDialogState extends State<PptxGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _keyPointsController = TextEditingController();

  String _selectedSlides = '1-3';

  final List<String> _slideOptions = ['1-3', '3-5', '5-8'];

  void _dismissKeyboardAndPop() {
    // Dismiss any focused text fields before closing
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _keyPointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenHeight < 700 || screenWidth < 400;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside content area
              FocusScope.of(context).unfocus();
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.85,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title bar
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9500).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.slideshow,
                              color: Color(0xFFFF9500),
                              size: settings.getScaledFontSize(isSmallScreen ? 18 : 20),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Presentation Maker',
                              style: TextStyle(
                                fontSize: settings.getScaledFontSize(isSmallScreen ? 16 : 18),
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleMedium?.color,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _dismissKeyboardAndPop,
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey,
                            ),
                            iconSize: settings.getScaledFontSize(20),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Prevent tap from bubbling up to parent GestureDetector
                        },
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Just provide the basic topic and ideas - AI will research, structure, and create a detailed presentation outline for you!',
                                  style: TextStyle(
                                    fontSize: settings.getScaledFontSize(14),
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 20),

                                // Topic (Required)
                                _buildTextField(
                                  controller: _topicController,
                                  label: 'Presentation Topic *',
                                  hint: 'e.g., Digital Marketing Strategies for 2024',
                                  isRequired: true,
                                  settings: settings,
                                ),
                                SizedBox(height: 16),

                                // Number of slides
                                _buildDropdownField(
                                  label: 'Number of Slides',
                                  value: _selectedSlides,
                                  options: _slideOptions,
                                  onChanged: (value) => setState(() => _selectedSlides = value!),
                                  settings: settings,
                                ),
                                SizedBox(height: 16),

                                // Key Points
                                _buildTextField(
                                  controller: _keyPointsController,
                                  label: 'Key Points to Cover',
                                  hint: 'Just mention key topics or ideas - AI will research and expand the details for you!',
                                  maxLines: 4,
                                  settings: settings,
                                ),
                                SizedBox(height: 24),

                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: _dismissKeyboardAndPop,
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(16),
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFFF9500),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: _handleGenerate,
                                        child: Text(
                                          'Generate',
                                          style: TextStyle(
                                            fontSize: settings.getScaledFontSize(16),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required SettingsProvider settings,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: settings.getScaledFontSize(14),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFFF9500)),
            ),
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: TextStyle(
            fontSize: settings.getScaledFontSize(14),
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required SettingsProvider settings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: settings.getScaledFontSize(14),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: TextStyle(
              fontSize: settings.getScaledFontSize(14),
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              size: settings.getScaledFontSize(20),
            ),
            elevation: 8,
            dropdownColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableDropdownField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required List<String> options,
    required SettingsProvider settings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: settings.getScaledFontSize(14),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
            ),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: settings.getScaledFontSize(14),
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: TextStyle(
                    fontSize: settings.getScaledFontSize(14),
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  controller.text = value;
                },
                itemBuilder: (BuildContext context) {
                  return options.map((String option) {
                    return PopupMenuItem<String>(
                      value: option,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(14),
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    );
                  }).toList();
                },
                padding: EdgeInsets.zero,
                offset: Offset(0, 4),
                elevation: 8,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    size: settings.getScaledFontSize(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleGenerate() {
    if (_formKey.currentState!.validate()) {
      final details = {
        'topic': _topicController.text.trim(),
        'slides': _selectedSlides,
        'keyPoints': _keyPointsController.text.trim(),
      };

      // Only dismiss keyboard, let the callback handle dialog closure
      FocusScope.of(context).unfocus();
      widget.onPptxRequest(details);
      // Don't call _dismissKeyboardAndPop() here as the callback will handle closing
    }
  }
}
