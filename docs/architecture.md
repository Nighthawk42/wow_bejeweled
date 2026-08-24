# Target architecture (post-analysis)

The analysis phase gate is satisfied. This ownership map now governs runtime implementation; currently implemented modules are `Core/Init.lua`, `Core/Constants.lua`, `Core/Audio.lua`, `Core/SavedVariables.lua`, `Engine/Grid.lua`, `Engine/Matches.lua`, `Engine/Cascade.lua`, `Engine/Scoring.lua`, `Engine/Input.lua`, `Engine/Session.lua`, `UI/Backdrops.lua`, `UI/GemPool.lua`, and `UI/Animations.lua`.

## Load order and ownership

1. `Core/Init.lua` — addon namespace, lifecycle, and subsystem wiring.
2. `Core/Constants.lua` — stable enums, dimensions, atlas data, and configuration constants.
3. `Core/Audio.lua` — supported sound playback, legacy identifiers, frame-deferred cue coalescing, combo sequencing, quiet variants, and gem-click throttling. Window visibility is supplied as a predicate; audio owns no frames.
4. `Core/SavedVariables.lua` — defaulting, legacy base-70 score authentication, exact nine-row Classic save/restore encoding, validation, and eventual proven migrations.
5. `Engine/Grid.lua` — deterministic grid representation, coordinates, swaps, and legal-move state.
6. `Engine/Matches.lua` — pure legacy-order match detection, axis-overlap reporting, and power/hyper-gem classification; clearing and scoring remain downstream responsibilities.
7. `Engine/Cascade.lua` — transactional clears, matched power-gem expansion, target-color and double-hyper activation, spawned-special preservation, fixed-cell gravity, bounded refill, and repeated transitions to a stable board. It emits immutable award, lightning-link, movement, and refill records but owns no animation or scoring.
8. `Engine/Scoring.lua` — legacy score arithmetic, combo/mode/level multipliers, wire-compatible statistics, probabilistic skill gains, one-time achievements, rank advancement, and pending/explicit level transitions. It emits presentation events and owns no frames, text, sound, or chat publishing.
9. `Engine/Input.lua` — authoritative selection and move coordination, optimistic adjacent swaps, match validation, immediate engine rollback for invalid moves, legacy hyper activation, move accounting, cascade/scoring handoff, pause gating, and session/presentation locking.
10. `Engine/Session.lua` — Classic session lifetime, pause/resume state, elapsed-time gating, stable-state autosave, authenticated restore, and coordination between input, scoring, persistence, grid projection, and animation clocks. It exclusively consumes pending scoring levels after a stable move, emits copied start/complete presentation records, retains the input lock while presentation is deferred, advances level arithmetic on completion, and only then autosaves. Game-over transitions remain follow-on session work.
11. `UI/Backdrops.lua` — backdrop-compatible frame construction and fresh-copy presets for tooltip, window, panel, slider, and level-border chrome. Every constructed frame explicitly inherits `BackdropTemplate`.
12. `UI/GemPool.lua` — fixed allocation and reuse of the 64 interactive gem frames, the sixteen board-art tiles, input-handler attachment, selection projection, and change-aware projection from authoritative grid cells into normal/hyper texture layers. Power-gem overlays remain `UI/Animations.lua` ownership.
13. `UI/Animations.lua` — deterministic swap/rollback and clear/gravity/refill plans, reusable animation groups, session-controlled pause/resume, interaction locking, cancellation, and final-grid normalization. It also owns the legacy-cadence 40-frame hyper atlas, counter-rotating/cross-faded power layers, pooled 16-frame explosion atlas, and pooled 15-tick lightning lines that gate settling. Shards, lightwaves, hint bounce, and floating text remain follow-on presentation work; current fall timings are explicit modernization defaults pending in-game tuning.
14. `UI/HUD.lua` — score, timer, level, status, hint, and achievement presentation.
15. `UI/Compartment.lua` — addon-compartment click and hover callbacks.

## Data flow

`SavedVariables initialization/restore → session-owned lifetime → engine-owned deterministic grid state → input/match/cascade/scoring transitions → UI rendering and animation → session-owned level/game-over gates → stable-state autosave and HUD/audio feedback`

The engine will own authoritative game state. UI frames will render state and report input; they will not become the source of gameplay truth. Audio and HUD reactions consume completed transitions.

## Compatibility boundary

`BejeweledData` and `BejeweledProfile` remain wire-compatible with the legacy snapshot until all analysis batches establish field meanings, invariants, defaults, and migration requirements. No migration schema exists in this phase.
