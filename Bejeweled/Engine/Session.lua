local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local SavedVariables = assert(addon.SavedVariables, "SavedVariables module is not loaded")
local Scoring = assert(addon.Scoring, "Scoring module is not loaded")
local Input = assert(addon.Input, "Input module is not loaded")

local Session = {}
Session.__index = Session

local CALLBACK_NAMES = {
	"onPauseChanged",
	"onSaved",
	"onRestored",
	"onLevelTransitionStarted",
	"onLevelTransitionComplete",
}

local RESTORED_STATE_KEYS = {
	"gameMode",
	"score",
	"combo",
	"level",
	"pointsToLevelUp",
	"pointMultiplier",
	"largestCascade",
	"largestCombo",
	"gemsCleared",
	"moves",
}

local function CopyTable(source)
	local copy = {}
	for key, value in pairs(source or {}) do
		copy[key] = value
	end
	return copy
end

local function CopyRecords(records)
	local copy = {}
	for index = 1, #(records or {}) do
		copy[index] = CopyTable(records[index])
	end
	return copy
end

local function CopyLevelTransition(record)
	if not record then
		return nil
	end
	local copy = CopyTable(record)
	copy.skillEvents = CopyRecords(record.skillEvents)
	return copy
end

local function ValidateCallbacks(options)
	local callbacks = {}
	for index = 1, #CALLBACK_NAMES do
		local name = CALLBACK_NAMES[index]
		local callback = options[name]
		assert(callback == nil or type(callback) == "function", name .. " must be a function")
		callbacks[name] = callback
	end
	return callbacks
end

function Session:New(grid, gemPool, animations, options)
	assert(type(grid) == "table" and type(grid.LoadLegacyBoard) == "function", "session requires a grid")
	assert(type(gemPool) == "table" and type(gemPool.Project) == "function", "session requires a gem pool")
	assert(type(animations) == "table" and type(animations.IsPlaying) == "function" and type(animations.SyncPersistentEffects) == "function", "session requires animations")
	options = options or {}
	assert(type(options.profile) == "table", "session requires a profile")
	assert(type(options.playerName) == "string" or type(options.playerName) == "function", "session requires a player-name value or provider")

	local gameMode = options.gameMode or Constants.GAME_MODE_CLASSIC
	local scoringState = options.scoringState or Scoring:NewState(gameMode)
	assert(scoringState.gameMode == gameMode, "session game mode differs from scoring state")
	local instance = setmetatable({
		grid = grid,
		gemPool = gemPool,
		animations = animations,
		profile = options.profile,
		playerName = options.playerName,
		savedVariables = options.savedVariables or SavedVariables,
		scoringState = scoringState,
		gameMode = gameMode,
		timerElapsed = options.timerElapsed or 0,
		active = options.active ~= false,
		paused = false,
		autoSave = options.autoSave ~= false,
		deferLevelTransitions = options.deferLevelTransitions == true,
		levelTransitionSequence = 0,
		levelTransition = nil,
		callbacks = ValidateCallbacks(options),
	}, self)
	assert(type(instance.timerElapsed) == "number" and instance.timerElapsed >= 0, "session elapsed time must be nonnegative")
	assert(options.deferLevelTransitions == nil or type(options.deferLevelTransitions) == "boolean", "deferred level-transition state must be Boolean")

	local inputOptions = CopyTable(options.inputOptions)
	local userMoveComplete = inputOptions.onMoveComplete
	inputOptions.scoringState = scoringState
	inputOptions.profile = options.profile
	inputOptions.onMoveComplete = function(result, input)
		instance:HandleMoveComplete(result)
		if userMoveComplete then
			userMoveComplete(result, input)
		end
	end
	instance.input = Input:New(grid, gemPool, animations, inputOptions)
	return instance
end

function Session:ResolvePlayerName()
	local playerName = self.playerName
	if type(playerName) == "function" then
		playerName = playerName()
	end
	assert(type(playerName) == "string" and playerName ~= "", "session player name is unavailable")
	return playerName
end

function Session:Notify(callbackName, result)
	local callback = self.callbacks[callbackName]
	if callback then
		callback(result, self)
	end
end

function Session:GetInput()
	return self.input
end

function Session:IsPaused()
	return self.paused
end

function Session:IsLocked()
	return self.input:IsLocked()
end

function Session:IsLevelTransitionPending()
	return self.levelTransition ~= nil
end

function Session:GetLevelTransition()
	return self.levelTransition and CopyLevelTransition(self.levelTransition.record) or nil
end

function Session:SetPaused(paused, reason)
	assert(type(paused) == "boolean", "session pause state must be Boolean")
	if self.paused == paused then
		return {
			status = paused and "paused" or "running",
			changed = false,
			reason = reason,
		}
	end
	self.paused = paused
	self.input:SetPaused(paused)
	local result = {
		status = paused and "paused" or "running",
		changed = true,
		reason = reason,
	}
	self:Notify("onPauseChanged", result)
	return result
end

function Session:Pause(reason)
	return self:SetPaused(true, reason or "pause")
end

function Session:Resume(reason)
	return self:SetPaused(false, reason or "resume")
end

function Session:SetElapsed(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "session elapsed time must be nonnegative")
	self.timerElapsed = elapsed
	return elapsed
end

function Session:AdvanceElapsed(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "session elapsed delta must be nonnegative")
	if self.active and not self.paused then
		self.timerElapsed = self.timerElapsed + elapsed
	end
	return self.timerElapsed
end

function Session:HasClassicGame()
	return self.savedVariables:HasClassicGame(self.profile)
end

function Session:SaveClassicGame(reason)
	assert(self.active and self.gameMode == Constants.GAME_MODE_CLASSIC, "only an active classic session can be saved")
	assert(not self.levelTransition, "classic session level transition must complete before saving")
	assert(not self.input.pendingMove and not self.animations:IsPlaying(), "classic session must be stable before saving")
	local savedState = self.savedVariables:SaveClassicGame(
		self.grid,
		self.scoringState,
		self.profile,
		self:ResolvePlayerName(),
		self.timerElapsed
	)
	local result = {
		status = "saved",
		reason = reason or "manual",
		savedState = savedState,
	}
	self:Notify("onSaved", result)
	return result
end

function Session:BeginLevelTransition(sourceMove)
	assert(type(sourceMove) == "table", "level transition requires a source move")
	assert(self.active and sourceMove.status == "complete", "level transition requires a completed active move")
	assert(not self.levelTransition, "level transition is already active")
	assert(not self.input.pendingMove and not self.animations:IsPlaying(), "level transition requires a stable board")
	assert(self.scoringState.levelPending, "scoring state has no pending level")

	self.input:SetSessionLocked(true, "level-transition")
	self.levelTransitionSequence = self.levelTransitionSequence + 1
	local record = {
		status = "started",
		transitionID = self.levelTransitionSequence,
		kind = self.gameMode == Constants.GAME_MODE_CLASSIC and "level-up" or "multiplier-up",
		gameMode = self.gameMode,
		score = self.scoringState.score,
		oldLevel = self.scoringState.level,
		level = self.scoringState.level + 1,
		oldPointMultiplier = self.scoringState.pointMultiplier,
		oldPointsToLevelUp = self.scoringState.pointsToLevelUp,
		sound = "LevelUp",
		skillEvents = {},
	}
	self.levelTransition = {
		record = record,
		sourceMove = sourceMove,
	}
	sourceMove.levelTransition = CopyLevelTransition(record)
	self.input:PlaySound(record.sound)
	self:Notify("onLevelTransitionStarted", CopyLevelTransition(record))

	if not self.deferLevelTransitions and self.levelTransition then
		self:CompleteLevelTransition()
	end
	return CopyLevelTransition(record)
end

function Session:CompleteLevelTransition()
	local activeTransition = self.levelTransition
	assert(activeTransition, "no level transition is active")
	local advanced = Scoring:AdvanceLevel(self.scoringState, self.profile, {
		random = self.input.random,
		skillLimit = self.input.skillLimit,
	})
	self.levelTransition = nil
	self.input:SetSessionLocked(false)

	local started = activeTransition.record
	local result = {
		status = "complete",
		transitionID = started.transitionID,
		kind = started.kind,
		gameMode = started.gameMode,
		score = started.score,
		oldLevel = advanced.oldLevel,
		level = advanced.level,
		oldPointMultiplier = started.oldPointMultiplier,
		pointMultiplier = advanced.pointMultiplier,
		oldPointsToLevelUp = started.oldPointsToLevelUp,
		pointsToLevelUp = advanced.pointsToLevelUp,
		skillEvents = CopyRecords(advanced.skillEvents),
	}
	activeTransition.sourceMove.levelTransitionComplete = CopyLevelTransition(result)
	if self.autoSave and self.active and self.gameMode == Constants.GAME_MODE_CLASSIC then
		activeTransition.sourceMove.saveResult = self:SaveClassicGame("level-transition")
	end
	self:Notify("onLevelTransitionComplete", CopyLevelTransition(result))
	return CopyLevelTransition(result)
end

function Session:HandleMoveComplete(result)
	if self.active and result.status == "complete" and self.scoringState.levelPending then
		self:BeginLevelTransition(result)
		return
	end
	if self.autoSave
		and self.active
		and self.gameMode == Constants.GAME_MODE_CLASSIC
		and result.status == "complete" then
		result.saveResult = self:SaveClassicGame("stable-move")
	end
end

function Session:RestoreClassicGame(options)
	options = options or {}
	assert(type(options) == "table", "classic restore options must be a table")
	local pauseAfterRestore = options.paused
	assert(pauseAfterRestore == nil or type(pauseAfterRestore) == "boolean", "restore pause state must be Boolean")
	assert(not self.levelTransition, "cannot restore during a level transition")
	assert(not self.input.pendingMove and not self.animations:IsPlaying(), "cannot restore during an active move")
	local wasPaused = self.paused
	local restored = self.savedVariables:RestoreClassicGame(self.grid, self.profile, self:ResolvePlayerName())
	for index = 1, #RESTORED_STATE_KEYS do
		local key = RESTORED_STATE_KEYS[index]
		self.scoringState[key] = restored[key]
	end
	self.scoringState.levelPending = nil
	self.scoringState.scoreTrack1 = nil
	self.scoringState.scoreTrack2 = nil
	self.scoringState.scoreTrack3 = nil
	self.scoringState.scoreTrack4 = nil
	self.gameMode = Constants.GAME_MODE_CLASSIC
	self.timerElapsed = restored.elapsed
	self.active = true
	self.input.moves = restored.moves
	self.input:ClearSelection("restore")
	self.gemPool:Project(self.grid, true)
	self.animations:SyncPersistentEffects(false)

	if pauseAfterRestore == nil then
		pauseAfterRestore = wasPaused
	end
	if self.paused ~= pauseAfterRestore then
		self:SetPaused(pauseAfterRestore, "restore")
	end
	local result = {
		status = "restored",
		state = restored,
		paused = self.paused,
	}
	self:Notify("onRestored", result)
	return result
end

function Session:HandleCell(column, row)
	return self.input:HandleCell(column, row)
end

function Session:CreateGemHandlers()
	return self.input:CreateGemHandlers()
end

addon.Session = Session
