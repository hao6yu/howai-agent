import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/models/thinking_level.dart';
import 'package:haogpt/providers/settings_provider.dart';
import 'package:haogpt/services/subscription_service.dart';
import 'package:haogpt/widgets/chat_input_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://howai-widget-test.supabase.co',
      anonKey: 'howai-widget-test-publishable-key',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpComposer(
    WidgetTester tester, {
    ThinkingLevel thinkingLevel = ThinkingLevel.auto,
    ThemeMode themeMode = ThemeMode.light,
    bool disableAnimations = false,
    List<XFile> pendingImages = const <XFile>[],
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider<SubscriptionService>.value(
            value: SubscriptionService(),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: disableAnimations,
            ),
            child: child!,
          ),
          theme: HowAITheme.light(),
          darkTheme: HowAITheme.dark(),
          themeMode: themeMode,
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
                pendingImages: pendingImages,
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
    expect(tester.getSize(find.byType(ChatInputWidget)).height, lessThan(65));
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

  testWidgets('tapping outside the field dismisses the keyboard focus',
      (tester) async {
    await pumpComposer(tester);

    final fieldFinder = find.byType(TextField);
    await tester.tap(fieldFinder);
    await tester.pump();
    expect(tester.widget<TextField>(fieldFinder).focusNode?.hasFocus, isTrue);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(tester.widget<TextField>(fieldFinder).focusNode?.hasFocus, isFalse);
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

  testWidgets('composer honors the reduced-motion accessibility setting',
      (tester) async {
    await pumpComposer(tester, disableAnimations: true);

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byKey(const ValueKey<String>('adaptive-composer-switcher')),
    );
    expect(switcher.duration, Duration.zero);
  });

  testWidgets('pending photo thumbnails use a bounded image decode',
      (tester) async {
    await pumpComposer(
      tester,
      pendingImages: [XFile('assets/icon/google.png')],
    );

    final thumbnail = tester.widget<Container>(
      find.byKey(const ValueKey<String>('pending_image_thumbnail_0')),
    );
    final decoration = thumbnail.decoration! as BoxDecoration;
    final provider = decoration.image!.image;

    expect(provider, isA<ResizeImage>());
    final resized = provider as ResizeImage;
    expect(resized.width, 256);
    expect(resized.height, 256);
  });

  for (final testCase in <({
    String name,
    ThemeMode mode,
    HowAIColors colors,
  })>[
    (
      name: 'light',
      mode: ThemeMode.light,
      colors: HowAIColors.light,
    ),
    (
      name: 'dark',
      mode: ThemeMode.dark,
      colors: HowAIColors.dark,
    ),
  ]) {
    testWidgets(
      'quick actions use readable grouped styling in ${testCase.name} mode',
      (tester) async {
        await pumpComposer(tester, themeMode: testCase.mode);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('quick_actions_sheet')),
          findsOneWidget,
        );
        expect(find.text('Quick Actions'), findsOneWidget);
        expect(find.text('Ask from photo'), findsOneWidget);
        expect(find.text('Voice Input'), findsOneWidget);
        // Thinking level is Pro-only. Limited free features should not look
        // locked while the user still has allowance remaining.
        expect(find.text('PRO'), findsOneWidget);

        for (final key in const <String>[
          'attachment_actions_group',
          'feature_actions_group',
        ]) {
          final group = tester.widget<Container>(
            find.byKey(ValueKey<String>(key)),
          );
          final decoration = group.decoration! as BoxDecoration;
          expect(decoration.color, testCase.colors.surface);
          expect(decoration.borderRadius, BorderRadius.circular(14));
        }

        final title = tester.widget<Text>(find.text('Voice Input'));
        expect(title.style?.fontSize, 15);
        expect(title.style?.fontWeight, FontWeight.w600);

        final description = tester.widget<Text>(find.text(
          'Speak naturally - your voice will be transcribed and understood',
        ));
        expect(description.maxLines, 2);
        expect(description.style?.color, testCase.colors.textSecondary);
      },
    );
  }
}

class _ComposerHarness extends StatefulWidget {
  const _ComposerHarness({
    required this.thinkingLevel,
    required this.pendingImages,
  });

  final ThinkingLevel thinkingLevel;
  final List<XFile> pendingImages;

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
      pendingImages: widget.pendingImages,
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
