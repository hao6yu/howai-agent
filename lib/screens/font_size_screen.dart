import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/custom_back_button.dart';
import 'package:haogpt/generated/app_localizations.dart';

class FontSizeScreen extends StatefulWidget {
  const FontSizeScreen({Key? key}) : super(key: key);

  @override
  State<FontSizeScreen> createState() => _FontSizeScreenState();
}

class _FontSizeScreenState extends State<FontSizeScreen> {
  late double _currentScale;
  late double _initialScale;

  @override
  void initState() {
    super.initState();
    _currentScale = Provider.of<SettingsProvider>(context, listen: false).fontSizeScale;
    _initialScale = _currentScale;
  }

  void _updateFontSize(double scale) {
    setState(() {
      _currentScale = scale;
    });
    // Update in real-time for preview
    Provider.of<SettingsProvider>(context, listen: false).setFontSizeScale(scale);
  }

  void _resetToDefault() {
    _updateFontSize(SettingsProvider.defaultFontScale);
  }

  void _onCancel() {
    // Restore original font size
    Provider.of<SettingsProvider>(context, listen: false).setFontSizeScale(_initialScale);
    Navigator.of(context).pop();
  }

  void _onDone() {
    // Keep current font size and close
    Navigator.of(context).pop();
  }

  String _getFontSizeLabel() {
    if (_currentScale <= 0.85) return AppLocalizations.of(context)!.small;
    if (_currentScale <= 0.95) return AppLocalizations.of(context)!.smallPlus;
    if (_currentScale <= 1.05) return AppLocalizations.of(context)!.defaultSize;
    if (_currentScale <= 1.15) return AppLocalizations.of(context)!.large;
    if (_currentScale <= 1.35) return AppLocalizations.of(context)!.largePlus;
    return AppLocalizations.of(context)!.extraLarge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.textSize,
        onBack: _onCancel,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.done,
                style: TextStyle(
                  fontSize: Provider.of<SettingsProvider>(context).getScaledFontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return Column(
            children: [
              // Preview Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF0078D4),
                              const Color(0xFF106ebe),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: settings.getScaledFontSize(24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.previewTextSize,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: settings.getScaledFontSize(18),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sample conversation
                      _buildMessageBubble(
                        isUser: true,
                        message: AppLocalizations.of(context)!.adjustSliderTextSize,
                        settings: settings,
                      ),

                      const SizedBox(height: 16),

                      _buildMessageBubble(
                        isUser: false,
                        message: AppLocalizations.of(context)!.textSizeChangeNote,
                        settings: settings,
                      ),

                      const SizedBox(height: 20),

                      // Current size indicator
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0078D4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF0078D4).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${_getFontSizeLabel()} (${(_currentScale * 100).round()}%)',
                            style: TextStyle(
                              color: const Color(0xFF0078D4),
                              fontSize: settings.getScaledFontSize(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Reset button
                      if (!settings.isDefaultFontSize)
                        Center(
                          child: TextButton.icon(
                            onPressed: _resetToDefault,
                            icon: Icon(
                              Icons.refresh,
                              color: const Color(0xFF0078D4),
                              size: settings.getScaledFontSize(18),
                            ),
                            label: Text(
                              AppLocalizations.of(context)!.resetToDefaultButton,
                              style: TextStyle(
                                color: const Color(0xFF0078D4),
                                fontSize: settings.getScaledFontSize(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Font size control area
              Container(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  children: [
                    // Size indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.defaultSize,
                          style: TextStyle(
                            fontSize: settings.getScaledFontSize(14),
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF0078D4),
                        inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                        thumbColor: const Color(0xFF0078D4),
                        overlayColor: const Color(0xFF0078D4).withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _currentScale,
                        min: SettingsProvider.minFontScale,
                        max: SettingsProvider.maxFontScale,
                        divisions: 20, // 20 steps between min and max
                        onChanged: _updateFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required bool isUser,
    required String message,
    required SettingsProvider settings,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0078D4) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
            fontSize: settings.getScaledFontSize(16),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
