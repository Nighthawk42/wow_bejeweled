local _, addon = ...

local SavedVariables = {}
addon.SavedVariables = SavedVariables

local BASE70_RADIX = 70

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

local function IsNonnegativeInteger(value)
	return type(value) == "number" and value == math.floor(value) and value >= 0
end

local function EncodeBase70(value, width, signed)
	assert(IsNonnegativeInteger(value), "base-70 value must be a nonnegative integer")
	assert(IsNonnegativeInteger(width) and width >= 1, "base-70 width must be a positive integer")
	if signed then
		value = value + math.floor((BASE70_RADIX ^ width) / 2)
	end
	local encoded = ""
	local divisions = 0
	while true do
		local digit = value % BASE70_RADIX
		if digit < 27 then
			encoded = string.char(96 + digit) .. encoded
		else
			encoded = string.char(48 + (digit - 27)) .. encoded
		end
		if value >= BASE70_RADIX then
			if divisions < width then
				value = math.floor(value / BASE70_RADIX)
				divisions = divisions + 1
			else
				encoded = EncodeBase70(0, width)
				break
			end
		else
			break
		end
	end
	if #encoded < width then
		encoded = string.rep(string.char(96), width - #encoded) .. encoded
	end
	return encoded
end

local function DecodeBase70(encoded, signed)
	assert(type(encoded) == "string" and #encoded >= 1, "base-70 payload must be a nonempty string")
	local value = 0
	local exponent = #encoded - 1
	for index = 1, #encoded do
		local byte = string.byte(encoded, index)
		local digit
		if byte >= 96 and byte <= 122 then
			digit = byte - 96
		elseif byte >= 48 and byte <= 90 then
			digit = byte - (48 - 27)
		else
			error("base-70 payload contains an invalid byte")
		end
		assert(digit >= 0 and digit < BASE70_RADIX, "base-70 digit is outside the wire alphabet")
		value = value + digit * (BASE70_RADIX ^ exponent)
		exponent = exponent - 1
	end
	if signed then
		value = value - math.floor((BASE70_RADIX ^ #encoded) / 2)
	end
	return value
end

local function ChecksumDigits(payload, seed)
	assert(type(payload) == "string", "checksum payload must be a string")
	seed = seed or 0
	assert(type(seed) == "number", "checksum seed must be numeric")
	local oddSum = seed
	local evenSum = seed
	for index = 1, #payload do
		local byte = string.byte(payload, index)
		if index % 2 == 0 then
			evenSum = evenSum + byte
		else
			oddSum = oddSum + byte
		end
	end
	local first = evenSum % 10
	local second = ((evenSum - first) % 100) / 10
	local third = oddSum % 10
	local fourth = ((oddSum - third) % 100) / 10
	local fifth = (first + second + third + fourth) % 10
	return first, second, third, fourth, fifth
end

local function AuthenticatePayload(payload, seed)
	local first, second, third, fourth, fifth = ChecksumDigits(payload, seed)
	local packed = 100000 + fifth * 10000 + fourth * 1000 + third * 100 + second * 10 + first
	return EncodeBase70(packed, 3) .. payload
end

local function VerifyAuthenticatedPayload(encoded, seed)
	if type(encoded) ~= "string" or #encoded < 4 then
		return nil
	end
	local checksumPrefix = string.sub(encoded, 1, 3)
	local payload = string.sub(encoded, 4)
	local first, second, third, fourth, fifth = ChecksumDigits(payload, seed)
	local succeeded, decodedChecksum = pcall(DecodeBase70, checksumPrefix)
	if not succeeded then
		return nil
	end
	decodedChecksum = tostring(decodedChecksum)
	if tonumber(string.sub(decodedChecksum, 6, 6)) == first
		and tonumber(string.sub(decodedChecksum, 5, 5)) == second
		and tonumber(string.sub(decodedChecksum, 4, 4)) == third
		and tonumber(string.sub(decodedChecksum, 3, 3)) == fourth
		and tonumber(string.sub(decodedChecksum, 2, 2)) == fifth then
		return payload
	end
	return nil
end

local function ByteSum(value)
	assert(type(value) == "string", "checksum identity must be a string")
	local total = 0
	for index = 1, #value do
		total = total + string.byte(value, index)
	end
	return total
end

local function ValidateSavedMetadata(metadata)
	assert(type(metadata) == "table", "saved game metadata row is missing")
	for index = 1, 8 do
		assert(type(metadata[index]) == "number", "saved game metadata contains a nonnumeric field")
	end
	assert(type(metadata[9]) == "string", "saved game score signature is missing")
	assert(IsNonnegativeInteger(metadata[1]), "saved score must be a nonnegative integer")
	assert(metadata[2] >= 0, "saved level threshold must be nonnegative")
	assert(IsNonnegativeInteger(metadata[3]) and metadata[3] >= 1, "saved level is invalid")
	assert(IsNonnegativeInteger(metadata[4]), "saved move count is invalid")
	assert(IsNonnegativeInteger(metadata[5]), "saved largest cascade is invalid")
	assert(IsNonnegativeInteger(metadata[6]), "saved largest combo is invalid")
	assert(metadata[7] >= 0, "saved elapsed time must be nonnegative")
	assert(metadata[8] > 0, "saved point multiplier must be positive")
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

function SavedVariables:EncodeBase70(value, width, signed)
	return EncodeBase70(value, width, signed)
end

function SavedVariables:DecodeBase70(encoded, signed)
	return DecodeBase70(encoded, signed)
end

function SavedVariables:ByteSum(value)
	return ByteSum(value)
end

function SavedVariables:AuthenticatePayload(payload, seed)
	return AuthenticatePayload(payload, seed)
end

function SavedVariables:VerifyAuthenticatedPayload(encoded, seed)
	return VerifyAuthenticatedPayload(encoded, seed)
end

function SavedVariables:HasClassicGame(profile)
	return type(profile) == "table"
		and type(profile.settings) == "table"
		and profile.settings.classicInProgress
		and type(profile.settings.savedState) == "table"
end

function SavedVariables:SaveClassicGame(grid, state, profile, playerName, elapsed)
	assert(type(grid) == "table" and type(grid.ExportLegacyBoard) == "function", "classic save requires a grid")
	assert(type(state) == "table" and state.gameMode == addon.Constants.GAME_MODE_CLASSIC, "classic save requires classic game state")
	assert(type(profile) == "table" and type(profile.settings) == "table", "classic save requires profile settings")
	assert(type(playerName) == "string" and playerName ~= "", "classic save requires a player name")
	elapsed = elapsed or 0
	assert(type(elapsed) == "number" and elapsed >= 0, "classic save elapsed time must be nonnegative")

	local board = grid:ExportLegacyBoard()
	local savedState = profile.settings.savedState
	if type(savedState) ~= "table" then
		savedState = {}
		profile.settings.savedState = savedState
	end
	for row = 1, grid.height do
		local savedRow = savedState[row]
		if type(savedRow) ~= "table" then
			savedRow = {}
			savedState[row] = savedRow
		end
		for column = 1, grid.width do
			savedRow[column] = board[row][column]
		end
	end
	local metadata = savedState[grid.height + 1]
	if type(metadata) ~= "table" then
		metadata = {}
		savedState[grid.height + 1] = metadata
	end
	metadata[1] = state.score
	metadata[2] = state.pointsToLevelUp
	metadata[3] = state.level
	metadata[4] = state.moves
	metadata[5] = state.largestCascade
	metadata[6] = state.largestCombo
	metadata[7] = elapsed
	metadata[8] = state.pointMultiplier
	metadata[9] = AuthenticatePayload(EncodeBase70(state.score, 4), ByteSum(playerName))
	profile.settings.classicInProgress = true
	return savedState
end

function SavedVariables:RestoreClassicGame(grid, profile, playerName)
	assert(type(grid) == "table" and type(grid.LoadLegacyBoard) == "function", "classic restore requires a grid")
	assert(self:HasClassicGame(profile), "no classic game is available to restore")
	assert(type(playerName) == "string" and playerName ~= "", "classic restore requires a player name")
	local savedState = profile.settings.savedState
	local metadata = savedState[grid.height + 1]
	ValidateSavedMetadata(metadata)
	local payload = VerifyAuthenticatedPayload(metadata[9], ByteSum(playerName))
	local score = 0
	if payload then
		local succeeded, decoded = pcall(DecodeBase70, payload)
		if succeeded then
			score = decoded
		else
			payload = nil
		end
	end
	grid:LoadLegacyBoard(savedState)
	return {
		gameMode = addon.Constants.GAME_MODE_CLASSIC,
		score = score,
		combo = 0,
		level = metadata[3],
		pointsToLevelUp = metadata[2],
		pointMultiplier = metadata[8],
		largestCascade = metadata[5],
		largestCombo = metadata[6],
		gemsCleared = 0,
		moves = metadata[4],
		elapsed = metadata[7],
		signatureValid = payload ~= nil,
		savedScore = metadata[1],
	}
end
