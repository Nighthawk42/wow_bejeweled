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
	assert(self.Animations, "Animations module is not loaded")
	assert(self.HUD, "HUD module is not loaded")
	assert(self.Summary, "Summary module is not loaded")
	assert(self.Skills, "Skills module is not loaded")
	assert(self.MainWindow, "MainWindow module is not loaded")
	assert(self.Compartment, "Compartment module is not loaded")
	assert(self.Input, "Input module is not loaded")
	assert(self.Session, "Session module is not loaded")

	self.accountData, self.profileData = self.SavedVariables:Initialize(accountData, profileData)
	self.grid = self.Grid:New()
	self.audio = self.Audio:New(self.profileData.settings)
	self.backdrops = self.Backdrops
	self.gemPoolFactory = self.GemPool
	self.animationFactory = self.Animations
	self.hudFactory = self.HUD
	self.summaryFactory = self.Summary
	self.skillsFactory = self.Skills
	self.mainWindowFactory = self.MainWindow
	self.compartment = self.Compartment
	self.inputFactory = self.Input
	self.sessionFactory = self.Session
	self.initialized = true
	if UIParent ~= nil and type(UnitName) == "function" and not self.runtime then
		self:StartRuntime()
	end

	return self
end

function addon:StartRuntime(options)
	assert(self.initialized, "addon must be initialized before starting the runtime")
	if self.runtime then
		return self.runtime
	end
	options = options or {}
	assert(type(options) == "table", "runtime options must be a table")
	local playerName = options.playerName or function()
		local name = UnitName("player")
		assert(type(name) == "string" and name ~= "", "player name is unavailable")
		return name
	end
	self.runtime = self.MainWindow:New(options.uiParent or UIParent, {
		createFrame = options.createFrame,
		profile = self.profileData,
		accountData = self.accountData,
		audio = self.audio,
		playerName = playerName,
		grid = self.grid,
		random = options.random,
		timedDuration = options.timedDuration,
		hintsEnabled = options.hintsEnabled,
		flightOptionProvider = options.flightOptionProvider,
		onFlightTimedRequested = options.onFlightTimedRequested,
	})
	self.runtime:Show()
	return self.runtime
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
