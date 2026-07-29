import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/ai_personality_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/push_notification_provider.dart';
import 'providers/startup_provider.dart';
import 'screens/ai_chat_screen.dart';
import 'services/elevenlabs_service.dart';
import 'services/openai_service.dart';
import 'services/database_service.dart';
import 'services/subscription_service.dart';
import 'services/sync_service.dart';
import 'screens/subscription_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/instructions_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/knowledge_hub_screen.dart';
import 'features/actions/presentation/actions_workspace_screen.dart';
import 'firebase_options.dart';
import 'services/push_notification_service.dart';
import 'core/accessibility/motion_preferences.dart';
import 'core/theme/howai_theme.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(
    _bootstrap,
    (error, stack) async {
      debugPrint('Unhandled startup error: $error');
      if (Firebase.apps.isNotEmpty) {
        await FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: true,
        );
      }
    },
  );
}

Future<void> _bootstrap() async {
  AppConfig.validatePublicBackendConfig();
  final settingsProvider = SettingsProvider();

  // Initialize Supabase with deep link handling
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    // supabase_flutter 2.x still names this parameter `anonKey`, but it
    // accepts the modern public-client publishable key.
    anonKey: AppConfig.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // These initializers only resolve the authenticated proxy configuration.
  await Future.wait([
    OpenAIService.initialize(),
    ElevenLabsService.initialize(),
    settingsProvider.ready,
  ]);

  final startupProvider = StartupProvider();
  final profileProvider = ProfileProvider();
  final conversationProvider = ConversationProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: startupProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            profileProvider: profileProvider,
            conversationProvider: conversationProvider,
          ),
        ),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider.value(value: conversationProvider),
        ChangeNotifierProvider(create: (_) => AIPersonalityProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => PushNotificationProvider()),
      ],
      child: const HowAIMainApp(),
    ),
  );

  unawaited(
    _completeDeferredBootstrap(
      startupProvider: startupProvider,
      profileProvider: profileProvider,
    ),
  );
}

Future<void> _completeDeferredBootstrap({
  required StartupProvider startupProvider,
  required ProfileProvider profileProvider,
}) async {
  final notificationInitialization = _initializeNotifications();

  // Local data remains a readiness gate so feature screens never observe a
  // half-activated account database.
  await _initializeLocalData(profileProvider, startupProvider);
  startupProvider.markReady();

  // Push setup is useful but must not hold the first usable screen hostage.
  await notificationInitialization;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PushNotificationService.instance.flushPendingNavigation();
  });
}

Future<void> _initializeNotifications() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize(
      navigatorKey: rootNavigatorKey,
    );
  } catch (error, stack) {
    debugPrint('Push notification initialization is unavailable: $error');
    if (Firebase.apps.isNotEmpty) {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: 'Firebase or push notification initialization failed',
      );
    }
  }
}

Future<void> _initializeLocalData(
  ProfileProvider profileProvider,
  StartupProvider startupProvider,
) async {
  // Check database integrity and repair if needed
  try {
    final dbService = DatabaseService();
    final currentUser = Supabase.instance.client.auth.currentUser;
    await dbService.activateAccount(
      currentUser == null || currentUser.isAnonymous ? null : currentUser.id,
    );
    await dbService.checkAndRepairDatabase();
  } catch (e) {
    debugPrint('Local database check failed without deleting data: $e');
    startupProvider.recordNonFatalError(e);
  }

  // Initialize sync service (will start background sync if authenticated)
  final syncService = SyncService();
  try {
    await syncService.initialize();
  } catch (error) {
    startupProvider.recordNonFatalError(error);
    debugPrint('Background sync initialization is unavailable: $error');
  }

  // Initialize the profile provider and load profiles
  try {
    await profileProvider.loadProfiles();
  } catch (e) {
    // Last-resort startup recovery for users upgrading from a bad local DB state.
    try {
      final dbService = DatabaseService();
      await dbService.checkAndRepairDatabase();
      await profileProvider.loadProfiles();
    } catch (_) {
      // Keep app booting even if local profile load still fails.
    }
  }
}

class HowAIMainApp extends StatelessWidget {
  const HowAIMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProvider,
        ({ThemeMode themeMode, double fontSizeScale, String? selectedLocale})>(
      selector: (_, settings) => (
        themeMode: settings.themeMode,
        fontSizeScale: settings.fontSizeScale,
        selectedLocale: settings.selectedLocale,
      ),
      builder: (context, appearance, _) {
        Locale? locale;
        if (appearance.selectedLocale != null) {
          final localeParts = appearance.selectedLocale!.split('_');
          if (localeParts.length > 1) {
            locale = Locale(localeParts[0], localeParts[1]);
          } else {
            locale = Locale(appearance.selectedLocale!);
          }
        }
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'HowAI',
          debugShowCheckedModeBanner: false,
          themeMode: appearance.themeMode,
          theme: HowAITheme.light(fontScale: appearance.fontSizeScale),
          darkTheme: HowAITheme.dark(fontScale: appearance.fontSizeScale),
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StartupGate(),
          routes: {
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const MainTabScaffold(),
            '/subscription': (context) => const SubscriptionScreen(),
            '/settings': (context) =>
                SettingsScreen(onBack: () => Navigator.pop(context)),
            '/knowledge-hub': (context) => const KnowledgeHubScreen(),
            '/actions': (context) => ActionsWorkspaceScreen(
                  onCreateInChat: () => Navigator.of(context).pop(),
                ),
          },
        );
      },
    );
  }
}

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isReady =
        context.select<StartupProvider, bool>((provider) => provider.isReady);
    return AnimatedSwitcher(
      duration: motionDuration(context, HowAIMotion.standard),
      switchInCurve: HowAIMotion.enterCurve,
      switchOutCurve: HowAIMotion.exitCurve,
      child: isReady
          ? const AuthGate(key: ValueKey<String>('startup_ready'))
          : const Scaffold(
              key: ValueKey<String>('startup_loading'),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}

// Auth Gate - Shows auth screen or main app based on auth status
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User can choose to continue without account.
        if (!authProvider.isAuthenticated) {
          return const AuthScreen();
        }

        return const MainTabScaffold();
      },
    );
  }
}

class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({super.key});

  void _navigateToGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => InstructionsScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiChatScreenWithNavigation(
      onNavigateToGuide: () => _navigateToGuide(context),
    );
  }
}

// Custom chat screen wrapper that includes navigation
class AiChatScreenWithNavigation extends StatelessWidget {
  final VoidCallback? onNavigateToGuide;

  const AiChatScreenWithNavigation({
    super.key,
    this.onNavigateToGuide,
  });

  @override
  Widget build(BuildContext context) {
    return AiChatScreen(
      onNavigateToGuide: onNavigateToGuide,
    );
  }
}
