import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/accessibility/motion_preferences.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/providers/profile_provider.dart';
import 'package:haogpt/screens/elevenlabs_call_screen.dart';
import 'package:haogpt/services/subscription_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://howai-voice-motion-test.supabase.co',
      anonKey: 'howai-voice-motion-test-publishable-key',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('voice screen exits through its controlled close path',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider<SubscriptionService>.value(
            value: SubscriptionService(),
          ),
        ],
        child: MaterialApp(
          theme: HowAITheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                key: const ValueKey<String>('open_voice_call'),
                onPressed: () => Navigator.of(context).push(
                  HowAIModalPageRoute<void>(
                    reducedMotion: true,
                    builder: (_) => const ElevenLabsCallScreen(),
                  ),
                ),
                child: const Text('Open voice'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('open_voice_call')));
    await tester.pump();
    expect(find.text('HowAI Voice'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump();

    expect(find.text('HowAI Voice'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('open_voice_call')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey<String>('open_voice_call')));
    await tester.pump();
    expect(find.text('HowAI Voice'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump();

    expect(find.text('HowAI Voice'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('open_voice_call')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
