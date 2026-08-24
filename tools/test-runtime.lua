local function LoadAddonFile(path, addon)
	local chunk, reason = loadfile(path)
	assert(chunk, reason)
	chunk("Bejeweled", addon)
end

local function AssertEqual(actual, expected, message)
	if actual ~= expected then
		error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
	end
end

local function MakeRandom(seed)
	local state = seed
	return function(minimum, maximum)
		state = (state * 1103515245 + 12345) % 2147483648
		return minimum + (state % (maximum - minimum + 1))
	end
end

local eventFrame = { scripts = {} }
function eventFrame:RegisterEvent(event)
	self.registeredEvent = event
	return true
end
function eventFrame:UnregisterEvent(event)
	if self.registeredEvent == event then
		self.registeredEvent = nil
	end
	return true
end
function eventFrame:SetScript(scriptName, callback)
	self.scripts[scriptName] = callback
end

function CreateFrame(frameType)
	AssertEqual(frameType, "Frame", "initializer frame type")
	return eventFrame
end

local addon = {}
LoadAddonFile("Bejeweled/Core/Init.lua", addon)
LoadAddonFile("Bejeweled/Core/Constants.lua", addon)
LoadAddonFile("Bejeweled/Core/SavedVariables.lua", addon)
LoadAddonFile("Bejeweled/Engine/Grid.lua", addon)
LoadAddonFile("Bejeweled/Engine/Matches.lua", addon)
LoadAddonFile("Bejeweled/Engine/Cascade.lua", addon)
LoadAddonFile("Bejeweled/Engine/Scoring.lua", addon)

AssertEqual(eventFrame.registeredEvent, "ADDON_LOADED", "initializer event registration")
AssertEqual(addon.Constants.GRID_WIDTH, 8, "grid width")
AssertEqual(addon.Constants.GRID_HEIGHT, 8, "grid height")
AssertEqual(addon.Constants.GEM_COLOR_COUNT, 7, "gem color count")

local existingSettings = { gameAlpha = 0.65, customSetting = "preserved" }
local account = { customAccountField = true }
local profile = { settings = existingSettings, customProfileField = true }
local initializedAccount, initializedProfile = addon.SavedVariables:Initialize(account, profile)
assert(initializedAccount == account, "account table identity changed")
assert(initializedProfile == profile, "profile table identity changed")
assert(initializedProfile.settings == existingSettings, "settings table identity changed")
AssertEqual(initializedProfile.settings.gameAlpha, 0.65, "existing setting")
AssertEqual(initializedProfile.settings.defaultPublish, "GUILD", "default publish channel")
AssertEqual(initializedProfile.settings.customSetting, "preserved", "unknown setting")
AssertEqual(initializedProfile.stats.gemMatch[8], 0, "gem-match wire width")
AssertEqual(initializedProfile.skill.friendList.c, 0, "friend counter")
AssertEqual(initializedProfile.scoreList.friends.classic[1][4], "9VW``nt", "classic signed fallback")
AssertEqual(initializedProfile.scoreList.guild.timed[10][4], "8H4`a3", "timed signed fallback")
assert(initializedProfile.scoreList.friends.classic ~= initializedProfile.scoreList.guild.classic, "leaderboard defaults share mutable tables")
assert(BejeweledData == account, "account SavedVariable was not installed")
assert(BejeweledProfile == profile, "profile SavedVariable was not installed")

local firstGrid = addon.Grid:New(MakeRandom(8675309))
local secondGrid = addon.Grid:New(MakeRandom(8675309))
assert(firstGrid:Fill(), "first deterministic fill failed")
assert(secondGrid:Fill(), "second deterministic fill failed")
assert(not firstGrid:HasAnyMatch(), "generated board contains an immediate match")
assert(firstGrid:FindLegalMove(), "generated board has no legal move")

local firstWire = firstGrid:ExportLegacyBoard()
local secondWire = secondGrid:ExportLegacyBoard()
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(firstWire[y][x], secondWire[y][x], "deterministic board cell")
	end
end

for seed = 1, 50 do
	local generatedGrid = addon.Grid:New(MakeRandom(seed))
	assert(generatedGrid:Fill(), "seeded board generation failed")
	assert(not generatedGrid:HasAnyMatch(), "seeded board contains an immediate match")
	assert(generatedGrid:FindLegalMove(), "seeded board has no legal move")
end

local swapGrid = addon.Grid:New()
swapGrid:Set(1, 1, 1)
swapGrid:Set(2, 1, 2)
swapGrid:Set(3, 1, 1)
swapGrid:Set(2, 2, 1)
swapGrid:Set(4, 1, 4)
swapGrid:Set(5, 1, 5)
assert(swapGrid:IsLegalSwap(2, 1, 2, 2), "known match-producing swap was rejected")
assert(not swapGrid:IsLegalSwap(4, 1, 5, 1), "known non-matching swap was accepted")
local moveFrom, moveTo = swapGrid:FindLegalMove()
assert(moveFrom and moveTo, "known legal move was not found")

swapGrid:Set(7, 7, addon.Constants.HYPER_CONTENTS)
swapGrid:Set(8, 7, 3)
assert(swapGrid:IsLegalSwap(7, 7, 8, 7), "hyper-gem swap was rejected")

local legacyRows = {}
for y = 1, addon.Constants.GRID_HEIGHT do
	legacyRows[y] = {}
	for x = 1, addon.Constants.GRID_WIDTH do
		legacyRows[y][x] = 0
	end
end
legacyRows[1][1] = 13
legacyRows[1][2] = 9
local loadedGrid = addon.Grid:New()
loadedGrid:LoadLegacyBoard(legacyRows)
AssertEqual(loadedGrid:Get(1, 1).contents, 3, "big-star color decode")
assert(loadedGrid:Get(1, 1).bigStar, "big-star marker decode")
AssertEqual(loadedGrid:Get(2, 1).contents, 9, "hyper-gem decode")
AssertEqual(loadedGrid:ExportLegacyBoard()[1][1], 13, "big-star wire round trip")

local invalidRows = {}
for y = 1, addon.Constants.GRID_HEIGHT do
	invalidRows[y] = {}
	for x = 1, addon.Constants.GRID_WIDTH do
		invalidRows[y][x] = 1
	end
end
invalidRows[8][8] = 10
local beforeInvalidLoad = loadedGrid:ExportLegacyBoard()
local loadedInvalid = pcall(function()
	loadedGrid:LoadLegacyBoard(invalidRows)
end)
assert(not loadedInvalid, "invalid legacy big-star value was accepted")
local afterInvalidLoad = loadedGrid:ExportLegacyBoard()
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(afterInvalidLoad[y][x], beforeInvalidLoad[y][x], "invalid legacy load was not atomic")
	end
end

local matchGrid = addon.Grid:New()
matchGrid:Set(2, 2, 3)
matchGrid:Set(3, 2, 3)
matchGrid:Set(4, 2, 3)
local threeMatch = addon.Matches:Find(matchGrid)
assert(threeMatch.hasMatches, "three-gem match was not found")
AssertEqual(#threeMatch.groups, 1, "three-gem group count")
AssertEqual(threeMatch.cellCount, 3, "three-gem matched cell count")
AssertEqual(threeMatch.groups[1].axis, "horizontal", "three-gem primary axis")
assert(not threeMatch.groups[1].special, "three-gem match created a special gem")
assert(threeMatch.marks[2][2].horizontal, "horizontal match mark was not reported")
assert(not matchGrid:Get(2, 2).markX, "match discovery mutated a grid cell")

matchGrid:Reset()
for x = 2, 5 do
	matchGrid:Set(x, 3, 4)
end
local preferredPowerCell = matchGrid:Get(4, 3)
local fourMatch = addon.Matches:Find(matchGrid, { preferredCell = preferredPowerCell })
AssertEqual(fourMatch.groups[1].special.kind, "power", "four-gem classification")
assert(fourMatch.groups[1].special.cell == preferredPowerCell, "preferred power-gem position was ignored")

matchGrid:Reset()
for y = 1, 5 do
	matchGrid:Set(6, y, 5)
end
local fiveMatch = addon.Matches:Find(matchGrid, { random = function() return 2 end })
AssertEqual(fiveMatch.groups[1].special.kind, "hyper", "five-gem classification")
assert(fiveMatch.groups[1].special.cell == matchGrid:Get(6, 2), "hyper-gem fallback position was not deterministic")

matchGrid:Reset()
matchGrid:Set(3, 1, 6)
matchGrid:Set(3, 2, 6)
matchGrid:Set(3, 3, 6)
matchGrid:Set(2, 3, 6)
matchGrid:Set(4, 3, 6)
local tMatch = addon.Matches:Find(matchGrid)
AssertEqual(#tMatch.groups, 1, "T-match group count")
AssertEqual(tMatch.groups[1].clearCount, 5, "T-match clear count")
AssertEqual(tMatch.groups[1].special.kind, "power", "T-match classification")
assert(tMatch.groups[1].special.cell == matchGrid:Get(3, 3), "T-match special was not placed at the intersection")

matchGrid:Set(1, 3, 6)
matchGrid:Set(5, 3, 6)
local longCrossMatch = addon.Matches:Find(matchGrid)
AssertEqual(longCrossMatch.groups[1].special.kind, "hyper", "five-wide cross classification")
assert(longCrossMatch.groups[1].special.cell == matchGrid:Get(3, 3), "cross hyper gem was not placed at the intersection")
matchGrid:Set(3, 3, 6, true)
local powerOccupiedCross = addon.Matches:Find(matchGrid, { random = function() return 1 end })
assert(powerOccupiedCross.groups[1].special.cell == matchGrid:Get(3, 1), "hyper gem did not fall back from a power-gem intersection")

matchGrid:Reset()
for y = 1, 3 do
	matchGrid:Set(2, y, 2)
	matchGrid:Set(4, y, 2)
end
matchGrid:Set(3, 3, 2)
local overlappingMatches = addon.Matches:Find(matchGrid)
AssertEqual(#overlappingMatches.groups, 2, "overlapping match group count")
AssertEqual(overlappingMatches.groups[1].clearCount, 5, "first overlapping group count")
AssertEqual(overlappingMatches.groups[2].clearCount, 5, "second overlapping group count")
AssertEqual(overlappingMatches.cellCount, 7, "overlapping unique cell count")

matchGrid:Reset()
matchGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
matchGrid:Set(2, 8, addon.Constants.HYPER_CONTENTS)
matchGrid:Set(3, 8, addon.Constants.HYPER_CONTENTS)
local hyperOnly = addon.Matches:Find(matchGrid)
assert(not hyperOnly.hasMatches, "hyper gems were treated as an ordinary color match")

for seed = 1, 100 do
	local random = MakeRandom(seed * 97)
	matchGrid:Reset()
	for y = 1, addon.Constants.GRID_HEIGHT do
		for x = 1, addon.Constants.GRID_WIDTH do
			matchGrid:Set(x, y, random(1, addon.Constants.GEM_COLOR_COUNT))
		end
	end
	local discovered = addon.Matches:Find(matchGrid, { random = random })
	local discoveredCells = {}
	for index = 1, #discovered.cells do
		discoveredCells[discovered.cells[index]] = true
	end
	for y = 1, addon.Constants.GRID_HEIGHT do
		for x = 1, addon.Constants.GRID_WIDTH do
			local cell = matchGrid:Get(x, y)
			AssertEqual(discoveredCells[cell] and true or false, matchGrid:HasMatchAt(x, y), "random-board match coverage")
		end
	end
end

local function FillStablePattern(grid)
	grid:Reset()
	for y = 1, addon.Constants.GRID_HEIGHT do
		for x = 1, addon.Constants.GRID_WIDTH do
			grid:Set(x, y, ((x + (y * 2)) % addon.Constants.GEM_COLOR_COUNT) + 1)
		end
	end
	assert(not grid:HasAnyMatch(), "stable cascade test pattern contains a match")
end

local cascadeGrid = addon.Grid:New(MakeRandom(424242))
FillStablePattern(cascadeGrid)
for x = 1, 3 do
	cascadeGrid:Set(x, 8, 1)
end
local simpleCascade = addon.Cascade:Step(cascadeGrid, addon.Matches:Find(cascadeGrid), {
	random = MakeRandom(1234),
	requireLegalMove = false,
})
AssertEqual(simpleCascade.matchedCellCount, 3, "simple cascade match count")
AssertEqual(simpleCascade.clearCount, 3, "simple cascade clear count")
AssertEqual(simpleCascade.removedCount, 3, "simple cascade removed count")
AssertEqual(#simpleCascade.moves, 21, "simple cascade gravity move count")
AssertEqual(#simpleCascade.refills, 3, "simple cascade refill count")
AssertEqual(cascadeGrid:Get(1, 8).contents, 2, "first compacted bottom gem")
AssertEqual(cascadeGrid:Get(2, 8).contents, 3, "second compacted bottom gem")
AssertEqual(cascadeGrid:Get(3, 8).contents, 4, "third compacted bottom gem")

FillStablePattern(cascadeGrid)
for x = 2, 5 do
	cascadeGrid:Set(x, 8, 7)
end
local powerTarget = cascadeGrid:Get(4, 8)
local powerCascade = addon.Cascade:Step(cascadeGrid, addon.Matches:Find(cascadeGrid, {
	preferredCell = powerTarget,
}), {
	random = MakeRandom(2345),
	requireLegalMove = false,
})
AssertEqual(#powerCascade.spawnedSpecials, 1, "power-gem spawn count")
AssertEqual(powerCascade.spawnedSpecials[1].kind, "power", "power-gem cascade kind")
AssertEqual(powerCascade.removedCount, 3, "power-gem preserved removal count")
AssertEqual(cascadeGrid:Get(4, 8).contents, 7, "power-gem preserved color")
assert(cascadeGrid:Get(4, 8).bigStar, "power gem was not preserved")

FillStablePattern(cascadeGrid)
for x = 2, 6 do
	cascadeGrid:Set(x, 8, 5)
end
local hyperTarget = cascadeGrid:Get(4, 8)
local hyperCascade = addon.Cascade:Step(cascadeGrid, addon.Matches:Find(cascadeGrid, {
	preferredCell = hyperTarget,
}), {
	random = MakeRandom(3456),
	requireLegalMove = false,
})
AssertEqual(#hyperCascade.spawnedSpecials, 1, "hyper-gem spawn count")
AssertEqual(hyperCascade.spawnedSpecials[1].kind, "hyper", "hyper-gem cascade kind")
AssertEqual(hyperCascade.removedCount, 4, "hyper-gem preserved removal count")
AssertEqual(cascadeGrid:Get(4, 8).contents, addon.Constants.HYPER_CONTENTS, "hyper gem was not preserved")
assert(not cascadeGrid:Get(4, 8).bigStar, "hyper gem retained a power marker")

FillStablePattern(cascadeGrid)
for x = 3, 5 do
	cascadeGrid:Set(x, 8, 6, x == 4)
end
cascadeGrid:Set(5, 7, cascadeGrid:Get(5, 7).contents, true)
local explosionCascade = addon.Cascade:Step(cascadeGrid, addon.Matches:Find(cascadeGrid), {
	random = MakeRandom(4567),
	requireLegalMove = false,
})
AssertEqual(explosionCascade.triggeredPowerCount, 2, "chained power-gem trigger count")
AssertEqual(explosionCascade.clearCount, 11, "chained power-gem neighborhood clear count")
AssertEqual(explosionCascade.removedCount, 11, "chained power-gem neighborhood removal count")

FillStablePattern(cascadeGrid)
for x = 1, 3 do
	cascadeGrid:Set(x, 8, 1)
end
local resolvedCascade = addon.Cascade:Resolve(cascadeGrid, {
	random = MakeRandom(5678),
	requireLegalMove = false,
})
assert(resolvedCascade.stable, "cascade resolution did not report stability")
assert(resolvedCascade.cascadeCount >= 1, "cascade resolution skipped an existing match")
assert(not cascadeGrid:HasAnyMatch(), "cascade resolution left a match on the board")

for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		cascadeGrid:Set(x, y, 1)
	end
end
local limitedCascadeSucceeded = pcall(function()
	addon.Cascade:Resolve(cascadeGrid, {
		random = function() return 1 end,
		requireLegalMove = false,
		maximumCascades = 1,
	})
end)
assert(not limitedCascadeSucceeded, "cascade limit did not reject an endless refill")
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(cascadeGrid:Get(x, y).contents, 1, "failed cascade resolution was not atomic")
	end
end

local scoringProfile = addon.SavedVariables:CreateDefaultProfile()
local scoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local simpleScoring = addon.Scoring:ApplyCascade(scoringState, { steps = { simpleCascade } }, scoringProfile, {
	random = function() return 1 end,
})
AssertEqual(simpleScoring.points, 10, "classic three-match score")
AssertEqual(scoringState.score, 10, "classic score state")
AssertEqual(simpleScoring.combo, 1, "classic three-match combo")
AssertEqual(scoringState.combo, 0, "combo was not reset after a stable move")
AssertEqual(scoringState.largestCombo, 1, "largest combo state")
AssertEqual(scoringState.largestCascade, 3, "largest cascade state")
AssertEqual(scoringProfile.stats.totalGemsMatched, 3, "legacy refill-backed gem statistic")
AssertEqual(scoringProfile.stats.gemMatch[1], 1, "per-color match statistic")
AssertEqual(scoringProfile.skill.skillPoints, 1, "match-three skill gain")

local powerScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local powerScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local powerScoring = addon.Scoring:ApplyCascade(powerScoringState, { steps = { powerCascade } }, powerScoringProfile, {
	random = function() return 1 end,
})
AssertEqual(powerScoring.points, 45, "four-match power-gem score")
AssertEqual(powerScoringProfile.stats.totalPowerGems, 1, "power-gem creation statistic")

local hyperScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local hyperScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local hyperScoring = addon.Scoring:ApplyCascade(hyperScoringState, { steps = { hyperCascade } }, hyperScoringProfile, {
	random = function() return 1 end,
})
AssertEqual(hyperScoring.points, 30, "five-match hyper-gem score")
AssertEqual(hyperScoringProfile.stats.totalHyperGems, 1, "hyper-gem creation statistic")

local explosionScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local explosionScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local explosionScoring = addon.Scoring:ApplyCascade(
	explosionScoringState,
	{ steps = { explosionCascade } },
	explosionScoringProfile,
	{ random = function() return 1 end }
)
AssertEqual(explosionScoring.points, 75, "chained power-gem score")
AssertEqual(#explosionScoring.scoreEvents, 2, "chained power-gem score event count")
AssertEqual(explosionScoring.scoreEvents[2].kind, "power-trigger", "chained power-gem score event kind")
AssertEqual(explosionScoring.scoreEvents[2].points, 40, "second power-gem explosion score")

local crossPowerGrid = addon.Grid:New()
crossPowerGrid:Set(3, 1, 6)
crossPowerGrid:Set(3, 2, 6)
crossPowerGrid:Set(3, 3, 6, true)
crossPowerGrid:Set(2, 3, 6)
crossPowerGrid:Set(4, 3, 6)
local crossPowerCascade = addon.Cascade:Step(crossPowerGrid, addon.Matches:Find(crossPowerGrid), {
	random = MakeRandom(6789),
	requireLegalMove = false,
})
AssertEqual(crossPowerCascade.matchAwards[1].powerTriggerCount, 2, "cross intersection power mark count")
local crossPowerProfile = addon.SavedVariables:CreateDefaultProfile()
local crossPowerState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local crossPowerScoring = addon.Scoring:ApplyCascade(
	crossPowerState,
	{ steps = { crossPowerCascade } },
	crossPowerProfile,
	{ random = function() return 1 end }
)
AssertEqual(crossPowerScoring.points, 95, "cross-intersection power-gem score")

local timedScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local timedScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_TIMED)
local timedScoring = addon.Scoring:ApplyCascade(timedScoringState, { steps = { simpleCascade } }, timedScoringProfile, {
	random = function() return 1 end,
})
AssertEqual(timedScoring.points, 150, "timed three-match score")
AssertEqual(timedScoringState.pointsToLevelUp, 7500, "timed initial level threshold")

local tieredSkillProfile = addon.SavedVariables:CreateDefaultProfile()
tieredSkillProfile.skill.skillPoints = 10
local failedTieredSkill = addon.Scoring:AttemptSkill(
	tieredSkillProfile,
	addon.Constants.SKILL_TYPE_MATCH,
	addon.Constants.SKILL_MATCH3,
	{ random = function() return 100 end }
)
AssertEqual(failedTieredSkill.gained, 0, "tier-one skill failure")
AssertEqual(tieredSkillProfile.skill.skillPoints, 10, "failed skill changed points")
local gainedTieredSkill = addon.Scoring:AttemptSkill(
	tieredSkillProfile,
	addon.Constants.SKILL_TYPE_MATCH,
	addon.Constants.SKILL_MATCH3,
	{ random = function() return 1 end }
)
AssertEqual(gainedTieredSkill.gained, 1, "tier-one skill gain")
AssertEqual(tieredSkillProfile.skill.skillPoints, 11, "successful skill points")

local achievementProfile = addon.SavedVariables:CreateDefaultProfile()
achievementProfile.skill.skillPoints = 150
local achievement = addon.Scoring:AttemptSkill(
	achievementProfile,
	addon.Constants.SKILL_TYPE_ACHIEVEMENT,
	addon.Constants.ACHIEVEMENT_POWER100,
	{ random = function() return 1 end }
)
assert(achievement.completed, "achievement was not completed")
AssertEqual(achievement.awardAmount, 5, "achievement award amount")
assert(achievementProfile.skill.gainAchieve4, "achievement wire flag was not set")

local levelingProfile = addon.SavedVariables:CreateDefaultProfile()
local levelingState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC, { score = 490 })
local thresholdScoring = addon.Scoring:ApplyCascade(levelingState, { steps = { simpleCascade } }, levelingProfile, {
	random = function() return 1 end,
})
assert(thresholdScoring.levelPending, "level threshold was not detected")
local levelAdvance = addon.Scoring:AdvanceLevel(levelingState, levelingProfile, {
	random = function() return 1 end,
})
AssertEqual(levelAdvance.level, 2, "advanced level")
AssertEqual(levelAdvance.pointMultiplier, 1.5, "advanced level point multiplier")
AssertEqual(levelAdvance.pointsToLevelUp, 1975, "advanced level threshold")
AssertEqual(levelingProfile.stats.classic.highestLevel, 2, "classic highest-level statistic")

eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "AnotherAddon", false)
assert(not addon.initialized, "foreign ADDON_LOADED initialized the addon")
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "Bejeweled", false)
assert(addon.initialized, "addon initialization did not complete")
assert(addon.grid, "addon initialization did not create a grid")
assert(eventFrame.registeredEvent == nil, "initializer event was not unregistered")
local initializedGrid = addon.grid
addon:Initialize({}, {})
assert(addon.grid == initializedGrid, "addon initialization is not idempotent")

print("Runtime verification passed: SavedVariables and deterministic gameplay engine.")
