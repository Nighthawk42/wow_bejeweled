local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Fonts = assert(addon.Fonts, "Fonts module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local Skills = {}
Skills.__index = Skills

local PAGE_SIZE = 6

local VALID_TABS = {
	skills = true,
	statistics = true,
	leaderboards = true,
	achievements = true,
}

local RANK_NAMES = {
	"Apprentice",
	"Journeyman",
	"Expert",
	"Artisan",
	"Master",
	"Grand Master",
}

local SKILL_CATEGORY_NAMES = {
	"Match Gems",
	"Gem Cascades",
	"Gem Combos",
	"Classic",
	"Timed",
}

local SKILL_NAMES = {
	[1] = {
		"Match 3 Gems",
		"Match 4 Gems (Create a |cFF0070DD[Power Gem]|r)",
		"Match 5 Gems (Create a |cFFA335EE[Hyper Cube]|r)",
	},
	[2] = {
		"Cause a x2 Cascade",
		"Cause a x3 Cascade",
		"Cause a x4 Cascade",
		"Cause a x5 Cascade",
	},
	[3] = {
		"Clear 10 Gems in one move",
		"Clear 15 Gems in one move",
		"Clear 20 Gems in one move",
		"Clear 25 Gems in one move",
	},
	[4] = {
		"Score 10,000 Points",
		"Survive to Level 10",
		"Survive 100 Moves",
		"Score 25,000 Points",
		"Survive to Level 15",
		"Score 50,000 Points",
		"Survive 250 Moves",
		"Score 75,000 Points",
	},
	[5] = {
		"Achieve a PPS of 250+ at end of game",
		"Achieve a PPS of 300+ at end of game",
		"Achieve a PPS of 350+ at end of game",
	},
}

local ACHIEVEMENTS = {
	[6] = {
		{ "Not Only Gems Fall", "Die from falling damage", "Interface\\Icons\\spell_shadow_twistedfaith" },
		{ "Queue Queue More", "Join a Battleground Queue", "Interface\\Icons\\achievement_bg_killxenemies_generalsroom" },
		{ "Blue Your Chance", "Loot a rare item", "Interface\\Icons\\spell_frost_wizardmark" },
		{ "Annoyed Grunt", "Kill a critter", "Interface\\Icons\\inv_jewelcrafting_crimsonhare" },
		{ "i can haz rez?", "Get resurrected", "Interface\\Icons\\spell_holy_guardianspirit" },
		{ "Purple Reign", "Loot an epic item", "Interface\\Icons\\inv_enchant_voidcrystal" },
		{ "Jewel of Denial", "Say yes to a raid ready check", "Interface\\Icons\\spell_misc_emotionsad" },
		{ "Rest In Pieces", "Die from combat damage", "Interface\\Icons\\spell_shadow_chilltouch" },
		{ "ur so leet", "Kill an elite monster", "Interface\\Icons\\spell_shadow_deathscream" },
		{ "Multitasking Mayhem", "Enter a raid instance", "Interface\\Icons\\achievement_dungeon_coablackdragonflight_normal" },
		{ "Mr. Friendly", "Gain a new reputation level", "Interface\\Icons\\inv_misc_head_dragon_bronze" },
		{ "Guilty, Your Honor", "Gain Honor from a killing blow", "Interface\\Icons\\ability_dualwieldspecialization" },
		{ "Rare For Art Thou?", "Kill a rare spawn monster", "Interface\\Icons\\achievement_zone_stormpeaks_03" },
		{ "Movin' On Up", "Gain a new level on any character", "Interface\\Icons\\achievement_level_80" },
		{ "Two Gems Enter, One Gem Leaves", "Win an Arena match", "Interface\\Icons\\ability_warrior_offensivestance" },
	},
	[7] = {
		{ "Pain In The Classic", "Beat another player's high score (Classic)", "Interface\\Icons\\achievement_pvp_p_14" },
		{ "Gem Collector", "Clear 1,000 Gems", "Interface\\Icons\\inv_misc_coin_17" },
		{ "Too Much Time On Your Hands", "Play 100 games between all characters", "Interface\\Icons\\inv_misc_map02" },
		{ "I've Got The Power!", "Get a |cFF002AFF[Power Gem]|r total of 100+", "Interface\\Icons\\inv_misc_gem_03" },
		{ "What Time Do You Have?", "Beat another player's high score (Timed)", "Interface\\Icons\\achievement_featsofstrength_gladiator_07" },
		{ "A True Master", "75,000 points in a single game", "Interface\\Icons\\ability_mage_brainfreeze" },
		{ "Truly Addicted", "Play 1,000 games between all characters", "Interface\\Icons\\achievement_bg_masterofallbgs" },
		{ "Hyperactive", "Get a |cFFB300B3[Hyper Cube]|r total of 50+", "Interface\\Icons\\spell_holy_summonlightwell" },
		{ "Keep Your Friends Close", "Compete with 10+ Friends", "Interface\\Icons\\achievement_reputation_08" },
		{ "Master of All You Survey", "Complete all Achievements", "Interface\\Icons\\inv_misc_celebrationcake_01" },
		{ "All In The Family", "Compete with 10+ Guildies", "Interface\\Icons\\achievement_reputation_02" },
	},
}

local TIER_COLORS = {
	{ 1, 0.5, 0.25, 1 },
	{ 1, 1, 0, 1 },
	{ 0.25, 0.75, 0.25, 1 },
	{ 0.3, 0.3, 0.3, 1 },
}

local GEM_NAMES = {
	"Yellow",
	"White",
	"Blue",
	"Red",
	"Purple",
	"Orange",
	"Green",
}

local function Clamp(value, minimum, maximum)
	return math.max(minimum, math.min(maximum, value))
end

local function CopyRecord(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

local function FormatInteger(value)
	local formatted = tostring(math.floor(value or 0))
	while true do
		local nextText, substitutions = string.gsub(formatted, "^(%-?%d+)(%d%d%d)", "%1,%2")
		formatted = nextText
		if substitutions == 0 then
			return formatted
		end
	end
end

local function FormatDuration(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	if days > 0 then
		return string.format("%d d %d h %d min", days, hours, minutes)
	end
	if hours > 0 then
		return string.format("%d h %d min", hours, minutes)
	end
	return string.format("%d min %d sec", minutes, seconds % 60)
end

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	Fonts:Set(fontString, size, "OUTLINE")
	fontString:SetText(text or "")
	fontString:SetTextColor(color[1], color[2], color[3], color[4] or 1)
	return fontString
end

function Skills:CreateFrame(parent, preset, width, height, levelOffset, frameType)
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

function Skills:CreateButton(parent, text, width, x, callback)
	local button = self:CreateFrame(parent, "tooltip", width, 26, 2, "Button")
	button:EnableMouse(true)
	button.label = CreateFontString(button, 11, text, { 1, 0.85, 0, 1 })
	button.label:SetPoint("CENTER", button, "CENTER", 0, 1)
	button:SetPoint("BOTTOM", parent, "BOTTOM", x, 10)
	button:SetScript("OnClick", callback)
	button:SetScript("OnEnter", function(frame)
		frame:SetBackdropColor(0.25, 0.18, 0.04, 1)
	end)
	button:SetScript("OnLeave", function(frame)
		frame:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
	end)
	return button
end

function Skills:BuildSkillRecords()
	local records = {}
	local points = math.max(0, math.floor(self.profile.skill.skillPoints or 0))
	for skillType = Constants.SKILL_TYPE_MATCH, Constants.SKILL_TYPE_TIMED do
		local thresholds = Constants.SKILL_THRESHOLDS[skillType]
		for index = #thresholds, 1, -1 do
			local entryThresholds = thresholds[index]
			if points >= entryThresholds[1] then
				local tier = 1
				for thresholdIndex = 2, 4 do
					if points >= entryThresholds[thresholdIndex] then
						tier = thresholdIndex
					end
				end
				if tier < 4 or points < entryThresholds[4] + 20 then
					records[#records + 1] = {
						type = skillType,
						index = index,
						category = SKILL_CATEGORY_NAMES[skillType],
						name = SKILL_NAMES[skillType][index],
						tier = tier,
					}
				end
			end
		end
	end
	return records
end

function Skills:BuildAchievementRecords()
	local complete = {}
	local incomplete = {}
	local points = math.max(0, math.floor(self.profile.skill.skillPoints or 0))
	local total = 0
	local unlocked = 0
	local completed = 0
	for skillType = Constants.SKILL_TYPE_FUN, Constants.SKILL_TYPE_ACHIEVEMENT do
		local prefix = skillType == Constants.SKILL_TYPE_FUN and "gainFun" or "gainAchieve"
		for index, achievement in ipairs(ACHIEVEMENTS[skillType]) do
			total = total + 1
			if points >= Constants.SKILL_THRESHOLDS[skillType][index][1] then
				unlocked = unlocked + 1
				local isComplete = self.profile.skill[prefix .. index] and true or false
				local record = {
					type = skillType,
					index = index,
					title = achievement[1],
					description = achievement[2],
					icon = achievement[3],
					completed = isComplete,
				}
				if isComplete then
					completed = completed + 1
					complete[#complete + 1] = record
				else
					incomplete[#incomplete + 1] = record
				end
			end
		end
	end
	for _, record in ipairs(incomplete) do
		complete[#complete + 1] = record
	end
	return complete, {
		total = total,
		unlocked = unlocked,
		completed = completed,
	}
end

function Skills:BuildStatisticRecords()
	local stats = self.profile.stats or {}
	local classic = stats.classic or {}
	local timed = stats.timed or {}
	local totalGames = 0
	for _, games in pairs(self.accountData.played or {}) do
		if type(games) == "number" and games >= 0 then
			totalGames = totalGames + games
		end
	end
	local favorite = "None"
	local maximum = 0
	local tied = false
	for index, name in ipairs(GEM_NAMES) do
		local matches = (stats.gemMatch or {})[index] or 0
		if matches > maximum then
			favorite = name
			maximum = matches
			tied = false
		elseif matches == maximum and matches > 0 then
			tied = true
		end
	end
	if tied or maximum == 0 then
		favorite = "None"
	end
	return {
		{ label = "Classic High Score", value = FormatInteger(classic.score) },
		{ label = "Timed High Score", value = string.format("%.2f PPS", timed.score or 0) },
		{ label = "Highest Classic Level", value = FormatInteger(classic.highestLevel) },
		{ label = "Most Timed Moves", value = FormatInteger(timed.mostMoves) },
		{ label = "Largest Cascade", value = FormatInteger(stats.largestCascade) },
		{ label = "Largest Combo", value = FormatInteger(stats.largestCombo) },
		{ label = "Total Play Time", value = FormatDuration(stats.played) },
		{ label = "Classic Play Time", value = FormatDuration(classic.played) },
		{ label = "Timed Play Time", value = FormatDuration(timed.played) },
		{ label = "Combat Entries", value = FormatInteger(stats.combatPause) },
		{ label = "Favorite Gem", value = favorite },
		{ label = "Gems Matched", value = FormatInteger(stats.totalGemsMatched) },
		{ label = "Games Played", value = FormatInteger(totalGames) },
		{ label = "Hyper Cubes Created", value = FormatInteger(stats.totalHyperGems) },
		{ label = "Power Gems Created", value = FormatInteger(stats.totalPowerGems) },
	}
end

function Skills:BuildLeaderboardRecords()
	local records = {}
	local scoreList = self.profile.scoreList or {}
	local scope = scoreList[self.leaderboardScope] or {}
	local board = scope[self.leaderboardMode] or {}
	for index = 1, 10 do
		local entry = board[index] or {}
		local rank = Clamp(math.floor(tonumber(entry[2]) or 1), 1, Constants.SKILL_MAX_RANK)
		local score = tonumber(entry[3]) or 0
		records[#records + 1] = {
			position = index,
			name = tostring(entry[1] or "-"),
			rank = rank,
			rankName = RANK_NAMES[rank],
			score = score,
			formattedScore = self.leaderboardMode == "timed" and string.format("%.2f PPS", score) or FormatInteger(score),
		}
	end
	return records
end

function Skills:GetRankState()
	local skill = self.profile.skill
	local rank = Clamp(math.floor(skill.rank or 1), 1, Constants.SKILL_MAX_RANK)
	local points = Clamp(math.floor(skill.skillPoints or 0), 0, Constants.SKILL_POINT_CAP)
	local rankStart = (rank - 1) * Constants.SKILL_RANK_SIZE
	local rankEnd = rank * Constants.SKILL_RANK_SIZE
	return {
		rank = rank,
		name = RANK_NAMES[rank],
		points = points,
		rankStart = rankStart,
		rankEnd = rankEnd,
		progress = Clamp((points - rankStart) / Constants.SKILL_RANK_SIZE, 0, 1),
	}
end

function Skills:New(parent, options)
	assert(parent ~= nil, "skill-screen parent is required")
	options = options or {}
	assert(type(options) == "table", "skill-screen options must be a table")
	assert(type(options.profile) == "table" and type(options.profile.skill) == "table", "skill screen requires profile skill data")
	assert(type(options.accountData) == "table", "skill screen requires account data")
	assert(type(options.onBack) == "function", "skill screen requires an onBack callback")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		profile = options.profile,
		accountData = options.accountData,
		onBack = options.onBack,
		activeTab = "skills",
		page = 1,
		records = {},
		visible = false,
		rows = {},
		leaderboardScope = "guild",
		leaderboardMode = "classic",
	}, self)
	assert(type(instance.createFrame) == "function", "CreateFrame is unavailable for skill screen")

	local frame = instance:CreateFrame(parent, "panel", 400, 400, 20)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	frame:EnableMouse(true)
	frame:Hide()
	frame.title = CreateFontString(frame, 20, "Feats of Skill", { 1, 0.85, 0.1, 1 })
	frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
	frame.rank = CreateFontString(frame, 12, "", { 1, 1, 1, 1 })
	frame.rank:SetPoint("TOP", frame.title, "BOTTOM", 0, -3)
	instance.frame = frame

	local progress = instance:CreateFrame(frame, "slider", 280, 14, 1)
	progress:SetPoint("TOP", frame.rank, "BOTTOM", 0, -5)
	progress.text = CreateFontString(progress, 9, "", { 1, 1, 1, 1 })
	progress.text:SetPoint("CENTER", progress, "CENTER", 0, 0)
	progress.fill = instance:CreateFrame(progress, "slider", 1, 10, 1)
	progress.fill:SetPoint("LEFT", progress, "LEFT", 2, 0)
	progress.fill:SetBackdropColor(0.76, 0.5, 0.08, 1)
	instance.progress = progress

	instance.tabs = {}
	local previousTab
	local tabDefinitions = {
		{ "skills", "Skills" },
		{ "statistics", "Stats" },
		{ "leaderboards", "Scores" },
		{ "achievements", "Achievements" },
	}
	for _, definition in ipairs(tabDefinitions) do
		local key = definition[1]
		local tab = instance:CreateFrame(frame, "tooltip", 90, 24, 2, "Button")
		if previousTab then
			tab:SetPoint("LEFT", previousTab, "RIGHT", 4, 0)
		else
			tab:SetPoint("TOP", progress, "BOTTOM", -141, -6)
		end
		tab:EnableMouse(true)
		tab.label = CreateFontString(tab, 9, definition[2], { 1, 0.85, 0, 1 })
		tab.label:SetPoint("CENTER", tab, "CENTER", 0, 0)
		tab:SetScript("OnClick", function()
			instance:SetTab(key)
		end)
		instance.tabs[key] = tab
		previousTab = tab
	end
	instance.skillsTab = instance.tabs.skills
	instance.statisticsTab = instance.tabs.statistics
	instance.leaderboardsTab = instance.tabs.leaderboards
	instance.achievementsTab = instance.tabs.achievements

	frame.status = CreateFontString(frame, 10, "", { 0.75, 0.75, 0.75, 1 })
	frame.status:SetPoint("TOP", frame, "TOP", 0, -105)

	local function CreateSelector(text, x, callback)
		local button = instance:CreateFrame(frame, "tooltip", 104, 20, 2, "Button")
		button:SetPoint("TOP", frame.status, "BOTTOM", x, -2)
		button:EnableMouse(true)
		button.label = CreateFontString(button, 9, text, { 1, 0.85, 0, 1 })
		button.label:SetPoint("CENTER", button, "CENTER", 0, 0)
		button:SetScript("OnClick", callback)
		button:Hide()
		return button
	end
	instance.scopeButton = CreateSelector("Guild", -54, function()
		instance.leaderboardScope = instance.leaderboardScope == "guild" and "friends" or "guild"
		instance.page = 1
		instance:Refresh()
	end)
	instance.modeButton = CreateSelector("Classic", 54, function()
		instance.leaderboardMode = instance.leaderboardMode == "classic" and "timed" or "classic"
		instance.page = 1
		instance:Refresh()
	end)

	for index = 1, PAGE_SIZE do
		local row = instance:CreateFrame(frame, "tooltip", 370, 30, 1)
		row:SetPoint("TOP", instance.scopeButton, "BOTTOM", 54, -3 - ((index - 1) * 32))
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.icon:SetWidth(24)
		row.icon:SetHeight(24)
		row.title = CreateFontString(row, 10, "", { 1, 1, 1, 1 })
		row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 34, -3)
		row.title:SetWidth(328)
		row.title:SetJustifyH("LEFT")
		row.description = CreateFontString(row, 9, "", { 0.75, 0.75, 0.75, 1 })
		row.description:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -1)
		row.description:SetWidth(328)
		row.description:SetJustifyH("LEFT")
		row:Hide()
		instance.rows[index] = row
	end

	instance.previousButton = instance:CreateButton(frame, "Previous", 82, -132, function()
		instance:SetPage(instance.page - 1)
	end)
	instance.nextButton = instance:CreateButton(frame, "Next", 82, -42, function()
		instance:SetPage(instance.page + 1)
	end)
	instance.pageText = CreateFontString(frame, 10, "", { 0.75, 0.75, 0.75, 1 })
	instance.pageText:SetPoint("BOTTOM", frame, "BOTTOM", 52, 17)
	instance.backButton = instance:CreateButton(frame, "Back", 82, 132, function()
		return instance.onBack(instance)
	end)
	return instance
end

function Skills:GetPageCount()
	return math.max(1, math.ceil(#self.records / PAGE_SIZE))
end

function Skills:GetVisibleRecords()
	local visible = {}
	local first = ((self.page - 1) * PAGE_SIZE) + 1
	local last = math.min(#self.records, first + PAGE_SIZE - 1)
	for index = first, last do
		visible[#visible + 1] = CopyRecord(self.records[index])
	end
	return visible
end

function Skills:SetPage(page)
	page = Clamp(math.floor(page or 1), 1, self:GetPageCount())
	self.page = page
	self:RenderPage()
	return page
end

function Skills:RenderPage()
	local visible = self:GetVisibleRecords()
	for index, row in ipairs(self.rows) do
		local record = visible[index]
		if record then
			if self.activeTab == "skills" then
				local color = TIER_COLORS[record.tier]
				row.icon:Hide()
				row.title:ClearAllPoints()
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 7, -9)
				row.title:SetWidth(355)
				row.title:SetText(record.category .. ": " .. record.name)
				row.title:SetTextColor(color[1], color[2], color[3], color[4])
				row.description:SetText("")
			elseif self.activeTab == "achievements" then
				row.icon:SetTexture(record.icon)
				row.icon:SetVertexColor(record.completed and 1 or 0.45, record.completed and 1 or 0.45, record.completed and 1 or 0.45, 1)
				row.icon:Show()
				row.title:ClearAllPoints()
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 34, -3)
				row.title:SetWidth(328)
				row.title:SetText((record.completed and "|cFF55CC55Complete|r - " or "") .. record.title)
				row.title:SetTextColor(1, 1, 1, 1)
				row.description:ClearAllPoints()
				row.description:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -1)
				row.description:SetWidth(328)
				row.description:SetJustifyH("LEFT")
				row.description:SetText(record.description)
			elseif self.activeTab == "statistics" then
				row.icon:Hide()
				row.title:ClearAllPoints()
				row.title:SetPoint("LEFT", row, "LEFT", 8, 0)
				row.title:SetWidth(220)
				row.title:SetText(record.label)
				row.title:SetTextColor(1, 0.8, 0.15, 1)
				row.description:SetText(record.value)
				row.description:ClearAllPoints()
				row.description:SetPoint("RIGHT", row, "RIGHT", -8, 0)
				row.description:SetWidth(130)
				row.description:SetJustifyH("RIGHT")
			else
				row.icon:Hide()
				row.title:ClearAllPoints()
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 8, -3)
				row.title:SetWidth(350)
				row.title:SetText(string.format("#%d  %s", record.position, record.name))
				row.title:SetTextColor(record.position == 1 and 0.25 or 1, record.position == 1 and 0.9 or 1, record.position == 1 and 0.25 or 1, 1)
				row.description:ClearAllPoints()
				row.description:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -1)
				row.description:SetWidth(350)
				row.description:SetJustifyH("LEFT")
				row.description:SetText(record.rankName .. " - " .. record.formattedScore)
			end
			row:Show()
		else
			row:Hide()
		end
	end
	local pageCount = self:GetPageCount()
	self.pageText:SetText(string.format("Page %d / %d", self.page, pageCount))
	if self.page > 1 then
		self.previousButton:Show()
	else
		self.previousButton:Hide()
	end
	if self.page < pageCount then
		self.nextButton:Show()
	else
		self.nextButton:Hide()
	end
	return visible
end

function Skills:Refresh()
	local rank = self:GetRankState()
	self.frame.rank:SetText(string.format("Bejeweling Skill Rank: %s", rank.name))
	self.progress.text:SetText(string.format("%d / %d", rank.points, rank.rankEnd))
	self.progress.fill:SetWidth(math.max(1, 276 * rank.progress))
	self.progress.ratio = rank.progress
	self.scopeButton:Hide()
	self.modeButton:Hide()
	if self.activeTab == "achievements" then
		local counts
		self.records, counts = self:BuildAchievementRecords()
		self.frame.status:SetText(string.format("Unlocked %d / %d   Completed %d", counts.unlocked, counts.total, counts.completed))
	elseif self.activeTab == "statistics" then
		self.records = self:BuildStatisticRecords()
		self.frame.status:SetText("Personal Bests and Fun Statistics")
	elseif self.activeTab == "leaderboards" then
		self.records = self:BuildLeaderboardRecords()
		self.frame.status:SetText("Local saved leaderboards")
		self.scopeButton.label:SetText(self.leaderboardScope == "guild" and "Guild" or "Friends")
		self.modeButton.label:SetText(self.leaderboardMode == "classic" and "Classic" or "Timed")
		self.scopeButton:Show()
		self.modeButton:Show()
	else
		self.records = self:BuildSkillRecords()
		self.frame.status:SetText(string.format("%d current skill challenges", #self.records))
	end
	for key, tab in pairs(self.tabs) do
		if key == self.activeTab then
			tab:SetBackdropColor(0.25, 0.18, 0.04, 1)
		else
			tab:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
		end
	end
	self.page = Clamp(self.page, 1, self:GetPageCount())
	self:RenderPage()
	return rank
end

function Skills:SetTab(tab)
	assert(VALID_TABS[tab], "unknown skill-screen tab")
	self.activeTab = tab
	self.page = 1
	self:Refresh()
	return tab
end

function Skills:Show(tab)
	if tab then
		assert(VALID_TABS[tab], "unknown skill-screen tab")
		self.activeTab = tab
	end
	self.page = 1
	self:Refresh()
	self.frame:Show()
	self.visible = true
	return self
end

function Skills:Hide()
	self.frame:Hide()
	self.visible = false
	return self
end

function Skills:IsShown()
	return self.visible
end

Skills.PAGE_SIZE = PAGE_SIZE
Skills.RANK_NAMES = RANK_NAMES

addon.Skills = Skills
