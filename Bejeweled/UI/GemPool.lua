local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local GemPool = {}
GemPool.__index = GemPool

local HIDDEN_TEX_COORD = { 0, 0, 0, 0 }
local FULL_TEX_COORD = { 0, 1, 0, 1 }
local GEM_IDLE_TEX_COORD = { 0, 49 / 255, 0, 49 / 255 }
local HYPER_IDLE_TEX_COORD = { 0, 0.1, 0, 0.19999 }
local BOARD_TEX_COORD = { 0.046875, 0.828125, 0.046875, 0.828125 }

local SCRIPT_NAMES = {
	onEnter = "OnEnter",
	onLeave = "OnLeave",
	onMouseDown = "OnMouseDown",
	onDragStart = "OnDragStart",
}

local function SetTexCoord(texture, coordinates)
	texture:SetTexCoord(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
end

local function SetTextureSize(texture, width, height)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

local function SetFrameSize(frame, width, height)
	frame:SetWidth(width)
	frame:SetHeight(height)
end

local function ResolveFrameLevel(parent, frameLevel, offset)
	if frameLevel ~= nil then
		return frameLevel
	end
	if parent and type(parent.GetFrameLevel) == "function" then
		return parent:GetFrameLevel() + (offset or 0)
	end
	return nil
end

function GemPool:New(parent, options)
	assert(parent ~= nil, "gem pool parent is required")
	options = options or {}
	assert(type(options) == "table", "gem pool options must be a table")

	local instance = setmetatable({}, self)
	instance.parent = parent
	instance.createFrame = options.createFrame or CreateFrame
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable")
	instance.frameLevel = ResolveFrameLevel(parent, options.frameLevel, 2)
	instance.tileFrameLevel = ResolveFrameLevel(parent, options.tileFrameLevel, 0)
	instance.handlers = options.handlers or {}
	assert(type(instance.handlers) == "table", "gem handlers must be a table")
	instance.frames = {}
	instance.tiles = {}

	if options.createBoardTiles ~= false then
		instance:CreateBoardTiles()
	end
	instance:AllocateFrames()

	return instance
end

function GemPool:CreateBoardTiles()
	if #self.tiles > 0 then
		return self.tiles
	end

	local tileWidth = Constants.GRID_WIDTH * Constants.GEM_WIDTH / 4
	local tileHeight = Constants.GRID_HEIGHT * Constants.GEM_HEIGHT / 4
	for tileRow = 0, 3 do
		for tileColumn = 0, 3 do
			local frame = self.createFrame("Frame", nil, self.parent)
			frame:SetPoint("TOPLEFT", tileColumn * tileWidth, -(tileRow * tileHeight))
			SetFrameSize(frame, tileWidth, tileHeight)
			frame.texture = frame:CreateTexture(nil, "BACKGROUND")
			SetTextureSize(frame.texture, tileWidth, tileHeight)
			frame.texture:SetPoint("CENTER")
			frame.texture:SetTexture(Constants.IMAGE_ROOT .. "board")
			SetTexCoord(frame.texture, BOARD_TEX_COORD)
			frame.texture:Show()
			frame:SetAlpha(0.8)
			if self.tileFrameLevel ~= nil then
				frame:SetFrameLevel(self.tileFrameLevel)
			end
			frame:Show()
			self.tiles[#self.tiles + 1] = frame
		end
	end

	return self.tiles
end

function GemPool:CreateGemFrame(column, row)
	local x = (column - 1) * Constants.GEM_WIDTH
	local y = (row - 1) * Constants.GEM_HEIGHT
	local frame = self.createFrame("Frame", nil, self.parent)
	frame:SetPoint("TOPLEFT", x, -y)
	SetFrameSize(frame, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
	frame.x = x
	frame.y = y
	frame.gridX = column
	frame.gridY = row
	frame.contents = Constants.EMPTY_CONTENTS
	frame.projectedContents = Constants.EMPTY_CONTENTS
	frame.projectedBigStar = false
	frame.glowLevel = 0

	frame.texture = frame:CreateTexture(nil, "ARTWORK")
	SetTextureSize(frame.texture, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
	frame.texture:SetPoint("CENTER")
	frame.texture:SetTexture(Constants.IMAGE_ROOT .. "gem_yellow")
	SetTexCoord(frame.texture, HIDDEN_TEX_COORD)
	frame.texture:Show()

	frame.highlight = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(frame.highlight, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
	frame.highlight:SetPoint("CENTER")
	frame.highlight:SetTexture(Constants.IMAGE_ROOT .. "shine_yellow")
	frame.highlight:SetBlendMode("ADD")
	SetTexCoord(frame.highlight, HIDDEN_TEX_COORD)
	frame.highlight:Show()

	frame.selector = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(frame.selector, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
	frame.selector:SetPoint("CENTER")
	frame.selector:SetTexture(Constants.IMAGE_ROOT .. "selector")
	frame.selector:Hide()

	frame.glow = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(frame.glow, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
	frame.glow:SetPoint("TOPLEFT", frame.texture)
	frame.glow:SetPoint("BOTTOMRIGHT", frame.texture)
	frame.glow:SetAlpha(0)
	SetTexCoord(frame.glow, HIDDEN_TEX_COORD)

	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	if self.frameLevel ~= nil then
		frame:SetFrameLevel(self.frameLevel)
	end
	for handlerName, scriptName in pairs(SCRIPT_NAMES) do
		local handler = self.handlers[handlerName]
		if handler then
			assert(type(handler) == "function", handlerName .. " handler must be a function")
			frame:SetScript(scriptName, handler)
		end
	end
	frame:SetAlpha(1)
	frame:Show()

	return frame
end

function GemPool:AllocateFrames()
	if #self.frames > 0 then
		return self.frames
	end

	for row = 1, Constants.GRID_HEIGHT do
		self.frames[row] = {}
		for column = 1, Constants.GRID_WIDTH do
			self.frames[row][column] = self:CreateGemFrame(column, row)
		end
	end

	return self.frames
end

function GemPool:GetFrame(column, row)
	assert(type(column) == "number" and column == math.floor(column) and column >= 1 and column <= Constants.GRID_WIDTH, "gem column is out of bounds")
	assert(type(row) == "number" and row == math.floor(row) and row >= 1 and row <= Constants.GRID_HEIGHT, "gem row is out of bounds")
	return self.frames[row][column]
end

function GemPool:RenderCell(column, row, cell, force)
	assert(type(cell) == "table", "projected grid cell must be a table")
	local frame = self:GetFrame(column, row)
	local contents = cell.contents or Constants.EMPTY_CONTENTS
	assert(type(contents) == "number", "projected gem contents must be a number")
	local bigStar = cell.bigStar and true or false
	if not force and frame.projectedContents == contents and frame.projectedBigStar == bigStar then
		return false, frame
	end

	frame.contents = contents
	frame.projectedContents = contents
	frame.projectedBigStar = bigStar
	if contents >= 1 and contents <= Constants.GEM_COLOR_COUNT then
		local textureName = assert(Constants.GEM_COLOR_TEXTURE_NAMES[contents], "gem color texture is unavailable")
		frame.texture:SetTexture(Constants.IMAGE_ROOT .. "gem_" .. textureName)
		SetTexCoord(frame.texture, GEM_IDLE_TEX_COORD)
		frame.highlight:SetTexture(Constants.IMAGE_ROOT .. "shine_" .. textureName)
		SetTexCoord(frame.highlight, HIDDEN_TEX_COORD)
		frame.glow:SetTexture(Constants.IMAGE_ROOT .. "highlight_" .. textureName)
		SetTexCoord(frame.glow, FULL_TEX_COORD)
	elseif contents == Constants.HYPER_CONTENTS then
		frame.texture:SetTexture(Constants.IMAGE_ROOT .. "hypergem")
		SetTexCoord(frame.texture, HYPER_IDLE_TEX_COORD)
		frame.highlight:SetTexture(Constants.IMAGE_ROOT .. "shine_white")
		SetTexCoord(frame.highlight, HIDDEN_TEX_COORD)
		SetTexCoord(frame.glow, HIDDEN_TEX_COORD)
	else
		assert(contents == Constants.EMPTY_CONTENTS, "unsupported projected gem contents: " .. tostring(contents))
		SetTexCoord(frame.texture, HIDDEN_TEX_COORD)
		SetTexCoord(frame.highlight, HIDDEN_TEX_COORD)
		SetTexCoord(frame.glow, HIDDEN_TEX_COORD)
	end

	return true, frame
end

function GemPool:ResetPresentation(grid)
	self.selectedFrame = nil
	for row = 1, Constants.GRID_HEIGHT do
		for column = 1, Constants.GRID_WIDTH do
			local frame = self.frames[row][column]
			frame.x = (column - 1) * Constants.GEM_WIDTH
			frame.y = (row - 1) * Constants.GEM_HEIGHT
			frame.gridX = column
			frame.gridY = row
			frame.contents = Constants.EMPTY_CONTENTS
			frame.projectedContents = nil
			frame.projectedBigStar = nil
			frame.glowLevel = 0
			frame.selector:Hide()
			frame.glow:SetAlpha(0)
			SetTexCoord(frame.texture, HIDDEN_TEX_COORD)
			SetTexCoord(frame.highlight, HIDDEN_TEX_COORD)
			SetTexCoord(frame.glow, HIDDEN_TEX_COORD)
			SetFrameSize(frame, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
			SetTextureSize(frame.texture, Constants.GEM_WIDTH, Constants.GEM_HEIGHT)
			frame:SetAlpha(1)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", frame.x, -frame.y)
			frame:Show()
		end
	end

	if grid then
		return self:Project(grid, true)
	end
	return { changedCount = 0, changes = {} }
end

function GemPool:SetSelection(column, row)
	if self.selectedFrame then
		self.selectedFrame.selector:Hide()
		self.selectedFrame = nil
	end
	if column == nil and row == nil then
		return nil
	end
	assert(column ~= nil and row ~= nil, "gem selection requires both coordinates")
	local frame = self:GetFrame(column, row)
	frame.selector:Show()
	self.selectedFrame = frame
	return frame
end

function GemPool:Project(grid, force)
	assert(type(grid) == "table" and type(grid.Get) == "function", "gem projection requires a grid")
	local changes = {}
	for row = 1, Constants.GRID_HEIGHT do
		for column = 1, Constants.GRID_WIDTH do
			local cell = grid:Get(column, row)
			local changed, frame = self:RenderCell(column, row, cell, force)
			if changed then
				changes[#changes + 1] = {
					column = column,
					row = row,
					contents = frame.contents,
					bigStar = frame.projectedBigStar,
					frame = frame,
				}
			end
		end
	end

	return {
		changedCount = #changes,
		changes = changes,
	}
end

function GemPool:SetHandlers(handlers)
	assert(type(handlers) == "table", "gem handlers must be a table")
	self.handlers = handlers
	for row = 1, Constants.GRID_HEIGHT do
		for column = 1, Constants.GRID_WIDTH do
			local frame = self.frames[row][column]
			for handlerName, scriptName in pairs(SCRIPT_NAMES) do
				local handler = handlers[handlerName]
				assert(handler == nil or type(handler) == "function", handlerName .. " handler must be a function")
				frame:SetScript(scriptName, handler)
			end
		end
	end
end

function GemPool:SetInteractive(enabled)
	for row = 1, Constants.GRID_HEIGHT do
		for column = 1, Constants.GRID_WIDTH do
			self.frames[row][column]:EnableMouse(enabled and true or false)
		end
	end
end

addon.GemPool = GemPool
