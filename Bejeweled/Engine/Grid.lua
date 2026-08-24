local _, addon = ...

local Constants = addon.Constants
local Grid = {}
Grid.__index = Grid
addon.Grid = Grid

local CARDINAL_OFFSETS = {
	{ Constants.NEIGHBOR_SCAN_PATTERNS[1][1], Constants.NEIGHBOR_SCAN_PATTERNS[1][3] },
	{ Constants.NEIGHBOR_SCAN_PATTERNS[2][1], Constants.NEIGHBOR_SCAN_PATTERNS[2][3] },
	{ Constants.NEIGHBOR_SCAN_PATTERNS[3][1], Constants.NEIGHBOR_SCAN_PATTERNS[3][3] },
	{ Constants.NEIGHBOR_SCAN_PATTERNS[4][1], Constants.NEIGHBOR_SCAN_PATTERNS[4][3] },
}

local function IsInteger(value)
	return type(value) == "number" and value == math.floor(value)
end

local function ValidateContents(contents, bigStar)
	if not IsInteger(contents) then
		return nil, "gem contents must be an integer"
	end
	if contents ~= Constants.EMPTY_CONTENTS
		and contents ~= Constants.HYPER_CONTENTS
		and (contents < 1 or contents > Constants.GEM_COLOR_COUNT) then
		return nil, "gem contents are outside the supported wire range"
	end
	if bigStar and (contents < 1 or contents > Constants.GEM_COLOR_COUNT) then
		return nil, "only colored gems can carry a big star"
	end
	return true
end

function Grid:New(randomFunction)
	local grid = setmetatable({
		width = Constants.GRID_WIDTH,
		height = Constants.GRID_HEIGHT,
		random = randomFunction or math.random,
		rows = {},
	}, self)
	grid:Reset()
	return grid
end

function Grid:Reset()
	for y = 1, self.height do
		local row = self.rows[y] or {}
		self.rows[y] = row
		for x = 1, self.width do
			local cell = row[x] or {}
			row[x] = cell
			cell.gridX = x
			cell.gridY = y
			cell.contents = Constants.EMPTY_CONTENTS
			cell.bigStar = nil
		end
	end
	return self
end

function Grid:IsInBounds(x, y)
	return IsInteger(x) and IsInteger(y) and x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function Grid:Get(x, y)
	if not self:IsInBounds(x, y) then
		return nil
	end
	return self.rows[y][x]
end

function Grid:Set(x, y, contents, bigStar)
	assert(self:IsInBounds(x, y), "grid coordinates are out of bounds")
	local valid, reason = ValidateContents(contents, bigStar)
	assert(valid, reason)

	local cell = self.rows[y][x]
	cell.contents = contents
	cell.bigStar = bigStar and true or nil
	return cell
end

function Grid:AreAdjacent(x1, y1, x2, y2)
	if not self:IsInBounds(x1, y1) or not self:IsInBounds(x2, y2) then
		return false
	end
	return math.abs(x1 - x2) + math.abs(y1 - y2) == 1
end

function Grid:Swap(x1, y1, x2, y2)
	assert(self:AreAdjacent(x1, y1, x2, y2), "grid swap requires orthogonally adjacent cells")
	local first = self.rows[y1][x1]
	local second = self.rows[y2][x2]

	first.contents, second.contents = second.contents, first.contents
	first.bigStar, second.bigStar = second.bigStar, first.bigStar
	return first, second
end

function Grid:HasMatchAt(x, y)
	local cell = self:Get(x, y)
	if not cell or cell.contents == Constants.EMPTY_CONTENTS or cell.contents == Constants.HYPER_CONTENTS then
		return false
	end

	local contents = cell.contents
	local horizontal = 1
	local vertical = 1
	local scanX = x - 1
	while scanX >= 1 and self.rows[y][scanX].contents == contents do
		horizontal = horizontal + 1
		scanX = scanX - 1
	end
	scanX = x + 1
	while scanX <= self.width and self.rows[y][scanX].contents == contents do
		horizontal = horizontal + 1
		scanX = scanX + 1
	end

	local scanY = y - 1
	while scanY >= 1 and self.rows[scanY][x].contents == contents do
		vertical = vertical + 1
		scanY = scanY - 1
	end
	scanY = y + 1
	while scanY <= self.height and self.rows[scanY][x].contents == contents do
		vertical = vertical + 1
		scanY = scanY + 1
	end

	return horizontal >= 3 or vertical >= 3
end

function Grid:HasAnyMatch()
	for y = 1, self.height do
		for x = 1, self.width do
			if self:HasMatchAt(x, y) then
				return true
			end
		end
	end
	return false
end

function Grid:IsLegalSwap(x1, y1, x2, y2)
	if not self:AreAdjacent(x1, y1, x2, y2) then
		return false
	end

	local first = self.rows[y1][x1]
	local second = self.rows[y2][x2]
	if first.contents == Constants.EMPTY_CONTENTS or second.contents == Constants.EMPTY_CONTENTS then
		return false
	end
	if first.contents == Constants.HYPER_CONTENTS or second.contents == Constants.HYPER_CONTENTS then
		return true
	end

	self:Swap(x1, y1, x2, y2)
	local legal = self:HasMatchAt(x1, y1) or self:HasMatchAt(x2, y2)
	self:Swap(x1, y1, x2, y2)
	return legal
end

function Grid:FindLegalMove()
	for y = 1, self.height do
		for x = 1, self.width do
			for index = 1, #CARDINAL_OFFSETS do
				local offset = CARDINAL_OFFSETS[index]
				local neighborX = x + offset[1]
				local neighborY = y + offset[2]
				if self:IsLegalSwap(x, y, neighborX, neighborY) then
					return self.rows[y][x], self.rows[neighborY][neighborX]
				end
			end
		end
	end
	return nil
end

function Grid:WouldCreateInitialMatch(x, y, contents)
	if x > 2
		and self.rows[y][x - 1].contents == contents
		and self.rows[y][x - 2].contents == contents then
		return true
	end
	if y > 2
		and self.rows[y - 1][x].contents == contents
		and self.rows[y - 2][x].contents == contents then
		return true
	end
	return false
end

function Grid:Fill(randomFunction, maximumAttempts)
	local random = randomFunction or self.random
	maximumAttempts = maximumAttempts or 200

	for attempt = 1, maximumAttempts do
		self:Reset()
		for y = 1, self.height do
			for x = 1, self.width do
				local initialContents = random(1, Constants.GEM_COLOR_COUNT)
				local contents = initialContents
				for offset = 0, Constants.GEM_COLOR_COUNT - 1 do
					contents = ((initialContents + offset - 1) % Constants.GEM_COLOR_COUNT) + 1
					if not self:WouldCreateInitialMatch(x, y, contents) then
						break
					end
				end
				self.rows[y][x].contents = contents
			end
		end
		if self:FindLegalMove() then
			return true, attempt
		end
	end

	self:Reset()
	return nil, "unable to generate a board with a legal move"
end

function Grid:DecodeLegacyValue(value)
	if not IsInteger(value) then
		return nil, nil, "legacy cell value must be an integer"
	end
	if value == Constants.HYPER_CONTENTS then
		return value, nil
	end
	if value >= 0 and value <= Constants.GEM_COLOR_COUNT then
		return value, nil
	end
	if value > Constants.BIG_STAR_WIRE_OFFSET
		and value <= Constants.BIG_STAR_WIRE_OFFSET + Constants.GEM_COLOR_COUNT then
		return value - Constants.BIG_STAR_WIRE_OFFSET, true
	end
	return nil, nil, "legacy cell value is outside the supported wire range"
end

function Grid:EncodeLegacyValue(cell)
	local valid, reason = ValidateContents(cell.contents, cell.bigStar)
	assert(valid, reason)
	if cell.bigStar then
		return cell.contents + Constants.BIG_STAR_WIRE_OFFSET
	end
	return cell.contents
end

function Grid:LoadLegacyBoard(savedRows)
	assert(type(savedRows) == "table", "legacy board must be a table")
	local decodedRows = {}
	for y = 1, self.height do
		assert(type(savedRows[y]) == "table", "legacy board row is missing")
		decodedRows[y] = {}
		for x = 1, self.width do
			local contents, bigStar, reason = self:DecodeLegacyValue(savedRows[y][x])
			assert(contents ~= nil, reason)
			decodedRows[y][x] = { contents = contents, bigStar = bigStar }
		end
	end

	for y = 1, self.height do
		for x = 1, self.width do
			local decoded = decodedRows[y][x]
			self:Set(x, y, decoded.contents, decoded.bigStar)
		end
	end
	return self
end

function Grid:ExportLegacyBoard()
	local savedRows = {}
	for y = 1, self.height do
		savedRows[y] = {}
		for x = 1, self.width do
			savedRows[y][x] = self:EncodeLegacyValue(self.rows[y][x])
		end
	end
	return savedRows
end
