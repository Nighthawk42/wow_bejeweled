local _, addon = ...

local Constants = {
	ADDON_ROOT = "Interface\\AddOns\\Bejeweled",
	IMAGE_ROOT = "Interface\\AddOns\\Bejeweled\\images\\",
	SOUND_ROOT = "Interface\\AddOns\\Bejeweled\\sounds\\",
	SAVED_PROFILE_VERSION = "11.0.2",

	GRID_WIDTH = 8,
	GRID_HEIGHT = 8,
	GEM_WIDTH = 50,
	GEM_HEIGHT = 50,
	GEM_COLOR_COUNT = 7,
	EMPTY_CONTENTS = 0,
	HYPER_CONTENTS = 9,
	BIG_STAR_WIRE_OFFSET = 10,

	GAME_MODE_CLASSIC = 1,
	GAME_MODE_TIMED = 2,
	GAME_MODE_FLIGHT_LEARNING = 3,

	LEVEL_SCORE_STEPS = { 10, 20, 30, 40, 60, 80, 110, 160, 210 },
	MODE_SCORE_MULTIPLIERS = {
		[1] = 1,
		[2] = 15,
		[3] = 15,
	},

	GEM_COLOR_TEXTURE_NAMES = {
		[1] = "yellow",
		[2] = "white",
		[3] = "blue",
		[4] = "red",
		[5] = "purple",
		[6] = "orange",
		[7] = "green",
	},

	NEIGHBOR_SCAN_PATTERNS = {
		[1] = { -1, -1, 0, 0 },
		[2] = { 1, 1, 0, 0 },
		[3] = { 0, 0, -1, -1 },
		[4] = { 0, 0, 1, 1 },
		[5] = { -1, 0.5, 0, 0 },
		[6] = { 0, 0, -1, 0.5 },
	},
}

addon.Constants = Constants
