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
LoadAddonFile("Bejeweled/Core/Audio.lua", addon)
LoadAddonFile("Bejeweled/Core/SavedVariables.lua", addon)
LoadAddonFile("Bejeweled/Engine/Grid.lua", addon)
LoadAddonFile("Bejeweled/Engine/Matches.lua", addon)
LoadAddonFile("Bejeweled/Engine/Cascade.lua", addon)
LoadAddonFile("Bejeweled/Engine/Scoring.lua", addon)
LoadAddonFile("Bejeweled/Engine/Input.lua", addon)
LoadAddonFile("Bejeweled/Engine/Session.lua", addon)
LoadAddonFile("Bejeweled/UI/Backdrops.lua", addon)
LoadAddonFile("Bejeweled/UI/GemPool.lua", addon)
LoadAddonFile("Bejeweled/UI/Animations.lua", addon)

AssertEqual(eventFrame.registeredEvent, "ADDON_LOADED", "initializer event registration")
AssertEqual(addon.Constants.GRID_WIDTH, 8, "grid width")
AssertEqual(addon.Constants.GRID_HEIGHT, 8, "grid height")
AssertEqual(addon.Constants.GEM_COLOR_COUNT, 7, "gem color count")

local windowBackdrop = addon.Backdrops:CreateDescriptor("window")
AssertEqual(windowBackdrop.bgFile, addon.Constants.IMAGE_ROOT .. "windowBackground", "window backdrop texture")
AssertEqual(windowBackdrop.edgeFile, addon.Constants.IMAGE_ROOT .. "windowBorder", "window backdrop border")
AssertEqual(windowBackdrop.insets.right, 3, "window backdrop right inset")
windowBackdrop.insets.right = 99
AssertEqual(addon.Backdrops:CreateDescriptor("window").insets.right, 3, "backdrop preset shared mutable insets")

local customPanelBackdrop = addon.Backdrops:CreateDescriptor("panel", {
	edgeSize = 24,
	insets = { left = 7 },
})
AssertEqual(customPanelBackdrop.edgeSize, 24, "backdrop scalar override")
AssertEqual(customPanelBackdrop.insets.left, 7, "backdrop inset override")
AssertEqual(customPanelBackdrop.insets.top, 3, "backdrop inset default preservation")

local createdBackdropFrame
local backdropCreateArguments
local function CreateBackdropFrame(frameType, name, parent, template)
	backdropCreateArguments = { frameType, name, parent, template }
	createdBackdropFrame = {}
	function createdBackdropFrame:SetBackdrop(descriptor)
		self.descriptor = descriptor
	end
	function createdBackdropFrame:SetBackdropColor(red, green, blue, alpha)
		self.backgroundColor = { red, green, blue, alpha }
	end
	function createdBackdropFrame:SetBackdropBorderColor(red, green, blue, alpha)
		self.borderColor = { red, green, blue, alpha }
	end
	return createdBackdropFrame
end

local backdropParent = {}
local appliedBackdropFrame, appliedDescriptor = addon.Backdrops:CreateFrame({
	name = "BejeweledBackdropTest",
	parent = backdropParent,
	template = "UIPanelButtonTemplate",
	preset = "panel",
	backgroundColor = { 0.6, 0.6, 0.6, 1 },
	borderColor = { 1, 0.8, 0.45 },
	createFrame = CreateBackdropFrame,
})
assert(appliedBackdropFrame == createdBackdropFrame, "backdrop frame identity changed")
assert(appliedDescriptor == createdBackdropFrame.descriptor, "created backdrop descriptor was not applied")
AssertEqual(backdropCreateArguments[1], "Frame", "default backdrop frame type")
AssertEqual(backdropCreateArguments[2], "BejeweledBackdropTest", "backdrop frame name")
assert(backdropCreateArguments[3] == backdropParent, "backdrop frame parent changed")
AssertEqual(backdropCreateArguments[4], "UIPanelButtonTemplate,BackdropTemplate", "backdrop template composition")
AssertEqual(createdBackdropFrame.backgroundColor[4], 1, "backdrop background alpha")
AssertEqual(createdBackdropFrame.borderColor[3], 0.45, "backdrop border blue")
assert(createdBackdropFrame.borderColor[4] == nil, "three-channel border color gained an alpha")

local existingTemplateFrame = addon.Backdrops:CreateFrame({
	template = "BackdropTemplate",
	createFrame = CreateBackdropFrame,
})
assert(existingTemplateFrame, "existing BackdropTemplate frame was not created")
AssertEqual(backdropCreateArguments[4], "BackdropTemplate", "BackdropTemplate was duplicated")

local function CreateMockTexture(layer)
	local texture = { layer = layer }
	function texture:SetWidth(width)
		self.width = width
	end
	function texture:SetHeight(height)
		self.height = height
	end
	function texture:SetPoint(...)
		self.points = self.points or {}
		self.points[#self.points + 1] = { ... }
	end
	function texture:SetTexture(path)
		self.path = path
		return true
	end
	function texture:SetTexCoord(left, right, bottom, top)
		self.texCoord = { left, right, bottom, top }
	end
	function texture:SetBlendMode(blendMode)
		self.blendMode = blendMode
	end
	function texture:SetAlpha(alpha)
		self.alpha = alpha
	end
	function texture:SetRotation(radians)
		self.rotation = radians
	end
	function texture:Show()
		self.shown = true
	end
	function texture:Hide()
		self.shown = false
	end
	return texture
end

local function CreateMockLine(layer)
	local line = CreateMockTexture(layer)
	function line:ClearAllPoints()
		self.startPoint = nil
		self.endPoint = nil
	end
	function line:SetStartPoint(...)
		self.startPoint = { ... }
	end
	function line:SetEndPoint(...)
		self.endPoint = { ... }
	end
	function line:SetThickness(thickness)
		self.thickness = thickness
	end
	function line:SetColorTexture(red, green, blue, alpha)
		self.color = { red, green, blue, alpha }
	end
	return line
end

local gemPoolCreatedFrames = {}
local function CreateGemPoolFrame(frameType, name, parent, template)
	local frame = {
		frameType = frameType,
		name = name,
		parent = parent,
		template = template,
		scripts = {},
	}
	function frame:SetPoint(...)
		self.points = self.points or {}
		self.points[#self.points + 1] = { ... }
	end
	function frame:ClearAllPoints()
		self.points = {}
	end
	function frame:SetWidth(width)
		self.width = width
	end
	function frame:SetHeight(height)
		self.height = height
	end
	function frame:CreateTexture(name, layer)
		local texture = CreateMockTexture(layer)
		self.createdTextures = self.createdTextures or {}
		self.createdTextures[#self.createdTextures + 1] = texture
		return texture
	end
	function frame:CreateLine(name, layer)
		local line = CreateMockLine(layer)
		self.createdLines = self.createdLines or {}
		self.createdLines[#self.createdLines + 1] = line
		return line
	end
	function frame:CreateAnimationGroup()
		local group = {
			animations = {},
			scripts = {},
			playing = false,
		}
		function group:CreateAnimation(animationType)
			local animation = { animationType = animationType }
			function animation:SetDuration(duration)
				self.duration = duration
			end
			function animation:SetOrder(order)
				self.order = order
			end
			function animation:SetOffset(offsetX, offsetY)
				self.offsetX = offsetX
				self.offsetY = offsetY
			end
			function animation:SetFromAlpha(alpha)
				self.fromAlpha = alpha
			end
			function animation:SetToAlpha(alpha)
				self.toAlpha = alpha
			end
			self.animations[#self.animations + 1] = animation
			return animation
		end
		function group:SetScript(scriptName, callback)
			self.scripts[scriptName] = callback
		end
		function group:Play()
			self.playing = true
			self.paused = false
		end
		function group:Pause()
			if self.playing then
				self.playing = false
				self.paused = true
			end
		end
		function group:IsPaused()
			return self.paused and true or false
		end
		function group:Stop()
			self.playing = false
			self.paused = false
			self.stopped = true
		end
		function group:FinishForTest()
			if not self.playing then
				return false
			end
			self.playing = false
			local callback = self.scripts.OnFinished
			if callback then
				callback(self)
			end
			return true
		end
		self.animationGroups = self.animationGroups or {}
		self.animationGroups[#self.animationGroups + 1] = group
		return group
	end
	function frame:SetAlpha(alpha)
		self.alpha = alpha
	end
	function frame:SetFrameLevel(frameLevel)
		self.frameLevel = frameLevel
	end
	function frame:EnableMouse(enabled)
		self.mouseEnabled = enabled
	end
	function frame:RegisterForDrag(button)
		self.dragButton = button
	end
	function frame:SetScript(scriptName, handler)
		self.scripts[scriptName] = handler
	end
	function frame:Show()
		self.shown = true
	end
	function frame:Hide()
		self.shown = false
	end
	gemPoolCreatedFrames[#gemPoolCreatedFrames + 1] = frame
	return frame
end

local gemPoolParent = {
	GetFrameLevel = function()
		return 10
	end,
}
local enteredGem
local gemPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	handlers = {
		onEnter = function(frame)
			enteredGem = frame
		end,
	},
})
AssertEqual(#gemPoolCreatedFrames, 80, "board tile and gem frame allocation count")
AssertEqual(#gemPool.tiles, 16, "board tile count")
AssertEqual(gemPool.tiles[1].texture.path, addon.Constants.IMAGE_ROOT .. "board", "board tile texture")
AssertEqual(gemPool.tiles[1].texture.texCoord[1], 0.046875, "board tile left coordinate")
AssertEqual(gemPool.tiles[16].points[1][2], 300, "last board tile x position")
AssertEqual(gemPool.tiles[16].points[1][3], -300, "last board tile y position")

local bottomRightGem = gemPool:GetFrame(8, 8)
AssertEqual(bottomRightGem.x, 350, "bottom-right gem x position")
AssertEqual(bottomRightGem.y, 350, "bottom-right gem y position")
AssertEqual(bottomRightGem.frameLevel, 12, "gem frame level")
AssertEqual(bottomRightGem.dragButton, "LeftButton", "gem drag registration")
AssertEqual(bottomRightGem.highlight.blendMode, "ADD", "gem highlight blend mode")
assert(not bottomRightGem.selector.shown, "gem selector started visible")
bottomRightGem.scripts.OnEnter(bottomRightGem)
assert(enteredGem == bottomRightGem, "gem enter handler wiring")

local projectionGrid = addon.Grid:New()
projectionGrid:Set(2, 3, 4)
projectionGrid:Set(3, 3, addon.Constants.HYPER_CONTENTS)
projectionGrid:Set(4, 3, 6, true)
local firstProjection = gemPool:Project(projectionGrid)
AssertEqual(firstProjection.changedCount, 3, "initial nonempty gem projection count")
local redGemFrame = gemPool:GetFrame(2, 3)
AssertEqual(redGemFrame.texture.path, addon.Constants.IMAGE_ROOT .. "gem_red", "normal gem texture projection")
AssertEqual(redGemFrame.texture.texCoord[2], 49 / 255, "normal gem idle coordinate")
AssertEqual(redGemFrame.glow.path, addon.Constants.IMAGE_ROOT .. "highlight_red", "normal gem glow projection")
local hyperGemFrame = gemPool:GetFrame(3, 3)
AssertEqual(hyperGemFrame.texture.path, addon.Constants.IMAGE_ROOT .. "hypergem", "hyper gem texture projection")
AssertEqual(hyperGemFrame.texture.texCoord[2], 0.1, "hyper gem idle coordinate")
local powerGemFrame = gemPool:GetFrame(4, 3)
assert(powerGemFrame.projectedBigStar, "power-gem projection marker")
AssertEqual(powerGemFrame.texture.path, addon.Constants.IMAGE_ROOT .. "gem_orange", "power-gem base texture")
AssertEqual(gemPool:Project(projectionGrid).changedCount, 0, "unchanged grid projection")

projectionGrid:Set(2, 3, 7)
local changedProjection = gemPool:Project(projectionGrid)
AssertEqual(changedProjection.changedCount, 1, "single-cell projection change count")
AssertEqual(redGemFrame.texture.path, addon.Constants.IMAGE_ROOT .. "gem_green", "changed gem texture projection")
gemPool:SetInteractive(false)
assert(not gemPool:GetFrame(1, 1).mouseEnabled, "gem interaction disable")
gemPool:SetHandlers({ onLeave = function() end })
assert(gemPool:GetFrame(1, 1).scripts.OnEnter == nil, "removed gem handler remained installed")
assert(type(gemPool:GetFrame(1, 1).scripts.OnLeave) == "function", "replacement gem handler was not installed")
redGemFrame.selector:Show()
redGemFrame.glow:SetAlpha(0.75)
local resetProjection = gemPool:ResetPresentation(projectionGrid)
AssertEqual(resetProjection.changedCount, 64, "forced projection after presentation reset")
assert(not redGemFrame.selector.shown, "presentation reset left selector visible")
AssertEqual(redGemFrame.glow.alpha, 0, "presentation reset left gem glow visible")
AssertEqual(redGemFrame.points[1][1], "TOPLEFT", "presentation reset gem anchor")
AssertEqual(redGemFrame.points[1][2], 50, "presentation reset gem x position")
AssertEqual(redGemFrame.points[1][3], -100, "presentation reset gem y position")
gemPool:SetSelection(2, 3)
assert(gemPool.selectedFrame == redGemFrame, "gem selection frame was not retained")
assert(redGemFrame.selector.shown, "selected gem selector was not shown")
gemPool:SetSelection(nil)
assert(gemPool.selectedFrame == nil, "cleared gem selection was retained")
assert(not redGemFrame.selector.shown, "cleared gem selector remained visible")

local playedFiles = {}
local playedSoundKits = {}
local audioSettings = {}
local audioVisible = true
local audio = addon.Audio:New(audioSettings, {
	isVisible = function()
		return audioVisible
	end,
	playSoundFile = function(path)
		playedFiles[#playedFiles + 1] = path
		return true, #playedFiles
	end,
	playSound = function(soundKitID)
		playedSoundKits[#playedSoundKits + 1] = soundKitID
		return true, #playedSoundKits
	end,
	soundKit = {
		UI_SCENARIO_STAGE_END = 31757,
		UI_AUTO_QUEST_COMPLETE = 23404,
	},
})

assert(audio:Play("Select"), "select sound request was rejected")
assert(audio:Play("Invalid"), "invalid-move sound request was rejected")
assert(audio:Play("Select"), "duplicate select sound request was rejected")
local ordinarySounds = audio:Update(0.1)
AssertEqual(#ordinarySounds, 2, "ordinary sound coalescing")
AssertEqual(ordinarySounds[1].name, "Invalid", "ordinary sound playback order")
AssertEqual(ordinarySounds[2].name, "Select", "ordinary sound playback order")
AssertEqual(playedFiles[1], addon.Constants.SOUND_ROOT .. "bad2.mp3", "invalid-move sound path")
AssertEqual(playedFiles[2], addon.Constants.SOUND_ROOT .. "select.mp3", "selection sound path")

audioSettings.quietSounds = 1
assert(audio:Play("PowerCreate"), "quiet power-create sound request was rejected")
audio:Update(0)
AssertEqual(playedFiles[3], addon.Constants.SOUND_ROOT .. "q_multishot.mp3", "quiet sound path")

assert(audio:Play("Combo", 9), "capped combo sound request was rejected")
assert(audio:Play("Combo", 2), "second combo sound request was rejected")
local firstComboSounds = audio:Update(0)
AssertEqual(#firstComboSounds, 1, "one combo per update")
AssertEqual(firstComboSounds[1].comboIndex, 2, "lowest pending combo tier")
AssertEqual(playedFiles[4], addon.Constants.SOUND_ROOT .. "q_combo32.mp3", "combo-two sound path")
local secondComboSounds = audio:Update(0)
AssertEqual(secondComboSounds[1].comboIndex, 6, "capped combo tier")
AssertEqual(playedFiles[5], addon.Constants.SOUND_ROOT .. "q_combo72.mp3", "combo-six sound path")

assert(not audio:Play("GemClick"), "initial gem click bypassed throttle")
audio:Update(0.11)
assert(audio:Play("GemClick"), "elapsed gem click was rejected")
audio:Update(0)
AssertEqual(playedFiles[6], addon.Constants.SOUND_ROOT .. "q_gemongem2.mp3", "gem-click sound path")
assert(not audio:Play("GemClick"), "immediate repeated gem click bypassed throttle")

audioVisible = false
assert(not audio:Play("Go"), "hidden-window sound request was accepted")
audioVisible = true
audioSettings.disableSounds = 1
assert(not audio:Play("Go"), "disabled sound request was accepted")
local clickTimeBeforeDisabledUpdate = audio.lastClick
audio:Update(1)
AssertEqual(audio.lastClick, clickTimeBeforeDisabledUpdate, "disabled audio advanced its click timer")
audioSettings.disableSounds = nil

assert(audio:Play("LevelUp"), "level-up sound request was rejected")
local levelSounds = audio:Update(0)
AssertEqual(levelSounds[1].name, "LevelUp", "level-up sound event")
AssertEqual(playedSoundKits[1], 31757, "supported level-up SoundKit")

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
do
	local popCapSeed = addon.SavedVariables:ByteSum("PopCap Games")
	local signedFallbackPayload = addon.SavedVariables:VerifyAuthenticatedPayload("9VW``nt", popCapSeed)
	AssertEqual(signedFallbackPayload, "``nt", "legacy signed fallback payload")
	AssertEqual(addon.SavedVariables:DecodeBase70(signedFallbackPayload), 1000, "legacy signed fallback score")
	AssertEqual(addon.SavedVariables:EncodeBase70(1000, 4), "``nt", "legacy base-70 score encoding")
	assert(addon.SavedVariables:VerifyAuthenticatedPayload("9VX``nt", popCapSeed) == nil, "tampered fallback signature was accepted")
end

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
AssertEqual(#simpleCascade.hyperAwards, 0, "normal cascade hyper award count")
AssertEqual(#simpleCascade.lightningLinks, 0, "normal cascade lightning-link count")
AssertEqual(#simpleCascade.moves, 21, "simple cascade gravity move count")
AssertEqual(#simpleCascade.refills, 3, "simple cascade refill count")
AssertEqual(cascadeGrid:Get(1, 8).contents, 2, "first compacted bottom gem")
AssertEqual(cascadeGrid:Get(2, 8).contents, 3, "second compacted bottom gem")
AssertEqual(cascadeGrid:Get(3, 8).contents, 4, "third compacted bottom gem")

local function FinishAllGemAnimations()
	local finishedAny = true
	local passes = 0
	while finishedAny do
		finishedAny = false
		passes = passes + 1
		assert(passes <= 20, "animation completion did not converge")
		for frameIndex = 1, #gemPoolCreatedFrames do
			local frame = gemPoolCreatedFrames[frameIndex]
			for groupIndex = 1, #(frame.animationGroups or {}) do
				if frame.animationGroups[groupIndex]:FinishForTest() then
					finishedAny = true
				end
			end
		end
	end
end

local function FinishAnimationRunner(runner)
	for pass = 1, 100 do
		FinishAllGemAnimations()
		if not runner:IsPlaying() then
			return true
		end
		runner:UpdateEffects(0.025)
	end
	error("animation runner did not finish effects", 2)
end

local animationGrid = addon.Grid:New(MakeRandom(9876))
FillStablePattern(animationGrid)
for x = 1, 3 do
	animationGrid:Set(x, 8, 1)
end
local animationPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
animationPool:Project(animationGrid, true)
local animationStep = addon.Cascade:Step(animationGrid, addon.Matches:Find(animationGrid), {
	random = MakeRandom(8765),
	requireLegalMove = false,
})
local animationPhases = {}
local animationCompleted = false
local animations = addon.Animations:New(animationPool, {
	clearDuration = 0.12,
	fallPerCell = 0.04,
	minimumFallDuration = 0.08,
})
assert(type(animations.effectFrame.scripts.OnUpdate) == "function", "persistent effect driver was not installed")
local animationPlan = animations:BuildPlan(animationStep)
AssertEqual(#animationPlan.steps, 1, "single-step animation plan count")
AssertEqual(#animationPlan.steps[1].clear, 3, "animation clear plan count")
AssertEqual(#animationPlan.steps[1].moves, 21, "animation move plan count")
AssertEqual(#animationPlan.steps[1].refills, 3, "animation refill plan count")
AssertEqual(animationPlan.steps[1].refills[1].fromY, 0, "refill entry row")
AssertEqual(animationPlan.steps[1].refills[1].offsetY, -50, "refill translation offset")
AssertEqual(animationPlan.steps[1].moves[1].duration, 0.08, "minimum movement duration")
local animationRun
animationRun = animations:Play(animationStep, animationGrid, {
	onPhase = function(phase, stepIndex)
		animationPhases[#animationPhases + 1] = phase .. ":" .. stepIndex
	end,
	onComplete = function(run)
		assert(run == animationRun, "animation completion run changed")
		animationCompleted = true
	end,
})
assert(animations:IsPlaying(), "animation runner did not enter playing state")
assert(not animationPool:GetFrame(1, 1).mouseEnabled, "animation runner left gem interaction enabled")
AssertEqual(animationPhases[1], "clear:1", "animation clear phase notification")
AssertEqual(animationPool:GetFrame(1, 8).bejeweledClearAnimation.alpha.duration, 0.12, "clear animation duration")
FinishAllGemAnimations()
assert(animationCompleted, "animation completion callback was not invoked")
assert(not animations:IsPlaying(), "animation runner stayed active after completion")
assert(animationPool:GetFrame(1, 1).mouseEnabled, "animation completion left gem interaction disabled")
AssertEqual(animationPhases[2], "settle:1", "animation settle phase notification")
AssertEqual(animationPool:GetFrame(1, 8).contents, animationGrid:Get(1, 8).contents, "animation final grid projection")
AssertEqual(animationPool:GetFrame(1, 8).points[1][2], 0, "animation final frame x anchor")
AssertEqual(animationPool:GetFrame(1, 8).points[1][3], -350, "animation final frame y anchor")

local cancelledReason
local cancelledRun = animations:Play(animationStep, animationGrid, {
	onCancel = function(reason)
		cancelledReason = reason
	end,
})
assert(animations:Cancel("test-cancel"), "active animation cancellation failed")
assert(cancelledRun.cancelled, "cancelled animation run was not marked")
AssertEqual(cancelledReason, "test-cancel", "animation cancellation reason")
assert(not animations:IsPlaying(), "cancelled animation runner stayed active")
assert(animationPool:GetFrame(1, 1).mouseEnabled, "animation cancellation left gem interaction disabled")
assert(not animations:Cancel(), "inactive animation cancellation succeeded")

animationPool:RenderCell(4, 4, { contents = addon.Constants.HYPER_CONTENTS }, true)
animationPool:RenderCell(5, 5, { contents = 6, bigStar = true }, true)
animations:SyncPersistentEffects(false)
local persistentHyper = animationPool:GetFrame(4, 4)
local persistentPower = animationPool:GetFrame(5, 5)
AssertEqual(persistentHyper.texture.texCoord[2], 0.1, "hyper atlas initial frame")
assert(persistentPower.bejeweledPowerEffect.texture.shown, "power effect texture was not shown")
assert(persistentPower.bejeweledPowerEffect.highlight.shown, "power effect highlight was not shown")
AssertEqual(persistentPower.bejeweledPowerEffect.texture.width, 90, "power effect width")
AssertEqual(persistentPower.bejeweledPowerEffect.highlight.blendMode, "ADD", "power effect blend mode")
animations.effectFrame.scripts.OnUpdate(animations.effectFrame, 0.025)
AssertEqual(persistentHyper.bejeweledHyperFrame, 2, "hyper atlas frame advance")
AssertEqual(persistentHyper.texture.texCoord[1], 0.1, "hyper atlas second-frame coordinate")
AssertEqual(persistentPower.bejeweledPowerEffect.alpha, 97, "power effect cross-fade advance")
assert(persistentPower.bejeweledPowerEffect.texture.rotation > 0, "power effect rotation did not advance")
animationPool:RenderCell(5, 5, { contents = 6 }, true)
animations:SyncPersistentEffects(false)
assert(not persistentPower.bejeweledPowerEffect.texture.shown, "removed power effect texture remained visible")
assert(not persistentPower.bejeweledPowerEffect.highlight.shown, "removed power effect highlight remained visible")

local explosionCompleted = false
local explosionStep = {
	removedCells = {},
	spawnedSpecials = {},
	triggeredPowerRecords = { { x = 2, y = 3, contents = 4 } },
	lightningLinks = {},
	moves = {},
	refills = {},
}
local explosionPlan = animations:BuildPlan(explosionStep)
AssertEqual(#explosionPlan.steps[1].explosions, 1, "triggered explosion plan count")
local explosionRun = animations:Play(explosionStep, animationGrid, {
	onComplete = function()
		explosionCompleted = true
	end,
})
assert(animations:IsPlaying(), "explosion barrier did not hold animation playback")
AssertEqual(#animations.activeExplosions, 1, "active explosion count")
local explosionFrame = animations.activeExplosions[1]
AssertEqual(explosionFrame.texture.path, addon.Constants.IMAGE_ROOT .. "explosion", "explosion texture")
AssertEqual(explosionFrame.texture.width, 150, "explosion texture width")
AssertEqual(explosionFrame.points[1][4], 50, "explosion x anchor")
AssertEqual(explosionFrame.points[1][5], -100, "explosion y anchor")
animations:UpdateEffects(0.025)
AssertEqual(explosionFrame.effectFrame, 2, "explosion atlas frame advance")
AssertEqual(explosionFrame.texture.texCoord[1], 49 / 255, "explosion atlas overlap coordinate")
for index = 2, 15 do
	animations:UpdateEffects(0.025)
end
assert(not explosionCompleted, "explosion barrier completed before the final atlas frame")
AssertEqual(explosionFrame.effectFrame, 16, "explosion final atlas frame")
animations:UpdateEffects(0.025)
assert(explosionCompleted, "explosion barrier did not complete")
assert(explosionRun.completed, "explosion animation run was not marked complete")
assert(not explosionFrame.shown, "completed explosion remained visible")
AssertEqual(#animations.explosionPool, 1, "completed explosion was not pooled")

local pooledExplosion = animations:PlayExplosion(1, 1)
assert(pooledExplosion == explosionFrame, "explosion pool did not reuse its frame")
for index = 1, 16 do
	animations:UpdateEffects(0.025)
end
AssertEqual(#animations.explosionPool, 1, "standalone explosion was not returned to its pool")

local cancelledExplosionRun = animations:Play(explosionStep, animationGrid)
local cancelledExplosionFrame = animations.activeExplosions[1]
assert(animations:Cancel("effect-cancel"), "explosion animation cancellation failed")
assert(cancelledExplosionRun.cancelled, "cancelled explosion run was not marked")
assert(not cancelledExplosionFrame.shown, "cancelled explosion remained visible")
AssertEqual(#animations.activeExplosions, 0, "cancelled explosion remained active")
AssertEqual(#animations.explosionPool, 1, "cancelled explosion was not pooled")

local inputGrid = addon.Grid:New()
FillStablePattern(inputGrid)
inputGrid:Set(2, 8, 1)
inputGrid:Set(3, 8, 1)
inputGrid:Set(1, 7, 1)
assert(not inputGrid:HasAnyMatch(), "input test board started with a match")
assert(inputGrid:IsLegalSwap(1, 7, 1, 8), "input test swap was not legal")
local inputPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
inputPool:Project(inputGrid, true)
local inputAnimations = addon.Animations:New(inputPool, {
	createFrame = CreateGemPoolFrame,
	swapDuration = 0.2,
})
local inputProfile = addon.SavedVariables:CreateDefaultProfile()
local inputScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local inputRandomValues = { 2, 3, 4 }
local inputRandomIndex = 0
local function InputRandom(minimum, maximum)
	inputRandomIndex = inputRandomIndex + 1
	local value = inputRandomValues[((inputRandomIndex - 1) % #inputRandomValues) + 1]
	return math.max(minimum, math.min(maximum, value))
end
local inputSounds = {}
local inputAudio = {
	Play = function(_, soundName)
		inputSounds[#inputSounds + 1] = soundName
		return true
	end,
}
local inputCompletions = {}
local inputCascades = {}
local input = addon.Input:New(inputGrid, inputPool, inputAnimations, {
	audio = inputAudio,
	scoringState = inputScoringState,
	profile = inputProfile,
	random = InputRandom,
	requireLegalMove = false,
	onMoveComplete = function(result)
		inputCompletions[#inputCompletions + 1] = result
	end,
	onCascadeResolved = function(result)
		inputCascades[#inputCascades + 1] = result.cascadeResult
	end,
})
local inputHandlers = input:CreateGemHandlers()
assert(type(inputHandlers.onMouseDown) == "function", "input gem handler was not created")
local firstSelection = inputHandlers.onMouseDown(inputPool:GetFrame(8, 1), "LeftButton")
AssertEqual(firstSelection.status, "selected", "input first selection status")
assert(inputPool:GetFrame(8, 1).selector.shown, "input selection did not show selector")
local clearedSelection = input:HandleCell(1, 7)
AssertEqual(clearedSelection.reason, "nonadjacent", "nonadjacent selection clear reason")
assert(input:GetSelection() == nil, "nonadjacent click retained selection")

AssertEqual(input:HandleCell(1, 7).status, "selected", "legal swap source selection")
local acceptedMove = input:HandleCell(1, 8)
assert(acceptedMove.valid, "legal input move was rejected")
AssertEqual(acceptedMove.status, "animating", "accepted input move status")
assert(input:IsLocked(), "accepted input move did not lock input")
AssertEqual(input:HandleCell(4, 4).status, "locked", "locked input accepted another cell")
AssertEqual(inputScoringState.moves, 1, "accepted move count")
assert(inputGrid:HasAnyMatch(), "accepted swap was not applied before presentation")
AssertEqual(acceptedMove.swapRun.kind, "swap", "accepted swap animation kind")
AssertEqual(inputPool:GetFrame(1, 7).bejeweledSwapForwardAnimation.outbound.duration, 0.2, "accepted swap duration")
FinishAllGemAnimations()
assert(not input:IsLocked(), "cascade completion left input locked")
AssertEqual(acceptedMove.status, "complete", "accepted move completion status")
AssertEqual(#inputCascades, 1, "accepted move cascade callback count")
AssertEqual(#inputCompletions, 1, "accepted move completion callback count")
assert(inputCascades[1].stable, "accepted move cascade did not stabilize")
assert(not inputGrid:HasAnyMatch(), "accepted move cascade left a match")
assert(inputPool:GetFrame(1, 1).mouseEnabled, "accepted move completion left gem input disabled")

local invalidFirstX, invalidFirstY, invalidSecondX, invalidSecondY
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH - 1 do
		if not inputGrid:IsLegalSwap(x, y, x + 1, y) then
			invalidFirstX, invalidFirstY = x, y
			invalidSecondX, invalidSecondY = x + 1, y
			break
		end
	end
	if invalidFirstX then
		break
	end
end
assert(invalidFirstX, "input test could not find an invalid adjacent swap")
local invalidBefore = inputGrid:ExportLegacyBoard()
input:HandleCell(invalidFirstX, invalidFirstY)
local rejectedMove = input:HandleCell(invalidSecondX, invalidSecondY)
assert(not rejectedMove.valid, "invalid input move was accepted")
assert(input:IsLocked(), "invalid rollback did not lock input")
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(inputGrid:EncodeLegacyValue(inputGrid:Get(x, y)), invalidBefore[y][x], "invalid swap changed authoritative grid")
	end
end
local rollbackAnimation = inputPool:GetFrame(invalidFirstX, invalidFirstY).bejeweledSwapRollbackAnimation
AssertEqual(rollbackAnimation.outbound.order, 1, "rollback outbound animation order")
AssertEqual(rollbackAnimation.returnTranslation.order, 2, "rollback return animation order")
FinishAllGemAnimations()
AssertEqual(rejectedMove.status, "rejected", "invalid move completion status")
assert(not input:IsLocked(), "invalid rollback left input locked")
AssertEqual(inputScoringState.moves, 1, "invalid move changed move count")
AssertEqual(inputSounds[#inputSounds], "Invalid", "invalid move sound")

FillStablePattern(inputGrid)
inputGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
local inputHyperTarget = inputGrid:Get(2, 8).contents
local inputHyperTargetCount = 0
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		if inputGrid:Get(x, y).contents == inputHyperTarget then
			inputHyperTargetCount = inputHyperTargetCount + 1
		end
	end
end
inputPool:Project(inputGrid, true)
AssertEqual(input:HandleCell(1, 8).status, "selected", "hyper swap source selection")
local hyperMove = input:HandleCell(2, 8)
assert(hyperMove.valid and hyperMove.hyperPlan, "hyper input move was not accepted")
AssertEqual(inputScoringState.moves, 1, "legacy hyper move changed move count")
FinishAnimationRunner(inputAnimations)
AssertEqual(hyperMove.status, "complete", "hyper input move completion status")
assert(hyperMove.cascadeResult.hyper, "hyper input move used the normal cascade path")
AssertEqual(#hyperMove.cascadeResult.steps[1].hyperAwards, inputHyperTargetCount + 1, "hyper input award count")
AssertEqual(#inputAnimations.lightningPool, inputHyperTargetCount - 1, "hyper lightning pool count")
local pooledLightning = inputAnimations.lightningPool[1]
AssertEqual(pooledLightning.base.path, addon.Constants.IMAGE_ROOT .. "lightning", "hyper lightning texture")
AssertEqual(pooledLightning.base.thickness, 10, "hyper lightning thickness")
AssertEqual(pooledLightning.highlight.color[1], addon.Constants.GEM_EFFECT_COLORS[inputHyperTarget][1], "hyper lightning color")
assert(not pooledLightning.base.shown and not pooledLightning.highlight.shown, "completed lightning remained visible")
AssertEqual(inputSounds[#inputSounds - 1], "HyperDestroy", "hyper destruction sound")
AssertEqual(inputSounds[#inputSounds], "ElectroExplode", "hyper electro sound")
assert(not input:IsLocked(), "hyper input move left input locked")

local function TestSessionRestore()
local sessionGrid = addon.Grid:New()
FillStablePattern(sessionGrid)
sessionGrid:Set(4, 4, addon.Constants.HYPER_CONTENTS)
local savedPowerContents = sessionGrid:Get(5, 5).contents
sessionGrid:Set(5, 5, savedPowerContents, true)
local sessionPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
sessionPool:Project(sessionGrid, true)
local sessionAnimations = addon.Animations:New(sessionPool, {
	createFrame = CreateGemPoolFrame,
	swapDuration = 0.2,
})
local sessionProfile = addon.SavedVariables:CreateDefaultProfile()
local sessionState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC, {
	score = 12345,
	pointsToLevelUp = 16000,
	level = 4,
	pointMultiplier = 2.5,
	largestCascade = 9,
	largestCombo = 4,
	moves = 37,
})
local sessionPauseEvents = {}
local sessionSaveEvents = {}
local sessionRestoreEvents = {}
local session = addon.Session:New(sessionGrid, sessionPool, sessionAnimations, {
	profile = sessionProfile,
	playerName = "Nighthawk",
	scoringState = sessionState,
	timerElapsed = 42.75,
	inputOptions = {
		random = MakeRandom(4810),
		requireLegalMove = false,
	},
	onPauseChanged = function(result)
		sessionPauseEvents[#sessionPauseEvents + 1] = result
	end,
	onSaved = function(result)
		sessionSaveEvents[#sessionSaveEvents + 1] = result
	end,
	onRestored = function(result)
		sessionRestoreEvents[#sessionRestoreEvents + 1] = result
	end,
})
local manualSessionSave = session:SaveClassicGame("test-save")
local savedSessionState = manualSessionSave.savedState
assert(session:HasClassicGame(), "saved classic session was not discoverable")
assert(sessionProfile.settings.classicInProgress, "classic in-progress wire flag was not set")
AssertEqual(savedSessionState[4][4], addon.Constants.HYPER_CONTENTS, "saved hyper wire value")
AssertEqual(savedSessionState[5][5], savedPowerContents + addon.Constants.BIG_STAR_WIRE_OFFSET, "saved power wire value")
AssertEqual(savedSessionState[9][1], 12345, "saved score metadata")
AssertEqual(savedSessionState[9][7], 42.75, "saved elapsed metadata")
local savedScorePayload = addon.SavedVariables:VerifyAuthenticatedPayload(
	savedSessionState[9][9],
	addon.SavedVariables:ByteSum("Nighthawk")
)
AssertEqual(addon.SavedVariables:DecodeBase70(savedScorePayload), 12345, "saved authenticated score")

sessionGrid:Reset()
sessionState.score = 1
sessionState.moves = 0
session:SetElapsed(0)
AssertEqual(session:Pause("pre-restore").status, "paused", "session pause status")
assert(session:IsPaused() and sessionAnimations:IsPaused(), "session pause did not freeze animations")
assert(not sessionPool:GetFrame(1, 1).mouseEnabled, "session pause left input interactive")
AssertEqual(session:HandleCell(1, 1).status, "paused", "paused session accepted input")
local restoredSession = session:RestoreClassicGame()
assert(restoredSession.state.signatureValid, "restored score signature was rejected")
assert(restoredSession.paused, "restore did not preserve the prior pause state")
AssertEqual(sessionGrid:Get(4, 4).contents, addon.Constants.HYPER_CONTENTS, "restored hyper contents")
assert(sessionGrid:Get(5, 5).bigStar, "restored power marker")
AssertEqual(sessionState.score, 12345, "restored authenticated score")
AssertEqual(sessionState.moves, 37, "restored move count")
AssertEqual(session.timerElapsed, 42.75, "restored elapsed time")
local pausedHyperFrame = sessionPool:GetFrame(4, 4)
local pausedHyperAtlasFrame = pausedHyperFrame.bejeweledHyperFrame
assert(not sessionAnimations:UpdateEffects(0.025), "paused session advanced effect timing")
AssertEqual(pausedHyperFrame.bejeweledHyperFrame, pausedHyperAtlasFrame, "paused hyper atlas advanced")
AssertEqual(session:AdvanceElapsed(5), 42.75, "paused session advanced elapsed time")
session:Resume("test-resume")
assert(not session:IsPaused() and not sessionAnimations:IsPaused(), "session resume left animations paused")
assert(sessionPool:GetFrame(1, 1).mouseEnabled, "session resume left input disabled")
sessionAnimations:UpdateEffects(0.025)
AssertEqual(pausedHyperFrame.bejeweledHyperFrame, pausedHyperAtlasFrame + 1, "resumed hyper atlas did not advance")
AssertEqual(session:AdvanceElapsed(1.25), 44, "running session elapsed time")
AssertEqual(#sessionPauseEvents, 2, "session pause callback count")
AssertEqual(#sessionRestoreEvents, 1, "session restore callback count")

local validSessionSignature = savedSessionState[9][9]
savedSessionState[9][9] = "000" .. string.sub(validSessionSignature, 4)
sessionGrid:Reset()
local invalidSignatureRestore = session:RestoreClassicGame({ paused = false })
assert(not invalidSignatureRestore.state.signatureValid, "tampered saved score signature was accepted")
AssertEqual(sessionState.score, 0, "tampered saved score did not restore as zero")
AssertEqual(invalidSignatureRestore.state.savedScore, 12345, "raw saved score evidence changed")
savedSessionState[9][9] = validSessionSignature

local invalidSavedCell = savedSessionState[1][1]
savedSessionState[1][1] = 99
local beforeFailedRestore = sessionGrid:ExportLegacyBoard()
local malformedRestoreSucceeded = pcall(function()
	session:RestoreClassicGame()
end)
assert(not malformedRestoreSucceeded, "malformed saved board was accepted")
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(
			sessionGrid:EncodeLegacyValue(sessionGrid:Get(x, y)),
			beforeFailedRestore[y][x],
			"failed session restore changed the grid"
		)
	end
end
savedSessionState[1][1] = invalidSavedCell

FillStablePattern(sessionGrid)
sessionGrid:Set(2, 8, 1)
sessionGrid:Set(3, 8, 1)
sessionGrid:Set(1, 7, 1)
sessionPool:Project(sessionGrid, true)
AssertEqual(session:HandleCell(1, 7).status, "selected", "session move source selection")
local sessionMove = session:HandleCell(1, 8)
assert(sessionMove.valid, "session legal move was rejected")
session:Pause("mid-swap")
local pausedSwapGroup = sessionPool:GetFrame(1, 7).bejeweledSwapForwardAnimation.group
assert(pausedSwapGroup:IsPaused(), "session pause did not pause the active swap group")
FinishAllGemAnimations()
assert(sessionAnimations:IsPlaying(), "paused swap completed while frozen")
session:Resume("mid-swap")
FinishAnimationRunner(sessionAnimations)
AssertEqual(sessionMove.status, "complete", "resumed session move completion status")
assert(sessionMove.saveResult and sessionMove.saveResult.status == "saved", "stable session move was not auto-saved")
AssertEqual(#sessionSaveEvents, 2, "session save callback count")
AssertEqual(sessionProfile.settings.savedState[9][4], sessionState.moves, "auto-saved move count")
end
TestSessionRestore()

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
cascadeGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
local hyperTargetContents = cascadeGrid:Get(2, 8).contents
local hyperTargetCount = 0
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		if cascadeGrid:Get(x, y).contents == hyperTargetContents then
			hyperTargetCount = hyperTargetCount + 1
		end
	end
end
cascadeGrid:Swap(1, 8, 2, 8)
local hyperResolution = addon.Cascade:ResolveHyper(cascadeGrid, {
	targetContents = hyperTargetContents,
	doubleHyper = false,
	activations = {
		{ x = 1, y = 8, consumedX = 2, consumedY = 8 },
	},
}, {
	random = MakeRandom(4680),
	requireLegalMove = false,
})
local hyperActivationStep = hyperResolution.steps[1]
assert(hyperResolution.hyper and hyperResolution.stable, "hyper resolution did not stabilize")
AssertEqual(#hyperActivationStep.hyperActivations, 1, "colored hyper activation count")
AssertEqual(#hyperActivationStep.hyperAwards, hyperTargetCount + 1, "colored hyper award count")
AssertEqual(hyperActivationStep.clearCount, hyperTargetCount + 1, "colored hyper clear count")
AssertEqual(#hyperActivationStep.lightningLinks, hyperTargetCount - 1, "colored hyper lightning-link count")
AssertEqual(hyperActivationStep.hyperAwards[1].kind, "hyper-destroy", "colored hyper destruction award kind")
AssertEqual(hyperActivationStep.hyperAwards[2].kind, "hyper-chain", "colored hyper chain award kind")

FillStablePattern(cascadeGrid)
cascadeGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
local hyperPowerTarget = cascadeGrid:Get(2, 8).contents
local hyperPowerCell
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		local cell = cascadeGrid:Get(x, y)
		if cell.contents == hyperPowerTarget and not (x == 2 and y == 8) then
			hyperPowerCell = cell
			break
		end
	end
	if hyperPowerCell then
		break
	end
end
assert(hyperPowerCell, "hyper power-target test could not find a matching color")
cascadeGrid:Set(hyperPowerCell.gridX, hyperPowerCell.gridY, hyperPowerTarget, true)
cascadeGrid:Swap(1, 8, 2, 8)
local hyperPowerResolution = addon.Cascade:ResolveHyper(cascadeGrid, {
	targetContents = hyperPowerTarget,
	doubleHyper = false,
	activations = {
		{ x = 1, y = 8, consumedX = 2, consumedY = 8 },
	},
}, {
	random = MakeRandom(4682),
	requireLegalMove = false,
})
local hyperPowerStep = hyperPowerResolution.steps[1]
AssertEqual(hyperPowerStep.triggeredPowerCount, 1, "hyper-targeted power-gem trigger count")
assert(hyperPowerStep.clearCount > #hyperPowerStep.hyperAwards, "hyper-targeted power gem did not expand its clear")

FillStablePattern(cascadeGrid)
cascadeGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
cascadeGrid:Set(2, 8, addon.Constants.HYPER_CONTENTS)
cascadeGrid:Set(4, 4, addon.Constants.HYPER_CONTENTS)
cascadeGrid:Swap(1, 8, 2, 8)
local doubleHyperResolution = addon.Cascade:ResolveHyper(cascadeGrid, {
	targetContents = addon.Constants.HYPER_CONTENTS,
	doubleHyper = true,
	activations = {
		{ x = 1, y = 8, consumedX = 2, consumedY = 8 },
		{ x = 2, y = 8, consumedX = 1, consumedY = 8 },
	},
}, {
	random = MakeRandom(4681),
	requireLegalMove = false,
})
local doubleHyperStep = doubleHyperResolution.steps[1]
AssertEqual(#doubleHyperStep.hyperActivations, 2, "double-hyper activation count")
AssertEqual(#doubleHyperStep.hyperAwards, 5, "double-hyper award count")
AssertEqual(doubleHyperStep.clearCount, 3, "double-hyper clear count")
AssertEqual(#doubleHyperStep.lightningLinks, 1, "double-hyper lightning-link count")

FillStablePattern(cascadeGrid)
cascadeGrid:Set(1, 8, addon.Constants.HYPER_CONTENTS)
cascadeGrid:Swap(1, 8, 2, 8)
local staleHyperBoard = cascadeGrid:ExportLegacyBoard()
local staleHyperSucceeded = pcall(function()
	addon.Cascade:ResolveHyper(cascadeGrid, {
		targetContents = 1,
		doubleHyper = false,
		activations = {
			{ x = 1, y = 8, consumedX = 2, consumedY = 8 },
		},
	}, { requireLegalMove = false })
end)
assert(not staleHyperSucceeded, "stale hyper plan was accepted")
for y = 1, addon.Constants.GRID_HEIGHT do
	for x = 1, addon.Constants.GRID_WIDTH do
		AssertEqual(
			cascadeGrid:EncodeLegacyValue(cascadeGrid:Get(x, y)),
			staleHyperBoard[y][x],
			"failed hyper resolution was not atomic"
		)
	end
end

local cancelledLightningRun = animations:Play(hyperActivationStep, cascadeGrid)
AssertEqual(#animations.activeLightning, hyperTargetCount - 1, "active hyper lightning count")
assert(animations:Cancel("lightning-cancel"), "hyper lightning cancellation failed")
assert(cancelledLightningRun.cancelled, "cancelled hyper lightning run was not marked")
AssertEqual(#animations.activeLightning, 0, "cancelled hyper lightning remained active")
AssertEqual(#animations.lightningPool, hyperTargetCount - 1, "cancelled hyper lightning was not pooled")

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

local moveProfile = addon.SavedVariables:CreateDefaultProfile()
local moveState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC, { moves = 99 })
local recordedMove = addon.Scoring:RecordMove(moveState, moveProfile, { random = function() return 1 end })
AssertEqual(recordedMove.moves, 100, "classic recorded move count")
AssertEqual(recordedMove.skillEvents[1].index, addon.Constants.SKILL_MOVE100, "classic move-100 skill index")
local timedMoveProfile = addon.SavedVariables:CreateDefaultProfile()
local timedMoveState = addon.Scoring:NewState(addon.Constants.GAME_MODE_TIMED, { moves = 4 })
addon.Scoring:RecordMove(timedMoveState, timedMoveProfile)
AssertEqual(timedMoveProfile.stats.timed.mostMoves, 5, "timed most-moves statistic")

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

local activationScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local activationScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local activationScoring = addon.Scoring:ApplyCascade(
	activationScoringState,
	{ steps = { hyperActivationStep } },
	activationScoringProfile,
	{ random = function() return 1 end }
)
AssertEqual(activationScoring.points, 75 + 20 * hyperTargetCount, "colored hyper activation score")
AssertEqual(activationScoring.scoreEvents[1].kind, "hyper-destroy", "colored hyper first score kind")
AssertEqual(activationScoring.scoreEvents[2].kind, "hyper-chain", "colored hyper electro score kind")

local doubleHyperScoringProfile = addon.SavedVariables:CreateDefaultProfile()
local doubleHyperScoringState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC)
local doubleHyperScoring = addon.Scoring:ApplyCascade(
	doubleHyperScoringState,
	{ steps = { doubleHyperStep } },
	doubleHyperScoringProfile,
	{ random = function() return 1 end }
)
AssertEqual(doubleHyperScoring.points, 210, "double-hyper activation score")
AssertEqual(#doubleHyperScoring.scoreEvents, 5, "double-hyper score event count")

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
assert(addon.audio, "addon initialization did not create audio")
assert(addon.backdrops == addon.Backdrops, "addon initialization did not install backdrops")
assert(addon.gemPoolFactory == addon.GemPool, "addon initialization did not install GemPool")
assert(addon.animationFactory == addon.Animations, "addon initialization did not install Animations")
assert(addon.inputFactory == addon.Input, "addon initialization did not install Input")
assert(addon.sessionFactory == addon.Session, "addon initialization did not install Session")
assert(eventFrame.registeredEvent == nil, "initializer event was not unregistered")
local initializedGrid = addon.grid
local initializedAudio = addon.audio
local initializedBackdrops = addon.backdrops
local initializedGemPoolFactory = addon.gemPoolFactory
local initializedAnimationFactory = addon.animationFactory
local initializedInputFactory = addon.inputFactory
local initializedSessionFactory = addon.sessionFactory
addon:Initialize({}, {})
assert(addon.grid == initializedGrid, "addon initialization is not idempotent")
assert(addon.audio == initializedAudio, "audio initialization is not idempotent")
assert(addon.backdrops == initializedBackdrops, "backdrop initialization is not idempotent")
assert(addon.gemPoolFactory == initializedGemPoolFactory, "GemPool initialization is not idempotent")
assert(addon.animationFactory == initializedAnimationFactory, "Animations initialization is not idempotent")
assert(addon.inputFactory == initializedInputFactory, "Input initialization is not idempotent")
assert(addon.sessionFactory == initializedSessionFactory, "Session initialization is not idempotent")

print("Runtime verification passed: pause/restore sessions, input, cascade animation, gem projection, UI backdrops, audio, SavedVariables, and deterministic gameplay engine.")
