local _, addon = ...

local Constants = addon.Constants
local Scoring = {}
addon.Scoring = Scoring

local function ApplyDefault(target, key, value)
	if target[key] == nil then
		target[key] = value
	end
end

local function ValidateMode(gameMode)
	local multiplier = Constants.MODE_SCORE_MULTIPLIERS[gameMode]
	assert(multiplier, "unsupported scoring game mode")
	return multiplier
end

local function ValidateProfile(profile)
	assert(type(profile) == "table", "scoring requires a profile")
	assert(type(profile.stats) == "table", "profile statistics are missing")
	assert(type(profile.skill) == "table", "profile skill data is missing")
	assert(type(profile.stats.classic) == "table" and type(profile.stats.timed) == "table", "profile mode statistics are missing")
	assert(type(profile.stats.gemMatch) == "table", "profile gem-match statistics are missing")
end

local function ValidateCascadeResult(cascadeResult)
	assert(type(cascadeResult) == "table" and type(cascadeResult.steps) == "table", "cascade result is incomplete")
	for stepIndex = 1, #cascadeResult.steps do
		local step = cascadeResult.steps[stepIndex]
		assert(type(step.matchAwards) == "table", "cascade step lacks immutable match awards")
		assert(type(step.hyperAwards) == "table", "cascade step lacks immutable hyper awards")
		assert(type(step.spawnedSpecials) == "table", "cascade step lacks spawned-special records")
		assert(type(step.triggeredPowerRecords) == "table", "cascade step lacks power-trigger records")
		assert(type(step.refills) == "table", "cascade step lacks refill records")
		for awardIndex = 1, #step.matchAwards do
			local award = step.matchAwards[awardIndex]
			assert(type(award.matchLength) == "number" and type(award.powerCells) == "table", "match award is incomplete")
		end
		for awardIndex = 1, #step.hyperAwards do
			local award = step.hyperAwards[awardIndex]
			assert(type(award.matchLength) == "number" and type(award.powerCells) == "table", "hyper award is incomplete")
			assert(award.hyperDestroyed, "hyper award lacks destruction evidence")
		end
	end
end

local function AddSkillResult(events, result)
	events[#events + 1] = result
	if result.metaAward then
		AddSkillResult(events, result.metaAward)
	end
end

local function AllMetaRequirementsComplete(skill)
	for index = 1, #Constants.SKILL_THRESHOLDS[Constants.SKILL_TYPE_FUN] do
		if not skill["gainFun" .. index] then
			return false
		end
	end
	for index = 1, #Constants.SKILL_THRESHOLDS[Constants.SKILL_TYPE_ACHIEVEMENT] do
		if index ~= Constants.ACHIEVEMENT_COMPLETE_ALL and not skill["gainAchieve" .. index] then
			return false
		end
	end
	return true
end

local function AttemptSkill(scoring, profile, skillType, skillIndex, options)
	local thresholdsByType = Constants.SKILL_THRESHOLDS[skillType]
	local thresholds = thresholdsByType and thresholdsByType[skillIndex]
	assert(thresholds, "unsupported skill type or index")
	options = options or {}
	local skill = profile.skill
	local random = options.random or math.random
	local force = options.force and true or false
	local cap = options.skillLimit and Constants.SKILL_LIMITED_POINT_CAP or Constants.SKILL_POINT_CAP
	local pointsBefore = skill.skillPoints or 0
	local rankBefore = skill.rank or 1
	local result = {
		type = skillType,
		index = skillIndex,
		pointsBefore = pointsBefore,
		rankBefore = rankBefore,
		awardAmount = 0,
		gained = 0,
		completed = false,
		forced = force,
	}

	local eligible = (((pointsBefore >= thresholds[1]) or force) and pointsBefore < cap)
		or (skillType >= Constants.SKILL_TYPE_FUN and pointsBefore >= thresholds[1])
	if not eligible then
		result.pointsAfter = pointsBefore
		result.rankAfter = rankBefore
		return result
	end

	local tier = 0
	while tier < 3 and pointsBefore >= thresholds[tier + 2] do
		tier = tier + 1
	end
	if skillType >= Constants.SKILL_TYPE_FUN then
		tier = 0
	end
	result.tier = tier
	if tier >= 3 and not force then
		result.pointsAfter = pointsBefore
		result.rankAfter = rankBefore
		return result
	end

	local awarded = tier == 0 or force
	if not awarded then
		awarded = random(1, 100) <= (100 - tier * 33)
	end
	if not awarded then
		result.pointsAfter = pointsBefore
		result.rankAfter = rankBefore
		return result
	end

	if skillType < Constants.SKILL_TYPE_FUN then
		result.awardAmount = 1
	else
		local flagPrefix = skillType == Constants.SKILL_TYPE_FUN and "gainFun" or "gainAchieve"
		local flag = flagPrefix .. skillIndex
		if skill[flag] or thresholds[1] > pointsBefore or thresholds[1] >= cap - 1 then
			result.pointsAfter = pointsBefore
			result.rankAfter = rankBefore
			return result
		end
		skill[flag] = true
		result.completed = true
		result.awardAmount = skillType == Constants.SKILL_TYPE_FUN and 3 or 5
		if skillType == Constants.SKILL_TYPE_FUN and skillIndex == 14 and type(options.accountData) == "table" then
			options.accountData.gainFun14 = true
		end
	end

	if force then
		result.awardAmount = result.awardAmount + 4
	end
	skill.skillPoints = math.min(pointsBefore + result.awardAmount, cap)
	result.gained = skill.skillPoints - pointsBefore
	if skill.skillPoints >= rankBefore * Constants.SKILL_RANK_SIZE
		and rankBefore < Constants.SKILL_MAX_RANK
		and (cap == Constants.SKILL_POINT_CAP or rankBefore < 5) then
		skill.rank = rankBefore + 1
		result.rankUp = true
	else
		skill.rank = rankBefore
	end
	result.pointsAfter = skill.skillPoints
	result.rankAfter = skill.rank

	if result.completed
		and skillType >= Constants.SKILL_TYPE_FUN
		and not skill["gainAchieve" .. Constants.ACHIEVEMENT_COMPLETE_ALL]
		and AllMetaRequirementsComplete(skill) then
		result.metaAward = AttemptSkill(
			scoring,
			profile,
			Constants.SKILL_TYPE_ACHIEVEMENT,
			Constants.ACHIEVEMENT_COMPLETE_ALL,
			options
		)
	end
	return result
end

function Scoring:AttemptSkill(profile, skillType, skillIndex, options)
	ValidateProfile(profile)
	return AttemptSkill(self, profile, skillType, skillIndex, options)
end

function Scoring:NewState(gameMode, values)
	local modeMultiplier = ValidateMode(gameMode)
	local state = values or {}
	ApplyDefault(state, "gameMode", gameMode)
	assert(state.gameMode == gameMode, "scoring state game mode differs from requested mode")
	ApplyDefault(state, "score", 0)
	ApplyDefault(state, "combo", 0)
	ApplyDefault(state, "level", 1)
	ApplyDefault(state, "pointsToLevelUp", 500 * modeMultiplier)
	ApplyDefault(state, "pointMultiplier", modeMultiplier)
	ApplyDefault(state, "largestCascade", 0)
	ApplyDefault(state, "largestCombo", 0)
	ApplyDefault(state, "gemsCleared", 0)
	ApplyDefault(state, "moves", 0)
	return state
end

local function TrySkill(scoring, events, profile, skillType, skillIndex, options)
	local result = AttemptSkill(scoring, profile, skillType, skillIndex, options)
	AddSkillResult(events, result)
	return result
end

local function CheckScoreThresholds(scoring, state, profile, skillEvents, options)
	if state.gameMode ~= Constants.GAME_MODE_CLASSIC then
		return
	end
	local checks = {
		{ 10000, 2, "scoreTrack1", Constants.SKILL_SCORE10000 },
		{ 25000, 3, "scoreTrack2", Constants.SKILL_SCORE25000 },
		{ 50000, 5, "scoreTrack3", Constants.SKILL_SCORE50000 },
		{ 75000, 6, "scoreTrack4", Constants.SKILL_SCORE75000 },
	}
	for index = 1, #checks do
		local check = checks[index]
		local rank = profile.skill.rank or 1
		if state.score >= check[1] and rank >= check[2] and not state[check[3]] then
			state[check[3]] = true
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_CLASSIC, check[4], options)
		end
	end
	if state.score >= 75000 and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_SCORE75000] then
		TrySkill(
			scoring,
			skillEvents,
			profile,
			Constants.SKILL_TYPE_ACHIEVEMENT,
			Constants.ACHIEVEMENT_SCORE75000,
			options
		)
	end
end

local function ScoreAward(scoring, state, profile, award, skillEvents, options)
	local points = 0
	local combo
	if award.matchLength >= 3 then
		TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_MATCH, Constants.SKILL_MATCH3, options)
		state.combo = state.combo + 1
		combo = state.combo
		if combo >= 2 then
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_COMBO, Constants.SKILL_COMBO2, options)
		end
		if combo >= 3 then
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_COMBO, Constants.SKILL_COMBO3, options)
		end
		if combo >= 4 then
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_COMBO, Constants.SKILL_COMBO4, options)
		end
		if combo >= 5 then
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_COMBO, Constants.SKILL_COMBO5, options)
		end
		points = Constants.LEVEL_SCORE_STEPS[math.min(combo, #Constants.LEVEL_SCORE_STEPS)]
	end
	if award.matchLength == 4 then
		points = points + 10
	elseif award.matchLength >= 5 then
		points = points + 20
	end
	if award.hasPowerBonus then
		TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_MATCH, Constants.SKILL_MATCH4, options)
		points = points + 25
	end
	if award.hyperDestroyed then
		if award.hyperSkill then
			TrySkill(scoring, skillEvents, profile, Constants.SKILL_TYPE_MATCH, Constants.SKILL_MATCH5, options)
		end
		if (award.powerTriggerCount or 0) == 0 then
			points = points + 75
		else
			points = points + 20
		end
	end
	local powerTriggerCount = award.powerTriggerCount or 0
	if powerTriggerCount == 1 then
		points = points + 25
	elseif powerTriggerCount > 1 then
		points = points + 10 * (powerTriggerCount + 2)
	end

	local rawPoints = points
	points = points * ValidateMode(state.gameMode)
	if state.gameMode <= Constants.GAME_MODE_FLIGHT_LEARNING then
		points = points * ((state.level + 1) / 2)
	end
	points = math.floor(points)
	state.score = state.score + points
	if state.score >= state.pointsToLevelUp and not state.levelPending then
		state.levelPending = true
	end
	CheckScoreThresholds(scoring, state, profile, skillEvents, options)
	return {
		kind = award.kind or "match",
		contents = award.contents,
		matchLength = award.matchLength,
		combo = combo,
		rawPoints = rawPoints,
		points = points,
		scoreAfter = state.score,
		powerTriggerCount = powerTriggerCount,
	}
end

local function UpdateLargestCascade(state, stats, awards)
	local totals = {}
	local largest = 0
	for index = 1, #awards do
		local award = awards[index]
		local key = award.originX .. ":" .. award.originY
		totals[key] = (totals[key] or 0) + award.matchLength
		if totals[key] > largest then
			largest = totals[key]
		end
	end
	state.largestCascade = math.max(state.largestCascade, largest)
	stats.largestCascade = math.max(stats.largestCascade or 0, largest)
	return largest
end

function Scoring:RecordMove(state, profile, options)
	assert(type(state) == "table", "move recording requires game state")
	ValidateMode(state.gameMode)
	ValidateProfile(profile)
	options = options or {}
	state.moves = (state.moves or 0) + 1
	if state.gameMode == Constants.GAME_MODE_TIMED then
		profile.stats.timed.mostMoves = math.max(profile.stats.timed.mostMoves or 0, state.moves)
	end
	local result = {
		moves = state.moves,
		skillEvents = {},
	}
	local skillOptions = {
		random = options.random or math.random,
		skillLimit = options.skillLimit,
	}
	if state.gameMode == Constants.GAME_MODE_CLASSIC then
		if state.moves == 100 then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_CLASSIC, Constants.SKILL_MOVE100, skillOptions)
		elseif state.moves == 250 then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_CLASSIC, Constants.SKILL_MOVE250, skillOptions)
		end
	end
	return result
end

function Scoring:ApplyCascade(state, cascadeResult, profile, options)
	assert(type(state) == "table", "cascade scoring requires game state")
	ValidateMode(state.gameMode)
	ValidateProfile(profile)
	ValidateCascadeResult(cascadeResult)
	options = options or {}
	local skillOptions = {
		random = options.random or math.random,
		skillLimit = options.skillLimit,
	}
	local stats = profile.stats
	local result = {
		scoreBefore = state.score,
		scoreEvents = {},
		skillEvents = {},
		levelWasPending = state.levelPending and true or false,
		largestCascade = 0,
	}
	local spawnedByStepAndGroup = {}
	local explosionCount = 0
	local refillCount = 0

	for stepIndex = 1, #cascadeResult.steps do
		local step = cascadeResult.steps[stepIndex]
		spawnedByStepAndGroup[stepIndex] = {}
		for specialIndex = 1, #step.spawnedSpecials do
			local special = step.spawnedSpecials[specialIndex]
			spawnedByStepAndGroup[stepIndex][special.groupIndex] = special
		end

		local originColors = {}
		local directPowerCells = {}
		for awardIndex = 1, #step.hyperAwards do
			result.scoreEvents[#result.scoreEvents + 1] = ScoreAward(
				self,
				state,
				profile,
				step.hyperAwards[awardIndex],
				result.skillEvents,
				skillOptions
			)
		end
		for awardIndex = 1, #step.matchAwards do
			local award = step.matchAwards[awardIndex]
			local spawned = spawnedByStepAndGroup[stepIndex][award.groupIndex]
			if spawned then
				if spawned.kind == "power" then
					stats.totalPowerGems = (stats.totalPowerGems or 0) + 1
					if stats.totalPowerGems >= 100
						and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_POWER100] then
						TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_ACHIEVEMENT, Constants.ACHIEVEMENT_POWER100, skillOptions)
					end
				elseif spawned.kind == "hyper" then
					stats.totalHyperGems = (stats.totalHyperGems or 0) + 1
					TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_MATCH, Constants.SKILL_MATCH5, skillOptions)
					if stats.totalHyperGems >= 50
						and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_HYPER50] then
						TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_ACHIEVEMENT, Constants.ACHIEVEMENT_HYPER50, skillOptions)
					end
				end
			end

			for powerIndex = 1, #award.powerCells do
				directPowerCells[award.powerCells[powerIndex]] = true
			end
			explosionCount = explosionCount + award.powerTriggerCount
			local scoreAward = {
				kind = "match",
				contents = award.contents,
				matchLength = award.matchLength,
				hasPowerBonus = award.hasIntersection or award.specialKind == "power",
				powerTriggerCount = award.powerTriggerCount,
			}
			result.scoreEvents[#result.scoreEvents + 1] = ScoreAward(
				self,
				state,
				profile,
				scoreAward,
				result.skillEvents,
				skillOptions
			)
			local originKey = award.originX .. ":" .. award.originY .. ":" .. award.contents
			if not originColors[originKey] then
				originColors[originKey] = true
				stats.gemMatch[award.contents] = (stats.gemMatch[award.contents] or 0) + 1
			end
		end

		for triggerIndex = 1, #step.triggeredPowerRecords do
			local trigger = step.triggeredPowerRecords[triggerIndex]
			if not directPowerCells[trigger.cell] then
				explosionCount = explosionCount + 1
				result.scoreEvents[#result.scoreEvents + 1] = ScoreAward(
					self,
					state,
					profile,
					{
						kind = "power-trigger",
						contents = trigger.contents,
						matchLength = 1,
						powerTriggerCount = explosionCount,
					},
					result.skillEvents,
					skillOptions
				)
			end
		end

		local stepLargest = UpdateLargestCascade(state, stats, step.matchAwards)
		result.largestCascade = math.max(result.largestCascade, stepLargest)
		local stepRefills = #step.refills
		refillCount = refillCount + stepRefills
		state.gemsCleared = state.gemsCleared + stepRefills
		stats.totalGemsMatched = (stats.totalGemsMatched or 0) + stepRefills
		if stats.totalGemsMatched >= 1000
			and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_CLEAR1000] then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_ACHIEVEMENT, Constants.ACHIEVEMENT_CLEAR1000, skillOptions)
		end
	end

	local clearChecks = {
		{ 10, Constants.SKILL_CLEAR10 },
		{ 15, Constants.SKILL_CLEAR15 },
		{ 20, Constants.SKILL_CLEAR20 },
		{ 25, Constants.SKILL_CLEAR25 },
	}
	for index = 1, #clearChecks do
		if state.gemsCleared >= clearChecks[index][1] then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_CLEAR, clearChecks[index][2], skillOptions)
		end
	end

	state.largestCombo = math.max(state.largestCombo, state.combo)
	stats.largestCombo = math.max(stats.largestCombo or 0, state.combo)
	result.combo = state.combo
	result.refills = refillCount
	result.scoreAfter = state.score
	result.points = state.score - result.scoreBefore
	result.levelPending = state.levelPending and true or false
	state.combo = 0
	state.gemsCleared = 0
	return result
end

function Scoring:AdvanceLevel(state, profile, options)
	assert(type(state) == "table", "level advancement requires game state")
	ValidateProfile(profile)
	local modeMultiplier = ValidateMode(state.gameMode)
	options = options or {}
	assert(state.levelPending or options.force, "level advancement is not pending")
	local oldLevel = state.level
	state.pointMultiplier = modeMultiplier + oldLevel * 0.5
	state.pointsToLevelUp = state.score
		+ state.pointsToLevelUp
		+ math.floor((500 + 150 * oldLevel) * state.pointMultiplier)
	state.level = oldLevel + 1
	state.levelPending = nil
	local stats = profile.stats
	if state.gameMode == Constants.GAME_MODE_CLASSIC then
		stats.classic.highestLevel = math.max(stats.classic.highestLevel or 0, state.level)
	end
	local result = {
		oldLevel = oldLevel,
		level = state.level,
		pointMultiplier = state.pointMultiplier,
		pointsToLevelUp = state.pointsToLevelUp,
		skillEvents = {},
	}
	local skillOptions = {
		random = options.random or math.random,
		skillLimit = options.skillLimit,
	}
	if state.gameMode == Constants.GAME_MODE_CLASSIC and state.level == 10 then
		TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_CLASSIC, Constants.SKILL_LEVEL10, skillOptions)
	elseif state.gameMode == Constants.GAME_MODE_CLASSIC and state.level == 15 then
		TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_CLASSIC, Constants.SKILL_LEVEL15, skillOptions)
	end
	return result
end

function Scoring:CheckCompletedGameAchievements(profile, totalGames, options)
	ValidateProfile(profile)
	assert(type(totalGames) == "number" and totalGames == math.floor(totalGames) and totalGames >= 1, "completed-game total is invalid")
	options = options or {}
	local result = {
		totalGames = totalGames,
		skillEvents = {},
	}
	local skillOptions = {
		random = options.random or math.random,
		skillLimit = options.skillLimit,
	}
	if totalGames >= 100
		and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_GAME100] then
		TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_ACHIEVEMENT, Constants.ACHIEVEMENT_GAME100, skillOptions)
	end
	if totalGames >= 1000
		and not profile.skill["gainAchieve" .. Constants.ACHIEVEMENT_GAME1000] then
		TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_ACHIEVEMENT, Constants.ACHIEVEMENT_GAME1000, skillOptions)
	end
	return result
end

function Scoring:FinalizeGame(state, profile, elapsed, options)
	assert(type(state) == "table", "game finalization requires game state")
	ValidateMode(state.gameMode)
	ValidateProfile(profile)
	assert(type(elapsed) == "number" and elapsed >= 0, "game finalization elapsed time must be nonnegative")
	options = options or {}
	local result = {
		gameMode = state.gameMode,
		score = state.score,
		elapsed = elapsed,
		metricName = "score",
		metric = state.score,
		skillEvents = {},
	}
	if state.gameMode ~= Constants.GAME_MODE_CLASSIC then
		assert(elapsed > 0, "timed game finalization requires positive elapsed time")
		result.metricName = "points-per-second"
		result.metric = state.score / elapsed
		local skillOptions = {
			random = options.random or math.random,
			skillLimit = options.skillLimit,
		}
		if result.metric >= 250 then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_TIMED, Constants.SKILL_PPS250, skillOptions)
		end
		if result.metric >= 300 then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_TIMED, Constants.SKILL_PPS300, skillOptions)
		end
		if result.metric >= 350 then
			TrySkill(self, result.skillEvents, profile, Constants.SKILL_TYPE_TIMED, Constants.SKILL_PPS350, skillOptions)
		end
	end
	return result
end
