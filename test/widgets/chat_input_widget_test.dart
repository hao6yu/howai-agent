import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/models/thinking_level.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:haogpt/widgets/chat_input_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpComposer(
    WidgetTester tester, {
    ThinkingLevel thinkingLevel = ThinkingLevel.auto,
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: _ComposerHarness(
                thinkingLevel: thinkingLevel,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('tools, text, and voice share one compact composer row',
      (tester) async {
    await pumpComposer(tester);

    final tools = find.byIcon(Icons.add);
    final field = find.byType(TextField);
    final dictation = find.byIcon(Icons.mic_none_rounded);
    final voice = find.byIcon(Icons.graphic_eq_rounded);

    expect(tools, findsOneWidget);
    expect(field, findsOneWidget);
    expect(dictation, findsOneWidget);
    expect(voice, findsOneWidget);
    expect(find.text('Ask HowAI'), findsOneWidget);
    expect(find.byIcon(Icons.language_rounded), findsNothing);
    expect(find.textContaining('Real-time Web Search'), findsNothing);

    final composer = tester.widget<Container>(
      find.byKey(const ValueKey<String>('adaptive_composer')),
    );
    final decoration = composer.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(12));

    expect(
      find.ancestor(of: tools, matching: find.byType(IconButton)),
      findsNothing,
    );
    expect(
      find.ancestor(of: tools, matching: find.byType(InkWell)),
      findsOneWidget,
    );

    final toolsCenter = tester.getCenter(tools);
    final fieldCenter = tester.getCenter(field);
    final voiceCenter = tester.getCenter(voice);
    expect((toolsCenter.dy - fieldCenter.dy).abs(), lessThan(8));
    expect((voiceCenter.dy - fieldCenter.dy).abs(), lessThan(8));
    expect(tester.getSize(find.byType(ChatInputWidget)).height, lessThan(80));
  });

  testWidgets('composer expands horizontally when the field is focused',
      (tester) async {
    await pumpComposer(tester);

    final composer = find.byKey(const ValueKey<String>('adaptive_composer'));
    final restingWidth = tester.getSize(composer).width;

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(tester.getSize(composer).width, greaterThan(restingWidth));
  });

  testWidgets('send replaces both voice controls while a draft exists',
      (tester) async {
    await pumpComposer(tester);

    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello Luna');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
  });

  testWidgets('thinking level uses a compact removable tag', (tester) async {
    await pumpComposer(tester, thinkingLevel: ThinkingLevel.balanced);

    expect(find.text('Balanced'), findsOneWidget);
    expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
    expect(tester.getSize(find.byType(InputChip)).height, lessThan(36));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('Balanced'), findsNothing);
  });
}

class _ComposerHarness extends StatefulWidget {
  const _ComposerHarness({required this.thinkingLevel});

  final ThinkingLevel thinkingLevel;

  @override
  State<_ComposerHarness> createState() => _ComposerHarnessState();
}

class _ComposerHarnessState extends State<_ComposerHarness>
    with TickerProviderStateMixin {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final AnimationController _sendController;
  late final AnimationController _micController;
  late final AnimationController _recordingController;
  late ThinkingLevel _thinkingLevel;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _sendController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _recordingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _thinkingLevel = widget.thinkingLevel;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _sendController.dispose();
    _micController.dispose();
    _recordingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatInputWidget(
      textController: _textController,
      textInputFocusNode: _focusNode,
      isVoiceInputMode: false,
      isRecording: false,
      isSending: false,
      pendingImages: const <XFile>[],
      pendingFiles: const <PlatformFile>[],
      isPdfWorkflowActive: false,
      pdfCountdown: 0,
      recordButtonText: '',
      recordingDuration: 0,
      isShowingCancelHint: false,
      isCancelingRecording: false,
      onToggleInputMode: () {},
      onStartRecording: () {},
      onStopRecording: () {},
      onCancelRecording: () {},
      onRecordingMove: (_) {},
      onRemovePendingImage: (_) {},
      onRemovePendingFile: (_) {},
      onConvertToPdf: () {},
      onCancelPdfAutoConversion: () {},
      onShowAttachmentOptions: (_) {},
      onShowFileUploadOptions: () {},
      onSendMessage: (_, __, ___) {},
      sendButtonController: _sendController,
      micAnimationController: _micController,
      recordingPulseController: _recordingController,
      onSpeakCall: () {},
      thinkingLevel: _thinkingLevel,
      onThinkingLevelChanged: (level) {
        setState(() => _thinkingLevel = level);
      },
    );
  }
}
