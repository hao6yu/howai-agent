import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ready exposes persisted appearance before the app is rendered',
      () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 'dark',
      'font_size_scale': 1.25,
      'selected_locale': 'es',
      'use_speaker_output': true,
    });

    final settings = SettingsProvider();
    await settings.ready;

    expect(settings.themeMode.name, 'dark');
    expect(settings.fontSizeScale, 1.25);
    expect(settings.selectedLocale, 'es');
    expect(settings.useSpeakerOutput, isTrue);
  });

  testWidgets('audio-only changes do not rebuild an appearance selector',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsProvider();
    await settings.ready;
    var appearanceBuilds = 0;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: settings,
        child: MaterialApp(
          home: Selector<
              SettingsProvider,
              ({
                ThemeMode themeMode,
                double fontSizeScale,
                String? selectedLocale
              })>(
            selector: (_, value) => (
              themeMode: value.themeMode,
              fontSizeScale: value.fontSizeScale,
              selectedLocale: value.selectedLocale,
            ),
            builder: (context, value, child) {
              appearanceBuilds += 1;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(appearanceBuilds, 1);

    await settings.setUseSpeakerOutput(true);
    await tester.pump();
    expect(appearanceBuilds, 1);

    await settings.setThemeMode(ThemeMode.dark);
    await tester.pump();
    expect(appearanceBuilds, 2);
  });
}
