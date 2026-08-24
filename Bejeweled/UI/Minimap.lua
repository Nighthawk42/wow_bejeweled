local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local MinimapButton = {}
MinimapButton.__index = MinimapButton

local BUTTON_SIZE = 33
local ICON_SIZE = 26
local ATTACHED_RADIUS = 105
local TRACKING_BORDER = "Interface\\Minimap\\MiniMap-TrackingBorder"
local HIGHLIGHT_TEXTURE = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"

local function Atan2(y, x)
	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	elseif x < 0 then
		return math.atan(y / x) - math.pi
	elseif y > 0 then
		return math.pi / 2
	elseif y < 0 then
		return -math.pi / 2
	end
	return 0
end

local function SetTextureSize(texture, width, height)
	texture:SetWidth(width)
	texture:SetHeight(height)
end

function MinimapButton:New(options)
	options = options or {}
	assert(type(options) == "table", "minimap-button options must be a table")
	assert(options.minimap ~= nil, "minimap button requires Minimap")
	assert(options.uiParent ~= nil, "minimap button requires UIParent")
	assert(type(options.settings) == "table", "minimap button requires profile settings")
	assert(type(options.runtimeProvider) == "function", "minimap button requires a runtime provider")

	local instance = setmetatable({
		minimap = options.minimap,
		uiParent = options.uiParent,
		settings = options.settings,
		runtimeProvider = options.runtimeProvider,
		createFrame = options.createFrame or CreateFrame,
		tooltip = options.tooltip,
		cursorPosition = options.cursorPosition or GetCursorPosition,
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for minimap button")
	assert(type(instance.cursorPosition) == "function", "cursor position provider must be a function")

	local frame = instance.createFrame("Frame", "BejeweledMinimapIcon", instance.minimap)
	frame:SetWidth(BUTTON_SIZE)
	frame:SetHeight(BUTTON_SIZE)
	if type(frame.SetFrameStrata) == "function" then
		frame:SetFrameStrata("HIGH")
	end
	frame:EnableMouse(true)
	if type(frame.SetClampedToScreen) == "function" then
		frame:SetClampedToScreen(true)
	end

	frame.icon = frame:CreateTexture(nil, "BACKGROUND")
	SetTextureSize(frame.icon, ICON_SIZE, ICON_SIZE)
	frame.icon:SetPoint("CENTER", frame, "CENTER", -1, 1)
	frame.icon:SetTexture(Constants.IMAGE_ROOT .. "windowIcon")

	frame.border = frame:CreateTexture(nil, "ARTWORK")
	SetTextureSize(frame.border, 52, 52)
	frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	frame.border:SetTexture(TRACKING_BORDER)

	frame.highlight = frame:CreateTexture(nil, "OVERLAY")
	SetTextureSize(frame.highlight, 32, 32)
	frame.highlight:SetPoint("CENTER", frame, "CENTER", 0, 0)
	frame.highlight:SetTexture(HIGHLIGHT_TEXTURE)
	frame.highlight:SetBlendMode("ADD")
	frame.highlight:Hide()

	frame:SetScript("OnMouseDown", function(button, mouseButton)
		button.icon:ClearAllPoints()
		button.icon:SetPoint("CENTER", button, "CENTER", 0, 0)
		if mouseButton == "RightButton" then
			button.moving = true
		end
	end)
	frame:SetScript("OnMouseUp", function(button, mouseButton)
		button.icon:ClearAllPoints()
		button.icon:SetPoint("CENTER", button, "CENTER", -1, 1)
		button.moving = nil
		if mouseButton == "LeftButton" then
			instance:ToggleRuntime()
		end
	end)
	frame:SetScript("OnEnter", function(button)
		instance:OnEnter(button)
	end)
	frame:SetScript("OnLeave", function(button)
		instance:OnLeave(button)
	end)
	frame:SetScript("OnUpdate", function(button)
		if button.moving then
			instance:UpdateDrag()
		end
	end)

	instance.frame = frame
	instance:RefreshPosition()
	instance:RefreshVisibility()
	return instance
end

function MinimapButton:GetTooltip()
	return self.tooltip or GameTooltip
end

function MinimapButton:GetUIScale()
	if type(self.uiParent.GetEffectiveScale) == "function" then
		return self.uiParent:GetEffectiveScale()
	end
	if type(self.uiParent.GetScale) == "function" then
		return self.uiParent:GetScale()
	end
	return 1
end

function MinimapButton:SetAttachedPosition(angle)
	angle = tonumber(angle) or 0
	self.frame:ClearAllPoints()
	self.frame:SetPoint(
		"CENTER",
		self.minimap,
		"CENTER",
		-(ATTACHED_RADIUS * math.cos(math.rad(angle))),
		ATTACHED_RADIUS * math.sin(math.rad(angle))
	)
	return angle
end

function MinimapButton:SetDetachedPosition(x, y)
	x = assert(tonumber(x), "detached minimap X position must be numeric")
	y = assert(tonumber(y), "detached minimap Y position must be numeric")
	self.frame:ClearAllPoints()
	self.frame:SetPoint("CENTER", self.uiParent, "BOTTOMLEFT", x, y)
	return x, y
end

function MinimapButton:RefreshPosition()
	local settings = self.settings
	local x = tonumber(settings.minimapX)
	local y = tonumber(settings.minimapY)
	if settings.minimapDetached and x and y then
		return self:SetDetachedPosition(x, y)
	end
	settings.minimapDetached = nil
	return self:SetAttachedPosition(settings.minimapAngle)
end

function MinimapButton:RefreshVisibility()
	if self.settings.hideMinimap then
		self.frame:Hide()
		return false
	end
	self.frame:Show()
	return true
end

function MinimapButton:SetHidden(hidden)
	self.settings.hideMinimap = hidden and 1 or nil
	return self:RefreshVisibility()
end

function MinimapButton:ToggleRuntime()
	local runtime = self.runtimeProvider()
	if not runtime or type(runtime.Toggle) ~= "function" or type(runtime.IsShown) ~= "function" then
		return nil
	end
	runtime:Toggle()
	return runtime:IsShown()
end

function MinimapButton:OnEnter(frame)
	frame.highlight:Show()
	local tooltip = self:GetTooltip()
	if not tooltip or type(tooltip.SetOwner) ~= "function" or type(tooltip.SetText) ~= "function"
		or type(tooltip.AddLine) ~= "function" or type(tooltip.Show) ~= "function" then
		return false
	end
	tooltip:SetOwner(frame, "ANCHOR_LEFT")
	tooltip:SetText("Bejeweled")
	tooltip:AddLine("Left-click to show or hide the game.", 1, 1, 1)
	tooltip:AddLine("Right-drag to move the icon.", 0.75, 0.75, 0.75)
	tooltip:Show()
	return true
end

function MinimapButton:OnLeave(frame)
	frame.highlight:Hide()
	local tooltip = self:GetTooltip()
	if tooltip and type(tooltip.Hide) == "function" then
		tooltip:Hide()
	end
	return true
end

function MinimapButton:UpdateDrag()
	local cursorX, cursorY = self.cursorPosition()
	assert(type(cursorX) == "number" and type(cursorY) == "number", "cursor position must be numeric")
	local scale = self:GetUIScale()
	assert(type(scale) == "number" and scale > 0, "UI scale must be positive")
	cursorX = cursorX / scale
	cursorY = cursorY / scale

	local minimapLeft = assert(self.minimap:GetLeft(), "Minimap left position is unavailable")
	local minimapBottom = assert(self.minimap:GetBottom(), "Minimap bottom position is unavailable")
	local minimapWidth = assert(self.minimap:GetWidth(), "Minimap width is unavailable")
	local minimapHeight = assert(self.minimap:GetHeight(), "Minimap height is unavailable")
	local centerX = minimapLeft + minimapWidth / 2
	local centerY = minimapBottom + minimapHeight / 2
	local offsetX = cursorX - centerX
	local offsetY = cursorY - centerY

	if math.sqrt(offsetX * offsetX + offsetY * offsetY) > minimapWidth then
		self.settings.minimapDetached = true
		self.settings.minimapX = cursorX
		self.settings.minimapY = cursorY
		self:SetDetachedPosition(cursorX, cursorY)
		return "detached", cursorX, cursorY
	end

	local angle = math.deg(Atan2(offsetY, -offsetX))
	self.settings.minimapAngle = angle
	self.settings.minimapDetached = nil
	self:SetAttachedPosition(angle)
	return "attached", angle
end

MinimapButton.BUTTON_SIZE = BUTTON_SIZE
MinimapButton.ICON_SIZE = ICON_SIZE
MinimapButton.ATTACHED_RADIUS = ATTACHED_RADIUS

addon.MinimapButton = MinimapButton
