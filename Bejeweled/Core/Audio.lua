local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local Audio = {}
Audio.__index = Audio

local SOUND_FILES = {
	Invalid = "bad2.mp3",
	Explosion = "bombexplode.mp3",
	GetReady = "Get_ready.mp3",
	NoMoreMoves = "No_More_Moves.mp3",
	TimesUp = "Time_Up.mp3",
	Go = "Go.mp3",
	Select = "select.mp3",
	PowerCreate = "multishot.mp3",
	HyperCreate = "hypergem_creation.mp3",
	HyperDestroy = "hypergem_destroyed.mp3",
	GemClick = "gemongem2.mp3",
	WipeBoard = "explode2.mp3",
	ElectroExplode = "electro_explode.mp3",
}

local PLAY_ORDER = {
	"Invalid",
	"Explosion",
	"GetReady",
	"NoMoreMoves",
	"TimesUp",
	"Go",
	"Select",
	"PowerCreate",
	"HyperCreate",
	"HyperDestroy",
	"GemClick",
	"WipeBoard",
	"ElectroExplode",
	"LevelUp",
}

local COMBO_FILES = {
	[1] = "gotset2.mp3",
	[2] = "combo32.mp3",
	[3] = "combo42.mp3",
	[4] = "combo52.mp3",
	[5] = "combo62.mp3",
	[6] = "combo72.mp3",
}

local function IsEnabled(settings)
	return not settings or not settings.disableSounds
end

local function AlwaysVisible()
	return true
end

function Audio:New(settings, options)
	options = options or {}
	assert(type(options) == "table", "audio options must be a table")

	local instance = setmetatable({}, self)
	instance.settings = settings or {}
	instance.isVisible = options.isVisible or AlwaysVisible
	instance.playSoundFile = options.playSoundFile or PlaySoundFile
	instance.playSound = options.playSound or PlaySound
	instance.soundKit = options.soundKit or SOUNDKIT
	instance.pending = {}
	instance.pendingCombos = {}
	instance.lastClick = 0

	return instance
end

function Audio:SetSettings(settings)
	assert(type(settings) == "table", "audio settings must be a table")
	self.settings = settings
end

function Audio:SetVisiblePredicate(isVisible)
	assert(type(isVisible) == "function", "audio visibility predicate must be a function")
	self.isVisible = isVisible
end

function Audio:IsEnabled()
	return IsEnabled(self.settings)
end

function Audio:Play(soundName, comboIndex)
	assert(type(soundName) == "string", "sound name must be a string")

	if not self:IsEnabled() or not self.isVisible() then
		return false
	end

	if soundName == "Combo" then
		assert(type(comboIndex) == "number" and comboIndex >= 1, "combo sound requires a positive tier")
		comboIndex = math.floor(comboIndex)
		if comboIndex > 6 then
			comboIndex = 6
		end
		self.pendingCombos[comboIndex] = true
		return true
	end

	assert(SOUND_FILES[soundName] or soundName == "LevelUp", "unknown sound name: " .. soundName)

	if soundName == "GemClick" then
		if self.lastClick <= 0.2 then
			return false
		end
		self.lastClick = 0
	end

	self.pending[soundName] = true
	return true
end

function Audio:PlayFile(fileName, quiet)
	if type(self.playSoundFile) ~= "function" then
		return false, "PlaySoundFile is unavailable"
	end

	local prefix = quiet and "q_" or ""
	return self.playSoundFile(Constants.SOUND_ROOT .. prefix .. fileName)
end

function Audio:PlayLevelUp()
	if type(self.playSound) ~= "function" then
		return false, "PlaySound is unavailable"
	end
	if type(self.soundKit) ~= "table" then
		return false, "SOUNDKIT is unavailable"
	end

	local soundKitID = self.soundKit.UI_SCENARIO_STAGE_END or self.soundKit.UI_AUTO_QUEST_COMPLETE
	if not soundKitID then
		return false, "supported level-up SoundKit is unavailable"
	end

	return self.playSound(soundKitID)
end

function Audio:Flush()
	local played = {}
	if not self:IsEnabled() then
		return played
	end

	local quiet = self.settings and self.settings.quietSounds and true or false
	for index = 1, #PLAY_ORDER do
		local soundName = PLAY_ORDER[index]
		if self.pending[soundName] then
			self.pending[soundName] = nil
			local succeeded, detail
			if soundName == "LevelUp" then
				succeeded, detail = self:PlayLevelUp()
			else
				succeeded, detail = self:PlayFile(SOUND_FILES[soundName], quiet)
			end
			played[#played + 1] = {
				name = soundName,
				succeeded = succeeded,
				detail = detail,
			}
		end
	end

	for comboIndex = 1, 6 do
		if self.pendingCombos[comboIndex] then
			self.pendingCombos[comboIndex] = nil
			local succeeded, detail = self:PlayFile(COMBO_FILES[comboIndex], quiet)
			played[#played + 1] = {
				name = "Combo",
				comboIndex = comboIndex,
				succeeded = succeeded,
				detail = detail,
			}
			break
		end
	end

	return played
end

function Audio:Update(elapsed)
	assert(type(elapsed) == "number" and elapsed >= 0, "audio elapsed time must be non-negative")
	if not self:IsEnabled() then
		return {}
	end

	self.lastClick = self.lastClick + elapsed
	return self:Flush()
end

Audio.SoundFiles = SOUND_FILES
Audio.ComboFiles = COMBO_FILES

addon.Audio = Audio
