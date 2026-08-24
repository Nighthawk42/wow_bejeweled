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
LoadAddonFile("Bejeweled/UI/Fonts.lua", addon)
LoadAddonFile("Bejeweled/UI/Backdrops.lua", addon)
LoadAddonFile("Bejeweled/UI/GemPool.lua", addon)
LoadAddonFile("Bejeweled/UI/Animations.lua", addon)
LoadAddonFile("Bejeweled/UI/HUD.lua", addon)
LoadAddonFile("Bejeweled/UI/Summary.lua", addon)
LoadAddonFile("Bejeweled/UI/Skills.lua", addon)
LoadAddonFile("Bejeweled/UI/Options.lua", addon)
LoadAddonFile("Bejeweled/UI/About.lua", addon)
LoadAddonFile("Bejeweled/UI/Legal.lua", addon)
LoadAddonFile("Bejeweled/UI/MainWindow.lua", addon)
LoadAddonFile("Bejeweled/UI/Compartment.lua", addon)

AssertEqual(eventFrame.registeredEvent, "ADDON_LOADED", "initializer event registration")
AssertEqual(addon.Constants.GRID_WIDTH, 8, "grid width")
AssertEqual(addon.Constants.GRID_HEIGHT, 8, "grid height")
AssertEqual(addon.Constants.GEM_COLOR_COUNT, 7, "gem color count")

do
	local fontAttempts = {}
	local rejectingBundledFont = {}
	function rejectingBundledFont:SetFont(path, size, flags)
		fontAttempts[#fontAttempts + 1] = { path, size, flags }
		return #fontAttempts > 1
	end
	local selectedFont, usedFallback = addon.Fonts:Set(rejectingBundledFont, 14, "OUTLINE", "Fonts\\TestFallback.ttf")
	AssertEqual(fontAttempts[1][1], addon.Fonts.BUNDLED_FONT_PATH, "bundled font was not attempted first")
	AssertEqual(fontAttempts[2][1], "Fonts\\TestFallback.ttf", "standard font fallback path")
	AssertEqual(selectedFont, "Fonts\\TestFallback.ttf", "selected fallback font path")
	assert(usedFallback, "rejected bundled font did not report fallback use")
end

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
	function texture:SetVertexColor(red, green, blue, alpha)
		self.vertexColor = { red, green, blue, alpha }
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

local function CreateMockFontString(layer)
	local fontString = CreateMockTexture(layer)
	function fontString:ClearAllPoints()
		self.points = {}
	end
	function fontString:SetText(text)
		self.text = text
	end
	function fontString:SetTextColor(red, green, blue, alpha)
		self.textColor = { red, green, blue, alpha }
	end
	function fontString:SetFont(path, size, flags)
		self.font = { path, size, flags }
		return true
	end
	function fontString:SetJustifyH(justify)
		self.justifyH = justify
	end
	return fontString
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
	function frame:SetMinMaxValues(minimum, maximum)
		self.minimum = minimum
		self.maximum = maximum
	end
	function frame:SetValueStep(step)
		self.valueStep = step
	end
	function frame:SetObeyStepOnDrag(obey)
		self.obeyStepOnDrag = obey
	end
	function frame:SetOrientation(orientation)
		self.orientation = orientation
	end
	function frame:SetThumbTexture(path)
		self.thumbTexture = CreateMockTexture("ARTWORK")
		self.thumbTexture.path = path
	end
	function frame:GetThumbTexture()
		return self.thumbTexture
	end
	function frame:SetValue(value)
		if self.minimum then
			value = math.max(self.minimum, math.min(self.maximum, value))
		end
		if self.valueStep then
			value = math.floor(value / self.valueStep + 0.5) * self.valueStep
		end
		self.value = value
		if self.scripts.OnValueChanged then
			self.scripts.OnValueChanged(self, value, false)
		end
	end
	function frame:GetValue()
		return self.value
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
	function frame:CreateFontString(name, layer)
		local fontString = CreateMockFontString(layer)
		self.createdFontStrings = self.createdFontStrings or {}
		self.createdFontStrings[#self.createdFontStrings + 1] = fontString
		return fontString
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
	function frame:SetBackdrop(descriptor)
		self.descriptor = descriptor
	end
	function frame:SetBackdropColor(red, green, blue, alpha)
		self.backgroundColor = { red, green, blue, alpha }
	end
	function frame:SetBackdropBorderColor(red, green, blue, alpha)
		self.borderColor = { red, green, blue, alpha }
	end
	function frame:SetFrameLevel(frameLevel)
		self.frameLevel = frameLevel
	end
	function frame:GetFrameLevel()
		if self.frameLevel then
			return self.frameLevel
		end
		if self.parent and type(self.parent.GetFrameLevel) == "function" then
			return self.parent:GetFrameLevel()
		end
		return 0
	end
	function frame:EnableMouse(enabled)
		self.mouseEnabled = enabled
	end
	function frame:SetMovable(movable)
		self.movable = movable
	end
	function frame:SetClampedToScreen(clamped)
		self.clamped = clamped
	end
	function frame:StartMoving()
		self.moving = true
	end
	function frame:StopMovingOrSizing()
		self.moving = false
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

animations:ClearTransientEffects()
assert(#animations.shardPool >= 30, "cascade clears did not emit pooled ten-shard bursts")
animations.random = MakeRandom(7007)
animations.hintDelay = 0.05
local hint = animations:ShowHint(2, 3)
assert(not hint.shown, "new hint bypassed its delay")
AssertEqual(hint.texture.path, addon.Constants.IMAGE_ROOT .. "hintArrow", "hint texture")
animations:UpdateEffects(0.025)
animations:UpdateEffects(0.025)
assert(not hint.shown, "hint appeared at rather than after its delay")
animations:UpdateEffects(0.025)
assert(hint.shown, "hint did not appear after its delay")
AssertEqual(hint.bounceY, 1, "hint initial bounce step")
local pausedHintBounce = hint.bounceY
animations:Pause()
assert(not animations:UpdateEffects(1), "paused effects clock advanced")
AssertEqual(hint.bounceY, pausedHintBounce, "paused hint continued bouncing")
animations:Resume()
assert(animations:HideHint(), "active hint was not hidden")
assert(not hint.shown, "hidden hint remained visible")

local shard = animations:PlayShard(2, 3, 4, {
	xVelocity = 1,
	yVelocity = 11,
	effectFrame = 12,
})
AssertEqual(shard.texture.path, addon.Constants.IMAGE_ROOT .. "gemshards", "shard texture")
AssertEqual(shard.texture.vertexColor[1], addon.Constants.GEM_EFFECT_COLORS[4][1], "shard color")
local shardX = shard.x
animations:UpdateEffects(0.025)
AssertEqual(shard.effectFrame, 1, "shard atlas wrap")
AssertEqual(shard.x, shardX + 1, "shard horizontal integration")
AssertEqual(shard.yVelocity, 11.5, "shard gravity integration")
AssertEqual(shard.alpha, 0.85, "shard fade threshold")
for _ = 1, 20 do
	animations:UpdateEffects(0.025)
end
AssertEqual(#animations.activeShards, 0, "finished shard remained active")
local pooledShard = animations.shardPool[#animations.shardPool]
local reusedShard = animations:PlayShard(1, 1, 3, { effectFrame = 1 })
assert(reusedShard == pooledShard, "shard pool did not reuse its frame")
animations:ClearTransientEffects()

local scoreText = animations:PlayFloatingText(100, 100, 30, 3, false)
AssertEqual(scoreText.text, "30", "floating score text")
AssertEqual(scoreText.font[1], addon.Constants.IMAGE_ROOT .. "Contb___.ttf", "floating text font")
AssertEqual(scoreText.textColor[3], addon.Constants.GEM_EFFECT_COLORS[3][3], "floating score color")
animations:UpdateEffects(0.025)
AssertEqual(scoreText.y, 99.75, "floating score upward motion")
for _ = 1, 80 do
	animations:UpdateEffects(0.025)
end
AssertEqual(#animations.activeFloatingText, 0, "finished floating score remained active")
AssertEqual(#animations.floatingTextPool, 1, "floating score was not pooled")
local skillText = animations:PlayFloatingText(120, 80, "+1 Skill", 3, true)
assert(skillText == scoreText, "floating text pool did not reuse its font string")
AssertEqual(skillText.textColor[1], 1, "nonscore floating text red channel")
AssertEqual(skillText.textColor[2], 0.4, "nonscore floating text green channel")
animations:UpdateEffects(0.025)
AssertEqual(skillText.y, 80.25, "nonscore floating text downward motion")
animations:ClearTransientEffects()

local lightwave = animations:PlayLightwave(1, 1, 0)
AssertEqual(lightwave.effectFrame, -1, "lightwave initial delay frame")
AssertEqual(lightwave.texture.texCoord[1], 0.33, "lightwave atlas cell")
animations:UpdateEffects(0.025)
animations:UpdateEffects(0.025)
AssertEqual(lightwave.effectFrame, 1, "lightwave activation frame")
AssertEqual(lightwave.alpha, 0.9, "lightwave activation alpha")
AssertEqual(#animations.activeLightwaves, 2, "lightwave did not propagate right")
AssertEqual(animations.activeLightwaves[2].column, 2, "propagated lightwave column")
animations:ClearTransientEffects()
animations.lightwavePeriod = 0.05
assert(animations:SetAmbientLightwaves(true), "ambient lightwaves were not enabled")
animations:UpdateEffects(0.025)
animations:UpdateEffects(0.025)
animations:UpdateEffects(0.025)
AssertEqual(#animations.activeLightwaves, addon.Constants.GRID_HEIGHT, "ambient lightwave row count")
assert(animations:SetAmbientLightwaves(false), "ambient lightwaves were not disabled")
AssertEqual(#animations.activeLightwaves, 0, "disabled ambient lightwaves remained active")

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
local sessionLevelStartedEvents = {}
local sessionLevelCompleteEvents = {}
local sessionSounds = {}
local session = addon.Session:New(sessionGrid, sessionPool, sessionAnimations, {
	profile = sessionProfile,
	playerName = "Nighthawk",
	scoringState = sessionState,
	timerElapsed = 42.75,
	deferLevelTransitions = true,
	detectGameOver = false,
	inputOptions = {
		random = MakeRandom(4810),
		requireLegalMove = false,
		audio = {
			Play = function(_, soundName)
				sessionSounds[#sessionSounds + 1] = soundName
			end,
		},
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
	onLevelTransitionStarted = function(result)
		sessionLevelStartedEvents[#sessionLevelStartedEvents + 1] = result
	end,
	onLevelTransitionComplete = function(result)
		sessionLevelCompleteEvents[#sessionLevelCompleteEvents + 1] = result
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

sessionState.score = 500
sessionState.pointsToLevelUp = 500
sessionState.level = 1
sessionState.pointMultiplier = 1
sessionState.levelPending = true
FillStablePattern(sessionGrid)
sessionGrid:Set(1, 1, addon.Constants.HYPER_CONTENTS)
local transitionPowerContents = sessionGrid:Get(2, 1).contents
sessionGrid:Set(2, 1, transitionPowerContents, true)
sessionPool:Project(sessionGrid, true)
local levelSourceMove = { status = "complete" }
session:HandleMoveComplete(levelSourceMove)
assert(session:IsLevelTransitionPending(), "session did not retain the presentation handoff")
assert(session:IsLocked(), "pending level transition did not lock input")
assert(not sessionPool:GetFrame(1, 1).mouseEnabled, "pending level transition left gems interactive")
AssertEqual(sessionState.level, 1, "level advanced before presentation completion")
assert(sessionState.levelPending, "pending level flag was consumed before presentation completion")
AssertEqual(#sessionLevelStartedEvents, 1, "level-transition start callback count")
AssertEqual(sessionLevelStartedEvents[1].kind, "level-up", "classic level-transition kind")
AssertEqual(sessionLevelStartedEvents[1].oldLevel, 1, "level-transition starting level")
AssertEqual(sessionLevelStartedEvents[1].level, 2, "level-transition target level")
AssertEqual(sessionSounds[#sessionSounds], "LevelUp", "level-transition sound")
sessionLevelStartedEvents[1].level = 99
levelSourceMove.levelTransition.oldLevel = 99
AssertEqual(session:GetLevelTransition().level, 2, "callback mutated active level-transition record")
AssertEqual(session:GetLevelTransition().oldLevel, 1, "source move mutated active level-transition record")
local transitionSaveSucceeded = pcall(function()
	session:SaveClassicGame("during-level-transition")
end)
assert(not transitionSaveSucceeded, "session saved an incomplete level transition")
session:Pause("level-transition")
session:Resume("level-transition")
assert(session:IsLocked(), "pause cycle released the level-transition lock")
assert(not sessionPool:GetFrame(1, 1).mouseEnabled, "pause cycle re-enabled input during level transition")

local completedLevelTransition = session:CompleteLevelTransition()
AssertEqual(completedLevelTransition.status, "complete", "level-transition completion status")
AssertEqual(completedLevelTransition.level, 2, "session-advanced level")
AssertEqual(completedLevelTransition.pointMultiplier, 1.5, "session-advanced point multiplier")
AssertEqual(completedLevelTransition.pointsToLevelUp, 1975, "session-advanced level threshold")
assert(completedLevelTransition.boardReset, "level transition did not regenerate the board")
AssertEqual(completedLevelTransition.preservedHyperGems, 1, "level transition hyper preservation record")
AssertEqual(completedLevelTransition.preservedPowerGems, 1, "level transition power preservation record")
local resetHyperCount = 0
local resetPowerCount = 0
for row = 1, addon.Constants.GRID_HEIGHT do
	for column = 1, addon.Constants.GRID_WIDTH do
		local resetCell = sessionGrid:Get(column, row)
		if resetCell.contents == addon.Constants.HYPER_CONTENTS then
			resetHyperCount = resetHyperCount + 1
		end
		if resetCell.bigStar then
			resetPowerCount = resetPowerCount + 1
		end
	end
end
AssertEqual(resetHyperCount, 1, "regenerated level board hyper count")
AssertEqual(resetPowerCount, 1, "regenerated level board power count")
assert(sessionGrid:FindLegalMove(), "regenerated level board has no legal move")
assert(not sessionState.levelPending, "completed transition retained the pending level flag")
assert(not session:IsLevelTransitionPending(), "completed level transition remained active")
assert(not session:IsLocked(), "completed level transition left input locked")
assert(sessionPool:GetFrame(1, 1).mouseEnabled, "completed level transition left gems disabled")
AssertEqual(#sessionLevelCompleteEvents, 1, "level-transition completion callback count")
AssertEqual(#sessionSaveEvents, 3, "level-transition autosave callback count")
assert(levelSourceMove.saveResult and levelSourceMove.saveResult.status == "saved", "level transition was not auto-saved")
AssertEqual(sessionProfile.settings.savedState[9][2], 1975, "auto-saved level threshold")
AssertEqual(sessionProfile.settings.savedState[9][3], 2, "auto-saved advanced level")

session.deferLevelTransitions = false
sessionState.score = 1975
sessionState.levelPending = true
local automaticLevelMove = { status = "complete" }
session:HandleMoveComplete(automaticLevelMove)
assert(not session:IsLevelTransitionPending(), "automatic level transition remained deferred")
AssertEqual(sessionState.level, 3, "automatic session-advanced level")
AssertEqual(sessionState.pointMultiplier, 2, "automatic session-advanced point multiplier")
AssertEqual(sessionState.pointsToLevelUp, 5550, "automatic session-advanced threshold")
AssertEqual(#sessionLevelStartedEvents, 2, "automatic level-transition start callback count")
AssertEqual(#sessionLevelCompleteEvents, 2, "automatic level-transition completion callback count")
AssertEqual(#sessionSaveEvents, 4, "automatic level-transition autosave callback count")
assert(automaticLevelMove.saveResult, "automatic level transition omitted stable-state autosave")
end

local function TestGameOverTransitions()
local gameOverGrid = addon.Grid:New()
FillStablePattern(gameOverGrid)
assert(not gameOverGrid:FindLegalMove(), "game-over fixture unexpectedly has a legal move")
local gameOverPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
gameOverPool:Project(gameOverGrid, true)
local gameOverAnimations = addon.Animations:New(gameOverPool, {
	createFrame = CreateGemPoolFrame,
})
local gameOverProfile = addon.SavedVariables:CreateDefaultProfile()
gameOverProfile.skill.skillPoints = 75
local gameOverAccount = addon.SavedVariables:CreateDefaultAccount()
gameOverAccount.played.OtherCharacter = 99
local gameOverState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC, {
	score = 4321,
	level = 5,
	pointsToLevelUp = 8000,
	pointMultiplier = 3,
	largestCascade = 12,
	largestCombo = 6,
	moves = 88,
})
local gameOverStarted = {}
local gameOverCompleted = {}
local gameOverSounds = {}
local gameOverSession = addon.Session:New(gameOverGrid, gameOverPool, gameOverAnimations, {
	profile = gameOverProfile,
	accountData = gameOverAccount,
	playerName = "Nighthawk",
	scoringState = gameOverState,
	timerElapsed = 75.5,
	deferGameOverTransitions = true,
	inputOptions = {
		random = function() return 1 end,
		audio = {
			Play = function(_, soundName)
				gameOverSounds[#gameOverSounds + 1] = soundName
			end,
		},
	},
	onGameOverStarted = function(result)
		gameOverStarted[#gameOverStarted + 1] = result
	end,
	onGameOverComplete = function(result)
		gameOverCompleted[#gameOverCompleted + 1] = result
	end,
})
assert(not gameOverSession:GetInput().requireLegalMove, "runtime input still forces legal cascade refills")
gameOverSession:SaveClassicGame("game-over-fixture")
assert(gameOverSession:HasClassicGame(), "game-over fixture did not create a resumable game")
local terminalMove = { status = "complete" }
gameOverSession:HandleMoveComplete(terminalMove)
assert(gameOverSession:IsGameOver(), "no-legal-move board did not end the session")
assert(gameOverSession:IsGameOverTransitionPending(), "game-over presentation was not deferred")
assert(not gameOverSession.active, "game-over session remained active")
assert(gameOverSession:IsLocked(), "game-over transition did not retain the input lock")
assert(not gameOverPool:GetFrame(1, 1).mouseEnabled, "game-over transition left gems interactive")
AssertEqual(#gameOverStarted, 1, "game-over start callback count")
AssertEqual(gameOverStarted[1].cause, "no-legal-move", "game-over cause")
AssertEqual(gameOverStarted[1].kind, "no-more-moves", "classic game-over presentation kind")
AssertEqual(gameOverStarted[1].score, 4321, "game-over final score snapshot")
AssertEqual(gameOverStarted[1].totalGames, 100, "account-wide completed-game count")
AssertEqual(gameOverProfile.skill.games, 1, "profile completed-game count")
AssertEqual(gameOverAccount.played.Nighthawk, 1, "account character completed-game count")
assert(gameOverProfile.skill.gainAchieve3, "100-game achievement was not checked")
AssertEqual(gameOverSounds[1], "NoMoreMoves", "classic game-over sound")
AssertEqual(gameOverSounds[2], "WipeBoard", "game-over board-wipe sound")
assert(not gameOverSession:HasClassicGame(), "completed Classic game remained resumable")
for row = 1, addon.Constants.GRID_HEIGHT + 1 do
	for column = 1, #(gameOverProfile.settings.savedState[row]) do
		AssertEqual(gameOverProfile.settings.savedState[row][column], 0, "cleared Classic save wire value")
	end
end
gameOverStarted[1].score = 0
terminalMove.gameOverTransition.level = 0
AssertEqual(gameOverSession:GetGameOverTransition().score, 4321, "callback mutated active game-over record")
AssertEqual(gameOverSession:GetGameOverTransition().level, 5, "source move mutated active game-over record")
gameOverSession:Pause("game-over")
gameOverSession:Resume("game-over")
assert(gameOverSession:IsLocked(), "pause cycle released the terminal input lock")

local classicSummary = gameOverSession:CompleteGameOver()
AssertEqual(classicSummary.status, "complete", "game-over completion status")
AssertEqual(classicSummary.metricName, "score", "classic summary metric name")
AssertEqual(classicSummary.metric, 4321, "classic summary metric")
assert(classicSummary.personalBest.updated, "classic personal best was not updated")
AssertEqual(gameOverProfile.stats.classic.score, 4321, "persisted Classic personal best")
local classicBestPayload = addon.SavedVariables:VerifyAuthenticatedPayload(
	gameOverProfile.stats.classic.data,
	addon.SavedVariables:ByteSum("Nighthawk")
)
AssertEqual(addon.SavedVariables:DecodeBase70(classicBestPayload), 4321, "authenticated Classic personal best")
local retainedClassicData = gameOverProfile.stats.classic.data
local lowerClassicBest = addon.SavedVariables:UpdatePersonalBest(
	gameOverProfile,
	addon.Constants.GAME_MODE_CLASSIC,
	4000,
	"Nighthawk"
)
assert(not lowerClassicBest.updated, "lower Classic score replaced the personal best")
AssertEqual(gameOverProfile.stats.classic.data, retainedClassicData, "lower Classic score replaced authenticated data")
assert(not gameOverSession:IsGameOverTransitionPending(), "completed game-over transition remained pending")
assert(gameOverSession:IsLocked(), "completed game-over transition released terminal input")
AssertEqual(gameOverSession:HandleCell(1, 1).status, "locked", "completed session accepted input")
AssertEqual(#gameOverCompleted, 1, "game-over completion callback count")
AssertEqual(terminalMove.gameOverComplete.metric, 4321, "source move summary handoff")
classicSummary.score = 0
AssertEqual(gameOverSession:GetGameOverSummary().score, 4321, "returned summary mutated retained handoff")

local timedGrid = addon.Grid:New()
FillStablePattern(timedGrid)
local timedPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
timedPool:Project(timedGrid, true)
local timedAnimations = addon.Animations:New(timedPool, {
	createFrame = CreateGemPoolFrame,
})
local timedProfile = addon.SavedVariables:CreateDefaultProfile()
timedProfile.skill.skillPoints = 225
local timedAccount = addon.SavedVariables:CreateDefaultAccount()
local timedSounds = {}
local timedState = addon.Scoring:NewState(addon.Constants.GAME_MODE_TIMED, {
	score = 3000,
	level = 2,
	largestCascade = 7,
	largestCombo = 4,
	moves = 25,
})
local timedSession = addon.Session:New(timedGrid, timedPool, timedAnimations, {
	profile = timedProfile,
	accountData = timedAccount,
	playerName = "Nighthawk",
	gameMode = addon.Constants.GAME_MODE_TIMED,
	scoringState = timedState,
	timerElapsed = 9,
	timeLimit = 10,
	detectGameOver = false,
	inputOptions = {
		random = function() return 1 end,
		audio = {
			Play = function(_, soundName)
				timedSounds[#timedSounds + 1] = soundName
			end,
		},
	},
})
AssertEqual(timedSession:AdvanceElapsed(2), 10, "timed session did not clamp at its limit")
assert(timedSession:IsGameOver(), "expired timed session did not end")
assert(not timedSession:IsGameOverTransitionPending(), "automatic timed summary remained deferred")
local timedSummary = timedSession:GetGameOverSummary()
AssertEqual(timedSummary.cause, "time-expired", "timed game-over cause")
AssertEqual(timedSummary.kind, "time-up", "timed game-over presentation kind")
AssertEqual(timedSummary.metricName, "points-per-second", "timed summary metric name")
AssertEqual(timedSummary.metric, 300, "timed points-per-second metric")
assert(timedSummary.personalBest.updated, "timed personal best was not updated")
AssertEqual(timedProfile.stats.timed.score, 300, "persisted timed personal best")
AssertEqual(timedProfile.stats.timed.played, 1, "timed playtime persistence")
AssertEqual(timedProfile.stats.played, 1, "total playtime persistence")
AssertEqual(#timedSummary.skillEvents, 2, "timed PPS skill-check count")
AssertEqual(timedSummary.skillEvents[1].index, addon.Constants.SKILL_PPS250, "250-PPS skill check")
AssertEqual(timedSummary.skillEvents[2].index, addon.Constants.SKILL_PPS300, "300-PPS skill check")
local timedBestPayload = addon.SavedVariables:VerifyAuthenticatedPayload(
	timedProfile.stats.timed.data,
	addon.SavedVariables:ByteSum("Nighthawk")
)
AssertEqual(addon.SavedVariables:DecodeBase70(timedBestPayload), 30000, "authenticated timed personal best")
AssertEqual(timedSounds[1], "TimesUp", "timed game-over sound")
AssertEqual(timedSounds[2], "WipeBoard", "timed board-wipe sound")
timedPool:SetInteractive(true)
timedSession:GetInput():SetSessionLocked(true, "terminal-refresh")
assert(not timedPool:GetFrame(1, 1).mouseEnabled, "idempotent terminal lock did not reassert interaction state")
end

function addon:TestHUDPresentationForTest()
local hudGrid = addon.Grid:New()
FillStablePattern(hudGrid)
hudGrid:Set(2, 8, 1)
hudGrid:Set(3, 8, 1)
hudGrid:Set(1, 7, 1)
assert(hudGrid:FindLegalMove(), "HUD fixture has no hintable move")
local hudPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
hudPool:Project(hudGrid, true)
local hudAnimations = addon.Animations:New(hudPool, {
	createFrame = CreateGemPoolFrame,
	hintDelay = 0.05,
})
local hudProfile = addon.SavedVariables:CreateDefaultProfile()
local hudChatMessages = {}
local hudState = addon.Scoring:NewState(addon.Constants.GAME_MODE_CLASSIC, {
	score = 12345,
	level = 3,
	pointsToLevelUp = 16000,
	pointMultiplier = 2,
	largestCascade = 7,
	largestCombo = 4,
	moves = 20,
})
local userPauseEvents = 0
local userLevelEvents = 0
local hud = addon.HUD:New(gemPoolParent, hudAnimations, {
	createFrame = CreateGemPoolFrame,
	statusDuration = 0.1,
	achievementDuration = 0.1,
	profile = hudProfile,
	chatMessage = function(message)
		hudChatMessages[#hudChatMessages + 1] = message
		return true
	end,
	skillLabel = function(event)
		return event.index == addon.Constants.ACHIEVEMENT_POWER100 and "I've Got The Power!" or nil
	end,
	skillDescription = function(event)
		return event.index == addon.Constants.ACHIEVEMENT_POWER100 and "Get a Power Gem total of 100+" or nil
	end,
})
local hudSession = hud:CreateSession(hudGrid, hudPool, {
	profile = hudProfile,
	playerName = "Nighthawk",
	scoringState = hudState,
	autoSave = false,
	detectGameOver = false,
	deferLevelTransitions = true,
	deferGameOverTransitions = true,
	inputOptions = {
		random = MakeRandom(9201),
		requireLegalMove = false,
	},
	onPauseChanged = function()
		userPauseEvents = userPauseEvents + 1
	end,
	onLevelTransitionComplete = function()
		userLevelEvents = userLevelEvents + 1
	end,
})
assert(hud.session == hudSession, "HUD did not attach its created session")
AssertEqual(hud.levelPanel.caption.text, "LVL", "classic HUD level caption")
AssertEqual(hud.levelPanel.value.text, "3", "classic HUD level value")
AssertEqual(hud.dataPanel.value.text, "12,345", "classic HUD formatted score")
AssertEqual(hud.progress.ratio, 12345 / 16000, "classic HUD progress ratio")
AssertEqual(hud.levelPanel.width, 94, "classic HUD level capsule width")
AssertEqual(hud.dataPanel.width, 128, "classic HUD score capsule width")
AssertEqual(hud.progress.width, 236, "classic HUD progress width")
AssertEqual(hud.progress.fill.points[1][1], "TOPLEFT", "classic HUD progress fill anchor")
AssertEqual(hud.progress.fill.points[1][5], -5, "classic HUD progress fill vertical offset")
assert(hudAnimations.hint and hudAnimations.hint.active, "HUD did not schedule an idle hint")

hudSession:Pause("hud-test")
assert(hud.pausedFrame.shown, "paused HUD overlay remained hidden")
assert(not hudAnimations.hint.active, "paused HUD retained its hint")
hudSession:Resume("hud-test")
assert(not hud.pausedFrame.shown, "resumed HUD retained its pause overlay")
assert(hudAnimations.hint.active, "resumed HUD did not reschedule its hint")
AssertEqual(userPauseEvents, 2, "HUD callback wiring replaced user pause callbacks")

local skillEvent = {
	type = addon.Constants.SKILL_TYPE_ACHIEVEMENT,
	index = addon.Constants.ACHIEVEMENT_POWER100,
	gained = 5,
	completed = true,
	pointsAfter = 80,
}
local floatingBefore = #hudAnimations.activeFloatingText
hud:OnCascadeResolved({
	scoringResult = {
		points = 75,
		scoreEvents = { { contents = 3 } },
		skillEvents = { skillEvent },
	},
})
AssertEqual(#hudAnimations.activeFloatingText, floatingBefore + 2, "HUD omitted score or achievement floating text")
AssertEqual(hud.achievementFrame.text.text, "Achievement: I've Got The Power!", "HUD achievement message")
AssertEqual(#hudChatMessages, 1, "HUD local skill chat message count")
AssertEqual(
	hudChatMessages[1],
	'[Bejeweled Addon] You just completed "Get a Power Gem total of 100+." +5 Skill!',
	"HUD local skill chat message"
)
AssertEqual(hud:PresentSkillEvents({ skillEvent }), 0, "HUD repeated an already-presented skill event")
AssertEqual(#hudChatMessages, 1, "HUD repeated local skill chat output")
local rankMessages = hud:BuildSkillChatMessages({
	gained = 1,
	pointsAfter = 75,
	rankUp = true,
	rankAfter = 2,
})
AssertEqual(#rankMessages, 2, "HUD rank-up local message count")
AssertEqual(rankMessages[1], "Your skill in Bejeweling has increased to 75.", "HUD rank-up skill message")
AssertEqual(rankMessages[2], "Your Bejeweling skill is now of the Journeyman rank.", "HUD rank-up message")
hud:Update(0.11)
assert(not hud.achievementFrame.shown, "HUD achievement notice did not expire")
hudAnimations:ClearTransientEffects()

hudState.score = hudState.pointsToLevelUp
hudState.levelPending = true
hudSession:HandleMoveComplete({ status = "complete" })
assert(hudSession:IsLevelTransitionPending(), "HUD level fixture did not defer its transition")
AssertEqual(hud.statusFrame.text.text, "Level up", "HUD level-start status")
assert(hud.statusFrame.shown, "HUD level-start status remained hidden")
local hudLevelResult = hudSession:CompleteLevelTransition()
AssertEqual(hudLevelResult.level, 4, "HUD level transition result")
AssertEqual(hud.levelPanel.value.text, "4", "HUD did not refresh the completed level")
AssertEqual(hud.statusFrame.text.text, "Level 4", "HUD level-complete status")
AssertEqual(userLevelEvents, 1, "HUD callback wiring replaced user level callbacks")
hud:Update(0.11)
assert(not hud.statusFrame.shown, "HUD temporary status did not expire")

local gameOverStarted = hudSession:BeginGameOver("manual-test")
AssertEqual(gameOverStarted.kind, "no-more-moves", "HUD classic game-over kind")
AssertEqual(hud.statusFrame.text.text, "No More Moves", "HUD game-over status")
hud:Update(10)
assert(hud.statusFrame.shown, "persistent HUD game-over status expired")
local hudSummary = hudSession:CompleteGameOver()
assert(hudSummary.personalBest, "HUD game-over fixture omitted personal-best data")
assert(hud.summaryFrame.shown, "HUD final summary remained hidden")
assert(string.find(hud.summaryFrame.text.text, "Score: 16,000", 1, true), "HUD summary omitted the formatted score")
assert(string.find(hud.summaryFrame.text.text, "Largest cascade: 7", 1, true), "HUD summary omitted cascade data")
assert(not hud.statusFrame.shown, "HUD final summary retained the game-over banner")

local timedGrid = addon.Grid:New()
FillStablePattern(timedGrid)
local timedPool = addon.GemPool:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	createBoardTiles = false,
})
timedPool:Project(timedGrid, true)
local timedAnimations = addon.Animations:New(timedPool, { createFrame = CreateGemPoolFrame })
local timedHUD = addon.HUD:New(gemPoolParent, timedAnimations, { createFrame = CreateGemPoolFrame })
local timedProfile = addon.SavedVariables:CreateDefaultProfile()
local timedState = addon.Scoring:NewState(addon.Constants.GAME_MODE_TIMED, {
	score = 300,
	pointMultiplier = 2.5,
})
local timedSession = timedHUD:CreateSession(timedGrid, timedPool, {
	profile = timedProfile,
	playerName = "Nighthawk",
	gameMode = addon.Constants.GAME_MODE_TIMED,
	scoringState = timedState,
	timerElapsed = 30,
	timeLimit = 60,
	detectGameOver = false,
	autoSave = false,
	inputOptions = { requireLegalMove = false },
})
AssertEqual(timedHUD.levelPanel.caption.text, "PPS", "timed HUD PPS caption")
AssertEqual(timedHUD.levelPanel.value.text, "10.00", "timed HUD PPS value")
AssertEqual(timedHUD.dataPanel.value.text, "2.5x", "timed HUD multiplier")
AssertEqual(timedHUD.progress.text.text, "0:30", "timed HUD countdown")
AssertEqual(timedHUD.progress.ratio, 0.5, "timed HUD progress ratio")
timedSession:SetElapsed(60)
timedHUD:Update(0)
AssertEqual(timedHUD.progress.text.text, "0:00", "timed HUD zero countdown")
AssertEqual(timedHUD.progress.ratio, 0, "timed HUD empty progress")
end

function addon:TestMainWindowForTest()
local runtimeProfile = addon.SavedVariables:CreateDefaultProfile()
local runtimeAccount = addon.SavedVariables:CreateDefaultAccount()
local runtimeAudio = {
	played = {},
	elapsed = 0,
}
function runtimeAudio:Play(soundName)
	self.played[#self.played + 1] = soundName
	return true
end
function runtimeAudio:Update(elapsed)
	self.elapsed = self.elapsed + elapsed
	return {}
end
local sessionStarts = {}
local sessionStops = {}
local flightState
local flightRequests = {}
local runtime = addon.MainWindow:New(gemPoolParent, {
	createFrame = CreateGemPoolFrame,
	profile = runtimeProfile,
	accountData = runtimeAccount,
	audio = runtimeAudio,
	playerName = "Nighthawk",
	random = MakeRandom(12001),
	onSessionStarted = function(result)
		sessionStarts[#sessionStarts + 1] = result
	end,
	onSessionStopped = function(result)
		sessionStops[#sessionStops + 1] = result
	end,
	flightOptionProvider = function()
		return flightState
	end,
	onFlightTimedRequested = function(state, window)
		flightRequests[#flightRequests + 1] = state
		return window:StartTimed(state.seconds)
	end,
})
AssertEqual(runtime.frame.width, addon.MainWindow.WINDOW_WIDTH, "runtime window width")
AssertEqual(runtime.frame.height, addon.MainWindow.WINDOW_HEIGHT, "runtime window height")
AssertEqual(runtime.boardSurface.width, 400, "runtime board width")
AssertEqual(runtime.boardSurface.height, 400, "runtime board height")
AssertEqual(#runtime.gemPool.tiles, 16, "runtime board tile count")
AssertEqual(runtime.summary.frame.width, 400, "runtime summary width")
AssertEqual(runtime.summary.frame.height, 400, "runtime summary height")
AssertEqual(runtime.skills.frame.width, 400, "runtime skill-screen width")
AssertEqual(runtime.skills.frame.height, 400, "runtime skill-screen height")
AssertEqual(runtime.options.frame.width, 400, "runtime options width")
AssertEqual(runtime.about.frame.width, 400, "runtime About width")
AssertEqual(runtime.legal.frame.width, 400, "runtime legal width")
runtime:Show()
assert(runtime.frame.shown, "runtime window did not show")
assert(runtime:IsShown(), "runtime visibility state did not follow Show")
AssertEqual(runtime.activeOverlay, "legal", "runtime initial legal notice")
assert(runtime.legal:IsShown(), "runtime initial legal notice remained hidden")
assert(string.find(runtime.legal.frame.text.text, "PopCap Games", 1, true), "runtime legal notice omitted PopCap attribution")
runtime.legal.okayButton.scripts.OnClick()
assert(runtimeAccount.legalDisplayed, "runtime legal acknowledgement was not persisted")
AssertEqual(runtime.activeOverlay, "menu", "runtime initial menu")
assert(not runtime.overlays.menu.resume.shown, "runtime initial menu exposed Resume")

runtimeProfile.skill.rank = 3
runtimeProfile.skill.skillPoints = 175
runtimeProfile.skill.gainFun1 = true
runtimeProfile.skill.gainAchieve1 = true
runtimeProfile.stats.classic.score = 123456
runtimeProfile.stats.timed.score = 42.5
runtimeProfile.stats.gemMatch[4] = 99
runtimeAccount.played.Nighthawk = 12
runtime.overlays.menu.skills.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "skills", "runtime Feats action did not open the skill screen")
assert(runtime.skills:IsShown(), "runtime skill screen remained hidden")
AssertEqual(runtime.skills.frame.rank.text, "Bejeweling Skill Rank: Expert", "runtime skill rank caption")
AssertEqual(runtime.skills.progress.text.text, "175 / 225", "runtime skill progress caption")
AssertEqual(runtime.skills.progress.ratio, 25 / 75, "runtime skill rank progress")
AssertEqual(runtime.skills.progress.fill.path, addon.Constants.IMAGE_ROOT .. "barArt", "runtime skill progress texture")
AssertEqual(runtime.skills.progress.fill.points[1][1], "LEFT", "runtime skill progress fill anchor")
AssertEqual(runtime.skills.progress.fill.points[1][5], 0, "runtime skill progress fill alignment")
local visibleSkills = runtime.skills:GetVisibleRecords()
AssertEqual(visibleSkills[1].category, "Match Gems", "runtime first skill category")
AssertEqual(visibleSkills[1].name, "Match 5 Gems (Create a |cFFA335EE[Hyper Cube]|r)", "runtime first skill challenge")
visibleSkills[1].name = "changed by caller"
AssertEqual(runtime.skills:GetVisibleRecords()[1].name, "Match 5 Gems (Create a |cFFA335EE[Hyper Cube]|r)", "runtime skill records were not copied")
runtime.skills.statisticsTab.scripts.OnClick()
AssertEqual(runtime.skills.activeTab, "statistics", "runtime statistics tab selection")
local visibleStatistics = runtime.skills:GetVisibleRecords()
AssertEqual(visibleStatistics[1].label, "Classic High Score", "runtime first personal statistic")
AssertEqual(visibleStatistics[1].value, "123,456", "runtime formatted Classic high score")
AssertEqual(runtime.skills:GetPageCount(), 3, "runtime statistics page count")
runtime.skills.leaderboardsTab.scripts.OnClick()
AssertEqual(runtime.skills.activeTab, "leaderboards", "runtime leaderboard tab selection")
AssertEqual(runtime.skills.scopeButton.label.text, "Guild", "runtime default leaderboard scope")
AssertEqual(runtime.skills.modeButton.label.text, "Classic", "runtime default leaderboard mode")
local visibleScores = runtime.skills:GetVisibleRecords()
AssertEqual(visibleScores[1].name, "PopCap Games", "runtime first local leaderboard name")
AssertEqual(visibleScores[1].formattedScore, "1,000", "runtime first local leaderboard score")
runtime.skills.scopeButton.scripts.OnClick()
AssertEqual(runtime.skills.leaderboardScope, "friends", "runtime leaderboard scope toggle")
runtime.skills.modeButton.scripts.OnClick()
AssertEqual(runtime.skills.leaderboardMode, "timed", "runtime leaderboard mode toggle")
runtime.skills.achievementsTab.scripts.OnClick()
AssertEqual(runtime.skills.activeTab, "achievements", "runtime achievement tab selection")
AssertEqual(runtime.skills.frame.status.text, "Unlocked 13 / 26   Completed 2", "runtime achievement counts")
AssertEqual(runtime.skills:GetPageSize(), addon.Skills.ACHIEVEMENT_PAGE_SIZE, "runtime achievement page size")
AssertEqual(runtime.skills.rows[1].height, 38, "runtime achievement row height")
AssertEqual(runtime.skills.rows[1].icon.width, 32, "runtime achievement icon width")
AssertEqual(runtime.skills.rows[1].icon.height, 32, "runtime achievement icon height")
AssertEqual(runtime.skills.rows[1].title.points[1][4], 42, "runtime achievement title inset")
AssertEqual(runtime.skills.rows[1].description.points[1][4], 42, "runtime achievement description inset")
local visibleAchievements = runtime.skills:GetVisibleRecords()
assert(visibleAchievements[1].completed, "runtime completed achievements were not sorted first")
AssertEqual(runtime.skills:GetPageCount(), 3, "runtime achievement page count")
runtime.skills.nextButton.scripts.OnClick()
AssertEqual(runtime.skills.page, 2, "runtime achievement next-page action")
assert(runtime.skills.previousButton.shown, "runtime achievement previous-page action remained hidden")
runtime.skills.backButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "menu", "runtime skill-screen Back action")
assert(not runtime.skills:IsShown(), "runtime skill-screen Back action retained the screen")
runtimeProfile.skill.rank = 1
runtimeProfile.skill.skillPoints = 0
runtimeProfile.skill.gainFun1 = nil
runtimeProfile.skill.gainAchieve1 = nil
runtimeProfile.stats.classic.score = 0
runtimeProfile.stats.timed.score = 0
runtimeProfile.stats.gemMatch[4] = 0
runtimeAccount.played.Nighthawk = nil

runtime.overlays.menu.settings.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "options", "runtime Settings action")
assert(runtime.options:IsShown(), "runtime Settings screen remained hidden")
runtime.options.rows[1].scripts.OnClick()
AssertEqual(runtimeProfile.settings.gameAlpha, 0.9, "runtime game-opacity setting")
AssertEqual(runtime.frame.alpha, 0.9, "runtime game-opacity application")
runtime.options.rows[3].scripts.OnClick()
AssertEqual(runtime.options:GetSoundMode(), "Quiet", "runtime sound-mode setting")
runtime.options.rows[4].scripts.OnClick()
assert(runtimeProfile.settings.disableHints, "runtime hint setting")
assert(not runtime.hud:AreHintsEnabled(), "runtime hint setting did not reach the HUD")
runtime.options.backButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "menu", "runtime Settings Back action")
runtimeProfile.settings.gameAlpha = 1
runtimeProfile.settings.disableHints = nil
runtimeProfile.settings.quietSounds = nil
runtimeProfile.settings.enableSounds = 1
runtime:ApplySettings("gameAlpha")

runtime.overlays.menu.about.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "about", "runtime About action")
AssertEqual(runtime.about.activeTab, "tutorial", "runtime default About tab")
runtime.about.tabs.story.scripts.OnClick()
AssertEqual(runtime.about.activeTab, "story", "runtime About story tab")
assert(string.find(runtime.about.contents.story.text.text, "github.com/Nighthawk42", 1, true), "runtime About story omitted project home")
runtime.about.tabs.credits.scripts.OnClick()
AssertEqual(runtime.about.activeTab, "credits", "runtime About credits tab")
runtime.about.backButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "menu", "runtime About Back action")

runtime.overlays.menu.legal.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "legal", "runtime manual Legal action")
runtime.legal.okayButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "menu", "runtime Legal acknowledgement action")

runtime.overlays.menu.newGame.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "mode", "runtime New Game did not show mode selection")
runtime.overlays.mode.classic.scripts.OnClick()
local firstClassic = runtime.session
assert(firstClassic and firstClassic.active, "runtime Classic session did not start")
assert(not runtime.animations:IsPaused(), "runtime Classic session inherited the menu pause")
AssertEqual(firstClassic.gameMode, addon.Constants.GAME_MODE_CLASSIC, "runtime Classic mode")
assert(runtime.grid:FindLegalMove(), "runtime Classic board has no legal move")
assert(runtimeProfile.settings.classicInProgress, "new Classic runtime was not resumable")
assert(type(runtime.gemPool:GetFrame(1, 1).scripts.OnMouseDown) == "function", "runtime did not attach gem input")
AssertEqual(sessionStarts[1].status, "started", "runtime Classic start callback")
runtime:Update(1.5)
AssertEqual(firstClassic.timerElapsed, 1.5, "runtime update did not advance session time")
AssertEqual(runtimeAudio.elapsed, 1.5, "runtime update did not flush audio")

runtime:ShowMenu()
assert(firstClassic:IsPaused(), "runtime menu did not pause Classic play")
assert(runtime.overlays.menu.resume.shown, "active runtime menu hid Resume")
assert(not runtime.hud.statusFrame.shown, "runtime menu retained the HUD status banner")
assert(not runtime.hud.achievementFrame.shown, "runtime menu retained the HUD achievement banner")
assert(not runtime.hud.pausedFrame.shown, "runtime menu retained the HUD paused banner")
runtime.overlays.menu.resume.scripts.OnClick()
assert(not firstClassic:IsPaused(), "runtime Resume left Classic paused")
assert(runtime.activeOverlay == nil, "runtime Resume retained a menu overlay")

firstClassic.scoringState.score = 2468
firstClassic:SaveClassicGame("continue-fixture")
runtime:ShowMenu()
runtime.overlays.menu.newGame.scripts.OnClick()
runtime.overlays.mode.classic.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "classic", "saved Classic did not show Continue/New Game")
runtime.overlays.classic.continue.scripts.OnClick()
local restoredClassic = runtime.session
assert(restoredClassic ~= firstClassic, "runtime Continue reused the abandoned session")
assert(not runtime.animations:IsPaused(), "runtime Continue inherited the menu pause")
assert(not firstClassic.active and firstClassic:IsLocked(), "runtime replacement did not deactivate the old session")
AssertEqual(restoredClassic.scoringState.score, 2468, "runtime Continue score")
AssertEqual(sessionStarts[2].status, "restored", "runtime Continue callback")
AssertEqual(#sessionStops, 1, "runtime Continue omitted session-stop callback")

runtime:ShowMenu()
runtime.overlays.menu.newGame.scripts.OnClick()
runtime.overlays.mode.timed.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "timed", "runtime Timed choice did not show setup")
AssertEqual(runtime.overlays.timed.slider.minimum, addon.MainWindow.MIN_TIMED_MINUTES, "runtime Timed minimum minutes")
AssertEqual(runtime.overlays.timed.slider.maximum, addon.MainWindow.MAX_TIMED_MINUTES, "runtime Timed maximum minutes")
AssertEqual(runtime.overlays.timed.slider.valueStep, 1, "runtime Timed minute step")
assert(runtime.overlays.timed.slider.obeyStepOnDrag, "runtime Timed slider did not obey its minute step")
AssertEqual(runtime.overlays.timed.slider.value, 5, "runtime Timed default minutes")
AssertEqual(runtime.overlays.timed.durationValue.text, "5 Minutes", "runtime Timed default caption")
assert(not runtime.overlays.timed.flightToggle.shown, "runtime exposed flight timing without adapter state")
runtime.overlays.timed.slider:SetValue(10)
AssertEqual(runtime.overlays.timed.durationValue.text, "10 Minutes", "runtime Timed upper-bound caption")
runtime.overlays.timed.slider:SetValue(2)
AssertEqual(runtime.overlays.timed.durationValue.text, "2 Minutes", "runtime Timed lower-bound caption")
runtime.overlays.timed.slider:SetValue(5)
runtime.overlays.timed.go.scripts.OnClick()
local timedRuntime = runtime.session
AssertEqual(timedRuntime.gameMode, addon.Constants.GAME_MODE_TIMED, "runtime Timed mode")
assert(not runtime.animations:IsPaused(), "runtime Timed session inherited the menu pause")
assert(runtime.gemPool:GetFrame(1, 1).mouseEnabled, "runtime Timed replacement left gem input disabled")
AssertEqual(timedRuntime.timeLimit, addon.MainWindow.DEFAULT_TIMED_DURATION, "runtime default Timed duration")
AssertEqual(runtime.hud.levelPanel.caption.text, "PPS", "runtime Timed HUD mode")
AssertEqual(sessionStarts[3].timeLimit, addon.MainWindow.DEFAULT_TIMED_DURATION, "runtime Timed callback duration")
assert(not restoredClassic.active, "runtime Timed start left Classic active")
timedRuntime.scoringState.score = 900
timedRuntime.scoringState.level = 2
timedRuntime.scoringState.largestCascade = 8
timedRuntime.scoringState.largestCombo = 3
timedRuntime.scoringState.moves = 12
timedRuntime:SetElapsed(60)
timedRuntime:BeginGameOver("runtime-restart-fixture")
assert(timedRuntime:IsGameOver() and timedRuntime:IsLocked(), "runtime Timed fixture did not reach terminal state")
assert(timedRuntime:GetGameOverSummary(), "runtime Timed summary handoff is unavailable")
AssertEqual(runtime.activeOverlay, "summary", "completed runtime did not open the summary")
assert(runtime.summary:IsShown(), "runtime summary frame remained hidden")
assert(not runtime.hud.summaryFrame.shown, "runtime retained the compact HUD summary")
AssertEqual(runtime.summary.frame.mode.text, "Timed Mode", "runtime summary mode")
AssertEqual(runtime.summary.metrics.primary.caption.text, "Points per Second", "runtime summary primary caption")
AssertEqual(runtime.summary.metrics.primary.value.text, "15.00", "runtime summary primary value")
AssertEqual(runtime.summary.metrics.time.value.text, "1 min 0 sec", "runtime summary elapsed time")
AssertEqual(runtime.summary.metrics.level.value.text, "2", "runtime summary level")
AssertEqual(runtime.summary.metrics.cascade.value.text, "8", "runtime summary largest cascade")
AssertEqual(runtime.summary.metrics.combo.value.text, "3", "runtime summary largest combo")
AssertEqual(runtime.summary.metrics.moves.value.text, "12", "runtime summary moves")
AssertEqual(runtime.summary.metrics.best.value.text, "15.00", "runtime summary personal best")
runtime.summary.menuButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "menu", "runtime summary Menu action")
assert(not runtime.summary:IsShown(), "runtime summary Menu action retained the summary")
assert(not runtime.overlays.menu.resume.shown, "terminal runtime menu exposed Resume")
local classicSummaryFixture = {
	gameMode = addon.Constants.GAME_MODE_CLASSIC,
	metricName = "score",
	metric = 1234567,
	elapsed = 75.9,
	level = 9,
	largestCascade = 14,
	largestCombo = 6,
	moves = 44,
	personalBest = { best = 1234567 },
}
runtime:ShowSummary(classicSummaryFixture)
AssertEqual(runtime.summary.frame.mode.text, "Classic Mode", "runtime Classic summary mode")
AssertEqual(runtime.summary.metrics.primary.caption.text, "Final Score", "runtime Classic summary primary caption")
AssertEqual(runtime.summary.metrics.primary.value.text, "1,234,567", "runtime Classic summary formatted score")
AssertEqual(runtime.summary.metrics.time.value.text, "1 min 15 sec", "runtime Classic summary floored time")
classicSummaryFixture.metric = 0
AssertEqual(runtime.summary:GetResult().metric, 1234567, "runtime summary retained provider-owned result state")
runtime.summary.newGameButton.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "mode", "runtime summary New Game action")
assert(not runtime.summary:IsShown(), "runtime summary New Game action retained the summary")
timedRuntime = runtime:StartTimed(60)
assert(runtime.gemPool:GetFrame(1, 1).mouseEnabled, "runtime terminal replacement left gem input disabled")
AssertEqual(timedRuntime.timeLimit, 60, "runtime custom Timed duration")

flightState = { seconds = 59, learning = false, routeToken = "short-route" }
runtime:ShowModeMenu()
runtime.overlays.mode.timed.scripts.OnClick()
assert(runtime.overlays.timed.flightWarning.shown, "short flight time warning was hidden")
assert(not runtime.overlays.timed.flightToggle.shown, "short flight time remained selectable")
flightState = { seconds = 12, learning = true, routeToken = "learning-route" }
runtime:RefreshTimedSetup()
assert(runtime.overlays.timed.flightToggle.shown, "flight-learning option was hidden")
AssertEqual(runtime.overlays.timed.flightStatus.text, "Recording flight time: 0 min 12 sec", "flight-learning status")
flightState = { seconds = 125, learning = false, routeToken = "known-route" }
runtime:RefreshTimedSetup()
assert(runtime.overlays.timed.flightToggle.shown, "known flight time option was hidden")
AssertEqual(runtime.overlays.timed.flightStatus.text, "Remaining flight time: 2 min 5 sec", "known flight status")
runtime.overlays.timed.flightToggle.scripts.OnClick()
assert(runtime.flightOptionSelected, "flight timing option did not select")
AssertEqual(runtime.overlays.timed.flightToggle.label.text, "[x] Use flight path time", "flight timing selected caption")
runtime:RefreshTimedSetup()
assert(runtime.flightOptionSelected, "flight timing refresh discarded an active selection")
runtime.overlays.timed.go.scripts.OnClick()
timedRuntime = runtime.session
AssertEqual(#flightRequests, 1, "flight timing request callback count")
assert(flightRequests[1] ~= flightState, "flight timing request leaked provider state")
AssertEqual(flightRequests[1].routeToken, "known-route", "flight timing request context")
AssertEqual(timedRuntime.timeLimit, 125, "flight timing request duration")
assert(runtime.activeOverlay == nil, "accepted flight timing request retained setup")

runtime:Hide()
assert(timedRuntime:IsPaused(), "hidden runtime window did not pause play")
assert(not runtime:IsShown(), "runtime visibility state did not follow Hide")
runtime:Show()
assert(not timedRuntime:IsPaused(), "shown runtime window did not resume its owned pause")
runtime.frame.scripts.OnDragStart(runtime.frame)
assert(runtime.frame.moving, "unlocked runtime window did not start moving")
runtime.frame.scripts.OnDragStop(runtime.frame)
assert(not runtime.frame.moving, "runtime drag stop left the window moving")
runtimeProfile.settings.lockWindow = true
runtime.frame.scripts.OnDragStart(runtime.frame)
assert(not runtime.frame.moving, "locked runtime window started moving")

runtime:ShowMenu()
runtime.overlays.menu.newGame.scripts.OnClick()
runtime.overlays.mode.classic.scripts.OnClick()
AssertEqual(runtime.activeOverlay, "classic", "runtime Classic save chooser was skipped")
runtime.overlays.classic.newGame.scripts.OnClick()
local freshClassic = runtime.session
AssertEqual(freshClassic.scoringState.score, 0, "runtime fresh Classic retained prior score")
assert(freshClassic ~= restoredClassic, "runtime fresh Classic reused a prior session")
AssertEqual(#sessionStarts, 6, "runtime session-start callback count")
AssertEqual(#sessionStops, 5, "runtime session-stop callback count")
end

TestSessionRestore()
TestGameOverTransitions()
addon:TestHUDPresentationForTest()
addon.TestHUDPresentationForTest = nil
addon:TestMainWindowForTest()
addon.TestMainWindowForTest = nil

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
assert(addon.fonts == addon.Fonts, "addon initialization did not install Fonts")
assert(addon.backdrops == addon.Backdrops, "addon initialization did not install backdrops")
assert(addon.gemPoolFactory == addon.GemPool, "addon initialization did not install GemPool")
assert(addon.animationFactory == addon.Animations, "addon initialization did not install Animations")
assert(addon.hudFactory == addon.HUD, "addon initialization did not install HUD")
assert(addon.summaryFactory == addon.Summary, "addon initialization did not install Summary")
assert(addon.skillsFactory == addon.Skills, "addon initialization did not install Skills")
assert(addon.optionsFactory == addon.Options, "addon initialization did not install Options")
assert(addon.aboutFactory == addon.About, "addon initialization did not install About")
assert(addon.legalFactory == addon.Legal, "addon initialization did not install Legal")
assert(addon.mainWindowFactory == addon.MainWindow, "addon initialization did not install MainWindow")
assert(addon.compartment == addon.Compartment, "addon initialization did not install Compartment")
assert(addon.inputFactory == addon.Input, "addon initialization did not install Input")
assert(addon.sessionFactory == addon.Session, "addon initialization did not install Session")
assert(eventFrame.registeredEvent == nil, "initializer event was not unregistered")
local initializedGrid = addon.grid
local initializedAudio = addon.audio
local initializedBackdrops = addon.backdrops
local initializedGemPoolFactory = addon.gemPoolFactory
local initializedAnimationFactory = addon.animationFactory
local initializedHUDFactory = addon.hudFactory
local initializedInputFactory = addon.inputFactory
local initializedSessionFactory = addon.sessionFactory
addon:Initialize({}, {})
assert(addon.grid == initializedGrid, "addon initialization is not idempotent")
assert(addon.audio == initializedAudio, "audio initialization is not idempotent")
assert(addon.fonts == addon.Fonts, "Fonts initialization is not idempotent")
assert(addon.backdrops == initializedBackdrops, "backdrop initialization is not idempotent")
assert(addon.gemPoolFactory == initializedGemPoolFactory, "GemPool initialization is not idempotent")
assert(addon.animationFactory == initializedAnimationFactory, "Animations initialization is not idempotent")
assert(addon.hudFactory == initializedHUDFactory, "HUD initialization is not idempotent")
assert(addon.summaryFactory == addon.Summary, "Summary initialization is not idempotent")
assert(addon.skillsFactory == addon.Skills, "Skills initialization is not idempotent")
assert(addon.optionsFactory == addon.Options, "Options initialization is not idempotent")
assert(addon.aboutFactory == addon.About, "About initialization is not idempotent")
assert(addon.legalFactory == addon.Legal, "Legal initialization is not idempotent")
assert(addon.mainWindowFactory == addon.MainWindow, "MainWindow initialization is not idempotent")
assert(addon.compartment == addon.Compartment, "Compartment initialization is not idempotent")
assert(addon.inputFactory == initializedInputFactory, "Input initialization is not idempotent")
assert(addon.sessionFactory == initializedSessionFactory, "Session initialization is not idempotent")
addon.runtimeForTest = addon:StartRuntime({
	uiParent = gemPoolParent,
	createFrame = CreateGemPoolFrame,
	playerName = "Nighthawk",
	random = MakeRandom(13001),
})
assert(addon.runtimeForTest == addon.runtime, "StartRuntime did not retain the playable shell")
AssertEqual(addon.runtimeForTest.activeOverlay, "legal", "StartRuntime did not open the first-run legal notice")
addon.runtimeForTest.legal.okayButton.scripts.OnClick()
AssertEqual(addon.runtimeForTest.activeOverlay, "menu", "StartRuntime legal acknowledgement did not open the menu")
assert(addon:StartRuntime() == addon.runtimeForTest, "StartRuntime is not idempotent")

function addon:TestCompartmentForTest()
	local mockRuntime = { visible = false, toggleCount = 0 }
	function mockRuntime:Toggle()
		self.visible = not self.visible
		self.toggleCount = self.toggleCount + 1
		return self
	end
	function mockRuntime:IsShown()
		return self.visible
	end
	local providerCalls = 0
	local tooltip = { lines = {} }
	function tooltip:SetOwner(owner, anchor)
		self.owner = owner
		self.anchor = anchor
	end
	function tooltip:SetText(value)
		self.text = value
	end
	function tooltip:AddLine(...)
		self.lines[#self.lines + 1] = { ... }
	end
	function tooltip:Show()
		self.shown = true
	end
	function tooltip:Hide()
		self.shown = false
	end
	local compartment = self.Compartment:New({
		addon = self,
		tooltip = tooltip,
		runtimeProvider = function()
			providerCalls = providerCalls + 1
			return mockRuntime
		end,
	})
	local shown = compartment:OnClick("Bejeweled", "LeftButton")
	AssertEqual(shown.status, "shown", "pre-runtime compartment show status")
	assert(shown.runtime == mockRuntime, "pre-runtime compartment did not retain the provided runtime")
	AssertEqual(providerCalls, 1, "pre-runtime provider call count")
	local hidden = compartment:OnClick("Bejeweled", "LeftButton")
	AssertEqual(hidden.status, "hidden", "compartment hide status")
	AssertEqual(mockRuntime.toggleCount, 2, "compartment runtime toggle count")
	local ignored = compartment:OnClick("Bejeweled", "RightButton")
	AssertEqual(ignored.status, "ignored", "compartment non-left click status")
	AssertEqual(providerCalls, 2, "ignored compartment click started a runtime")

	local menuButton = {}
	assert(compartment:OnEnter("Bejeweled", menuButton), "compartment hover did not show its tooltip")
	assert(tooltip.owner == menuButton, "compartment tooltip owner changed")
	AssertEqual(tooltip.anchor, "ANCHOR_LEFT", "compartment tooltip anchor")
	AssertEqual(tooltip.text, "Bejeweled", "compartment tooltip title")
	AssertEqual(tooltip.lines[1][1], "Left-click to show or hide the game.", "compartment tooltip instruction")
	assert(tooltip.shown, "compartment tooltip did not show")
	assert(compartment:OnLeave("Bejeweled", menuButton), "compartment hover leave was ignored")
	assert(not tooltip.shown, "compartment tooltip did not hide")

	assert(type(Bejeweled_OnAddonCompartmentClick) == "function", "compartment click global is unavailable")
	assert(type(Bejeweled_OnAddonCompartmentEnter) == "function", "compartment enter global is unavailable")
	assert(type(Bejeweled_OnAddonCompartmentLeave) == "function", "compartment leave global is unavailable")
	local liveHidden = Bejeweled_OnAddonCompartmentClick("Bejeweled", "LeftButton")
	AssertEqual(liveHidden.status, "hidden", "live compartment hide status")
	assert(not self.runtimeForTest:IsShown(), "live compartment did not hide the runtime")
	local liveShown = Bejeweled_OnAddonCompartmentClick("Bejeweled", "LeftButton")
	AssertEqual(liveShown.status, "shown", "live compartment show status")
	assert(self.runtimeForTest:IsShown(), "live compartment did not restore the runtime")
end

addon:TestCompartmentForTest()
addon.TestCompartmentForTest = nil

print("Runtime verification passed: local skill chat, aligned skill/footer presentation, full local summary, Timed setup/flight boundary, addon-compartment access, playable Classic/Timed window shell, HUD, pause/restore/level/game-over sessions, input, cascade/effect animation, gem projection, UI backdrops, audio, SavedVariables, and deterministic gameplay engine.")
