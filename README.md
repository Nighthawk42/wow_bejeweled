# Bejeweled modernization

This branch contains the analysis-complete, Mainline-first modernization of the legacy World of Warcraft Bejeweled addon. Its Retail TOC and headless runtime foundation are installable for development, but the addon is not yet playable because the remaining effects, HUD, and menu integration still need to be restored.

## Status and phase gate

The preserved 8,401-line Mainline source must be analyzed sequentially, in evidence-backed batches, before runtime work begins. All behavior-critical shortened symbols must be resolved and all batches must be complete before any public Lua API, runtime module, modern TOC, packaging, or release work is added.

All 17 batches (lines 1–8,401) are documented, the cross-batch identifier audit has no remaining `working` or `unresolved` declarations, and the retained Retail API contracts are pinned in `docs/api-baseline.md`. The analysis phase gate is closed. Runtime implementation now includes wire-compatible SavedVariables initialization, authenticated Classic restoration and personal-best persistence, deterministic grid/match/cascade/scoring transitions, pause/resume and stable-state autosave coordination, session-owned level/game-over handoffs, no-move and timed-expiry detection, click selection, validated swap/rollback sessions, skills, levels, legacy-compatible audio cue scheduling, BackdropTemplate-safe UI chrome, persistent grid-to-gem texture projection, cancellable cascade sequencing, power/hyper presentation, and pooled explosion/lightning playback.

## Goal

The eventual addon will target current Retail/Mainline World of Warcraft while preserving gameplay behavior and the `BejeweledData` and `BejeweledProfile` SavedVariables wire formats until complete analysis supports an explicit migration.

## Repository layout

- `Legacy/` — immutable Mainline Lua and TOC reference from source commit `6faec1c`.
- `Bejeweled/images/` — immutable legacy images and bundled font.
- `Bejeweled/sounds/` — immutable legacy sounds.
- `Bejeweled/Core/` — private addon initialization, constants, supported audio playback, non-destructive SavedVariables defaulting, legacy-authenticated Classic save encoding, terminal save clearing, account game counts, and authenticated personal bests.
- `Bejeweled/Engine/` — deterministic gameplay state; currently the 8×8 grid, selection/swap and pause/resume sessions, authenticated restoration, session-locked level/game-over transitions, legal moves, legacy cell encoding, stable cascade resolution, legacy score formulas, move accounting, final summary metrics, statistics, skill gains, achievements, and level thresholds.
- `Bejeweled/UI/` — Retail-safe frame/rendering boundaries; currently shared backdrop construction, board tiles, persistent gem-frame projection, and recorded cascade-transition playback.
- `docs/analysis/` — sequential batch reports, identifier ledger, and exact coverage schedule.
- `docs/architecture.md` — module ownership and authoritative runtime data flow.
- `docs/api-baseline.md` — verified Retail API constraints for implementation.
- `docs/mainline-integration.md` — safe migration gate for the dedicated-client repository restructure.
- `tools/test-runtime.lua` and `tools/verify-runtime.ps1` — Lua 5.1-compatible engine tests and TOC verification.
- `plan.md` — the bootstrap specification executed by the root commit.
- `todo.md` — the running implementation roadmap and completed runtime slices.

## Contributing

Runtime contributions must cite the completed legacy analysis, preserve the documented wire formats, remain Lua 5.1 compatible, and use current verified Mainline APIs. Keep engine state independent from UI frames and do not edit preserved legacy code or assets.

See `ACKNOWLEDGEMENT.md` for attribution and the boundary between preserved legacy material and newly authored MIT-licensed work.
