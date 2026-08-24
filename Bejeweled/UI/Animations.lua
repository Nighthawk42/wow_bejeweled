local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local Animations = {}
Animations.__index = Animations

local DEFAULT_CLEAR_DURATION = 0.1
local DEFAULT_FALL_PER_CELL = 0.05
local DEFAULT_MINIMUM_FALL_DURATION = 0.1

local function AssertCoordinate(value, maximum, label)
	assert(type(value) == "number" and value == math.floor(value) and value >= 1 and value <= maximum, label .. " is out of bounds")
end

local function AssertRecordList(step, fieldName)
	local records = step[fieldName]
	assert(type(records) == "table", "cascade step is missing " .. fieldName)
	return records
end

local function CopyCallbacks(defaults, callbacks)
	callbacks = callbacks or {}
	assert(type(callbacks) == "table", "animation callbacks must be a table")
	local result = {}
	for _, callbackName in ipairs({ "onPhase", "onComplete", "onCancel" }) do
		local callback = callbacks[callbackName]
		if callback == nil then
			callback = defaults[callbackName]
		end
		assert(callback == nil or type(callback) == "function", callbackName .. " must be a function")
		result[callbackName] = callback
	end
	return result
end

local function ResolveSteps(cascadeResult)
	assert(type(cascadeResult) == "table", "animation plan requires a cascade result")
	if cascadeResult.steps ~= nil then
		assert(type(cascadeResult.steps) == "table", "cascade steps must be a table")
		return cascadeResult.steps
	end
	return { cascadeResult }
end

local function SetFrameAnchor(frame, column, row)
	local x = (column - 1) * Constants.GEM_WIDTH
	local y = (row - 1) * Constants.GEM_HEIGHT
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", x, -y)
	frame.x = x
	frame.y = y
end

local function CreateClearAnimation(frame)
	local group = frame:CreateAnimationGroup()
	local alpha = group:CreateAnimation("Alpha")
	frame.bejeweledClearAnimation = {
		group = group,
		alpha = alpha,
	}
	return frame.bejeweledClearAnimation
end

local function CreateMoveAnimation(frame)
	local group = frame:CreateAnimationGroup()
	local translation = group:CreateAnimation("Translation")
	local alpha = group:CreateAnimation("Alpha")
	frame.bejeweledMoveAnimation = {
		group = group,
		translation = translation,
		alpha = alpha,
	}
	return frame.bejeweledMoveAnimation
end

local function MakeFinishedCallback(runner, run, group, onFinished)
	return function()
		if runner.active ~= run or run.cancelled or not run.activeGroups[group] then
			return
		end
		run.activeGroups[group] = nil
		group:SetScript("OnFinished", nil)
		run.pending = run.pending - 1
		if run.pending == 0 then
			onFinished()
		end
	end
end

function Animations:New(gemPool, options)
	assert(type(gemPool) == "table" and type(gemPool.GetFrame) == "function", "animations require a gem pool")
	options = options or {}
	assert(type(options) == "table", "animation options must be a table")

	local instance = setmetatable({}, self)
	instance.gemPool = gemPool
	instance.clearDuration = options.clearDuration or DEFAULT_CLEAR_DURATION
	instance.fallPerCell = options.fallPerCell or DEFAULT_FALL_PER_CELL
	instance.minimumFallDuration = options.minimumFallDuration or DEFAULT_MINIMUM_FALL_DURATION
	assert(type(instance.clearDuration) == "number" and instance.clearDuration > 0, "clear duration must be positive")
	assert(type(instance.fallPerCell) == "number" and instance.fallPerCell > 0, "fall duration per cell must be positive")
	assert(type(instance.minimumFallDuration) == "number" and instance.minimumFallDuration > 0, "minimum fall duration must be positive")
	instance.callbacks = CopyCallbacks({}, options)
	instance.generation = 0
	instance.active = nil
	return instance
end

function Animations:BuildPlan(cascadeResult)
	local sourceSteps = ResolveSteps(cascadeResult)
	local plan = { steps = {} }
	for stepIndex = 1, #sourceSteps do
		local source = sourceSteps[stepIndex]
		assert(type(source) == "table", "cascade step must be a table")
		local removedCells = AssertRecordList(source, "removedCells")
		local spawnedSpecials = AssertRecordList(source, "spawnedSpecials")
		local moves = AssertRecordList(source, "moves")
		local refills = AssertRecordList(source, "refills")
		local step = {
			source = source,
			clear = {},
			specials = {},
			moves = {},
			refills = {},
		}

		for index = 1, #removedCells do
			local record = removedCells[index]
			assert(type(record) == "table", "removed-cell record must be a table")
			AssertCoordinate(record.x, Constants.GRID_WIDTH, "removed-cell column")
			AssertCoordinate(record.y, Constants.GRID_HEIGHT, "removed-cell row")
			step.clear[index] = {
				x = record.x,
				y = record.y,
				duration = self.clearDuration,
				record = record,
			}
		end

		for index = 1, #spawnedSpecials do
			local record = spawnedSpecials[index]
			assert(type(record) == "table", "spawned-special record must be a table")
			AssertCoordinate(record.createdX, Constants.GRID_WIDTH, "spawned-special column")
			AssertCoordinate(record.createdY, Constants.GRID_HEIGHT, "spawned-special row")
			assert(record.kind == "power" or record.kind == "hyper", "unsupported spawned-special kind")
			step.specials[index] = {
				x = record.createdX,
				y = record.createdY,
				contents = record.kind == "hyper" and Constants.HYPER_CONTENTS or record.contents,
				bigStar = record.kind == "power",
				record = record,
			}
		end

		for index = 1, #moves do
			local record = moves[index]
			assert(type(record) == "table", "movement record must be a table")
			AssertCoordinate(record.fromX, Constants.GRID_WIDTH, "movement source column")
			AssertCoordinate(record.fromY, Constants.GRID_HEIGHT, "movement source row")
			AssertCoordinate(record.toX, Constants.GRID_WIDTH, "movement destination column")
			AssertCoordinate(record.toY, Constants.GRID_HEIGHT, "movement destination row")
			local distance = record.distance or (record.toY - record.fromY)
			assert(type(distance) == "number" and distance > 0, "movement distance must be positive")
			step.moves[index] = {
				fromX = record.fromX,
				fromY = record.fromY,
				toX = record.toX,
				toY = record.toY,
				distance = distance,
				duration = math.max(self.minimumFallDuration, distance * self.fallPerCell),
				offsetX = (record.toX - record.fromX) * Constants.GEM_WIDTH,
				offsetY = -(record.toY - record.fromY) * Constants.GEM_HEIGHT,
				contents = record.contents,
				bigStar = record.bigStar and true or false,
				record = record,
			}
		end

		local refillCounts = {}
		for index = 1, #refills do
			local record = refills[index]
			assert(type(record) == "table", "refill record must be a table")
			AssertCoordinate(record.x, Constants.GRID_WIDTH, "refill column")
			AssertCoordinate(record.y, Constants.GRID_HEIGHT, "refill row")
			refillCounts[record.x] = (refillCounts[record.x] or 0) + 1
		end
		for index = 1, #refills do
			local record = refills[index]
			local fromY = record.y - refillCounts[record.x]
			local distance = record.y - fromY
			step.refills[index] = {
				fromX = record.x,
				fromY = fromY,
				toX = record.x,
				toY = record.y,
				distance = distance,
				duration = math.max(self.minimumFallDuration, distance * self.fallPerCell),
				offsetX = 0,
				offsetY = -(record.y - fromY) * Constants.GEM_HEIGHT,
				contents = record.contents,
				bigStar = false,
				record = record,
			}
		end

		plan.steps[stepIndex] = step
	end
	return plan
end

function Animations:IsPlaying()
	return self.active ~= nil
end

function Animations:NotifyPhase(run, phase, stepIndex, step)
	if run.callbacks.onPhase then
		run.callbacks.onPhase(phase, stepIndex, step, run)
	end
end

function Animations:WaitForGroups(run, groups, onFinished)
	if #groups == 0 then
		onFinished()
		return
	end
	run.pending = #groups
	for index = 1, #groups do
		local group = groups[index]
		run.activeGroups[group] = true
		group:SetScript("OnFinished", MakeFinishedCallback(self, run, group, onFinished))
		group:Play()
	end
end

function Animations:CompleteRun(run)
	if self.active ~= run or run.cancelled then
		return
	end
	self.gemPool:ResetPresentation(run.finalGrid)
	self.gemPool:SetInteractive(true)
	self.active = nil
	run.completed = true
	if run.callbacks.onComplete then
		run.callbacks.onComplete(run)
	end
end

function Animations:PlaySettle(run, stepIndex, step)
	if self.active ~= run or run.cancelled then
		return
	end
	self:NotifyPhase(run, "settle", stepIndex, step)
	if self.active ~= run or run.cancelled then
		return
	end

	for index = 1, #step.moves do
		local move = step.moves[index]
		self.gemPool:RenderCell(move.fromX, move.fromY, { contents = Constants.EMPTY_CONTENTS }, true)
	end

	local groups = {}
	local destinations = {}
	local function PrepareMovement(movement, fadeIn)
		local frame = self.gemPool:GetFrame(movement.toX, movement.toY)
		self.gemPool:RenderCell(movement.toX, movement.toY, {
			contents = movement.contents,
			bigStar = movement.bigStar,
		}, true)
		SetFrameAnchor(frame, movement.fromX, movement.fromY)
		frame:SetAlpha(fadeIn and 0 or 1)
		frame:Show()
		local animation = frame.bejeweledMoveAnimation or CreateMoveAnimation(frame)
		animation.translation:SetDuration(movement.duration)
		animation.translation:SetOffset(movement.offsetX, movement.offsetY)
		animation.alpha:SetDuration(movement.duration)
		animation.alpha:SetFromAlpha(fadeIn and 0 or 1)
		animation.alpha:SetToAlpha(1)
		groups[#groups + 1] = animation.group
		destinations[#destinations + 1] = { frame = frame, movement = movement }
	end

	for index = 1, #step.moves do
		PrepareMovement(step.moves[index], false)
	end
	for index = 1, #step.refills do
		PrepareMovement(step.refills[index], true)
	end

	self:WaitForGroups(run, groups, function()
		if self.active ~= run or run.cancelled then
			return
		end
		for index = 1, #destinations do
			local destination = destinations[index]
			SetFrameAnchor(destination.frame, destination.movement.toX, destination.movement.toY)
			destination.frame:SetAlpha(1)
		end
		self:PlayStep(run, stepIndex + 1)
	end)
end

function Animations:PlayStep(run, stepIndex)
	if self.active ~= run or run.cancelled then
		return
	end
	local step = run.plan.steps[stepIndex]
	if not step then
		self:CompleteRun(run)
		return
	end

	self:NotifyPhase(run, "clear", stepIndex, step)
	if self.active ~= run or run.cancelled then
		return
	end
	local groups = {}
	for index = 1, #step.clear do
		local clear = step.clear[index]
		local frame = self.gemPool:GetFrame(clear.x, clear.y)
		frame:SetAlpha(1)
		local animation = frame.bejeweledClearAnimation or CreateClearAnimation(frame)
		animation.alpha:SetDuration(clear.duration)
		animation.alpha:SetFromAlpha(1)
		animation.alpha:SetToAlpha(0)
		groups[#groups + 1] = animation.group
	end

	self:WaitForGroups(run, groups, function()
		if self.active ~= run or run.cancelled then
			return
		end
		for index = 1, #step.clear do
			local clear = step.clear[index]
			self.gemPool:RenderCell(clear.x, clear.y, { contents = Constants.EMPTY_CONTENTS }, true)
			self.gemPool:GetFrame(clear.x, clear.y):SetAlpha(1)
		end
		for index = 1, #step.specials do
			local special = step.specials[index]
			self.gemPool:RenderCell(special.x, special.y, special, true)
		end
		self:PlaySettle(run, stepIndex, step)
	end)
end

function Animations:Play(cascadeResult, finalGrid, callbacks)
	assert(type(finalGrid) == "table" and type(finalGrid.Get) == "function", "animation playback requires the final grid")
	if self.active then
		self:Cancel("superseded")
	end
	self.generation = self.generation + 1
	local run = {
		generation = self.generation,
		plan = self:BuildPlan(cascadeResult),
		finalGrid = finalGrid,
		callbacks = CopyCallbacks(self.callbacks, callbacks),
		activeGroups = {},
		pending = 0,
		cancelled = false,
		completed = false,
	}
	self.active = run
	self.gemPool:SetInteractive(false)
	self:PlayStep(run, 1)
	return run
end

function Animations:Cancel(reason)
	local run = self.active
	if not run then
		return false
	end
	run.cancelled = true
	run.cancelReason = reason or "cancelled"
	for group in pairs(run.activeGroups) do
		group:SetScript("OnFinished", nil)
		group:Stop()
	end
	run.activeGroups = {}
	run.pending = 0
	self.gemPool:ResetPresentation(run.finalGrid)
	self.gemPool:SetInteractive(true)
	self.active = nil
	if run.callbacks.onCancel then
		run.callbacks.onCancel(run.cancelReason, run)
	end
	return true
end

addon.Animations = Animations
