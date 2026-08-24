# Changelog

All notable changes and updates to the Bejeweled addon for World of Warcraft.

## [12.1.0] - 2026

- **Midnight Migration**: Updated TOC interface version for World of Warcraft: Midnight (12.1.0 / 120100).
- **Client Branches**: Split repository into dedicated branches for each active WoW client flavor (`master` / Retail, `mists`, `tbc`, `vanilla`, `wrath`, `cata`).
- **Single TOC & Lua**: Standardized addon structure to a single `Bejeweled.toc` and `Bejeweled.lua` per client branch.
- **Score Sync Fixes**: Fixed guild and friend high score synchronization by properly registering addon message prefixes (`BEJEWELED2` and `BEJ2a`).
- **UI Bug Fixes**:
  - High Scores panel now defaults to the Guild tab.
  - Fixed popup close buttons broken by template syntax.
  - Publish Scores button on the Game Over screen no longer disables after one click and includes helpful tooltips.
  - Fixed crash in dropdown menu when selecting Party/Raid/Custom channel for score bragging.
  - Prevented keyboard input from remaining trapped after keybind capture using `SetPropagateKeyboardInput(true)`.

## [11.0.2] - 2024

- Initial support for *The War Within* (Mainline).
- Updated interface versions for Cataclysm Classic and Classic Era.

## [10.0.5] - 2023

- Updated interface versions for *Dragonflight* (Mainline), *Wrath of the Lich King Classic*, and *Classic Era*.

## [10.0.2] - 2022

- Fixed window resizing issues (credit: `chrisliebaer`).

## [10.0.0] - 2022

- Modernized and updated to function with *World of Warcraft: Dragonflight* (Patch 10.0).

## [9.2.0] - 2022

- Updated to function with *World of Warcraft: Shadowlands* (Patch 9.2.0).

## [7.0.3] - 2016

- Upgraded to function with *World of Warcraft: Legion* (Patch 7.0.3).
- Version numbering adjusted to match WoW client interface versions.

## [1.1] - 2009

- **Score System Upgrade**: Migrated score data to a new format with enhanced guild and friend score broadcast.
- **Stats & Achievements**:
  - Renamed the "Personal" tab to "Stats" and added "Total Games Played" across all characters.
  - Added dedicated "Achievements" tab to the Feats of Skill window.
  - Adjusted achievement requirements and difficulty curves.
- **Gameplay & Flight Integration**:
  - Added default flight times for Northrend.
  - Fixed various edge cases with shape matches (L/T power gem vs hypercube creation).
  - Resolved conflicts with flight path addons and shape-shifted states.

## [1.03] - 2008

- Added "One score per person on high score lists" option.
- Fixed achievement triggers for combat damage, falling damage, and raid ready checks.
- Prevented game element state bleed-over between consecutive games.

## [1.02] - 2008

- Added `/bejeweled reset` slash command.
- Added option to toggle and detach the minimap button.

## [1.01] - 2008

- Improved addon communication bandwidth efficiency during score sync.
- Resolved flight auto-start logic edge cases.
- Fixed non-English client localization quirks.
