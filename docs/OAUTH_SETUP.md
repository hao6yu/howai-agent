# OAuth Setup Guide

## Overview
This guide explains how to configure Google and Apple OAuth for the HowAI mobile app.

## Deep Link Configuration

### iOS (Info.plist)
✅ Already configured with URL scheme: `com.hyu.haogpt`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.hyu.haogpt</string>
        </array>
    </dict>
</array>
```

### Android (AndroidManifest.xml)
✅ Already configured with deep link intent filter

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="com.hyu.haogpt"
        android:host="login-callback" />
</intent-filter>
```

## Supabase Configuration

### 1. Add Redirect URLs in Supabase Dashboard

Go to your Supabase project → Authentication → URL Configuration

Add these redirect URLs:
```
com.hyu.haogpt://login-callback/
com.hyu.haogpt://login-callback
```

### 2. Configure OAuth Providers

#### Google OAuth

1. **Google Cloud Console Setup:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create or select your project
   - Enable Google+ API
   - Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
   
2. **Create OAuth Client IDs:**
   
   **For iOS:**
   - Application type: iOS
   - Bundle ID: `com.hyu.haogpt`
   - Copy the Client ID
   
   **For Android:**
   - Application type: Android
   - Package name: `com.hyu.haogpt`
   - SHA-1 certificate fingerprint: (get from your keystore)
   - Copy the Client ID
   
   **For Web (Supabase):**
   - Application type: Web application
   - Authorized redirect URIs: 
     - `https://your-project.supabase.co/auth/v1/callback`
   - Copy Client ID and Client Secret

3. **Configure in Supabase:**
   - Go to Supabase Dashboard → Authentication → Providers
   - Enable Google provider
   - Paste Web Client ID and Client Secret
   - Save

#### Apple Sign In

1. **Apple Developer Console Setup:**
   - Go to [Apple Developer](https://developer.apple.com/)
   - Certificates, Identifiers & Profiles
   - Identifiers → App IDs
   - Select your app ID: `com.hyu.haogpt`
   - Enable "Sign in with Apple"
   - Configure Services ID:
     - Create new Services ID
     - Enable "Sign in with Apple"
     - Configure domains and redirect URLs:
       - Domain: `your-project.supabase.co`
       - Redirect URL: `https://your-project.supabase.co/auth/v1/callback`

2. **Create Key:**
   - Keys → Create new key
   - Enable "Sign in with Apple"
   - Download the key file (.p8)
   - Note the Key ID

3. **Configure in Supabase:**
   - Go to Supabase Dashboard → Authentication → Providers
   - Enable Apple provider
   - Enter:
     - Services ID
     - Team ID
     - Key ID
     - Private Key (contents of .p8 file)
   - Save

## Testing

### Test Google Sign In
1. Run the app
2. Tap "Continue with Google"
3. Browser/WebView opens with Google sign in
4. After signing in, should redirect back to app
5. App should show main chat screen (not web version)

### Test Apple Sign In
1. Run the app on iOS device (not simulator for full testing)
2. Tap "Continue with Apple"
3. Apple sign in sheet appears
4. After signing in, should return to app
5. App should show main chat screen

## Troubleshooting

### Issue: Redirects to web version instead of app

**Solution:**
- ✅ Deep links configured in iOS Info.plist
- ✅ Deep links configured in Android AndroidManifest.xml
- ✅ Supabase initialized with PKCE flow
- ✅ OAuth methods use correct redirect URL
- ⚠️ Make sure redirect URLs are added in Supabase Dashboard

### Issue: "Invalid redirect URL" error

**Solution:**
- Check Supabase Dashboard → Authentication → URL Configuration
- Ensure `com.hyu.haogpt://login-callback/` is in allowed redirect URLs
- Try both with and without trailing slash

### Issue: OAuth doesn't work on Android

**Solution:**
- Verify SHA-1 fingerprint is correct in Google Cloud Console
- Get SHA-1 from your keystore:
  ```bash
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- Add SHA-1 to Google Cloud Console OAuth client

### Issue: Apple Sign In not working

**Solution:**
- Ensure "Sign in with Apple" capability is enabled in Xcode
- Verify Services ID is correctly configured
- Check that private key (.p8) is correctly pasted in Supabase
- Ensure Team ID and Key ID are correct

## Code Implementation

### Supabase Service (lib/services/supabase_service.dart)

Uses **native Google Sign In** and **native Apple Sign In** as recommended by Supabase:

```dart
// Sign in with Google using native Google Sign In (recommended by Supabase)
Future<AuthResponse> signInWithGoogle() async {
  try {
    const webClientId = 'YOUR_WEB_CLIENT_ID';
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in was cancelled');

    final googleAuth = await googleUser.authentication;
    
    // Sign in to Supabase with the Google tokens
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken!,
    );

    return response;
  } catch (e) {
    debugPrint('[SupabaseService] Google sign in error: $e');
    rethrow;
  }
}
```

### Benefits of Native Auth:
- ✅ **Stays in app** - No browser redirect
- ✅ **Better UX** - Native Google/Apple UI
- ✅ **Faster** - Direct token exchange
- ✅ **More secure** - No deep link vulnerabilities
- ✅ **Recommended by Supabase** - Official approach

### Main App Initialization (lib/main.dart)

```dart
// Initialize Supabase with deep link handling
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);
```

## Security Notes

1. **Never commit OAuth secrets to git**
   - Keep `.env` file in `.gitignore`
   - Store secrets in environment variables

2. **Use PKCE flow for mobile**
   - ✅ Already configured
   - More secure than implicit flow

3. **Validate redirect URLs**
   - Only allow your app's custom scheme
   - Prevent open redirect vulnerabilities

## Next Steps

1. ✅ Deep link configuration complete
2. ⚠️ Configure Google OAuth in Google Cloud Console
3. ⚠️ Configure Apple Sign In in Apple Developer Console
4. ⚠️ Add redirect URLs in Supabase Dashboard
5. ⚠️ Test on real devices (iOS and Android)

## Status

- ✅ Deep links configured (iOS & Android)
- ✅ Supabase PKCE flow enabled
- ✅ OAuth methods updated
- ⚠️ Requires OAuth provider configuration
- ⚠️ Requires Supabase redirect URL configuration

