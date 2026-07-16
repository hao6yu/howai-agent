# dispatch-automations

Internal Cron worker for M4.5 conversational Automations.

Each tick claims at most two due occurrences, reserves metered OpenAI usage,
generates a live-web briefing, runs a separate fail-closed verification pass,
and atomically appends the approved result to the Automation's conversation.
Push delivery is a separate retryable step; its payload deep-links to the saved
conversation and message. Market Automations stay unclaimed until the separate
structured-market-data feature flag is enabled.

The endpoint has no public JWT surface. It requires the constant-time checked
`x-howai-cron-secret` value stored as `REMINDER_DISPATCH_SECRET`.
