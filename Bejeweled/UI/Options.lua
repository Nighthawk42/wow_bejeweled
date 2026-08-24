local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local Options = {}
Options.__index = Options

local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"
local PAGE_SIZE = 8
local ALPHA_STEPS = { 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3 }

local DEFINITIONS = {
	{ key = "gameAlpha", label = "Game Opacity", kind = "alpha" },
	{ key = "mouseoffAlpha", label = "Mouse-off Opacity", kind = "alpha" },
	{ key = "soundMode", label = "Sound", kind = "sound" },
	{ key = "disableHints", label = "Disable Hints", kind = "toggle" },
	{ key = "lockWindow", label = "Lock Window", kind = "toggle" },
	{ key = "publishSkillGains", label = "Chat Skill Gains", kind = "toggle" },
	{ key = "publishRankGains", label = "Guild Rank Gains", kind = "toggle" },
	{ key = "publishScores", label = "Publish Scores", kind = "toggle" },
	{ key = "hideDuplicates", label = "Hide Duplicate Scores", kind = "toggle" },
	{ key = "newGameFlight", label = "New Game on Flight", kind = "toggle" },
	{ key = "showFlightTooltips", label = "Show Flight Tooltips", kind = "toggle" },
	{ key = "openFlightStart", label = "Open at Flight Start", kind = "toggle" },
	{ key = "closeFlightEnd", label = "Close at Flight End", kind = "toggle" },
	{ key = "openOnDeath", label = "Open on Death", kind = "toggle" },
	{ key = "closeReadyCheck", label = "Close for Ready Check", kind = "toggle" },
	{ key = "openOnLogin", label = "Open on Login", kind = "toggle" },
	{ key = "closeCombat", label = "Close in Combat", kind = "toggle" },
}

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled options font could not be loaded")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

local function Clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

function Options:CreateFrame(parent, preset, width, height, levelOffset, frameType)
	local frame = Backdrops:CreateFrame({
		frameType = frameType,
		parent = parent,
		preset = preset,
		createFrame = self.createFrame,
		backgroundColor = { 0.08, 0.08, 0.08, 0.98 },
		borderColor = { 1, 0.8, 0.45, 1 },
	})
	frame:SetWidth(width)
	frame:SetHeight(height)
	if type(parent.GetFrameLevel) == "function" then
		frame:SetFrameLevel(parent:GetFrameLevel() + (levelOffset or 1))
	end
	return frame
end

function Options:CreateButton(parent, text, width, x, callback)
	local button = self:CreateFrame(parent, "tooltip", width, 26, 2, "Button")
	button:SetPoint("BOTTOM", parent, "BOTTOM", x, 10)
	button:EnableMouse(true)
	button.label = CreateFontString(button, 11, text, { 1, 0.85, 0, 1 })
	button.label:SetPoint("CENTER", button, "CENTER", 0, 0)
	button:SetScript("OnClick", callback)
	return button
end

function Options:GetSoundMode()
	if self.settings.disableSounds then
		return "Off"
	end
	if self.settings.quietSounds then
		return "Quiet"
	end
	return "Normal"
end

function Options:GetValueText(definition)
	if definition.kind == "sound" then
		return self:GetSoundMode()
	end
	local value = self.settings[definition.key]
	if definition.kind == "alpha" then
		return string.format("%d%%", math.floor((tonumber(value) or 1) * 100 + 0.5))
	end
	return value and "Enabled" or "Disabled"
end

function Options:GetSettingRecords()
	local records = {}
	for _, definition in ipairs(DEFINITIONS) do
		records[#records + 1] = {
			key = definition.key,
			label = definition.label,
			kind = definition.kind,
			value = self:GetValueText(definition),
		}
	end
	return records
end

function Options:CycleAlpha(key)
	local current = tonumber(self.settings[key]) or 1
	local closest = 1
	local distance = math.huge
	for index, value in ipairs(ALPHA_STEPS) do
		local candidateDistance = math.abs(value - current)
		if candidateDistance < distance then
			closest = index
			distance = candidateDistance
		end
	end
	self.settings[key] = ALPHA_STEPS[(closest % #ALPHA_STEPS) + 1]
end

function Options:CycleSound()
	local mode = self:GetSoundMode()
	self.settings.enableSounds = nil
	self.settings.quietSounds = nil
	self.settings.disableSounds = nil
	if mode == "Normal" then
		self.settings.quietSounds = 1
	elseif mode == "Quiet" then
		self.settings.disableSounds = 1
	else
		self.settings.enableSounds = 1
	end
end

function Options:Activate(definition)
	if definition.kind == "alpha" then
		self:CycleAlpha(definition.key)
	elseif definition.kind == "sound" then
		self:CycleSound()
	else
		self.settings[definition.key] = self.settings[definition.key] and nil or 1
	end
	self.onChanged(definition.key, self.settings[definition.key], self)
	self:Refresh()
	return self.settings[definition.key]
end

function Options:New(parent, options)
	assert(parent ~= nil, "options parent is required")
	options = options or {}
	assert(type(options.profile) == "table" and type(options.profile.settings) == "table", "options require profile settings")
	assert(type(options.onChanged) == "function", "options require an onChanged callback")
	assert(type(options.onBack) == "function", "options require an onBack callback")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		settings = options.profile.settings,
		onChanged = options.onChanged,
		onBack = options.onBack,
		page = 1,
		rows = {},
		visible = false,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for options")

	local frame = instance:CreateFrame(parent, "panel", 400, 400, 20)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	frame:EnableMouse(true)
	frame:Hide()
	frame.title = CreateFontString(frame, 20, "Settings", { 1, 0.85, 0.1, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -12)
	frame.help = CreateFontString(frame, 10, "Click a setting to change it", { 0.75, 0.75, 0.75, 1 })
	frame.help:SetPoint("TOP", frame.title, "BOTTOM", 0, -4)
	instance.frame = frame

	for index = 1, PAGE_SIZE do
		local row = instance:CreateFrame(frame, "tooltip", 360, 30, 1, "Button")
		row:SetPoint("TOP", frame.help, "BOTTOM", 0, -7 - ((index - 1) * 34))
		row:EnableMouse(true)
		row.label = CreateFontString(row, 11, "", { 1, 0.8, 0.15, 1 })
		row.label:SetPoint("LEFT", row, "LEFT", 9, 0)
		row.value = CreateFontString(row, 11, "", { 1, 1, 1, 1 })
		row.value:SetPoint("RIGHT", row, "RIGHT", -9, 0)
		row:SetScript("OnClick", function()
			local definition = row.definition
			if definition then
				instance:Activate(definition)
			end
		end)
		row:Hide()
		instance.rows[index] = row
	end

	instance.previousButton = instance:CreateButton(frame, "Previous", 82, -132, function()
		instance:SetPage(instance.page - 1)
	end)
	instance.nextButton = instance:CreateButton(frame, "Next", 82, -42, function()
		instance:SetPage(instance.page + 1)
	end)
	instance.pageText = CreateFontString(frame, 10, "", { 0.75, 0.75, 0.75, 1 })
	instance.pageText:SetPoint("BOTTOM", frame, "BOTTOM", 52, 17)
	instance.backButton = instance:CreateButton(frame, "Back", 82, 132, function()
		return instance.onBack(instance)
	end)
	return instance
end

function Options:GetPageCount()
	return math.ceil(#DEFINITIONS / PAGE_SIZE)
end

function Options:SetPage(page)
	self.page = Clamp(math.floor(page or 1), 1, self:GetPageCount())
	self:Refresh()
	return self.page
end

function Options:Refresh()
	local first = ((self.page - 1) * PAGE_SIZE) + 1
	for rowIndex, row in ipairs(self.rows) do
		local definition = DEFINITIONS[first + rowIndex - 1]
		row.definition = definition
		if definition then
			row.label:SetText(definition.label)
			row.value:SetText(self:GetValueText(definition))
			row:Show()
		else
			row:Hide()
		end
	end
	local pageCount = self:GetPageCount()
	self.pageText:SetText(string.format("Page %d / %d", self.page, pageCount))
	if self.page > 1 then
		self.previousButton:Show()
	else
		self.previousButton:Hide()
	end
	if self.page < pageCount then
		self.nextButton:Show()
	else
		self.nextButton:Hide()
	end
	return self:GetSettingRecords()
end

function Options:Show()
	self.page = 1
	self:Refresh()
	self.frame:Show()
	self.visible = true
	return self
end

function Options:Hide()
	self.frame:Hide()
	self.visible = false
	return self
end

function Options:IsShown()
	return self.visible
end

Options.PAGE_SIZE = PAGE_SIZE

addon.Options = Options
