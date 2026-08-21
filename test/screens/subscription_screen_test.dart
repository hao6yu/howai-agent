import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/core/theme/howai_theme.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:haogpt/screens/subscription_screen.dart';
import 'package:haogpt/services/subscription_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://howai-subscription-test.supabase.co',
      anonKey: 'howai-subscription-test-publishable-key',
    );
  });

  late SubscriptionService subscriptionService;

  setUpAll(() {
    subscriptionService = SubscriptionService();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await subscriptionService.setDebugPremiumOverride(true);
  });

  tearDown(() async {
    await subscriptionService.clearDebugOverride();
  });

  Future<void> pumpPremiumScreen(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider<SubscriptionService>.value(
        value: subscriptionService,
        child: MaterialApp(
          theme: HowAITheme.light(),
          darkTheme: HowAITheme.dark(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SubscriptionScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('active subscribers retain restore in the compact layout', (
    tester,
  ) async {
    await pumpPremiumScreen(tester, size: const Size(393, 852));

    expect(
      find.byKey(const Key('subscription_premium_status')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('subscription_manage_group')), findsOneWidget);
    expect(
      find.byKey(const Key('subscription_restore_active')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('subscription_features_group')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('subscription_details_group')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('premium layout does not overflow on a narrow phone', (
    tester,
  ) async {
    await pumpPremiumScreen(tester, size: const Size(320, 700));

    await tester.scrollUntilVisible(
      find.byKey(const Key('subscription_restore_active')),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const Key('subscription_restore_active')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
