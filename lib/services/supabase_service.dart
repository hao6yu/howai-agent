import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Get the Supabase client
  SupabaseClient get client => _client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Sign up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Sign in error: $e');
      rethrow;
    }
  }

  // Sign in with Google using Supabase OAuth (web-based flow)
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Use Supabase's built-in OAuth flow for Google
      // Use externalApplication to explicitly launch Safari/Chrome
      // For mobile, we must specify the deep link redirect URL to override the default Site URL
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.hyu.haogpt://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // The OAuth flow was initiated successfully
      // The actual authentication happens in the external browser
      // Supabase will automatically update the auth state when the user returns via deep link
      debugPrint('[SupabaseService] Google OAuth flow initiated: $result');

      // Return a response indicating the flow was started
      // The actual auth state will be updated via the auth state listener
      return AuthResponse(session: null, user: null);
    } catch (e) {
      debugPrint('[SupabaseService] Google sign in error: $e');
      rethrow;
    }
  }

  // Sign in with Apple using Supabase OAuth (web-based flow)
  Future<AuthResponse> signInWithApple() async {
    try {
      // Use Supabase's built-in OAuth flow for Apple
      // For mobile: Use custom deep link so Supabase redirects back to app after OAuth
      // For web: Use the web app URL
      // Note: Apple requires HTTPS URLs in Apple Developer Console, but Supabase
      // will accept the custom scheme and handle the OAuth callback server-side
      final String redirectUrl = kIsWeb
          ? 'https://chat.howai.io'
          : 'com.hyu.haogpt://login-callback';

      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // The OAuth flow was initiated successfully
      // Supabase will handle the HTTPS callback from Apple, then redirect to our deep link
      debugPrint('[SupabaseService] Apple OAuth flow initiated with redirect: $redirectUrl, result: $result');

      // Return a response indicating the flow was started
      // The actual auth state will be updated via the auth state listener
      return AuthResponse(session: null, user: null);
    } catch (e) {
      debugPrint('[SupabaseService] Apple sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('[SupabaseService] User signed out successfully');
    } catch (e) {
      debugPrint('[SupabaseService] Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('[SupabaseService] Password reset email sent to $email');
    } catch (e) {
      debugPrint('[SupabaseService] Reset password error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateUserProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: updates),
      );
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Update profile error: $e');
      rethrow;
    }
  }

  // Get user profile from profiles table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client.from('profiles').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      debugPrint('[SupabaseService] Get user profile error: $e');
      return null;
    }
  }

  // Create or update user profile in profiles table
  Future<void> upsertUserProfile({
    required String userId,
    String? email,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        'id': userId,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('profiles').upsert(data);
      debugPrint('[SupabaseService] User profile upserted successfully');
    } catch (e) {
      debugPrint('[SupabaseService] Upsert profile error: $e');
      // Don't rethrow - profile creation can fail silently
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      // Note: This requires additional server-side logic
      // For now, just sign out
      await signOut();
      debugPrint('[SupabaseService] Account deletion initiated');
    } catch (e) {
      debugPrint('[SupabaseService] Delete account error: $e');
      rethrow;
    }
  }
}
