# Target architecture (post-analysis)

The analysis phase gate is satisfied. This ownership map now governs runtime implementation; currently implemented modules are `Core/Init.lua`, `Core/Constants.lua`, `Core/Audio.lua`, `Core/SavedVariables.lua`, `Engine/Grid.lua`, `Engine/Matches.lua`, `Engine/Cascade.lua`, `Engine/Scoring.lua`, `Engine/Input.lua`, `UI/Backdrops.lua`, `UI/GemPool.lua`, and `UI/Animations.lua`.

## Load order and ownership

1. `Core/Init.lua` — addon namespace, lifecycle, and subsystem wiring.
2. `Core/Constants.lua` — stable enums, dimensions, atlas data, and configuration constants.
3. `Core/Audio.lua` — supported sound playback, legacy identifiers, frame-deferred cue coalescing, combo sequencing, quiet variants, and gem-click throttling. Window visibility is supplied as a predicate; audio owns no frames.
4. `Core/SavedVariables.lua` — defaulting, validation, and eventual proven migrations.
5. `Engine/Grid.lua` — deterministic grid representation, coordinates, swaps, and legal-move state.
6. `Engine/Matches.lua` — pure legacy-order match detection, axis-overlap reporting, and power/hyper-gem classification; clearing and scoring remain downstream responsibilities.
7. `Engine/Cascade.lua` — transactional clears, matched power-gem expansion, spawned-special preservation, fixed-cell gravity, bounded refill, and repeated transitions to a stable board. It emits logical movement/refill records but owns no animation or scoring.
8. `Engine/Scoring.lua` — legacy score arithmetic, combo/mode/level multipliers, wire-compatible statistics, probabilistic skill gains, one-time achievements, rank advancement, and pending/explicit level transitions. It emits presentation events and owns no frames, text, sound, or chat publishing.
9. `Engine/Input.lua` — authoritative selection and move-session coordination, optimistic adjacent swaps, match validation, immediate engine rollback for invalid moves, move accounting, cascade/scoring handoff, and presentation locking. Hyper activation, pause/resume, levels, restore, and game-over remain follow-on session work.
10. `UI/Backdrops.lua` — backdrop-compatible frame construction and fresh-copy presets for tooltip, window, panel, slider, and level-border chrome. Every constructed frame explicitly inherits `BackdropTemplate`.
11. `UI/GemPool.lua` — fixed allocation and reuse of the 64 interactive gem frames, the sixteen board-art tiles, input-handler attachment, selection projection, and change-aware projection from authoritative grid cells into normal/hyper texture layers. Power-gem overlays remain `UI/Animations.lua` ownership.
12. `UI/Animations.lua` — deterministic swap/rollback and clear/gravity/refill plans, reusable animation groups, interaction locking, cancellation, and final-grid normalization. It also owns the legacy-cadence 40-frame hyper atlas, counter-rotating/cross-faded power layers, pooled 16-frame explosion atlas, and explosion phase barrier. Shards, lightwaves/lightning, hint bounce, and floating text remain follow-on presentation work; current fall timings are explicit modernization defaults pending in-game tuning.
13. `UI/HUD.lua` — score, timer, level, status, hint, and achievement presentation.
14. `UI/Compartment.lua` — addon-compartment click and hover callbacks.

## Data flow

`SavedVariables initialization → engine-owned deterministic grid state → input/match/cascade/scoring transitions → UI rendering and animation → HUD/audio feedback`

The engine will own authoritative game state. UI frames will render state and report input; they will not become the source of gameplay truth. Audio and HUD reactions consume completed transitions.

## Compatibility boundary

`BejeweledData` and `BejeweledProfile` remain wire-compatible with the legacy snapshot until all analysis batches establish field meanings, invariants, defaults, and migration requirements. No migration schema exists in this phase.
