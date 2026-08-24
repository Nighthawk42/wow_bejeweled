local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Matches = assert(addon.Matches, "Matches module is not loaded")
local Cascade = assert(addon.Cascade, "Cascade module is not loaded")
local Scoring = assert(addon.Scoring, "Scoring module is not loaded")

local Input = {}
Input.__index = Input

local CALLBACK_NAMES = {
	"onSelectionChanged",
	"onMoveStarted",
	"onCascadeResolved",
	"onMoveComplete",
}

local function ValidateCallbacks(options)
	local callbacks = {}
	for index = 1, #CALLBACK_NAMES do
		local callbackName = CALLBACK_NAMES[index]
		local callback = options[callbackName]
		assert(callback == nil or type(callback) == "function", callbackName .. " must be a function")
		callbacks[callbackName] = callback
	end
	return callbacks
end

local function CopyCell(cell)
	return {
		x = cell.gridX,
		y = cell.gridY,
		contents = cell.contents,
		bigStar = cell.bigStar and true or false,
	}
end

local function BuildHyperPlan(firstCell, secondCell)
	local firstHyper = firstCell.contents == Constants.HYPER_CONTENTS
	local secondHyper = secondCell.contents == Constants.HYPER_CONTENTS
	if not firstHyper and not secondHyper then
		return nil
	end
	if firstHyper and secondHyper then
		return {
			doubleHyper = true,
			targetContents = Constants.HYPER_CONTENTS,
			activations = {
				{ x = firstCell.gridX, y = firstCell.gridY, consumedX = secondCell.gridX, consumedY = secondCell.gridY },
				{ x = secondCell.gridX, y = secondCell.gridY, consumedX = firstCell.gridX, consumedY = firstCell.gridY },
			},
		}
	end
	local hyperCell = firstHyper and firstCell or secondCell
	local colorCell = firstHyper and secondCell or firstCell
	return {
		doubleHyper = false,
		targetContents = colorCell.contents,
		activations = {
			{ x = hyperCell.gridX, y = hyperCell.gridY, consumedX = colorCell.gridX, consumedY = colorCell.gridY },
		},
	}
end

function Input:New(grid, gemPool, animations, options)
	assert(type(grid) == "table" and type(grid.Get) == "function" and type(grid.Swap) == "function", "input requires a grid")
	assert(type(gemPool) == "table" and type(gemPool.SetSelection) == "function", "input requires a gem pool")
	assert(type(animations) == "table" and type(animations.PlaySwap) == "function" and type(animations.Play) == "function" and type(animations.IsPlaying) == "function", "input requires animations")
	options = options or {}
	assert(type(options) == "table", "input options must be a table")
	assert((options.scoringState == nil) == (options.profile == nil), "scoring state and profile must be supplied together")
	assert(options.audio == nil or type(options.audio.Play) == "function", "input audio must expose Play")

	local instance = setmetatable({}, self)
	instance.grid = grid
	instance.gemPool = gemPool
	instance.animations = animations
	instance.matches = options.matches or Matches
	instance.cascade = options.cascade or Cascade
	instance.scoring = options.scoring or Scoring
	instance.scoringState = options.scoringState
	instance.profile = options.profile
	instance.audio = options.audio
	instance.random = options.random or grid.random or math.random
	instance.requireLegalMove = options.requireLegalMove ~= false
	instance.maximumRefillAttempts = options.maximumRefillAttempts
	instance.maximumCascades = options.maximumCascades
	instance.skillLimit = options.skillLimit
	instance.callbacks = ValidateCallbacks(options)
	instance.selectedX = nil
	instance.selectedY = nil
	instance.locked = false
	instance.pendingMove = nil
	instance.lastMove = nil
	instance.moves = instance.scoringState and (instance.scoringState.moves or 0) or (options.moves or 0)
	return instance
end

function Input:IsLocked()
	return self.locked or self.animations:IsPlaying()
end

function Input:GetSelection()
	if not self.selectedX then
		return nil
	end
	return {
		x = self.selectedX,
		y = self.selectedY,
		cell = self.grid:Get(self.selectedX, self.selectedY),
	}
end

function Input:PlaySound(soundName)
	if self.audio then
		self.audio:Play(soundName)
	end
end

function Input:Notify(callbackName, result)
	local callback = self.callbacks[callbackName]
	if callback then
		callback(result, self)
	end
end

function Input:SetSelection(column, row, reason)
	self.selectedX = column
	self.selectedY = row
	self.gemPool:SetSelection(column, row)
	local selection = self:GetSelection()
	self:Notify("onSelectionChanged", {
		status = selection and "selected" or "cleared",
		reason = reason,
		selection = selection,
	})
	return selection
end

function Input:ClearSelection(reason)
	if not self.selectedX then
		return false
	end
	self:SetSelection(nil, nil, reason or "cleared")
	return true
end

function Input:FinishMove(result, status)
	if self.pendingMove ~= result then
		return
	end
	result.status = status
	self.pendingMove = nil
	self.locked = false
	self.lastMove = result
	self:Notify("onMoveComplete", result)
end

function Input:ResolveAcceptedMove(result)
	if self.pendingMove ~= result or result.cascadeStarted then
		return
	end
	result.cascadeStarted = true
	local cascadeOptions = {
		random = self.random,
		requireLegalMove = self.requireLegalMove,
		maximumRefillAttempts = self.maximumRefillAttempts,
		maximumCascades = self.maximumCascades,
	}
	local cascadeResult
	if result.hyperPlan then
		cascadeResult = self.cascade:ResolveHyper(self.grid, result.hyperPlan, cascadeOptions)
		self:PlaySound("HyperDestroy")
		self:PlaySound("ElectroExplode")
	else
		self:PlaySound("GemClick")
		cascadeOptions.initialMatches = result.matchResult
		cascadeResult = self.cascade:Resolve(self.grid, cascadeOptions)
	end
	result.cascadeResult = cascadeResult
	if self.scoringState then
		result.scoringResult = self.scoring:ApplyCascade(
			self.scoringState,
			cascadeResult,
			self.profile,
			{ random = self.random, skillLimit = self.skillLimit }
		)
	end
	self:Notify("onCascadeResolved", result)
	result.cascadeRun = self.animations:Play(cascadeResult, self.grid, {
		onComplete = function()
			self:FinishMove(result, "complete")
		end,
		onCancel = function(reason)
			result.cascadePresentationCancelled = reason
			self:FinishMove(result, "complete")
		end,
	})
end

function Input:BeginSwap(firstX, firstY, secondX, secondY)
	local firstCell = self.grid:Get(firstX, firstY)
	local secondCell = self.grid:Get(secondX, secondY)
	assert(firstCell and secondCell and self.grid:AreAdjacent(firstX, firstY, secondX, secondY), "input swap requires adjacent cells")
	local hyperPlan = BuildHyperPlan(firstCell, secondCell)
	local result = {
		status = "animating",
		first = CopyCell(firstCell),
		second = CopyCell(secondCell),
		valid = false,
		hyperPlan = hyperPlan,
	}
	self.locked = true
	self:ClearSelection("swap")
	self.grid:Swap(firstX, firstY, secondX, secondY)
	if hyperPlan then
		result.valid = true
	else
		local preferredCells = {
			self.grid:Get(firstX, firstY),
			self.grid:Get(secondX, secondY),
		}
		local matchResult = self.matches:Find(self.grid, {
			preferredCells = preferredCells,
			random = self.random,
		})
		result.matchResult = matchResult
		result.valid = matchResult.hasMatches
	end
	if not result.valid then
		self.grid:Swap(firstX, firstY, secondX, secondY)
		self:PlaySound("Invalid")
	elseif not hyperPlan then
		if self.scoringState then
			result.moveResult = self.scoring:RecordMove(
				self.scoringState,
				self.profile,
				{ random = self.random, skillLimit = self.skillLimit }
			)
			self.moves = self.scoringState.moves
		else
			self.moves = self.moves + 1
			result.moveResult = { moves = self.moves, skillEvents = {} }
		end
	else
		result.moveResult = {
			moves = self.moves,
			skillEvents = {},
			legacyHyperMove = true,
		}
	end
	self.pendingMove = result
	result.swapRun = self.animations:PlaySwap(
		firstX,
		firstY,
		secondX,
		secondY,
		not result.valid,
		self.grid,
		{
			onComplete = function()
				if result.valid then
					self:ResolveAcceptedMove(result)
				else
					self:FinishMove(result, "rejected")
				end
			end,
			onCancel = function(reason)
				result.swapPresentationCancelled = reason
				if result.valid then
					self:ResolveAcceptedMove(result)
				else
					self:FinishMove(result, "rejected")
				end
			end,
		}
	)
	self:Notify("onMoveStarted", result)
	return result
end

function Input:HandleCell(column, row)
	if self:IsLocked() then
		return { status = "locked" }
	end
	local cell = self.grid:Get(column, row)
	assert(cell, "input cell is out of bounds")
	if cell.contents == Constants.EMPTY_CONTENTS then
		return { status = "empty" }
	end
	if not self.selectedX then
		self:SetSelection(column, row, "input")
		self:PlaySound("Select")
		return { status = "selected", selection = self:GetSelection() }
	end
	if self.selectedX == column and self.selectedY == row then
		self:ClearSelection("toggle")
		return { status = "cleared" }
	end
	if not self.grid:AreAdjacent(self.selectedX, self.selectedY, column, row) then
		self:ClearSelection("nonadjacent")
		return { status = "cleared", reason = "nonadjacent" }
	end
	return self:BeginSwap(self.selectedX, self.selectedY, column, row)
end

function Input:CreateGemHandlers()
	return {
		onMouseDown = function(frame, button)
			if button == nil or button == "LeftButton" then
				return self:HandleCell(frame.gridX, frame.gridY)
			end
		end,
	}
end

addon.Input = Input
