# Target architecture (post-analysis)

The analysis phase gate is satisfied. This ownership map now governs runtime implementation; currently implemented modules are `Core/Init.lua`, `Core/Constants.lua`, `Core/Audio.lua`, `Core/SavedVariables.lua`, `Engine/Grid.lua`, `Engine/Matches.lua`, `Engine/Cascade.lua`, and `Engine/Scoring.lua`.

## Load order and ownership

1. `Core/Init.lua` — addon namespace, lifecycle, and subsystem wiring.
2. `Core/Constants.lua` — stable enums, dimensions, atlas data, and configuration constants.
3. `Core/Audio.lua` — supported sound playback, legacy identifiers, frame-deferred cue coalescing, combo sequencing, quiet variants, and gem-click throttling. Window visibility is supplied as a predicate; audio owns no frames.
4. `Core/SavedVariables.lua` — defaulting, validation, and eventual proven migrations.
5. `Engine/Grid.lua` — deterministic grid representation, coordinates, swaps, and legal-move state.
6. `Engine/Matches.lua` — pure legacy-order match detection, axis-overlap reporting, and power/hyper-gem classification; clearing and scoring remain downstream responsibilities.
7. `Engine/Cascade.lua` — transactional clears, matched power-gem expansion, spawned-special preservation, fixed-cell gravity, bounded refill, and repeated transitions to a stable board. It emits logical movement/refill records but owns no animation or scoring.
8. `Engine/Scoring.lua` — legacy score arithmetic, combo/mode/level multipliers, wire-compatible statistics, probabilistic skill gains, one-time achievements, rank advancement, and pending/explicit level transitions. It emits presentation events and owns no frames, text, sound, or chat publishing.
9. `UI/Backdrops.lua` — backdrop-compatible frame construction and shared chrome.
10. `UI/GemPool.lua` — gem-frame allocation, reuse, and grid-to-frame projection.
11. `UI/Animations.lua` — animation groups, transition timing, and visual effect orchestration.
12. `UI/HUD.lua` — score, timer, level, status, hint, and achievement presentation.
13. `UI/Compartment.lua` — addon-compartment click and hover callbacks.

## Data flow

`SavedVariables initialization → engine-owned deterministic grid state → match/cascade/scoring transitions → UI rendering and animation → HUD/audio feedback`

The engine will own authoritative game state. UI frames will render state and report input; they will not become the source of gameplay truth. Audio and HUD reactions consume completed transitions.

## Compatibility boundary

`BejeweledData` and `BejeweledProfile` remain wire-compatible with the legacy snapshot until all analysis batches establish field meanings, invariants, defaults, and migration requirements. No migration schema exists in this phase.
