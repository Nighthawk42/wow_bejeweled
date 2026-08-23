# Shortened identifier ledger

Each row identifies one declaration, not merely one spelling. `chunk` means the outer lexical scope of `Legacy/Bejeweled_Mainline.lua`; narrower scopes are named explicitly. Working names are hypotheses unless status is `resolved`. Batch 01 spans lines 1–500, so later-use claims remain open until their scheduled batch is analyzed.

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `t` / chunk (first binding) | 4 | String initializer only before shadow at 186. | `addonRootPath` | dead | High: path literal at 4; no read before 186. | 01–01 | Core/Constants | Was elimination intentional? |
| `l` / chunk | 5 | Path initializer; concatenated with bundled font at 618 and 633. | `imageRootPath` | resolved | High: literal and direct font-path consumers (5, 618, 633). | 01–02 | Core/Constants | Other consumers remain to inventory. |
| `ut` / chunk | 6 | Path initializer; no batch-01 read. | `soundRootPath` | working | High: literal ends in `sounds\` (6). | 01–01 | Core/Audio | Confirm path casing/contracts. |
| `xe` / chunk | 7 | String initializer; no batch-01 read. | `addonMessagePrefix` | working | Medium: `BEJEWELED2` literal (7). | 01–01 | Core/Init | Confirm registration/send sites. |
| `ft` / chunk | 8 | Seven-entry colored/name table; no batch-01 read. | `gemDisplayNames` | working | Medium: ordered color names (8). | 01–01 | UI/HUD | Confirm indices and markup purpose. |
| `he` / chunk | 169 | Nine RGB triples; initialized only in batch 01. | `gemColors` | working | Medium: values mirror seven gem colors plus two white entries (169–179). | 01–01 | Core/Constants | Determine meanings of indices 8–9. |
| `U` / chunk | 180 | Numeric keys 1–7 map to lowercase color names. | `gemColorNames` | working | High: complete table at 180. | 01–01 | Core/Constants | Confirm use in asset filenames. |
| `F` / chunk | 181 | Written at indices `i..i+4` from atlas math (199–203); read by `unpack` into `J` (204–208). | `atlas50Rects` | working | High for shape, medium for asset: 5×5, 50/255 derivation. | 01–01 | UI/Animations | Identify texture and off-by-one rationale. |
| `N` / chunk | 182 | Written as nine UV rectangles in a 3×3 loop (218–222). | `atlas3x3Rects` | working | High for shape: indices and 42.66/128 math. | 01–01 | UI/Animations | Identify texture/effect frames. |
| `J` / chunk | 183 | Receives copies of all `F` rectangles via `unpack` (204–208). | `mutableAtlas50Rects` | working | Medium: copy semantics are explicit. | 01–01 | UI/Animations | Why is a second copy required? |
| `O` / chunk | 184 | Written at 50 numeric indices using 10×5 normalized UV cells (188–198). | `atlas10x5Rects` | working | High for shape, medium for texture. | 01–01 | UI/Animations | Identify owning texture. |
| `ie` / chunk | 185 | Written at 16 indices using a 4×4 UV grid (211–217). | `atlas4x4Rects` | working | High for shape, medium for texture. | 01–01 | UI/Animations | Identify owning texture. |
| `t` / chunk (second binding) | 186 | Declared nil, then shadowed again at 263; no read. | — | dead | High: no assignment/read before shadow. | 01–01 | Unassigned | Minifier artifact? |
| `i` / chunk | 186 | Set to 1 (187, 210); indexes `F`, `J`, `ie`; incremented by 5/4 (208, 216). | `atlasIndex` | resolved | High: direct loop-index data flow (187–216). | 01–01 | UI/Animations | None for these loops. |
| `e` / first atlas loop | 188 | Loop values 0–4; multiplies row offsets and indices (189–203). | `row` | resolved | High: numeric-for and row arithmetic (188–203). | 01–01 | UI/Animations | None for this scope. |
| `e` / second atlas loop | 211 | Loop values 0–3; computes vertical quarters (212–215). | `row` | resolved | High: loop and `/4` UV math (211–215). | 01–01 | UI/Animations | None for this scope. |
| `e` / third atlas loop | 218 | Loop values 0–2; computes 3×3 indices/UVs (219–221). | `row` | resolved | High: loop and `*3`/`.33` math (218–221). | 01–01 | UI/Animations | Exact `.33` edge behavior later. |
| `K` / chunk | 227 | Constant `0`; no batch-01 read. | unknown enum zero | unresolved | Low: declaration only. | 01–01 | Core/Constants | Locate consumers. |
| `Ye` / chunk | 228 | Constant `24`; halved into `pt` (285). | unknown dimension | unresolved | Low: declaration/arithmetic only. | 01–01 | UI/GemPool | Which axis/object? |
| `Ze` / chunk | 229 | Constant `24`; halved into `ct` (286). | unknown dimension | unresolved | Low: declaration/arithmetic only. | 01–01 | UI/GemPool | Which axis/object? |
| `b` / chunk | 230 | Constant `50`; halved into `ce` (283). | likely gem width | working | Medium: matches 50-pixel atlas cells (199–203). | 01–01 | UI/GemPool | Confirm frame geometry. |
| `p` / chunk | 231 | Constant `50`; copied to `ue` and a shadowed `t`, halved into `ne` (272, 274, 284). | likely gem height | working | Medium: paired with `b`. | 01–01 | UI/GemPool | Confirm frame geometry. |
| `lt` / chunk | 232 | Constant expression `70 + 20`; no batch-01 read. | unknown 90-pixel dimension | unresolved | Low: declaration only. | 01–01 | UI | Locate consumers. |
| `Ue` / chunk | 233 | Constant expression `70 + 20`; no batch-01 read. | unknown 90-pixel dimension | unresolved | Low: declaration only. | 01–01 | UI | Paired with `lt`? |
| `Qe` / chunk | 234 | Constant expression `100 + 50`; halved by dead `t` at 287. | unknown 150-pixel dimension | unresolved | Low: declaration and dead derivation. | 01–01 | UI | Locate live consumer. |
| `qe` / chunk | 235 | Constant expression `100 + 50`; halved by dead `t` at 288. | unknown 150-pixel dimension | unresolved | Low: declaration and dead derivation. | 01–01 | UI | Locate live consumer. |
| `s` / chunk | 236 | Constant `400`; used in `q = s + 32 + 16` (238). | board width | working | Medium: 8 × likely 50-pixel cells. | 01–01 | Engine/Grid, UI/GemPool | Confirm coordinate ownership. |
| `w` / chunk | 237 | Constant `400`; used in `me = w + 110` (239). | board height | working | Medium: paired with `s`. | 01–01 | Engine/Grid, UI/GemPool | Confirm coordinate ownership. |
| `q` / chunk | 238 | Derived `448` from `s`; no batch-01 read. | board-area width | working | Low: geometry derivation only. | 01–01 | UI/HUD | Meaning of 32+16 padding. |
| `me` / chunk | 239 | Derived `510` from `w`; no batch-01 read. | window/game-area height | working | Low: geometry derivation only. | 01–01 | UI/HUD | Meaning of 110 padding. |
| `f` / chunk | 240 | Constant `160`; no batch-01 read. | unknown UI dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `L` / chunk | 241 | Constant `216`; no batch-01 read. | unknown UI dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `Je` / chunk | 242 | Constant `10`; halved into `gt` (290). | unknown dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `E` / chunk | 243 | Receives `math.random`, copied to `m` (307), then nilled (308). | temporary random alias | dead | High: direct alias chain. | 01–01 | Engine/Grid | None after `m` capture. |
| `S` / chunk | 244 | Constant `-1`; assigned to hidden hint object's `fxType` during level-up reset (527). | `inactiveHintFxType` | working | Medium: reset/hide sequence (526–527). | 01–02 | UI/Animations | Confirm animator interpretation. |
| `y` / chunk | 245 | Constant `1`; no batch-01 read. | unknown enum one | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Lt` / chunk | 246 | Constant `20`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `ye` / chunk | 247 | Constant `3`; no batch-01 read. | unknown enum three | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `ve` / chunk | 248 | Constant `360`; no batch-01 read. | likely angle/full rotation | working | Low: value only. | 01–01 | UI/Animations | Confirm angular use. |
| `Oe` / chunk | 249 | Constant `4`; no batch-01 read. | unknown enum four | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `bt` / chunk | 250 | Constant `16`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `He` / chunk | 251 | Constant `5`; no batch-01 read. | unknown enum five | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Xe` / chunk | 252 | Constant `12`; no batch-01 read. | unknown enum twelve | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `A` / chunk | 253 | Constant `6`; no batch-01 read. | unknown enum six | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `se` / chunk | 254 | Constant `4`; no batch-01 read. | unknown enum four | unresolved | Low. | 01–01 | Engine | Distinguish from `Oe`. |
| `je` / chunk | 255 | Constant `7`; no batch-01 read. | unknown enum seven | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `it` / chunk | 256 | Assigned `#FX_SHINE_ALPHA` (=6). | shine alpha count | working | High: direct length operation (223, 256). | 01–01 | UI/Animations | Confirm later iteration contract. |
| `ke` / chunk | 257 | Constant `8`; no batch-01 read. | unknown enum eight | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `Re` / chunk | 258 | Assigned `#FX_SHINE_ALPHA` (=6), duplicating `it`. | shine alpha count alias | working | High for value, low for distinct role (223, 258). | 01–01 | UI/Animations | Why two aliases? |
| `g` / chunk | 259 | Constant `9`; no batch-01 read. | unknown enum nine | unresolved | Low. | 01–01 | Engine | Locate consumers. |
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
| `at` / chunk | 277 | Constant `53`; no batch-01 read. | unknown enum 53 | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `t` / chunk (line 278) | 278 | Constant `16`; shadowed at 287. | unknown enum sixteen | shadowed | Low. | 01–01 | Engine | Locate any pre-287 read. |
| `Te` / chunk | 279 | Constant `20`; halved into `oe` (289). | unknown dimension | unresolved | Low. | 01–01 | UI | Locate consumers. |
| `et` / chunk | 280 | Constant `150`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `wt` / chunk | 281 | Constant `60`; no batch-01 read. | likely seconds/minute | working | Low: value only. | 01–01 | Engine/Scoring | Confirm time arithmetic. |
| `Gt` / chunk | 282 | Constant `10`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `ce` / chunk | 283 | Derived `b / 2` (=25). | half gem width | working | Medium: paired dimension derivation. | 01–01 | UI/GemPool | Confirm `b`. |
| `ne` / chunk | 284 | Derived `p / 2` (=25). | half gem height | working | Medium: paired dimension derivation. | 01–01 | UI/GemPool | Confirm `p`. |
| `pt` / chunk | 285 | Derived `Ye / 2` (=12). | half unknown width | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `ct` / chunk | 286 | Derived `Ze / 2` (=12). | half unknown height | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `t` / chunk (line 287) | 287 | Derived `Qe / 2`; shadowed at 288. | — | dead | High: immediate shadow, no read. | 01–01 | Unassigned | Minifier artifact. |
| `t` / chunk (line 288) | 288 | Derived `qe / 2`; shadowed at 296. | — | dead | High: no read before shadow. | 01–01 | Unassigned | Minifier artifact. |
| `oe` / chunk | 289 | Derived `Te / 2` (=10). | half unknown dimension | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `gt` / chunk | 290 | Derived `Je / 2` (=5). | half unknown dimension | unresolved | Low. | 01–01 | UI | Identify source dimension. |
| `h` / chunk | 291 | Constant `8`; no batch-01 read. | likely grid width | working | Medium: Bejeweled board convention and paired `a`. | 01–01 | Engine/Grid | Prove from indexing loops. |
| `a` / chunk | 292 | Constant `8`; no batch-01 read. | likely grid height | working | Medium: paired with `h`. | 01–01 | Engine/Grid | Prove from indexing loops. |
| `V` / chunk | 293 | Constant `0`; no batch-01 read. | unknown enum zero | unresolved | Low. | 01–01 | Engine | Locate consumers. |
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
| `m` / chunk | 307 | Copies `math.random` alias `E`; no batch-01 call. | `random` | resolved | High: alias chain 243, 307–308. | 01–01 | Engine/Grid | Later argument patterns still pending. |
| `c` / chunk | 309 | Constant `1`; keys `Ce`; controls classic score, bar, game-over, and leaderboard branches (467, 500, 536, 611, 881). | `GAME_MODE_CLASSIC` | resolved | High: repeated explicit classic behavior. | 01–02 | Core/Constants | None for identity. |
| `ae` / chunk | 310 | Constant `2`; used as `Ce` key (312). | timed game mode | working | Medium: paired mode enum; no branch yet. | 01–01 | Engine/Scoring | Confirm later use. |
| `k` / chunk | 311 | Constant `3`; keys `Ce`; controls the `flightOptionWindow.learning` timer branches (552, 639). | `GAME_MODE_FLIGHT_LEARNING` | resolved | High: two explicit learning-mode branches. | 01–02 | Core/Constants | Broader flight-mode naming may refine. |
| `T` / chunk | 312 | Nine-number array indexed by `n.combo`, capped at final entry (977–980). | `comboBaseScores` | resolved | High: direct scoring use. | 01–02 | Engine/Scoring | Confirm whether combo resets per move/cascade. |
| `Ce` / chunk | 312 | Mode-keyed values used as `500 * Ce[o]` for non-classic bar maximum (626). | `modeScoreRangeMultiplier` | resolved | High: direct arithmetic consumer. | 01–02 | Core/Constants | Why classic entry exists despite bypass. |
| `j` / chunk (byte alias) | 312 | Copies `string.byte`; called by codec helpers (667, 720, 764), then shadowed by function at 769; earlier closures retain it. | `stringByte` | resolved | High: direct alias/calls and lexical capture. | 01–02 | Core/SavedVariables | None. |
| `P` / chunk (char alias) | 313 | Copies `string.char`; called inside encoder `x` (692, 694, 708), then shadowed by function at 735; `x` retains it. | `stringChar` | resolved | High: direct alias/calls and lexical capture. | 01–02 | Core/SavedVariables | None. |
| `d` / chunk | 314 | Copies `math.floor`; called for timer fields and codec/game metrics (558, 564, 582, 677, 687, 698, 878–879, 900, 911, 933). | `floor` | resolved | High: direct alias and calls. | 01–02 | Core | None. |
| `u` / chunk | 315 | Receives `table.insert`; called by `st` at 457. | `tableInsert` | resolved | High: direct alias and call. | 01–01 | Core | None. |
| `B` / chunk | 316 | Receives `table.remove`; no batch-01 call. | `tableRemove` | resolved | High: direct alias. | 01–01 | Core | Call sites pending. |
| `Y` / chunk | 317 | Copies `tostring`; converts decoded checksum/rank values (750, 890, 912). | `toString` | resolved | High: direct alias and calls. | 01–02 | Core | None. |
| `G` / chunk | 318 | Copies `string.sub`; slices checksum payloads, decimal digits, and rank prefixes (745–755, 777–778). | `stringSub` | resolved | High: direct alias and calls. | 01–02 | Core/SavedVariables | None. |
| `D` / chunk | 319 | Copies `tonumber`; parses checksum digits and rank prefixes (751–755, 777). | `toNumber` | resolved | High: direct alias and calls. | 01–02 | Core/SavedVariables | None. |
| `R` / chunk | 320 | Copies `type`; rejects non-string authenticated scores (742). | `valueType` | resolved | High: direct alias and call. | 01–02 | Core/SavedVariables | None. |
| `re` / chunk (numeric overwrite) | 321 | Overwrites earlier binding with `40`; no batch-01 read. | unknown constant 40 | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `z` / chunk (numeric overwrite) | 322 | Overwrites earlier binding with `7`; no batch-01 read. | unknown enum seven | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `o` / chunk | 323 | Eight empty subtables written by loop (324–326); exported as `Bejeweled.debugArray` (442); used as local shadow elsewhere. | debug array | resolved | High: explicit export name (442). | 01–01 | Core/Init | Determine runtime semantics later. |
| `e` / debug-array loop | 324 | Loop 1–8; indexes `o` for writes (325). | `index` | resolved | High: direct loop role. | 01–01 | Core/Init | None. |
| `v` / chunk | 327 | Forward declaration; used as key for authenticated personal-best payload in `n.statDB` (887, 900). | `statEncodedScoreKey` | working | Medium: value type is proven; concrete selected key is not. | 01–02 | Core/SavedVariables | Find assignments for mode-specific key. |
| `I` / chunk | 327 | Forward declaration; used as key for numeric personal-best metric in `n.statDB` (885–886, 898–899). | `statNumericScoreKey` | working | Medium: value type is proven; concrete selected key is not. | 01–02 | Core/SavedVariables | Find assignments for mode-specific key. |
| `ge` / chunk | 327 | Declared nil; no batch-01 use. | unknown forward declaration | unresolved | Low. | 01–01 | Unassigned | Find assignment/function role. |
| `we` / chunk | 327 | Forward declaration; assigned `true` when max-score level-up begins (529). | `levelUpPendingFlag` | working | Low: writer observed, reader absent. | 01–02 | Engine/Scoring, UI/Animations | Find consumer/reset. |
| `r` / chunk | 333 | Six-entry array of four-number direction/offset tuples. | neighbor/offset patterns | working | Medium: signed coordinate-like tuples. | 01–01 | Engine/Matches | Establish tuple field semantics. |
| `n` / chunk | 334 | Exported current-game state; score/level/mode/stats/combo/game-over/statDB fields are read or written throughout score finalization and `M` (443, 464–529, 874–999). | `currentGame` | resolved | High: explicit debug export and repeated state transitions. | 01–02 | Engine/Grid, Engine/Scoring | Full dynamic table shape still grows later. |
| `C` / chunk function | 444 | Called nowhere in batch; returns a backdrop descriptor table (445–452). | `createTooltipBackdropInfo` | working | High for return contract; action/name uncertain. | 01–01 | UI/Backdrops | Is each call a fresh mutable table by design? |
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
| `X` / chunk function | 662 | Converts legacy base-70 text to number with optional centered signed offset (663–680). | `decodeBase70` | resolved | High: complete body. | 02–02 | Core/SavedVariables | Preserve malformed-input behavior. |
| `n`,`l` / `X` parameters | 662 | Encoded string and boolean signed-mode flag (665–679). | `encoded`, `signed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / `X` local | 663 | Numeric accumulator updated by positional base-70 arithmetic and returned (673–679). | `value` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `o` / `X` first declaration | 664 | Nil declaration shadowed at 665 before read. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `e` / `X` local | 664 | Receives each byte/digit and is normalized before arithmetic (667–673). | `digit` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `o` / `X` second declaration | 665 | Starts at `#encoded-1`, supplies exponent, decrements each loop (673–674). | `exponent` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `i` / `X` loop | 666 | Iterates encoded character positions 1..length (667). | `index` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `x` / chunk function | 682 | Converts a number to fixed-width legacy base-70 text with optional centered signed offset (683–711). | `encodeBase70` | resolved | High: complete body. | 02–02 | Core/SavedVariables | Preserve overflow recursion behavior. |
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
| `P` / chunk function | 735 | Shadows char alias; prefixes packed checksum to payload (736–739). | `authenticateScore` | resolved | High: complete body and later uses. | 02–02 | Core/SavedVariables | None. |
| `e`,`t` / `P` parameters | 735 | Payload and optional checksum seed; parameter `t` is shadowed at 736 after initializer access. | `payload`, `seed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `t` / `P` defaulted seed | 736 | Defaults parameter seed, then is consumed by `H` initializer at 737 and shadowed by returned digit. | `seed` | shadowed | High. | 02–02 | Core/SavedVariables | None. |
| `l`,`o`,`t`,`i`,`n` / `P` checksum outputs | 737 | Five checksum digits returned by first `H`, packed in reverse variable order into decimal positions at 738. | `d1`, `d2`, `d3`, `d4`, `d5` | resolved | High for positional role; descriptive checksum names intentionally neutral. | 02–02 | Core/SavedVariables | Semantic digit ordering is legacy-specific. |
| `fe` / chunk function | 741 | Validates checksum prefix and returns authenticated payload or nil (742–759). | `verifyScore` | resolved | High: complete body. | 02–02 | Core/SavedVariables | None. |
| `e`,`t` / `fe` parameters | 741 | Authenticated string and optional checksum seed; `e` later shadowed after prefix/payload extraction. | `encodedScore`, `seed` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `r`,`n` / `fe` locals | 745, 746 | Three-character checksum prefix and remaining payload. | `checksumPrefix`, `payload` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `d`,`h`,`c`,`S`,`s` / `fe` expected digits | 748 | Five checksum digits returned from first `H` and compared positionally (751–756). | `expected1`…`expected5` | resolved | High for positional role. | 02–02 | Core/SavedVariables | Neutral names preserve unusual order. |
| `l`,`i`,`t`,`o`,`a` / `fe` actual digits | 749 | Decimal digits parsed from decoded prefix positions 6..2 and compared to expected digits (751–756). | `actual1`…`actual5` | resolved | High for positional role. | 02–02 | Core/SavedVariables | None. |
| `e` / `fe` nested local | 750 | Shadows encoded-score parameter with decimal string of decoded checksum prefix. | `decodedChecksum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `H` / second chunk function | 761 | Shadows first `H`; returns sum of all input bytes (762–767). | `byteSum` | resolved | High: complete body and consumers. | 02–02 | Core/SavedVariables | None. |
| `t` / second `H` parameter | 761 | Input string iterated byte-by-byte. | `text` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `n` / second `H` local | 762 | Initialized zero but immediately shadowed by loop variable at 763. | — | dead | High. | 02–02 | Unassigned | Minifier artifact. |
| `e` / second `H` local | 762 | Accumulates byte values and is returned (764–766). | `sum` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `n` / second `H` loop | 763 | Character index 1..length. | `index` | resolved | High. | 02–02 | Core/SavedVariables | None. |
| `j` / chunk function | 769 | Shadows byte alias; validates and merges variadic leaderboard entries (770–870). | `mergeLeaderboardScores` | resolved | High: complete body. | 02–02 | Core/SavedVariables, Engine/Scoring | Network parser/callers remain to inventory. |
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
| `_` / implicit chunk global | external; write 925 | Receives three ignored positional returns through the same repeated target; the last assignment survives globally. | discarded friend-info return | unresolved | High for accidental global write; later reads not yet audited. | 02–02 | Core/Init | Does any later code depend on global `_`? |
| `online` / implicit chunk global | external; write/read 925 | Receives the fifth friend-info return and immediately gates whisper publishing. | `friendOnline` | working | High for legacy intended role; API return contract pending. | 02–02 | Core/Init | Must become local and use current API shape. |
| `mod` / external function | external; calls 690, 721, 727–731 | Computes remainder for base-70 digits, parity, and checksum decimal digits. | `modulo` | resolved | High: arithmetic operands/results are explicit. | 02–02 | Core/SavedVariables | Choose Lua-5.1-compatible qualified implementation later. |
| `M` / chunk function | 953 | Partial match-scoring/animation function; continues after line 1000. | `scoreMatch` | working | Medium: scoring prefix observed only. | 02–02 | Engine/Matches, Engine/Scoring | Complete in batch 03. |
| `l` / `M` parameter | 953 | Compared as match length ≥3, =4, or ≥5 (961, 983–986). | `matchLength` | resolved | High for observed role. | 02–02 | Engine/Matches | None for prefix. |
| `s`,`S` / `M` parameters | 953 | Not read through line 1000. | unknown | unresolved | Low. | 02–02 | Unassigned | Await batch 03. |
| `f` / `M` parameter | 953 | Boolean-like flag gates match-4 skill and +25 bonus (988–990). | `createdPowerGem` | working | Medium: skill association. | 02–02 | Engine/Matches, Engine/Scoring | Confirm semantics in continuation/callers. |
| `m` / `M` parameter | 953 | Boolean-like flag gates special-destruction scoring/sound (992–999). | `specialDestroyed` | working | Medium. | 02–02 | Engine/Matches, Engine/Scoring | Exact special object/type. |
| `a` / `M` parameter | 953 | When special flag set, zero selects hyper +75; nonzero selects electro +20 (993–998). | `specialType` | working | Medium. | 02–02 | Engine/Matches | Identify enum values. |
| `c`,`h`,`u` / `M` parameters | 953 | Not read through line 1000. | unknown | unresolved | Low. | 02–02 | Unassigned | Await batch 03. |
| `t` / `M` local | 957 | Point accumulator: combo base plus length/power/special bonuses (978–998). | `points` | working | High for observed prefix; function incomplete. | 02–02 | Engine/Scoring | Further modifiers/application await batch 03. |
| `r` / `M` local | 958 | Aliases `Bejeweled.animator`; not used through line 1000. | `animator` | working | High for alias, incomplete use. | 02–02 | UI/Animations | Await batch 03. |
| `o` / `M` local | 959 | Accumulates return values from `CheckSkill` calls (962–975, 989). | `skillPointsGained` | working | High for prefix. | 02–02 | Engine/Scoring | How applied/reported later. |
| `g` / `M` local | 960 | Captures player skill rank; not used through line 1000. | `skillRank` | working | High for alias, incomplete use. | 02–02 | Engine/Scoring | Await batch 03. |
| `i` / `M` combo local | 964 | Aliases incremented `n.combo`; drives thresholds and `T` index (965–980). | `comboCount` | resolved | High. | 02–02 | Engine/Scoring | Reset timing pending. |

## Batch 02 resolution policy

Complete helper bodies are resolved when their transformation and side effects are fully visible, even though later method attachment may supply the eventual public name. Lexically captured standard-library bindings are retained as live entries after same-spelling shadow declarations. The incomplete `M` function and all unread parameters remain working or unresolved until batch 03.
