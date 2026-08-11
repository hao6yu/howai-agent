# Changelog

## 2.0.3+48 — 2026-08-08

### Fixed

- Prevented photo-first conversations from returning to the new-chat screen
  during background synchronization.
- Prevented stale remote snapshots from deleting conversations uploaded while
  synchronization is in flight.
- Kept streamed chat requests active until completion and routed photo analysis
  through the complete-response path.

### Improved

- Reduced memory pressure from full-resolution pending-photo thumbnails.
- Added localized provisional titles for photo-only conversations.
- Made Edge Function release checks deterministic and Android release signing
  fail closed.
- Added focused regression coverage and a `2.0.3` release runbook.
