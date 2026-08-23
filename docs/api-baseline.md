# Retail API baseline

The modernization baseline is the authoritative WoW API source snapshot for live build `12.1.0.69404`, Interface `120100`. These constraints apply to future runtime work; this branch contains no runtime implementation.

| Area | Verified constraint | Future use |
| --- | --- | --- |
| Backdrops | Frames that call backdrop methods must inherit `BackdropTemplate`. | `UI/Backdrops.lua` will create compatible frames before calling `SetBackdrop` or related methods. |
| Timers | `C_Timer.After` and `C_Timer.NewTicker` are the supported timer primitives. | Replace legacy polling/on-update timing only after behavior-equivalence analysis. |
| Addon sounds | `PlaySoundFile` continues to support addon-owned paths. Obsolete Blizzard-internal paths are not stable. | Preserve addon media paths; replace internal Blizzard paths with supported SoundKit or FileDataID references after call-site analysis. |
| Metadata | Addon metadata access is provided by `C_AddOns`. | Route future metadata queries through `C_AddOns`. |
| Animation | Frames expose `CreateAnimationGroup`, and groups expose `CreateAnimation`. | Prefer animation objects where their timing and cancellation behavior matches the legacy contract. |
| Addon compartment | Click uses `func(addonName, buttonName, menuButtonFrame)`; hover uses `funcOnEnter(addonName, menuButtonFrame)` and `funcOnLeave(addonName, menuButtonFrame)`. | `UI/Compartment.lua` will implement those distinct current contracts without assuming one shared parameter list. |

API existence alone does not prove behavioral equivalence. Each future substitution must cite the legacy call site, arguments, return values, timing assumptions, and the authoritative current API contract before implementation.
