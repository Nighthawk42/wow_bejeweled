# Contributing to Bejeweled for World of Warcraft

Thank you for helping maintain and improve *Bejeweled for World of Warcraft*! This guide explains our multi-client branch architecture and workflow for contributing bug fixes, features, and compatibility updates.

---

## 🌿 Multi-Client Branch Architecture

Each active World of Warcraft client flavor is maintained in its own dedicated Git branch:

| Branch | Client Flavor | Interface Version | Purpose |
|---|---|---|---|
| [`mainline`](https://github.com/Nighthawk42/wow_bejeweled/tree/mainline) | **Retail / Mainline** | `120100`, `120001` | Default development branch (Midnight / Retail) |
| [`mists`](https://github.com/Nighthawk42/wow_bejeweled/tree/mists) | **Mists of Pandaria Classic** | `50504` | Classic Progression |
| [`tbc`](https://github.com/Nighthawk42/wow_bejeweled/tree/tbc) | **TBC Classic / Anniversary** | `20506`, `20505` | Classic Anniversary Edition |
| [`vanilla`](https://github.com/Nighthawk42/wow_bejeweled/tree/vanilla) | **Classic Era / Vanilla** | `11509`, `11508` | World of Warcraft Classic Era |
| [`wrath`](https://github.com/Nighthawk42/wow_bejeweled/tree/wrath) | **Wrath of the Lich King** | `38002`, `30405` | Titan Reforged / Wrath |
| [`cata`](https://github.com/Nighthawk42/wow_bejeweled/tree/cata) | **Cataclysm Classic** | `40402`, `40400` | Cataclysm Classic |
| [`archive`](https://github.com/Nighthawk42/wow_bejeweled/tree/archive) | *Historical* | N/A | Pre-branch snapshot of the legacy codebase |

---

## 🛠️ Development & Contribution Workflow

### 1. General Fixes & Features (Cross-Client)
- Most game logic, UI fixes, sound triggers, and score synchronization apply equally across all WoW flavors.
- **Workflow:**
  1. Base your feature or bug fix on `mainline`.
  2. Test in the game client (or simulation).
  3. Submit a Pull Request targeting `mainline`.
  4. Once merged into `mainline`, changes can be propagated (cherry-picked or rebased) to the flavor branches (`mists`, `tbc`, `vanilla`, etc.).

### 2. Flavor-Specific Fixes (API Differences)
- If an issue or feature only applies to a specific client version (e.g., legacy FrameXML APIs or modern UI deprecations):
  - Submit your Pull Request directly against that client's branch (e.g., `vanilla` or `mists`).
  - Note in the PR description why the change is flavor-specific.

### 3. TOC & Versioning Conventions
- **Single TOC & Lua File:** Each branch must only contain `Bejeweled.toc` and `Bejeweled.lua` inside the `Bejeweled/` directory. Do not introduce flavor suffixes (`Bejeweled_Mainline.*`, etc.).
- **TOC Interface Numbers:** Ensure `## Interface:` matches the latest patch interface value for that client flavor.
- **Version Strings:** Update the version in:
  - `Bejeweled.toc`: `## Version: X.Y.Z`
  - `Bejeweled.lua`: `Bejeweled.version = "Version X.Y.Z"` and default profile version.

---

## 📜 Licensing & Asset Attribution
- All new community contributions, bug fixes, and maintenance code are licensed under the **[MIT License](LICENSE)**.
- Original game design, art, sounds, and base code remain copyright **PopCap Games, Inc. / Electronic Arts**.
- Please credit any original ideas, patches, or third-party tools in [ACKNOWLEDGEMENT.md](ACKNOWLEDGEMENT.md).

---

## 🧪 Testing Guidelines
- Whenever possible, test changes live in-game on the appropriate client version before submitting a PR.
- Use a Lua error reporting addon (e.g., BugSack / BugGrabber) to ensure no silent errors or frame leaks occur during gameplay, score syncing, flight paths, or game transitions.
