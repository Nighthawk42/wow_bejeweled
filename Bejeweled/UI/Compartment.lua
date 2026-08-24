local _, addon = ...

local Compartment = {}
Compartment.__index = Compartment

function Compartment:New(options)
	options = options or {}
	assert(type(options) == "table", "compartment options must be a table")
	local instance = setmetatable({}, Compartment)
	instance.addon = options.addon or addon
	instance.runtimeProvider = options.runtimeProvider
	instance.tooltip = options.tooltip
	return instance
end

function Compartment:GetRuntime()
	if self.runtimeProvider then
		return self.runtimeProvider()
	end
	if self.addon.runtime then
		return self.addon.runtime
	end
	if self.addon.initialized and type(self.addon.StartRuntime) == "function" then
		return self.addon:StartRuntime()
	end
	return nil
end

function Compartment:GetTooltip()
	return self.tooltip or GameTooltip
end

function Compartment:OnClick(addonName, buttonName)
	if addonName ~= self.addon.name or buttonName ~= "LeftButton" then
		return {
			status = "ignored",
			addonName = addonName,
			buttonName = buttonName,
		}
	end

	local runtime = self:GetRuntime()
	if not runtime or type(runtime.Toggle) ~= "function" or type(runtime.IsShown) ~= "function" then
		return {
			status = "unavailable",
			addonName = addonName,
			buttonName = buttonName,
		}
	end

	runtime:Toggle()
	return {
		status = runtime:IsShown() and "shown" or "hidden",
		addonName = addonName,
		buttonName = buttonName,
		runtime = runtime,
	}
end

function Compartment:OnEnter(addonName, menuButtonFrame)
	if addonName ~= self.addon.name or not menuButtonFrame then
		return false
	end
	local tooltip = self:GetTooltip()
	if not tooltip or type(tooltip.SetOwner) ~= "function" or
		type(tooltip.SetText) ~= "function" or type(tooltip.AddLine) ~= "function" or
		type(tooltip.Show) ~= "function" then
		return false
	end

	tooltip:SetOwner(menuButtonFrame, "ANCHOR_LEFT")
	tooltip:SetText("Bejeweled")
	tooltip:AddLine("Left-click to show or hide the game.", 1, 1, 1)
	tooltip:Show()
	return true
end

function Compartment:OnLeave(addonName, menuButtonFrame)
	if addonName ~= self.addon.name or not menuButtonFrame then
		return false
	end
	local tooltip = self:GetTooltip()
	if not tooltip or type(tooltip.Hide) ~= "function" then
		return false
	end
	tooltip:Hide()
	return true
end

addon.Compartment = Compartment:New()

function Bejeweled_OnAddonCompartmentClick(addonName, buttonName)
	return addon.Compartment:OnClick(addonName, buttonName)
end

function Bejeweled_OnAddonCompartmentEnter(addonName, menuButtonFrame)
	return addon.Compartment:OnEnter(addonName, menuButtonFrame)
end

function Bejeweled_OnAddonCompartmentLeave(addonName, menuButtonFrame)
	return addon.Compartment:OnLeave(addonName, menuButtonFrame)
end
