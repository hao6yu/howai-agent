# M4.6 Places and Maps refactor

Status: Planned after M4.5
Date: 2026-07-16

## Decision

Places and Maps remain part of HowAI 2.0, but their structural and visual
redesign is scheduled as M4.6 rather than being folded into M4.1 or M4.5.

The current `lib/widgets/place_result_widget.dart` is more than 7,000 lines and
combines result presentation, carousel and list layouts, map state, directions,
place details, reviews, Street View, sharing, and several modal surfaces. A
broad restyle without first separating those responsibilities would create a
large regression surface and distract from the M4.5 Automations foundation.

## Product objective

Make Places feel like a native part of the clean HowAI interface in light and
dark mode while preserving the behavior users already rely on. The experience
should be compact, readable, responsive, accessible, and consistent from a
place result in Chat through map, details, directions, and supporting sheets.

## Scope

- Turn the current widget into a thin coordinator with extracted state and
  presentation components.
- Separate result cards, result carousel, full list, map, place details,
  navigation options, reviews, Street View, sharing, and supporting sheets.
- Apply the shared semantic color, typography, spacing, app-bar, button,
  dialog, and bottom-sheet systems in both themes.
- Use compact responsive cards that prioritize the place name, category,
  distance, rating, availability, and the next useful action.
- Provide intentional loading, empty, partial-result, offline, permission
  denied, provider failure, and retry states.
- Preserve localization, large text, screen-reader labels, keyboard access,
  and minimum touch targets.
- Keep map/list state, selected place, filters, and navigation handoff stable
  while moving between surfaces.

Likely component boundaries include:

- `place_result_card`
- `places_result_carousel`
- `places_list_screen`
- `places_map_screen`
- `place_details_sheet`
- `navigation_options_sheet`
- `place_reviews_sheet`
- `place_street_view_sheet`
- a shared Places controller/state layer and provider adapters

The final names may change to match the repository structure; the separation of
responsibilities is the requirement.

## Non-goals

- Replacing the current map or Places provider.
- Adding itinerary generation or calendar export.
- Adding new third-party connectors.
- Rewriting the Places backend or changing existing public response contracts
  unless a compatibility defect requires it.

## Implementation slices

1. Add characterization tests and document the existing interaction/state
   boundaries before moving code.
2. Extract pure result-card, carousel, list, and shared formatting components
   without visual or behavioral changes.
3. Extract map, details, navigation, reviews, Street View, sharing, and modal
   flows behind explicit inputs and callbacks.
4. Apply the M4.1 semantic visual system and complete all transient, permission,
   and failure states in light and dark mode.
5. Run simulator and physical-device regression passes, remove obsolete paths,
   and capture final screenshots and accessibility checks.

## Exit criteria

- The original oversized widget is a thin coordinator rather than the owner of
  every Places behavior.
- Existing result, selection, map/list, details, directions, reviews, Street
  View, sharing, and deep-link behavior passes regression tests.
- Light and dark mode, large text, smallest supported phone, and screen-reader
  checks pass without clipping or unreachable controls.
- Location permission denial, unavailable location, empty results, provider
  errors, offline behavior, and retry behavior are understandable and usable.
- Navigation handoff and external map links still work on supported platforms.
- No new provider credentials, backend migration, or store configuration is
  required for the refactor.

## Ordering

M4.5 Automations is implemented first. M4.6 begins after its foundational data,
worker, approval, run-history, and notification paths are stable. M5 Realtime
voice follows M4.6 unless a later product decision explicitly allows the two
workstreams to proceed independently.
