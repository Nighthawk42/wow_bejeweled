local _, addon = ...

local Constants = addon.Constants
local Matches = addon.Matches
local Cascade = {}
addon.Cascade = Cascade

local function SnapshotGrid(grid)
	local snapshot = {}
	for y = 1, grid.height do
		snapshot[y] = {}
		for x = 1, grid.width do
			local cell = grid.rows[y][x]
			snapshot[y][x] = {
				contents = cell.contents,
				bigStar = cell.bigStar,
			}
		end
	end
	return snapshot
end

local function RestoreGrid(grid, snapshot)
	for y = 1, grid.height do
		for x = 1, grid.width do
			local saved = snapshot[y][x]
			grid:Set(x, y, saved.contents, saved.bigStar)
		end
	end
end

local function IsGridCell(grid, cell)
	return type(cell) == "table"
		and grid:IsInBounds(cell.gridX, cell.gridY)
		and grid.rows[cell.gridY][cell.gridX] == cell
end

local function ValidateMatchResult(grid, matchResult)
	assert(type(matchResult) == "table", "cascade step requires a match result")
	assert(type(matchResult.groups) == "table" and type(matchResult.cells) == "table", "match result is incomplete")
	assert(matchResult.hasMatches == (#matchResult.groups > 0), "match result flag is inconsistent")
	for index = 1, #matchResult.cells do
		local cell = matchResult.cells[index]
		assert(IsGridCell(grid, cell), "match result contains a foreign grid cell")
		assert(cell.contents ~= Constants.EMPTY_CONTENTS, "match result is stale")
	end
	for groupIndex = 1, #matchResult.groups do
		local group = matchResult.groups[groupIndex]
		assert(type(group.cells) == "table" and #group.cells >= 3, "match group is incomplete")
		for cellIndex = 1, #group.cells do
			local cell = group.cells[cellIndex]
			assert(IsGridCell(grid, cell) and cell.contents == group.contents, "match group is stale")
		end
		if group.special then
			assert(IsGridCell(grid, group.special.cell), "special target is a foreign grid cell")
		end
	end
end

local function AddClearCell(clearCells, clearSet, cell)
	if cell.contents ~= Constants.EMPTY_CONTENTS and not clearSet[cell] then
		clearSet[cell] = true
		clearCells[#clearCells + 1] = cell
		return true
	end
	return false
end

local function SummarizeMatchAwards(matchResult)
	local awards = {}
	for groupIndex = 1, #matchResult.groups do
		local group = matchResult.groups[groupIndex]
		local powerCells = {}
		for cellIndex = 1, #group.primaryCells do
			local cell = group.primaryCells[cellIndex]
			if cell.bigStar then
				powerCells[#powerCells + 1] = cell
			end
		end
		if group.crossCells then
			for cellIndex = 1, #group.crossCells do
				local cell = group.crossCells[cellIndex]
				if cell.bigStar then
					powerCells[#powerCells + 1] = cell
				end
			end
		end
		local origin = group.primaryCells[1]
		awards[groupIndex] = {
			groupIndex = groupIndex,
			contents = group.contents,
			matchLength = group.clearCount,
			hasIntersection = group.crossCells ~= nil,
			specialKind = group.special and group.special.kind or nil,
			originX = origin.gridX,
			originY = origin.gridY,
			powerCells = powerCells,
			powerTriggerCount = #powerCells,
		}
	end
	return awards
end

local function PlanSpecials(matchResult)
	local plans = {}
	local byCell = {}
	local suppressed = {}
	for groupIndex = 1, #matchResult.groups do
		local group = matchResult.groups[groupIndex]
		local special = group.special
		if special then
			local cell = special.cell
			local plan = {
				groupIndex = groupIndex,
				kind = special.kind,
				contents = group.contents,
				cell = cell,
				createdX = cell.gridX,
				createdY = cell.gridY,
			}
			if cell.bigStar then
				plan.reason = "existing-power-gem"
				suppressed[#suppressed + 1] = plan
			else
				local existing = byCell[cell]
				if not existing then
					byCell[cell] = plan
					plans[#plans + 1] = plan
				elseif existing.kind ~= "power" and plan.kind == "power" then
					existing.reason = "power-gem-priority"
					suppressed[#suppressed + 1] = existing
					byCell[cell] = plan
					for index = 1, #plans do
						if plans[index] == existing then
							plans[index] = plan
							break
						end
					end
				else
					plan.reason = "special-target-collision"
					suppressed[#suppressed + 1] = plan
				end
			end
		end
	end
	return plans, byCell, suppressed
end

local function ExpandPowerGemClears(grid, clearCells, clearSet)
	local queue = {}
	local queued = {}
	local triggered = {}
	for index = 1, #clearCells do
		local cell = clearCells[index]
		if cell.bigStar and not queued[cell] then
			queued[cell] = true
			queue[#queue + 1] = cell
		end
	end

	local queueIndex = 1
	while queueIndex <= #queue do
		local powerCell = queue[queueIndex]
		queueIndex = queueIndex + 1
		triggered[#triggered + 1] = powerCell
		for y = powerCell.gridY - 1, powerCell.gridY + 1 do
			for x = powerCell.gridX - 1, powerCell.gridX + 1 do
				if grid:IsInBounds(x, y) then
					local cell = grid.rows[y][x]
					AddClearCell(clearCells, clearSet, cell)
					if cell.bigStar and not queued[cell] then
						queued[cell] = true
						queue[#queue + 1] = cell
					end
				end
			end
		end
	end
	return triggered
end

local function ApplyClears(grid, clearCells, specialByCell)
	local removed = {}
	for index = 1, #clearCells do
		local cell = clearCells[index]
		if not specialByCell[cell] then
			removed[#removed + 1] = {
				cell = cell,
				x = cell.gridX,
				y = cell.gridY,
				contents = cell.contents,
				bigStar = cell.bigStar and true or nil,
			}
			grid:Set(cell.gridX, cell.gridY, Constants.EMPTY_CONTENTS)
		end
	end
	return removed
end

local function ApplySpecials(grid, plans)
	local occupants = {}
	for index = 1, #plans do
		local plan = plans[index]
		if plan.kind == "power" then
			grid:Set(plan.cell.gridX, plan.cell.gridY, plan.contents, true)
		elseif plan.kind == "hyper" then
			grid:Set(plan.cell.gridX, plan.cell.gridY, Constants.HYPER_CONTENTS)
		else
			error("unsupported special-gem kind")
		end
		occupants[plan.cell] = plan
	end
	return occupants
end

local function CompactColumns(grid, specialOccupants)
	local moves = {}
	for x = 1, grid.width do
		local writeY = grid.height
		for readY = grid.height, 1, -1 do
			local source = grid.rows[readY][x]
			if source.contents ~= Constants.EMPTY_CONTENTS then
				if readY ~= writeY then
					local destination = grid.rows[writeY][x]
					moves[#moves + 1] = {
						fromCell = source,
						toCell = destination,
						fromX = x,
						fromY = readY,
						toX = x,
						toY = writeY,
						distance = writeY - readY,
						contents = source.contents,
						bigStar = source.bigStar and true or nil,
					}
					grid:Set(x, writeY, source.contents, source.bigStar)
					grid:Set(x, readY, Constants.EMPTY_CONTENTS)
					local special = specialOccupants[source]
					if special then
						specialOccupants[source] = nil
						specialOccupants[destination] = special
						special.cell = destination
					end
				end
				writeY = writeY - 1
			end
		end
	end
	return moves
end

local function CollectRefillCells(grid)
	local cells = {}
	for x = 1, grid.width do
		for y = grid.height, 1, -1 do
			local cell = grid.rows[y][x]
			if cell.contents == Constants.EMPTY_CONTENTS then
				cells[#cells + 1] = cell
			end
		end
	end
	return cells
end

local function Refill(grid, cells, random, requireLegalMove, maximumAttempts)
	if #cells == 0 then
		return {}, 0
	end
	for attempt = 1, maximumAttempts do
		for index = 1, #cells do
			local cell = cells[index]
			grid:Set(cell.gridX, cell.gridY, random(1, Constants.GEM_COLOR_COUNT))
		end
		if not requireLegalMove or grid:FindLegalMove() then
			local refills = {}
			for index = 1, #cells do
				local cell = cells[index]
				refills[index] = {
					cell = cell,
					x = cell.gridX,
					y = cell.gridY,
					contents = cell.contents,
				}
			end
			return refills, attempt
		end
		for index = 1, #cells do
			local cell = cells[index]
			grid:Set(cell.gridX, cell.gridY, Constants.EMPTY_CONTENTS)
		end
	end
	error("unable to refill the board with a legal move")
end

local function RunStep(grid, matchResult, options)
	ValidateMatchResult(grid, matchResult)
	assert(matchResult.hasMatches, "cascade step requires at least one match")
	local random = options.random or grid.random or math.random
	local maximumRefillAttempts = options.maximumRefillAttempts or 200
	assert(type(maximumRefillAttempts) == "number" and maximumRefillAttempts >= 1, "refill attempt limit must be positive")

	local clearCells = {}
	local clearSet = {}
	local matchAwards = SummarizeMatchAwards(matchResult)
	for index = 1, #matchResult.cells do
		AddClearCell(clearCells, clearSet, matchResult.cells[index])
	end
	local specials, specialByCell, suppressedSpecials = PlanSpecials(matchResult)
	local triggeredPowerCells = ExpandPowerGemClears(grid, clearCells, clearSet)
	local triggeredPowerRecords = {}
	for index = 1, #triggeredPowerCells do
		local cell = triggeredPowerCells[index]
		triggeredPowerRecords[index] = {
			cell = cell,
			x = cell.gridX,
			y = cell.gridY,
			contents = cell.contents,
		}
	end
	local removedCells = ApplyClears(grid, clearCells, specialByCell)
	local specialOccupants = ApplySpecials(grid, specials)
	local moves = CompactColumns(grid, specialOccupants)
	local refillCells = CollectRefillCells(grid)
	local refills, refillAttempts = Refill(
		grid,
		refillCells,
		random,
		options.requireLegalMove ~= false,
		maximumRefillAttempts
	)
	local nextMatches = Matches:Find(grid, { random = random })

	return {
		matches = matchResult,
		matchAwards = matchAwards,
		matchedCellCount = matchResult.cellCount,
		clearCells = clearCells,
		clearCount = #clearCells,
		removedCells = removedCells,
		removedCount = #removedCells,
		triggeredPowerCells = triggeredPowerCells,
		triggeredPowerRecords = triggeredPowerRecords,
		triggeredPowerCount = #triggeredPowerCells,
		spawnedSpecials = specials,
		suppressedSpecials = suppressedSpecials,
		moves = moves,
		refills = refills,
		refillAttempts = refillAttempts,
		nextMatches = nextMatches,
		hasNextCascade = nextMatches.hasMatches,
	}
end

function Cascade:Step(grid, matchResult, options)
	assert(type(grid) == "table" and type(grid.rows) == "table", "cascade step requires a grid")
	options = options or {}
	local snapshot = SnapshotGrid(grid)
	local succeeded, result = pcall(function()
		return RunStep(grid, matchResult, options)
	end)
	if not succeeded then
		RestoreGrid(grid, snapshot)
		error(result, 0)
	end
	return result
end

local function RunResolve(cascade, grid, options)
	local random = options.random or grid.random or math.random
	local maximumCascades = options.maximumCascades or 100
	assert(type(maximumCascades) == "number" and maximumCascades >= 1, "cascade limit must be positive")
	local matches = options.initialMatches or Matches:Find(grid, {
		preferredCell = options.preferredCell,
		preferredCells = options.preferredCells,
		random = random,
	})
	local result = {
		steps = {},
		cascadeCount = 0,
		totalMatched = 0,
		totalRemoved = 0,
		totalPowerTriggers = 0,
	}

	while matches.hasMatches do
		if result.cascadeCount >= maximumCascades then
			error("cascade limit exceeded")
		end
		local step = cascade:Step(grid, matches, {
			random = random,
			requireLegalMove = options.requireLegalMove,
			maximumRefillAttempts = options.maximumRefillAttempts,
		})
		result.steps[#result.steps + 1] = step
		result.cascadeCount = result.cascadeCount + 1
		result.totalMatched = result.totalMatched + step.matchedCellCount
		result.totalRemoved = result.totalRemoved + step.removedCount
		result.totalPowerTriggers = result.totalPowerTriggers + step.triggeredPowerCount
		matches = step.nextMatches
	end

	result.finalMatches = matches
	result.stable = true
	return result
end

function Cascade:Resolve(grid, options)
	assert(type(grid) == "table" and type(grid.rows) == "table", "cascade resolution requires a grid")
	options = options or {}
	local snapshot = SnapshotGrid(grid)
	local succeeded, result = pcall(function()
		return RunResolve(self, grid, options)
	end)
	if not succeeded then
		RestoreGrid(grid, snapshot)
		error(result, 0)
	end
	return result
end
