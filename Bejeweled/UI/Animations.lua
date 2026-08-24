local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local Animations = {}
Animations.__index = Animations

local DEFAULT_CLEAR_DURATION = 0.1
local DEFAULT_FALL_PER_CELL = 0.05
local DEFAULT_MINIMUM_FALL_DURATION = 0.1
local DEFAULT_EFFECT_INTERVAL = 0.025
local DEFAULT_SWAP_DURATION = Constants.GEM_WIDTH / 150
local HYPER_FRAME_COUNT = 40
local EXPLOSION_FRAME_COUNT = 16
local LIGHTNING_FRAME_COUNT = 15
local POWER_STAR_SIZE = 90
local EXPLOSION_SIZE = 150
local LIGHTNING_THICKNESS = 10

local function BuildHyperAtlas()
	local atlas = {}
	for row = 0, 3 do
		for column = 0, 9 do
			atlas[#atlas + 1] = {
				column * 0.1,
				(column + 1) * 0.1,
				row * 0.19999,
				(row + 1) * 0.19999,
			}
		end
	end
	return atlas
end

local function BuildExplosionAtlas()
	local atlas = {}
	for row = 0, 4 do
		for column = 0, 4 do
			local left = column == 0 and 0 or (column * 50 - 1) / 255
			atlas[#atlas + 1] = {
				left,
				((column + 1) * 50 - 1) / 255,
				(row * 50) / 255,
				((row + 1) * 50 - 1) / 255,
			}
		end
	end
	return atlas
end

local HYPER_ATLAS = BuildHyperAtlas()
local EXPLOSION_ATLAS = BuildExplosionAtlas()

local function SetTexCoord(texture, coordinates)
	texture:SetTexCoord(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
end

local function SetTextureSize(texture, width, height)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

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

local function CreateSwapAnimation(frame, rollback)
	local group = frame:CreateAnimationGroup()
	local outbound = group:CreateAnimation("Translation")
	outbound:SetOrder(1)
	local animation = {
		group = group,
		outbound = outbound,
	}
	if rollback then
		animation.returnTranslation = group:CreateAnimation("Translation")
		animation.returnTranslation:SetOrder(2)
		frame.bejeweledSwapRollbackAnimation = animation
	else
		frame.bejeweledSwapForwardAnimation = animation
	end
	return animation
end

local function FinishPending(runner, run, onFinished)
	if runner.active ~= run or run.cancelled then
		return
	end
	run.pending = run.pending - 1
	if run.pending == 0 then
		onFinished()
	end
end

local function MakeFinishedCallback(runner, run, group, onFinished)
	return function()
		if runner.active ~= run or run.cancelled or not run.activeGroups[group] then
			return
		end
		run.activeGroups[group] = nil
		group:SetScript("OnFinished", nil)
		FinishPending(runner, run, onFinished)
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
	instance.effectInterval = options.effectInterval or DEFAULT_EFFECT_INTERVAL
	instance.swapDuration = options.swapDuration or DEFAULT_SWAP_DURATION
	assert(type(instance.clearDuration) == "number" and instance.clearDuration > 0, "clear duration must be positive")
	assert(type(instance.fallPerCell) == "number" and instance.fallPerCell > 0, "fall duration per cell must be positive")
	assert(type(instance.minimumFallDuration) == "number" and instance.minimumFallDuration > 0, "minimum fall duration must be positive")
	assert(type(instance.effectInterval) == "number" and instance.effectInterval > 0, "effect interval must be positive")
	assert(type(instance.swapDuration) == "number" and instance.swapDuration > 0, "swap duration must be positive")
	instance.callbacks = CopyCallbacks({}, options)
	instance.generation = 0
	instance.active = nil
	instance.paused = false
	instance.effectElapsed = 0
	instance.activeExplosions = {}
	instance.explosionPool = {}
	instance.activeLightning = {}
	instance.lightningPool = {}
	instance.createFrame = options.createFrame or gemPool.createFrame or CreateFrame
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for animation effects")
	instance.effectParent = options.effectParent or gemPool.parent
	instance.effectFrame = instance.createFrame("Frame", nil, instance.effectParent)
	assert(type(instance.effectFrame.SetScript) == "function", "animation effect driver does not support scripts")
	instance.effectFrame:SetScript("OnUpdate", function(_, elapsed)
		instance:UpdateEffects(elapsed)
	end)
	instance.effectFrame:Show()
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
		local triggeredPowerRecords = AssertRecordList(source, "triggeredPowerRecords")
		local lightningLinks = AssertRecordList(source, "lightningLinks")
		local moves = AssertRecordList(source, "moves")
		local refills = AssertRecordList(source, "refills")
		local step = {
			source = source,
			clear = {},
			specials = {},
			moves = {},
			refills = {},
			explosions = {},
			lightning = {},
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

		for index = 1, #triggeredPowerRecords do
			local record = triggeredPowerRecords[index]
			assert(type(record) == "table", "triggered-power record must be a table")
			AssertCoordinate(record.x, Constants.GRID_WIDTH, "triggered-power column")
			AssertCoordinate(record.y, Constants.GRID_HEIGHT, "triggered-power row")
			step.explosions[index] = {
				x = record.x,
				y = record.y,
				record = record,
			}
		end

		for index = 1, #lightningLinks do
			local record = lightningLinks[index]
			assert(type(record) == "table", "lightning-link record must be a table")
			AssertCoordinate(record.fromX, Constants.GRID_WIDTH, "lightning source column")
			AssertCoordinate(record.fromY, Constants.GRID_HEIGHT, "lightning source row")
			AssertCoordinate(record.toX, Constants.GRID_WIDTH, "lightning target column")
			AssertCoordinate(record.toY, Constants.GRID_HEIGHT, "lightning target row")
			assert(type(Constants.GEM_EFFECT_COLORS[record.contents]) == "table", "lightning color is unsupported")
			step.lightning[index] = {
				fromX = record.fromX,
				fromY = record.fromY,
				toX = record.toX,
				toY = record.toY,
				contents = record.contents,
				delayTicks = index - 1,
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

function Animations:IsPaused()
	return self.paused
end

function Animations:Pause()
	if self.paused then
		return false
	end
	self.paused = true
	local run = self.active
	if run then
		run.paused = true
		for group in pairs(run.activeGroups) do
			group:Pause()
		end
	end
	self.gemPool:SetInteractive(false)
	return true
end

function Animations:Resume()
	if not self.paused then
		return false
	end
	self.paused = false
	local run = self.active
	if run then
		run.paused = false
		for group in pairs(run.activeGroups) do
			group:Play()
		end
	else
		self.gemPool:SetInteractive(true)
	end
	return true
end

function Animations:CreatePowerLayers(frame)
	local texture = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(texture, POWER_STAR_SIZE, POWER_STAR_SIZE)
	texture:SetPoint("CENTER", frame.texture)
	texture:SetTexture(Constants.IMAGE_ROOT .. "bigstar")
	texture:SetTexCoord(0, 1, 0, 1)

	local highlight = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(highlight, POWER_STAR_SIZE, POWER_STAR_SIZE)
	highlight:SetPoint("CENTER", frame.texture)
	highlight:SetTexture(Constants.IMAGE_ROOT .. "bigstar")
	highlight:SetTexCoord(0, 1, 0, 1)
	highlight:SetBlendMode("ADD")

	frame.bejeweledPowerEffect = {
		texture = texture,
		highlight = highlight,
		angle = 1,
		highlightAngle = 1,
		alpha = 100,
		alphaStep = -3,
	}
	return frame.bejeweledPowerEffect
end

function Animations:SyncFrameEffect(frame, advance)
	local contents = frame.projectedContents
	local bigStar = frame.projectedBigStar and true or false
	if frame.bejeweledEffectContents ~= contents or frame.bejeweledEffectBigStar ~= bigStar then
		frame.bejeweledEffectContents = contents
		frame.bejeweledEffectBigStar = bigStar
		frame.bejeweledHyperFrame = 1
		local power = frame.bejeweledPowerEffect
		if power then
			power.angle = 1
			power.highlightAngle = 1
			power.alpha = 100
			power.alphaStep = -3
		end
	end

	if contents == Constants.HYPER_CONTENTS then
		local hyperFrame = frame.bejeweledHyperFrame or 1
		if advance then
			hyperFrame = hyperFrame + 1
			if hyperFrame > HYPER_FRAME_COUNT then
				hyperFrame = 1
			end
			frame.bejeweledHyperFrame = hyperFrame
		end
		SetTexCoord(frame.texture, HYPER_ATLAS[hyperFrame])
	end

	local power = frame.bejeweledPowerEffect
	if bigStar then
		power = power or self:CreatePowerLayers(frame)
		if advance then
			power.angle = power.angle + 0.5
			if power.angle > 360 then
				power.angle = 360 - power.angle
			end
			power.highlightAngle = power.highlightAngle - 2.5
			if power.highlightAngle <= 0 then
				power.highlightAngle = power.highlightAngle + 360
			end
			local alpha = power.alpha + power.alphaStep
			if alpha > 100 then
				power.alphaStep = -power.alphaStep
				alpha = 100
			elseif alpha < 0 then
				power.alphaStep = -power.alphaStep
				alpha = 0
			end
			power.alpha = alpha
		end
		local visibleAngle = power.angle <= 0 and 360 + power.angle or power.angle
		power.texture:SetRotation(visibleAngle * math.pi / 180)
		power.highlight:SetRotation(power.highlightAngle * math.pi / 180)
		power.texture:SetAlpha(power.alpha / 100)
		power.highlight:SetAlpha((100 - power.alpha) / 100)
		power.texture:Show()
		power.highlight:Show()
	elseif power then
		power.texture:Hide()
		power.highlight:Hide()
	end
end

function Animations:SyncPersistentEffects(advance)
	for row = 1, Constants.GRID_HEIGHT do
		for column = 1, Constants.GRID_WIDTH do
			self:SyncFrameEffect(self.gemPool:GetFrame(column, row), advance and true or false)
		end
	end
end

function Animations:CreateExplosionFrame()
	local frame = self.createFrame("Frame", nil, self.effectParent)
	frame:SetWidth(Constants.GEM_WIDTH)
	frame:SetHeight(Constants.GEM_HEIGHT)
	if self.effectParent and type(self.effectParent.GetFrameLevel) == "function" then
		frame:SetFrameLevel(self.effectParent:GetFrameLevel() + 4)
	end
	frame.texture = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(frame.texture, EXPLOSION_SIZE, EXPLOSION_SIZE)
	frame.texture:SetPoint("CENTER")
	frame.texture:SetTexture(Constants.IMAGE_ROOT .. "explosion")
	frame:Hide()
	return frame
end

function Animations:CreateLightningObject()
	assert(type(self.effectFrame.CreateLine) == "function", "animation effect frame cannot create lines")
	local base = self.effectFrame:CreateLine(nil, "ARTWORK")
	local highlight = self.effectFrame:CreateLine(nil, "OVERLAY")
	base:SetTexture(Constants.IMAGE_ROOT .. "lightning")
	base:SetBlendMode("ADD")
	base:SetThickness(LIGHTNING_THICKNESS)
	highlight:SetBlendMode("ADD")
	highlight:SetThickness(math.max(1, LIGHTNING_THICKNESS / 3))
	base:Hide()
	highlight:Hide()
	return {
		base = base,
		highlight = highlight,
	}
end

function Animations:ReleaseLightning(lightning, completed)
	for index = #self.activeLightning, 1, -1 do
		if self.activeLightning[index] == lightning then
			table.remove(self.activeLightning, index)
			break
		end
	end
	if lightning.run then
		lightning.run.activeLightning[lightning] = nil
	end
	lightning.base:Hide()
	lightning.highlight:Hide()
	local onFinished = lightning.onFinished
	lightning.onFinished = nil
	lightning.run = nil
	self.lightningPool[#self.lightningPool + 1] = lightning
	if completed and onFinished then
		onFinished()
	end
end

function Animations:PlayLightning(record, onFinished, run)
	local lightning = table.remove(self.lightningPool) or self:CreateLightningObject()
	local fromX = (record.fromX - 0.5) * Constants.GEM_WIDTH
	local fromY = -((record.fromY - 0.5) * Constants.GEM_HEIGHT)
	local toX = (record.toX - 0.5) * Constants.GEM_WIDTH
	local toY = -((record.toY - 0.5) * Constants.GEM_HEIGHT)
	local color = Constants.GEM_EFFECT_COLORS[record.contents]
	lightning.base:ClearAllPoints()
	lightning.highlight:ClearAllPoints()
	lightning.base:SetStartPoint("TOPLEFT", self.effectParent, fromX, fromY)
	lightning.base:SetEndPoint("TOPLEFT", self.effectParent, toX, toY)
	lightning.highlight:SetStartPoint("TOPLEFT", self.effectParent, fromX, fromY)
	lightning.highlight:SetEndPoint("TOPLEFT", self.effectParent, toX, toY)
	lightning.highlight:SetColorTexture(color[1], color[2], color[3], 1)
	lightning.base:SetAlpha(0.8)
	lightning.highlight:SetAlpha(0.2)
	lightning.effectFrame = 1
	lightning.delayTicks = record.delayTicks or 0
	lightning.onFinished = onFinished
	lightning.run = run
	if lightning.delayTicks == 0 then
		lightning.base:Show()
		lightning.highlight:Show()
	else
		lightning.base:Hide()
		lightning.highlight:Hide()
	end
	self.activeLightning[#self.activeLightning + 1] = lightning
	if run then
		run.activeLightning[lightning] = true
	end
	return lightning
end

function Animations:ReleaseExplosion(explosion, completed)
	for index = #self.activeExplosions, 1, -1 do
		if self.activeExplosions[index] == explosion then
			table.remove(self.activeExplosions, index)
			break
		end
	end
	if explosion.run then
		explosion.run.activeExplosions[explosion] = nil
	end
	explosion:Hide()
	local onFinished = explosion.onFinished
	explosion.onFinished = nil
	explosion.run = nil
	self.explosionPool[#self.explosionPool + 1] = explosion
	if completed and onFinished then
		onFinished()
	end
end

function Animations:PlayExplosion(column, row, onFinished, run)
	AssertCoordinate(column, Constants.GRID_WIDTH, "explosion column")
	AssertCoordinate(row, Constants.GRID_HEIGHT, "explosion row")
	assert(onFinished == nil or type(onFinished) == "function", "explosion completion callback must be a function")
	local explosion = table.remove(self.explosionPool) or self:CreateExplosionFrame()
	explosion:ClearAllPoints()
	explosion:SetPoint(
		"TOPLEFT",
		self.effectParent,
		"TOPLEFT",
		(column - 1) * Constants.GEM_WIDTH,
		-((row - 1) * Constants.GEM_HEIGHT)
	)
	explosion.column = column
	explosion.row = row
	explosion.effectFrame = 1
	explosion.onFinished = onFinished
	explosion.run = run
	SetTexCoord(explosion.texture, EXPLOSION_ATLAS[1])
	explosion:SetAlpha(1)
	explosion:Show()
	self.activeExplosions[#self.activeExplosions + 1] = explosion
	if run then
		run.activeExplosions[explosion] = true
	end
	return explosion
end

function Animations:UpdateEffects(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "animation elapsed time must be nonnegative")
	if self.paused then
		return false
	end
	self.effectElapsed = self.effectElapsed + elapsed
	if self.effectElapsed < self.effectInterval then
		return false
	end
	self.effectElapsed = 0
	self:SyncPersistentEffects(true)
	for index = #self.activeExplosions, 1, -1 do
		local explosion = self.activeExplosions[index]
		local nextFrame = explosion.effectFrame + 1
		if nextFrame > EXPLOSION_FRAME_COUNT then
			self:ReleaseExplosion(explosion, true)
		else
			explosion.effectFrame = nextFrame
			SetTexCoord(explosion.texture, EXPLOSION_ATLAS[nextFrame])
		end
	end
	for index = #self.activeLightning, 1, -1 do
		local lightning = self.activeLightning[index]
		if lightning.delayTicks > 0 then
			lightning.delayTicks = lightning.delayTicks - 1
			if lightning.delayTicks == 0 then
				lightning.base:Show()
				lightning.highlight:Show()
			end
		else
			local nextFrame = lightning.effectFrame + 1
			if nextFrame > LIGHTNING_FRAME_COUNT then
				self:ReleaseLightning(lightning, true)
			else
				lightning.effectFrame = nextFrame
				lightning.highlight:SetAlpha(math.fmod(nextFrame, 2) == 1 and 0.2 or 0.6)
			end
		end
	end
	return true
end

function Animations:NotifyPhase(run, phase, stepIndex, step)
	if run.callbacks.onPhase then
		run.callbacks.onPhase(phase, stepIndex, step, run)
	end
end

function Animations:WaitForPhase(run, groups, explosions, lightning, onFinished)
	local pending = #groups + #explosions + #lightning
	if pending == 0 then
		onFinished()
		return
	end
	run.pending = pending
	for index = 1, #groups do
		local group = groups[index]
		run.activeGroups[group] = true
		group:SetScript("OnFinished", MakeFinishedCallback(self, run, group, onFinished))
		group:Play()
		if self.paused then
			group:Pause()
		end
	end
	for index = 1, #explosions do
		local explosion = explosions[index]
		self:PlayExplosion(explosion.x, explosion.y, function()
			FinishPending(self, run, onFinished)
		end, run)
	end
	for index = 1, #lightning do
		self:PlayLightning(lightning[index], function()
			FinishPending(self, run, onFinished)
		end, run)
	end
end

function Animations:CompleteRun(run)
	if self.active ~= run or run.cancelled then
		return
	end
	self.gemPool:ResetPresentation(run.finalGrid)
	self:SyncPersistentEffects(false)
	self.gemPool:SetInteractive(not self.paused)
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
	self:SyncPersistentEffects(false)

	self:WaitForPhase(run, groups, {}, {}, function()
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

	self:WaitForPhase(run, groups, step.explosions, step.lightning, function()
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
		self:SyncPersistentEffects(false)
		self:PlaySettle(run, stepIndex, step)
	end)
end

function Animations:PlaySwap(firstX, firstY, secondX, secondY, rollback, finalGrid, callbacks)
	AssertCoordinate(firstX, Constants.GRID_WIDTH, "first swap column")
	AssertCoordinate(firstY, Constants.GRID_HEIGHT, "first swap row")
	AssertCoordinate(secondX, Constants.GRID_WIDTH, "second swap column")
	AssertCoordinate(secondY, Constants.GRID_HEIGHT, "second swap row")
	assert(math.abs(firstX - secondX) + math.abs(firstY - secondY) == 1, "swap animation requires adjacent cells")
	assert(type(finalGrid) == "table" and type(finalGrid.Get) == "function", "swap animation requires the final grid")
	if self.active then
		self:Cancel("superseded")
	end

	self.generation = self.generation + 1
	local run = {
		kind = "swap",
		generation = self.generation,
		finalGrid = finalGrid,
		callbacks = CopyCallbacks(self.callbacks, callbacks),
		activeGroups = {},
		activeExplosions = {},
		activeLightning = {},
		pending = 0,
		cancelled = false,
		completed = false,
		paused = self.paused,
		rollback = rollback and true or false,
	}
	self.active = run
	self.gemPool:SetInteractive(false)
	self.gemPool:SetSelection(nil)
	if run.callbacks.onPhase then
		run.callbacks.onPhase(run.rollback and "swap-rollback" or "swap", 1, nil, run)
	end
	if self.active ~= run or run.cancelled then
		return run
	end

	local groups = {}
	local movements = {
		{ frame = self.gemPool:GetFrame(firstX, firstY), offsetX = (secondX - firstX) * Constants.GEM_WIDTH, offsetY = -(secondY - firstY) * Constants.GEM_HEIGHT },
		{ frame = self.gemPool:GetFrame(secondX, secondY), offsetX = (firstX - secondX) * Constants.GEM_WIDTH, offsetY = -(firstY - secondY) * Constants.GEM_HEIGHT },
	}
	for index = 1, #movements do
		local movement = movements[index]
		local animation
		if run.rollback then
			animation = movement.frame.bejeweledSwapRollbackAnimation or CreateSwapAnimation(movement.frame, true)
			animation.returnTranslation:SetDuration(self.swapDuration)
			animation.returnTranslation:SetOffset(-movement.offsetX, -movement.offsetY)
		else
			animation = movement.frame.bejeweledSwapForwardAnimation or CreateSwapAnimation(movement.frame, false)
		end
		animation.outbound:SetDuration(self.swapDuration)
		animation.outbound:SetOffset(movement.offsetX, movement.offsetY)
		groups[#groups + 1] = animation.group
	end

	self:WaitForPhase(run, groups, {}, {}, function()
		self:CompleteRun(run)
	end)
	return run
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
		activeExplosions = {},
		activeLightning = {},
		pending = 0,
		cancelled = false,
		completed = false,
		paused = self.paused,
	}
	self.active = run
	self.gemPool:SetInteractive(false)
	self:SyncPersistentEffects(false)
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
	local explosions = {}
	for explosion in pairs(run.activeExplosions) do
		explosions[#explosions + 1] = explosion
	end
	for index = 1, #explosions do
		self:ReleaseExplosion(explosions[index], false)
	end
	local lightning = {}
	for effect in pairs(run.activeLightning) do
		lightning[#lightning + 1] = effect
	end
	for index = 1, #lightning do
		self:ReleaseLightning(lightning[index], false)
	end
	run.activeGroups = {}
	run.activeExplosions = {}
	run.activeLightning = {}
	run.pending = 0
	self.gemPool:ResetPresentation(run.finalGrid)
	self:SyncPersistentEffects(false)
	self.gemPool:SetInteractive(not self.paused)
	self.active = nil
	if run.callbacks.onCancel then
		run.callbacks.onCancel(run.cancelReason, run)
	end
	return true
end

addon.Animations = Animations
