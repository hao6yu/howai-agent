# reminder-actions

JWT-protected M3 endpoint for reminder and recurring-reminder actions.

Supported operations:

- `capabilities`: returns whether reminders are enabled for the current account.
- `propose`: validates and stores a human-readable action proposal.
- `decide`: rejects a proposal or atomically executes an approved proposal.

The model never writes reminder rows directly. It can only draft a proposal;
the user must explicitly approve it before the service-only database RPC applies
the mutation. Authenticated users can read only their own action audit and
reminder rows through row-level security.
