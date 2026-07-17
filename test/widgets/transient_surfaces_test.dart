import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/widgets/full_language_selection_dialog.dart';
import 'package:haogpt/widgets/upgrade_dialog.dart';

Widget _themed(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: HowAITheme.light(),
    darkTheme: HowAITheme.dark(),
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('upgrade prompt stays compact and semantic in dark mode',
      (tester) async {
    await tester.pumpWidget(
      _themed(
        UpgradeDialog(
          featureName: 'Image Analysis',
          limitMessage: 'The free preview is complete.',
          premiumBenefits: const ['Unlimited analysis', 'Thinking controls'],
          onUpgradePressed: () {},
        ),
        brightness: Brightness.dark,
      ),
    );

    expect(find.text('Image Analysis limit reached'), findsOneWidget);
    expect(find.text('Included with Pro'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('language picker uses a searchable list in dark mode',
      (tester) async {
    await tester.pumpWidget(
      _themed(
        FullLanguageSelectionDialog(
          sourceText: 'hello',
          detectedLanguage: 'English',
          onLanguageSelected: (_, __) {},
        ),
        brightness: Brightness.dark,
      ),
    );

    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('Detected: English'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
