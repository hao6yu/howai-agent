import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/models/conversation.dart';
import 'package:haogpt/providers/conversation_provider.dart';
import 'package:haogpt/providers/profile_provider.dart';
import 'package:haogpt/services/subscription_service.dart';
import 'package:haogpt/widgets/conversation_drawer.dart';
import 'package:haogpt/widgets/new_conversation_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _TestConversationProvider extends ConversationProvider {
  _TestConversationProvider(this.items, {this.archivedItems = const []});

  final List<Conversation> items;
  final List<Conversation> archivedItems;

  @override
  List<Conversation> get conversations => items;

  @override
  List<Conversation> get archivedConversations => archivedItems;
}

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
    ConversationProvider? conversationProvider,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ConversationProvider>(
            create: (_) => conversationProvider ?? ConversationProvider(),
          ),
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

  testWidgets('drawer uses the shared new-conversation control', (
    tester,
  ) async {
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

  testWidgets('large conversation histories build rows lazily', (tester) async {
    final now = DateTime.now();
    final conversations = List<Conversation>.generate(
      1000,
      (index) => Conversation(
        id: index + 1,
        title: 'Conversation $index',
        createdAt: now,
        updatedAt: now,
        profileId: 1,
      ),
    );

    await pumpDrawer(
      tester,
      conversationProvider: _TestConversationProvider(conversations),
    );

    final builtActionCount = find
        .byTooltip('Conversation actions')
        .evaluate()
        .length;
    expect(builtActionCount, greaterThan(0));
    expect(builtActionCount, lessThan(50));
    expect(
      find.byKey(const ValueKey<String>('conversation_tile_1000')),
      findsNothing,
    );
  });

  testWidgets('archived rows are lazy until their section is expanded', (
    tester,
  ) async {
    final now = DateTime.now();
    final archived = List<Conversation>.generate(
      200,
      (index) => Conversation(
        id: index + 1,
        title: 'Archived conversation $index',
        createdAt: now,
        updatedAt: now,
        archivedAt: now,
        profileId: 1,
      ),
    );

    await pumpDrawer(
      tester,
      conversationProvider: _TestConversationProvider(
        const [],
        archivedItems: archived,
      ),
    );

    expect(find.byTooltip('Conversation actions'), findsNothing);
    await tester.tap(
      find.byKey(const ValueKey<String>('archived_conversations_toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Conversation actions'), findsWidgets);
    expect(
      find.byTooltip('Conversation actions').evaluate().length,
      lessThan(50),
    );
  });

  for (final testCase in <({String name, ThemeMode mode, HowAIColors colors})>[
    (name: 'light', mode: ThemeMode.light, colors: HowAIColors.light),
    (name: 'dark', mode: ThemeMode.dark, colors: HowAIColors.dark),
  ]) {
    testWidgets('workspace links stay compact in ${testCase.name} mode', (
      tester,
    ) async {
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
    });
  }

  testWidgets('workspace navigation waits for the sliding drawer to close', (
    tester,
  ) async {
    final closeCompleter = Completer<void>();
    var closeRequested = false;

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
            body: ConversationDrawer(
              onClose: () {
                closeRequested = true;
                return closeCompleter.future;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Automations'));
    await tester.pump();

    expect(closeRequested, isTrue);
    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsNothing,
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsNothing,
    );

    closeCompleter.complete();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('actions_destination')),
      findsOneWidget,
    );
  });
}
