local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Fonts = assert(addon.Fonts, "Fonts module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local Summary = {}
Summary.__index = Summary

local function CopyResult(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = value
	end
	if type(copy.personalBest) == "table" then
		local personalBest = {}
		for key, value in pairs(copy.personalBest) do
			personalBest[key] = value
		end
		copy.personalBest = personalBest
	end
	return copy
end

local function FormatInteger(value)
	local text = tostring(math.floor(value or 0))
	local formatted = text
	while true do
		local nextText, substitutions = string.gsub(formatted, "^(%-?%d+)(%d%d%d)", "%1,%2")
		formatted = nextText
		if substitutions == 0 then
			return formatted
		end
	end
end

local function FormatDuration(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%d min %d sec", math.floor(seconds / 60), seconds % 60)
end

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	Fonts:Set(fontString, size, "OUTLINE")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

local function ValidateCallback(callback, name)
	assert(type(callback) == "function", name .. " must be a function")
	return callback
end

function Summary:CreateFrame(parent, preset, width, height, levelOffset, frameType)
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

function Summary:CreateMetric(parent, key, label, x, y)
	local caption = CreateFontString(parent, 11, label, { 1, 0.78, 0.1, 1 })
	caption:SetPoint("TOP", parent, "TOP", x, y)
	local value = CreateFontString(parent, 19, "0", { 1, 1, 1, 1 })
	value:SetPoint("TOP", caption, "BOTTOM", 0, -4)
	self.metrics[key] = {
		caption = caption,
		value = value,
	}
	return self.metrics[key]
end

function Summary:CreateButton(parent, text, x, callback)
	local button = self:CreateFrame(parent, "tooltip", 160, 30, 2, "Button")
	button:SetPoint("BOTTOM", parent, "BOTTOM", x, 12)
	button:EnableMouse(true)
	button.label = CreateFontString(button, 13, text, { 1, 0.85, 0, 1 })
	button.label:SetPoint("CENTER", button, "CENTER", 0, 1)
	button:SetScript("OnClick", function()
		return callback()
	end)
	button:SetScript("OnEnter", function(frame)
		frame:SetBackdropColor(0.25, 0.18, 0.04, 1)
	end)
	button:SetScript("OnLeave", function(frame)
		frame:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
	end)
	return button
end

function Summary:New(parent, options)
	assert(parent ~= nil, "summary parent is required")
	options = options or {}
	assert(type(options) == "table", "summary options must be a table")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		onNewGame = ValidateCallback(options.onNewGame, "onNewGame"),
		onMenu = ValidateCallback(options.onMenu, "onMenu"),
		metrics = {},
		result = nil,
		visible = false,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for summary")

	local frame = instance:CreateFrame(parent, "panel", 400, 400, 20)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	frame:EnableMouse(true)
	frame:Hide()
	frame.title = CreateFontString(frame, 22, "Game Over!", { 1, 0.85, 0.1, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -14)
	frame.mode = CreateFontString(frame, 12, "", { 0.75, 0.75, 0.75, 1 })
	frame.mode:SetPoint("TOP", frame.title, "BOTTOM", 0, -3)
	instance.frame = frame

	instance:CreateMetric(frame, "primary", "Final Score", 0, -72)
	instance:CreateMetric(frame, "time", "Time", -92, -142)
	instance:CreateMetric(frame, "level", "Level", 92, -142)
	instance:CreateMetric(frame, "cascade", "Largest Cascade", -92, -207)
	instance:CreateMetric(frame, "combo", "Largest Combo", 92, -207)
	instance:CreateMetric(frame, "moves", "Moves", -92, -272)
	instance:CreateMetric(frame, "best", "Personal Best", 92, -272)

	instance.newGameButton = instance:CreateButton(frame, "New Game", -88, function()
		return instance.onNewGame(instance:GetResult(), instance)
	end)
	instance.menuButton = instance:CreateButton(frame, "Menu", 88, function()
		return instance.onMenu(instance:GetResult(), instance)
	end)
	return instance
end

function Summary:GetResult()
	return self.result and CopyResult(self.result) or nil
end

function Summary:Show(result)
	assert(type(result) == "table", "summary result must be a table")
	self.result = CopyResult(result)
	local timed = result.metricName == "points-per-second"
	local metric = result.metric or result.score or 0
	local best = type(result.personalBest) == "table" and result.personalBest.best or nil
	self.frame.mode:SetText(result.gameMode == Constants.GAME_MODE_TIMED and "Timed Mode" or "Classic Mode")
	self.metrics.primary.caption:SetText(timed and "Points per Second" or "Final Score")
	self.metrics.primary.value:SetText(timed and string.format("%.2f", metric) or FormatInteger(metric))
	self.metrics.time.value:SetText(FormatDuration(result.elapsed))
	self.metrics.level.value:SetText(tostring(result.level or 1))
	self.metrics.cascade.value:SetText(tostring(result.largestCascade or 0))
	self.metrics.combo.value:SetText(tostring(result.largestCombo or 0))
	self.metrics.moves.value:SetText(tostring(result.moves or 0))
	self.metrics.best.value:SetText(best == nil and "-" or (timed and string.format("%.2f", best) or FormatInteger(best)))
	self.frame:Show()
	self.visible = true
	return self:GetResult()
end

function Summary:Hide()
	self.frame:Hide()
	self.visible = false
	return self
end

function Summary:IsShown()
	return self.visible
end

addon.Summary = Summary
