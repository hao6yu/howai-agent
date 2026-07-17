# dispatch-reminders

Minute-level reminder delivery worker invoked by Supabase Cron.

Required secrets:

- `REMINDER_DISPATCH_SECRET`
- `FIREBASE_SERVICE_ACCOUNT_JSON`

The worker atomically claims occurrence records, sends through FCM HTTP v1,
records per-device attempts, disables unregistered tokens, retries transient
provider failures, and advances recurring reminders only after finalization.
