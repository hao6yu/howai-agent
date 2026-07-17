import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:haogpt/screens/font_size_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('maximum text size remains scrollable without overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      const {'font_size_scale': SettingsProvider.maxFontScale},
    );
    final settings = SettingsProvider();
    await tester.pump();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: MaterialApp(
          theme: HowAITheme.light(fontScale: SettingsProvider.maxFontScale),
          darkTheme: HowAITheme.dark(fontScale: SettingsProvider.maxFontScale),
          themeMode: ThemeMode.dark,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FontSizeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preview text size'), findsOneWidget);
    expect(find.textContaining('HowAI'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
