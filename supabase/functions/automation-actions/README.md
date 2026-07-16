# automation-actions

JWT-protected M4.5 endpoint for generated briefing proposals.

Supported operations:

- `capabilities`: returns rollout and Pro eligibility.
- `propose`: strictly validates a News or Market briefing and stores a review proposal.
- `decide`: rejects it or atomically creates the approved Automation.

This slice creates definitions only. It does not schedule, retrieve, generate,
validate, or deliver briefing runs.
