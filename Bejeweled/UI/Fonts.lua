local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")

local Fonts = {}

local BUNDLED_FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"
local DEFAULT_FALLBACK_PATH = "Fonts\\FRIZQT__.TTF"

function Fonts:GetFallbackPath()
	if type(STANDARD_TEXT_FONT) == "string" and STANDARD_TEXT_FONT ~= "" then
		return STANDARD_TEXT_FONT
	end
	if GameFontNormal and type(GameFontNormal.GetFont) == "function" then
		local path = GameFontNormal:GetFont()
		if type(path) == "string" and path ~= "" then
			return path
		end
	end
	return DEFAULT_FALLBACK_PATH
end

function Fonts:Set(fontString, size, flags, fallbackPath)
	assert(fontString and type(fontString.SetFont) == "function", "font target must expose SetFont")
	assert(type(size) == "number" and size > 0, "font size must be positive")
	flags = flags or ""
	assert(type(flags) == "string", "font flags must be a string")
	if fontString:SetFont(BUNDLED_FONT_PATH, size, flags) then
		return BUNDLED_FONT_PATH, false
	end
	fallbackPath = fallbackPath or self:GetFallbackPath()
	assert(type(fallbackPath) == "string" and fallbackPath ~= "", "fallback font path is unavailable")
	assert(fontString:SetFont(fallbackPath, size, flags), "neither bundled nor standard UI font could be loaded")
	return fallbackPath, true
end

Fonts.BUNDLED_FONT_PATH = BUNDLED_FONT_PATH
Fonts.DEFAULT_FALLBACK_PATH = DEFAULT_FALLBACK_PATH

addon.Fonts = Fonts
