import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/migration_service.dart';
import '../services/sync_service.dart';
import '../services/subscription_service.dart';
import '../services/push_notification_service.dart';
import '../services/database_service.dart';
import 'conversation_provider.dart';
import 'profile_provider.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;
  final ProfileProvider _profileProvider;
  final ConversationProvider _conversationProvider;
  Future<void>? _postAuthTask;
  String? _postAuthUserId;
  Future<void> _authTransition = Future<void>.value();
  Future<void> _lastAuthOperation = Future<void>.value();
  String? _queuedAuthUserId;
  bool _authTransitionFailed = false;
  int _authGeneration = 0;

  // Flag to indicate sync has completed and UI should refresh
  bool _syncCompleted = false;

  AuthProvider({
    required ProfileProvider profileProvider,
    required ConversationProvider conversationProvider,
  })  : _profileProvider = profileProvider,
        _conversationProvider = conversationProvider {
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
    _queuedAuthUserId = _user?.id;
    _isLoading = false;

    // Listen to auth state changes
    _authSubscription = _supabaseService.authStateChanges.listen(
      (authState) {
        unawaited(
          _queueAuthStateChange(authState.session?.user).catchError(
            (Object _) {},
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[AuthProvider] Auth state stream failed: $error');
        _errorMessage = 'Authentication status could not be refreshed.';
        notifyListeners();
      },
    );

    if (_user != null && !_user!.isAnonymous) {
      _triggerPostAuthTasks();
    }

    notifyListeners();
  }

  Future<void> _queueAuthStateChange(User? nextUser) {
    final nextUserId = nextUser?.id;
    if (_queuedAuthUserId == nextUserId && !_authTransitionFailed) {
      _user = nextUser;
      notifyListeners();
      return _lastAuthOperation;
    }

    _queuedAuthUserId = nextUserId;
    _authTransitionFailed = false;
    final generation = ++_authGeneration;
    _isLoading = true;
    _user = nextUser;
    notifyListeners();

    final operation = _authTransition.then(
      (_) => _performAuthTransition(nextUser, generation),
    );
    _authTransition = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    _lastAuthOperation = operation;
    return operation;
  }

  Future<void> _performAuthTransition(User? nextUser, int generation) async {
    try {
      await SyncService().clearSyncData();
      final previousPostAuthTask = _postAuthTask;
      if (previousPostAuthTask != null) {
        await previousPostAuthTask.catchError((Object _) {});
      }
      if (_authGeneration != generation) return;

      await DatabaseService().activateAccount(
        nextUser == null || nextUser.isAnonymous ? null : nextUser.id,
      );
      if (_authGeneration != generation) return;

      await _reloadLocalAccountState();
      if (_authGeneration != generation) return;

      _authTransitionFailed = false;
      _errorMessage = null;
      if (nextUser != null && !nextUser.isAnonymous) {
        _triggerPostAuthTasks();
      }
    } catch (error) {
      debugPrint('[AuthProvider] Account storage switch failed: $error');
      _errorMessage = 'Your local account data could not be opened.';
      if (_authGeneration == generation) {
        _authTransitionFailed = true;
      }
      rethrow;
    } finally {
      if (_authGeneration == generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
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

      if (response.user != null && response.session != null) {
        // Create profile in profiles table
        await _supabaseService.upsertUserProfile(
          userId: response.user!.id,
          email: email,
          name: name,
        );

        await _queueAuthStateChange(response.user);
        _isLoading = false;
        notifyListeners();

        return true;
      }

      if (response.user != null) {
        _errorMessage =
            'Check your email to confirm your account, then sign in.';
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
        await _queueAuthStateChange(response.user);
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

  // Start local/accountless mode with an anonymous Supabase session.
  Future<bool> signInAnonymously() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final response = await _supabaseService.signInAnonymously();

      if (response.user != null) {
        await _queueAuthStateChange(response.user);
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
  Future<bool> signOut() async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();
      try {
        await PushNotificationService.instance.unregisterCurrentDevice();
      } catch (error) {
        debugPrint(
          '[AuthProvider] Push device unregister failed during sign out: $error',
        );
      }
      await _supabaseService.signOut();
      await _queueAuthStateChange(null);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
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

  Future<void> _reloadLocalAccountState() async {
    await _profileProvider.loadProfiles();
    _conversationProvider.clearSelection();
    await _conversationProvider.loadConversations(
      profileId: _profileProvider.selectedProfileId,
    );
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
    final user = _user;
    if (user == null || user.isAnonymous) return;
    if (_postAuthUserId == user.id && _postAuthTask != null) return;

    final generation = _authGeneration;
    _postAuthUserId = user.id;
    _postAuthTask = Future.microtask(() async {
      try {
        if (!_isCurrentAuthContext(user.id, generation)) return;

        // Check if migration is needed
        final migrationService = MigrationService();
        if (await migrationService.needsMigration()) {
          if (!_isCurrentAuthContext(user.id, generation)) return;
          debugPrint('[AuthProvider] Starting background migration');
          await migrationService.startMigration();
        }
        if (!_isCurrentAuthContext(user.id, generation)) return;

        // Restart sync service with new auth state
        final syncService = SyncService();
        await syncService.initialize();
        if (!_isCurrentAuthContext(user.id, generation)) return;
        await syncService.syncNow();
        if (!_isCurrentAuthContext(user.id, generation)) return;

        // Sync subscription status to Supabase
        final subscriptionService = SubscriptionService();
        await subscriptionService.syncCurrentSubscriptionToSupabase();
        if (!_isCurrentAuthContext(user.id, generation)) return;

        // Load user profile and AI insights from Supabase (cross-device sync)
        debugPrint('[AuthProvider] Loading profile from Supabase...');
        await _profileProvider.loadProfiles();
        if (!_isCurrentAuthContext(user.id, generation)) return;
        await _profileProvider.loadProfileFromSupabase();
        if (!_isCurrentAuthContext(user.id, generation)) return;
        await _conversationProvider.loadConversations(
          profileId: _profileProvider.selectedProfileId,
        );

        if (!_isCurrentAuthContext(user.id, generation)) return;

        debugPrint('[AuthProvider] Post-auth tasks completed');

        // Signal that sync is complete - UI should refresh
        _syncCompleted = true;
        notifyListeners();

        debugPrint('[AuthProvider] Notified UI to refresh after sync');
      } catch (e) {
        debugPrint('[AuthProvider] Error in post-auth tasks (silent): $e');
        // Silent failure - don't disrupt user experience
      } finally {
        if (_postAuthUserId == user.id) {
          _postAuthTask = null;
        }
      }
    });
  }

  bool _isCurrentAuthContext(String userId, int generation) {
    return _authGeneration == generation &&
        _user?.id == userId &&
        _supabaseService.currentUser?.id == userId;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
