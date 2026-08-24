local _, addon = ...

local Constants = assert(addon.Constants, "Constants module is not loaded")
local Backdrops = assert(addon.Backdrops, "Backdrops module is not loaded")

local Skills = {}
Skills.__index = Skills

local FONT_PATH = Constants.IMAGE_ROOT .. "Contb___.ttf"
local PAGE_SIZE = 7

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

local function CreateFontString(frame, size, text, color)
	local fontString = frame:CreateFontString(nil, "OVERLAY")
	assert(fontString:SetFont(FONT_PATH, size, "OUTLINE"), "bundled skill-screen font could not be loaded")
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
	assert(type(options.onBack) == "function", "skill screen requires an onBack callback")
	local instance = setmetatable({
		parent = parent,
		createFrame = options.createFrame or CreateFrame,
		profile = options.profile,
		onBack = options.onBack,
		activeTab = "skills",
		page = 1,
		records = {},
		visible = false,
		rows = {},
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

	instance.skillsTab = instance:CreateFrame(frame, "tooltip", 150, 24, 2, "Button")
	instance.skillsTab:SetPoint("TOP", progress, "BOTTOM", -78, -6)
	instance.skillsTab:EnableMouse(true)
	instance.skillsTab.label = CreateFontString(instance.skillsTab, 11, "Skills", { 1, 0.85, 0, 1 })
	instance.skillsTab.label:SetPoint("CENTER", instance.skillsTab, "CENTER", 0, 0)
	instance.skillsTab:SetScript("OnClick", function()
		instance:SetTab("skills")
	end)
	instance.achievementsTab = instance:CreateFrame(frame, "tooltip", 150, 24, 2, "Button")
	instance.achievementsTab:SetPoint("LEFT", instance.skillsTab, "RIGHT", 6, 0)
	instance.achievementsTab:EnableMouse(true)
	instance.achievementsTab.label = CreateFontString(instance.achievementsTab, 11, "Achievements", { 1, 0.85, 0, 1 })
	instance.achievementsTab.label:SetPoint("CENTER", instance.achievementsTab, "CENTER", 0, 0)
	instance.achievementsTab:SetScript("OnClick", function()
		instance:SetTab("achievements")
	end)

	frame.status = CreateFontString(frame, 10, "", { 0.75, 0.75, 0.75, 1 })
	frame.status:SetPoint("TOP", instance.skillsTab, "BOTTOM", 78, -4)

	for index = 1, PAGE_SIZE do
		local row = instance:CreateFrame(frame, "tooltip", 370, 30, 1)
		row:SetPoint("TOP", frame.status, "BOTTOM", 0, -3 - ((index - 1) * 32))
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
			else
				row.icon:SetTexture(record.icon)
				row.icon:SetVertexColor(record.completed and 1 or 0.45, record.completed and 1 or 0.45, record.completed and 1 or 0.45, 1)
				row.icon:Show()
				row.title:ClearAllPoints()
				row.title:SetPoint("TOPLEFT", row, "TOPLEFT", 34, -3)
				row.title:SetWidth(328)
				row.title:SetText((record.completed and "|cFF55CC55Complete|r - " or "") .. record.title)
				row.title:SetTextColor(1, 1, 1, 1)
				row.description:SetText(record.description)
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
	if self.activeTab == "achievements" then
		local counts
		self.records, counts = self:BuildAchievementRecords()
		self.frame.status:SetText(string.format("Unlocked %d / %d   Completed %d", counts.unlocked, counts.total, counts.completed))
		self.skillsTab:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
		self.achievementsTab:SetBackdropColor(0.25, 0.18, 0.04, 1)
	else
		self.records = self:BuildSkillRecords()
		self.frame.status:SetText(string.format("%d current skill challenges", #self.records))
		self.skillsTab:SetBackdropColor(0.25, 0.18, 0.04, 1)
		self.achievementsTab:SetBackdropColor(0.08, 0.08, 0.08, 0.98)
	end
	self.page = Clamp(self.page, 1, self:GetPageCount())
	self:RenderPage()
	return rank
end

function Skills:SetTab(tab)
	assert(tab == "skills" or tab == "achievements", "unknown skill-screen tab")
	self.activeTab = tab
	self.page = 1
	self:Refresh()
	return tab
end

function Skills:Show(tab)
	if tab then
		assert(tab == "skills" or tab == "achievements", "unknown skill-screen tab")
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
