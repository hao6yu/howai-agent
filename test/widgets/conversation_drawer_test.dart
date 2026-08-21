import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/accessibility/motion_preferences.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/providers/conversation_provider.dart';
import 'package:haogpt/providers/profile_provider.dart';
import 'package:haogpt/services/subscription_service.dart';
import 'package:haogpt/widgets/conversation_drawer.dart';
import 'package:haogpt/widgets/new_conversation_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://howai-drawer-test.supabase.co',
      anonKey: 'howai-drawer-test-publishable-key',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpDrawer(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConversationProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider<SubscriptionService>.value(
            value: SubscriptionService(),
          ),
        ],
        child: MaterialApp(
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
          home: const Scaffold(body: ConversationDrawer()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('drawer uses the shared new-conversation control',
      (tester) async {
    await pumpDrawer(tester);

    expect(find.byType(NewConversationButton), findsOneWidget);
    expect(find.byIcon(Icons.edit_square), findsOneWidget);
    expect(find.byIcon(Icons.post_add), findsNothing);
  });

  testWidgets('drawer gives the full search hint enough room', (tester) async {
    await pumpDrawer(tester);

    final searchField = find.byKey(
      const ValueKey<String>('conversation_search_field'),
    );
    expect(searchField, findsOneWidget);
    expect(tester.getSize(searchField).width, greaterThanOrEqualTo(270));
    expect(find.text('Search conversations'), findsOneWidget);
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
      'workspace links stay compact in ${testCase.name} mode',
      (tester) async {
        await pumpDrawer(tester, themeMode: testCase.mode);

        final navigation = find.byKey(
          const ValueKey<String>('drawer_workspace_navigation'),
        );
        expect(navigation, findsOneWidget);
        expect(find.text('Automations'), findsOneWidget);
        expect(find.text('Knowledge Hub'), findsOneWidget);
        expect(find.text('Reminders and recurring tasks'), findsNothing);

        expect(tester.getSize(navigation).height, lessThanOrEqualTo(104));
        final container = tester.widget<Container>(navigation);
        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.color, testCase.colors.surface);
      },
    );
  }

  testWidgets('workspace navigation waits for the drawer to close',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConversationProvider()),
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
          routes: {
            '/actions': (_) => const Scaffold(
                  body: Text(
                    'Actions destination',
                    key: ValueKey<String>('actions_destination'),
                  ),
                ),
          },
          home: Scaffold(
            drawer: const ConversationDrawer(),
            body: Builder(
              builder: (context) => TextButton(
                key: const ValueKey<String>('open_drawer'),
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('open_drawer')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Automations'));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsNothing,
    );

    await tester.pump(
      HowAIMotion.drawerTransition - const Duration(milliseconds: 1),
    );
    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsOneWidget,
    );
  });
}
