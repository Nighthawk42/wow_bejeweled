local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local Legal = {}
Legal.__index = Legal

local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"
local NOTICE = "(c) 2000, 2008 PopCap Games, Inc. All rights reserved. This application is made available free of charge for personal, non-commercial entertainment use and is provided as is, without warranties. PopCap Games, Inc. has no liability to you or anyone else if you choose to use it.\n\nThe community modernization code is distributed under the repository MIT License. Original artwork, audio, names, and acknowledgements retain their respective ownership and attribution."

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled legal font could not be loaded")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

function Legal:CreateFrame(parent, preset, width, height, levelOffset, frameType)
	local frame = Backdrops:CreateFrame({
		frameType = frameType,
		parent = parent,
		preset = preset,
		createFrame = self.createFrame,
		backgroundColor = { 0.08, 0.08, 0.08, 0.99 },
		borderColor = { 1, 0.8, 0.45, 1 },
	})
	frame:SetWidth(width)
	frame:SetHeight(height)
	if type(parent.GetFrameLevel) == "function" then
		frame:SetFrameLevel(parent:GetFrameLevel() + (levelOffset or 1))
	end
	return frame
end

function Legal:New(parent, options)
	assert(parent ~= nil, "legal parent is required")
	options = options or {}
	assert(type(options.accountData) == "table", "legal notice requires account data")
	assert(type(options.onAcknowledge) == "function", "legal notice requires an acknowledgement callback")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		accountData = options.accountData,
		onAcknowledge = options.onAcknowledge,
		visible = false,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for legal notice")

	local frame = instance:CreateFrame(parent, "panel", 400, 400, 25)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	frame:EnableMouse(true)
	frame:Hide()
	frame.title = CreateFontString(frame, 22, "Bejeweled", { 1, 0.85, 0.1, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -28)
	frame.subtitle = CreateFontString(frame, 12, "Legal Notice", { 1, 1, 1, 1 })
	frame.subtitle:SetPoint("TOP", frame.title, "BOTTOM", 0, -5)
	frame.text = CreateFontString(frame, 11, NOTICE, { 1, 1, 1, 1 })
	frame.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 35, -92)
	frame.text:SetWidth(330)
	frame.text:SetJustifyH("LEFT")
	instance.frame = frame

	instance.okayButton = instance:CreateFrame(frame, "tooltip", 140, 30, 2, "Button")
	instance.okayButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 22)
	instance.okayButton:EnableMouse(true)
	instance.okayButton.label = CreateFontString(instance.okayButton, 12, "Okay", { 1, 0.85, 0, 1 })
	instance.okayButton.label:SetPoint("CENTER", instance.okayButton, "CENTER", 0, 0)
	instance.okayButton:SetScript("OnClick", function()
		instance.accountData.legalDisplayed = true
		return instance.onAcknowledge(instance)
	end)
	return instance
end

function Legal:Show()
	self.frame:Show()
	self.visible = true
	return self
end

function Legal:Hide()
	self.frame:Hide()
	self.visible = false
	return self
end

function Legal:IsShown()
	return self.visible
end

Legal.NOTICE = NOTICE

addon.Legal = Legal
