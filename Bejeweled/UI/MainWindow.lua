local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Fonts = assert(addon.Fonts, "Fonts module is not loaded")
local SavedVariables = assert(addon.SavedVariables, "SavedVariables module is not loaded")
local Grid = assert(addon.Grid, "Grid module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")
local GemPool = assert(addon.GemPool, "GemPool module is not loaded")
local Animations = assert(addon.Animations, "Animations module is not loaded")
local HUD = assert(addon.HUD, "HUD module is not loaded")
local Summary = assert(addon.Summary, "Summary module is not loaded")
local Skills = assert(addon.Skills, "Skills module is not loaded")
local Options = assert(addon.Options, "Options module is not loaded")
local About = assert(addon.About, "About module is not loaded")
local Legal = assert(addon.Legal, "Legal module is not loaded")

local MainWindow = {}
MainWindow.__index = MainWindow

local WINDOW_WIDTH = 448
local WINDOW_HEIGHT = 510
local BOARD_BORDER_WIDTH = 414
local BOARD_BORDER_HEIGHT = 412
local BOARD_WIDTH = Constants.GRID_WIDTH * Constants.GEM_WIDTH
local BOARD_HEIGHT = Constants.GRID_HEIGHT * Constants.GEM_HEIGHT
local DEFAULT_TIMED_DURATION = 5 * 60
local MIN_TIMED_MINUTES = 2
local MAX_TIMED_MINUTES = 10
local function SetFrameSize(frame, width, height)
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function SetTextureSize(texture, width, height)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	Fonts:Set(fontString, size, "OUTLINE")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

local function ValidateCallback(callback, name)
	assert(callback == nil or type(callback) == "function", name .. " must be a function")
	return callback
end

local function CopyTable(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

local function FormatDuration(seconds)
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d min %d sec", math.floor(seconds / 60), seconds % 60)
end

function MainWindow:CreateBackdropFrame(parent, preset, width, height, levelOffset, frameType)
	local frame = Backdrops:CreateFrame({
		frameType = frameType,
		parent = parent,
		preset = preset,
		createFrame = self.createFrame,
		backgroundColor = { 0.08, 0.08, 0.08, 0.96 },
		borderColor = { 1, 0.8, 0.45, 1 },
	})
	SetFrameSize(frame, width, height)
	if parent and type(parent.GetFrameLevel) == "function" then
		frame:SetFrameLevel(parent:GetFrameLevel() + (levelOffset or 1))
	end
	return frame
end

function MainWindow:CreateButton(parent, text, width, height, onClick)
	assert(type(onClick) == "function", "window button requires a click callback")
	local button = self:CreateBackdropFrame(parent, "tooltip", width, height, 2, "Button")
	button:EnableMouse(true)
	button.label = CreateFontString(button, 13, text, { 1, 0.85, 0, 1 })
	button.label:SetPoint("CENTER", button, "CENTER", 0, 1)
	button:SetScript("OnClick", function()
		onClick()
	end)
	button:SetScript("OnEnter", function(frame)
		frame:SetBackdropColor(0.25, 0.18, 0.04, 1)
	end)
	button:SetScript("OnLeave", function(frame)
		frame:SetBackdropColor(0.08, 0.08, 0.08, 0.96)
	end)
	return button
end

function MainWindow:CreateWindowFrame()
	local frame = self:CreateBackdropFrame(self.uiParent, "window", WINDOW_WIDTH, WINDOW_HEIGHT, 5)
	frame:SetPoint("CENTER", self.uiParent, "CENTER", 0, 0)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	if type(frame.SetClampedToScreen) == "function" then
		frame:SetClampedToScreen(true)
	end
	frame:SetAlpha(self.profile.settings.gameAlpha or 1)
	frame:SetScript("OnDragStart", function(window)
		if not self.profile.settings.lockWindow then
			window:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(window)
		window:StopMovingOrSizing()
	end)
	frame:SetScript("OnShow", function()
		if not self.suppressWindowScript then
			self:HandleWindowShown()
		end
	end)
	frame:SetScript("OnHide", function()
		if not self.suppressWindowScript then
			self:HandleWindowHidden()
		end
	end)
	frame:SetScript("OnUpdate", function(_, elapsed)
		self:Update(elapsed)
	end)
	frame:Hide()

	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	frame.icon:SetTexture(Constants.IMAGE_ROOT .. "windowIcon")
	frame.icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, 4)
	SetTextureSize(frame.icon, 58, 58)
	frame.title = CreateFontString(frame, 24, "Bejeweled", { 1, 0.85, 0, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -18)

	frame.closeButton = self:CreateButton(frame, "X", 28, 26, function()
		self:Hide()
	end)
	frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
	frame.menuButton = self:CreateButton(frame, "Menu", 56, 26, function()
		if self.activeOverlay and self.activeOverlay ~= "summary" then
			self:ResumeGame()
		else
			self:ShowMenu()
		end
	end)
	frame.menuButton:SetPoint("TOPRIGHT", frame.closeButton, "TOPLEFT", -4, 0)
	self.frame = frame
end

function MainWindow:CreateBoard()
	local boardFrame = self:CreateBackdropFrame(self.frame, "panel", BOARD_BORDER_WIDTH, BOARD_BORDER_HEIGHT, 2)
	boardFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 17, -60)
	boardFrame:SetBackdropColor(0, 0, 0, 0)
	local surface = self.createFrame("Frame", nil, boardFrame)
	SetFrameSize(surface, BOARD_WIDTH, BOARD_HEIGHT)
	surface:SetPoint("TOPLEFT", boardFrame, "TOPLEFT", 7, -4)
	if boardFrame and type(boardFrame.GetFrameLevel) == "function" then
		surface:SetFrameLevel(boardFrame:GetFrameLevel() + 1)
	end
	surface:EnableMouse(true)
	surface:Show()

	self.boardFrame = boardFrame
	self.boardSurface = surface
	self.gemPool = GemPool:New(surface, {
		createFrame = self.createFrame,
	})
	self.gemPool:Project(self.grid, true)
	self.animations = Animations:New(self.gemPool, {
		createFrame = self.createFrame,
		random = self.random,
	})
	self.hud = HUD:New(surface, self.animations, {
		createFrame = self.createFrame,
		width = BOARD_WIDTH,
		hintsEnabled = self.hintsEnabled,
		profile = self.profile,
		chatMessage = self.chatMessage,
		skillLabel = function(event)
			return Skills:GetSkillLabel(event.type, event.index)
		end,
		skillDescription = function(event)
			return Skills:GetSkillDescription(event.type, event.index)
		end,
	})
	self.summary = Summary:New(surface, {
		createFrame = self.createFrame,
		onNewGame = function()
			return self:ShowModeMenu()
		end,
		onMenu = function()
			return self:ShowMenu()
		end,
	})
	self.skills = Skills:New(surface, {
		createFrame = self.createFrame,
		profile = self.profile,
		accountData = self.accountData,
		onBack = function()
			return self:ShowMenu()
		end,
	})
	self.options = Options:New(surface, {
		createFrame = self.createFrame,
		profile = self.profile,
		onChanged = function(key)
			return self:ApplySettings(key)
		end,
		onBack = function()
			return self:ShowMenu()
		end,
	})
	self.about = About:New(surface, {
		createFrame = self.createFrame,
		onBack = function()
			return self:ShowMenu()
		end,
	})
	self.legal = Legal:New(surface, {
		createFrame = self.createFrame,
		accountData = self.accountData,
		onAcknowledge = function()
			return self:ShowMenu()
		end,
	})
end

function MainWindow:CreateOverlay(title, height)
	local overlay = self:CreateBackdropFrame(self.frame, "panel", 190, height, 35)
	overlay:SetPoint("CENTER", self.frame, "CENTER", 0, 8)
	overlay.title = CreateFontString(overlay, 17, title, { 1, 1, 1, 1 })
	overlay.title:SetPoint("TOP", overlay, "TOP", 0, -10)
	overlay:Hide()
	return overlay
end

function MainWindow:CreateMenus()
	local menu = self:CreateOverlay("Menu", 272)
	menu.resume = self:CreateButton(menu, "Resume", 160, 28, function()
		self:ResumeGame()
	end)
	menu.resume:SetPoint("TOP", menu, "TOP", 0, -36)
	menu.newGame = self:CreateButton(menu, "New Game", 160, 28, function()
		self:ShowModeMenu()
	end)
	menu.newGame:SetPoint("TOP", menu.resume, "BOTTOM", 0, -8)
	menu.skills = self:CreateButton(menu, "Feats of Skill", 160, 28, function()
		self:ShowSkills()
	end)
	menu.skills:SetPoint("TOP", menu.newGame, "BOTTOM", 0, -8)
	menu.settings = self:CreateButton(menu, "Settings", 160, 28, function()
		self:ShowOptions()
	end)
	menu.settings:SetPoint("TOP", menu.skills, "BOTTOM", 0, -8)
	menu.about = self:CreateButton(menu, "About", 160, 28, function()
		self:ShowAbout()
	end)
	menu.about:SetPoint("TOP", menu.settings, "BOTTOM", 0, -8)
	menu.legal = self:CreateButton(menu, "Legal Notice", 160, 28, function()
		self:ShowLegal()
	end)
	menu.legal:SetPoint("TOP", menu.about, "BOTTOM", 0, -8)

	local mode = self:CreateOverlay("Game Type", 164)
	mode.classic = self:CreateButton(mode, "Classic", 160, 28, function()
		self:ChooseClassic()
	end)
	mode.classic:SetPoint("TOP", mode, "TOP", 0, -36)
	mode.timed = self:CreateButton(mode, "Timed", 160, 28, function()
		self:ShowTimedMenu()
	end)
	mode.timed:SetPoint("TOP", mode.classic, "BOTTOM", 0, -8)
	mode.back = self:CreateButton(mode, "Back", 160, 28, function()
		self:ShowMenu()
	end)
	mode.back:SetPoint("TOP", mode.timed, "BOTTOM", 0, -8)

	local classic = self:CreateOverlay("Classic Mode", 164)
	classic.continue = self:CreateButton(classic, "Continue", 160, 28, function()
		self:StartClassic(true)
	end)
	classic.continue:SetPoint("TOP", classic, "TOP", 0, -36)
	classic.newGame = self:CreateButton(classic, "New Game", 160, 28, function()
		self:StartClassic(false)
	end)
	classic.newGame:SetPoint("TOP", classic.continue, "BOTTOM", 0, -8)
	classic.back = self:CreateButton(classic, "Back", 160, 28, function()
		self:ShowModeMenu()
	end)
	classic.back:SetPoint("TOP", classic.newGame, "BOTTOM", 0, -8)

	local timed = self:CreateOverlay("Timed Mode", 242)
	timed.timeCaption = CreateFontString(timed, 11, "Time", { 1, 1, 1, 1 })
	timed.timeCaption:SetPoint("TOP", timed, "TOP", 0, -36)
	timed.durationValue = CreateFontString(timed, 13, string.format("%d Minutes", self.timedMinutes), { 1, 0.85, 0, 1 })
	timed.durationValue:SetPoint("TOP", timed.timeCaption, "BOTTOM", 0, -6)
	timed.slider = self:CreateBackdropFrame(timed, "slider", 148, 18, 2, "Slider")
	timed.slider:SetPoint("TOP", timed.durationValue, "BOTTOM", 0, -10)
	timed.slider:SetMinMaxValues(MIN_TIMED_MINUTES, MAX_TIMED_MINUTES)
	timed.slider:SetValueStep(1)
	timed.slider:SetObeyStepOnDrag(true)
	timed.slider:SetOrientation("HORIZONTAL")
	timed.slider:SetThumbTexture(Constants.IMAGE_ROOT .. "selector")
	local thumb = timed.slider:GetThumbTexture()
	SetTextureSize(thumb, 18, 18)
	timed.slider:SetScript("OnValueChanged", function(_, value)
		self:SetTimedMinutes(value)
	end)
	timed.slider:SetValue(self.timedMinutes)

	timed.flightToggle = self:CreateButton(timed, "[ ] Use flight path time", 160, 28, function()
		self:SetFlightOptionSelected(not self.flightOptionSelected)
	end)
	Fonts:Set(timed.flightToggle.label, 11, "OUTLINE")
	timed.flightToggle:SetPoint("TOP", timed.slider, "BOTTOM", 0, -10)
	timed.flightStatus = CreateFontString(timed, 10, "", { 1, 1, 1, 1 })
	timed.flightStatus:SetPoint("TOP", timed.flightToggle, "BOTTOM", 0, -6)
	timed.flightWarning = CreateFontString(timed, 10, "Flight time is too short\nfor a timed game.", { 1, 0.6, 0.13, 1 })
	timed.flightWarning:SetPoint("TOP", timed.slider, "BOTTOM", 0, -15)

	timed.go = self:CreateButton(timed, "Go!", 160, 28, function()
		self:StartTimedSelection()
	end)
	timed.go:SetPoint("BOTTOM", timed, "BOTTOM", 0, 42)
	timed.back = self:CreateButton(timed, "Back", 160, 28, function()
		self:ShowModeMenu()
	end)
	timed.back:SetPoint("TOP", timed.go, "BOTTOM", 0, -6)

	self.overlays = {
		menu = menu,
		mode = mode,
		classic = classic,
		timed = timed,
	}
end

function MainWindow:New(uiParent, options)
	assert(uiParent ~= nil, "main window requires UIParent")
	options = options or {}
	assert(type(options) == "table", "main-window options must be a table")
	assert(type(options.profile) == "table", "main window requires a profile")
	assert(type(options.accountData) == "table", "main window requires account data")
	assert(
		type(options.audio) == "table"
			and type(options.audio.Play) == "function"
			and type(options.audio.Update) == "function",
		"main window requires audio"
	)
	assert(type(options.playerName) == "string" or type(options.playerName) == "function", "main window requires a player name")
	local instance = setmetatable({
		uiParent = uiParent,
		createFrame = options.createFrame or CreateFrame,
		profile = options.profile,
		accountData = options.accountData,
		audio = options.audio,
		playerName = options.playerName,
		random = options.random or math.random,
		chatMessage = options.chatMessage,
		timedDuration = options.timedDuration or DEFAULT_TIMED_DURATION,
		hintsEnabled = options.hintsEnabled,
		onSessionStarted = ValidateCallback(options.onSessionStarted, "onSessionStarted"),
		onSessionStopped = ValidateCallback(options.onSessionStopped, "onSessionStopped"),
		flightOptionProvider = ValidateCallback(options.flightOptionProvider, "flightOptionProvider"),
		onFlightTimedRequested = ValidateCallback(options.onFlightTimedRequested, "onFlightTimedRequested"),
		grid = options.grid or Grid:New(options.random),
		session = nil,
		activeOverlay = nil,
		menuOwnsPause = false,
		windowOwnsPause = false,
		suppressWindowScript = false,
		visible = false,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for main window")
	assert(type(instance.random) == "function", "main-window random provider must be a function")
	assert(type(instance.timedDuration) == "number" and instance.timedDuration > 0, "timed duration must be positive")
	if instance.hintsEnabled == nil then
		instance.hintsEnabled = function()
			return not instance.profile.settings.disableHints
		end
	end
	assert(
		(instance.flightOptionProvider == nil) == (instance.onFlightTimedRequested == nil),
		"flight timing requires both provider and request callbacks"
	)
	instance.timedMinutes = math.floor(instance.timedDuration / 60 + 0.5)
	instance.timedMinutes = math.max(MIN_TIMED_MINUTES, math.min(MAX_TIMED_MINUTES, instance.timedMinutes))
	instance:CreateWindowFrame()
	instance:CreateBoard()
	instance:CreateMenus()
	return instance
end

function MainWindow:HideOverlays()
	if self.summary then
		self.summary:Hide()
	end
	if self.skills then
		self.skills:Hide()
	end
	if self.options then
		self.options:Hide()
	end
	if self.about then
		self.about:Hide()
	end
	if self.legal then
		self.legal:Hide()
	end
	for _, overlay in pairs(self.overlays) do
		overlay:Hide()
	end
	self.activeOverlay = nil
end

function MainWindow:ShowSkills(tab)
	self:PauseForMenu()
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	self.skills:Show(tab)
	self.activeOverlay = "skills"
	return self.skills
end

function MainWindow:ShowOptions()
	self:PauseForMenu()
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	self.options:Show()
	self.activeOverlay = "options"
	return self.options
end

function MainWindow:ShowAbout(tab)
	self:PauseForMenu()
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	self.about:Show(tab)
	self.activeOverlay = "about"
	return self.about
end

function MainWindow:ShowLegal()
	self:PauseForMenu()
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	self.legal:Show()
	self.activeOverlay = "legal"
	return self.legal
end

function MainWindow:ApplySettings(key)
	if key == nil or key == "gameAlpha" then
		self.frame:SetAlpha(self.profile.settings.gameAlpha or 1)
	end
	return key and self.profile.settings[key] or self.profile.settings
end

function MainWindow:ShowSummary(result)
	assert(type(result) == "table", "main window summary requires a result")
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	self.summary:Show(result)
	self.activeOverlay = "summary"
	return self.summary
end

function MainWindow:ShowOverlay(name)
	local overlay = self.overlays[name]
	assert(overlay, "unknown main-window overlay")
	self:HideOverlays()
	self.hud:HideTransientOverlays()
	overlay:Show()
	self.activeOverlay = name
	return overlay
end

function MainWindow:PauseForMenu()
	local session = self.session
	if session and session.active and not session:IsPaused() then
		session:Pause("menu")
		self.menuOwnsPause = true
	end
end

function MainWindow:ShowMenu()
	self:PauseForMenu()
	local menu = self:ShowOverlay("menu")
	if self.session and self.session.active then
		menu.resume:Show()
	else
		menu.resume:Hide()
	end
	return menu
end

function MainWindow:ShowModeMenu()
	self:PauseForMenu()
	return self:ShowOverlay("mode")
end

function MainWindow:SetTimedMinutes(minutes)
	assert(type(minutes) == "number", "timed minutes must be numeric")
	minutes = math.floor(minutes + 0.5)
	assert(minutes >= MIN_TIMED_MINUTES and minutes <= MAX_TIMED_MINUTES, "timed minutes are outside the 2-10 range")
	self.timedMinutes = minutes
	self.timedDuration = minutes * 60
	if self.overlays and self.overlays.timed then
		self.overlays.timed.durationValue:SetText(string.format("%d Minutes", minutes))
	end
	return minutes
end

function MainWindow:GetFlightOptionState()
	if not self.flightOptionProvider then
		return nil
	end
	local state = self.flightOptionProvider(self)
	if state == nil then
		return nil
	end
	assert(type(state) == "table", "flight option provider must return a table or nil")
	assert(type(state.seconds) == "number" and state.seconds >= 0, "flight option seconds must be nonnegative")
	assert(state.learning == nil or type(state.learning) == "boolean", "flight option learning state must be Boolean")
	state = CopyTable(state)
	state.learning = state.learning and true or false
	state.eligible = state.learning or state.seconds >= 60
	return state
end

function MainWindow:SetFlightOptionSelected(selected)
	selected = selected and true or false
	if not self.flightOptionState or not self.flightOptionState.eligible then
		selected = false
	end
	self.flightOptionSelected = selected
	local timed = self.overlays and self.overlays.timed
	if timed then
		timed.flightToggle.label:SetText(selected and "[x] Use flight path time" or "[ ] Use flight path time")
	end
	return selected
end

function MainWindow:RefreshTimedSetup(resetSelection)
	local timed = self.overlays.timed
	local state = self:GetFlightOptionState()
	local selected = not resetSelection and self.flightOptionSelected or false
	self.flightOptionState = state
	timed.flightToggle:Hide()
	timed.flightStatus:Hide()
	timed.flightWarning:Hide()
	if not state then
		self:SetFlightOptionSelected(false)
		return nil
	end
	if not state.eligible then
		self:SetFlightOptionSelected(false)
		timed.flightWarning:Show()
		return state
	end
	self:SetFlightOptionSelected(selected)
	timed.flightToggle:Show()
	timed.flightStatus:SetText(
		(state.learning and "Recording flight time: " or "Remaining flight time: ") .. FormatDuration(state.seconds)
	)
	timed.flightStatus:Show()
	return state
end

function MainWindow:ShowTimedMenu()
	self:PauseForMenu()
	local timed = self:ShowOverlay("timed")
	self:RefreshTimedSetup(true)
	return timed
end

function MainWindow:StartTimedSelection()
	if self.flightOptionSelected then
		assert(self.flightOptionState and self.flightOptionState.eligible, "selected flight option is unavailable")
		return self.onFlightTimedRequested(CopyTable(self.flightOptionState), self)
	end
	return self:StartTimed(self.timedMinutes * 60)
end

function MainWindow:ChooseClassic()
	if SavedVariables:HasClassicGame(self.profile) then
		return self:ShowOverlay("classic")
	end
	return self:StartClassic(false)
end

function MainWindow:ResumeGame()
	self:HideOverlays()
	if self.menuOwnsPause and self.session and self.session.active and not self.session:IsGameOver() then
		self.session:Resume("menu")
	end
	self.menuOwnsPause = false
	return self.session
end

function MainWindow:StopSession(reason)
	local session = self.session
	if not session then
		return nil
	end
	local result = session:Deactivate(reason or "new-game")
	if self.onSessionStopped then
		self.onSessionStopped(result, session, self)
	end
	return result
end

function MainWindow:StartGame(gameMode, restore, duration)
	assert(
		gameMode == Constants.GAME_MODE_CLASSIC or gameMode == Constants.GAME_MODE_TIMED,
		"main window supports Classic or Timed sessions"
	)
	assert(type(restore) == "boolean", "restore state must be Boolean")
	if restore then
		assert(gameMode == Constants.GAME_MODE_CLASSIC and SavedVariables:HasClassicGame(self.profile), "no Classic game is available to continue")
	end
	self:StopSession("new-game")
	self:HideOverlays()
	self.menuOwnsPause = false
	self.windowOwnsPause = false
	self.animations:Resume()
	self.gemPool:SetInteractive(true)
	local fillAttempts
	if not restore then
		local filled, attempts = self.grid:Fill(self.random)
		assert(filled, attempts)
		fillAttempts = attempts
		if gameMode == Constants.GAME_MODE_CLASSIC then
			SavedVariables:ClearClassicGame(self.grid, self.profile)
		end
	end
	self.gemPool:Project(self.grid, true)
	local session = self.hud:CreateSession(self.grid, self.gemPool, {
		profile = self.profile,
		accountData = self.accountData,
		playerName = self.playerName,
		gameMode = gameMode,
		timeLimit = gameMode == Constants.GAME_MODE_TIMED and duration or nil,
		autoSave = true,
		inputOptions = {
			random = self.random,
			audio = self.audio,
		},
		onGameOverComplete = function(result)
			self:ShowSummary(result)
		end,
	})
	self.session = session
	self.gemPool:SetHandlers(session:CreateGemHandlers())
	if restore then
		session:RestoreClassicGame({ paused = false })
	else
		self.gemPool:Project(self.grid, true)
		self.animations:SyncPersistentEffects(false)
		if gameMode == Constants.GAME_MODE_CLASSIC then
			session:SaveClassicGame("new-game")
		end
	end
	local result = {
		status = restore and "restored" or "started",
		gameMode = gameMode,
		timeLimit = session.timeLimit,
		fillAttempts = fillAttempts,
		session = session,
	}
	self.lastStartResult = result
	if self.onSessionStarted then
		self.onSessionStarted(result, session, self)
	end
	return session, result
end

function MainWindow:StartClassic(restore)
	return self:StartGame(Constants.GAME_MODE_CLASSIC, restore and true or false)
end

function MainWindow:StartTimed(duration)
	duration = duration or self.timedMinutes * 60
	assert(type(duration) == "number" and duration > 0, "timed game duration must be positive")
	return self:StartGame(Constants.GAME_MODE_TIMED, false, duration)
end

function MainWindow:HandleWindowShown()
	self.visible = true
	if self.windowOwnsPause and self.session and self.session.active and not self.activeOverlay then
		self.session:Resume("window-shown")
	end
	self.windowOwnsPause = false
	if not self.session and not self.activeOverlay then
		if self.accountData.legalDisplayed then
			self:ShowMenu()
		else
			self:ShowLegal()
		end
	end
end

function MainWindow:HandleWindowHidden()
	self.visible = false
	if self.session and self.session.active and not self.session:IsPaused() then
		self.session:Pause("window-hidden")
		self.windowOwnsPause = true
	end
end

function MainWindow:Show()
	self.suppressWindowScript = true
	self.frame:Show()
	self.suppressWindowScript = false
	self:HandleWindowShown()
	return self
end

function MainWindow:Hide()
	self.suppressWindowScript = true
	self.frame:Hide()
	self.suppressWindowScript = false
	self:HandleWindowHidden()
	return self
end

function MainWindow:IsShown()
	return self.visible
end

function MainWindow:Toggle()
	if self.visible then
		return self:Hide()
	end
	return self:Show()
end

function MainWindow:Update(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "main-window elapsed time must be nonnegative")
	if self.session then
		self.session:AdvanceElapsed(elapsed)
		self.hud:Update(elapsed)
	end
	self.audio:Update(elapsed)
	return self.session and self.session.timerElapsed or 0
end

MainWindow.WINDOW_WIDTH = WINDOW_WIDTH
MainWindow.WINDOW_HEIGHT = WINDOW_HEIGHT
MainWindow.DEFAULT_TIMED_DURATION = DEFAULT_TIMED_DURATION
MainWindow.MIN_TIMED_MINUTES = MIN_TIMED_MINUTES
MainWindow.MAX_TIMED_MINUTES = MAX_TIMED_MINUTES

addon.MainWindow = MainWindow
