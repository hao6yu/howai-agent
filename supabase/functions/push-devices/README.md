# push-devices

JWT-protected registration boundary for Firebase Cloud Messaging tokens.

- Signed-in, non-anonymous accounts only.
- Internal/full rollout is controlled by `feature_flags.push_notifications`.
- Tokens are private service-role data and never returned to clients.
- Registration atomically transfers a rotated FCM token to the current user.
