local _, addon = ...

local Constants = addon.Constants
local Matches = {}
addon.Matches = Matches

local AXIS_HORIZONTAL = "horizontal"
local AXIS_VERTICAL = "vertical"

local function NewMarkRows(grid)
	local rows = {}
	for y = 1, grid.height do
		rows[y] = {}
		for x = 1, grid.width do
			rows[y][x] = {}
		end
	end
	return rows
end

local function AddUniqueCell(cells, seen, cell)
	if not seen[cell] then
		seen[cell] = true
		cells[#cells + 1] = cell
	end
end

local function IsPreferred(cell, options)
	if options.preferredCell == cell then
		return true
	end
	local preferredCells = options.preferredCells
	if preferredCells then
		for index = 1, #preferredCells do
			if preferredCells[index] == cell then
				return true
			end
		end
	end
	return false
end

local function SelectSpecialCell(primaryCells, intersection, options, random, specialKind)
	if intersection then
		if specialKind ~= "hyper" or not intersection.bigStar then
			return intersection
		end
		return primaryCells[random(1, #primaryCells)]
	end
	for index = 1, #primaryCells do
		local cell = primaryCells[index]
		if IsPreferred(cell, options) and (specialKind ~= "hyper" or not cell.bigStar) then
			return cell
		end
	end
	return primaryCells[random(1, #primaryCells)]
end

local function ClassifySpecial(primaryLength, crossLength)
	if crossLength then
		if primaryLength >= 5 or crossLength >= 5 then
			return "hyper"
		end
		return "power"
	end
	if primaryLength >= 5 then
		return "hyper"
	end
	if primaryLength == 4 then
		return "power"
	end
	return nil
end

local function BuildGroup(axis, contents, primaryCells, crossCells, intersection, options, random)
	local cells = {}
	local seen = {}
	for index = 1, #primaryCells do
		AddUniqueCell(cells, seen, primaryCells[index])
	end
	if crossCells then
		for index = 1, #crossCells do
			AddUniqueCell(cells, seen, crossCells[index])
		end
	end

	local specialKind = ClassifySpecial(#primaryCells, crossCells and #crossCells or nil)
	local special
	if specialKind then
		special = {
			kind = specialKind,
			cell = SelectSpecialCell(primaryCells, intersection, options, random, specialKind),
		}
	end

	return {
		axis = axis,
		contents = contents,
		primaryCells = primaryCells,
		crossCells = crossCells,
		intersection = intersection,
		cells = cells,
		clearCount = #cells,
		special = special,
	}
end

local function FindHorizontalCross(grid, x, y, contents)
	local left = x - 1
	while left >= 1 and grid.rows[y][left].contents == contents do
		left = left - 1
	end
	local right = x + 1
	while right <= grid.width and grid.rows[y][right].contents == contents do
		right = right + 1
	end
	if (x - left - 1) + (right - x - 1) < 2 then
		return nil
	end

	local cells = {}
	for scanX = left + 1, right - 1 do
		cells[#cells + 1] = grid.rows[y][scanX]
	end
	return cells
end

local function FindVerticalCross(grid, x, y, contents)
	local top = y - 1
	while top >= 1 and grid.rows[top][x].contents == contents do
		top = top - 1
	end
	local bottom = y + 1
	while bottom <= grid.height and grid.rows[bottom][x].contents == contents do
		bottom = bottom + 1
	end
	if (y - top - 1) + (bottom - y - 1) < 2 then
		return nil
	end

	local cells = {}
	for scanY = top + 1, bottom - 1 do
		cells[#cells + 1] = grid.rows[scanY][x]
	end
	return cells
end

local function AddGroup(result, group)
	result.groups[#result.groups + 1] = group
	for index = 1, #group.cells do
		local cell = group.cells[index]
		if not result.cellSet[cell] then
			result.cellSet[cell] = true
			result.cells[#result.cells + 1] = cell
		end
	end
end

local function ScanVertical(grid, x, y, contents, marks, options, random)
	local primaryCells = {}
	local crossCells
	local intersection
	local scanY = y
	while scanY <= grid.height do
		local cell = grid.rows[scanY][x]
		if cell.contents ~= contents or marks[scanY][x].vertical then
			break
		end
		primaryCells[#primaryCells + 1] = cell
		if not crossCells then
			crossCells = FindHorizontalCross(grid, x, scanY, contents)
			if crossCells then
				intersection = cell
			end
		end
		scanY = scanY + 1
	end

	if #primaryCells < 3 then
		return nil
	end
	for index = 1, #primaryCells do
		local cell = primaryCells[index]
		marks[cell.gridY][cell.gridX].vertical = true
	end
	if crossCells then
		for index = 1, #crossCells do
			local cell = crossCells[index]
			marks[cell.gridY][cell.gridX].horizontal = true
		end
	end
	return BuildGroup(AXIS_VERTICAL, contents, primaryCells, crossCells, intersection, options, random)
end

local function ScanHorizontal(grid, x, y, contents, marks, options, random)
	local primaryCells = {}
	local crossCells
	local intersection
	local scanX = x
	while scanX <= grid.width do
		local cell = grid.rows[y][scanX]
		if cell.contents ~= contents or marks[y][scanX].horizontal then
			break
		end
		primaryCells[#primaryCells + 1] = cell
		if not crossCells then
			crossCells = FindVerticalCross(grid, scanX, y, contents)
			if crossCells then
				intersection = cell
			end
		end
		scanX = scanX + 1
	end

	if #primaryCells < 3 then
		return nil
	end
	for index = 1, #primaryCells do
		local cell = primaryCells[index]
		marks[cell.gridY][cell.gridX].horizontal = true
	end
	if crossCells then
		for index = 1, #crossCells do
			local cell = crossCells[index]
			marks[cell.gridY][cell.gridX].vertical = true
		end
	end
	return BuildGroup(AXIS_HORIZONTAL, contents, primaryCells, crossCells, intersection, options, random)
end

function Matches:Find(grid, options)
	assert(type(grid) == "table" and type(grid.rows) == "table", "match discovery requires a grid")
	options = options or {}
	local random = options.random or grid.random or math.random
	local marks = NewMarkRows(grid)
	local result = {
		hasMatches = false,
		groups = {},
		cells = {},
		cellSet = {},
		marks = marks,
	}

	for y = 1, grid.height do
		for x = 1, grid.width do
			local contents = grid.rows[y][x].contents
			if contents ~= Constants.EMPTY_CONTENTS and contents ~= Constants.HYPER_CONTENTS then
				if y < grid.height then
					local vertical = ScanVertical(grid, x, y, contents, marks, options, random)
					if vertical then
						AddGroup(result, vertical)
					end
				end
				if x < grid.width then
					local horizontal = ScanHorizontal(grid, x, y, contents, marks, options, random)
					if horizontal then
						AddGroup(result, horizontal)
					end
				end
			end
		end
	end

	result.hasMatches = #result.groups > 0
	result.cellCount = #result.cells
	result.cellSet = nil
	return result
end
