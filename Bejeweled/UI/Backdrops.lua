local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local Backdrops = {}

local PRESETS = {
	tooltip = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = 1,
		edgeSize = 16,
		insets = { top = 5, right = 5, left = 5, bottom = 5 },
	},
	window = {
		bgFile = Constants.IMAGE_ROOT .. "windowBackground",
		tileSize = 64,
		edgeFile = Constants.IMAGE_ROOT .. "windowBorder",
		tile = 1,
		edgeSize = 32,
		insets = { top = 5, right = 3, left = 5, bottom = 5 },
	},
	panel = {
		bgFile = Constants.IMAGE_ROOT .. "windowBackground",
		tileSize = 128,
		edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
		tile = 1,
		edgeSize = 32,
		insets = { top = 3, right = 5, left = 5, bottom = 5 },
	},
	slider = {
		bgFile = Constants.IMAGE_ROOT .. "windowBackground",
		tileSize = 64,
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = 1,
		edgeSize = 8,
		insets = { top = 5, right = 2, left = 2, bottom = 5 },
	},
	level = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tileSize = 16,
		edgeFile = Constants.IMAGE_ROOT .. "levelBorder",
		tile = 1,
		edgeSize = 32,
		insets = { top = 5, right = 2, left = 2, bottom = 5 },
	},
}

local function CopyInsets(insets)
	return {
		top = insets.top,
		right = insets.right,
		left = insets.left,
		bottom = insets.bottom,
	}
end

local function CopyDescriptor(descriptor)
	local copy = {}
	for key, value in pairs(descriptor) do
		if key == "insets" then
			copy.insets = CopyInsets(value)
		else
			copy[key] = value
		end
	end
	return copy
end

local function AddBackdropTemplate(template)
	if not template or template == "" then
		return "BackdropTemplate"
	end
	if string.find(template, "BackdropTemplate", 1, true) then
		return template
	end
	return template .. ",BackdropTemplate"
end

local function ApplyColor(frame, methodName, color)
	if not color then
		return
	end
	assert(type(color) == "table", methodName .. " color must be a table")
	assert(type(frame[methodName]) == "function", "frame does not support " .. methodName)
	if color[4] == nil then
		frame[methodName](frame, color[1], color[2], color[3])
	else
		frame[methodName](frame, color[1], color[2], color[3], color[4])
	end
end

function Backdrops:CreateDescriptor(presetName, overrides)
	presetName = presetName or "tooltip"
	local preset = PRESETS[presetName]
	assert(preset, "unknown backdrop preset: " .. tostring(presetName))
	assert(overrides == nil or type(overrides) == "table", "backdrop overrides must be a table")

	local descriptor = CopyDescriptor(preset)
	if overrides then
		for key, value in pairs(overrides) do
			if key == "insets" then
				assert(type(value) == "table", "backdrop inset overrides must be a table")
				for insetName, insetValue in pairs(value) do
					descriptor.insets[insetName] = insetValue
				end
			else
				descriptor[key] = value
			end
		end
	end

	return descriptor
end

function Backdrops:Apply(frame, descriptor, backgroundColor, borderColor)
	assert(frame ~= nil, "backdrop frame is required")
	assert(type(frame.SetBackdrop) == "function", "frame does not support SetBackdrop")
	assert(type(descriptor) == "table", "backdrop descriptor must be a table")

	frame:SetBackdrop(descriptor)
	ApplyColor(frame, "SetBackdropColor", backgroundColor)
	ApplyColor(frame, "SetBackdropBorderColor", borderColor)
	return frame
end

function Backdrops:CreateFrame(options)
	options = options or {}
	assert(type(options) == "table", "backdrop frame options must be a table")

	local createFrame = options.createFrame or CreateFrame
	assert(type(createFrame) == "function", "CreateFrame is unavailable")
	local descriptor = options.descriptor or self:CreateDescriptor(options.preset, options.overrides)
	local frame = createFrame(
		options.frameType or "Frame",
		options.name,
		options.parent,
		AddBackdropTemplate(options.template)
	)

	self:Apply(frame, descriptor, options.backgroundColor, options.borderColor)
	return frame, descriptor
end

Backdrops.PresetNames = {
	"tooltip",
	"window",
	"panel",
	"slider",
	"level",
}

addon.Backdrops = Backdrops
