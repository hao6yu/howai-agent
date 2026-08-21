import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/widgets/chat_empty_state.dart';

void main() {
  Future<void> pumpEmptyState(
    WidgetTester tester, {
    required ValueChanged<String> onPromptSelected,
    required VoidCallback onAnalyzePhoto,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        theme: HowAITheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChatEmptyState(
            onPromptSelected: onPromptSelected,
            onAnalyzePhoto: onAnalyzePhoto,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows useful starter actions instead of an empty sentence', (
    tester,
  ) async {
    String? selectedPrompt;
    var photoSelected = false;
    await pumpEmptyState(
      tester,
      onPromptSelected: (prompt) => selectedPrompt = prompt,
      onAnalyzePhoto: () => photoSelected = true,
    );

    expect(find.text('What can I help you with?'), findsOneWidget);
    expect(find.text('Concept Explanation'), findsOneWidget);
    expect(find.text('Professional Writing'), findsOneWidget);
    expect(find.text('Idea Generation'), findsOneWidget);
    expect(find.text('Photo Analysis'), findsOneWidget);
    expect(find.textContaining('No conversations yet'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('chat_starter_explain')),
    );
    expect(selectedPrompt, 'Explain this concept ');

    await tester.tap(find.byKey(const ValueKey<String>('chat_starter_photo')));
    expect(photoSelected, isTrue);
  });

  testWidgets('remains scrollable on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpEmptyState(
      tester,
      onPromptSelected: (_) {},
      onAnalyzePhoto: () {},
      textScaler: const TextScaler.linear(1.8),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
