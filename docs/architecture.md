# Target architecture (post-analysis)

This document records intended ownership only. It does not authorize runtime implementation before the analysis phase gate is satisfied.

## Load order and ownership

1. `Core/Init.lua` — addon namespace, lifecycle, and subsystem wiring.
2. `Core/Constants.lua` — stable enums, dimensions, atlas data, and configuration constants.
3. `Core/Audio.lua` — supported sound playback and sound identifiers.
4. `Core/SavedVariables.lua` — defaulting, validation, and eventual proven migrations.
5. `Engine/Grid.lua` — deterministic grid representation, coordinates, swaps, and legal-move state.
6. `Engine/Matches.lua` — match detection and special-gem classification.
7. `Engine/Cascade.lua` — clears, gravity, refill, and cascade transitions.
8. `Engine/Scoring.lua` — score, level, multiplier, skill, and achievement transitions.
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
