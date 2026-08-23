# Shortened identifier ledger

Each row identifies one declaration, not merely one spelling. `chunk` means the outer lexical scope of `Legacy/Bejeweled_Mainline.lua`; narrower scopes are named explicitly. Working names are hypotheses unless status is `resolved`. Batch 01 spans lines 1–500, so later-use claims remain open until their scheduled batch is analyzed.

| Legacy identifier / lexical scope | Decl. | Observed reads, writes, calls, keys, arithmetic | Working or proposed name | Status | Confidence / evidence | First–last batch | Target subsystem | Open question |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `t` / chunk (first binding) | 4 | String initializer only before shadow at 186. | `addonRootPath` | dead | High: path literal at 4; no read before 186. | 01–01 | Core/Constants | Was elimination intentional? |
| `l` / chunk | 5 | Path initializer; no batch-01 read. | `imageRootPath` | working | High: literal ends in `images\` (5). | 01–01 | Core/Constants | Confirm every later consumer. |
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
| `S` / chunk | 244 | Constant `-1`; no batch-01 read. | unknown sentinel | unresolved | Low. | 01–01 | Engine | Locate consumers. |
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
| `te` / chunk | 261 | Constant `10`; no batch-01 read. | unknown constant | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
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
| `c` / chunk | 309 | Constant `1`; used as `Ce` key (312) and compared with `o.gameMode` (467, 500). | classic game mode | working | High: score branch plus legacy constants context (467–500). | 01–01 | Engine/Scoring | Confirm all game modes. |
| `ae` / chunk | 310 | Constant `2`; used as `Ce` key (312). | timed game mode | working | Medium: paired mode enum; no branch yet. | 01–01 | Engine/Scoring | Confirm later use. |
| `k` / chunk | 311 | Constant `3`; used as `Ce` key (312). | unknown third game mode | unresolved | Low: key only. | 01–01 | Engine | Identify mode. |
| `T` / chunk | 312 | Nine-number array `{10,20,30,40,60,80,110,160,210}`. | progression thresholds | working | Low: shape only. | 01–01 | Engine/Scoring | Determine units and indexing. |
| `Ce` / chunk | 312 | Table keyed by `c`,`ae`,`k` with values 1,15,15. | game-mode parameter map | working | Low: key/value shape only. | 01–01 | Engine | Identify parameter semantics. |
| `j` / chunk | 312 | Copies `string.byte`; no batch-01 call. | `stringByte` | resolved | High: direct alias from 302. | 01–01 | Core | Call sites pending. |
| `P` / chunk | 313 | Copies `string.char`; no batch-01 call. | `stringChar` | resolved | High: direct alias from 303. | 01–01 | Core | Call sites pending. |
| `d` / chunk | 314 | Copies `math.floor`; no batch-01 call. | `floor` | resolved | High: direct alias from 305. | 01–01 | Core | Call sites pending. |
| `u` / chunk | 315 | Receives `table.insert`; called by `st` at 457. | `tableInsert` | resolved | High: direct alias and call. | 01–01 | Core | None. |
| `B` / chunk | 316 | Receives `table.remove`; no batch-01 call. | `tableRemove` | resolved | High: direct alias. | 01–01 | Core | Call sites pending. |
| `Y` / chunk | 317 | Copies `tostring`; no batch-01 call. | `toString` | resolved | High: direct alias from 306. | 01–01 | Core | Call sites pending. |
| `G` / chunk | 318 | Copies `string.sub`; no batch-01 call. | `stringSub` | resolved | High: direct alias from 304. | 01–01 | Core | Call sites pending. |
| `D` / chunk | 319 | Copies `tonumber`; no batch-01 call. | `toNumber` | resolved | High: direct alias from 269. | 01–01 | Core | Call sites pending. |
| `R` / chunk | 320 | Copies `type`; no batch-01 call. | `valueType` | resolved | High: direct alias from 270. | 01–01 | Core | Call sites pending. |
| `re` / chunk (numeric overwrite) | 321 | Overwrites earlier binding with `40`; no batch-01 read. | unknown constant 40 | unresolved | Low. | 01–01 | Unassigned | Locate consumers. |
| `z` / chunk (numeric overwrite) | 322 | Overwrites earlier binding with `7`; no batch-01 read. | unknown enum seven | unresolved | Low. | 01–01 | Engine | Locate consumers. |
| `o` / chunk | 323 | Eight empty subtables written by loop (324–326); exported as `Bejeweled.debugArray` (442); used as local shadow elsewhere. | debug array | resolved | High: explicit export name (442). | 01–01 | Core/Init | Determine runtime semantics later. |
| `e` / debug-array loop | 324 | Loop 1–8; indexes `o` for writes (325). | `index` | resolved | High: direct loop role. | 01–01 | Core/Init | None. |
| `v` / chunk | 327 | Declared nil; no batch-01 use. | unknown forward declaration | unresolved | Low. | 01–01 | Unassigned | Find assignment/function role. |
| `I` / chunk | 327 | Declared nil; no batch-01 use. | unknown forward declaration | unresolved | Low. | 01–01 | Unassigned | Find assignment/function role. |
| `ge` / chunk | 327 | Declared nil; no batch-01 use. | unknown forward declaration | unresolved | Low. | 01–01 | Unassigned | Find assignment/function role. |
| `we` / chunk | 327 | Declared nil; no batch-01 use. | unknown forward declaration | unresolved | Low. | 01–01 | Unassigned | Find assignment/function role. |
| `r` / chunk | 333 | Six-entry array of four-number direction/offset tuples. | neighbor/offset patterns | working | Medium: signed coordinate-like tuples. | 01–01 | Engine/Matches | Establish tuple field semantics. |
| `n` / chunk | 334 | Game-state table; exported at 443; `score` read/written and mode/flags read/written in `ht` (464–500). | current game state | resolved | High: keys and debug export (334–340, 443, 464–500). | 01–01 | Engine/Grid, Engine/Scoring | Full table shape grows later. |
| `C` / chunk function | 444 | Called nowhere in batch; returns a backdrop descriptor table (445–452). | `createTooltipBackdropInfo` | working | High for return contract; action/name uncertain. | 01–01 | UI/Backdrops | Is each call a fresh mutable table by design? |
| `st` / chunk function | 455 | Reads `e.animated`; appends `e` to `t.animationStack`; writes flag true (456–459). | `queueAnimationOnce` | working | High: full function body. | 01–01 | UI/Animations | Identify owner and element types at call sites. |
| `t` / `st` parameter | 455 | Table-key read `t.animationStack` passed to `table.insert` (457). | `animationOwner` | working | Medium: body only. | 01–01 | UI/Animations | Concrete frame/controller type. |
| `e` / `st` parameter | 455 | Reads/writes key `animated`; inserted into stack (456–458). | `animation` | working | Medium: body only. | 01–01 | UI/Animations | Concrete table/frame type. |
| `ht` / chunk function | 462 | Score update/control-flow function begins; continues after batch boundary. | `setScore` | working | Medium: writes target/current score and checks thresholds (463–500). | 01–01 | Engine/Scoring, UI/HUD | Analyze continuation before resolving. |
| `i` / `ht` parameter | 462 | Reads `maxScore`; writes `score`; later shadowed by local at 499 (463,465,498). | `scoreDisplay` | working | Medium: observed keys. | 01–01 | UI/HUD | Concrete widget/controller type. |
| `t` / `ht` parameter | 462 | Assigned to both score fields; compared against thresholds/max (465–498). | `score` | resolved | High: direct data flow and comparisons. | 01–01 | Engine/Scoring | None for observed prefix. |
| `o` / `ht` local | 464 | Aliases `n`; score write, mode/leveledUp reads (466–500). | `gameState` | resolved | High: direct alias. | 01–01 | Engine/Scoring | Function continuation pending. |
| `i` / `ht` nested local | 499 | Shadows parameter; assigned `Bejeweled.gameStatusText`; no use before boundary. | `gameStatusText` | working | High: explicit source object (499). | 01–01 | UI/HUD | Analyze continuation. |

## Batch 01 resolution policy

Only direct standard-library aliases, loop counters with complete local bodies, explicit debug exports, and values with complete observed data flow are marked `resolved`. Numeric constants and texture tables retain `working` or `unresolved` status even where a likely role is apparent. Later batches must append evidence rather than silently promoting a proposed name.
