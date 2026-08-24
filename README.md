# Bejeweled modernization

This branch contains the analysis-complete, Mainline-first modernization of the legacy World of Warcraft Bejeweled addon. Its Retail TOC and headless runtime foundation are installable for development, but the addon is not yet playable because UI, match/cascade/scoring, animation, and input slices remain to be restored.

## Status and phase gate

The preserved 8,401-line Mainline source must be analyzed sequentially, in evidence-backed batches, before runtime work begins. All behavior-critical shortened symbols must be resolved and all batches must be complete before any public Lua API, runtime module, modern TOC, packaging, or release work is added.

All 17 batches (lines 1–8,401) are documented, the cross-batch identifier audit has no remaining `working` or `unresolved` declarations, and the retained Retail API contracts are pinned in `docs/api-baseline.md`. The analysis phase gate is closed. Runtime implementation has begun with wire-compatible SavedVariables initialization and an engine-owned deterministic 8×8 grid.

## Goal

The eventual addon will target current Retail/Mainline World of Warcraft while preserving gameplay behavior and the `BejeweledData` and `BejeweledProfile` SavedVariables wire formats until complete analysis supports an explicit migration.

## Repository layout

- `Legacy/` — immutable Mainline Lua and TOC reference from source commit `6faec1c`.
- `Bejeweled/images/` — immutable legacy images and bundled font.
- `Bejeweled/sounds/` — immutable legacy sounds.
- `Bejeweled/Core/` — private addon initialization, constants, and non-destructive SavedVariables defaulting.
- `Bejeweled/Engine/` — deterministic gameplay state; currently the 8×8 grid, swaps, legal moves, and legacy cell encoding.
- `docs/analysis/` — sequential batch reports, identifier ledger, and exact coverage schedule.
- `docs/architecture.md` — module ownership and authoritative runtime data flow.
- `docs/api-baseline.md` — verified Retail API constraints for implementation.
- `tools/test-runtime.lua` and `tools/verify-runtime.ps1` — Lua 5.1-compatible foundation tests and TOC verification.
- `plan.md` — the bootstrap specification executed by the root commit.

## Contributing

Runtime contributions must cite the completed legacy analysis, preserve the documented wire formats, remain Lua 5.1 compatible, and use current verified Mainline APIs. Keep engine state independent from UI frames and do not edit preserved legacy code or assets.

See `ACKNOWLEDGEMENT.md` for attribution and the boundary between preserved legacy material and newly authored MIT-licensed work.
