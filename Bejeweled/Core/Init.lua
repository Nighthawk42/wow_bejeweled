local addonName, addon = ...

if type(addon) ~= "table" then
	error("Bejeweled requires a private addon namespace")
end

addon.name = addonName
addon.runtimeVersion = "0.1.0-alpha"

function addon:Initialize(accountData, profileData)
	if self.initialized then
		return self
	end

	assert(self.SavedVariables, "SavedVariables module is not loaded")
	assert(self.Grid, "Grid module is not loaded")
	assert(self.Audio, "Audio module is not loaded")
	assert(self.Backdrops, "Backdrops module is not loaded")
	assert(self.GemPool, "GemPool module is not loaded")

	self.accountData, self.profileData = self.SavedVariables:Initialize(accountData, profileData)
	self.grid = self.Grid:New()
	self.audio = self.Audio:New(self.profileData.settings)
	self.backdrops = self.Backdrops
	self.gemPoolFactory = self.GemPool
	self.initialized = true

	return self
end

if type(CreateFrame) == "function" then
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("ADDON_LOADED")
	eventFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
		if event == "ADDON_LOADED" and loadedAddonName == addonName then
			self:UnregisterEvent("ADDON_LOADED")
			addon:Initialize()
		end
	end)
	addon.eventFrame = eventFrame
end
