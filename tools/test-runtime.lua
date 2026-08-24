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

eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "AnotherAddon", false)
assert(not addon.initialized, "foreign ADDON_LOADED initialized the addon")
eventFrame.scripts.OnEvent(eventFrame, "ADDON_LOADED", "Bejeweled", false)
assert(addon.initialized, "addon initialization did not complete")
assert(addon.grid, "addon initialization did not create a grid")
assert(eventFrame.registeredEvent == nil, "initializer event was not unregistered")
local initializedGrid = addon.grid
addon:Initialize({}, {})
assert(addon.grid == initializedGrid, "addon initialization is not idempotent")

print("Runtime verification passed: SavedVariables, deterministic 8x8 grid, and pure match discovery.")
