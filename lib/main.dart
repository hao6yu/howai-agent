import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/ai_personality_provider.dart';
import 'providers/auth_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //// print('====== HowAI APP STARTED ======');

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase with deep link handling
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

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
  await profileProvider.loadProfiles();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => profileProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => AIPersonalityProvider()),
      ],
      child: const HowAIMainApp(),
    ),
  );
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
          title: 'HowAI',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0078D4),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F7F7),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0078D4)),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: settings.getScaledFontSize(20),
                fontFamily: 'Roboto',
              ),
            ),
            textTheme: GoogleFonts.robotoTextTheme().copyWith(
              bodyLarge:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(16)),
              bodyMedium:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(14)),
              bodySmall:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(12)),
              headlineLarge:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(32)),
              headlineMedium:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(28)),
              headlineSmall:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(24)),
              titleLarge:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(22)),
              titleMedium:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(16)),
              titleSmall:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(14)),
              labelLarge:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(14)),
              labelMedium:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(12)),
              labelSmall:
                  GoogleFonts.roboto(fontSize: settings.getScaledFontSize(11)),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0078D4),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF2C2C2E),
              foregroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Color(0xFF0078D4)),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: settings.getScaledFontSize(20),
                fontFamily: 'Roboto',
              ),
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF2C2C2E),
              elevation: 0,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF2C2C2E),
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF2C2C2E),
            ),
            textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme)
                .copyWith(
              bodyLarge: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(16),
                color: Colors.white,
              ),
              bodyMedium: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(14),
                color: Colors.white,
              ),
              bodySmall: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(12),
                color: Colors.white70,
              ),
              headlineLarge: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(32),
                color: Colors.white,
              ),
              headlineMedium: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(28),
                color: Colors.white,
              ),
              headlineSmall: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(24),
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(22),
                color: Colors.white,
              ),
              titleMedium: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(16),
                color: Colors.white,
              ),
              titleSmall: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(14),
                color: Colors.white,
              ),
              labelLarge: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(14),
                color: Colors.white,
              ),
              labelMedium: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(12),
                color: Colors.white70,
              ),
              labelSmall: GoogleFonts.roboto(
                fontSize: settings.getScaledFontSize(11),
                color: Colors.white70,
              ),
            ),
            useMaterial3: true,
          ),
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

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  // Default to chat screen - no tab switching needed
  Widget _currentScreen = const AiChatScreen();

  void _navigateToGuide() {
    setState(() {
      _currentScreen = InstructionsScreen(onBack: _navigateToChat);
    });
  }

  void _navigateToChat() {
    setState(() {
      _currentScreen = const AiChatScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No bottom navigation bar - full screen for content
      body: _buildScreenWithNavigation(),
    );
  }

  Widget _buildScreenWithNavigation() {
    // Pass navigation callbacks to the chat screen if it's currently active
    if (_currentScreen is AiChatScreen) {
      return AiChatScreenWithNavigation(
        onNavigateToGuide: _navigateToGuide,
      );
    }

    // For non-chat screens, just show the screen directly
    // The CustomAppBar will handle the back button functionality
    return _currentScreen;
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
