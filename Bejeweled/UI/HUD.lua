local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local HUD = {}
HUD.__index = HUD

local DEFAULT_WIDTH = Constants.GRID_WIDTH * Constants.GEM_WIDTH
local DEFAULT_STATUS_DURATION = 2.5
local DEFAULT_ACHIEVEMENT_DURATION = 4
local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"

local SESSION_CALLBACKS = {
	onPauseChanged = "OnPauseChanged",
	onRestored = "OnRestored",
	onLevelTransitionStarted = "OnLevelTransitionStarted",
	onLevelTransitionComplete = "OnLevelTransitionComplete",
	onGameOverStarted = "OnGameOverStarted",
	onGameOverComplete = "OnGameOverComplete",
}

local INPUT_CALLBACKS = {
	onSelectionChanged = "OnSelectionChanged",
	onMoveStarted = "OnMoveStarted",
	onCascadeResolved = "OnCascadeResolved",
	onMoveComplete = "OnMoveComplete",
}

local function CopyTable(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = value
	end
	return copy
end

local function Clamp(value, minimum, maximum)
	if value < minimum then
		return minimum
	elseif value > maximum then
		return maximum
	end
	return value
end

local function FormatInteger(value)
	local text = tostring(math.floor(value or 0))
	local sign = ""
	if string.sub(text, 1, 1) == "-" then
		sign = "-"
		text = string.sub(text, 2)
	end
	local formatted = text
	while true do
		local nextText, substitutions = string.gsub(formatted, "^(%d+)(%d%d%d)", "%1,%2")
		formatted = nextText
		if substitutions == 0 then
			break
		end
	end
	return sign .. formatted
end

local function FormatDuration(seconds)
	seconds = math.max(0, math.ceil(seconds or 0))
	local minutes = math.floor(seconds / 60)
	local remainder = seconds - minutes * 60
	return string.format("%d:%02d", minutes, remainder)
end

local function FormatMultiplier(multiplier)
	multiplier = multiplier or 1
	if multiplier == math.floor(multiplier) then
		return string.format("%dx", multiplier)
	end
	return string.format("%.1fx", multiplier)
end

local function SetFrameSize(frame, width, height)
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function SetTextureSize(texture, width, height)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

local function ResolveFrameLevel(parent, offset)
	if parent and type(parent.GetFrameLevel) == "function" then
		return parent:GetFrameLevel() + offset
	end
	return nil
end

local function CreateFontString(frame, size, text, color, justify)
	assert(type(frame.CreateFontString) == "function", "HUD frame cannot create font strings")
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled HUD font could not be loaded")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	if justify and type(fontString.SetJustifyH) == "function" then
		fontString:SetJustifyH(justify)
	end
	return fontString
end

local function ChainCallback(target, callbackName, callback)
	local existing = target[callbackName]
	assert(existing == nil or type(existing) == "function", callbackName .. " must be a function")
	target[callbackName] = function(result, owner)
		callback(result, owner)
		if existing then
			return existing(result, owner)
		end
	end
end

function HUD:CreateBackdropFrame(parent, preset, width, height, levelOffset)
	local frame = Backdrops:CreateFrame({
		parent = parent,
		preset = preset,
		createFrame = self.createFrame,
		backgroundColor = { 0.05, 0.05, 0.05, 0.9 },
	})
	SetFrameSize(frame, width, height)
	local frameLevel = ResolveFrameLevel(parent, levelOffset or 1)
	if frameLevel then
		frame:SetFrameLevel(frameLevel)
	end
	return frame
end

function HUD:CreateStatusBar()
	local statusBar = self:CreateBackdropFrame(self.parent, "slider", self.width, 32, 2)
	statusBar:SetPoint("TOPLEFT", self.parent, "BOTTOMLEFT", 0, 0)

	local levelPanel = self:CreateBackdropFrame(statusBar, "level", 90, 32, 1)
	levelPanel:SetPoint("LEFT", statusBar, "LEFT", 0, 0)
	levelPanel.caption = CreateFontString(levelPanel, 10, "LVL", { 0.07, 0.67, 1, 1 }, "LEFT")
	levelPanel.caption:SetPoint("LEFT", levelPanel, "LEFT", 8, 1)
	levelPanel.value = CreateFontString(levelPanel, 15, "1", { 1, 1, 1, 1 }, "RIGHT")
	levelPanel.value:SetPoint("RIGHT", levelPanel, "RIGHT", -8, 1)

	local dataPanel = self:CreateBackdropFrame(statusBar, "level", 110, 32, 1)
	dataPanel:SetPoint("LEFT", levelPanel, "RIGHT", -4, 0)
	dataPanel.value = CreateFontString(dataPanel, 12, "0", { 1, 1, 1, 1 }, "CENTER")
	dataPanel.value:SetPoint("CENTER", dataPanel, "CENTER", 0, 1)

	local progressWidth = self.width - 90 - 110 + 8
	local progress = self:CreateBackdropFrame(statusBar, "slider", progressWidth, 32, 1)
	progress:SetPoint("LEFT", dataPanel, "RIGHT", -4, 0)
	progress:SetPoint("RIGHT", statusBar, "RIGHT", 0, 0)
	progress.fillWidth = progressWidth - 4
	progress.fill = progress:CreateTexture(nil, "ARTWORK")
	progress.fill:SetTexture(Constants.IMAGE_ROOT .. "barArt")
	progress.fill:SetPoint("LEFT", progress, "LEFT", 2, -2)
	SetTextureSize(progress.fill, 0.01, 22)
	progress.text = CreateFontString(progress, 12, "", { 1, 1, 1, 1 }, "CENTER")
	progress.text:SetPoint("CENTER", progress, "CENTER", 0, 1)

	self.statusBar = statusBar
	self.levelPanel = levelPanel
	self.dataPanel = dataPanel
	self.progress = progress
end

function HUD:CreateOverlay(width, height, yOffset, fontSize, color)
	local frame = self:CreateBackdropFrame(self.parent, "panel", width, height, 8)
	frame:SetPoint("CENTER", self.parent, "CENTER", 0, yOffset or 0)
	frame.text = CreateFontString(frame, fontSize, "", color, "CENTER")
	frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.text:SetWidth(width - 20)
	frame.text:SetHeight(height - 12)
	frame:Hide()
	return frame
end

function HUD:New(parent, animations, options)
	assert(parent ~= nil, "HUD parent is required")
	assert(
		type(animations) == "table"
			and type(animations.ShowHint) == "function"
			and type(animations.HideHint) == "function"
			and type(animations.PlayFloatingText) == "function",
		"HUD requires animation presentation services"
	)
	options = options or {}
	assert(type(options) == "table", "HUD options must be a table")
	local instance = setmetatable({
		parent = parent,
		animations = animations,
		createFrame = options.createFrame or CreateFrame,
		width = options.width or DEFAULT_WIDTH,
		statusDuration = options.statusDuration or DEFAULT_STATUS_DURATION,
		achievementDuration = options.achievementDuration or DEFAULT_ACHIEVEMENT_DURATION,
		hintsEnabled = options.hintsEnabled,
		statusRemaining = nil,
		achievementRemaining = nil,
		statusVisible = false,
		presentedSkillEvents = {},
		session = nil,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for HUD")
	assert(type(instance.width) == "number" and instance.width >= 300, "HUD width must be at least 300")
	assert(type(instance.statusDuration) == "number" and instance.statusDuration > 0, "HUD status duration must be positive")
	assert(type(instance.achievementDuration) == "number" and instance.achievementDuration > 0, "HUD achievement duration must be positive")
	assert(
		instance.hintsEnabled == nil
			or type(instance.hintsEnabled) == "boolean"
			or type(instance.hintsEnabled) == "function",
		"HUD hint setting must be Boolean or a provider"
	)

	instance:CreateStatusBar()
	instance.statusFrame = instance:CreateOverlay(instance.width - 40, 72, 25, 28, { 1, 0.85, 0, 1 })
	instance.achievementFrame = instance:CreateOverlay(instance.width - 30, 46, 100, 16, { 1, 0.85, 0, 1 })
	instance.pausedFrame = instance:CreateOverlay(instance.width - 80, 90, 20, 40, { 1, 0.85, 0, 1 })
	instance.pausedFrame.text:SetText("Paused")
	instance.summaryFrame = instance:CreateOverlay(instance.width - 40, 245, 10, 16, { 1, 1, 1, 1 })
	return instance
end

function HUD:AreHintsEnabled()
	if type(self.hintsEnabled) == "function" then
		return self.hintsEnabled() and true or false
	end
	return self.hintsEnabled ~= false
end

function HUD:SetProgress(ratio, red, green, blue)
	ratio = Clamp(ratio or 0, 0, 1)
	self.progress.fill:SetWidth(math.max(0.01, self.progress.fillWidth * ratio))
	self.progress.fill:SetVertexColor(red, green, blue, 1)
	self.progress.ratio = ratio
end

function HUD:Refresh(session)
	session = session or self.session
	if not session then
		return false
	end
	local state = session.scoringState
	if session.gameMode == Constants.GAME_MODE_CLASSIC then
		self.levelPanel.caption:SetText("LVL")
		self.levelPanel.caption:SetTextColor(0.07, 0.67, 1, 1)
		self.levelPanel.value:SetText(tostring(state.level))
		self.dataPanel.value:SetText(FormatInteger(state.score))
		self.progress.text:SetText("")
		local ratio = state.pointsToLevelUp > 0 and state.score / state.pointsToLevelUp or 0
		if state.levelPending then
			ratio = 1
		end
		self:SetProgress(ratio, 0, 0.5, 1)
	else
		self.levelPanel.caption:SetText("PPS")
		self.levelPanel.caption:SetTextColor(0, 1, 0, 1)
		local pps = session.timerElapsed > 0 and state.score / session.timerElapsed or 0
		self.levelPanel.value:SetText(string.format("%.2f", pps))
		self.dataPanel.value:SetText(FormatMultiplier(state.pointMultiplier))
		if session.timeLimit then
			local remaining = math.max(0, session.timeLimit - session.timerElapsed)
			self.progress.text:SetText(FormatDuration(remaining))
			self:SetProgress(remaining / session.timeLimit, 0, 1, 0)
		else
			self.progress.text:SetText("Timing")
			self:SetProgress(1, 0, 1, 0)
		end
	end
	return true
end

function HUD:ShowStatus(text, duration, color)
	assert(type(text) == "string" and text ~= "", "HUD status text is required")
	self.statusFrame.text:SetText(text)
	if color then
		self.statusFrame.text:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	else
		self.statusFrame.text:SetTextColor(1, 0.85, 0, 1)
	end
	self.statusRemaining = duration
	self.statusVisible = true
	self.statusFrame:Show()
	return text
end

function HUD:HideStatus()
	local shown = self.statusVisible
	self.statusRemaining = nil
	self.statusVisible = false
	self.statusFrame:Hide()
	return shown and true or false
end

function HUD:ShowAchievement(text, duration)
	assert(type(text) == "string" and text ~= "", "HUD achievement text is required")
	self.achievementFrame.text:SetText(text)
	self.achievementRemaining = duration or self.achievementDuration
	self.achievementFrame:Show()
	return text
end

function HUD:DescribeSkillEvent(event)
	if type(event) ~= "table" or (event.gained or 0) <= 0 then
		return nil
	end
	if event.rankUp then
		return "Rank up: " .. tostring(event.rankAfter)
	elseif event.completed and event.type == Constants.SKILL_TYPE_ACHIEVEMENT then
		return "Achievement unlocked #" .. tostring(event.index)
	elseif event.completed and event.type == Constants.SKILL_TYPE_FUN then
		return "Feat unlocked #" .. tostring(event.index)
	end
	return "Skill +" .. tostring(event.gained)
end

function HUD:PresentSkillEvents(events)
	local presented = 0
	for index = 1, #(events or {}) do
		local event = events[index]
		local message = self:DescribeSkillEvent(event)
		local eventKey = message and table.concat({
			tostring(event.type),
			tostring(event.index),
			tostring(event.pointsAfter),
			tostring(event.gained),
			tostring(event.completed),
		}, ":") or nil
		if message and not self.presentedSkillEvents[eventKey] then
			self.presentedSkillEvents[eventKey] = true
			presented = presented + 1
			self:ShowAchievement(message)
			self.animations:PlayFloatingText(105, 250, message, Constants.HYPER_CONTENTS, true)
		end
	end
	return presented
end

function HUD:ScheduleHint()
	local session = self.session
	self.animations:HideHint()
	if not session
		or not session.active
		or session.paused
		or session:IsLocked()
		or not self:AreHintsEnabled() then
		return false
	end
	local first = session.grid:FindLegalMove()
	if not first then
		return false
	end
	self.animations:ShowHint(first.gridX, first.gridY)
	return true
end

function HUD:ShowSummary(result)
	assert(type(result) == "table", "HUD summary requires a game-over result")
	local metricLabel = result.metricName == "points-per-second" and "Points/sec" or "Score"
	local metric = result.metricName == "points-per-second"
		and string.format("%.2f", result.metric or 0)
		or FormatInteger(result.metric or result.score)
	local best = result.personalBest and result.personalBest.best
	local lines = {
		"Game Over",
		metricLabel .. ": " .. metric,
		"Time: " .. FormatDuration(result.elapsed),
		"Level: " .. tostring(result.level),
		"Largest cascade: " .. tostring(result.largestCascade),
		"Largest combo: " .. tostring(result.largestCombo),
		"Moves: " .. tostring(result.moves),
	}
	if best ~= nil then
		lines[#lines + 1] = "Personal best: " .. (result.metricName == "points-per-second"
			and string.format("%.2f", best)
			or FormatInteger(best))
	end
	self.summaryFrame.text:SetText(table.concat(lines, "\n"))
	self.summaryFrame:Show()
	return lines
end

function HUD:OnPauseChanged(result, session)
	self.session = session or self.session
	if result.status == "paused" then
		self.pausedFrame:Show()
		self.animations:HideHint()
	else
		self.pausedFrame:Hide()
		self:ScheduleHint()
	end
	self:Refresh()
end

function HUD:OnRestored(result, session)
	self.session = session or self.session
	self.summaryFrame:Hide()
	self:Refresh()
	self:ScheduleHint()
end

function HUD:OnSelectionChanged(result)
	self.animations:HideHint()
	if result.status == "cleared" and result.reason ~= "swap" then
		self:ScheduleHint()
	end
end

function HUD:OnMoveStarted(result)
	self.animations:HideHint()
	self:PresentSkillEvents(result.moveResult and result.moveResult.skillEvents)
end

function HUD:OnCascadeResolved(result)
	local scoring = result.scoringResult
	if scoring then
		if scoring.points > 0 then
			local firstEvent = scoring.scoreEvents[1]
			local contents = firstEvent and firstEvent.contents or Constants.HYPER_CONTENTS
			self.animations:PlayFloatingText(175, 200, "+" .. tostring(scoring.points), contents, false)
		end
		self:PresentSkillEvents(scoring.skillEvents)
	end
	self:Refresh()
end

function HUD:OnMoveComplete(result)
	self:Refresh()
	if result.status == "complete" then
		self:ScheduleHint()
	end
end

function HUD:OnLevelTransitionStarted(result, session)
	self.session = session or self.session
	self.animations:HideHint()
	self:ShowStatus(result.kind == "level-up" and "Level up" or "Multiplier up", self.statusDuration)
	self:PresentSkillEvents(result.skillEvents)
	self:Refresh()
end

function HUD:OnLevelTransitionComplete(result, session)
	self.session = session or self.session
	self:ShowStatus(result.kind == "level-up" and "Level " .. tostring(result.level)
		or "Multiplier " .. FormatMultiplier(result.pointMultiplier), self.statusDuration)
	self:PresentSkillEvents(result.skillEvents)
	self:Refresh()
	self:ScheduleHint()
end

function HUD:OnGameOverStarted(result, session)
	self.session = session or self.session
	self.animations:HideHint()
	self:ShowStatus(result.kind == "no-more-moves" and "No More Moves" or "Time Up", nil, { 1, 0.2, 0.2, 1 })
	self:PresentSkillEvents(result.skillEvents)
	self:Refresh()
end

function HUD:OnGameOverComplete(result, session)
	self.session = session or self.session
	self:HideStatus()
	self:PresentSkillEvents(result.skillEvents)
	self:ShowSummary(result)
	self:Refresh()
end

function HUD:CreateSessionOptions(options)
	local prepared = CopyTable(options)
	prepared.inputOptions = CopyTable(options and options.inputOptions)
	for callbackName, methodName in pairs(SESSION_CALLBACKS) do
		ChainCallback(prepared, callbackName, function(result, session)
			self[methodName](self, result, session)
		end)
	end
	for callbackName, methodName in pairs(INPUT_CALLBACKS) do
		ChainCallback(prepared.inputOptions, callbackName, function(result, input)
			self[methodName](self, result, input)
		end)
	end
	return prepared
end

function HUD:AttachSession(session)
	assert(
		type(session) == "table"
			and type(session.AdvanceElapsed) == "function"
			and type(session.GetInput) == "function",
		"HUD requires a session"
	)
	self.session = session
	self.summaryFrame:Hide()
	if session:IsPaused() then
		self.pausedFrame:Show()
	else
		self.pausedFrame:Hide()
	end
	self:Refresh(session)
	self:ScheduleHint()
	return session
end

function HUD:CreateSession(grid, gemPool, options)
	local Session = assert(addon.Session, "Session module is not loaded")
	local session = Session:New(grid, gemPool, self.animations, self:CreateSessionOptions(options))
	return self:AttachSession(session)
end

function HUD:Update(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "HUD elapsed time must be nonnegative")
	self:Refresh()
	if self.statusRemaining then
		self.statusRemaining = self.statusRemaining - elapsed
		if self.statusRemaining <= 0 then
			self:HideStatus()
		end
	end
	if self.achievementRemaining then
		self.achievementRemaining = self.achievementRemaining - elapsed
		if self.achievementRemaining <= 0 then
			self.achievementRemaining = nil
			self.achievementFrame:Hide()
		end
	end
	return self.session ~= nil
end

addon.HUD = HUD
