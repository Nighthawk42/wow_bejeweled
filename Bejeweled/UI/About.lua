local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local About = {}
About.__index = About

local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"
local VALID_TABS = { tutorial = true, story = true, credits = true }

local CONTENT = {
	tutorial = {
		title = "How to Play",
		text = "|cFFFF9922Swap adjacent gems to make sets of 3!|r\n\n"
			.. "Match 4 gems to create a |cFF0070DD[Power Gem]|r. "
			.. "Its explosion clears nearby gems when matched.\n\n"
			.. "Match 5 gems to create a |cFFA335EE[Hyper Cube]|r. "
			.. "Swap it with a gem to clear every gem of that color.\n\n"
			.. "Longer cascades, larger clears, and special gems build score and Bejeweling Skill.",
	},
	story = {
		title = "The PopCap Story",
		text = "Many PopCap employees were also dedicated World of Warcraft players who played Bejeweled during long flights and queues. "
			.. "When they learned the game could be implemented as an addon, the PopCap guild began building a game within the game.\n\n"
			.. "This modernization preserves that work for current Retail clients while retaining the original gameplay evidence and assets.\n\n"
			.. "Project home:\nhttps://github.com/Nighthawk42/wow_bejeweled\n\n"
			.. "Runtime version: " .. tostring(addon.runtimeVersion or "development"),
	},
	credits = {
		title = "Credits",
		text = "Bejeweled Addon for World of Warcraft\n\n"
			.. "Original programmer: Michael Fromwiller\n"
			.. "Original artist: Tysen Henderson\n"
			.. "Original producer: T. Carl Kwoh\n\n"
			.. "Maintained by Kadecgos, Nighthawk42, and contributors.\n\n"
			.. "Original Bejeweled by Jason Kapalka, Brian Fiete, and John Vechey.\n\n"
			.. "PopCap, contributor, library, and beta-tester acknowledgements are preserved in ACKNOWLEDGEMENT.md.",
	},
}

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled About font could not be loaded")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

function About:CreateFrame(parent, preset, width, height, levelOffset, frameType)
	local frame = Backdrops:CreateFrame({
		frameType = frameType,
		parent = parent,
		preset = preset,
		createFrame = self.createFrame,
		backgroundColor = { 0.08, 0.08, 0.08, 0.98 },
		borderColor = { 1, 0.8, 0.45, 1 },
	})
	frame:SetWidth(width)
	frame:SetHeight(height)
	if type(parent.GetFrameLevel) == "function" then
		frame:SetFrameLevel(parent:GetFrameLevel() + (levelOffset or 1))
	end
	return frame
end

function About:New(parent, options)
	assert(parent ~= nil, "About parent is required")
	options = options or {}
	assert(type(options.onBack) == "function", "About requires an onBack callback")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		onBack = options.onBack,
		activeTab = "tutorial",
		tabs = {},
		contents = {},
		visible = false,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for About")

	local frame = instance:CreateFrame(parent, "panel", 400, 400, 20)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	frame:EnableMouse(true)
	frame:Hide()
	frame.title = CreateFontString(frame, 20, "About Bejeweled", { 1, 0.85, 0.1, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -12)
	instance.frame = frame

	local previousTab
	local definitions = {
		{ "tutorial", "How to Play" },
		{ "story", "Story" },
		{ "credits", "Credits" },
	}
	for _, definition in ipairs(definitions) do
		local key = definition[1]
		local tab = instance:CreateFrame(frame, "tooltip", 116, 26, 2, "Button")
		if previousTab then
			tab:SetPoint("LEFT", previousTab, "RIGHT", 5, 0)
		else
			tab:SetPoint("TOP", frame.title, "BOTTOM", -121, -8)
		end
		tab:EnableMouse(true)
		tab.label = CreateFontString(tab, 10, definition[2], { 1, 0.85, 0, 1 })
		tab.label:SetPoint("CENTER", tab, "CENTER", 0, 0)
		tab:SetScript("OnClick", function()
			instance:SetTab(key)
		end)
		instance.tabs[key] = tab
		previousTab = tab
	end

	for key, content in pairs(CONTENT) do
		local panel = instance:CreateFrame(frame, "tooltip", 360, 270, 1)
		panel:SetPoint("TOP", frame.title, "BOTTOM", 0, -43)
		panel.heading = CreateFontString(panel, 16, content.title, { 1, 0.8, 0.15, 1 })
		panel.heading:SetPoint("TOP", panel, "TOP", 0, -12)
		panel.text = CreateFontString(panel, 11, content.text, { 1, 1, 1, 1 })
		panel.text:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -44)
		panel.text:SetWidth(332)
		panel.text:SetJustifyH("LEFT")
		panel:Hide()
		instance.contents[key] = panel
	end

	instance.backButton = instance:CreateFrame(frame, "tooltip", 120, 28, 2, "Button")
	instance.backButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 11)
	instance.backButton:EnableMouse(true)
	instance.backButton.label = CreateFontString(instance.backButton, 12, "Back", { 1, 0.85, 0, 1 })
	instance.backButton.label:SetPoint("CENTER", instance.backButton, "CENTER", 0, 0)
	instance.backButton:SetScript("OnClick", function()
		return instance.onBack(instance)
	end)
	return instance
end

function About:SetTab(tab)
	assert(VALID_TABS[tab], "unknown About tab")
	self.activeTab = tab
	for key, panel in pairs(self.contents) do
		if key == tab then
			panel:Show()
			self.tabs[key]:SetBackdropColor(0.25, 0.18, 0.04, 1)
		else
			panel:Hide()
			self.tabs[key]:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
		end
	end
	return tab
end

function About:Show(tab)
	self:SetTab(tab or self.activeTab)
	self.frame:Show()
	self.visible = true
	return self
end

function About:Hide()
	self.frame:Hide()
	self.visible = false
	return self
end

function About:IsShown()
	return self.visible
end

addon.About = About
