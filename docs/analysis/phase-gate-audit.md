# Analysis phase-gate audit

## Result

The analysis gate is closed for the immutable 8,401-line Mainline source.

- All 17 scheduled reports are complete and cover lines 1–8,401 exactly once.
- Every nonblank source line is represented by line-indexed coverage.
- The identifier ledger contains no `working` or `unresolved` declarations after the complete-file audit.
- Preserved source and assets remain governed by the byte-identity checks against commit `6faec1c`.
- Retail contracts needed to interpret the final external-result identifiers are pinned to build `12.1.0.69404`, Interface `120100`, in `docs/api-baseline.md`.

Statuses `dead` and `shadowed` remain intentional classifications, not open rename hypotheses. A `dead` declaration has no behavior-bearing consumer; a `shadowed` declaration is superseded before a relevant read.

## Cross-batch closure

The complete-file pass resolved the stale hypotheses left open by batch boundaries, including:

- atlas tables, texture dimensions, effect enums, animation states, and movement constants;
- match scan directions, neighbor patterns, clear/refill transitions, and effect lifecycles;
- animator attachment methods and callback parameter roles;
- score/floating-text fallbacks and accidental implicit globals;
- friend presence, battlefield status, ready-check intent, combat-log field roles, and arena-result fields.

The final external-result names are semantically resolved even where the Retail API must use a different extraction mechanism. Identifier resolution answers what the legacy value means; `docs/api-baseline.md` separately defines what a supported runtime adapter may consume.

## Runtime constraints carried forward

Runtime implementation must not reproduce legacy positional friend returns, combat-log event varargs, deprecated ready-check globals, or persistent arena-team membership calls. Combat-log-dependent skill triggers require a single compatibility adapter and in-client verification because the pinned generated documentation does not publish the variadic return schema.

The `BejeweledData` and `BejeweledProfile` wire formats remain frozen until an explicit, documented migration schema exists.
