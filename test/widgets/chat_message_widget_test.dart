import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/models/chat_message.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:haogpt/widgets/chat_message_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpMessage(
    WidgetTester tester, {
    required bool isUserMessage,
    bool includeMemoryActions = false,
  }) async {
    final message = ChatMessage(
      message: isUserMessage ? 'Hello HowAI' : 'Hello! How can I help?',
      isUserMessage: isUserMessage,
      timestamp: DateTime(2026, 7, 15).toIso8601String(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: MaterialApp(
          theme: HowAITheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ChatMessageWidget(
              message: message,
              messageKey: 1,
              selectionMode: false,
              selectedMessages: const <int>{},
              onToggleSelection: (_) {},
              onTranslate: (_) {},
              translationPreferenceVersion: 0,
              onDelete: (_) {},
              translatedMessages: const <int, String>{},
              isPlayingAudio: false,
              onPlayAudio: (_) {},
              onSpeakWithHighlight: (_) {},
              onQuickSaveToKnowledgeHub:
                  includeMemoryActions ? (_) {} : null,
              onSaveToKnowledgeHub: includeMemoryActions ? (_) {} : null,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('assistant actions stay visible without decorative avatars',
      (tester) async {
    await pumpMessage(tester, isUserMessage: false);

    expect(find.byIcon(Icons.copy), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('user message keeps the subtle bubble without an avatar',
      (tester) async {
    await pumpMessage(tester, isUserMessage: true);

    expect(find.text('Hello HowAI'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byIcon(Icons.flag_outlined), findsNothing);
  });

  testWidgets('user message actions use a compact anchored menu',
      (tester) async {
    await pumpMessage(
      tester,
      isUserMessage: true,
      includeMemoryActions: true,
    );

    await tester.longPress(find.text('Hello HowAI'));
    await tester.pumpAndSettle();

    final menu = find.byKey(const ValueKey('user-message-actions'));
    expect(menu, findsOneWidget);
    expect(tester.getSize(menu).width, lessThanOrEqualTo(342));
    expect(tester.getSize(menu).height, lessThanOrEqualTo(74));
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
    expect(find.byIcon(Icons.translate_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
