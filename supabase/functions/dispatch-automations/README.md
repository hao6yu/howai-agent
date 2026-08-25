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

Automation model calls use an independent `automation` usage-ledger route.
They still count toward the paid-user and project-wide budgets, but cannot
silently exhaust the interactive Research allowance (or be blocked by it).
The default `AUTOMATION_MODEL` is `gpt-5.6-luna`; paid interactive chat remains
on Sol while recurring background work uses Luna plus an independent,
fail-closed verification pass.
The conservative defaults allow headroom for scheduled runs plus occasional
manual testing while the product-level limit remains two active Automations
per paid user and generated schedules remain capped at once per day.

Optional Automation policy limits:

```text
AUTOMATION_MODEL=gpt-5.6-luna
AUTOMATION_RESERVATION_MICROUSD=100000
AUTOMATION_DAILY_BUDGET_MICROUSD=2000000
AUTOMATION_MONTHLY_BUDGET_MICROUSD=40000000
OPENAI_PROXY_GLOBAL_DAILY_BUDGET_MICROUSD=10000000
OPENAI_PROXY_GLOBAL_MONTHLY_BUDGET_MICROUSD=150000000
```

Paid users have no separate aggregate user cost ceiling. Automation's own
route budget remains in force, along with the shared global safety ceilings.

Both verified reports and fail-closed/withheld outcomes are appended to the
conversation and Automation history. When push delivery is enabled, only a
completed, verified result sends a notification; diagnostic failures do not
interrupt the user with repeated push alerts.
