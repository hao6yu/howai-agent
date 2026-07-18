# HowAI OAuth runbook

Google and Apple sign-in use Supabase Auth with PKCE. On mobile, Supabase opens
the provider in the system browser and returns to:

```text
com.hyu.haogpt://login-callback
```

## Mobile client configuration

HowAI bundles its Supabase project URL and modern publishable key because both
are public mobile-client configuration. This keeps authentication available
when the app is launched directly from Xcode, Android Studio, or `flutter run`.
Provider credentials and service-role keys are never bundled.

Direct local runs are supported:

```bash
flutter run -d <device-id>
```

Use the checked-in wrapper when you need `.env` to override public values for
another Supabase project or to supply other public mobile configuration:

```bash
scripts/run-configured.sh -d <device-id>
```

VS Code's checked-in launch configurations already include the same define
file.

Release builds may use the same override file:

```bash
scripts/with-public-mobile-config.sh flutter build ios --release
scripts/with-public-mobile-config.sh flutter build appbundle --release
```

Only public mobile configuration belongs in `.env`. OpenAI, Apple, and other
server secrets stay in Supabase/provider secret storage.

## Canonical configuration

- iOS bundle ID: `com.hyu.HaoGPT`
- Android application ID: `com.hyu.haogpt`
- Mobile callback: `com.hyu.haogpt://login-callback`
- Supabase project ref: `yjxoreszkpdealtzyvyu`
- Provider callback: `https://yjxoreszkpdealtzyvyu.supabase.co/auth/v1/callback`
- Web redirect: `https://chat.howai.io`

Supabase Authentication > URL Configuration should allow both:

```text
com.hyu.haogpt://login-callback
com.hyu.haogpt://login-callback/
```

Google's Web OAuth client and the Apple Services ID both use the Supabase
provider callback above. Do not rotate provider credentials when neither
Google nor Apple opens; verify the resolved public client configuration first.

## Triage order

1. If **all** auth methods fail with a relative `/auth/v1/...` URI, confirm the
   bundled public fallback is present and no invalid Dart define overrides it.
2. If the browser never opens, inspect Flutter logs for `Could not open` and
   verify `AppConfig.supabaseUrl` resolves to a complete HTTPS URL.
3. If the provider page opens but errors, inspect Supabase Auth `/authorize`
   logs and that provider's configuration.
4. If provider login succeeds but HowAI does not resume, verify the mobile
   callback in Supabase and the platform deep-link registration.
5. If HowAI receives the callback but sign-in fails, inspect the PKCE `/token`
   exchange. Do not clear app data during the flow because it removes the code
   verifier.

Useful callback check after an iOS build:

```bash
plutil -p build/ios/iphoneos/Runner.app/Info.plist | rg -A8 CFBundleURLTypes
```

## Release smoke test

On a real iPhone:

1. Install over the currently released build.
2. Complete Google sign-in, then sign out.
3. Complete Apple sign-in, then force-quit and reopen.
4. Confirm the session persists and the correct account is shown.
5. Cancel each provider once and confirm the app remains usable.

Do not use a simulator-only Apple test as release sign-off.
