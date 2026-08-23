# Shortened identifier ledger

Each row identifies one declaration, not merely one spelling. `chunk` means the outer lexical scope of `Legacy/Bejeweled_Mainline.lua`; narrower scopes are named explicitly. Working names are hypotheses unless status is `resolved`. Batch 01 spans lines 1–500, so later-use claims remain open until their scheduled batch is analyzed.

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `t` / chunk (first binding) | 4 | String initializer only before shadow at 186. | `addonRootPath` | dead | High: path literal at 4; no read before 186. | 01–01 | Core/Constants | Was elimination intentional? |
| `l` / chunk | 5 | Image/font root used for bundled fonts and attempted legal-popup background path (5, 618, 633, 1664). | `imageRootPath` | resolved | High: literal and direct asset-path consumers. | 01–04 | Core/Constants | Other consumers remain to inventory. |
| `ut` / chunk | 6 | Path initializer; no batch-01 read. | `soundRootPath` | working | High: literal ends in `sounds\` (6). | 01–01 | Core/Audio | Confirm path casing/contracts. |
| `xe` / chunk | 7 | Starts as `BEJEWELED2`; migration may change it to `BEJ2a` (3563), and network factory registers it alongside literal `BEJ2a` (4972–4973). | `addonMessagePrefix` | resolved | High. | 01–10 | Core/Init, Persistence/Migration, Network | Preserve dual registration. |
| `ft` / chunk | 8 | Seven-entry colored/name table; no batch-01 read. | `gemDisplayNames` | working | Medium: ordered color names (8). | 01–01 | UI/HUD | Confirm indices and markup purpose. |
| `he` / chunk | 169 | Nine RGB triples; initialized only in batch 01. | `gemColors` | working | Medium: values mirror seven gem colors plus two white entries (169–179). | 01–01 | Core/Constants | Determine meanings of indices 8–9. |
| `U` / chunk | 180 | Numeric keys 1–7 map to lowercase color names. | `gemColorNames` | working | High: complete table at 180. | 01–01 | Core/Constants | Confirm use in asset filenames. |
| `F` / chunk | 181 | Generated as 25 atlas rectangles, copied into `J`, and `F[1]` resets gem texture coordinates (199–208, 1969). | `gemAtlasRects` | working | High for gem consumer; atlas asset/other frames pending. | 01–04 | UI/GemPool, UI/Animations | Identify texture and off-by-one rationale. |
| `N` / chunk | 182 | Written as nine UV rectangles in a 3×3 loop (218–222). | `atlas3x3Rects` | working | High for shape: indices and 42.66/128 math. | 01–01 | UI/Animations | Identify texture/effect frames. |
| `J` / chunk | 183 | Receives copies of all `F` rectangles via `unpack` (204–208). | `mutableAtlas50Rects` | working | Medium: copy semantics are explicit. | 01–01 | UI/Animations | Why is a second copy required? |
| `O` / chunk | 184 | Written at 50 numeric indices using 10×5 normalized UV cells (188–198). | `atlas10x5Rects` | working | High for shape, medium for texture. | 01–01 | UI/Animations | Identify owning texture. |
| `ie` / chunk | 185 | Written at 16 indices using a 4×4 UV grid (211–217). | `atlas4x4Rects` | working | High for shape, medium for texture. | 01–01 | UI/Animations | Identify owning texture. |
| `t` / chunk (second binding) | 186 | Declared nil, then shadowed again at 263; no read. | — | dead | High: no assignment/read before shadow. | 01–01 | Unassigned | Minifier artifact? |
| `i` / chunk | 186 | Atlas scratch indexes `F`,`J`,`ie` (187–216); animator factory later reuses the captured binding for rotation angle radians (4939–4941). | `atlasOrAngleScratch` | resolved | High: both temporal roles explicit. | 01–10 | UI/Animations | Split roles in rewrite. |
| `e` / first atlas loop | 188 | Loop values 0–4; multiplies row offsets and indices (189–203). | `row` | resolved | High: numeric-for and row arithmetic (188–203). | 01–01 | UI/Animations | None for this scope. |
| `e` / second atlas loop | 211 | Loop values 0–3; computes vertical quarters (212–215). | `row` | resolved | High: loop and `/4` UV math (211–215). | 01–01 | UI/Animations | None for this scope. |
| `e` / third atlas loop | 218 | Loop values 0–2; computes 3×3 indices/UVs (219–221). | `row` | resolved | High: loop and `*3`/`.33` math (218–221). | 01–01 | UI/Animations | Exact `.33` edge behavior later. |
| `K` / chunk | 227 | Starts at zero; accumulates every value in `BejeweledData.played` during achievement setup (1397–1399). | `totalGamesAcrossCharacters` | resolved | High: direct account-data sum. | 01–03 | Core/SavedVariables | Not reset before summing; assess repeat calls. |
| `Ye` / chunk | 228 | Constant `24`; halved into `pt` (285). | unknown dimension | unresolved | Low: declaration/arithmetic only. | 01–01 | UI/GemPool | Which axis/object? |
| `Ze` / chunk | 229 | Constant `24`; halved into `ct` (286), then shadowed by command function at 3619. | unknown dimension | unresolved | Low: declaration/arithmetic only. | 01–08 | UI/GemPool | Which axis/object? |
| `b` / chunk | 230 | Constant `50`; halved into `ce`; multiplies horizontal match-length offset (283, 1013). | `gemWidth` | resolved | High: direct X-coordinate geometry. | 01–03 | UI/GemPool | None. |
| `p` / chunk | 231 | Constant `50`; copied/halved; multiplies vertical match-length offset (272, 274, 284, 1014). | `gemHeight` | resolved | High: direct Y-coordinate geometry. | 01–03 | UI/GemPool | None. |
| `lt` / chunk | 232 | Constant expression `70 + 20`; no batch-01 read. | unknown 90-pixel dimension | unresolved | Low: declaration only. | 01–01 | UI | Locate consumers. |
| `Ue` / chunk | 233 | Constant expression `70 + 20`; no batch-01 read. | unknown 90-pixel dimension | unresolved | Low: declaration only. | 01–01 | UI | Paired with `lt`? |
| `Qe` / chunk | 234 | Constant expression `100 + 50`; halved by dead `t` at 287. | unknown 150-pixel dimension | unresolved | Low: declaration and dead derivation. | 01–01 | UI | Locate live consumer. |
| `qe` / chunk | 235 | Constant expression `100 + 50`; halved by dead `t` at 288. | unknown 150-pixel dimension | unresolved | Low: declaration and dead derivation. | 01–01 | UI | Locate live consumer. |
| `s` / chunk | 236 | Constant `400`; used in `q = s + 32 + 16` (238). | board width | working | Medium: 8 × likely 50-pixel cells. | 01–01 | Engine/Grid, UI/GemPool | Confirm coordinate ownership. |
| `w` / chunk | 237 | Constant `400`; used in `me = w + 110` (239). | board height | working | Medium: paired with `s`. | 01–01 | Engine/Grid, UI/GemPool | Confirm coordinate ownership. |
| `q` / chunk | 238 | Derived `448`; assigned main-window width by legal display (1651). | `mainWindowWidth` | resolved | High: direct frame geometry. | 01–04 | UI/HUD | Padding derivation rationale remains. |
| `me` / chunk | 239 | Derived `510`; assigned main-window height by legal display (1652). | `mainWindowHeight` | resolved | High: direct frame geometry. | 01–04 | UI/HUD | Padding derivation rationale remains. |
| `f` / chunk | 240 | Constant `160`; legal popup width is `f×2` and text width `f×1.8` (1658, 1676). | `legalPopupHalfWidth` | resolved | High: direct geometry use. | 01–04 | UI/HUD | Name reflects legacy arithmetic. |
| `L` / chunk | 241 | Constant `216`; legal popup height is `L+32` (1659). | `legalPopupContentHeight` | resolved | High: direct geometry use. | 01–04 | UI/HUD | None. |
| `Je` / chunk | 242 | Constant `10`; halved into `gt` (290). | unknown dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `E` / chunk | 243 | Receives `math.random`, copied to `m`, then nilled; later read as the nil reset value for `gem.fxType` (307–308, 1972). | `nilFxType` after temporary alias | resolved | High: temporal value flow is explicit. | 01–04 | UI/Animations | Preserve nil reset without retaining alias indirection. |
| `S` / chunk | 244 | Constant `-1`; assigned to hidden hint object's `fxType` during level-up reset (527). | `inactiveHintFxType` | working | Medium: reset/hide sequence (526–527). | 01–02 | UI/Animations | Confirm animator interpretation. |
| `y` / chunk | 245 | Constant `1`; assigned to non-hyper gems' effect type during board transition (1990–1992). | `gameOverGemFxType` | working | Medium: function incomplete. | 01–04 | UI/Animations | Complete `Ke` dispatcher evidence. |
| `Lt` / chunk | 246 | Constant `20`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `ye` / chunk | 247 | Constant `3`; no batch-01 read. | unknown enum three | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `ve` / chunk | 248 | Constant `360`; no batch-01 read. | likely angle/full rotation | working | Low: value only. | 01–01 | UI/Animations | Confirm angular use. |
| `Oe` / chunk | 249 | Constant `4`; no batch-01 read. | unknown enum four | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `bt` / chunk | 250 | Constant `16`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `He` / chunk | 251 | Constant `5`; no batch-01 read. | unknown enum five | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Xe` / chunk | 252 | Constant `12`; no batch-01 read. | unknown enum twelve | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `A` / chunk | 253 | Effect enum `6`; in clear phase dispatches score/power/hyper/big-star work (4404–4522), then is shadowed by animator factory at 4922. | `FX_CLEAR_WORK` | resolved | High. | 01–10 | UI/Animator, Engine/Matches | Preserve numeric wire/state value. |
| `se` / chunk | 254 | Constant `4`; no batch-01 read. | unknown enum four | unresolved | Low. | 01–01 | Engine | Distinguish from `Oe`. |
| `je` / chunk | 255 | Constant `7`; no batch-01 read. | unknown enum seven | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `it` / chunk | 256 | Assigned `#FX_SHINE_ALPHA` (=6). | shine alpha count | working | High: direct length operation (223, 256). | 01–01 | UI/Animations | Confirm later iteration contract. |
| `ke` / chunk | 257 | Constant `8`; no batch-01 read. | unknown enum eight | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Re` / chunk | 258 | Assigned `#FX_SHINE_ALPHA` (=6), duplicating `it`. | shine alpha count alias | working | High for value, low for distinct role (223, 258). | 01–01 | UI/Animations | Why two aliases? |
| `g` / chunk | 259 | Constant `9`; compared with gem effect type to identify hyper-specific cleanup (1990–1995). | `hyperGemFxType` | working | Medium: transition evidence. | 01–04 | UI/Animations | Confirm general dispatcher meaning. |
| `mt` / chunk | 260 | Constant `40`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `te` / chunk | 261 | Constant `10`; assigned to all multiplier floating-text objects (513, 518). | `multiplierTextFxType` | working | High for observed role; enum ownership pending. | 01–02 | UI/Animations | Find effect dispatcher branch. |
| `be` / chunk | 262 | Constant `10`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Distinguish from `te`. |
| `t` / chunk (line 263) | 263 | Constant `11`; shadowed at 273. | unknown enum eleven | shadowed | Low: declaration only. | 01–01 | Engine | Was any lexical read optimized away? |
| `Ve` / chunk | 264 | Constant `12`; no batch-01 read. | unknown enum twelve | unresolved | Low. | 01–01 | Engine | Distinguish from `Xe`. |
| `yt` / chunk | 265 | Constant `25`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `De` / chunk | 266 | Constant `13`; no batch-01 read. | unknown enum thirteen | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `We` / chunk | 267 | Constant `14`; no batch-01 read. | unknown enum fourteen | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Rt` / chunk | 268 | Constant `15`; no batch-01 read. | unknown enum fifteen | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `re` / chunk (function binding) | 269 | Receives `tonumber`, copied to `D` (319), overwritten with `40` (321). | temporary `tonumber` alias | shadowed | High: direct alias chain. | 01–01 | Core | None after `D` capture. |
| `z` / chunk (function binding) | 270 | Receives `type`, copied to `R` (320), overwritten with `7` (322). | temporary `type` alias | shadowed | High: direct alias chain. | 01–01 | Core | None after `R` capture. |
| `_e` / chunk | 271 | Constant `50`; no batch-01 read. | unknown 50 constant | unresolved | Low. | 01–01 | Unassigned | Distinguish from dimensions. |
| `ue` / chunk | 272 | Copies `p` (=50); no batch-01 read. | unknown height alias | unresolved | Low: copy only. | 01–01 | UI | Locate consumers. |
| `t` / chunk (line 273) | 273 | Constant `51`; shadowed at 274. | unknown enum 51 | shadowed | High that it is unreachable after next declaration. | 01–01 | Unassigned | Minifier artifact? |
| `t` / chunk (line 274) | 274 | Copies `p`; shadowed at 278. | unknown height alias | shadowed | High that it is unreachable after 278. | 01–01 | Unassigned | Minifier artifact? |
| `le` / chunk | 275 | Constant `51`; no batch-01 read. | unknown enum 51 | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `W` / chunk | 276 | Constant `52`; no batch-01 read. | unknown enum 52 | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `at` / chunk | 277 | Constant `53`; assigned to every gem's `moving` field before random-velocity animation (1997–1999). | `gameOverMovementState` | working | Medium: `Ke` incomplete. | 01–04 | UI/Animations | Identify movement-state dispatcher. |
| `t` / chunk (line 278) | 278 | Constant `16`; shadowed at 287. | unknown enum sixteen | shadowed | Low. | 01–01 | Engine | Locate any pre-287 read. |
| `Te` / chunk | 279 | Constant `20`; halved into `oe` (289). | unknown dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `et` / chunk | 280 | Constant `150`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `wt` / chunk | 281 | Constant `60`; no batch-01 read. | likely seconds/minute | working | Low: value only. | 01–01 | Engine/Scoring | Confirm time arithmetic. |
| `Gt` / chunk | 282 | Constant `10`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `ce` / chunk | 283 | Derived `gemWidth/2`; centers floating text on a gem for vertical/override paths (1014, 1018). | `halfGemWidth` | resolved | High: direct coordinate use. | 01–03 | UI/GemPool, UI/Animations | None. |
| `ne` / chunk | 284 | Derived `p / 2` (=25) and used as half-height in off-board refill geometry (3912–3914), then shadowed by countdown function at 4093. | `halfGemHeight` | resolved | High. | 01–09 | UI/GemPool, Engine/BoardSpawn | None. |
| `pt` / chunk | 285 | Derived `Ye / 2` (=12). | half unknown width | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `ct` / chunk | 286 | Derived `Ze / 2` (=12). | half unknown height | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `t` / chunk (line 287) | 287 | Derived `Qe / 2`; shadowed at 288. | — | dead | High: immediate shadow, no read. | 01–01 | Unassigned | Minifier artifact. |
| `t` / chunk (line 288) | 288 | Derived `qe / 2`; shadowed at 296. | — | dead | High: no read before shadow. | 01–01 | Unassigned | Minifier artifact. |
| `oe` / chunk | 289 | Derived `Te / 2` (=10). | half unknown dimension | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `gt` / chunk | 290 | Derived `Je / 2` (=5). | half unknown dimension | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `h` / chunk | 291 | Constant `8`; upper bound of inner column loop indexing `o[row][column]` (1276–1277). | `GRID_WIDTH` | resolved | High: direct grid traversal. | 01–03 | Engine/Grid | None. |
| `a` / chunk | 292 | Constant `8`; upper bound of outer row loop indexing `o[row][column]` (1275–1277). | `GRID_HEIGHT` | resolved | High: direct grid traversal. | 01–03 | Engine/Grid | None. |
| `V` / chunk | 293 | Animator idle status `0`, used by state transitions/update/factory (4145, 4177, 4192, 4326, 4937), then shadowed by network factory at 4971. | `ANIM_IDLE` | resolved | High. | 01–10 | UI/Animator | Preserve numeric state value. |
| `Pe` / chunk | 294 | Constant `1`; no batch-01 read. | unknown enum one | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Ct` / chunk | 295 | Constant `2`; no batch-01 read. | unknown enum two | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `t` / chunk (line 296) | 296 | Constant `3`; shadowed at 306. | unknown enum three | shadowed | Low. | 01–01 | Engine | Locate any pre-306 read. |
| `pe` / chunk | 297 | Constant `4`; no batch-01 read. | unknown enum four | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `ot` / chunk | 298 | Constant `5`; no batch-01 read. | unknown enum five | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Fe` / chunk | 299 | Constant `6`; no batch-01 read. | unknown enum six | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `nt` / chunk | 300 | Constant `1`; no batch-01 read. | unknown enum one | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Ne` / chunk | 301 | Constant `2`; no batch-01 read. | unknown enum two | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Ie` / chunk | 302 | Receives `string.byte`, copied to `j` (312), nilled (328). | temporary `string.byte` alias | dead | High: direct alias chain. | 01–01 | Core | None after `j` capture. |
| `Be` / chunk | 303 | Receives `string.char`, copied to `P` (313), nilled (329). | temporary `string.char` alias | dead | High. | 01–01 | Core | None after `P` capture. |
| `Ge` / chunk | 304 | Receives `string.sub`, copied to `G` (318), nilled (330). | temporary `string.sub` alias | dead | High. | 01–01 | Core | None after `G` capture. |
| `Ae` / chunk | 305 | Receives `math.floor`, copied to `d` (314), nilled (331). | temporary `math.floor` alias | dead | High. | 01–01 | Core | None after `d` capture. |
| `t` / chunk (line 306) | 306 | Receives `tostring`, copied to `Y` (317), nilled (332). | temporary `tostring` alias | dead | High. | 01–01 | Core | None after `Y` capture. |
| `m` / chunk | 307 | Copies `math.random`; called for randomized gem X/Y velocities (1998). | `random` | resolved | High: alias and calls. | 01–04 | Engine/Grid, UI/Animations | None. |
| `c` / chunk | 309 | Constant `1`; keys `Ce`; controls classic score/bar/results and pause alpha behavior (467, 500, 536, 611, 881, 1278–1352). | `GAME_MODE_CLASSIC` | resolved | High: repeated explicit classic behavior. | 01–03 | Core/Constants | None for identity. |
| `ae` / chunk | 310 | Constant `2`; keys `Ce`; pause handling shows/hides `pausedText` specifically for this mode (1299–1304). | `GAME_MODE_TIMED` | resolved | High: paired PPS evidence plus explicit pause UI. | 01–03 | Core/Constants | None for identity. |
| `k` / chunk | 311 | Constant `3`; keys `Ce`; controls flight-learning timer and pause/animator behavior (552, 639, 1278–1352). | `GAME_MODE_FLIGHT_LEARNING` | resolved | High: repeated explicit learning-mode branches. | 01–03 | Core/Constants | Broader flight-mode naming may refine. |
| `T` / chunk (score-table binding) | 312 | Nine-number array indexed by `n.combo`, capped at final entry (977–980); shadowed at 1266, while earlier `M` retains it lexically. | `comboBaseScores` | resolved | High: direct scoring use and capture. | 01–03 | Engine/Scoring | Confirm whether combo resets per move/cascade. |
| `Ce` / chunk | 312 | Mode-keyed values scale non-classic bar maximum and final match points (626, 1007). | `modeScoreMultiplier` | resolved | High: two direct arithmetic consumers. | 01–03 | Core/Constants | Same factor serves range and score scaling. |
| `j` / chunk (byte alias) | 312 | Copies `string.byte`; called by codec helpers (667, 720, 764), then shadowed by function at 769; earlier closures retain it. | `stringByte` | resolved | High: direct alias/calls and lexical capture. | 01–02 | Core/SavedVariables | None. |
| `P` / chunk (char alias) | 313 | Copies `string.char`; called inside encoder `x` (692, 694, 708), then shadowed by function at 735; `x` retains it. | `stringChar` | resolved | High: direct alias/calls and lexical capture. | 01–02 | Core/SavedVariables | None. |
| `d` / chunk | 314 | Copies `math.floor`; called for timer, codec, score popup, and flight-duration values (558, 564, 582, 677, 687, 698, 878–879, 900, 911, 933, 1023, 1366). | `floor` | resolved | High: direct alias and calls. | 01–03 | Core | None. |
| `u` / chunk | 315 | Receives `table.insert`; queues animations and event callbacks (457, 1425). | `tableInsert` | resolved | High: direct alias and calls. | 01–03 | Core | None. |
| `B` / chunk | 316 | Receives `table.remove`; consumes three front entries from flight path and removes completed event callbacks (1367–1369, 1413). | `tableRemove` | resolved | High: direct alias and calls. | 01–03 | Core | None. |
| `Y` / chunk | 317 | Copies `tostring`; converts decoded checksum/rank values (750, 890, 912). | `toString` | resolved | High: direct alias and calls. | 01–02 | Core | None. |
| `G` / chunk | 318 | Copies `string.sub`; slices checksum payloads, decimal digits, and rank prefixes (745–755, 777–778). | `stringSub` | resolved | High: direct alias and calls. | 01–02 | Core/SavedVariables | None. |
| `D` / chunk | 319 | Copies `tonumber`; parses checksum digits and rank prefixes (751–755, 777). | `toNumber` | resolved | High: direct alias and calls. | 01–02 | Core/SavedVariables | None. |
| `R` / chunk | 320 | Copies `type`; rejects non-string scores and identifies numeric gem fields during reset (742, 1955). | `valueType` | resolved | High: direct alias and calls. | 01–04 | Core/SavedVariables, UI/GemPool | None. |
| `re` / chunk (numeric overwrite) | 321 | Overwrites earlier binding with `40`; no batch-01 read. | unknown constant 40 | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `z` / chunk (numeric overwrite) | 322 | Overwrites earlier binding with `7`; no batch-01 read. | unknown enum seven | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `o` / chunk | 323 | Eight row tables initialized, exported as `debugArray`, and traversed as `o[row][column]` gem frames (324–326, 442, 1275–1293). | `gemGrid` | resolved | High: explicit 8×8 traversal. | 01–03 | Engine/Grid, UI/GemPool | Debug export naming is incidental. |
| `e` / debug-array loop | 324 | Loop 1–8; indexes `o` for writes (325). | `index` | resolved | High: direct loop role. | 01–01 | Core/Init | None. |
| `v` / chunk | 327 | Key for authenticated personal-best payloads in current-game/profile classic/timed stats (887, 900, 3490–3491, 3601–3613). | `statEncodedScoreKey` | working | High for role; concrete selected key pending. | 01–08 | Core/SavedVariables | Find mode-specific assignments. |
| `I` / chunk | 327 | Key for decoded numeric personal-best metrics in current-game/profile classic/timed stats (885–886, 898–899, 3603–3612). | `statNumericScoreKey` | working | High for role; concrete selected key pending. | 01–08 | Core/SavedVariables | Find mode-specific assignments. |
| `ge` / chunk | 327 | Forward declaration populated by `ze` with faction-selected four-region coordinate adjacency graphs (1040–1249). | `flightGraph` | resolved | High: complete assignment shape. | 01–03 | Core/SavedVariables | Region meanings/search consumers pending. |
| `we` / chunk | 327 | Set when max-score level-up begins (529); during level spawning it counts/removes carried hyper and big-star state for later restoration (3890–3906). | `levelSpawnSpecialRecovery` | working | Medium-high. | 01–08 | Engine/Scoring, Engine/BoardSpawn | Find reset and full restoration completion. |
| `r` / chunk | 333 | Six-entry array of four-number direction/offset tuples. | neighbor/offset patterns | working | Medium: signed coordinate-like tuples. | 01–01 | Engine/Matches | Establish tuple field semantics. |
| `n` / chunk | 334 | Exported current-game state; drives scoring/pause/events/save metadata and receives erroneous `bgFile` write (443, 464–529, 874–1008, 1274–1407, 1664, 1924–1933). | `currentGame` | resolved | High: explicit debug export and repeated state transitions. | 01–04 | Engine/Grid, Engine/Scoring | Full dynamic table shape still grows later. |
| `C` / chunk function | 444 | Returns a fresh backdrop descriptor; consumers mutate/apply it to legal and score-migration popups (445–452, 1663–1668, 3501–3508). | `createBackdropInfo` | resolved | High. | 01–08 | UI/Backdrops | None. |
| `st` / chunk function | 455 | Reads `e.animated`; appends `e` to `t.animationStack`; writes flag true (456–459). | `queueAnimationOnce` | working | High: full function body. | 01–01 | UI/Animations | Identify owner and element types at call sites. |
| `t` / `st` parameter | 455 | Table-key read `t.animationStack` passed to `table.insert` (457). | `animationOwner` | working | Medium: body only. | 01–01 | UI/Animations | Concrete frame/controller type. |
| `e` / `st` parameter | 455 | Reads/writes key `animated`; inserted into stack (456–458). | `animation` | working | Medium: body only. | 01–01 | UI/Animations | Concrete table/frame type. |
| `ht` / chunk function | 462 | Writes score/game state, checks thresholds, emits level/multiplier UI/audio, marks level-up, then updates bar (463–533). | `setScore` | resolved | High: complete body. | 01–02 | Engine/Scoring, UI/HUD | Method attachment still pending. |
| `i` / `ht` parameter | 462 | Score/level-bar controller: reads range, writes score, and calls `UpdateBar`; nested local shadows it only inside level-up branch (463–531). | `levelBar` | resolved | High: complete receiver contract. | 01–02 | UI/HUD | Method attachment still pending. |
| `t` / `ht` parameter | 462 | Assigned to both score fields; compared against thresholds/max (465–498). | `score` | resolved | High: direct data flow and comparisons. | 01–01 | Engine/Scoring | None for observed prefix. |
| `o` / `ht` local | 464 | Aliases `n`; score write, mode/leveledUp reads (466–500). | `gameState` | resolved | High: direct alias. | 01–01 | Engine/Scoring | Function continuation pending. |
| `i` / `ht` nested local | 499 | Shadows parameter inside level-up branch; status text receives label, is shown, and exposes background (499–525). | `gameStatusText` | resolved | High: explicit source and complete branch use. | 01–02 | UI/HUD | None. |

## Batch 01 resolution policy

Only direct standard-library aliases, loop counters with complete local bodies, explicit debug exports, and values with complete observed data flow are marked `resolved`. Numeric constants and texture tables retain `working` or `unresolved` status even where a likely role is apparent. Later batches must append evidence rather than silently promoting a proposed name.

## Batch 02 declarations and scopes

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `o` / `ht` multiplier branch | 504 | Receives integer or one-decimal multiplier label and is passed to four floating-text calls (505–520). | `multiplierLabel` | resolved | High: complete branch-local flow. | 02–02 | UI/HUD | None. |
| `t` / `ht` multiplier branch | 510 | Receives each floating-text object; fields/methods set before animator insertion (512–520). | `floatingText` | resolved | High: complete loop use. | 02–02 | UI/Animations | None. |
| `n` / `ht` multiplier branch (pre-loop) | 510 | Nil declaration immediately shadowed by numeric-for variable at 511. | — | dead | High: lexical shadow before read. | 02–02 | Unassigned | Minifier artifact. |
| `n` / `ht` floating-text loop | 511 | Numeric-for values 25–325 step 100; used as X coordinate (512, 516). | `x` | resolved | High: direct call argument. | 02–02 | UI/Animations | None. |
| `Tt` / chunk function | 535 | Complete classic score/non-classic timer bar rendering body (536–595). | `updateLevelBar` | resolved | High: complete body and UI effects. | 02–02 | UI/HUD | Method attachment pending. |
| `t` / `Tt` parameter | 535 | Reads mode/score/range/timer and updates bar/text (536–593). | `levelBar` | resolved | High: complete receiver shape. | 02–02 | UI/HUD | None. |
| `n`,`e`,`o` / `Tt` timed-display branch | 553 | Minute, second, and optional minimum-width `.01`; all assigned/consumed within 554–574. | `minutes`, `seconds`, `minimumWidth` | resolved | High: complete branch flow. | 02–02 | UI/HUD | None. |
| `n`,`e` / `Tt` learning-display branch | 577 | Minute and second format elapsed time (578–592). | `minutes`, `seconds` | resolved | High: complete branch flow. | 02–02 | UI/HUD | None. |
| `o` / `Tt` learning-display branch | 577 | Declared but never read or written. | — | dead | High: complete branch body. | 02–02 | Unassigned | Minifier artifact. |
| `Bt` / chunk function | 597 | Assigns score range fields (598–599). | `setMinMaxScore` | resolved | High: complete body. | 02–02 | UI/HUD | Method attachment pending. |
| `e`,`n`,`t` / `Bt` parameters | 597 | Receiver plus values written to `minScore` and `maxScore`. | `levelBar`, `minScore`, `maxScore` | resolved | High: direct assignments. | 02–02 | UI/HUD | None. |
| `xt` / chunk function | 602 | Adds delta to receiver score and delegates to `SetScore` (603). | `addScore` | resolved | High: complete body. | 02–02 | Engine/Scoring, UI/HUD | Method attachment pending. |
| `e`,`t` / `xt` parameters | 602 | Receiver and score delta are read at 603. | `levelBar`, `delta` | resolved | High. | 02–02 | Engine/Scoring, UI/HUD | None. |
| `n` / `xt` parameter | 602 | Never read in the complete body. | — | dead | High. | 02–02 | Unassigned | Why third argument existed. |
| `rt` / chunk function | 606 | Initializes mode-specific level/timer bar and related HUD layout (607–644). | `initializeModeBar` | resolved | High: complete body. | 02–02 | UI/HUD | Method attachment pending. |
| `t`,`o`,`i` / `rt` parameters | 606 | Receiver, mode value, and timer/duration seed drive all branches (608–642). | `levelBar`, `gameMode`, `timerValue` | resolved | High: direct branch and call flow. | 02–02 | UI/HUD | Exact units of `i` by caller. |
| `n` / `rt` local | 607 | Self-initializer captures outer current-game `n`, but the new alias is never read. | — | dead | High: no read in complete body. | 02–02 | Unassigned | Minifier artifact. |
| `kt` / chunk function | 646 | Sets timer start/remaining/elapsed and starts it (647–651). | `setTimer` | resolved | High: complete body. | 02–02 | UI/HUD | Method attachment pending. |
| `e`,`t` / `kt` parameters | 646 | Receiver and optional initial seconds populate timer fields. | `levelBar`, `duration` | resolved | High. | 02–02 | UI/HUD | None. |
| `Ft` / chunk function | 653 | Resets update accumulator and shows timer (654–656). | `startTimer` | resolved | High: complete body. | 02–02 | UI/HUD | Frame update handler pending. |
| `e` / `Ft` parameter | 653 | Receiver whose `timer` is reset/shown. | `levelBar` | resolved | High. | 02–02 | UI/HUD | None. |
| `Pt` / chunk function | 658 | Hides timer (659). | `stopTimer` | resolved | High: complete body. | 02–02 | UI/HUD | Whether hide pauses all update behavior. |
| `e` / `Pt` parameter | 658 | Receiver whose timer is hidden. | `levelBar` | resolved | High. | 02–02 | UI/HUD | None. |
| `X` / chunk function | 662 | Converts legacy base-70 text to number with optional centered signed offset; migration consumes it through 3610 before gravity function shadows it at 4041. | `decodeBase70` | resolved | High. | 02–09 | Core/SavedVariables | Preserve malformed-input behavior. |
| `n`,`l` / `X` parameters | 662 | Encoded string and boolean signed-mode flag (665–679). | `encoded`, `signed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / `X` local | 663 | Numeric accumulator updated by positional base-70 arithmetic and returned (673–679). | `value` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `o` / `X` first declaration | 664 | Nil declaration shadowed at 665 before read. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `e` / `X` local | 664 | Receives each byte/digit and is normalized before arithmetic (667–673). | `digit` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `o` / `X` second declaration | 665 | Starts at `#encoded-1`, supplies exponent, decrements each loop (673–674). | `exponent` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `i` / `X` loop | 666 | Iterates encoded character positions 1..length (667). | `index` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `x` / chunk function | 682 | Converts numbers to fixed-width base-70 text; used by score/network/save authentication (683–711, 818–853, 887–911, 1933). | `encodeBase70` | resolved | High: complete body and consumers. | 02–04 | Core/SavedVariables | Preserve overflow recursion behavior. |
| `t`,`n`,`l` / `x` parameters | 682 | Numeric value is transformed/divided; width limits/pads; boolean enables centered signed offset. | `value`, `width`, `signed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `o`,`e`,`i` / `x` locals | 683, 684, 685 | Base-70 digit, accumulated encoded string, and division counter (689–710). | `digit`, `encoded`, `digitIndex` | resolved | High: complete body. | 02–02 | Core/SavedVariables | Counter permits `i < n`, an apparent width+1 edge to preserve. |
| `H` / first chunk function | 713 | Produces five decimal checksum digits from alternating byte sums (714–733); shadowed at 761 but captured by `P`/`fe`. | `checksumDigits` | resolved | High: complete body and consumers. | 02–02 | Core/SavedVariables | None. |
| `s`,`e` / first `H` parameters | 713 | Input string and optional seed copied into accumulators before `e` is shadowed (715–724). | `text`, `seed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `d`,`i` / first `H` declaration | 714 | `d` becomes string length and `i` each input byte. | `length`, `byte` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / first `H` initial declaration | 714 | Shadowed at 716 without read. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `o` / first `H` local | 715 | Odd-position byte-sum accumulator initialized from seed (724, 729–730). | `oddSum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / first `H` second binding | 716 | Even-position byte-sum accumulator initialized from seed (722, 727–728). | `evenSum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `n`,`a`,`e`,`l`,`r` / first `H` outputs | 717 | Even ones/tens, odd ones/tens, and combined check digit (727–732). | `evenOnes`, `evenTens`, `oddOnes`, `oddTens`, `checkDigit` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `e` / first `H` loop | 719 | Character index; parity chooses accumulator (720–725). | `index` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `P` / chunk function | 735 | Prefixes packed checksum to payload; used by leaderboards, personal bests, and saved game state (736–739, 818–853, 887–911, 1933). | `authenticateScore` | resolved | High: complete body and consumers. | 02–04 | Core/SavedVariables | None. |
| `e`,`t` / `P` parameters | 735 | Payload and optional checksum seed; parameter `t` is shadowed at 736 after initializer access. | `payload`, `seed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / `P` defaulted seed | 736 | Defaults parameter seed, then is consumed by `H` initializer at 737 and shadowed by returned digit. | `seed` | shadowed | High. | 02–02 | Core/SavedVariables | None. |
| `l`,`o`,`t`,`i`,`n` / `P` checksum outputs | 737 | Five checksum digits returned by first `H`, packed in reverse variable order into decimal positions at 738. | `d1`, `d2`, `d3`, `d4`, `d5` | resolved | High for positional role; descriptive checksum names intentionally neutral. | 02–02 | Core/SavedVariables | Semantic digit ordering is legacy-specific. |
| `fe` / chunk function | 741 | Validates checksum prefix and returns authenticated payload or nil; migration uses it for leaderboard/personal-best repair before it is shadowed at 3829 (742–759, 3569–3613). | `verifyScore` | resolved | High. | 02–08 | Core/SavedVariables | None. |
| `e`,`t` / `fe` parameters | 741 | Authenticated string and optional checksum seed; `e` later shadowed after prefix/payload extraction. | `encodedScore`, `seed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `r`,`n` / `fe` locals | 745, 746 | Three-character checksum prefix and remaining payload. | `checksumPrefix`, `payload` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `d`,`h`,`c`,`S`,`s` / `fe` expected digits | 748 | Five checksum digits returned from first `H` and compared positionally (751–756). | `expected1`…`expected5` | resolved | High for positional role. | 02–02 | Core/SavedVariables | Neutral names preserve unusual order. |
| `l`,`i`,`t`,`o`,`a` / `fe` actual digits | 749 | Decimal digits parsed from decoded prefix positions 6..2 and compared to expected digits (751–756). | `actual1`…`actual5` | resolved | High for positional role. | 02–02 | Core/SavedVariables | None. |
| `e` / `fe` nested local | 750 | Shadows encoded-score parameter with decimal string of decoded checksum prefix. | `decodedChecksum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `H` / second chunk function | 761 | Returns sum of all input bytes for name-bound leaderboard/personal/save checksums (762–767, 774–911, 1933). | `byteSum` | resolved | High: complete body and consumers. | 02–04 | Core/SavedVariables | None. |
| `t` / second `H` parameter | 761 | Input string iterated byte-by-byte. | `text` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `n` / second `H` local | 762 | Initialized zero but immediately shadowed by loop variable at 763. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `e` / second `H` local | 762 | Accumulates byte values and is returned (764–766). | `sum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `n` / second `H` loop | 763 | Character index 1..length. | `index` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `j` / chunk function | 769 | Validates/merges leaderboard entries; receives decoded inbound sync entries from `Ee` (770–870, 1699). | `mergeLeaderboardScores` | resolved | High: complete body and network consumer. | 02–04 | Core/SavedVariables, Engine/Scoring | Sender trust still pending. |
| `S` / `j` parameter | 769 | Score-list receiver; selects `.classic` or `.timed` tables (786, 791). | `scoreList` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `a` / `j` declaration positions 1–2 | 770 | Duplicate same-statement bindings hidden by the third `a`, then line 771. | — | dead | High: Lua duplicate-name lexical resolution. | 02–02 | Unassigned | Minifier artifact. |
| `a` / `j` declaration position 3 | 770 | Hidden by new local `a` at 771 before read. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `o`,`c`,`n`,`i`,`t`,`l`,`d` / `j` locals | 770 | Name/rank-prefixed input, rank, decoded metric, insertion index, selected board, PopCap fallback metric, and decrement step (775–855). | `name`, `rank`, `score`, `insertAt`, `board`, `fallbackScore`, `fallbackStep` | resolved | High: complete body. | 02–02 | Core/SavedVariables | None. |
| `a` / `j` checksum local | 771 | Starts `PopCap Games`, then becomes its byte-sum seed (774, 818, 820). | `popCapChecksumSeed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `f` / `j` local | 771 | Current player name used to distinguish displaced third parties (842). | `playerName` | resolved | High. | 02–02 | Core/SavedVariables | Realm qualification unresolved. |
| `h` / `j` local | 772 | Set when a non-player/non-PopCap row is displaced; gates achievement checks (842–866). | `displacedOtherPlayer` | resolved | High. | 02–02 | Engine/Scoring | None. |
| `r` / `j` local | 773 | Boolean classic-encoding flag; cleared for timed entries (780, 792, 817–820, 850–853). | `isClassic` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `s` / `j` variadic-pair loop | 774 | Odd argument index 1..count step 2 (775–776). | `argumentIndex` | resolved | High. | 02–02 | Core/SavedVariables | Odd argument count is unguarded. |
| `s` / `j` insertion local | 797 | Boolean allowing insertion; cleared for non-improving duplicate (802–828). | `shouldInsert` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `e` / `j` duplicate-search loop | 800 | Searches rows 1..10 for same name (801–825). | `row` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `e` / `j` duplicate-shift loop | 805 | Shifts rows `e..9` upward after improved duplicate (806–813). | `row` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `e` / `j` rank-search loop | 829 | Scans rows 10..1 to find insertion index (830–839). | `row` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `e` / `j` insertion-shift loop | 841 | Shifts rows 10 down to `insertAt+1` (842–846). | `row` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `_t` / chunk function | 872 | Finalizes game results, best scores, publishing, result HUD, and first-game popup (873–951). | `finalizeGame` | resolved | High: complete body. | 02–02 | Engine/Scoring, UI/HUD | Method/callback attachment pending. |
| `t` / `_t` parameter | 872 | Result-window/controller whose captions, values, buttons, and payload are updated. | `resultsFrame` | resolved | High. | 02–02 | UI/HUD | None. |
| `r` / `_t` declaration | 873 | Receives elapsed seconds and drives game metrics/time display (877–933). | `elapsed` | resolved | High: complete body. | 02–02 | Engine/Scoring, UI/HUD | None. |
| `i`,`S`,`o` / `_t` declaration | 873 | Minute/remainder locals `i`,`S` are computed but unused; `o` is shadowed at 875 before read. | — | dead | High: complete body. | 02–02 | Unassigned | Minifier/removed display logic. |
| `l` / `_t` local | 874 | Aliases current game state; reads mode/score/stats and clears mode (881–943). | `gameState` | resolved | High. | 02–02 | Engine/Scoring | None. |
| `o` / `_t` second declaration | 875 | Shadows earlier nil `o`; receives rank+name then full publish payload (890–931). | `publishPayload` | resolved | High. | 02–02 | Core/Init | Network module ownership pending. |
| `s` / `_t` local | 876 | Player-name byte-sum used as checksum seed (880, 887–911). | `playerChecksumSeed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `a` / `_t` local | 877 | Current player name used in display, score keys, and payload. | `playerName` | resolved | High. | 02–02 | UI/HUD, Core/SavedVariables | Realm qualification unresolved. |
| `i` / `_t` classic branch | 882 | Aliases final integer score and is encoded/persisted (884–889). | `finalScore` | resolved | High. | 02–02 | Engine/Scoring | None. |
| `i` / `_t` timed branch | 895 | Computes points per second, drives UI/best/skills/encoding (896–915). | `pointsPerSecond` | resolved | High. | 02–02 | Engine/Scoring | Division assumes elapsed > 0. |
| `i` / `_t` friend declaration | 923 | Shadowed by the numeric-for variable at 924 before read. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `n` / `_t` friend declaration | 923 | Receives friend name and is used as whisper target (925–927). | `friendName` | resolved | High for legacy call flow. | 02–02 | Core/Init | Current friend API contract must be verified. |
| `i` / `_t` friend loop | 924 | Iterates friend-list indices `1..GetNumFriends()` and is passed to `GetFriendInfo` (925). | `friendIndex` | resolved | High. | 02–02 | Core/Init | Current friend API contract must be verified. |
| `_` / implicit chunk global | external; writes 925, 1433 | Receives repeated ignored friend-info returns, then a combat-log positional return; each assignment survives globally. | discarded positional return | unresolved | High for accidental global writes; later reads not yet audited. | 02–03 | Core/Init | Does any later code depend on global `_`? |
| `online` / implicit chunk global | external; write/read 925 | Receives the fifth friend-info return and immediately gates whisper publishing. | `friendOnline` | working | High for legacy intended role; API return contract pending. | 02–02 | Core/Init | Must become local and use current API shape. |
| `mod` / external function | external; calls 690, 721, 727–731 | Computes remainder for base-70 digits, parity, and checksum decimal digits. | `modulo` | resolved | High: arithmetic operands/results are explicit. | 02–02 | Core/SavedVariables | Choose Lua-5.1-compatible qualified implementation later. |
| `M` / chunk function | 953 | Computes match/combo/special points and skill gains, positions score/rank/skill floating text, and closes at 1037. | `presentMatchScore` | resolved | High: complete body; it presents but does not apply score. | 02–03 | Engine/Matches, Engine/Scoring, UI/Animations | Call sites must establish where score is applied. |
| `l` / `M` parameter | 953 | Controls skill/length bonuses and horizontal/vertical midpoint offset (961, 983–986, 1013–1025). | `matchLength` | resolved | High: complete body. | 02–03 | Engine/Matches | None. |
| `s` / `M` parameter | 953 | Frame/table anchor supplying `.x` and `.y` for floating-text placement (1010–1018). | `anchor` | resolved | High: direct coordinate reads. | 02–03 | UI/Animations | Concrete object type pending call sites. |
| `S` / `M` parameter | 953 | Passed as fourth argument to ordinary score `CreateFloatingText` (1023). | `scoreTextStyle` | working | Medium: direct call role, style domain unknown. | 02–03 | UI/Animations | Identify animator style enum. |
| `f` / `M` parameter | 953 | Boolean-like flag gates match-4 skill and +25 bonus (988–990). | `createdPowerGem` | working | Medium: complete body but call sites still needed. | 02–03 | Engine/Matches, Engine/Scoring | Confirm flag source. |
| `m` / `M` parameter | 953 | Boolean-like flag gates hyper/electro destruction sound and bonus (992–999). | `specialDestroyed` | working | Medium: complete body. | 02–03 | Engine/Matches, Engine/Scoring | Exact source object/type. |
| `a` / `M` parameter | 953 | Zero/nonzero selects destruction type when `m`; independently adds 25 for 1 or `10×(a+2)` above 1 (993–1006). | `specialTypeOrCount` | working | Medium: full arithmetic known, domain unresolved. | 02–03 | Engine/Matches, Engine/Scoring | Resolve from call sites. |
| `c` / `M` parameter | 953 | True selects horizontal X offset; false selects vertical Y offset (1012–1015). | `isHorizontal` | resolved | High: complete branch. | 02–03 | Engine/Matches, UI/Animations | None. |
| `h` / `M` parameter | 953 | Overrides derived position with anchor-centered coordinates (1016–1019). | `centerOnAnchor` | working | Medium: effect known, reason/callers pending. | 02–03 | UI/Animations | Identify triggering match case. |
| `u` / `M` parameter | 953 | Checks match-5 skill and suppresses ordinary score popup (1020–1028). | `createdHyperCube` | working | High for observed effect; caller confirmation pending. | 02–03 | Engine/Matches, UI/Animations | Confirm flag source. |
| `t` / `M` local | 957 | Accumulates all match/special/mode/level points and is floored for score popup (978–1023). | `points` | resolved | High: complete body. | 02–03 | Engine/Scoring | Actual score application is external. |
| `r` / `M` local | 958 | Animator alias creates/adds score, rank-up, and skill text (1023–1035). | `animator` | resolved | High: direct alias and complete body. | 02–03 | UI/Animations | None. |
| `o` / `M` local | 959 | Accumulates `CheckSkill` return values and controls one message per point (962–1035). | `skillPointsGained` | resolved | High: complete body. | 02–03 | Engine/Scoring, UI/Animations | None. |
| `g` / `M` local | 960 | Captures initial rank and detects rank change after checks (1029–1030). | `initialSkillRank` | resolved | High: direct before/after comparison. | 02–03 | Engine/Scoring | None. |
| `i` / `M` combo local | 964 | Aliases incremented `n.combo`; drives thresholds and `T` index (965–980). | `comboCount` | resolved | High. | 02–02 | Engine/Scoring | Reset timing pending. |

## Batch 02 resolution policy

Complete helper bodies are resolved when their transformation and side effects are fully visible, even though later method attachment may supply the eventual public name. Lexically captured standard-library bindings are retained as live entries after same-spelling shadow declarations. The incomplete `M` function and all unread parameters remain working or unresolved until batch 03.

## Batch 03 declarations and scopes

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `i` / `M` position local | 1010 | Starts at `anchor.x`; receives orientation/centering offsets and becomes floating-text X (1012–1034). | `textX` | resolved | High: complete remaining body. | 03–03 | UI/Animations | None. |
| `a` / `M` position local | 1011 | Shadows parameter after its last arithmetic use; starts at `anchor.y` and becomes floating-text Y (1012–1034). | `textY` | resolved | High: complete remaining body. | 03–03 | UI/Animations | None. |
| `e` / `M` score-text local | 1023 | Receives floating-text object, optionally gets `comboSound`, then is added (1024–1027). | `scoreText` | resolved | High. | 03–03 | UI/Animations | None. |
| `e` / `M` skill-text loop | 1033 | Iterates X values `textX+1..textX+skillPoints` for `+1 Skill` messages (1034). | `skillTextX` | resolved | High. | 03–03 | UI/Animations | None. |
| `ze` / chunk function | 1039 | Builds faction flight graph, detaches loader event, self-nils, and requests collection (1040–1255). | `loadFlightGraph` | resolved | High: complete body. | 03–03 | Core/SavedVariables | Loader attachment site pending. |
| `e` / `ze` parameter | 1039 | Loader frame whose script/event are disabled after graph creation (1250–1252). | `loaderFrame` | resolved | High. | 03–03 | Core/Init | None. |
| `t` / `ze` parameter | 1039 | Never read in complete body. | — | dead | High. | 03–03 | Unassigned | Event signature/minifier artifact. |
| `jt` / chunk function | 1257 | Looks up sine/cosine and writes rotated four-corner texture coordinates (1258–1264). | `setRotatedTexCoord` | resolved | High: complete body. | 03–03 | UI/Animations | Call sites must establish angle units/table precision. |
| `i`,`l`,`e`,`o`,`n` / `jt` parameters | 1257 | Trig-table owner, texture, angle index, center X, and center Y (1258–1263). | `trig`, `texture`, `angle`, `centerX`, `centerY` | resolved | High: direct lookup/geometry. | 03–03 | UI/Animations | None. |
| `t` / `jt` local | 1261 | Sine lookup for normalized angle; used in texture corners (1263). | `sin` | resolved | High. | 03–03 | UI/Animations | None. |
| `e` / `jt` local | 1262 | Shadows angle after initializer; cosine lookup used in corners (1263). | `cos` | resolved | High. | 03–03 | UI/Animations | None. |
| `T` / chunk function | 1266 | Shadows combo-score table for later declarations; applies pause/resume UI across grid, animator, and timer (1267–1361). Earlier `M` retains the table binding. | `setPaused` | resolved | High: complete body and lexical capture. | 03–03 | Engine/Grid, UI/Animations, UI/HUD | Method/callback attachment pending. |
| `r` / `T` parameter | 1266 | Boolean-like pause request; controls action, alpha/visibility, and timer (1268–1359). | `paused` | resolved | High. | 03–03 | Engine/Grid | None. |
| `i` / `T` duplicate declarations 1–2 | 1267 | Both nil bindings are shadowed by initialized `i` at 1274 before read. | — | dead | High. | 03–03 | Unassigned | Minifier artifact. |
| `l` / `T` local | 1267 | Dynamic method name `Hide` or `Show`, used on gems/animator (1268–1304). | `visibilityMethod` | resolved | High. | 03–03 | UI/GemPool, UI/Animations | None. |
| `t` / `T` local | 1267 | Receives each gem or animation/hint object and drives alpha/visibility bookkeeping (1277–1350). | `object` | resolved | High. | 03–03 | UI/GemPool, UI/Animations | None. |
| `i` / `T` mode local | 1274 | Captures current game mode and controls all mode branches (1278–1352). | `gameMode` | resolved | High. | 03–03 | Core/Constants | None. |
| `n` / `T` grid-row loop | 1275 | Iterates rows 1..`GRID_HEIGHT`; indexes gem grid (1277). | `row` | resolved | High. | 03–03 | Engine/Grid | None. |
| `e` / `T` grid-column loop | 1276 | Iterates columns 1..`GRID_WIDTH`; indexes gem grid (1277). | `column` | resolved | High. | 03–03 | Engine/Grid | None. |
| `o` / `T` stack local | 1307 | Aliases animator `animationStack`; indexed at positive loop values (1308–1313). | `animationStack` | resolved | High. | 03–03 | UI/Animations | None. |
| `n` / `T` animation loop | 1308 | Iterates synthetic index 0 through stack length; zero selects hint object (1309–1313). | `animationIndex` | resolved | High. | 03–03 | UI/Animations | None. |
| `t` / `UpdateFlightTimes` local | 1364 | Aliases `flightOptionWindow`; reads path/timer state and resets leg timer (1365–1383). | `flightWindow` | resolved | High. | 03–03 | UI/HUD | None. |
| `o` / `UpdateFlightTimes` local | 1366 | Rounded observed leg duration, optionally adjusted by 1.35, persisted/averaged (1370–1380). | `observedDuration` | resolved | High. | 03–03 | Core/SavedVariables | Rationale for constants pending. |
| `n`,`i`,`l` / `UpdateFlightTimes` locals | 1367, 1368, 1369 | FIFO-removed from-node, to-node, and prior estimated duration (1375–1380). | `fromNode`, `toNode`, `estimatedDuration` | resolved | High: direct nested keys/comparison. | 03–03 | Core/SavedVariables | None. |
| `e` / `UpdateFlightTimes` local | 1374 | Receives legacy current-continent index and keys `flightTimes` (1375–1380). | `continent` | resolved | High for legacy contract. | 03–03 | Core/SavedVariables | Current Retail replacement required. |
| `o` / `LoadAchievementEvents` local | 1387 | Aliases profile skill table; gates/synchronizes all fun-achievement registrations through method close (1388–1606). | `skillData` | resolved | High: complete method. | 03–04 | Core/SavedVariables, Engine/Scoring | None. |
| `t` / `LoadAchievementEvents` duplicate locals 1–2 | 1396 | Both are shadowed by generic-for key at 1397; second is later shadowed again by frame at 1400. | — | dead | High. | 03–03 | Unassigned | Minifier artifact. |
| `t`,`e` / `LoadAchievementEvents` played loop | 1397 | Character key and games value from `pairs`; only value `e` is added to `K` (1398). | `characterName`, `gamesPlayed` | resolved | High. | 03–03 | Core/SavedVariables | Key is intentionally unused. |
| `t` / `LoadAchievementEvents` watcher local | 1400 | Named event frame; owns dispatcher and all conditional callbacks through method close (1401–1606). | `eventWatcher` | resolved | High: complete method. | 03–04 | Core/Init | None. |
| `i`,`o` / watcher `OnEvent` parameters | 1406 | Event frame and event name; frame passed to callbacks/removal, event keys list (1407–1420). | `frame`, `event` | resolved | High. | 03–03 | Core/Init | None. |
| `l` / watcher `OnEvent` pre-loop local | 1408 | Nil binding shadowed by numeric-for variable at 1410 before read. | — | dead | High. | 03–03 | Unassigned | Minifier artifact. |
| `e`,`n` / watcher `OnEvent` locals | 1408 | Mutable callback index and callback completion result (1409–1416). | `callbackIndex`, `completed` | resolved | High. | 03–03 | Core/Init | None. |
| `l` / watcher dispatch loop | 1410 | Counts 1 through original callback-list length; not used for indexing (1411–1417). | `iteration` | resolved | High. | 03–03 | Core/Init | Fixed upper bound creates shrink edge. |
| `t`,`e`,`n` / `AddEvent` parameters | 1424 | Watcher self, event name, and callback inserted/registered (1425–1426). | `self`, `event`, `callback` | resolved | High. | 03–03 | Core/Init | None. |
| `t` / falling callback duplicate parameters 1–2 | 1429 | First is hidden by duplicate second; second is shadowed at 1431 before read. | — | dead | High. | 03–03 | Unassigned | Legacy callback signature artifact. |
| `n` / falling callback local | 1430 | Starts zero, receives `CheckSkill` result, and returns completion test (1437–1441). | `skillGain` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `t` / falling callback event local | 1431 | Receives combat-log subevent, then falling subtype at 1433; shadowed by health local at 1435. | `damageType` | resolved | High: sequential role within branch. | 03–03 | Core/Init | Current combat-log extraction required. |
| `t` / falling callback health local | 1435 | Computes current health minus damage and participates in lethal test (1436). | `healthAfterDamage` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `unitName` / implicit chunk global | external; write/read 1433–1434 | Receives legacy combat-log unit name and is compared with player name. | `damagedUnitName` | working | High for legacy intent; positional field contract pending. | 03–03 | Core/Init | Must become local/current API field. |
| `damageAmount` / implicit chunk global | external; write/read 1433–1436 | Receives falling damage and feeds lethal estimate. | `damageAmount` | working | High for legacy intent; positional field contract pending. | 03–03 | Core/Init | Must become local/current API field. |
| `t` / battlefield callback duplicate parameters 1–2 | 1445 | Both are hidden by local result `t` at 1446 before read. | — | dead | High. | 03–03 | Unassigned | Legacy callback signature artifact. |
| `t` / battlefield callback local | 1446 | Starts zero, receives `CheckSkill` result, returns completion test (1451–1454). | `skillGain` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `n` / battlefield pre-loop local | 1447 | Shadowed by numeric-for variable at 1448 before read. | — | dead | High. | 03–03 | Unassigned | Minifier artifact. |
| `n` / battlefield loop | 1448 | Iterates queue slots and is passed to `GetBattlefieldStatus` (1449). | `queueIndex` | resolved | High for legacy API. | 03–03 | Core/Init | Verify current queue API. |
| `bgStatus` / implicit chunk global | external; write/read 1449–1450 | Receives battlefield status and is compared with `queued`. | `battlefieldStatus` | working | High for legacy intent. | 03–03 | Core/Init | Must become local/current API field. |
| `t` / rare-loot callback duplicate parameters 1–2 | 1459 | Hidden by message local at 1461 before read. | — | dead | High. | 03–03 | Unassigned | Legacy callback signature artifact. |
| `n` / rare-loot callback local | 1460 | Starts zero, receives skill result for rare quality, returns completion test (1466–1469). | `skillGain` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `t` / rare-loot message local | 1461 | Receives loot message and is parsed before quality lookup (1462–1464). | `message` | resolved | High: complete callback. | 03–03 | Core/Init | None. |
| `o` / rare-loot message local | 1461 | Never read in complete callback. | — | dead | High. | 03–03 | Unassigned | Minifier artifact. |
| `t` / rare-loot quality local | 1464 | Shadows message after initializer; receives third `GetItemInfo` result and is compared with 3 (1465). | `itemQuality` | resolved | High for legacy return shape. | 03–03 | Core/Init | Verify current item API/cache behavior. |
| `t` / critter callback duplicate parameters 1–2 | 1473 | Both are hidden by local result `t` at 1474 before read. | — | dead | High. | 03–03 | Unassigned | Legacy callback signature artifact. |
| `t` / critter callback result local | 1474 | Starts zero, receives skill result, and returns completion test (1478–1481). | `skillGain` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `i`,`o`,`n` / critter callback fields | 1475 | Legacy subevent, source GUID, and destination GUID are tested at 1476. | `subevent`, `sourceGUID`, `destinationGUID` | working | High for intended fields; positional contract pending. | 03–03 | Core/Init | Verify current combat-log extraction. |
| `l` / critter callback duplicate field bindings 1–2 | 1475 | First is hidden by duplicate second; second is never read in complete callback. | — | dead | High. | 03–03 | Unassigned | Legacy positional/minifier artifact. |
| `t` / resurrection callback duplicate parameters 1–2 | 1485 | Neither parameter is read. | — | dead | High: complete callback. | 03–03 | Unassigned | Legacy callback signature artifact. |
| `e` / resurrection callback local | 1486 | Receives skill result and returns nonzero completion (1487). | `skillGain` | resolved | High. | 03–03 | Engine/Scoring | None. |
| `t` / epic-loot callback duplicate parameters 1–2 | 1492 | Hidden by message local at 1494 before read and inaccessible thereafter. | — | dead | High: lexical shadow is complete despite open callback. | 03–03 | Unassigned | Minifier artifact. |
| `n` / epic-loot callback local | 1493 | Starts zero, receives skill result for quality 4, and returns nonzero completion (1499–1502). | `skillGain` | resolved | High: callback complete. | 03–04 | Engine/Scoring | None. |
| `t` / epic-loot message local | 1494 | Receives/parses message, then is shadowed by quality local at 1497. | `message` | resolved | High: its lexical lifetime is complete. | 03–03 | Core/Init | None. |
| `o` / epic-loot message local | 1494 | Receives possible second event argument and is never read before callback closes. | — | dead | High: complete callback. | 03–04 | Unassigned | Minifier artifact. |
| `t` / epic-loot quality local | 1497 | Third item-info return compared with quality 4 before callback completion (1498–1503). | `itemQuality` | resolved | High: complete callback. | 03–04 | Core/Init | Verify current item API/cache behavior. |

## Batch 03 resolution policy

The completed `M`, flight loader, rotation helper, and pause helper are resolved by their full bodies. Massive coordinate tables are named only by proven graph shape; region semantics are deferred. Event locals are resolved only where the callback closes in this batch, while the epic-loot callback ending after line 1500 remains working/shadowed. Accidental globals are recorded without legitimizing them as future API.

## Batch 04 declarations and scopes

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `t` / ready-check hook parameter | 1506 | Truthiness gates ready-check achievement (1508–1509). | `accepted` | working | High for truth contract; exact hook signature pending. | 04–04 | Core/Init | Verify current function arguments. |
| `skillTrigger` / implicit chunk global | external; write 1509 | Receives `CheckSkill` result and is not read in this batch. | ready-check skill result | unresolved | High for accidental write. | 04–04 | Core/Init | Must become local or discard result. |
| `t` / combat-death callback duplicate parameters 1–2 | 1515 | Hidden by field local at 1517 before read. | — | dead | High. | 04–04 | Unassigned | Legacy callback artifact. |
| `o` / combat-death callback local | 1516 | Skill-gain accumulator returned as completion (1523–1527). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t`,`i`,`n` / combat-death fields | 1517 | Damage subevent/type, damaged unit name, and damage amount drive filters/lethal estimate (1518–1523). | `damageType`, `unitName`, `damageAmount` | working | Medium: legacy positional contract unresolved. | 04–04 | Core/Init | Verify modern combat-log positions. |
| `l` / combat-death duplicate fields 1–6 | 1517 | Earlier duplicates hide each other; final binding is unread. | — | dead | High. | 04–04 | Unassigned | Minifier/positional discard artifact. |
| `t` / combat-death health local | 1521 | Shadows damage type; computed remaining health feeds lethal check (1522). | `healthAfterDamage` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / elite-kill callback duplicate parameters 1–2 | 1531 | Hidden by result local at 1532. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `t` / elite-kill result local | 1532 | Skill gain returned as completion (1536–1539). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `i`,`n`,`o` / elite-kill fields | 1533 | Subevent, source GUID, destination GUID tested at 1534. | `subevent`, `sourceGUID`, `destinationGUID` | working | Medium: positional API pending. | 04–04 | Core/Init | Verify current combat-log fields. |
| `l` / elite-kill duplicate fields 1–2 | 1533 | Both unread; first hidden by second. | — | dead | High. | 04–04 | Unassigned | Positional discard artifact. |
| `t` / raid callback duplicate parameters 1–2 | 1543 | Never read. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `e` / raid callback local | 1544 | Skill gain returned as completion (1545). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / reputation callback duplicate parameters 1–2 | 1549 | Hidden by result local at 1550. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `t`,`n` / reputation callback locals | 1550, 1551 | Skill gain and system message; message pattern-gates skill check (1552–1555). | `skillGain`, `message` | resolved | High. | 04–04 | Engine/Scoring, Core/Init | None. |
| `t` / honor callback duplicate parameters 1–2 | 1559 | Never read. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `e` / honor callback local | 1560 | Skill gain returned as completion (1561). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / rare-kill callback duplicate parameters 1–2 | 1565 | Hidden by combat field at 1567. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `n` / rare-kill callback local | 1566 | Skill gain returned as completion (1571–1574). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t`,`o`,`i` / rare-kill fields | 1567 | Subevent, source GUID, destination GUID tested at 1568. | `subevent`, `sourceGUID`, `destinationGUID` | working | Medium: positional API pending. | 04–04 | Core/Init | Verify current combat-log fields. |
| `l` / rare-kill duplicate fields 1–2 | 1567 | Both unread; first hidden by second. | — | dead | High. | 04–04 | Unassigned | Positional discard artifact. |
| `t` / rare-kill classification local | 1569 | Shadows subevent; accepts rare/rareelite (1570). | `classification` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / level-up callback duplicate parameters 1–2 | 1578 | Never read. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `e` / level-up callback local | 1579 | Skill gain returned as completion (1580). | `skillGain` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / arena callback duplicate parameters 1–2 | 1584 | Hidden by local win flag at 1586. | — | dead | High. | 04–04 | Unassigned | Callback artifact. |
| `n`,`t` / arena callback locals | 1585, 1586 | Skill gain and boolean rating-increase flag (1589–1603). | `skillGain`, `wonArenaMatch` | resolved | High for legacy body. | 04–04 | Engine/Scoring | APIs obsolete candidates. |
| `teamName1`,`oldTeamRating1`,`newTeamRating1` / implicit globals | external; write 1587 | First team name and rating transition used at 1589–1593. | team-1 result fields | working | High for legacy role. | 04–04 | Core/Init | Must use locals/current arena API. |
| `teamName2`,`oldTeamRating2`,`newTeamRating2` / implicit globals | external; write 1588 | Second team name and rating transition used at 1589–1597. | team-2 result fields | working | High for legacy role. | 04–04 | Core/Init | Must use locals/current arena API. |
| `t` / legal Okay callback parameter | 1681 | Never read. | — | dead | High. | 04–04 | Unassigned | Callback self unused. |
| `Ee` / chunk function | 1689 | Selects score list by channel, splits payload, merges authenticated entries (1690–1700). | `receiveHighScoreSync` | resolved | High: complete body. | 04–04 | Core/SavedVariables | Network binding/message type pending. |
| `e` / `Ee` duplicate parameters 1 and 4 | 1689 | First hidden by fourth; fourth shadowed by local at 1693 before read. | — | dead | High. | 04–04 | Unassigned | Minifier/callback artifact. |
| `t`,`n` / `Ee` parameters | 1689 | Payload and channel; channel selects friends for whisper, guild otherwise (1690–1699). | `payload`, `channel` | resolved | High. | 04–04 | Core/SavedVariables | Sender identity ignored here. |
| `e` / `Ee` local | 1693 | Selected destination score list passed to `j` (1694–1699). | `scoreList` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `o`,`n` / `CheckName` parameters | 1702 | Skill-map key and competitor name control uniqueness/count branches (1703–1721). | `listKey`, `name` | resolved | High. | 04–04 | Engine/Scoring | None. |
| `t` / `CheckName` local | 1704 | Aliases selected skill competitor map and is mutated (1706–1718). | `competitorList` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `dt` / chunk function | 1725 | Serializes current-player friend/guild leaderboard rows into chunked `HSSync` messages (1726–1805). | `sendHighScoreSync` | resolved | High: complete body. | 04–04 | Core/SavedVariables | Network ownership pending. |
| `l`,`a` / `dt` parameters | 1725 | Target and channel select branch/transport (1728–1802); loop `a` bindings shadow channel locally. | `target`, `channel` | resolved | High. | 04–04 | Core/Init | Guild target semantics pending. |
| `i` / `dt` preliminary duplicate bindings 1–3 | 1726 | Hidden by player-name local at 1727. | — | dead | High. | 04–04 | Unassigned | Minifier artifact. |
| `n`,`o`,`t` / `dt` locals | 1726 | Selected score list, row name, and serialized payload (1729–1803). | `scoreList`, `rowName`, `payload` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `i` / `dt` player local | 1727 | Current player name used to select owned rows; later overwritten with guild member names (1734–1795). | `memberName` | resolved | High. | 04–04 | Core/SavedVariables | Realm qualification unresolved. |
| `a` / `dt` friend-row loop | 1731 | Iterates leaderboard rows 1–10 (1732–1756). | `row` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `r`,`d` / `dt` guild locals | 1763, 1764 | Serialized-entry count and whether member has a score row (1765–1799). | `entryCount`, `hasScore` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `a` / `dt` guild-member loop | 1765 | Iterates guild roster; inner row loop shadows it (1766–1800). | `memberIndex` | resolved | High. | 04–04 | Core/Init | None. |
| `a` / `dt` guild-row loop | 1768 | Iterates ten rows for one guild member (1769–1793). | `row` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `l`,`i`,`o`,`n`,`t`,`a`,`r` / `ScrubLists` locals | 1808 | Mutable row, name, fallback score, selected list/board key, presence flag, and roster name drive scrub (1810–1901). | `row`, `name`, `fallbackScore`, `scoreLists`, `modeKey`, `isPresent`, `rosterName` | working | Medium: complete body but heavily reused. | 04–04 | Core/SavedVariables | Mechanical rewrite should split scopes. |
| `d` / `ScrubLists` duplicate declarations 1–4 | 1808 | Duplicate bindings are hidden by later duplicates and outer loop at 1810. | — | dead | High. | 04–04 | Unassigned | Minifier artifact. |
| `S` / `ScrubLists` local | 1809 | Current player name exempted from membership removal (1865). | `playerName` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `d`,`s` / `ScrubLists` outer loops | 1810, 1816 | Select friend/guild list and classic/timed board (1811–1825). | `listKind`, `modeKind` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `scoreOffset` / implicit chunk global | external; writes 1819, 1823, 1858, 1861 | Fallback decrement used when regenerating PopCap rows (1843, 1890, 1896). | `fallbackScoreStep` | working | High for role; accidental global. | 04–04 | Core/SavedVariables | Must become lexical local. |
| `t` / `ScrubLists` name-list loop | 1827 | Temporary map key used to delete every entry (1828). | `name` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `n` / `ScrubLists` name-list loop | 1827 | Iteration value is never read. | — | dead | High. | 04–04 | Unassigned | Generic-for discard artifact. |
| `a` / `ScrubLists` duplicate scan | 1831 | Ten iterations while mutable `l` selects current row (1832–1854). | `iteration` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `e` / `ScrubLists` duplicate-shift loop | 1838 | Shifts fields 1–3 for rows `l..9` (1839–1845). | `row` | resolved | High. | 04–04 | Core/SavedVariables | Field 4 omission is defect evidence. |
| `e` / `ScrubLists` membership scan | 1863 | Iterates leaderboard rows; also seeds removal shift at 1885 (1864–1899). | `row` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `e` / `ScrubLists` friend/guild loops | 1868, 1876 | Iterates current friend or guild roster while searching name (1869–1882). | `rosterIndex` | resolved | High for legacy APIs. | 04–04 | Core/Init | Verify current API. |
| `e` / `ScrubLists` removal-shift loop | 1885 | Starts from outer row value and shifts fields 1–3 through row 9 (1886–1892). | `shiftRow` | resolved | High. | 04–04 | Core/SavedVariables | Field 4 omission is defect evidence. |
| `St` / chunk function | 1904 | Serializes grid and game metadata into `settings.savedState` (1905–1934). | `saveGameState` | resolved | High: complete body. | 04–04 | Core/SavedVariables | Load/validation counterpart pending. |
| `t` / `St` duplicate preliminary bindings 1–2 | 1905 | Hidden by saved-state local at 1906. | — | dead | High. | 04–04 | Unassigned | Minifier artifact. |
| `i` / `St` local | 1905 | Gem encoded contents, optionally +10 for big star (1916–1920). | `encodedGem` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `t` / `St` saved-state local | 1906 | Owns grid rows then metadata row (1907–1933). | `savedState` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `e`,`n` / `St` allocation/grid loops | 1910, 1914 | Allocate rows 1..9; then row loop 1..8 with column `e` at 1915. | `row`, `row` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `e` / `St` column loop | 1915 | Iterates grid columns and writes encoded gem (1916–1920). | `column` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `n` / `St` metadata local | 1924 | Aliases current game for metadata fields (1925–1932). | `gameState` | resolved | High. | 04–04 | Core/SavedVariables | None. |
| `e` / `NumberWithCommas` parameter | 1936 | Used by the local initializer at 1937, then shadowed. | `value` | shadowed | High. | 04–04 | UI/HUD | Input coercion relies on string library. |
| `e` / `NumberWithCommas` local | 1937 | First `gsub` result; repeatedly transformed and returned (1938–1943). | `formattedNumber` | resolved | High. | 04–04 | UI/HUD | None. |
| `t` / `NumberWithCommas` local | 1937 | Receives `gsub` replacement count; zero terminates loop (1939–1941). | `replacementCount` | resolved | High. | 04–04 | UI/HUD | None. |
| `e`,`t` / `SecondsConvert` bindings | 1946–1947 | Seconds parameter becomes remainder; local `t` is floored minutes (1947–1949). | `seconds`, `minutes` | resolved | High. | 04–04 | UI/HUD | None. |
| `Q` / chunk function | 1952 | Clears dynamic numeric/transient gem fields and restores geometry/visual defaults (1953–1982). | `resetGem` | resolved | High: complete body. | 04–04 | UI/GemPool | Call sites pending. |
| `e`,`n`,`o` / `Q` parameters | 1952 | Gem, column, row; coordinates/keys assigned after cleanup (1965–1979). | `gem`, `column`, `row` | resolved | High. | 04–04 | UI/GemPool | None. |
| `t` / `Q` local | 1953 | Receives each value's type and gates removal of numeric-valued keys (1954–1958). | `valueType` | resolved | High. | 04–04 | UI/GemPool | None. |
| `n`,`o` / `Q` generic loop | 1954 | Shadow parameters inside loop as key/value; removes numeric values (1955–1958). | `key`, `value` | resolved | High. | 04–04 | UI/GemPool | None. |
| `Ke` / chunk function | 1984 | Applies game-over movement/effects and queues every gem (1985–2002). | `startGameOverGemAnimation` | resolved | High: complete body. | 04–05 | UI/Animations | Dispatcher remains ahead. |
| `n` / `Ke` duplicate preliminary bindings 1–2 | 1985 | Hidden by animator local at 1986. | — | dead | High. | 04–04 | Unassigned | Minifier artifact. |
| `t` / `Ke` local | 1985 | Receives/mutates each gem before queueing (1989–2000). | `gem` | resolved | High. | 04–05 | UI/Animations | None. |
| `n` / `Ke` animator local | 1986 | Receives every grid gem (1999–2002). | `animator` | resolved | High. | 04–05 | UI/Animations | None. |
| `i`,`e` / `Ke` grid loops | 1987, 1988 | Iterate grid rows/columns and index gem grid (1989). | `row`, `column` | resolved | High. | 04–04 | Engine/Grid | None. |

## Batch 04 resolution policy

Completed event callbacks and helpers are resolved by full local data flow. Legacy positional API fields remain `working` where modern contracts are unverified. Duplicate declarations and proven-unused callback parameters are `dead`; accidental global writes remain explicit `working`/`unresolved` evidence. `Ke` and its transition-state constants stay working across the batch boundary.

## Batch 05 declarations and scopes

| Legacy identifier / lexical scope | Decl. | Observed interactions | Proposed name | Status | Confidence/evidence | First–last | Target | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `de` / chunk function | 2004 | Randomly assigns color and optionally avoids initial matches; `Le` uses it during refill/reroll through 3945 before state-transition function shadows it at 4139. | `assignRandomGem` | resolved | High. | 05–09 | Engine/Grid, Engine/BoardSpawn | None. |
| `t`,`n`,`f`,`i` / `de` parameters | 2004 | Column, row, avoidance flag, skip-reset flag. | `column`,`row`,`avoidMatches`,`skipReset` | resolved | High. | 05–05 | Engine/Grid | None. |
| `p` / `de` duplicate locals 1–5 | 2005 | Hidden by later bindings or unread. | — | dead | High. | 05–05 | Unassigned | Minifier artifact. |
| `s`,`c`,`d`,`S`,`e` / `de` locals | 2005 | Match count, safe flag, two scan steps, chosen color (2006–2049). | `matchCount`,`safe`,`xStep`,`yStep`,`color` | resolved | High. | 05–05 | Engine/Grid | None. |
| `i`,`l` / `de` loops | 2012, 2014, 2020, 2025 | Attempts, pattern, row offset, column offset. | `attempt/pattern`,`rowOffset`,`columnOffset` | resolved | High. | 05–05 | Engine/Grid | None. |
| `t` / `de` gem local | 2049 | Shadows column after indexing and receives rendered gem. | `gem` | resolved | High. | 05–05 | UI/GemPool | None. |
| `R` / chunk renderer | 2059 | Shadows type alias; renders normal/hyper/empty gem (2060–2075). | `renderGem` | resolved | High. | 05–05 | UI/GemPool | Earlier reset closure retains old alias. |
| `t` / renderer parameter | 2059 | Gem/content receiver. | `gem` | resolved | High. | 05–05 | UI/GemPool | None. |
| `j` / chunk game function | 2077 | Shadows leaderboard merger; initializes/restores game (2078–2245). | `startGame` | resolved | High. | 05–05 | Engine/Grid | Attachment pending. |
| `l`,`s`,`r` / game parameters | 2077 | Mode, duration, resume flag. | `mode`,`duration`,`resume` | resolved | High. | 05–05 | Engine/Grid | None. |
| `d`,`i`,`t` / game locals | 2078–2079 | Player name (after dead duplicate), object temporary, game-state alias. | `playerName`,`object`,`gameState` | resolved | High. | 05–05 | Engine/Grid | None. |
| `t`,`e` / game loops | 2099, 2129–2130, 2184–2192, 2202–2203 | Animation/grid indices. | `index/row/column` | resolved | High. | 05–05 | Engine/Grid, UI/Animations | None. |
| `n`,`l`,`r` / resume locals | 2199–2201 | Saved state, encoded gem, animator. | `savedState`,`encodedGem`,`animator` | resolved | High. | 05–05 | Core/SavedVariables | None. |
| `ee` / chunk function | 2247 | Creates power gem/big star and achievement (2248–2264). | `createPowerGem` | resolved | High. | 05–05 | Engine/Matches | None. |
| `Z` / chunk function | 2266 | Creates hyper gem and achievement (2267–2283). | `createHyperGem` | resolved | High. | 05–05 | Engine/Matches | None. |
| `t`,`i`,`o` / `ee` and `Z` bindings | 2247–2267 | Gem, forced flag, created result in each helper. | `gem`,`forced`,`created` | resolved | High. | 05–05 | Engine/Matches | None. |
| `Le` / chunk function | 2285 | Marks directional clear/explosion and queues animation (2286–2300); shadowed by board-spawn function at 3874. | `markGemForClear` | resolved | High. | 05–08 | Engine/Matches | Direction enum pending. |
| `t`,`o` / `Le` parameters | 2285 | Gem and direction; `Ne` selects X. | `gem`,`direction` | resolved | High. | 05–05 | Engine/Matches | None. |
| `Q` / chunk move finder | 2302 | Shadows reset helper; transactional swaps detect legal match (2303–2347). | `findLegalMove` | resolved | High. | 05–05 | Engine/Matches | Returns one candidate gem. |
| `e`,`t`,`p` / move loops | 2304–2306 | Row, column, cardinal direction. | `row`,`column`,`direction` | resolved | High. | 05–05 | Engine/Matches | None. |
| `n`,`i`,`c`,`f`,`d`,`s`,`S`,`l` / move locals | 2303 | Neighbor row/column, swapped gem, validity and four run bounds. | `neighborRow`,`neighborColumn`,`gem`,`valid`,`left`,`right`,`top`,`bottom` | resolved | High. | 05–05 | Engine/Matches | Preliminary duplicate `e` bindings dead. |
| `e` / `TotalTime` local | 2350 | Accumulates duration text. | `text` | resolved | High. | 05–05 | UI/HUD | None. |
| `Se` / chunk function | 2384 | Clears current/next selection and selector UI; gravity transfer uses it at 4070 before animator update shadows it at 4235. | `clearSelection` | resolved | High. | 05–09 | Engine/Grid | None. |
| `t`,`e` / `Se` bindings | 2384–2385 | Next flag and selected gem. | `next`,`gem` | resolved | High. | 05–05 | Engine/Grid | None. |
| `Me` / chunk function | 2403 | Finalizes game and starts board wipe (2404–2456). | `endGame` | resolved | High. | 05–05 | Engine/Scoring | Summary follows later. |
| `o`,`t` / `Me` locals | 2404–2405 | Animator and status text. | `animator`,`statusText` | resolved | High. | 05–05 | UI/HUD | None. |
| `e` / `Me` duplicate/loop bindings | 2423–2429 | Dead duplicate locals; live loops clear saved state. | `column/index` | resolved | High. | 05–05 | Core/SavedVariables | None. |
| `At` / chunk function | 2458 | Creates positioned layered BackdropTemplate frame (2459–2482). | `createImageFrame` | resolved | High. | 05–05 | UI/GemPool | First parameter unused. |
| `a`,`o`,`i`,`n`,`t`,`e`,`l` / `At` parameters | 2458 | Unused, X, Y, width, height, parent, overlay flag. | —,`x`,`y`,`width`,`height`,`parent`,`overlay` | working | High except unused first. | 05–05 | UI/GemPool | Identify first argument. |
| `e` / `At` frame local | 2459 | Shadows parent after initializer; returned frame. | `frame` | resolved | High. | 05–05 | UI/GemPool | None. |
| `tt` / chunk function | 2484 | Begins gem-frame creation; continues after 2500. | `createGemFrame` | working | High for prefix. | 05–05 | UI/GemPool | Complete in batch 06. |
| `n`,`i`,`o`,`t`,`e` / `tt` bindings | 2484–2485 | X, Y, parent, color, created frame. | `x`,`y`,`parent`,`color`,`gem` | working | High for prefix. | 05–05 | UI/GemPool | Continue in batch 06. |
| `t` / `TotalTime` parameter | 2349 | Floored and reduced by day/hour/minute moduli (2351–2375). | `seconds` | resolved | High. | 05–05 | UI/HUD | None. |
| `o`,`n`,`e`,`t` / `Print` parameters | 2380 | Passed directly to chat-frame message plus RGB values (2381). | `message`,`red`,`green`,`blue` | resolved | High. | 05–05 | UI/HUD | None. |
| `t`,`e` / `Me` saved-grid loops | 2424–2425 | Row/column indices clearing saved grid. | `row`,`column` | resolved | High. | 05–05 | Core/SavedVariables | None. |
| `e` / `Me` metadata loop | 2429 | Index clearing saved metadata row. | `index` | resolved | High. | 05–05 | Core/SavedVariables | None. |

## Batch 05 resolution policy

Complete helpers are resolved from full bodies. Same-spelling functions are separate entries because earlier closures retain prior bindings. `tt` and dispatcher-dependent constants remain working.

## Batch 06 declarations and scopes

| Legacy identifier / scope | Decl. | Evidence | Proposed name | Status | Confidence | First–last | Target | Question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `tt` / chunk | 2484 | Completes layered gem frame at 2506. | `createGemFrame` | resolved | High. | 05–06 | UI/GemPool | None. |
| `It` / chunk; `t`,`e` params | 2508 | Configures `e` as hyper gem; `t` unused. | `configureHyperGem`; —,`gem` | resolved | High. | 06–06 | UI/GemPool | None. |
| `Ht` / chunk; `t`,`o`,`i`,`n`,`e` bindings | 2519–2520 | Pooled big-star factory: animator,x,y,parent,object. | `createBigStar` | resolved | High. | 06–06 | UI/Animations | None. |
| `Ot` / chunk; `n`,`i`,`a`,`o`,`t` bindings | 2545–2546 | Pooled explosion factory: animator,x,y,source,object. | `createExplosion` | resolved | High. | 06–06 | UI/Animations | None. |
| `Et` / chunk; `t`,`n` params | 2566 | Lazy hint factory/reset for animator and optional gem. | `createHintArrow` | resolved | High. | 06–06 | UI/Animations | None. |
| `vt` / chunk; `n`,`t`,`o`,`e` bindings | 2585–2586 | Pooled delayed lightwave for animator,parent,delay. | `createLightwave` | resolved | High. | 06–06 | UI/Animations | `lightWaveObv` typo compatibility. |
| `lt` / shadow function | 2604 | Pooled lightning factory; removed route drawing (2605–2621). | `createLightning` | resolved | High. | 06–06 | UI/Animations | Replacement geometry required. |
| `a`,`r`,`o`,`i`,`n`,`d`,`t` / `lt` bindings | 2604–2605 | Animator, endpoints, color index, texture object. | `animator`,`x1`,`y1`,`x2`,`y2`,`color`,`lightning` | resolved | High. | 06–06 | UI/Animations | None. |
| `qe` / shadow function | 2623 | Pooled colored shard factory (2624–2643). | `createShard` | resolved | High. | 06–06 | UI/Animations | None. |
| `n`,`i`,`o`,`a`,`r`,`t` / `qe` bindings | 2623–2624 | Animator, offsets, source gem, color, shard. | `animator`,`x`,`y`,`gem`,`color`,`shard` | resolved | High. | 06–06 | UI/Animations | None. |
| `Qe` / shadow function | 2645 | Clears gem/big star and spawns directional shards (2646–2698). | `clearGem` | resolved | High. | 06–06 | Engine/Matches, UI/Animations | None. |
| `r`,`S`,`s`,`e`,`a`,`i`,`l`,`d` / `Qe` params | 2645 | Animator, position, gem, color, direction vector, suppression flag. | `animator`,`x`,`y`,`gem`,`color`,`dx`,`dy`,`suppressScore` | resolved | High. | 06–06 | Engine/Matches | None. |
| `h`,`o`,`t` / `Qe` locals | 2646 | Unused `h`, shard object, sign/speed temporary. | —,`shard`,`sign` | working | High except unused. | 06–06 | UI/Animations | Split dead `h`. |
| `Je` / shadow function | 2700 | Pooled floating-text factory (2701–2729). | `createFloatingText` | resolved | High. | 06–06 | UI/Animations | None. |
| `d`,`i`,`n`,`o`,`a`,`l`,`t`,`r` / `Je` bindings | 2700–2702 | Animator,x,y,text,color,non-score,object,parent. | resolved by position | resolved | High. | 06–06 | UI/Animations | None. |
| `Ye` / chunk; `t` param | 2749 | Defers or applies mouse-over gem. | `handleGemMouseEnter`; `gem` | resolved | High. | 06–06 | UI/GemPool | None. |
| `Ue` / shadow function; `t` local | 2770–2771 | Advances current-game level/multiplier/threshold. | `advanceLevel`; `gameState` | resolved | High. | 06–06 | Engine/Scoring | None. |
| `Ce` / shadow function; `t`,`n` bindings | 2800–2801 | Processes hyper chain using gem and animator. | `triggerHyperChain` | resolved | High. | 06–06 | Engine/Matches | None. |
| `S`,`s`,`i`,`r`,`l`,`d`,`e` / `Ce` locals/loops | 2814–2821 | Source/target centers, coordinates, row/column, matching gem. | coordinate/search roles | resolved | High. | 06–06 | Engine/Matches | None. |
| `he` / chunk function | 2842 | Scans vertical/horizontal matches, marks clears, creates power/hyper gems, reports matches/statistics, returns match-found at 3039. Shadows the RGB table captured by earlier effect factories. | `findAndMarkMatches` | resolved | High. | 06–07 | Engine/Matches | None. |
| `x`,`e`,`S`,`c`,`T`,`r`,`s`,`w`,`g`,`C`,`u`,`l`,`d`,`p`,`f` / `he` locals | 2843–2844 | Match-found flag, run length/color/counts, gem, creation flags and cross-arm bounds. | match-scan roles by use | resolved | High. | 06–07 | Engine/Matches | None. |
| `i`,`t`,`n`,`e`,`d`,`l` / `he` loops | 2845–3033 | Grid, run, and cross-arm indices in declaration-specific loop scopes. | row/column/run indices | resolved | High. | 06–07 | Engine/Matches | None. |
| `explodeCount` / implicit chunk global | external; writes 2887, 2975; read 3019 | Accumulates `Le` explosion returns and is passed to `M`. | `explosionCount` | working | High; accidental global. | 06–07 | Engine/Matches | Must become local without changing accumulation. |

## Batch 06 resolution policy

Completed factories are resolved by pool/field contracts. The open match scanner and its reused locals remain working until batch 07; accidental `explodeCount` is recorded as global evidence.

## Batch 07 declarations and scopes

| Legacy identifier / scope | Decl. | Evidence | Proposed name | Status | Confidence | First–last | Target | Question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `ce` / shadow function; `e` param | 3041 | Mouse-leave handler clears deferred hover or ends eligible effects. Shadows earlier half-gem-width constant only for later declarations. | `handleGemMouseLeave`; `gem` | resolved | High. | 07–07 | UI/GemPool | None. |
| `Z` / shadow function; `t` param | 3057 | Main click/swap controller. `he` retains the earlier `createHyperGem` binding. | `handleGemClick`; `gem` | resolved | High. | 07–07 | Engine/Input | None. |
| `r` / `Z` adjacency scope | 3082 | False until clicked gem is one orthogonal neighbor of current selection. | `isAdjacent` | resolved | High. | 07–07 | Engine/Input | None. |
| `a` / `Z` swap scope | 3083 | Holds hyper activation/target state used with match result. | `hyperTriggered` | resolved | Medium-high. | 07–07 | Engine/Input, Engine/Matches | Preserve exact truthy values. |
| `l` / `Z` swap scope | 3084 | Animator used for hints and moving-gem scheduling. | `animator` | resolved | High. | 07–07 | UI/Animations | None. |
| `o`,`i` / `Z` selected-coordinate scope | 3089 | Hold selected X/Y; nested `o` at 3102 separately binds selected gem. | `selectedX`,`selectedY` | resolved | High. | 07–07 | Engine/Input | Keep nested binding distinct. |
| `o` / `Z` adjacent-swap scope | 3102 | Selected gem paired with clicked parameter `t`. | `selectedGem` | resolved | High. | 07–07 | Engine/Input | None. |
| `e` / `Z` bCrowbar scope | 3148 | Serialized previous-board state for optional bCrowbar integration. | `previousState` | resolved | High. | 07–07 | Integration/bCrowbar | None. |
| `t` / repeated `Z` locals and loop | 3150–3151 | Repeated same-scope nil declarations precede board serialization loop. | dead temporaries / row index | dead | High. | 07–07 | Integration/bCrowbar | Remove only after equivalence tests. |
| `n` / `Z` serialization loop | 3155 | Inner board index for bCrowbar previous-state capture. | `column` | resolved | High. | 07–07 | Integration/bCrowbar | None. |
| `o`,`i` / `Z` generic loop | 3161 | Iterator key/value over serialized board state. | `key`,`value` | resolved | High. | 07–07 | Integration/bCrowbar | None. |
| `i` / `Z` swap local | 3167 | Temporary used while exchanging gem identity/state. | `swapTemporary` | resolved | High. | 07–07 | Engine/Input | None. |
| `l` / `Z` result scope | 3174 | Boolean indicating both swapping gems are hyper gems. | `bothHyper` | resolved | High. | 07–07 | Engine/Matches | None. |
| `a` / `Z` result scope | 3182 | Receives `he` return and participates in valid-move decision. | `matchFound` | resolved | High. | 07–07 | Engine/Matches | None. |
| `t`,`e` / `Z` invalid-result scope | 3208 | Snapshot `o.fxType` and `o.fxFrame`, then are never read. | — | dead | High. | 07–07 | Engine/Input | Remove after behavioral capture. |
| `ee` / shadow function; `t` param | 3234 | Drag-release handler maps cursor displacement to a neighboring gem and calls new `Z`. `he` retains earlier `createPowerGem`. | `handleGemDragRelease`; `gem` | resolved | High. | 07–07 | Engine/Input | None. |
| `e`,`l` / `ee` locals | 3239 | Cursor coordinates from `GetCursorPosition`, later reused for target column/row. | `cursorXOrColumn`,`cursorYOrRow` | resolved | High. | 07–07 | Engine/Input | Verify Retail coordinate scaling. |
| `r`,`i` / `ee` locals | 3240–3241 | Horizontal and vertical displacement from pressed gem, normalized on the selected axis. | `deltaX`,`deltaY` | resolved | High. | 07–07 | Engine/Input | None. |
| `d` / `ee` local | 3242 | Neighbor chosen from dominant drag direction. | `targetGem` | resolved | High. | 07–07 | Engine/Input | None. |
| `U` / shadow function; `n` param | 3270 | Selects one of four tabs and restyles all tab buttons; shadows color-name table for later code. | `selectTab`; `tabButton` | resolved | High. | 07–07 | UI/Tabs | None. |
| `e` / `U` first local | 3271 | Declared and immediately shadowed before any read. | — | dead | High. | 07–07 | UI/Tabs | None. |
| `e` / `U` parent local | 3272 | Parent container whose contents/buttons are updated. | `container` | resolved | High. | 07–07 | UI/Tabs | None. |
| `t` / `U` loop | 3273 | Tab index 1–4. | `index` | resolved | High. | 07–07 | UI/Tabs | None. |
| `nt` / shadow function; `o`,`r` params | 3288 | Populates leaderboard rows for owner and selected list; shadows direction constant for later code. | `populateLeaderboard`; `owner`,`listKey` | resolved | High. | 07–07 | UI/Leaderboard | None. |
| `t` / duplicated `nt` locals | 3293 | Two nil declarations superseded by row-loop `t` without a read. | — | dead | High. | 07–07 | UI/Leaderboard | None. |
| `n`,`i`,`l` / `nt` locals | 3293 | Record name/rank/score values reused for classic and timed rows. | `name`,`rank`,`score` | resolved | High. | 07–07 | UI/Leaderboard | None. |
| `h`,`a`,`S`,`d`,`s` / `nt` locals | 3294–3298 | Score list, cyan color, green color, player name, friend count. | `scoreList`,`cyan`,`green`,`playerName`,`friendCount` | resolved | High. | 07–07 | UI/Leaderboard | None. |
| `t` / `nt` row loop | 3299 | Display row index 1–10. | `rowIndex` | resolved | High. | 07–07 | UI/Leaderboard | None. |
| `e` / `nt` friend loops | 3315, 3348 | Friend-list index in distinct nested loop scopes. | `friendIndex` | resolved | High. | 07–07 | UI/Leaderboard | None. |
| `Ne` / shadow function; `t`,`n` params | 3369 | Throttled timer `OnUpdate`; delta parameter `n` is consumed before a later local shadows it. Shadows direction constant for later code. | `updateTimer`; `frame`,`delta` | resolved | High. | 07–07 | UI/Timer | None. |
| `n` / `Ne` timed-window local | 3378 | Timed-window object used after delta accumulation. | `timedWindow` | resolved | High. | 07–07 | UI/Timer | None. |
| `i`,`a`,`t`,`o` / `UpdateSavedVariablesDatabase` locals | 3463–3466 | Classic stats, timed stats, saved state, and player identity then checksum seed through completed migration (3463–3614). | `classicStats`,`timedStats`,`savedState`,`playerNameOrChecksum` | resolved | High. | 07–08 | Persistence/Migration | Split `o` roles in rewrite. |
| `n` / score-migration popup scope | 3494 | Popup frame fully constructed, stored as `Bejeweled.updatePopup`, and shown by upgrade controls (3494–3560). | `migrationPopup` | resolved | High. | 07–08 | UI/Migration | Duplicate global No button is preserved defect evidence. |

## Batch 07 resolution policy

Bindings are resolved only where complete control/data flow closes within this batch or the completed cross-batch `he` body. Locals in the open saved-variable method and ambiguous animator/row temporaries remain working; unused declarations are marked dead without yet authorizing removal.

## Batch 08 declarations and scopes

| Legacy identifier / scope | Decl. | Evidence | Proposed name | Status | Confidence | First–last | Target | Question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `t` / migration backdrop local | 3501 | Fresh `C()` descriptor mutated and passed to popup backdrop. | `backdropInfo` | resolved | High. | 08–08 | UI/Migration | None. |
| `t` / migration close-button local | 3509 | Popup close button configured through callback. | `closeButton` | resolved | High. | 08–08 | UI/Migration | None. |
| `e` / close callback | 3512 | Button whose parent is hidden. | `button` | resolved | High. | 08–08 | UI/Migration | None. |
| `t` / migration message local | 3515 | Popup explanatory font string. | `messageText` | resolved | High. | 08–08 | UI/Migration | None. |
| `t` / migration action-control local | 3524 | Yes button, then reassigned to two No buttons and upgrade launcher (3524–3561). | `actionControl` | resolved | High. | 08–08 | UI/Migration | Preserve duplicate named No construction. |
| `e` / Yes/No callbacks | 3528, 3537, 3546 | Distinct callback button parameters; Yes ignores it, No callbacks hide its parent. | `button` | resolved | High. | 08–08 | UI/Migration | None. |
| `t` / upgrade-launch callback | 3559 | Callback parameter is never read. | — | dead | High. | 08–08 | UI/Migration | None. |
| `e` / migration repair helper and params | 3564 | Local helper/table parameter validates and repairs one ten-row leaderboard. | `repairLeaderboard`; `leaderboard` | resolved | High. | 08–08 | Persistence/Migration | Calls cover only two distinct lists. |
| `r`,`n`,`d` / repair-helper params | 3564 | Classic flag, fallback score, and decrement step. | `isClassic`,`fallbackScore`,`fallbackStep` | resolved | High. | 08–08 | Persistence/Migration | None. |
| `i`,`o` / repair-helper locals | 3565 | PopCap fallback name and decoded signed payload. | `fallbackName`,`decodedPayload` | resolved | High. | 08–08 | Persistence/Migration | None. |
| `t` / first repair local | 3565 | First duplicate binding is hidden by the second same-statement `t`. | — | shadowed | High. | 08–08 | Persistence/Migration | None. |
| `t` / second repair local | 3565 | Survives the declaration but has no read outside the nested numeric-loop scopes. | — | dead | High. | 08–08 | Persistence/Migration | None. |
| `l` / repair-helper local | 3566 | Counts invalid rows but is never read. | — | dead | High. | 08–08 | Persistence/Migration | None. |
| `a` / repair-helper local | 3567 | Byte-sum checksum seed for PopCap fallback name. | `fallbackSeed` | resolved | High. | 08–08 | Persistence/Migration | None. |
| `t` / repair outer and shift loops | 3568, 3577 | Descending record index and nested upward shift index in distinct scopes. | `recordIndex`,`shiftIndex` | resolved | High. | 08–08 | Persistence/Migration | None. |
| `e` / personal-best local | 3601 | Verified payload reused for classic and timed profile scores. | `decodedPayload` | resolved | High. | 08–08 | Persistence/Migration | None. |
| `Ze` / shadow function; `t` param | 3619 | Command-text handler parses reset token or toggles window; shadows earlier dimension constant. | `handleCommand`; `message` | resolved | High. | 08–08 | Commands | Registration site pending. |
| `n` / `Ze` local | 3620 | Copy/remainder of command text; transformations have no observable consumer. | — | dead | High. | 08–08 | Commands | None. |
| `t` / `Ze` command local | 3621 | First token lowercased and compared with `reset`. | `command` | resolved | High. | 08–08 | Commands | None. |
| `o` / `Ze` local | 3622 | Index of first space used to split command. | `separatorIndex` | resolved | High. | 08–08 | Commands | None. |
| `e` / `Ze` toggle local | 3732 | Global main-window frame toggled visible/hidden. | `window` | resolved | High. | 08–08 | Commands, UI/MainWindow | Replace `getglobal` only after API baseline. |
| `e` / checkbox-click param | 3740 | Checkbox name yields setting key; checked value is stored. | `checkbox` | resolved | High. | 08–08 | UI/Settings | None. |
| `e` / slider-change param | 3744 | Slider supplies setting metadata, value, caption, and update callback. | `slider` | resolved | High. | 08–08 | UI/Settings | Truthy-only setting write is behavior-critical. |
| `a`,`l`,`s`,`h`,`n`,`t`,`o`,`d`,`r`,`i`,`S` / `CreateSlider` params | 3758 | X,Y,width,label,setting key,parent,min/default,max,step,percent flag,update callback. | positional roles as observed | resolved | High. | 08–08 | UI/Settings | Preserve `o` dual role. |
| `t` / `CreateSlider` result local | 3759 | Slider frame; shadows parent parameter only after RHS initializer. | `slider` | resolved | High. | 08–08 | UI/Settings | Lua 5.1 initializer scope is required. |
| `d`,`r`,`a`,`o`,`l`,`t`,`n`,`i` / `CreateCheckbox` params | 3798 | X,Y,label,setting key,checked value,parent,callback,radio flag. | positional roles as observed | resolved | High. | 08–08 | UI/Settings | None. |
| `t` / `CreateCheckbox` result local | 3799 | Check-button frame; shadows parent parameter only after RHS initializer. | `checkbox` | resolved | High. | 08–08 | UI/Settings | Lua 5.1 initializer scope is required. |
| `fe` / shadow function; `t`,`o` params | 3829 | Throttled gameplay timer updater for timer frame and elapsed delta; shadows signed-score verifier. | `updateGameTimer`; `timer`,`delta` | resolved | High. | 08–08 | Engine/Timer | None. |
| `e` / `fe` flight-sync local | 3854 | Flight timer used to reconcile elapsed/remaining values. | `flightTimer` | resolved | High. | 08–08 | Engine/Timer | None. |
| `Le` / shadow function; `i` param | 3874 | Spawns/refills empty cells, rerolls for a legal board, restores special gems, advances levels, and checks achievement; attached as animator `HandleJewelDropping` at 4965. | `handleJewelDropping` | resolved | High. | 08–10 | Engine/BoardSpawn, UI/Animator | None. |
| `s` / first two `Le` declarations | 3878 | First and second duplicate bindings are hidden by later same-statement `s` declarations. | — | shadowed | High. | 08–08 | Engine/BoardSpawn | None. |
| `s` / final `Le` declaration | 3878 | Accessible same-spelling nil binding is never read before function close. | — | dead | High. | 08–09 | Engine/BoardSpawn | None. |
| `t`,`d`,`l`,`r` / `Le` initial locals | 3878 | Current gem, randomized vertical spacing, column, and row used across refill and special restoration. | `gem`,`verticalGap`,`column`,`row` | resolved | High. | 08–09 | Engine/BoardSpawn | None. |
| `e` / `Le` column loop | 3879 | Board column and column-offset index. | `column` | resolved | High. | 08–08 | Engine/BoardSpawn | None. |
| `l` / `Le` row loop | 3884 | Bottom-up board row; shadows/reuses local spelling by loop scope. | `row` | resolved | High. | 08–08 | Engine/BoardSpawn | None. |
| `d` / `Le` post-fill local | 3937 | Declared nil before legal-board retry and never read before function close. | — | dead | High. | 08–09 | Engine/BoardSpawn | None. |
| `n` / `Le` retry loop | 3939 | Attempt number 1–200; shadows current-game upvalue only inside loop. | `attempt` | resolved | High. | 08–08 | Engine/BoardSpawn | None. |
| `e` / `Le` refill loops | 3941, 3944 | Distinct indices over `newJewel` for clear then refill. | `index` | resolved | High. | 08–08 | Engine/BoardSpawn | None. |
| `e` / `Le` big-star loops | 3963, 3964, 3975 | Count, six random attempts, and cyclic scan in nested declaration-specific scopes. | `starIndex`,`attempt`,`scanIndex` | resolved | High. | 08–08 | Engine/BoardSpawn | None. |
| `e` / `Le` hyper loops | 3998, 3999, 4008 | Hyper count, six random attempts, and cyclic fallback scan in nested scopes. | `hyperIndex`,`attempt`,`scanIndex` | resolved | High. | 08–09 | Engine/BoardSpawn | None. |

## Batch 08 resolution policy

The completed migration, command, settings, and timer bodies support resolved roles. Duplicate calls/control construction and truthy-only writes are recorded as evidence without correction. All bindings belonging to open `Le` remain working or unresolved unless their individual loop scope closes within this batch.

## Batch 09 declarations and scopes

| Legacy identifier / scope | Decl. | Evidence | Proposed name | Status | Confidence | First–last | Target | Question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `X` / shadow function; `r` param | 4041 | Collapses contents/big-star ownership into empty cells, retains earlier `Se`, and is attached as animator `HandleJewelFalling` at 4966. | `handleJewelFalling`; `animator` | resolved | High. | 09–10 | Engine/Gravity, UI/Animator | None. |
| `e` / `X` local | 4042 | Destination empty-cell frame receiving source state. | `targetGem` | resolved | High. | 09–09 | Engine/Gravity | None. |
| `t` / first two `X` locals | 4042 | Hidden by later same-statement `t` bindings. | — | shadowed | High. | 09–09 | Engine/Gravity | None. |
| `t` / final `X` local | 4042 | Accessible binding is hidden within all relevant work by the column-loop `t` and never read after it. | — | dead | High. | 09–09 | Engine/Gravity | None. |
| `l`,`t`,`i` / `X` loops | 4043–4046 | Destination row bottom-up, column, and nearest candidate source row above. | `targetRow`,`column`,`sourceRow` | resolved | High. | 09–09 | Engine/Gravity | None. |
| `ne` / shadow function; `t` param | 4093 | Drives new-game 3/2/1/Go countdown and is attached as animator `HandleNewGameCountdown` at 4967; shadows half-height constant. | `handleNewGameCountdown`; `animator` | resolved | High. | 09–10 | Engine/Countdown, UI/Animator | None. |
| `t` / `ne` fade local | 4120 | Fade descriptor shadows animator parameter after its final use. | `fadeInfo` | resolved | High. | 09–09 | UI/HUD | Verify replacement for `UIFrameFade`. |
| `de` / shadow function; `t`,`o` params | 4139 | Coordinates animation-state transitions and is attached as animator `HandleAnimatorStatusChange` at 4964; shadows random-gem assignment. | `handleAnimatorStatusChange`; `animator`,`previousState` | resolved | High. | 09–10 | Engine/StateMachine, UI/Animator | None. |
| `i`,`o` / `de` locals | 4148 | Match-found result and later legal-move candidate; local `o` shadows consumed parameter. | `matchFound`,`legalMove` | resolved | High. | 09–09 | Engine/StateMachine | None. |
| `Se` / shadow function; `l`,`w` params | 4235 | Central animator update closes at 4920 and is attached as animator `OnUpdate` at 4933; shadows selection-clear helper. | `updateAnimator`; `animator`,`delta` | resolved | High. | 09–10 | UI/Animator | None. |
| `T`,`K` / `Se` locals | 4244–4245 | Animator reference used for effect creation/stack adds and game-board anchor for floating text. | `animatorRef`,`gameBoard` | resolved | High. | 09–10 | UI/Animator | None. |
| `k`,`_`,`P`,`I` / `Se` motion locals | 4246–4249 | Gravity for shards/free flight, swap offset step, board-drop acceleration, and floating-text frame/position step. | `gravityStep`,`swapStep`,`dropAcceleration`,`textStep` | resolved | High. | 09–10 | UI/Animator | None. |
| `t` / first `Se` local | 4250 | Derived `et * .025` then immediately shadowed at 4251. | — | shadowed | High. | 09–09 | UI/Animator | None. |
| `t` / second `Se` local | 4251 | Initial value 20 is overwritten before read; binding then holds each animation-stack object through function close. | `animationObject` | resolved | High. | 09–10 | UI/Animator | None. |
| `x` / `Se` local | 4258 | Alias of mutable animation stack. | `animationStack` | resolved | High. | 09–09 | UI/Animator | None. |
| `r` / two locals at 4259 | 4259 | First is hidden by same-statement final `r`; final is then hidden by line-4260 `r`. | — | shadowed | High. | 09–09 | UI/Animator | None. |
| `f` / `Se` local | 4259 | Mutable current stack index adjusted after removals. | `stackIndex` | resolved | High. | 09–09 | UI/Animator | Preserve mutation order. |
| `i`,`C`,`s`,`j`,`D`,`L`,`U` / `Se` locals | 4259 | Effect frame/index, big-star blend alpha, adjacent shine gem, and four spawn-crop UV coordinates. | `frameOrIndex`,`blendAlpha`,`adjacentGem`,`uvLeft`,`uvRight`,`uvTop`,`uvBottom` | resolved | High. | 09–10 | UI/Animator | Split by branch in rewrite. |
| `c`,`r` / `Se` locals | 4260 | X and Y displacement/position temporaries across swap/drop branches; `r` shadows earlier duplicates. | `xOffset`,`yOffset` | resolved | High. | 09–10 | UI/Animator | Split vertical roles in rewrite. |
| `m` / `Se` local | 4261 | Snapshot of animator `animationStatus` selecting idle/clear/drop branches. | `animationStatus` | resolved | High. | 09–09 | UI/Animator | None. |
| `G`,`v` / `Se` locals | 4262 | Per-update guards serializing hyper trigger and big-star explosion work. | `hyperProcessed`,`bigStarProcessed` | resolved | High for observed branches. | 09–09 | UI/Animator | Confirm later reset-free scope at close. |
| `H` / `Se` local | 4272 | Normalized oscillating alpha multiplier applied to hyper/big-star 5×5 glow fields. | `glowAlphaScale` | resolved | High. | 09–10 | UI/Animator | None. |
| `e` / `Se` periodic/board/queue loops | 4277, 4282, 4291 | Row indices for lightwaves/glow reset and queue-drain count in distinct scopes. | `rowOrIndex` by scope | resolved | High. | 09–09 | UI/Animator | None. |
| `n` / `Se` board loop | 4283 | Column index; shadows current-game upvalue only within loop. | `column` | resolved | High. | 09–09 | UI/Animator | None. |
| `w` / `Se` local | 4295 | Shadows consumed delta parameter; starts true for non-idle state, active effects clear it, and a surviving true value advances animator status at 4916–4918. | `phaseComplete` | resolved | High. | 09–10 | UI/Animator | None. |
| `Y` / `Se` animation loop | 4302 | Counts original animation-stack length while `f` tracks mutable current index. | `iteration` | resolved | High. | 09–09 | UI/Animator | None. |
| `e` / lightwave parent local | 4308 | Parent gem for position/visibility and right-neighbor wave propagation. | `parentGem` | resolved | High. | 09–09 | UI/Animator | None. |
| `n`,`e` / shine-coordinate locals | 4353–4354 | Adjacent target column and row derived from shine offset tables. | `targetColumn`,`targetRow` | resolved | High. | 09–09 | UI/Animator | None. |
| `r` / big-star branch local | 4467 | Captures `forcedExplode` before clearing the gem flag. | `forcedExplosion` | resolved | High. | 09–09 | Engine/Matches, UI/Animator | None. |
| `i`,`e` / big-star neighborhood loops | 4470, 4472 | Relative row and column offsets over -1..1. | `rowOffset`,`columnOffset` | resolved | High. | 09–09 | Engine/Matches | None. |
| `n` / big-star pre-loop local | 4487 | Nil binding immediately shadowed by numeric-for variable. | — | dead | High. | 09–09 | Engine/Matches | None. |
| `n` / big-star upward loop | 4488 | Rows above the exploding gem receive fall motion. | `row` | resolved | High. | 09–09 | Engine/Matches | None. |

## Batch 09 resolution policy

Complete spawn, gravity, countdown, and state-transition bodies support resolved names. The open animator update is named only at working confidence; locals whose consumers lie after line 4500 remain working, while closed loop/branch bindings are resolved independently.

## Batch 10 declarations and scopes

| Legacy identifier / scope | Decl. | Evidence | Proposed name | Status | Confidence | First–last | Target | Question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| `frame2` / implicit chunk global | external; writes 4650, 4655 | Secondary counter for opposing big-star highlight rotation; read for rotation and stored back to `t.fxFrame2`. | `secondaryRotationFrame` | resolved | High; accidental global. | 10–10 | UI/Animator | Must become local without changing per-object update. |
| `e` / hyper-glow local | 4628 | Gem receiving weighted glow inside a 5×5 hyper neighborhood. | `glowGem` | resolved | High. | 10–10 | UI/Animator | None. |
| `i`,`n` / hyper-glow loops | 4629, 4631 | Relative row/column offsets -2..2. | `rowOffset`,`columnOffset` | resolved | High. | 10–10 | UI/Animator | None. |
| `e` / big-star-glow local | 4678 | Gem receiving weighted glow around star parent. | `glowGem` | resolved | High. | 10–10 | UI/Animator | None. |
| `i`,`n` / big-star-glow loops | 4679, 4681 | Relative row/column offsets -2..2. | `rowOffset`,`columnOffset` | resolved | High. | 10–10 | UI/Animator | None. |
| `e` / swap completion local | 4810 | Boolean set when either axis reaches its target, driving reversal/finalization. | `axisComplete` | resolved | High. | 10–10 | Engine/Swaps | Preserve single-axis trigger behavior. |
| `A` / shadow function | 4922 | Constructs/wires invisible animator frame and all effect queues/helpers; shadows clear-work effect enum. | `createAnimator` | resolved | High. | 10–10 | UI/Animator | None. |
| `e` / `A` local | 4923 | Animator frame configured and returned. | `animator` | resolved | High. | 10–10 | UI/Animator | `movingGems`/`movingJewels` mismatch. |
| `t` / `A` rotation loop | 4938 | Degree 0–360 used to precompute sine/cosine tables. | `degrees` | resolved | High. | 10–10 | UI/Animator | None. |
| `V` / shadow function | 4971 | Network-frame factory remains open after 5000; shadows idle animator state captured by earlier closures/factory. | `createNetwork` | working | High for prefix. | 10–10 | Network/Transport | Complete in batch 11. |
| `o` / `V` local | 4974 | Network frame with queue, send method, throttling, and callbacks. | `network` | working | High for prefix. | 10–10 | Network/Transport | Complete in batch 11. |
| `l`,`i`,`o`,`n`,`t` / network `Send` params | 4981 | Unused self, message type, two required payload fields, optional final field. | `self`,`messageType`,`field1`,`field2`,`field3` | resolved | High. | 10–10 | Network/Transport | Determine semantic fields from callers. |
| `t`,`o` / network `OnUpdate` params | 4988 | Network frame and elapsed delta; callback continues after 5000. | `network`,`delta` | working | High for prefix. | 10–10 | Network/Transport | Complete in batch 11. |

## Batch 10 resolution policy

`Se` and `A` close in this batch, so their data-flow roles and explicit method attachments are resolved. Implicit `frame2` is recorded as accidental global evidence. Network factory `V` and its open update callback remain working until batch 11.
