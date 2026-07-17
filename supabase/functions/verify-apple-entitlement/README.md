# Verify Apple entitlement

Authenticates a non-anonymous Supabase user, verifies a StoreKit 2 signed
transaction with Apple's official App Store Server Library, and caches the
result in `public.app_entitlements` for backend model routing.

The function verifies both Production and Sandbox transactions. Xcode local
StoreKit transactions are intentionally not accepted by the production
backend. Local UI testing can continue to use the app's debug premium toggle.

No App Store Connect private key is required for transaction verification.
The Apple root certificates are public and pinned in `_shared`.

Optional environment overrides:

- `APPLE_APP_BUNDLE_ID` (default `com.hyu.HaoGPT`)
- `APPLE_APP_ID` (default `6746110671`)
- `APPLE_SUBSCRIPTION_PRODUCT_IDS` (comma-separated)
- `APPLE_VERIFY_ONLINE_CHECKS` (default `false`; enables live certificate OCSP checks)

The function must retain JWT verification. It writes through the service-role
client; `app_entitlements` remains inaccessible to app clients.
