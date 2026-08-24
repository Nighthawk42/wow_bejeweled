local _, addon = ...

local SavedVariables = {}
addon.SavedVariables = SavedVariables

local CLASSIC_SCORES = {
	{ "PopCap Games", 1, 1000, "9VW``nt" },
	{ "PopCap Games", 1, 900, "7Rk``lQ" },
	{ "PopCap Games", 1, 800, "zDR``k3" },
	{ "PopCap Games", 1, 700, "v>z``j`" },
	{ "PopCap Games", 1, 600, "v;a``h=" },
	{ "PopCap Games", 1, 500, ";OC``gj" },
	{ "PopCap Games", 1, 400, ";MH``eG" },
	{ "PopCap Games", 1, 300, "7EM``dt" },
	{ "PopCap Games", 1, 200, "7CR``bQ" },
	{ "PopCap Games", 1, 100, "x1C```j" },
}

local TIMED_SCORES = {
	{ "PopCap Games", 1, 2.8, "=H7`d`" },
	{ "PopCap Games", 1, 2.6, "wST`cG" },
	{ "PopCap Games", 1, 2.4, "<Nm`c3" },
	{ "PopCap Games", 1, 2.2, ";ST`cj" },
	{ "PopCap Games", 1, 2.0, "xgl`bQ" },
	{ "PopCap Games", 1, 1.8, "=a5`b=" },
	{ "PopCap Games", 1, 1.6, "<gl`bt" },
	{ "PopCap Games", 1, 1.4, "9BI`b`" },
	{ "PopCap Games", 1, 1.2, "=oH`aG" },
	{ "PopCap Games", 1, 1.0, "8H4`a3" },
}

local function DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, nestedValue in pairs(value) do
		copy[DeepCopy(key)] = DeepCopy(nestedValue)
	end
	return copy
end

local function MergeDefaults(target, defaults)
	for key, defaultValue in pairs(defaults) do
		local currentValue = target[key]
		if currentValue == nil then
			target[key] = DeepCopy(defaultValue)
		elseif type(defaultValue) == "table" then
			if type(currentValue) ~= "table" then
				currentValue = {}
				target[key] = currentValue
			end
			MergeDefaults(currentValue, defaultValue)
		end
	end
	return target
end

function SavedVariables:CreateDefaultAccount()
	return {
		flightTimes = {},
	}
end

function SavedVariables:CreateDefaultProfile()
	return {
		stats = {
			classic = {
				score = 0,
				played = 0,
				highestLevel = 0,
			},
			timed = {
				score = 0,
				played = 0,
				mostMoves = 0,
			},
			largestCascade = 0,
			largestCombo = 0,
			played = 0,
			combatPause = 0,
			totalGemsMatched = 0,
			totalPowerGems = 0,
			totalHyperGems = 0,
			gemMatch = { 0, 0, 0, 0, 0, 0, 0, 0 },
		},
		skill = {
			rank = 1,
			skillPoints = 0,
			timedGames = 0,
			games = 0,
			friendList = { c = 0 },
			guildList = { c = 0 },
		},
		settings = {
			gameAlpha = 1,
			mouseoffAlpha = 0.3,
			publishSkillGains = 1,
			publishRankGains = 1,
			newGameFlight = 1,
			publishScores = 1,
			enableSounds = 1,
			openFlightStart = 1,
			openOnDeath = 1,
			closeReadyCheck = 1,
			closeCombat = 1,
			showFlightTooltips = 1,
			defaultPublish = "GUILD",
		},
		version = addon.Constants.SAVED_PROFILE_VERSION,
		scoresUpdated = true,
		scoresPopup = true,
		scoreList = {
			friends = {
				classic = DeepCopy(CLASSIC_SCORES),
				timed = DeepCopy(TIMED_SCORES),
			},
			guild = {
				classic = DeepCopy(CLASSIC_SCORES),
				timed = DeepCopy(TIMED_SCORES),
			},
		},
	}
end

function SavedVariables:Initialize(accountData, profileData)
	if type(accountData) ~= "table" then
		accountData = type(BejeweledData) == "table" and BejeweledData or {}
	end
	if type(profileData) ~= "table" then
		profileData = type(BejeweledProfile) == "table" and BejeweledProfile or {}
	end

	MergeDefaults(accountData, self:CreateDefaultAccount())
	MergeDefaults(profileData, self:CreateDefaultProfile())

	BejeweledData = accountData
	BejeweledProfile = profileData

	return accountData, profileData
end
