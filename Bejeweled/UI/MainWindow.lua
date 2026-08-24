local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local SavedVariables = assert(addon.SavedVariables, "SavedVariables module is not loaded")
local Grid = assert(addon.Grid, "Grid module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")
local GemPool = assert(addon.GemPool, "GemPool module is not loaded")
local Animations = assert(addon.Animations, "Animations module is not loaded")
local HUD = assert(addon.HUD, "HUD module is not loaded")

local MainWindow = {}
MainWindow.__index = MainWindow

local WINDOW_WIDTH = 448
local WINDOW_HEIGHT = 510
local BOARD_BORDER_WIDTH = 414
local BOARD_BORDER_HEIGHT = 412
local BOARD_WIDTH = Constants.GRID_WIDTH * Constants.GEM_WIDTH
local BOARD_HEIGHT = Constants.GRID_HEIGHT * Constants.GEM_HEIGHT
local DEFAULT_TIMED_DURATION = 5 * 60
local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"

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
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled window font could not be loaded")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

local function ValidateCallback(callback, name)
	assert(callback == nil or type(callback) == "function", name .. " must be a function")
	return callback
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
		if self.activeOverlay then
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
	local menu = self:CreateOverlay("Menu", 128)
	menu.resume = self:CreateButton(menu, "Resume", 160, 28, function()
		self:ResumeGame()
	end)
	menu.resume:SetPoint("TOP", menu, "TOP", 0, -36)
	menu.newGame = self:CreateButton(menu, "New Game", 160, 28, function()
		self:ShowModeMenu()
	end)
	menu.newGame:SetPoint("TOP", menu.resume, "BOTTOM", 0, -8)

	local mode = self:CreateOverlay("Game Type", 164)
	mode.classic = self:CreateButton(mode, "Classic", 160, 28, function()
		self:ChooseClassic()
	end)
	mode.classic:SetPoint("TOP", mode, "TOP", 0, -36)
	mode.timed = self:CreateButton(mode, "Timed (5 minutes)", 160, 28, function()
		self:StartTimed()
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

	self.overlays = {
		menu = menu,
		mode = mode,
		classic = classic,
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
		timedDuration = options.timedDuration or DEFAULT_TIMED_DURATION,
		hintsEnabled = options.hintsEnabled,
		onSessionStarted = ValidateCallback(options.onSessionStarted, "onSessionStarted"),
		onSessionStopped = ValidateCallback(options.onSessionStopped, "onSessionStopped"),
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
	instance:CreateWindowFrame()
	instance:CreateBoard()
	instance:CreateMenus()
	return instance
end

function MainWindow:HideOverlays()
	for _, overlay in pairs(self.overlays) do
		overlay:Hide()
	end
	self.activeOverlay = nil
end

function MainWindow:ShowOverlay(name)
	local overlay = self.overlays[name]
	assert(overlay, "unknown main-window overlay")
	self:HideOverlays()
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
	duration = duration or self.timedDuration
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
		self:ShowMenu()
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

addon.MainWindow = MainWindow
