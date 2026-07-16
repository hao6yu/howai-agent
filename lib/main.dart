import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'core/theme/howai_theme.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //// print('====== HowAI APP STARTED ======');

  // Initialize Supabase with deep link handling
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.instance.initialize(
      navigatorKey: rootNavigatorKey,
    );
  } catch (error) {
    debugPrint('Push notification initialization is unavailable: $error');
  }

  // Check database integrity and repair if needed
  try {
    //// print("Checking database integrity...");
    final dbService = DatabaseService();
    final wasRepaired = await dbService.checkAndRepairDatabase();
    if (wasRepaired) {
      //// print("Database was reset due to integrity issues");
    }
  } catch (e) {
    //// print("Error during database check: $e");
  }

  // Initialize services
  await OpenAIService.initialize();
  await ElevenLabsService.initialize();

  // Initialize sync service (will start background sync if authenticated)
  final syncService = SyncService();
  await syncService.initialize();

  // Initialize the profile provider and load profiles
  final profileProvider = ProfileProvider();
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => profileProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => AIPersonalityProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => PushNotificationProvider()),
      ],
      child: const HowAIMainApp(),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PushNotificationService.instance.flushPendingNavigation();
  });
}

class HowAIMainApp extends StatelessWidget {
  const HowAIMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        Locale? locale;
        if (settings.selectedLocale != null) {
          final localeParts = settings.selectedLocale!.split('_');
          if (localeParts.length > 1) {
            locale = Locale(localeParts[0], localeParts[1]);
          } else {
            locale = Locale(settings.selectedLocale!);
          }
        }
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: 'HowAI',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: HowAITheme.light(fontScale: settings.fontSizeScale),
          darkTheme: HowAITheme.dark(fontScale: settings.fontSizeScale),
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
            Locale('zh', 'TW'),
            Locale('ja'),
            Locale('es'),
            Locale('fr'),
            Locale('hi'),
            Locale('ar'),
            Locale('ru'),
            Locale('pt', 'BR'),
            Locale('ko'),
            Locale('de'),
            Locale('id'),
            Locale('tr'),
            Locale('it'),
            Locale('vi'),
            Locale('pl'),
          ],
          home: const AuthGate(),
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Show auth screen if not authenticated
        // User can choose to continue without account
        if (!authProvider.isAuthenticated) {
          return const AuthScreen();
        }

        // Show main app if authenticated
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
