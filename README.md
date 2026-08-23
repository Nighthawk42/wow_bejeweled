# Bejeweled modernization

This branch is an analysis-only bootstrap for a Mainline-first modernization of the legacy World of Warcraft Bejeweled addon. It is intentionally **not installable or playable**: there is no runtime TOC and no modernized Lua module yet.

## Status and phase gate

The preserved 8,401-line Mainline source must be analyzed sequentially, in evidence-backed batches, before runtime work begins. All behavior-critical shortened symbols must be resolved and all batches must be complete before any public Lua API, runtime module, modern TOC, packaging, or release work is added.

Batches 01–05 (lines 1–2,500) are documented. The remaining batches are scheduled but not analyzed.

## Goal

The eventual addon will target current Retail/Mainline World of Warcraft while preserving gameplay behavior and the `BejeweledData` and `BejeweledProfile` SavedVariables wire formats until complete analysis supports an explicit migration.

## Repository layout

- `Legacy/` — immutable Mainline Lua and TOC reference from source commit `6faec1c`.
- `Bejeweled/images/` — immutable legacy images and bundled font.
- `Bejeweled/sounds/` — immutable legacy sounds.
- `docs/analysis/` — sequential batch reports, identifier ledger, and exact coverage schedule.
- `docs/architecture.md` — future module ownership and data flow; not an implementation.
- `docs/api-baseline.md` — verified Retail API constraints for future implementation.
- `plan.md` — the bootstrap specification executed by the root commit.

## Contributing

Analysis contributions must proceed in schedule order and cite exact legacy line numbers. Record every shortened identifier by declaration and lexical scope, distinguish evidence from inference, retain unresolved names when proof is incomplete, and update the shared ledger with each batch. Do not edit preserved legacy code or assets.

Runtime contributions are premature until all 8,401 lines have been covered exactly once and behavior-critical symbols are resolved. Future Lua must remain Lua 5.1 compatible and must use current, verified Mainline APIs.

See `ACKNOWLEDGEMENT.md` for attribution and the boundary between preserved legacy material and newly authored MIT-licensed work.
