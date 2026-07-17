import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/migration_service.dart';
import '../services/sync_service.dart';
import '../services/subscription_service.dart';
import '../services/push_notification_service.dart';
import 'profile_provider.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;

  // Flag to indicate sync has completed and UI should refresh
  bool _syncCompleted = false;

  AuthProvider() {
    _initialize();
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;
  bool get hasSyncAccount => isAuthenticated && !isAnonymous;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLocalMode => !hasSyncAccount;
  bool get syncCompleted => _syncCompleted;

  // Reset the sync completed flag after UI has handled it
  void resetSyncCompletedFlag() {
    _syncCompleted = false;
  }

  // Initialize and listen to auth state changes
  void _initialize() {
    _user = _supabaseService.currentUser;
    _isLoading = false;

    debugPrint(
        '[AuthProvider] Initializing with user: ${_user?.email ?? "none"}');

    // Listen to auth state changes
    _authSubscription = _supabaseService.authStateChanges.listen((authState) {
      final previousUser = _user;
      _user = authState.session?.user;

      debugPrint(
          '[AuthProvider] Auth state changed - Previous: ${previousUser?.email ?? "none"}, Current: ${_user?.email ?? "none"}');

      // If user just logged into a recoverable account, trigger sync tasks.
      // Anonymous sessions are intentionally local-only.
      if (_user != null &&
          !_user!.isAnonymous &&
          (previousUser == null || previousUser.isAnonymous)) {
        debugPrint('[AuthProvider] User logged in, triggering post-auth tasks');
        _triggerPostAuthTasks();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        _user = response.user;

        // Create profile in profiles table
        await _supabaseService.upsertUserProfile(
          userId: response.user!.id,
          email: email,
          name: name,
        );

        _isLoading = false;
        notifyListeners();

        // Trigger migration and sync after successful sign up
        _triggerPostAuthTasks();

        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();

        // Trigger migration and sync after successful sign in
        _triggerPostAuthTasks();

        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Start local/accountless mode with an anonymous Supabase session.
  Future<bool> signInAnonymously() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabaseService.signInAnonymously();

      if (response.user != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Initiate OAuth flow (opens browser/webview)
      await _supabaseService.signInWithGoogle();

      // OAuth flow initiated successfully
      // The actual authentication will complete in the browser
      // and the auth state listener will update the user
      _isLoading = false;
      notifyListeners();

      // Return true to indicate OAuth flow started successfully
      // The actual login will be handled by the auth state listener
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Initiate OAuth flow (opens browser/webview)
      await _supabaseService.signInWithApple();

      // OAuth flow initiated successfully
      // The actual authentication will complete in the browser
      // and the auth state listener will update the user
      _isLoading = false;
      notifyListeners();

      // Return true to indicate OAuth flow started successfully
      // The actual login will be handled by the auth state listener
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _errorMessage = null;
      await PushNotificationService.instance.unregisterCurrentDevice();
      await _supabaseService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _supabaseService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      _errorMessage = null;

      final response = await _supabaseService.updateUserProfile(
        name: name,
        avatarUrl: avatarUrl,
      );

      if (response.user != null) {
        _user = response.user;

        // Also update profiles table
        await _supabaseService.upsertUserProfile(
          userId: response.user!.id,
          name: name,
          avatarUrl: avatarUrl,
        );

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper to extract user-friendly error messages
  String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please confirm your email address';
        case 'User already registered':
          return 'An account with this email already exists';
        case 'anonymous_provider_disabled':
        case 'Anonymous sign-ins are disabled':
          return 'Local mode is not enabled yet. Please try signing in.';
        default:
          if (error.message.toLowerCase().contains('anonymous')) {
            return 'Local mode is not enabled yet. Please try signing in.';
          }
          return error.message;
      }
    }
    return 'An error occurred. Please try again.';
  }

  // Trigger post-authentication tasks (migration, sync, etc.)
  void _triggerPostAuthTasks() {
    // Run in background, don't await
    Future.microtask(() async {
      try {
        if (_user?.isAnonymous ?? true) {
          debugPrint(
              '[AuthProvider] Anonymous session active, skipping cloud sync tasks');
          return;
        }

        // Check if migration is needed
        final migrationService = MigrationService();
        if (await migrationService.needsMigration()) {
          debugPrint('[AuthProvider] Starting background migration');
          await migrationService.startMigration();
        }

        // Restart sync service with new auth state
        final syncService = SyncService();
        await syncService.initialize();

        // Sync subscription status to Supabase
        final subscriptionService = SubscriptionService();
        await subscriptionService.syncCurrentSubscriptionToSupabase();

        // Load user profile and AI insights from Supabase (cross-device sync)
        debugPrint('[AuthProvider] Loading profile from Supabase...');
        final profileProvider = ProfileProvider();
        await profileProvider.loadProfiles(); // Load local profiles first
        await profileProvider.loadProfileFromSupabase(); // Then sync from cloud

        debugPrint('[AuthProvider] Post-auth tasks completed');

        // Signal that sync is complete - UI should refresh
        _syncCompleted = true;
        notifyListeners();

        debugPrint('[AuthProvider] Notified UI to refresh after sync');
      } catch (e) {
        debugPrint('[AuthProvider] Error in post-auth tasks (silent): $e');
        // Silent failure - don't disrupt user experience
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
