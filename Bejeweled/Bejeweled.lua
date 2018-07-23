local Bejeweled = Bejeweled or {}
Bejeweled.version = "Version 8.0.1"
Bejeweled.splashDisplayTime = 3
local t = "Interface\\AddOns\\Bejeweled"
local l = "Interface\\AddOns\\Bejeweled\\images\\"
local ut = "Interface\\AddOns\\Bejeweled\\sounds\\"
local xe = "BEJEWELED2"
local ft = { "|cFFFFFF00" .. "Yellow", "White", "|cFF2255FF" .. "Blue", "|cFFFF0000" .. "Red", "|cFFEE00EE" .. "Purple", "|cFFFF9922" .. "Orange", "|cFF00FF00" .. "Green" }
Bejeweled.const = {}
Bejeweled.const.channels = { "GUILD", "PARTY", "RAID" }
Bejeweled.const.channelNames = { CHAT_MSG_GUILD, CHAT_MSG_PARTY, CHAT_MSG_RAID }
Bejeweled.const.dropInfo = {}
Bejeweled.const.skillDataNames = { "Match Gems", "Gem Cascades", "Gem Combos", "Classic", "Timed", "Fun Achievements", "Game Achievements" }
Bejeweled.const.skillDataRanks = { "Apprentice", "Journeyman", "Expert", "Artisan", "Master", "Grand Master" }
Bejeweled.const.skillData = {
    [1] = {
        [1] = { "Match 3 Gems", 0, 10, 20, 50 },
        [2] = { "Match 4 Gems (Create a |cFF0070DD[Power Gem]|r)", 50, 105, 150, 215 },
        [3] = { "Match 5 Gems (Create a |cFFA335EE[Hyper Cube]|r)", 150, 275, 380, 445 },
    },
    [2] = {
        [1] = { "Cause a x2 Cascade", 0, 25, 55, 75 },
        [2] = { "Cause a x3 Cascade", 40, 100, 160, 225 },
        [3] = { "Cause a x4 Cascade", 80, 125, 195, 280 },
        [4] = { "Cause a x5 Cascade", 125, 190, 265, 335 },
    },
    [3] = {
        [1] = { "Clear 10 Gems in one move", 115, 225, 300, 375 },
        [2] = { "Clear 15 Gems in one move", 150, 260, 345, 500 },
        [3] = { "Clear 20 Gems in one move", 225, 325, 420, 501 },
        [4] = { "Clear 25 Gems in one move", 300, 380, 500, 501 },
    },
    [4] = {
        [1] = { "Score 10,000 Points", 75, 150, 225, 300 },
        [2] = { "Survive to Level 10", 75, 150, 230, 325 },
        [3] = { "Survive 100 Moves", 60, 150, 230, 325 },
        [4] = { "Score 25,000 Points", 150, 280, 375, 500 },
        [5] = { "Survive to Level 15", 150, 280, 385, 500 },
        [6] = { "Score 50,000 Points", 225, 300, 420, 500 },
        [7] = { "Survive 250 Moves", 265, 375, 500, 501 },
        [8] = { "Score 75,000 Points", 300, 500, 501, 502 },
    },
    [5] = {
        [1] = { "Achieve a PPS of 250+ at end of game", 75, 150, 225, 300 },
        [2] = { "Achieve a PPS of 300+ at end of game", 150, 225, 375, 500 },
        [3] = { "Achieve a PPS of 350+ at end of game", 225, 300, 500, 501 },
    },
    [6] = {
        [1] = { "Die from falling damage", 0, 0, 0, 0, "Not Only Gems Fall", "Interface\\Icons\\spell_shadow_twistedfaith" },
        [2] = { "Join a Battleground Queue", 0, 0, 0, 0, "Queue Queue More", "Interface\\Icons\\achievement_bg_killxenemies_generalsroom" },
        [3] = { "Loot a rare item", 75, 75, 75, 75, "Blue Your Chance", "Interface\\Icons\\spell_frost_wizardmark" },
        [4] = { "Kill a critter", 75, 75, 75, 75, "Annoyed Grunt", "Interface\\Icons\\inv_jewelcrafting_crimsonhare" },
        [5] = { "Get resurrected", 75, 75, 75, 75, "i can haz rez?", "Interface\\Icons\\spell_holy_guardianspirit" },
        [6] = { "Loot an epic item", 150, 150, 150, 150, "Purple Reign", "Interface\\Icons\\inv_enchant_voidcrystal" },
        [7] = { "Say yes to a raid ready check", 150, 150, 150, 150, "Jewel of Denial", "Interface\\Icons\\spell_misc_emotionsad" },
        [8] = { "Die from combat damage", 150, 150, 150, 150, "Rest In Pieces", "Interface\\Icons\\spell_shadow_chilltouch" },
        [9] = { "Kill an elite monster", 225, 225, 225, 225, "ur so leet", "Interface\\Icons\\spell_shadow_deathscream" },
        [10] = { "Enter a raid instance", 225, 225, 225, 225, "Multitasking Mayhem", "Interface\\Icons\\achievement_dungeon_coablackdragonflight_normal" },
        [11] = { "Gain a new reputation level", 225, 225, 225, 225, "Mr. Friendly", "Interface\\Icons\\inv_misc_head_dragon_bronze" },
        [12] = { "Gain Honor from a killing blow", 300, 300, 300, 300, "Guilty, Your Honor", "Interface\\Icons\\ability_dualwieldspecialization" },
        [13] = { "Kill a rare spawn monster", 300, 300, 300, 300, "Rare For Art Thou?", "Interface\\Icons\\achievement_zone_stormpeaks_03" },
        [14] = { "Gain a new level on any character", 375, 375, 375, 375, "Movin' On Up", "Interface\\Icons\\achievement_level_80" },
        [15] = { "Win an Arena match", 375, 375, 375, 375, "Two Gems Enter, One Gem Leaves", "Interface\\Icons\\ability_warrior_offensivestance" },
    },
    [7] = {
        [1] = { "Beat another player's high score (Classic)", 0, 0, 0, 0, "Pain In The Classic", "Interface\\Icons\\achievement_pvp_p_14" },
        [2] = { "Clear 1,000 Gems", 75, 75, 75, 75, "Gem Collector", "Interface\\Icons\\inv_misc_coin_17" },
        [3] = { "Play 100 games between all characters", 75, 75, 75, 75, "Too Much Time On Your Hands", "Interface\\Icons\\inv_misc_map02" },
        [4] = { "Get a |cFF002AFF[Power Gem]|r total of 100+", 150, 150, 150, 150, "I've Got The Power!", "Interface\\Icons\\inv_misc_gem_03" },
        [5] = { "Beat another player's high score (Timed)", 150, 150, 150, 150, "What Time Do You Have?", "Interface\\Icons\\achievement_featsofstrength_gladiator_07" },
        [6] = { "75,000 points in a single game", 225, 225, 225, 225, "A True Master", "Interface\\Icons\\ability_mage_brainfreeze" },
        [7] = { "Play 1,000 games between all characters", 225, 225, 225, 225, "Truly Addicted", "Interface\\Icons\\achievement_bg_masterofallbgs" },
        [8] = { "Get a |cFFB300B3[Hyper Cube]|r total of 50+", 300, 300, 300, 300, "Hyperactive", "Interface\\Icons\\spell_holy_summonlightwell" },
        [9] = { "Compete with 10+ Friends", 300, 300, 300, 300, "Keep Your Friends Close", "Interface\\Icons\\achievement_reputation_08" },
        [10] = { "Complete all Achievements", 375, 375, 375, 375, "Master of All You Survey", "Interface\\Icons\\inv_misc_celebrationcake_01" },
        [11] = { "Compete with 10+ Guildies", 375, 375, 375, 375, "All In The Family", "Interface\\Icons\\achievement_reputation_02" },
    },
}
Bejeweled.const.skillDataColors = { { 1, .5, .25 }, { 1, 1, 0 }, { .25, .75, .25 }, { .3, .3, .3 } }
Bejeweled.const.SKILLTYPE_MATCH = 1
Bejeweled.const.SKILL_MATCH3 = 1
Bejeweled.const.SKILL_MATCH4 = 2
Bejeweled.const.SKILL_MATCH5 = 3
Bejeweled.const.SKILLTYPE_COMBO = 2
Bejeweled.const.SKILL_COMBO2 = 1
Bejeweled.const.SKILL_COMBO3 = 2
Bejeweled.const.SKILL_COMBO4 = 3
Bejeweled.const.SKILL_COMBO5 = 4
Bejeweled.const.SKILLTYPE_GEMCOMBO = 3
Bejeweled.const.SKILL_CLEAR10 = 1
Bejeweled.const.SKILL_CLEAR15 = 2
Bejeweled.const.SKILL_CLEAR20 = 3
Bejeweled.const.SKILL_CLEAR25 = 4
Bejeweled.const.SKILLTYPE_CLASSIC = 4
Bejeweled.const.SKILL_SCORE100K = 1
Bejeweled.const.SKILL_SCORE250K = 4
Bejeweled.const.SKILL_LEVEL10 = 2
Bejeweled.const.SKILL_MOVE100 = 3
Bejeweled.const.SKILL_LEVEL15 = 5
Bejeweled.const.SKILL_SCORE500K = 6
Bejeweled.const.SKILL_MOVE250 = 7
Bejeweled.const.SKILL_SCORE750K = 8
Bejeweled.const.SKILLTYPE_TIMED = 5
Bejeweled.const.SKILL_PPS350 = 1
Bejeweled.const.SKILL_PPS300 = 2
Bejeweled.const.SKILL_PPS250 = 3
Bejeweled.const.SKILLTYPE_FUN = 6
Bejeweled.const.SKILL_FUNRANK1A = 1
Bejeweled.const.SKILL_FUNRANK1B = 2
Bejeweled.const.SKILL_FUNRANK2A = 3
Bejeweled.const.SKILL_FUNRANK2B = 4
Bejeweled.const.SKILL_FUNRANK2C = 5
Bejeweled.const.SKILL_FUNRANK3A = 6
Bejeweled.const.SKILL_FUNRANK3B = 7
Bejeweled.const.SKILL_FUNRANK3C = 8
Bejeweled.const.SKILL_FUNRANK4A = 9
Bejeweled.const.SKILL_FUNRANK4B = 10
Bejeweled.const.SKILL_FUNRANK4C = 11
Bejeweled.const.SKILL_FUNRANK5A = 12
Bejeweled.const.SKILL_FUNRANK5B = 13
Bejeweled.const.SKILL_FUNRANK6A = 14
Bejeweled.const.SKILL_FUNRANK6B = 15
Bejeweled.const.SKILLTYPE_ACHIEVEMENT = 7
Bejeweled.const.SKILL_ACHIEVE1A = 1
Bejeweled.const.SKILL_ACHIEVE2A = 2
Bejeweled.const.SKILL_ACHIEVE2B = 3
Bejeweled.const.SKILL_ACHIEVE3A = 4
Bejeweled.const.SKILL_ACHIEVE3B = 5
Bejeweled.const.SKILL_ACHIEVE4A = 6
Bejeweled.const.SKILL_ACHIEVE4B = 7
Bejeweled.const.SKILL_ACHIEVE5A = 8
Bejeweled.const.SKILL_ACHIEVE5B = 9
Bejeweled.const.SKILL_ACHIEVE6A = 10
Bejeweled.const.SKILL_ACHIEVE6B = 11
Bejeweled.const.largeText = {
    ["Go"] = { 135, 76, 0, .263, 0, .296, 224 / 255, 142 / 255, 254 / 255 },
    ["3"] = { 36, 55, .637, .706, .785, 1, 225 / 255, 32 / 255, 38 / 255 },
    ["2"] = { 40, 55, .479, .556, .344, .557, 192 / 255, 189 / 255, 24 / 255 },
    ["1"] = { 25, 55, .43, .478, .344, .557, 54 / 255, 255 / 255, 54 / 255 },
    ["Time's up"] = { 155, 40, .264, .565, .16, .314, 223 / 255, 0, 0 },
    ["No more moves"] = { 295, 41, .264, .839, 0, .158, 223 / 255, 0, 0 },
    ["Level up"] = { 220, 56, 0, .429, .341, .557, 102 / 255, 197 / 255, 254 / 255 },
    ["Bejeweled"] = { 285, 59, 0, .555, .559, .786, 1, 1, 1 },
    ["Multiplier up"] = { 313, 54, 0, .611, .79, 1, 102 / 255, 197 / 255, 254 / 255 },
    ["Strip"] = { 448, 82, 0, .622, .32, .336, 1, 1, 1 },
    ["Popcap"] = { 100, 100, .715, .85, .161, .431, 1, 1, 1 },
    ["Tutorial_1"] = { 150, 83, .708, 1, .677, 1, 1, 1, 1 },
    ["Tutorial_2"] = { 152, 76, 1, 0, .852, 0, 1, .592, .852, .592, 1, 1, 1 },
    ["Tutorial_3"] = { 151, 62, .557, .851, .434, .674, 1, 1, 1 },
}
Bejeweled.const.windowFadeOut = { mode = "OUT", timeToFade = .5, startAlpha = 1, endAlpha = .3, }
Bejeweled.const.windowFadeIn = { mode = "IN", timeToFade = .15, startAlpha = .3, endAlpha = 1, }
Bejeweled.const.windowGameOverFadeOut = {
    mode = "OUT",
    timeToFade = 5,
    startAlpha = 1,
    endAlpha = 0,
    finishedFunc = function()
        if (Bejeweled.const.windowGameOverFadeOut.timeToFade == -1) then
            Bejeweled.const.windowGameOverFadeOut.timeToFade = 5
            Bejeweled.window:Show()
            Bejeweled.window:SetAlpha(BejeweledProfile.settings.gameAlpha)
        else
            Bejeweled.window:Hide();
        end
        Bejeweled.window.hiding = nil;
    end,
}
local he = {
    [1] = { 1, 1, 0 },
    [2] = { 1, 1, 1 },
    [3] = { .2, .4, 1 },
    [4] = { 1, 0, 0 },
    [5] = { .8, 0, .8 },
    [6] = { 1, .6, .2 },
    [7] = { 0, 1, 0 },
    [8] = { 1, 1, 1 },
    [9] = { 1, 1, 1 },
}
local U = { [1] = "yellow", [2] = "white", [3] = "blue", [4] = "red", [5] = "purple", [6] = "orange", [7] = "green", }
local F = {}
local N = {}
local J = {}
local O = {}
local ie = {}
local t, i
i = 1
for e = 0, 4 do
    O[e * 10 + 1] = { 0, .1, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 2] = { .1, .2, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 3] = { .2, .3, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 4] = { .3, .4, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 5] = { .4, .5, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 6] = { .5, .6, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 7] = { .6, .7, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 8] = { .7, .8, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 9] = { .8, .9, e * .19999, (e + 1) * .19999 }
    O[e * 10 + 10] = { .9, 1, e * .19999, (e + 1) * .19999 }
    F[i] = { 0, 49 / 255, (e * 50) / 255, ((e + 1) * 50 - 1) / 255 }
    F[i + 1] = { 49 / 255, 99 / 255, (e * 50) / 255, ((e + 1) * 50 - 1) / 255 }
    F[i + 2] = { 99 / 255, 149 / 255, (e * 50) / 255, ((e + 1) * 50 - 1) / 255 }
    F[i + 3] = { 149 / 255, 199 / 255, (e * 50) / 255, ((e + 1) * 50 - 1) / 255 }
    F[i + 4] = { 199 / 255, 249 / 255, (e * 50) / 255, ((e + 1) * 50 - 1) / 255 }
    J[i] = { unpack(F[i]) }
    J[i + 1] = { unpack(F[i + 1]) }
    J[i + 2] = { unpack(F[i + 2]) }
    J[i + 3] = { unpack(F[i + 3]) }
    J[i + 4] = { unpack(F[i + 4]) } i = i + 5;
end
i = 1
for e = 0, 3 do
    ie[i] = { 0, .25, e / 4, (e + 1) / 4 }
    ie[i + 1] = { .25, .5, e / 4, (e + 1) / 4 }
    ie[i + 2] = { .5, .75, e / 4, (e + 1) / 4 }
    ie[i + 3] = { .75, 1, e / 4, (e + 1) / 4 }
    i = i + 4;
end
for e = 0, 2 do
    N[1 + e * 3] = { 0, 42.66 / 128, e * .33, (e + 1) * .33 }
    N[2 + e * 3] = { .33, 85.33 / 128, e * .33, (e + 1) * .33 }
    N[3 + e * 3] = { .66, 1, e * .33, (e + 1) * .33 }
end
FX_SHINE_ALPHA = { 0, .43, .66, .8, .66, .43 }
FX_SHINE_KEYFRAME = { 1, 5, 3, 7, 2, 6, 4, 8, 9 }
FX_SHINE_GRIDX = { 0, 0, -1, 1, -1, 1, -1, 1, -8 }
FX_SHINE_GRIDY = { -1, 1, 0, 0, -1, 1, 1, -1, -8 }
local K = 0
local Ye = 24
local Ze = 24
local b = 50
local p = 50
local lt = 70 + 20
local Ue = 70 + 20
local Qe = 100 + 50
local qe = 100 + 50
local s = 400
local w = 400
local q = s + 32 + 16
local me = w + 110
local f = 160
local L = 216
local Je = 10
local E = math.random
local S = -1
local y = 1
local Lt = 20
local ye = 3
local ve = 360
local Oe = 4
local bt = 16
local He = 5
local Xe = 12
local A = 6
local se = 4
local je = 7
local it = #FX_SHINE_ALPHA
local ke = 8
local Re = #FX_SHINE_ALPHA
local g = 9
local mt = 40
local te = 10
local be = 10
local t = 11
local Ve = 12
local yt = 25
local De = 13
local We = 14
local Rt = 15
local re = tonumber
local z = type
local _e = 50
local ue = p
local t = 51
local t = p
local le = 51
local W = 52
local at = 53
local t = 16
local Te = 20
local et = 150
local wt = 60
local Gt = 10
local ce = b / 2
local ne = p / 2
local pt = Ye / 2
local ct = Ze / 2
local t = Qe / 2
local t = qe / 2
local oe = Te / 2
local gt = Je / 2
local h = 8
local a = 8
local V = 0
local Pe = 1
local Ct = 2
local t = 3
local pe = 4
local ot = 5
local Fe = 6
local nt = 1
local Ne = 2
local Ie = string.byte
local Be = string.char
local Ge = string.sub
local Ae = math.floor
local t = tostring
local m = E
E = nil
local c = 1
local ae = 2
local k = 3
local T = { 10, 20, 30, 40, 60, 80, 110, 160, 210 } local Ce = { [c] = 1, [ae] = 15, [k] = 15, } local j = Ie
local P = Be
local d = Ae
local u = table.insert
local B = table.remove
local Y = t
local G = Ge
local D = re
local R = z
re = 40
z = 7
local o = {}
for e = 1, 8 do
    o[e] = {};
end
local v, I, ge, we
Ie = nil
Be = nil
Ge = nil
Ae = nil
t = nil
local r = { [1] = { -1, -1, 0, 0 }, [2] = { 1, 1, 0, 0 }, [3] = { 0, 0, -1, -1 }, [4] = { 0, 0, 1, 1 }, [5] = { -1, .5, 0, 0 }, [6] = { 0, 0, -1, .5 }, }
local n = {
    round = 1,
    score = 0,
    paused = false,
    moveAllowed = nil,
    activeTime = 0
}
BejeweledData = { ["flightTimes"] = {}, }
BejeweledProfile = {
    ["stats"] = {
        ["classic"] = {
            ["score"] = 0,
            ["played"] = 0,
            ["highestLevel"] = 0
        },
        ["timed"] = {
            ["score"] = 0,
            ["played"] = 0,
            ["mostMoves"] = 0
        },
        ["largestCascade"] = 0,
        ["largestCombo"] = 0,
        ["played"] = 0,
        ["combatPause"] = 0,
        ["totalGemsMatched"] = 0,
        ["totalPowerGems"] = 0,
        ["totalHyperGems"] = 0,
        ["gemMatch"] = { 0, 0, 0, 0, 0, 0, 0, 0 },
    },
    ["skill"] = { ["rank"] = 1, ["skillPoints"] = 0, ["timedGames"] = 0, ["games"] = 0, },
    ["settings"] = {
        ["keybinding"] = nil,
        ["gameAlpha"] = 1,
        ["mouseoffAlpha"] = .3,
        ["publishSkillGains"] = 1,
        ["publishRankGains"] = 1,
        ["newGameFlight"] = 1,
        ["publishScores"] = 1,
        ["enableSounds"] = 1,
        ["disableHints"] = nil,
        ["lockWindow"] = nil,
        ["openFlightStart"] = 1,
        ["closeFlightEnd"] = nil,
        ["openOnDeath"] = 1,
        ["closeReadyCheck"] = 1,
        ["openLogin"] = nil,
        ["closeCombat"] = 1,
        ["showFlightTooltips"] = 1,
        ["defaultPublish"] = "GUILD"
    },
    ["version"] = "8.0.1",
    ["scoresUpdated"] = true,
    ["scoresPopup"] = true,
    ["scoreList"] = {
        ["friends"] = {
            ["classic"] = {
                [1] = { "PopCap Games", 1, 1e3, "9VW``nt" },
                [2] = { "PopCap Games", 1, 900, "7Rk``lQ" },
                [3] = { "PopCap Games", 1, 800, "zDR``k3" },
                [4] = { "PopCap Games", 1, 700, "v>z``j`" },
                [5] = { "PopCap Games", 1, 600, "v;a``h=" },
                [6] = { "PopCap Games", 1, 500, ";OC``gj" },
                [7] = { "PopCap Games", 1, 400, ";MH``eG" },
                [8] = { "PopCap Games", 1, 300, "7EM``dt" },
                [9] = { "PopCap Games", 1, 200, "7CR``bQ" },
                [10] = { "PopCap Games", 1, 100, "x1C```j" },
            },
            ["timed"] = {
                [1] = { "PopCap Games", 1, 2.8, "=H7`d`" },
                [2] = { "PopCap Games", 1, 2.6, "wST`cG" },
                [3] = { "PopCap Games", 1, 2.4, "<Nm`c3" },
                [4] = { "PopCap Games", 1, 2.2, ";ST`cj" },
                [5] = { "PopCap Games", 1, 2, "xgl`bQ" },
                [6] = { "PopCap Games", 1, 1.8, "=a5`b=" },
                [7] = { "PopCap Games", 1, 1.6, "<gl`bt" },
                [8] = { "PopCap Games", 1, 1.4, "9BI`b`" },
                [9] = { "PopCap Games", 1, 1.2, "=oH`aG" },
                [10] = { "PopCap Games", 1, 1, "8H4`a3" },
            },
        },
        ["guild"] = {
            ["classic"] = {
                [1] = { "PopCap Games", 1, 1e3, "9VW``nt" },
                [2] = { "PopCap Games", 1, 900, "7Rk``lQ" },
                [3] = { "PopCap Games", 1, 800, "zDR``k3" },
                [4] = { "PopCap Games", 1, 700, "v>z``j`" },
                [5] = { "PopCap Games", 1, 600, "v;a``h=" },
                [6] = { "PopCap Games", 1, 500, ";OC``gj" },
                [7] = { "PopCap Games", 1, 400, ";MH``eG" },
                [8] = { "PopCap Games", 1, 300, "7EM``dt" },
                [9] = { "PopCap Games", 1, 200, "7CR``bQ" },
                [10] = { "PopCap Games", 1, 100, "x1C```j" },
            },
            ["timed"] = {
                [1] = { "PopCap Games", 1, 2.8, "=H7`d`" },
                [2] = { "PopCap Games", 1, 2.6, "wST`cG" },
                [3] = { "PopCap Games", 1, 2.4, "<Nm`c3" },
                [4] = { "PopCap Games", 1, 2.2, ";ST`cj" },
                [5] = { "PopCap Games", 1, 2, "xgl`bQ" },
                [6] = { "PopCap Games", 1, 1.8, "=a5`b=" },
                [7] = { "PopCap Games", 1, 1.6, "<gl`bt" },
                [8] = { "PopCap Games", 1, 1.4, "9BI`b`" },
                [9] = { "PopCap Games", 1, 1.2, "=oH`aG" },
                [10] = { "PopCap Games", 1, 1, "8H4`a3" },
            },
        },
    },
}
Bejeweled.debugArray = o
Bejeweled.debugCurrentGameData = n
local function C()
    return {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1,
        edgeSize = 16,
        insets = { top = 5, right = 5, left = 5, bottom = 5, }
    }
end

local function st(t, e)
    if not e.animated then
        u(t.animationStack, e)
        e.animated = true;
    end
end

local function ht(i, t)
    if (i.maxScore) then
        local o = n
        i.score = t
        o.score = t
        if (o.gameMode == c) then
            if (BejeweledProfile.skill.rank >= 2) then
                if (t >= 1e4) and not (n.scoreTrack1) then
                    n.scoreTrack1 = true
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_SCORE100K);
                end
            end
            if (BejeweledProfile.skill.rank >= 3) then
                if (t >= 25e3) and not (n.scoreTrack2) then
                    n.scoreTrack2 = true
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_SCORE250K);
                end
            end
            if (BejeweledProfile.skill.rank >= 5) then
                if (t >= 5e4) and not (n.scoreTrack3) then
                    n.scoreTrack3 = true
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_SCORE500K);
                end
            end
            if (BejeweledProfile.skill.rank >= 6) then
                if (t >= 75e3) and not (n.scoreTrack4) then
                    n.scoreTrack4 = true
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_SCORE750K);
                end
            end
            if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE4A] then
                if (t >= 75e3) then
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE4A);
                end
            end
        end
        if (t >= i.maxScore) and not o.leveledUp then
            local i = Bejeweled.gameStatusText
            if (o.gameMode == c) then
                i:SetText("Level up")
            else
                i:SetText("Multiplier up")
                local o
                if (math.fmod(n.level, 2) == 0) then
                    o = n.level .. "x"
                else
                    o = string.format("%.1fx", (1 + n.level * .5));
                end
                local t, n
                for n = 25, 325, 100 do
                    t = Bejeweled.animator:CreateFloatingText(n, 135, o, 2)
                    t.fxType = te
                    t:Show()
                    Bejeweled.animator:Add(t)
                    t = Bejeweled.animator:CreateFloatingText(n, 250, o, 3, true)
                    t:SetTextColor(1, 1, 1)
                    t.fxType = te
                    t:Show()
                    Bejeweled.animator:Add(t);
                end
            end
            Bejeweled.sound:Play("LevelUp")
            i:Show()
            i.background:Show()
            Bejeweled.animator.hintObj:Hide()
            Bejeweled.animator.hintObj.fxType = S
            o.leveledUp = true
            we = true;
        end
        i:UpdateBar();
    end
end

local function Tt(t)
    if (t.mode == c) then
        if (t.lastScore ~= t.score) then
            t.lastScore = t.score
            Bejeweled.dataText:SetText(Bejeweled:NumberWithCommas(t.score));
        end
        if (n.leveledUp) then
            t.bar:SetWidth(t:GetWidth() - 4);
        else
            t.bar:SetWidth((t.score - t.minScore + .5) / (t.maxScore - t.minScore) * (t:GetWidth() - 4));
        end
    else
        local n = (t.score / t.timer.timeElapsed);
        if (t.score > 0) then
            Bejeweled.levelText:SetFormattedText("%.2f", n);
        else
            Bejeweled.levelText:SetFormattedText("%.2f", 0);
        end
        if not ((t.mode == k) and (Bejeweled.flightOptionWindow.learning)) then
            local n, e, o;
            if (t.timer.timeLeft == -1) then
                t.text:SetText("Timing")
            else
                if (t.timer.timeLeft == t.timer.timeStart) then
                    n = d((t.timer.timeLeft) / 60) e = d((t.timer.timeLeft) - (n * 60))
                elseif (t.timer.timeLeft == 0) then
                    n = 0
                    e = 0
                    o = .01
                else
                    n = d((t.timer.timeLeft + 1) / 60) e = d((t.timer.timeLeft + 1) - (n * 60));
                end
                if (e < 10) then
                    e = "0" .. e
                end
                t.text:SetFormattedText("%d:%s", n, e)
                if (t.timer.timeLeft == t.timer.timeStart) then
                    t.bar:SetWidth(t:GetWidth() - 4)
                else
                    t.bar:SetWidth(o or (((t.timer.timeLeft + .1) / (t.timer.timeStart) * t:GetWidth()) - 4));
                end
            end
        else
            local n, e, o
            if (t.timer.timeElapsed == 0) then
                n = 0
                e = 0
            else
                n = d((t.timer.timeElapsed + 1) / 60) e = d((t.timer.timeElapsed + 1) - (n * 60));
            end
            if (e < 10) then
                e = "0" .. e
            end
            if (t.timer.timeLeft == -1) then
                t.text:SetText("Timing")
            else
                t.text:SetFormattedText("%d:%s", n, e);
            end
            t.bar:SetWidth(t:GetWidth() - 4);
        end
    end
end

local function Bt(e, n, t)
    e.minScore = n
    e.maxScore = t
end

local function xt(e, t, n)
    return e:SetScore(e.score + t)
end

local function rt(t, o, i)
    local n = n
    t.mode = o
    Bejeweled.levelText:SetText("1")
    Bejeweled.levelBar.text:SetText("")
    if (o == c) then
        t:SetTimer() t:SetMinMaxScore(0, 500)
        t:SetScore(0)
        t.bar:SetVertexColor(0, .5, 1)
        Bejeweled.dataBorder:SetWidth(128)
        Bejeweled.levelBorder:SetWidth(94)
        Bejeweled.levelTextCaption:SetText("|cFF11AAFFlvl|r") Bejeweled.dataText:SetText("0")
        Bejeweled.dataText:SetFont(l .. "Contb___.ttf", 12, "Outline")
        Bejeweled.levelText:ClearAllPoints() Bejeweled.levelText:SetPoint("Topright", -16, 0)
        Bejeweled.levelText:SetPoint("Bottomleft", 48, 1)
        Bejeweled.levelText:SetJustifyH("LEFT")
        Bejeweled.levelTextCaption:ClearAllPoints() Bejeweled.levelTextCaption:SetPoint("Topright", Bejeweled.levelText, "Topleft", 5, 0)
        Bejeweled.levelTextCaption:SetWidth(20)
        Bejeweled.levelTextCaption:SetHeight(30)
    else
        t:SetTimer(i) t:SetMinMaxScore(0, 500 * Ce[o])
        t:SetScore(0)
        t.bar:SetVertexColor(0, 1, 0)
        Bejeweled.dataBorder:SetWidth(76)
        Bejeweled.levelBorder:SetWidth(130)
        Bejeweled.levelTextCaption:SetText(" |cFF00FF00pps|r")
        Bejeweled.dataText:SetText("1|cFF00FF00x")
        Bejeweled.dataText:SetFont(l .. "Contb___.ttf", 10, "Outline")
        Bejeweled.levelText:ClearAllPoints() Bejeweled.levelText:SetPoint("Topleft", 16, 0)
        Bejeweled.levelText:SetPoint("Bottomright", -48, 1)
        Bejeweled.levelText:SetJustifyH("RIGHT")
        Bejeweled.levelTextCaption:ClearAllPoints() Bejeweled.levelTextCaption:SetPoint("Topleft", Bejeweled.levelText, "Topright", -5, 0)
        Bejeweled.levelTextCaption:SetPoint("Bottomright", -20, 1)
        if (o == k) and (Bejeweled.flightOptionWindow.learning) then
            t.timer.timeElapsed = i
            t.timer.legJourney = i;
        end
    end
end

local function kt(e, t)
    e.timer.timeLeft = t or (0)
    e.timer.timeStart = t or (0)
    e.timer.timeElapsed = 0
    e:StartTimer()
end

local function Ft(e)
    e.timer.elapsed = 0
    e.timer:Show()
end

local function Pt(e)
    e.timer:Hide()
end

local function X(n, l)
    local t = 0
    local o, e
    local o = #n - 1
    for i = 1, #n do
        e = j(n, i)
        if (e >= 96) then
            e = e - 96
        else
            e = e - (48 - 27)
        end
        t = t + (e * (70 ^ (o)))
        o = o - 1;
    end
    if (l == true) then
        t = t - d((70 ^ #n) / 2);
    end
    return t;
end

local function x(t, n, l)
    local o
    local e = ""
    local i = 0
    if (l == true) then
        t = t + d((70 ^ n) / 2);
    end
    while true do
        o = mod(t, 70)
        if (o < 27) then
            e = P(96 + o) .. e
        else
            e = P(48 + (o - 27)) .. e;
        end
        if (t >= 70) then
            if (i < n) then
                t = d(t / 70)
                i = i + 1
            else
                e = x(0, n) break;
            end
        else
            break;
        end
    end
    if (#e < n) then
        e = string.rep(P(96), (n - #e)) .. e;
    end
    return e;
end

local function H(s, e)
    local d, i, t
    local o = e or 0
    local t = e or 0
    local n, a, e, l, r
    d = #s
    for e = 1, d do
        i = j(s, e)
        if (mod(e, 2) == 0) then
            t = t + i
        else
            o = o + i;
        end
    end
    n = mod(t, 10)
    a = mod(t - n, 100) / 10
    e = mod(o, 10)
    l = mod(o - e, 100) / 10
    r = mod(n + a + e + l, 10)
    return n, a, e, l, r
end

local function P(e, t)
    local t = t or 0
    local l, o, t, i, n = H(e, t)
    return x(1e5 + n * 1e4 + i * 1e3 + t * 100 + o * 10 + l, 3) .. e
end

local function fe(e, t)
    if (R(e) ~= "string") or (#e < 4) then
        return;
    end
    local r = G(e, 1, 3)
    local n = G(e, 4)
    t = t or 0
    local d, h, c, S, s = H(n, t)
    local l, i, t, o, a
    local e = Y(X(r))
    l = D(G(e, 6, 6))
    i = D(G(e, 5, 5))
    t = D(G(e, 4, 4))
    o = D(G(e, 3, 3))
    a = D(G(e, 2, 2))
    if ((l == d) and (i == h) and (t == c) and (o == S) and (a == s)) then
        return n;
    end
end

local function H(t)
    local n, e = 0, 0
    for n = 1, #t do
        e = e + j(t, n);
    end
    return e;
end

local function j(S, ...)
    local a, a, a, o, c, n, i, t, l, d
    local a = "PopCap Games" local f = UnitName("player")
    local h
    local r
    a = H(a) for s = 1, select("#", ...), 2 do
        n = select(s + 1, ...)
        o = select(s, ...)
        c = D(G(o, 1, 1))
        o = G(o, 2)
        n = fe(n, H(o))
        r = true
        if (n) then
            if (#n > 3) then
                n = X(n)
                l = 1e3
                d = 100
                t = S.classic
            else
                n = X(n) / 100
                l = 2.8
                d = .2
                t = S.timed
                r = nil;
            end
        else
            n = -1;
        end
        local s = true
        if (n >= t[10][3]) then
            if (BejeweledProfile.settings.hideDuplicates) then
                for e = 1, 10 do
                    if (o == t[e][1]) then
                        s = nil
                        if (n > t[e][3]) then
                            s = true
                            for e = e, 9 do
                                t[e][1] = t[e + 1][1]
                                t[e][2] = t[e + 1][2]
                                t[e][3] = t[e + 1][3]
                                t[e][4] = t[e + 1][4]
                                if (t[e][1] == "PopCap Games") then
                                    l = t[e][3] - d;
                                end
                            end
                            t[10][1] = "PopCap Games"
                            t[10][2] = 1
                            t[10][3] = l
                            if (r) then
                                t[10][4] = P(x(l, 4), a)
                            else
                                t[10][4] = P(x(l * 100, 3), a);
                            end
                        end
                        break;
                    end
                end
            end
            i = nil
            if (s) then
                for e = 10, 1, -1 do
                    if (n == t[e][3]) and (o == t[e][1]) then
                        i = nil
                        break;
                    end
                    if (n > t[e][3]) then
                        i = e
                    else
                        break;
                    end
                end
                if (i) then
                    for e = 10, i + 1, -1 do
                        if (t[e - 1][1] ~= f) and (t[e - 1][1] ~= "PopCap Games") then
                            h = true;
                        end
                        t[e][1] = t[e - 1][1] t[e][2] = t[e - 1][2] t[e][3] = t[e - 1][3] t[e][4] = t[e - 1][4]
                    end
                    t[i][1] = o
                    t[i][2] = c
                    t[i][3] = n
                    if (r) then
                        t[i][4] = P(x(n, 4), H(o))
                    else
                        t[i][4] = P(x(n * 100, 3), H(o));
                    end
                end
                if (h) then
                    if (t == S.classic) then
                        if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE1A] then
                            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE1A);
                        end
                    else
                        if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE3B] then
                            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE3B);
                        end
                    end
                end
            end
        end
    end
end

local function _t(t)
    local r, i, S, o
    local l = n
    local o
    local s
    local a = UnitName("player") r = Bejeweled.levelBar.timer.timeElapsed
    i = d(r / 60)
    S = d(r - (i * 60))
    s = H(a)
    if (l.gameMode == c) then
        local i = l.score
        t.scoreCaption:SetText("Final Score")
        t.scoreValue:SetText(Bejeweled:NumberWithCommas(i))
        t.bragString = "[Bejeweled Addon]: " .. a .. " just scored " .. t.scoreValue:GetText() .. " points in Classic mode! Download the Bejeweled Addon for Wow to defeat their score!" if (i > n.statDB[I]) then
            n.statDB[I] = i
            n.statDB[v] = P(x(i, 4), s);
        end
        i = P(x(i, 4), s)
        o = Y(BejeweledProfile.skill.rank) .. a
        j(BejeweledProfile.scoreList.friends, o, i)
        j(BejeweledProfile.scoreList.guild, o, i)
        o = o .. "*" .. i
    else
        local i = (l.score / r)
        t.scoreCaption:SetText("Points per Second")
        t.scoreValue:SetFormattedText("%.2f", i)
        t.bragString = "[Bejeweled Addon]: " .. a .. " just scored " .. t.scoreValue:GetText() .. " points per second in a Timed mode! Download the Bejeweled Addon for Wow to defeat their score!" if (i > n.statDB[I]) then
            n.statDB[I] = i
            n.statDB[v] = P(x(d(i * 100), 3), s);
        end
        if (i >= 250) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_TIMED, Bejeweled.const.SKILL_PPS250);
        end
        if (i >= 300) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_TIMED, Bejeweled.const.SKILL_PPS300);
        end
        if (i >= 350) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_TIMED, Bejeweled.const.SKILL_PPS350);
        end
        i = P(x(d(i * 100), 3), s)
        o = Y(BejeweledProfile.skill.rank) .. a
        j(BejeweledProfile.scoreList.friends, o, i)
        j(BejeweledProfile.scoreList.guild, o, i)
        o = o .. "*" .. i;
    end
    t.publishButton:Enable()
    t.seeScoresButton:Enable()
    t.bragButton:Enable()
    t.publishButton:Show()
    if (BejeweledProfile.settings.publishScores) then
        Bejeweled.network:Send("HSPub", o, "GUILD", "")
        local i, n
        for i = 1, GetNumFriends() do
            n, _, _, _, online = GetFriendInfo(i) if (online) then
                Bejeweled.network:Send("HSPub", o, "WHISPER", n);
            end
        end
        t.publishButton:Hide();
    end
    t.bragButton:Show()
    t.publishButton.dataDump = o
    t.publishButton:Enable()
    t.timeValue:SetText(Bejeweled:TotalTime(d(r)))
    t.levelValue:SetText(l.level)
    t.cascadeValue:SetText(l.largestCascade)
    t.comboValue:SetText(l.largestCombo)
    Bejeweled.levelBar.bar:SetVertexColor(1, 0, 0)
    Bejeweled.levelBar.bar:SetWidth(Bejeweled.levelBar:GetWidth() - 4)
    Bejeweled.levelBar.text:SetText("")
    Bejeweled.levelBarButton:SetID(2)
    Bejeweled.levelBarButton:Show()
    Bejeweled.levelBarButton.text:SetText("New game")
    l.gameMode = nil
    Bejeweled.gameStatusText:Hide()
    if not (BejeweledData.firstGame) then
        BejeweledData.firstGame = true
        Bejeweled.popup.text:SetText(Bejeweled.popup.text.tip3)
        Bejeweled.popup:Hide()
        Bejeweled.popup:Show();
    end
end

local function M(l, s, S, f, m, a, c, h, u)
    if (n.gameOver) then
        return;
    end
    local t = 0
    local r = Bejeweled.animator
    local o = 0
    local g = BejeweledProfile.skill.rank
    if (l >= 3) then
        o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_MATCH, Bejeweled.const.SKILL_MATCH3)
        n.combo = n.combo + 1
        local i = n.combo
        if (i >= 2) then
            o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_COMBO, Bejeweled.const.SKILL_COMBO2);
        end
        if (i >= 3) then
            o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_COMBO, Bejeweled.const.SKILL_COMBO3);
        end
        if (i >= 4) then
            o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_COMBO, Bejeweled.const.SKILL_COMBO4);
        end
        if (i >= 5) then
            o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_COMBO, Bejeweled.const.SKILL_COMBO5);
        end
        if (n.combo < #T) then
            t = T[i]
        else
            t = T[#T];
        end
    end
    if (l == 4) then
        t = t + 10
    elseif (l >= 5) then
        t = t + 20;
    end
    if (f) then
        o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_MATCH, Bejeweled.const.SKILL_MATCH4)
        t = t + 25;
    end
    if (m) then
        if (a == 0) then
            t = t + 75
            Bejeweled.sound:Play("HyperDestroy")
        else
            t = t + 20
            Bejeweled.sound:Play("ElectroExplode");
        end
    end
    if (a == 1) then
        t = t + 25
    end
    if (a > 1) then
        t = t + 10 * (a + 2)
    end
    t = t * Ce[n.gameMode] if (n.gameMode <= k) then
        t = t * ((n.level + 1) / 2)
    end
    local i = s.x
    local a = s.y
    if (c == true) then
        i = i + b * (l / 2) else
        a = a + p * (l / 2) i = i + ce;
    end
    if (h) then
        a = s.y
        i = s.x + ce;
    end
    if (u) then
        o = o + Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_MATCH, Bejeweled.const.SKILL_MATCH5)
    else
        local e = r:CreateFloatingText(i, a, d(t), S)
        if (l >= 3) then
            e.comboSound = n.combo;
        end
        r:Add(e);
    end
    if (g ~= BejeweledProfile.skill.rank) then
        r:Add(r:CreateFloatingText(i - 20, a - 20, "RANK UP: " .. Bejeweled.const.skillDataRanks[BejeweledProfile.skill.rank], 7, true));
    end
    if (o > 0) then
        for e = (i + 1), (i + o) do
            r:Add(r:CreateFloatingText(e, a + 20, "+1 Skill", 3, true));
        end
    end
end

local function ze(e, t)
    if (UnitFactionGroup("player") == "Horde") then
        ge = {
            [1] = {
                ["146,244"] = { ["176,165"] = 270, ["159,229"] = 79, ["202,270"] = 194, ["169,279"] = 161, ["198,195"] = 248, ["199,224"] = 237, ["129,220"] = 137, },
                ["179,126"] = { ["166,137"] = 49, ["176,165"] = 165, ["173,93"] = 106, ["191,69"] = 221, ["184,105"] = 65, ["198,195"] = 230, ["191,158"] = 91, ["142,154"] = 231, },
                ["139,107"] = { ["131,73"] = 130, ["176,165"] = 269, ["173,93"] = 107, ["191,69"] = 193, ["100,146"] = 226, ["142,154"] = 261, },
                ["166,137"] = { ["179,126"] = 49, ["176,165"] = 84, ["173,93"] = 126, ["142,154"] = 116, },
                ["131,73"] = { ["191,69"] = 247, ["139,107"] = 130, ["157,83"] = 97, },
                ["176,165"] = { ["146,244"] = 244, ["179,126"] = 164, ["139,107"] = 255, ["166,137"] = 92, ["173,93"] = 189, ["191,69"] = 311, ["198,195"] = 135, ["191,158"] = 51, ["175,204"] = 161, ["128,185"] = 144, ["142,154"] = 174, ["199,224"] = 171, ["129,220"] = 231, },
                ["159,229"] = { ["146,244"] = 139, ["175,204"] = 82, ["129,220"] = 115, },
                ["202,270"] = { ["146,244"] = 197, ["169,279"] = 145, ["198,195"] = 297, ["199,224"] = 135, },
                ["173,93"] = { ["179,126"] = 106, ["139,107"] = 123, ["166,137"] = 136, ["176,165"] = 188, ["191,69"] = 93, ["184,105"] = 70, ["142,154"] = 220, },
                ["191,69"] = { ["179,126"] = 223, ["139,107"] = 195, ["131,73"] = 242, ["176,165"] = 307, ["173,93"] = 89, ["157,83"] = 107, ["191,158"] = 243, ["198,195"] = 352, ["142,154"] = 305, },
                ["157,83"] = { ["131,73"] = 100, ["191,69"] = 113, },
                ["169,279"] = { ["146,244"] = 161, ["202,270"] = 147, ["142,154"] = 409, },
                ["184,105"] = { ["179,126"] = 65, ["173,93"] = 71, },
                ["198,195"] = { ["146,244"] = 250, ["179,126"] = 231, ["176,165"] = 112, ["202,270"] = 322, ["191,69"] = 418, ["191,158"] = 108, ["175,204"] = 92, ["142,154"] = 227, ["199,224"] = 97, },
                ["191,158"] = { ["179,126"] = 99, ["176,165"] = 68, ["191,69"] = 241, ["198,195"] = 108, },
                ["100,146"] = { ["139,107"] = 205, ["142,154"] = 173, ["128,185"] = 201, },
                ["175,204"] = { ["176,165"] = 165, ["159,229"] = 86, ["198,195"] = 95, ["199,224"] = 94, ["129,220"] = 168, },
                ["128,185"] = { ["176,165"] = 152, ["100,146"] = 199, ["142,154"] = 317, ["129,220"] = 121, },
                ["142,154"] = { ["179,126"] = 239, ["139,107"] = 255, ["166,137"] = 112, ["176,165"] = 159, ["173,93"] = 205, ["191,69"] = 293, ["198,195"] = 209, ["100,146"] = 161, ["128,185"] = 197, ["199,224"] = 270, ["129,220"] = 266, },
                ["199,224"] = { ["146,244"] = 239, ["176,165"] = 251, ["202,270"] = 130, ["198,195"] = 101, ["175,204"] = 93, ["142,154"] = 258, },
                ["129,220"] = { ["146,244"] = 137, ["176,165"] = 230, ["159,229"] = 121, ["175,204"] = 170, ["128,185"] = 121, ["142,154"] = 247, },
            },
            [2] = {
                ["193,255"] = { ["182,265"] = 45, ["192,230"] = 103, ["184,331"] = 251, },
                ["131,221"] = { ["158,120"] = 491, ["192,230"] = 264, ["144,202"] = 142, ["186,194"] = 286, ["172,190"] = 302, ["117,207"] = 107, },
                ["172,190"] = { ["117,207"] = 107, ["158,120"] = 260, ["131,221"] = 260, ["144,202"] = 118, ["186,194"] = 90, },
                ["170,74"] = { ["158,120"] = 287, ["129,25"] = 262, ["133,50"] = 190, ["158,110"] = 199, },
                ["144,202"] = { ["131,221"] = 139, ["186,194"] = 193, ["172,190"] = 118, ["117,207"] = 101, },
                ["133,50"] = { ["158,120"] = 318, ["170,74"] = 189, ["129,25"] = 80, ["158,110"] = 199, },
                ["146,121"] = { ["158,120"] = 69, ["158,110"] = 61, },
                ["117,207"] = { ["131,221"] = 114, ["144,202"] = 96, },
                ["184,331"] = { ["193,255"] = 234, ["186,287"] = 167, },
                ["186,287"] = { ["182,265"] = 61, ["184,331"] = 185, },
                ["129,25"] = { ["133,50"] = 76, ["158,120"] = 315, ["170,74"] = 252, },
                ["182,265"] = { ["186,287"] = 75, ["192,230"] = 62, ["193,255"] = 54, },
                ["158,120"] = { ["131,221"] = 500, ["170,74"] = 283, ["133,50"] = 316, ["172,190"] = 258, ["129,25"] = 299, ["146,121"] = 58, ["158,110"] = 89, },
                ["192,230"] = { ["131,221"] = 260, ["186,194"] = 142, ["182,265"] = 58, ["193,255"] = 97, },
                ["186,194"] = { ["144,202"] = 163, ["131,221"] = 286, ["172,190"] = 160, ["192,230"] = 140, },
                ["172,190"] = { ["131,221"] = 257, ["144,202"] = 118, ["186,194"] = 92, ["158,120"] = 261, },
                ["158,110"] = { ["158,120"] = 89, ["170,74"] = 200, ["146,121"] = 62, ["133,50"] = 207 },
            },
            [3] = {
                ["73,174"] = { ["119,238"] = 113, ["91,132"] = 82, ["138,115"] = 153, ["140,170"] = 113, ["169,151"] = 149, },
                ["140,170"] = { ["119,238"] = 108, ["73,174"] = 112, ["153,226"] = 70, ["138,115"] = 88, ["169,151"] = 63, },
                ["119,238"] = { ["198,287"] = 159, ["73,174"] = 149, ["133,253"] = 27, ["182,256"] = 98, ["153,226"] = 69, ["140,170"] = 117, },
                ["248,163"] = { ["206,174"] = 61, ["169,151"] = 120, },
                ["255,80"] = { ["208,81"] = 68, },
                ["245,51"] = { ["208,81"] = 62, },
                ["206,174"] = { ["214,130"] = 68, ["248,163"] = 71.25, ["160,94"] = 131, ["169,151"] = 68, },
                ["208,81"] = { ["255,80"] = 85, ["160,94"] = 70, ["245,51"] = 73, },
                ["182,256"] = { ["198,287"] = 49, ["133,253"] = 81, ["153,226"] = 66, ["119,238"] = 109, ["227,253"] = 67, },
                ["160,94"] = { ["208,81"] = 66, ["206,174"] = 127, ["138,115"] = 55, },
                ["153,226"] = { ["119,238"] = 68, ["182,256"] = 60, ["140,170"] = 74, },
                ["198,287"] = { ["182,256"] = 57, ["119,238"] = 157, ["227,253"] = 70, },
                ["91,132"] = { ["73,174"] = 68, ["138,115"] = 78, ["169,151"] = 126, },
                ["138,115"] = { ["91,132"] = 86, ["73,174"] = 137, ["140,170"] = 82, ["160,94"] = 69, ["169,151"] = 78, },
                ["133,253"] = { ["182,256"] = 78, ["119,238"] = 33, },
                ["214,130"] = { ["206,174"] = 64, },
                ["169,151"] = { ["91,132"] = 135, ["73,174"] = 151, ["138,115"] = 73, ["206,174"] = 75, ["140,170"] = 70, },
                ["227,253"] = { ["198,287"] = 61, ["182,256"] = 65, },
            },
            [4] = {
                ["38,166"] = { ["52,166"] = 30.175, },
                ["46,151"] = { ["90,163"] = 87, ["91,151"] = 95, ["57,186"] = 0, ["52,166"] = 37, },
                ["52,166"] = { ["90,163"] = 49, ["57,186"] = 24, ["46,151"] = 30, ["38,166"] = 26, },
                ["57,186"] = { ["90,163"] = 76.34999999999999, ["52,166"] = 57, ["77,210"] = 58, },
                ["77,210"] = { ["165,217"] = 302, ["99,199"] = 129, ["57,186"] = 94, ["88,254"] = 138.35, },
                ["90,163"] = { ["99,199"] = 72, ["46,151"] = 86, ["143,172"] = 0, ["91,151"] = 33, ["57,186"] = 74, ["52,166"] = 76, },
                ["91,151"] = { ["90,163"] = 23, ["155,148"] = 119, ["46,151"] = 88, },
                ["99,199"] = { ["90,163"] = 119.35, ["164,230"] = 160, ["88,254"] = 113, ["143,172"] = 101, ["119,276"] = 164, ["165,217"] = 142, ["77,210"] = 78, },
                ["119,276"] = { ["156,277"] = 77, ["181,277"] = 122, ["164,230"] = 122, ["99,199"] = 138, ["175,225"] = 136, ["88,254"] = 78, },
                ["143,172"] = { ["90,163"] = 114, ["99,199"] = 118, ["155,148"] = 65, ["169,168"] = 52, ["150,197"] = 66, ["187,158"] = 90.5, },
                ["150,197"] = { ["200,203"] = 108, ["143,172"] = 54, ["169,168"] = 68, ["165,217"] = 58, ["187,158"] = 91, },
                ["155,148"] = { ["143,172"] = 65, ["169,168"] = 49, ["165,217"] = 124, ["169,168"] = 51, ["187,158"] = 62, },
                ["156,277"] = { ["119,276"] = 42, ["164,230"] = 74, ["165,217"] = 141, ["181,277"] = 51, },
                ["164,230"] = { ["165,217"] = 71, ["99,199"] = 159, ["156,277"] = 97, ["119,276"] = 127, ["175,225"] = 34, ["88,254"] = 171, },
                ["165,217"] = { ["156,277"] = 123, ["164,230"] = 37.85, ["169,168"] = 121, ["77,210"] = 212, ["150,197"] = 260.35, ["200,203"] = 0, ["175,225"] = 33, ["195,225"] = 0, ["155,148"] = 160, ["188,212"] = 58, ["99,199"] = 162, },
                ["169,168"] = { ["143,172"] = 47, ["150,197"] = 45, ["155,148"] = 43, ["165,217"] = 66, ["187,158"] = 34, ["200,203"] = 50, },
                ["175,225"] = { ["189,263"] = 104, ["119,276"] = 149, ["164,230"] = 29, ["165,217"] = 32, },
                ["181,277"] = { ["156,277"] = 61, ["201,286"] = 45, ["189,263"] = 42, },
                ["187,158"] = { ["267,94"] = 186, ["143,172"] = 133, ["169,168"] = 53, ["220,159"] = 60, ["200,203"] = 84, ["150,197"] = 121, ["235,132"] = 99, ["155,148"] = 83, ["219,203"] = 108, },
                ["188,212"] = { ["165,217"] = 56, ["195,225"] = 34, ["200,203"] = 39, },
                ["189,263"] = { ["181,277"] = 38, ["195,225"] = 88, ["175,225"] = 80, ["201,286"] = 52, ["231,262"] = 97, },
                ["195,225"] = { ["200,203"] = 45.675, ["189,263"] = 76, ["227,251"] = 101, ["165,217"] = 0, ["188,212"] = 38, ["231,262"] = 91, },
                ["200,203"] = { ["165,217"] = 0, ["150,197"] = 108.5, ["188,212"] = 28, ["228,210"] = 64, ["195,225"] = 41, ["169,168"] = 92, ["219,203"] = 45, ["187,158"] = 98.5, },
                ["201,286"] = { ["189,263"] = 44, ["181,277"] = 49, ["247,216"] = 154, ["227,251"] = 105, ["231,262"] = 88, },
                ["219,203"] = { ["200,203"] = 41, ["266,173"] = 106, ["187,158"] = 122, ["220,159"] = 76, ["228,210"] = 44, },
                ["220,159"] = { ["264,145"] = 86, ["266,173"] = 102, ["235,132"] = 58, ["219,203"] = 81, ["187,158"] = 88, },
                ["227,251"] = { ["195,225"] = 88, ["201,286"] = 85, ["231,262"] = 33, ["247,216"] = 90, },
                ["228,210"] = { ["200,203"] = 54, ["266,173"] = 101, ["219,203"] = 25, ["247,216"] = 42.5, },
                ["231,262"] = { ["189,263"] = 101, ["247,216"] = 99, ["195,225"] = 115, ["227,251"] = 46, ["201,286"] = 74, },
                ["233,102"] = { ["235,132"] = 56, ["267,94"] = 65, },
                ["235,132"] = { ["233,102"] = 55, ["267,94"] = 93, ["264,145"] = 60.5, ["220,159"] = 48, ["187,158"] = 118, },
                ["247,216"] = { ["266,173"] = 83, ["231,262"] = 87, ["227,251"] = 86, ["258,241"] = 54, ["201,286"] = 155, ["228,210"] = 54, },
                ["258,241"] = { ["247,216"] = 56, },
                ["264,145"] = { ["266,173"] = 59.5, ["267,94"] = 81, ["235,132"] = 58, ["220,159"] = 95, ["300,128"] = 74, },
                ["266,173"] = { ["264,145"] = 49, ["300,128"] = 106, ["247,216"] = 93, ["220,159"] = 96.5, ["219,203"] = 93, ["228,210"] = 100, },
                ["267,94"] = { ["264,145"] = 80.5, ["300,128"] = 81, ["235,132"] = 104, ["233,102"] = 78, ["187,158"] = 195, },
                ["300,128"] = { ["264,145"] = 74, ["267,94"] = 81, ["266,173"] = 105, },
            },
        } else
        ge = {
            [1] = {
                ["190,67"] = { ["191,158"] = 244, ["157,83"] = 105, ["201,116"] = 155, ["152,106"] = 177, ["132,73"] = 199, },
                ["123,210"] = { ["125,173"] = 128, ["135,263"] = 179, ["146,212"] = 156, },
                ["132,73"] = { ["190,67"] = 190, ["99,108"] = 176, ["157,83"] = 94, },
                ["201,116"] = { ["146,212"] = 370, ["191,158"] = 116, ["190,67"] = 158, ["135,263"] = 530, ["125,173"] = 335, ["152,106"] = 164, ["192,211"] = 235, ["184,105"] = 65, },
                ["67,259"] = { ["69,290"] = 78, },
                ["159,229"] = { ["167,261"] = 128, ["183,215"] = 104, ["146,212"] = 81, },
                ["203,269"] = { ["167,261"] = 108, ["192,211"] = 168, ["174,279"] = 112, },
                ["174,279"] = { ["167,261"] = 62, ["135,263"] = 143, ["203,269"] = 120, },
                ["69,290"] = { ["67,259"] = 78, },
                ["125,173"] = { ["201,116"] = 308, ["135,263"] = 283, ["123,210"] = 121, ["99,108"] = 233, },
                ["192,211"] = { ["135,263"] = 303, ["191,158"] = 137, ["167,261"] = 285, ["201,116"] = 241, ["203,269"] = 179, ["183,215"] = 28, ["146,212"] = 151, },
                ["183,215"] = { ["159,229"] = 110, ["192,211"] = 29, ["146,212"] = 143, },
                ["184,105"] = { ["201,116"] = 53, ["152,106"] = 106, },
                ["131,296"] = { ["135,263"] = 86, },
                ["135,263"] = { ["174,279"] = 152, ["125,173"] = 294, ["192,211"] = 301, ["131,296"] = 86, ["201,116"] = 445, ["167,261"] = 191, ["123,210"] = 182, ["99,108"] = 475, ["146,212"] = 169, },
                ["191,158"] = { ["201,116"] = 107, ["190,67"] = 246, ["192,211"] = 131, ["146,212"] = 198, },
                ["157,83"] = { ["190,67"] = 105, ["132,73"] = 95, },
                ["167,261"] = { ["159,229"] = 129, ["203,269"] = 108, ["174,279"] = 68, ["192,211"] = 283, ["135,263"] = 189, },
                ["152,106"] = { ["201,116"] = 160, ["190,67"] = 172, ["99,108"] = 179, ["184,105"] = 87, },
                ["99,108"] = { ["125,173"] = 228, ["135,263"] = 554, ["152,106"] = 155, ["132,73"] = 154, },
                ["146,212"] = { ["159,229"] = 80, ["135,263"] = 150, ["191,158"] = 194, ["201,116"] = 389, ["183,215"] = 135, ["123,210"] = 156, ["192,211"] = 149, },
                ["173,284"] = { ["131,296"] = 152, },
            },
            [2] = {
                ["123,72"] = { ["137,63"] = 63, ["129,93"] = 87, ["129,25"] = 186, ["148,73"] = 98, ["159,86"] = 132, },
                ["140,193"] = { ["150,213"] = 82, ["143,155"] = 111, ["162,186"] = 74, ["156,205"] = 73, ["147,143"] = 207, },
                ["150,213"] = { ["193,229"] = 147, ["140,193"] = 86, ["156,205"] = 66, ["147,143"] = 261, },
                ["193,229"] = { ["193,255"] = 56, ["150,213"] = 150, ["147,143"] = 369, ["184,331"] = 61, ["156,205"] = 163, },
                ["159,86"] = { ["123,72"] = 136, ["164,99"] = 62, ["148,73"] = 62, ["129,93"] = 114, },
                ["156,205"] = { ["140,193"] = 69, ["150,213"] = 54, ["193,229"] = 165, ["162,186"] = 77, ["147,143"] = 247, },
                ["164,99"] = { ["129,93"] = 153, ["159,86"] = 64, ["172,66"] = 198, ["147,121"] = 92, },
                ["193,255"] = { ["193,229"] = 51, ["184,331"] = 252, },
                ["147,121"] = { ["164,99"] = 91, ["166,135"] = 89, ["129,93"] = 127, ["147,143"] = 90, },
                ["148,73"] = { ["123,72"] = 94, ["172,66"] = 98, ["137,63"] = 48, ["159,86"] = 61, ["129,93"] = 83, ["129,25"] = 172, },
                ["172,66"] = { ["164,99"] = 210, ["148,73"] = 91, ["129,93"] = 190, },
                ["137,63"] = { ["123,72"] = 67, ["129,25"] = 116, ["148,73"] = 50, ["129,93"] = 98, },
                ["129,25"] = { ["123,72"] = 149, ["129,93"] = 200, ["148,73"] = 168, ["137,63"] = 118, },
                ["166,135"] = { ["143,155"] = 154, ["162,186"] = 164, ["147,121"] = 83, ["147,143"] = 110, },
                ["129,93"] = { ["123,72"] = 79, ["172,66"] = 177, ["137,63"] = 93, ["159,86"] = 114, ["164,99"] = 154, ["129,25"] = 200, ["147,121"] = 134, ["148,73"] = 117, ["147,143"] = 217, },
                ["143,155"] = { ["140,193"] = 108, ["166,135"] = 163, ["162,186"] = 115, ["147,143"] = 90, },
                ["162,186"] = { ["140,193"] = 88, ["143,155"] = 127, ["156,205"] = 73, ["166,135"] = 171, ["147,143"] = 272, },
                ["184,331"] = { ["193,255"] = 229, ["193,229"] = 266, },
                ["147,143"] = { ["140,193"] = 216, ["150,213"] = 258, ["193,229"] = 350, ["129,93"] = 201, ["156,205"] = 241, ["184,331"] = 428, ["143,155"] = 115, ["162,186"] = 204, ["147,121"] = 85, ["166,135"] = 102, },
            },
            [3] = {
                ["165,174"] = { ["204,149"] = 88, ["118,174"] = 82, },
                ["245,51"] = { ["219,54"] = 43, },
                ["132,221"] = { ["182,256"] = 85, ["99,231"] = 61, ["118,174"] = 73, ["133,253"] = 54, },
                ["204,149"] = { ["175,82"] = 119, ["138,115"] = 121, ["248,158"] = 66, ["236,176"] = 57, ["165,174"] = 77, },
                ["248,158"] = { ["165,174"] = 117, ["236,176"] = 28, ["204,149"] = 74, },
                ["236,176"] = { ["204,149"] = 59, ["248,158"] = 33, },
                ["99,231"] = { ["198,287"] = 155, ["118,174"] = 83, ["133,253"] = 52, ["182,256"] = 120, ["132,221"] = 58, ["84,196"] = 76, },
                ["118,174"] = { ["165,174"] = 82, ["138,115"] = 98, ["132,221"] = 69, ["84,196"] = 64, ["99,231"] = 92, ["86,90"] = 126, },
                ["182,256"] = { ["198,287"] = 49, ["99,231"] = 127, ["133,253"] = 82, ["132,221"] = 90, ["227,253"] = 67, },
                ["86,90"] = { ["175,82"] = 123, ["118,174"] = 128, ["138,115"] = 89, },
                ["198,287"] = { ["182,256"] = 56.35, ["99,231"] = 155, ["227,253"] = 70, },
                ["255,80"] = { ["219,54"] = 82, },
                ["138,115"] = { ["118,174"] = 85, ["175,82"] = 77, ["204,149"] = 112, ["86,90"] = 89, },
                ["133,253"] = { ["182,256"] = 78, ["99,231"] = 56, ["132,221"] = 45, },
                ["219,54"] = { ["255,80"] = 85, ["175,82"] = 102, ["245,51"] = 44, },
                ["84,196"] = { ["118,174"] = 54, ["99,231"] = 66, },
                ["175,82"] = { ["219,54"] = 80, ["204,149"] = 98, ["138,115"] = 76, ["86,90"] = 150, },
                ["227,253"] = { ["182,256"] = 66, ["198,287"] = 58, },
            },
            [4] = {
                ["38,166"] = { ["52,166"] = 31, },
                ["52,166"] = { ["38,166"] = 25, ["65,178"] = 25, ["68,136"] = 46, },
                ["55,212"] = { ["65,178"] = 117, ["77,210"] = 77, ["88,254"] = 138, },
                ["65,178"] = { ["52,166"] = 45, ["55,212"] = 77, ["68,136"] = 71, ["77,210"] = 64, ["91,151"] = 66, ["133,164"] = 65.3, },
                ["68,136"] = { ["52,166"] = 64, ["65,178"] = 76.5, ["91,151"] = 64, ["133,164"] = 147, },
                ["77,210"] = { ["55,212"] = 65, ["65,178"] = 210.35, ["88,254"] = 140, ["129,201"] = 225, ["165,217"] = 302, },
                ["88,254"] = { ["55,212"] = 119, ["77,210"] = 118, ["119,276"] = 95, ["129,201"] = 173, ["164,230"] = 174.175, },
                ["91,151"] = { ["65,178"] = 80, ["68,136"] = 61, ["133,164"] = 99, ["155,148"] = 119, },
                ["119,276"] = { ["88,254"] = 78, ["129,201"] = 142, ["175,225"] = 135, ["156,277"] = 77, ["164,230"] = 122, ["181,277"] = 122, },
                ["129,201"] = { ["77,210"] = 137, ["88,254"] = 167, ["119,276"] = 162, ["133,164"] = 81, ["145,189"] = 50, ["164,230"] = 110, ["165,217"] = 91, },
                ["133,164"] = { ["68,136"] = 133, ["91,151"] = 100, ["129,201"] = 67, ["145,189"] = 83, ["155,148"] = 72, ["169,168"] = 90, ["188,169"] = 0, },
                ["145,189"] = { ["129,201"] = 61, ["133,164"] = 74, ["165,217"] = 67.35, ["169,168"] = 66, ["188,169"] = 88, ["200,203"] = 120, },
                ["155,148"] = { ["91,151"] = 133, ["133,164"] = 56, ["165,217"] = 123, ["169,168"] = 49, ["188,169"] = 86, ["233,102"] = 186, },
                ["156,277"] = { ["119,276"] = 87, ["165,217"] = 141, ["164,230"] = 74, ["181,277"] = 51, },
                ["164,230"] = { ["88,254"] = 168, ["119,276"] = 124, ["129,201"] = 108, ["156,277"] = 98, ["165,217"] = 72, ["175,225"] = 36.175, },
                ["165,217"] = { ["77,210"] = 212, ["129,201"] = 116, ["145,189"] = 101, ["155,148"] = 160, ["156,277"] = 124, ["164,230"] = 40, ["169,168"] = 121, ["175,225"] = 116, ["184,199"] = 54, ["195,225"] = 59, ["200,203"] = 82, },
                ["169,168"] = { ["133,164"] = 45, ["145,189"] = 40, ["155,148"] = 37, ["165,217"] = 0, ["188,169"] = 66.35, ["200,203"] = 73.35, },
                ["175,225"] = { ["119,276"] = 148, ["164,230"] = 29, ["165,217"] = 33, ["179,236"] = 41, },
                ["179,236"] = { ["175,225"] = 34, ["181,277"] = 66, ["195,225"] = 49, ["201,286"] = 99, },
                ["181,277"] = { ["119,276"] = 0, ["156,277"] = 61, ["179,236"] = 79, ["201,286"] = 113, },
                ["184,199"] = { ["165,217"] = 49, ["188,169"] = 77, ["195,225"] = 0, ["200,203"] = 48.175, },
                ["188,169"] = { ["133,164"] = 0, ["145,189"] = 97, ["155,148"] = 100, ["169,168"] = 55, ["184,199"] = 72, ["200,203"] = 65, ["219,203"] = 90, ["230,163"] = 78, ["241,115"] = 127, },
                ["195,225"] = { ["165,217"] = 0, ["179,236"] = 0, ["184,199"] = 0, ["200,203"] = 45.35, ["227,251"] = 101, },
                ["200,203"] = { ["145,189"] = 112, ["165,217"] = 68, ["169,168"] = 92, ["184,199"] = 35, ["188,169"] = 62, ["195,225"] = 41, ["219,203"] = 46, ["228,210"] = 65, },
                ["201,286"] = { ["179,236"] = 0, ["181,277"] = 49, ["227,251"] = 105, ["247,216"] = 104.35, },
                ["219,203"] = { ["188,169"] = 84, ["200,203"] = 41, ["228,210"] = 45, ["230,163"] = 84, },
                ["227,251"] = { ["195,225"] = 89, ["201,286"] = 86, ["247,216"] = 90, },
                ["228,210"] = { ["200,203"] = 54, ["219,203"] = 25, ["247,216"] = 42, ["261,189"] = 72, },
                ["230,163"] = { ["188,169"] = 83, ["219,203"] = 67, ["241,115"] = 84, ["261,189"] = 84, ["277,141"] = 117, },
                ["233,102"] = { ["155,148"] = 195, ["241,115"] = 37, ["276,97"] = 81, },
                ["241,115"] = { ["188,169"] = 152, ["230,163"] = 78, ["233,102"] = 52, ["276,97"] = 70, ["277,141"] = 86, },
                ["247,216"] = { ["201,286"] = 155, ["227,251"] = 86, ["228,210"] = 54, ["258,241"] = 54, ["261,189"] = 57, },
                ["258,241"] = { ["247,216"] = 57, },
                ["261,189"] = { ["228,210"] = 83, ["230,163"] = 80, ["247,216"] = 74, ["277,141"] = 86, },
                ["276,97"] = { ["233,102"] = 97, ["241,115"] = 71, ["277,141"] = 71.5, },
                ["277,141"] = { ["230,163"] = 97, ["241,115"] = 81, ["261,189"] = 98.5, ["276,97"] = 74, },
            },
        };
    end
    e:SetScript("OnEvent", function()
    end)
    e:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ze = nil
    collectgarbage();
end

local function jt(i, l, e, o, n)
    if (e <= 0) then
        e = 360 + e
    end
    local t = i.tableSin[e]
    local e = i.tableCos[e]
    l:SetTexCoord(o - t, n + e, o + e, n + t, o - e, n - t, o + t, n - e);
end

local function T(r)
    local i, i, l, t
    if (r == true) and ((bCrowbar == nil) or ((bCrowbar) and (not bCrowbar.jewelEdit))) then
        l = "Hide"
    else
        l = "Show";
    end
    Bejeweled.paused = r
    local i = n.gameMode
    for n = 1, a do
        for e = 1, h do
            t = o[n][e]
            if (i == c) or (i == k) then
                if (l == "Hide") then
                    if not (t.oldAlphaJewel) then
                        t.oldAlphaJewel = t:GetAlpha()
                        t:SetAlpha(t.oldAlphaJewel / 2);
                    end
                else
                    t:SetAlpha((t.oldAlphaJewel or (.5)) * 2)
                    t.oldAlphaJewel = nil;
                end
            else
                t[l](t);
            end
        end
    end
    if (i == k) then
        Bejeweled.animator:Show()
    else
        Bejeweled.animator[l](Bejeweled.animator)
        if (i == ae) then
            if (l == "Show") then
                Bejeweled.pausedText:Hide()
            else
                Bejeweled.pausedText:Show();
            end
        end
    end
    local o = Bejeweled.animator.animationStack
    for n = 0, #o do
        if (n == 0) then
            t = Bejeweled.animator.hintObj
        else
            t = o[n];
        end
        if (t) then
            if (r == true) then
                if (i == c) or (i == k) then
                    if (t:IsShown()) then
                        t.wasShown = true
                        if not t.oldAlpha then
                            t.oldAlpha = t:GetAlpha()
                            if not (t.contents) then
                                t:SetAlpha(t.oldAlpha / 2);
                            end
                        end
                    end
                else
                    if (t:IsShown()) then
                        t.wasShown = true
                        t:Hide();
                    end
                end
            else
                if (i == c) then
                    if (t.wasShown) then
                        t.wasShown = nil
                        if not (t.contents) then
                            t:SetAlpha((t.oldAlpha or (.5)) * 2);
                        end
                        t.oldAlpha = nil;
                    end
                else
                    if (t.wasShown) then
                        t.wasShown = nil
                        t:Show();
                    end
                end
            end
        end
    end
    if (r) and (i ~= k) then
        Bejeweled.levelBar.timer:Hide()
    else
        if not n.gameOver and (n.gameMode) then
            Bejeweled.levelBar.timer:Show()
        else
            Bejeweled.levelBar.timer:Hide();
        end
    end
end

function Bejeweled:UpdateFlightTimes()
    local t = Bejeweled.flightOptionWindow
    if (#t.pathArray > 0) then
        local o = d(t.timer.legJourney + .75)
        local n = B(t.pathArray, 1)
        local i = B(t.pathArray, 1)
        local l = B(t.pathArray, 1)
        if (#t.pathArray > 0) then
            o = o + 1.35
        end
        SetMapToCurrentZone()
        local e = GetCurrentMapContinent()
        if (l == 0) or (math.abs(o - l) > 5) then
            BejeweledData.flightTimes[e] = BejeweledData.flightTimes[e] or {}
            BejeweledData.flightTimes[e][n] = BejeweledData.flightTimes[e][n] or {} BejeweledData.flightTimes[e][n][i] = o
        else
            BejeweledData.flightTimes[e] = BejeweledData.flightTimes[e] or {}
            BejeweledData.flightTimes[e][n] = BejeweledData.flightTimes[e][n] or {} BejeweledData.flightTimes[e][n][i] = ((BejeweledData.flightTimes[e][n][i] or (o)) + o) / 2;
        end
    end
    t.timer.legJourney = 0;
end

function Bejeweled:LoadAchievementEvents()
    local o = BejeweledProfile.skill
    if (o.gainFun14) then
        BejeweledData.gainFun14 = true;
    end
    if (BejeweledData.gainFun14) then
        o.gainFun14 = true;
    end
    BejeweledData.played = BejeweledData.played or {}
    BejeweledData.played[UnitName("player")] = BejeweledProfile.skill.games
    local t, t
    for t, e in pairs(BejeweledData.played) do
        K = K + e;
    end
    local t = CreateFrame("Frame", "BejeweledEventWatcher", UIParent)
    t:SetWidth(1)
    t:SetHeight(1)
    t:SetPoint("Top")
    t:Show()
    t.eventList = {}
    t:SetScript("OnEvent", function(i, o, ...)
        if n.gameMode and Bejeweled.window:IsVisible() then
            local l, e, n
            e = 1
            for l = 1, #t.eventList[o] do
                n = t.eventList[o][e](i, o, ...)
                if (n == true) then
                    B(i.eventList[o], e)
                else
                    e = e + 1;
                end
            end
            if #t.eventList[o] == 0 then
                t.eventList[o] = nil
                i:UnregisterEvent(o);
            end
        end
    end)
    t.AddEvent = function(t, e, n)
        t.eventList[e] = t.eventList[e] or {} u(t.eventList[e], n)
        t:RegisterEvent(e)
    end
    if not o.gainFun1 then
        t:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function(t, t, ...)
            local n = 0
            local t = select(2, ...)
            if (t == "ENVIRONMENTAL_DAMAGE") then
                unitName, _, t, damageAmount = select(7, ...)
                if (t == "FALLING") and (unitName == UnitName("player")) and (damageAmount) then
                    local t = UnitHealth("player") - damageAmount
                    if UnitIsDeadOrGhost("player") or (UnitHealth("player") < 2) or (t <= 0) then
                        n = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK1A);
                    end
                end
            end
            return (n ~= 0)
        end);
    end
    if not o.gainFun2 then
        t:AddEvent("UPDATE_BATTLEFIELD_STATUS", function(t, t, ...)
            local t = 0
            local n
            for n = 1, MAX_BATTLEFIELD_QUEUES do
                bgStatus = GetBattlefieldStatus(n)
                if (bgStatus == "queued") then
                    t = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK1B);
                end
            end
            return (t ~= 0)
        end);
    end
    if not o.gainFun3 then
        Bejeweled.lootText = string.gsub(LOOT_ITEM_SELF, "%%s", "(.*)")
        t:AddEvent("CHAT_MSG_LOOT", function(t, t, ...)
            local n = 0
            local t, o = select(1, ...)
            if (string.find(t, Bejeweled.lootText)) then
                t = string.match(t, Bejeweled.lootText) or ("")
                local t = select(3, GetItemInfo(t))
                if (t == 3) then
                    n = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK2A);
                end
            end
            return (n ~= 0)
        end);
    end
    if not o.gainFun4 then
        t:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function(t, t, ...)
            local t = 0
            local i, o, l, l, n = select(2, ...)
            if (i == "PARTY_KILL") and (o == UnitGUID("player")) and (n == UnitGUID("target")) then
                if UnitCreatureType("target") == "Critter" then
                    t = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK2B);
                end
            end
            return (t ~= 0)
        end);
    end
    if not o.gainFun5 then
        t:AddEvent("RESURRECT_REQUEST", function(t, t, ...)
            local e = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK2C)
            return (e ~= 0)
        end);
    end
    if not o.gainFun6 then
        Bejeweled.lootText = string.gsub(LOOT_ITEM_SELF, "%%s", "(.*)")
        t:AddEvent("CHAT_MSG_LOOT", function(t, t, ...)
            local n = 0
            local t, o = select(1, ...)
            if (string.find(t, Bejeweled.lootText)) then
                t = string.match(t, Bejeweled.lootText) or ("")
                local t = select(3, GetItemInfo(t))
                if (t == 4) then
                    n = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK3A);
                end
            end
            return (n ~= 0)
        end);
    end
    if not o.gainFun7 then
        hooksecurefunc("ConfirmReadyCheck", function(t)
            if not o.gainFun7 then
                if (t) then
                    skillTrigger = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK3B);
                end
            end
        end);
    end
    if not o.gainFun8 then
        t:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function(t, t, ...)
            local o = 0
            local t, l, l, l, l, i, l, l, n = select(2, ...)
            if (i == UnitName("player")) and (t ~= "FALLING") and (n) then
                if (t == "SWING_DAMAGE") or (t == "RANGE_DAMAGE") or (t == "SPELL_DAMAGE") or (t == "SPELL_PERIODIC_DAMAGE") then
                    n = D(n) or (0)
                    local t = UnitHealth("player") - n
                    if (t <= 0) or UnitIsDeadOrGhost("player") or (UnitHealth("player") <= 2) then
                        o = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK3C);
                    end
                end
            end
            return (o ~= 0)
        end);
    end
    if not o.gainFun9 then
        t:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function(t, t, ...)
            local t = 0
            local i, n, l, l, o = select(2, ...)
            if (i == "PARTY_KILL") and (n == UnitGUID("player")) and (o == UnitGUID("target")) then
                if UnitClassification("target") == "elite" then
                    t = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK4A);
                end
            end
            return (t ~= 0)
        end);
    end
    if not o.gainFun10 then
        t:AddEvent("RAID_INSTANCE_WELCOME", function(t, t, ...)
            local e = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK4B)
            return (e ~= 0)
        end);
    end
    if not o.gainFun11 then
        Bejeweled.repText = string.gsub(FACTION_STANDING_CHANGED, "%%s", "(.*)") t:AddEvent("CHAT_MSG_SYSTEM", function(t, t, ...)
            local t = 0
            local n = select(1, ...)
            if string.find(n, Bejeweled.repText) then
                t = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK4C);
            end
            return (t ~= 0)
        end);
    end
    if not o.gainFun12 then
        t:AddEvent("CHAT_MSG_COMBAT_HONOR_GAIN", function(t, t, ...)
            local e = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK5A)
            return (e ~= 0)
        end);
    end
    if not o.gainFun13 then
        t:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function(t, t, ...)
            local n = 0
            local t, o, l, l, i = select(2, ...)
            if (t == "PARTY_KILL") and (o == UnitGUID("player")) and (i == UnitGUID("target")) then
                local t = UnitClassification("target")
                if (t == "rare") or (t == "rareelite") then
                    n = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK5B);
                end
            end
            return (n ~= 0)
        end);
    end
    if (not o.gainFun14) then
        t:AddEvent("PLAYER_LEVEL_UP", function(t, t, ...)
            local e = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK6A)
            return (e ~= 0)
        end);
    end
    if (not o.gainFun15) then
        t:AddEvent("UPDATE_BATTLEFIELD_SCORE", function(t, t, ...)
            local n = 0
            local t
            teamName1, oldTeamRating1, newTeamRating1 = GetBattlefieldTeamInfo(0)
            teamName2, oldTeamRating2, newTeamRating2 = GetBattlefieldTeamInfo(1)
            if (oldTeamRating1 ~= 0) and (oldTeamRating2 ~= 0) then
                if (teamName1 == GetArenaTeam(1)) or (teamName1 == GetArenaTeam(2)) or (teamName1 == GetArenaTeam(3)) then
                    if (oldTeamRating1 < newTeamRating1) then
                        t = true;
                    end
                elseif (teamName2 == GetArenaTeam(1)) or (teamName2 == GetArenaTeam(2)) or (teamName2 == GetArenaTeam(3)) then
                    if (oldTeamRating2 < newTeamRating2) then
                        t = true;
                    end
                end
            end
            if t then
                n = Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_FUN, Bejeweled.const.SKILL_FUNRANK6B);
            end
            return (n ~= 0)
        end);
    end
end

function Bejeweled:VariablesLoaded()
    if IsInGuild() then
        GuildRoster();
    end
    BejeweledProfile.skill.friendList = BejeweledProfile.skill.friendList or { c = 0 }
    BejeweledProfile.skill.guildList = BejeweledProfile.skill.guildList or { c = 0 }
    Bejeweled:UpdateSavedVariablesDatabase()
    Bejeweled:Initialize_OptionsScreen()
    Bejeweled:LoadAchievementEvents()
    Bejeweled.LoadAchievementEvents = nil
    Bejeweled.Initialize_OptionsScreen = nil
    Bejeweled.CreateCheckbox = nil
    Bejeweled.CreateCheckbox_OnClick = nil
    Bejeweled.CreateSlider = nil
    Bejeweled.CreateSlider_OnValueChanged = nil
    if (BejeweledProfile.settings.openLogin) then
        Bejeweled.menuWindow:Hide()
    else
        Bejeweled.window:Hide();
    end
    if not BejeweledProfile.settings.hideMinimap then
        Bejeweled.minimap:Show()
    else
        Bejeweled.minimap:Hide();
    end
    if (BejeweledProfile.settings.minimapDetached == nil) then
        Bejeweled.minimap:SetPoint("Center", Minimap, "Center", -(76 * math.cos(math.rad(BejeweledProfile.settings.minimapAngle or (0)))), (76 * math.sin(math.rad(BejeweledProfile.settings.minimapAngle or (0))))) else
        Bejeweled.minimap:SetPoint("Center", UIParent, "bottomleft", BejeweledProfile.settings.minimapX, BejeweledProfile.settings.minimapY);
    end
    Bejeweled.VariablesLoaded = nil
    if Bejeweled.skillLimit ~= true then
        if (BejeweledProfile.skill.skillPoints == 375) and (BejeweledProfile.skill.rank == 5) then
        end
    end
    if (Bejeweled_Fu) then
        Bejeweled_Fu.game = Bejeweled.window;
    end
    if (Bejeweled_Titan) then
        Bejeweled_Titan.game = Bejeweled.window;
    end
end

function Bejeweled:ShowLegal()
    Bejeweled.window:SetWidth(q)
    Bejeweled.window:SetHeight(me)
    Bejeweled.window:ClearAllPoints()
    Bejeweled.window:SetPoint("Center")
    Bejeweled.window:SetAlpha(1)
    Bejeweled.window.splash.firstGame = true
    local t = CreateFrame("Frame", "BejeweledLegalPopup", Bejeweled.window)
    t:SetWidth(f * 2)
    t:SetHeight(L + 32)
    t:SetToplevel(true)
    t:SetFrameStrata("High") t:SetPoint("Center")
    t:EnableMouse(true)
    local n = C()
    n.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" n.bgFile = l .. "windowBackground"
    n.edgeSize = 32
    n.tileSize = 128
    n.insets.top = 3
    t:SetBackdrop(n)
    t:SetBackdropColor(.6, .6, .6, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetMovable(true)
    local n = t:CreateFontString(nil, "Overlay")
    n:SetFont(STANDARD_TEXT_FONT, 12, "Outline")
    n:SetTextColor(1, 1, 1)
    n:SetPoint("Top", 0, -38)
    n:SetWidth(f * 1.8)
    n:SetText("Bejeweled\n\n\n" .. "(c)2000, 2008 PopCap Games, Inc.  All rights reserved.  This application is " .. "being made available free of charge for your personal, non-commercial entertainment " .. 'use, and is provided "as is", without any warranties.  PopCap Games, Inc. will have ' .. "no liability to you or anyone else if you choose to use it.  See readme.txt for details.")
    n:Show()
    local t = CreateFrame("Button", "", t, "OptionsButtonTemplate") t:SetPoint("Bottom", 0, 16)
    t:SetText(OKAY)
    t:SetScript("OnClick", function(t)
        t:GetParent():Hide()
        BejeweledData.legalDisplayed = true
        Bejeweled.window.splash.elapsed = 0
    end)
end

local function Ee(e, t, n, e)
    if (t == "") then
        return
    end
    local e
    if (n == "WHISPER") then
        e = BejeweledProfile.scoreList.friends
    else
        e = BejeweledProfile.scoreList.guild
    end
    j(e, strsplit("*", t));
end

function Bejeweled:CheckName(o, n)
    if (n ~= "PopCap Games") then
        local t = BejeweledProfile.skill[o]
        if (o == "friendList") and not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE5B] then
            if not t[n] then
                t[n] = true
                t.c = t.c + 1
                if (t.c > 10) then
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE5B);
                end
            end
        elseif (o == "guildList") and not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE6B] then
            if not t[n] then
                t[n] = true
                t.c = t.c + 1
                if (t.c > 10) then
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE6B);
                end
            end
        end
    end
end

local function dt(l, a)
    local i, n, o, i, i, t
    local i = UnitName("player")
    if (a == "WHISPER") then
        n = BejeweledProfile.scoreList.friends
        t = ""
        for a = 1, 10 do
            o = n.classic[a][1]
            Bejeweled:CheckName("friendList", o)
            if (o == i) then
                if (t ~= "") then
                    t = t .. "*";
                end
                t = t .. n.classic[a][2] .. i .. "*" .. (n.classic[a][4] or "")
            end
            if (string.len(t) > 180) then
                Bejeweled.network:Send("HSSync", t, "WHISPER", l)
                t = "";
            end
            o = n.timed[a][1]
            Bejeweled:CheckName("friendList", o)
            if (o == i) then
                if (t ~= "") then
                    t = t .. "*";
                end
                t = t .. n.timed[a][2] .. i .. "*" .. (n.timed[a][4] or "")
            end
            if (string.len(t) > 180) then
                Bejeweled.network:Send("HSSync", t, "WHISPER", l)
                t = "";
            end
        end
        if (t ~= "") then
            Bejeweled.network:Send("HSSync", t, "WHISPER", l);
        end
    else
        n = BejeweledProfile.scoreList.guild
        t = ""
        local r = 0
        local d
        for a = 1, GetNumGuildMembers(true) do
            i = GetGuildRosterInfo(a)
            d = nil
            for a = 1, 10 do
                o = n.classic[a][1]
                if (o == i) then
                    d = true
                    if (t ~= "") then
                        t = t .. "*";
                    end
                    t = t .. n.classic[a][2] .. i .. "*" .. (n.classic[a][4] or "") r = r + 1;
                end
                if (string.len(t) > 180) then
                    Bejeweled.network:Send("HSSync", t, "GUILD", l)
                    t = "";
                end
                o = n.timed[a][1]
                if (o == i) then
                    d = true
                    if (t ~= "") then
                        t = t .. "*";
                    end
                    t = t .. n.timed[a][2] .. i .. "*" .. (n.timed[a][4] or "") r = r + 1;
                end
                if (string.len(t) > 180) then
                    Bejeweled.network:Send("HSSync", t, "GUILD", l)
                    t = "";
                end
            end
            if (d) then
                Bejeweled:CheckName("guildList", i);
            end
            if (r >= 20) then
                break
            end
        end
        if (t ~= "") then
            Bejeweled.network:Send("HSSync", t, "GUILD", l);
        end
    end
end

function Bejeweled:ScrubLists()
    local l, d, d, i, o, d, d, n, t, a, r
    local S = UnitName("player")
    for d = 1, 2 do
        if (d == 1) then
            n = BejeweledProfile.scoreList.friends
        else
            n = BejeweledProfile.scoreList.guild;
        end
        for s = 1, 2 do
            if (s == 1) then
                o = 1e3
                scoreOffset = 100
                t = "classic"
            else
                o = 2.8
                scoreOffset = .2
                t = "timed";
            end
            if (BejeweledProfile.settings.hideDuplicates) then
                Bejeweled.nameList = Bejeweled.nameList or {} for t, n in pairs(Bejeweled.nameList) do
                    Bejeweled.nameList[t] = nil;
                end
                l = 1
                for a = 1, 10 do
                    i = n[t][l][1]
                    if (i ~= "PopCap Games") then
                        if not Bejeweled.nameList[i] then
                            Bejeweled.nameList[i] = true
                        else
                            if (l < 10) then
                                for e = l, 9 do
                                    n[t][e][1] = n[t][e + 1][1]
                                    n[t][e][2] = n[t][e + 1][2]
                                    n[t][e][3] = n[t][e + 1][3]
                                    if (n[t][e][1] == "PopCap Games") then
                                        o = n[t][e][3] - scoreOffset;
                                    end
                                end
                                l = l - 1;
                            end
                            n[t][10][1] = "PopCap Games"
                            n[t][10][2] = 1
                            n[t][10][3] = o;
                        end
                    end
                    l = l + 1;
                end
            end
            if (s == 1) then
                o = 1e3
                scoreOffset = 100
            else
                o = 2.8
                scoreOffset = .2;
            end
            for e = 1, 10 do
                i = n[t][e][1]
                if (i ~= "PopCap Games") and (i ~= S) then
                    a = nil
                    if (d == 1) then
                        for e = 1, GetNumFriends() do
                            r = GetFriendInfo(e)
                            if (i == r) then
                                a = true
                                break;
                            end
                        end
                    else
                        for e = 1, GetNumGuildMembers(true) do
                            r = GetGuildRosterInfo(e)
                            if (i == r) then
                                a = true
                                break;
                            end
                        end
                    end
                    if not a then
                        for e = e, 9 do
                            n[t][e][1] = n[t][e + 1][1]
                            n[t][e][2] = n[t][e + 1][2]
                            n[t][e][3] = n[t][e + 1][3]
                            if (n[t][e][1] == "PopCap Games") then
                                o = n[t][e][3] - scoreOffset;
                            end
                        end
                        n[t][10][1] = "PopCap Games"
                        n[t][10][2] = 1
                        n[t][10][3] = o
                        o = o - scoreOffset;
                    end
                end
            end
        end
    end
end

local function St()
    local t, t, i
    local t = BejeweledProfile.settings.savedState
    if not t then
        BejeweledProfile.settings.savedState = {}
        t = BejeweledProfile.settings.savedState
        for e = 1, a + 1 do
            t[e] = {};
        end
    end
    for n = 1, a do
        for e = 1, h do
            i = o[n][e].contents
            if (o[n][e].bigStar) then
                i = i + 10;
            end
            t[n][e] = i;
        end
    end
    t = t[a + 1]
    local n = n
    t[1] = n.score
    t[2] = n.pointsToLevelUp
    t[3] = n.level
    t[4] = n.moves
    t[5] = n.largestCascade
    t[6] = n.largestCombo
    t[7] = Bejeweled.levelBar.timer.timeElapsed
    t[8] = n.pointMultiplier
    t[9] = P(x(t[1], 4), H(UnitName("player")));
end

function Bejeweled:NumberWithCommas(e)
    local e = string.gsub(e, "(%d)(%d%d%d)$", "%1,%2") local t
    while true do
        e, t = string.gsub(e, "(%d)(%d%d%d),", "%1,%2,") if t == 0 then
            break
        end
    end
    return e
end

function Bejeweled:SecondsConvert(e)
    local t = d(e / 60)
    e = math.ceil(e - (t * 60))
    return t, e
end

local function Q(e, n, o)
    local t
    for n, o in pairs(e) do
        t = R(o)
        if (t == "number") then
            e[n] = nil;
        end
    end
    e.markX = nil
    e.markY = nil
    e.spawnHyper = nil
    e.adj = nil
    e.swapJewel = nil
    e.x = (n - 1) * b
    e.y = (o - 1) * p
    e.gridX = n
    e.gridY = o
    e.texture:SetTexCoord(unpack(F[1]))
    e.texture:SetWidth(b)
    e.texture:SetHeight(p)
    e.fxType = E
    e.fxFrame = 1
    e:Show()
    e:SetAlpha(1)
    e:ClearAllPoints()
    e:SetWidth(b)
    e:SetHeight(p)
    e:SetPoint("Topleft", e.x, -e.y)
    e.selector:Hide()
    e.glowLevel = 0;
end

local function Ke()
    local n, n, t
    local n = Bejeweled.animator
    for i = 1, a do
        for e = 1, h do
            t = o[i][e]
            if (t.fxType ~= g) then
                t.fxType = y
            else
                t.wasHyper = true
                t.contents = 0
                t.hyperGemContents = nil;
            end
            t.moving = at
            t.yVel = (4 - m(1, 5) / 2) t.xVel = ((m(1, 11) - 6) / 2)
            n:Add(t);
        end
    end
end

local function de(t, n, f, i)
    local p, p, p, p, s, p, c, d, S, e
    e = m(1, 7)
    if not i then
        Q(o[n][t], t, n)
        o[n][t].contents = 0;
    end
    if (f) then
        for i = 1, 7 do
            c = true
            for i = 1, 6 do
                s = 0
                S = r[i][4]
                if S == 0 then
                    S = 1;
                end
                for l = r[i][3], r[i][4] * 2, math.ceil(S) do
                    d = r[i][2]
                    if d == 0 then
                        d = 1;
                    end
                    for i = r[i][1], r[i][2] * 2, math.ceil(d) do
                        if (n + l) > 0 and (n + l) <= a then
                            if (t + i) > 0 and (t + i) <= h then
                                if o[n + l][t + i].contents == e then
                                    s = s + 1;
                                end
                            end
                        end
                    end
                end
                if (s > 1) then
                    e = e + 1
                    if e > 7 then
                        e = 1;
                    end
                    c = false
                    break;
                end
            end
            if c == true then
                break;
            end
        end
    end
    local t = o[n][t] t.contents = e
    t.texture:SetTexture(l .. "gem_" .. U[e])
    t.texture:SetTexCoord(unpack(F[1]))
    t.highlight:SetTexture(l .. "shine_" .. U[e])
    t.highlight:SetTexCoord(0, 0, 0, 0)
    if not f then
        BejeweledProfile.stats.totalGemsMatched = BejeweledProfile.stats.totalGemsMatched + 1;
    end
end

local function R(t)
    if (t.contents) and (t.contents > 0) and (t.contents <= 7) then
        t.texture:SetTexture(l .. "gem_" .. U[t.contents])
        t.texture:SetTexCoord(unpack(F[1]))
        t.highlight:SetTexture(l .. "shine_" .. U[t.contents])
        t.highlight:SetTexCoord(0, 0, 0, 0)
        t.glow:SetTexture(l .. "highlight_" .. U[t.contents])
        t.glow:SetTexCoord(0, 1, 0, 1)
    else
        if (t.contents == 9) then
            Bejeweled.animator:CreateHyperGem(t)
        else
            t.texture:SetTexCoord(0, 0, 0, 0)
            t.glow:SetTexCoord(0, 0, 0, 0);
        end
    end
end

local function j(l, s, r)
    local d, d, i, t
    local d = UnitName("player")
    t = n
    t.gameOver = false
    t.paused = false
    t.score = 0
    t.combo = 0
    t.level = 1
    t.moveAllowed = true
    t.selectedJewel = nil
    t.pointsToLevelUp = 500 * Ce[l]
    t.gameMode = l
    t.explosions = 0
    t.bigStarSpawn = 0
    t.hyperSpawn = 0
    t.moves = 0
    t.gemsCleared = 0
    if (Bejeweled.window.splash.firstGame == true) then
        Bejeweled.window.splash.firstGame = nil
        Bejeweled.window.splash:Hide();
    end
    for t = 1, #Bejeweled.animator.animationStack do
        i = Bejeweled.animator.animationStack[1] if (i.fxType == ye) then
            u(Bejeweled.animator.bigStarQueue, i)
            i:ClearAllPoints()
            i:SetAlpha(0)
            if (i.parent) then
                i.parent.bigStar = nil;
            end
            i.parent = nil
            i:Hide()
        elseif (i.fxType == Oe) then
            u(Bejeweled.animator.explosionQueue, i)
            i:Hide()
        elseif (i.fxType == te) then
            u(Bejeweled.animator.floatingTextQueue, i)
            i:Hide()
        elseif (i.fxType == He) then
            u(Bejeweled.animator.shardQueue, i)
            i:Hide()
        elseif (i.fxType == De) then
            u(Bejeweled.animator.lightwaveQueue, i)
            i:GetParent().lightWaveObj = nil
            i:Hide()
        elseif (i.fxType == We) then
            u(Bejeweled.animator.lightningQueue, i)
            i.highlight:Hide()
            i:Hide();
        end
        B(Bejeweled.animator.animationStack, 1) i.animated = nil;
    end
    for t = 1, a do
        for e = 1, h do
            Q(o[t][e], e, t)
            o[t][e].wasHyper = nil;
        end
    end
    if (Bejeweled_Fu) then
        Bejeweled_Fu.currentMode = l;
    end
    if (Bejeweled_Titan) then
        Bejeweled_Titan.currentMode = l;
    end
    if (l == c) then
        t.statDB = BejeweledProfile.stats.classic
        if (t.statDB.highestLevel == 0) then
            t.statDB.highestLevel = 1;
        end
        BejeweledProfile.settings.classicInProgress = true
    else
        BejeweledProfile.settings.classicInProgress = nil
        t.statDB = BejeweledProfile.stats.timed;
    end
    t.largestCascade = 0
    t.largestCombo = 0
    t.leveledUp = nil
    t.levelingUp = nil
    Bejeweled.pausedText:Hide()
    Bejeweled.flightOptionWindow.learning = nil
    Bejeweled.levelBar:SetMode(l, s)
    Bejeweled.animator.newGameStart = true
    Bejeweled.animator.countdownState = 4
    t.moveAllowed = nil
    if (l == ae) then
        Bejeweled.levelBar:StopTimer()
    elseif (l == k) then
        Bejeweled.animator.countdownState = 0
        t.moveAllowed = nil;
    end
    Bejeweled.gameStatusText:Hide()
    Bejeweled.gameStatusText.background:Hide()
    Bejeweled.summaryScreen:Hide()
    Bejeweled.summaryScreen.bragScreen:Hide() Bejeweled.aboutScreen:Hide()
    Bejeweled.featsOfSkillScreen:Hide()
    Bejeweled.optionsScreen:Hide()
    Bejeweled.levelBarButton:Hide()
    Bejeweled.levelBarButton:SetID(0)
    Bejeweled.levelBarButton.text:SetText("Return to Game")
    Bejeweled.animator.spawningLevel = true
    Bejeweled.animator.animationStatus = pe
    Bejeweled.animator.spawnedJewels = nil
    Bejeweled.animator.hintObj:Hide()
    Bejeweled.animator.hintObj:ClearAllPoints()
    if (math) and (math.randomseed) then
        math.randomseed(math.random(0, 214748364) + (GetTime() * 1e3));
    end
    for e = 1, a do
        de(e, e, true)
        o[e][e].contents = 0
        for t = e + 1, h do
            de(t, e, true)
            o[e][t].contents = 0;
        end
        for t = e + 1, a do
            de(e, t, true)
            o[t][e].contents = 0;
        end
    end
    if (r) then
        Bejeweled.animator.spawningLevel = nil
        Bejeweled.animator.animationStatus = V
        local n = BejeweledProfile.settings.savedState
        local l
        local r = Bejeweled.animator
        for e = 1, a do
            for t = 1, h do
                i = o[e][t]
                l = n[e][t]
                if (l < 9) then
                    i.contents = l
                elseif (l == 9) then
                    r:CreateHyperGem(i)
                    r:Add(i)
                else
                    i.contents = l - 10
                    i.bigStar = r:CreateBigStar(0, 0, i)
                    r:Add(i.bigStar);
                end
                R(i);
            end
        end
        n = n[a + 1]
        t.score = n[1]
        t.pointsToLevelUp = n[2]
        t.level = n[3]
        t.moves = n[4]
        t.largestCascade = n[5]
        t.largestCombo = n[6]
        t[I] = fe(n[9], H(d)) if (t[I]) then
            t[I] = X(t[I])
        else
            t[I] = 0;
        end
        Bejeweled.levelBar.timer.timeElapsed = n[7]
        t.pointMultiplier = n[8]
        Bejeweled.animator.countdownState = 0
        Bejeweled.levelBar.score = t.score
        Bejeweled.levelBar.maxScore = t.pointsToLevelUp
        Bejeweled.levelText:SetText(t.level)
        Bejeweled.levelBar:UpdateBar();
    end
    if (t.level > 1) then
        we = true
    else
        we = nil;
    end
    T(false);
end

local function ee(t, i)
    local o
    if (n.selectedJewel and ((n.selectedJewel == t) or (n.selectedJewel.swapJewel == t))) or (i) then
        o = true
        if not (t.explode) then
            t.bigStarSpawn = Bejeweled.animator:CreateBigStar(0, 0, t)
            t.bigStarSpawn:Hide()
            Bejeweled.animator:Add(t.bigStarSpawn)
            BejeweledProfile.stats.totalPowerGems = BejeweledProfile.stats.totalPowerGems + 1
            if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE3A] then
                if (BejeweledProfile.stats.totalPowerGems >= 100) then
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE3A);
                end
            end
        end
    end
    return o;
end

local function Z(t, i)
    local o
    if (n.selectedJewel and ((n.selectedJewel == t) or (n.selectedJewel.swapJewel == t))) or (i) then
        if not (t.bigStar) then
            t.hyperGemSpawn = true
            t.fxType = A
            Bejeweled.animator:Add(t)
            o = true
            BejeweledProfile.stats.totalHyperGems = BejeweledProfile.stats.totalHyperGems + 1
            M(0, t, 9, nil, nil, 0, nil, nil, true) if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE5A] then
                if (BejeweledProfile.stats.totalHyperGems >= 50) then
                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE5A);
                end
            end
        end
    end
    return o;
end

local function Le(t, o)
    if (o == Ne) then
        t.markX = true
    else
        t.markY = true;
    end
    if (t.bigStar) then
        t.explode = 1
        n.explosions = n.explosions + 1;
    end
    t.fxType = A
    t.fxFrame = 1
    t.highlight:SetAlpha(0)
    Bejeweled.animator:Add(t)
    return (t.explode or 0);
end

local function Q()
    local e, e, n, i, e, c, e, f, d, s, S, l
    for e = 1, a do
        for t = 1, h do
            for p = 1, 4 do
                i = t + r[p][1]
                n = e + r[p][3]
                if (i > 0) and (i <= h) and (n > 0) and (n <= a) then
                    c = o[e][t]
                    f = nil
                    if (c.contents == 9) then
                        f = true;
                    end
                    if (o[n][i].contents ~= 0) then
                        o[e][t] = o[n][i]
                        o[n][i] = c
                        d = t
                        s = t
                        while ((d > 1) and (o[e][d - 1].contents ~= 0) and (o[e][t].contents == o[e][d - 1].contents)) do
                            d = d - 1;
                        end
                        while ((s < h) and (o[e][s + 1].contents ~= 0) and (o[e][t].contents == o[e][s + 1].contents)) do
                            s = s + 1;
                        end
                        S = e
                        l = e
                        while ((S > 1) and (o[S - 1][t].contents ~= 0) and (o[e][t].contents == o[S - 1][t].contents)) do
                            S = S - 1;
                        end
                        while ((l < a) and (o[l + 1][t].contents ~= 0) and (o[e][t].contents == o[l + 1][t].contents)) do
                            l = l + 1;
                        end
                        c = o[e][t] o[e][t] = o[n][i]
                        o[n][i] = c
                        if ((s - d) >= 2) or ((l - S) >= 2) then
                            f = true;
                        end
                    end
                    if f then
                        return c;
                    end
                end
            end
        end
    end
end

function Bejeweled:TotalTime(t)
    local e = ""
    t = d(t)
    if (t >= 86400) then
        e = e .. d(t / 86400) .. " d" t = mod(t, 86400);
    end
    if (t >= 3600) then
        if (e ~= "") then
            e = e .. " ";
        end
        e = e .. d(t / 3600) .. " hr" t = mod(t, 3600);
    end
    if (t >= 60) then
        if (e ~= "") then
            e = e .. " ";
        end
        e = e .. d(t / 60) .. " min" t = mod(t, 60);
    end
    if (t == 0) then
        if (e == "") then
            e = "0 s";
        end
    else
        if (e ~= "") then
            e = e .. " ";
        end
        e = e .. d(t) .. " s";
    end
    return e;
end

function Bejeweled:Print(o, n, e, t)
    DEFAULT_CHAT_FRAME:AddMessage(o, n, e, t)
end

local function Se(t)
    local e
    if (t) then
        e = n.nextSelectedJewel
        n.nextSelectedJewel = nil
    else
        e = n.selectedJewel
        n.selectedJewel = nil;
    end
    if (e) then
        if (e.fxType ~= g) then
            e.fxEnd = true;
        end
        e.selector:Hide()
        e.mouseX = nil
        e.mouseY = nil;
    end
end

local function Me()
    local o = Bejeweled.animator
    local t = Bejeweled.gameStatusText
    o.hintObj:Hide()
    o.hintObj.fxType = S
    n.gameOver = true
    n.moveAllowed = nil
    n.lastGameMode = n.gameMode
    if (Bejeweled_Fu) then
        Bejeweled_Fu.currentMode = nil
        Bejeweled_Fu.lastScore = Bejeweled:NumberWithCommas(n.score);
    end
    if (Bejeweled_Titan) then
        Bejeweled_Titan.currentMode = nil
        Bejeweled_Titan.lastScore = Bejeweled:NumberWithCommas(n.score);
    end
    Bejeweled.levelBar:StopTimer()
    if (n.gameMode == c) then
        t:SetText("No more moves")
        Bejeweled.sound:Play("NoMoreMoves")
        local e, e
        for t = 1, a do
            for e = 1, h do
                BejeweledProfile.settings.savedState[t][e] = 0;
            end
        end
        for e = 1, #BejeweledProfile.settings.savedState[a + 1] do
            BejeweledProfile.settings.savedState[a + 1][e] = 0;
        end
        BejeweledProfile.settings.classicInProgress = nil
    else
        t:SetText("Time's up")
        Bejeweled.sound:Play("TimesUp");
    end
    BejeweledProfile.skill.games = BejeweledProfile.skill.games + 1
    K = K + 1
    if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE2B] then
        if (K >= 100) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE2B);
        end
    end
    if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE4B] then
        if (K >= 1e3) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE4B);
        end
    end
    t:Show()
    t.background:Show()
    Se()
    Se(true)
    o.animationStatus = Fe
    Ke()
    Bejeweled.sound:Play("WipeBoard");
end

local function At(a, o, i, n, t, e, l)
    local e = CreateFrame("Frame", "", e)
    e:SetPoint("Topleft", o, -i)
    e:SetWidth(n)
    e:SetHeight(t)
    e:Show()
    if (l) then
        e.texture = e:CreateTexture(nil, "OVERLAY")
    else
        e.texture = e:CreateTexture(nil, "ART");
    end
    e.texture:SetWidth(n)
    e.texture:SetHeight(t)
    e.texture:SetPoint("Center")
    e.texture:Show()
    e.highlight = e:CreateTexture(nil, "OVERLAY")
    e.highlight:SetWidth(n)
    e.highlight:SetHeight(t)
    e.highlight:SetBlendMode("add")
    e.highlight:SetPoint("Center")
    e.highlight:Show()
    e.x = o
    e.y = i
    return e;
end

local function tt(n, i, o, t)
    local e = Bejeweled.animator:CreateImage(n, i, b, p, o)
    e.texture:SetTexture(l .. "gem_" .. U[t])
    e.texture:SetTexCoord(0, 0, 0, 0)
    e.highlight:SetTexture(l .. "shine_" .. U[t])
    e.highlight:SetTexCoord(0, 0, 0, 0)
    e.selector = e:CreateTexture(nil, "OVERLAY")
    e.selector:SetTexture(l .. "selector")
    e.selector:SetHeight(p)
    e.selector:SetWidth(b)
    e.selector:SetPoint("Center")
    e.selector:Hide()
    e.glow = e:CreateTexture(nil, "OVERLAY")
    e.glow:SetHeight(p)
    e.glow:SetWidth(b)
    e.glow:SetPoint("Topleft", e.texture)
    e.glow:SetPoint("Bottomright", e.texture)
    e.glow:SetAlpha(0)
    e.glowLevel = 0
    e.fxType = E
    e.fxFrame = 1
    return e;
end

local function It(t, e)
    e.texture:SetTexture(l .. "hypergem")
    e.texture:SetTexCoord(unpack(O[1]))
    e.highlight:SetTexture(l .. "shine_white")
    e.highlight:SetTexCoord(0, 0, 0, 0)
    e.glow:SetTexCoord(0, 0, 0, 0)
    e.fxType = g
    e.fxFrame = 1
    e.contents = 9;
end

local function Ht(t, o, i, n)
    local e = t.bigStarQueue[1]
    if e then
        B(t.bigStarQueue, 1)
    else
        e = t:CreateImage(o, i, b, p, n, true)
        e.texture:SetTexture(l .. "bigstar")
        e.texture:SetHeight(lt)
        e.texture:SetWidth(Ue)
        e.highlight:SetTexture(l .. "bigstar")
        e.highlight:SetHeight(lt)
        e.highlight:SetWidth(Ue);
    end
    e:ClearAllPoints()
    e:SetPoint("Topleft", n, "Topleft")
    e.fxType = ye
    e.fxFrame = 1
    e.fxFrame2 = 1
    e.fxAlpha = 100
    e.fxAlphaStep = -3
    e:SetAlpha(1)
    e:Show()
    e.parent = n
    return e;
end

local function Ot(n, i, a, o)
    local t = n.explosionQueue[1]
    if t then
        B(n.explosionQueue, 1)
    else
        t = n:CreateImage(i, a, b, p, Bejeweled.gameBoard) t.texture:SetTexture(l .. "explosion")
        t.texture:SetHeight(Qe)
        t.texture:SetWidth(qe);
    end
    t.x = o.x
    t.y = o.y
    t:ClearAllPoints()
    t:SetPoint("Topleft", Bejeweled.gameBoard, "Topleft", t.x, -t.y)
    t.texture:SetTexCoord(unpack(J[1]))
    t:Show()
    t.fxType = Oe
    t.fxFrame = 1
    Bejeweled.sound:Play("Explosion")
    return t;
end

local function Et(t, n)
    if not t.hintObj then
        t.hintObj = t:CreateImage(0, 0, 64, 64, Bejeweled.foreground, true)
        t.hintObj.texture:SetTexture(l .. "hintArrow");
    end
    if (n) then
        t.hintObj.x = n.x + 2
        t.hintObj.y = n.y - ne
        t.hintObj:ClearAllPoints()
        t.hintObj:SetPoint("Topleft", t.hintObj.x, -t.hintObj.y)
        t.hintObj.fxType = Ve
        t.hintObj.fxFrame = 0;
    end
    t.hintObj:SetAlpha(1) t.hintObj:Hide()
    t.hintObj.bounceY = 0
    t.hintObj.bounceDir = 1
    return t.hintObj;
end

local function vt(n, t, o)
    local e = n.lightwaveQueue[1]
    if e then
        B(n.lightwaveQueue, 1)
    else
        e = n:CreateImage(0, 0, b, p, t, true);
    end
    e:ClearAllPoints()
    e:SetParent(t)
    e.texture:SetTexture(t.highlight:GetTexture())
    e:SetAllPoints(t.texture)
    e:Show()
    e.texture:SetTexCoord(unpack(N[2]))
    e:SetAlpha(0) e.fxType = De
    e.fxFrame = -(o * 2) - 1
    t.lightWaveObv = e
    return e;
end

local function lt(a, r, o, i, n, d)
    local t = a.lightningQueue[1]
    if t then
        B(a.lightningQueue, 1)
    else
        t = Bejeweled.foreground:CreateTexture(nil, "ARTWORK")
        t:SetTexture(l .. "lightning")
        t.highlight = Bejeweled.foreground:CreateTexture(nil, "OVERLAY")
        t.highlight:SetTexture(l .. "lightning");
    end
    t:SetVertexColor(unpack(he[d]))
    t.fxType = We
    t.fxFrame = 1
	-- FixMe:  DrawRouteLine no longer exists.  This is what generates the 'Lightning' effect when you use an 'Ultra' gem.  The gem still works, but the effect is now missing.
    -- DrawRouteLine(t, Bejeweled.gameBoard, r, -o, i, -n, 128, "TOPLEFT") DrawRouteLine(t.highlight, Bejeweled.gameBoard, r, -o, i, -n, 128, "TOPLEFT") t:Show()
    t.highlight:Show()
    return t;
end

local function qe(n, i, o, a, r)
    local t = n.shardQueue[1]
    if t then
        B(n.shardQueue, 1)
    else
        t = n:CreateImage(i, o, Ye, Ze, Bejeweled.gameBoard, true)
        t.texture:SetTexture(l .. "gemshards");
    end
    t.x = a.x + i
    t.y = a.y + o
    t:ClearAllPoints()
    t:SetPoint("Topleft", t.x, -t.y)
    t.texture:SetTexCoord(unpack(ie[1]))
    t.texture:SetVertexColor(unpack(he[r]))
    t:SetAlpha(1) t.yVel = 0
    t.xVel = 0
    t:Show()
    t.fxType = He
    t.fxFrame = m(1, Xe)
    return t;
end

local function Qe(r, S, s, e, a, i, l, d)
    local h, o, t
    if (e.bigStar) and not e.explode then
        e.explode = 1
        e.fxType = A
        r:Add(e)
        if not d then
            n.explosions = n.explosions + 1
            M(1, e, a, nil, nil, n.explosions);
        end
    elseif (e.contents ~= 0) then
        if (e.contents == 9) then
            a = 9
            M(1, e, a, nil, true, 0);
        end
        e.contents = 0
        R(e)
        if not ((i == 0) and (l == 0)) then
            for n = 1, Je do
                if (n > gt) then
                    t = 1
                else
                    t = -1;
                end
                local d = l * m(4, 7)
                if (l == 0) then
                    d = t * m(1, 5);
                end
                if (i < 0) then
                    t = -1;
                end
                if (i > 0) then
                    t = 1;
                end
                local n = m(4, 7)
                if (i == 0) then
                    n = 2;
                end
                o = r:CreateShard(S + ce - pt + (12 - (m(1, 24))), s + ne - ct + (12 - (m(1, 24))), e, a)
                o.yVel = (d) + (l * m(1, 5))
                if (i == 0) then
                    if (l == -1) then
                        o.xVel = (t * 3 / m(1, 5))
                    else
                        o.xVel = (t * m(0, 5));
                    end
                else
                    o.xVel = (t * n) + (t * m(1, n));
                end
                u(r.animationStack, o);
            end
        end
    end
end

local function Je(d, i, n, o, a, l)
    local t = d.floatingTextQueue[1]
    local r = Bejeweled.foreground
    if t then
        B(d.floatingTextQueue, 1)
        t:SetText(o)
    else
        t = Bejeweled:CreateCaption(i, n, o, r, 50, 1, 1, 1, true);
    end
    t.x = i
    t.y = n
    if (l) then
        t:SetTextColor(1, .4, 1)
    else
        if (he[a]) then
            t:SetTextColor(unpack(he[a]))
        else
            t:SetTextColor(unpack(he[9]));
        end
    end
    t:ClearAllPoints()
    t:SetPoint("Topleft", r, "Topleft", i, -n)
    t:SetAlpha(1) t:Hide()
    t.score = o
    t.notScore = l
    t.comboSound = nil
    t.fxType = A
    t.fxFrame = 0
    return t;
end

function Bejeweled:CreateCaption(S, s, d, e, t, o, n, i, r, a)
    local e = e:CreateFontString(nil, "Overlay")
    if (r) then
        e:SetFont(l .. "Contb___.ttf", (t or 10), "Outline")
    else
        if (a) then
            e:SetFont(STANDARD_TEXT_FONT, (t or 10))
        else
            e:SetFont(STANDARD_TEXT_FONT, (t or 10), "Outline");
        end
    end
    e:SetTextColor((o or 1), (n or 1), (i or 1))
    e:SetPoint("Topleft", S, -s)
    e:SetText(d)
    e:Show()
    return e;
end

local function Ye(t)
    if not n.moveAllowed then
        n.currentMouseOver = t
        return
    end
    Bejeweled:UpdateMouseOver(t);
end

function Bejeweled:UpdateMouseOver(t)
    if (t.fxType ~= y) and (t.fxType ~= g) and (t.fxType ~= W) and (t.fxType ~= A) and (t.fxType ~= S) then
        Bejeweled.animator:Add(t)
        t.fxType = je
        t.fxFrame = it
        t.nextGlow = 0
        t.fxEnd = nil
        t.adj = nil
        t.highlight:SetTexCoord(unpack(N[1]))
        t.highlight:SetAlpha(0);
    end
end

local function Ue()
    local t = n
    t.pointMultiplier = Ce[t.gameMode] + t.level * .5
    t.pointsToLevelUp = t.score + (t.pointsToLevelUp + d((500 + 150 * t.level) * t.pointMultiplier)) Bejeweled.levelBar:SetMinMaxScore(t.score, t.pointsToLevelUp)
    if (t.gameMode == c) then
        Bejeweled.levelText:SetText(t.level + 1)
    else
        if (math.fmod(t.level, 2) == 0) then
            Bejeweled.dataText:SetFormattedText("%d|cFF00FF00x", (t.level))
        else
            Bejeweled.dataText:SetFormattedText("%.1f|cFF00FF00x", (1 + t.level * .5));
        end
    end
    t.level = t.level + 1
    if (t.statDB.highestLevel) then
        if (t.level > t.statDB.highestLevel) then
            t.statDB.highestLevel = t.level;
        end
    end
    if (t.gameMode == c) then
        if (t.level == 10) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_LEVEL10);
        end
        if (t.level == 15) then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_LEVEL15);
        end
    end
    Bejeweled.levelBar:UpdateBar();
end

local function Ce(t)
    local n = Bejeweled.animator
    n:CreateShardSpawn(0, 0, t, t.hyperGemContents, 0, 0)
    M(1, t, t.hyperGemContents, nil, true, -1, true)
    t.hyperGemTrigger = nil
    t.contents = 0
    t.fxType = S
    if (t.bigStar) then
        t.bigStar.explode = 1
        t.fxType = A
        n:Add(t)
        t.fxFrame = 1
        t.highlight:SetAlpha(0);
    end
    local S = t.x + ce
    local s = t.y + ne
    local i, r
    local l, l, e
    for l = 1, a do
        for d = 1, h do
            if (o[l][d].contents == t.hyperGemContents) then
                e = o[l][d]
                e.hyperGemTrigger = true
                e.hyperGemContents = t.hyperGemContents
                e.fxType = A
                n:Add(e)
                l = a
                i = e.x + ce
                r = e.y + ne
                break;
            end
        end
        if (i) then
            break;
        end
    end
    if (i) then
        n:Add(n:CreateLightning(S, s, i, r, t.hyperGemContents));
    end
    t.hyperGemContents = nil;
end

local function he()
    local t, t, x, e, S, c, T, t, t, r, s, t, t, t, w, g, C, u, l, d, p
    local f
    for i = 1, a do
        for t = 1, h do
            S = o[i][t].contents
            if (S ~= 0) and (S ~= 9) then
                c = 0
                e = 0
                if i < a then
                    l = nil
                    d = nil
                    p = nil
                    for n = i, a do
                        T = o[n][t]
                        if T.contents == S and not T.markY then
                            e = e + 1
                        else
                            break;
                        end
                        if not l then
                            w = 0
                            g = 0
                            for e = t + 1, h do
                                if (o[n][e].contents == S) then
                                    g = g + 1
                                else
                                    break;
                                end
                            end
                            for e = t - 1, 1, -1 do
                                if (o[n][e].contents == S) then
                                    w = w + 1
                                else
                                    break;
                                end
                            end
                            if (g + w > 1) then
                                d = n
                                l = t;
                            end
                        end
                    end
                    if e > 2 then
                        x = true
                        explodeCount = 0
                        for e = i, i + e - 1 do
                            explodeCount = explodeCount + Le(o[e][t], nt);
                        end
                        if (l) then
                            for e = l - w, l + g do
                                explodeCount = explodeCount + Le(o[d][e], Ne);
                            end
                            if (e > 4) or (w + g > 3) then
                                p = true;
                            end
                            e = e + w + g;
                        end
                        r = nil
                        s = nil
                        if (e == 4) or (l and not p) then
                            if (l) then
                                r = ee(o[d][l], true) or r
                            else
                                for e = i, i + e - 1 do
                                    r = ee(o[e][t]) or r;
                                end
                            end
                            if not r then
                                r = ee(o[m(i, (i + e - 1))][t], true) or r;
                            end
                        elseif (e >= 5) then
                            f = nil
                            if (p) then
                                f = i
                            end
                            f = f or (i + e - 1)
                            if (l) then
                                s = Z(o[d][l], true) or s
                            else
                                for e = i, i + e - 1 do
                                    s = Z(o[e][t]) or s;
                                end
                            end
                            if not s then
                                s = Z(o[m(i, f)][t], true) or s;
                            end
                        end
                        if (l) then
                            M(e, o[d][l], S, true, nil, explodeCount, nil, true)
                        else
                            M(e, o[i][t], S, r, nil, explodeCount);
                        end
                        c = c + e;
                    end
                end
                e = 0
                if t < h then
                    l = nil
                    d = nil
                    p = nil
                    for t = t, h do
                        T = o[i][t]
                        if T.contents == S and not T.markX then
                            e = e + 1
                        else
                            break;
                        end
                        if not d then
                            u = 0
                            C = 0
                            for e = i + 1, a do
                                if (o[e][t].contents == S) then
                                    u = u + 1
                                else
                                    break;
                                end
                            end
                            for e = i - 1, 1, -1 do
                                if (o[e][t].contents == S) then
                                    C = C + 1
                                else
                                    break;
                                end
                            end
                            if (C + u > 1) then
                                l = t
                                d = i;
                            end
                        end
                    end
                    if e > 2 then
                        x = true
                        explodeCount = 0
                        for e = t, t + e - 1 do
                            explodeCount = explodeCount + Le(o[i][e], Ne)
                        end
                        if (d) then
                            for e = d - C, d + u do
                                explodeCount = explodeCount + Le(o[e][l], nt);
                            end
                            if (e > 4) or (C + u > 3) then
                                p = true;
                            end
                            e = e + C + u;
                        end
                        r = nil
                        s = nil
                        if (e == 4) or (d and not p) then
                            if (d) then
                                r = ee(o[d][l], true) or r
                            else
                                for e = t, t + e - 1 do
                                    r = ee(o[i][e]) or r;
                                end
                            end
                            if not r then
                                r = ee(o[i][m(t, (t + e - 1))], true) or r;
                            end
                        elseif (e >= 5) then
                            f = nil
                            if (p) then
                                f = t
                            end
                            f = f or (t + e - 1)
                            if (d) then
                                s = Z(o[d][l], true) or s
                            else
                                for e = t, t + e - 1 do
                                    s = Z(o[i][e]) or s;
                                end
                            end
                            if not s then
                                s = Z(o[i][m(t, f)], true) or s;
                            end
                        end
                        if (l) then
                            M(e, o[d][l], S, true, nil, explodeCount, nil, true)
                        else
                            M(e, o[i][t], S, r, nil, explodeCount, true);
                        end
                        c = c + e;
                    end
                end
                if (c > n.largestCascade) then
                    n.largestCascade = c;
                end
                if (c > BejeweledProfile.stats.largestCascade) then
                    BejeweledProfile.stats.largestCascade = c;
                end
                if (c > 2) then
                    BejeweledProfile.stats.gemMatch[S] = BejeweledProfile.stats.gemMatch[S] + 1;
                end
            end
        end
    end
    return x;
end

local function ce(e)
    if not n.moveAllowed then
        n.currentMouseOver = nil
        return
    end
    if (e.fxType ~= y) and (e.fxType ~= g) and (e.fxType ~= W) and (e.fxType ~= A) and (e.fxType ~= S) and not e.moving then
        e.fxEnd = true
        if (e.adj) and (e.adj.fxType == ke) then
            if (e.adj.fxFrame <= Re) then
                e.adj.fxFrame = Re - e.adj.fxFrame + 1;
            end
        end
        e.adj = nil;
    end
end

local function Z(t)
    if (not n.gameMode) or (Bejeweled.paused == true) then
        return;
    end
    if (bCrowbar) and (bCrowbar.jewelEdit) then
        bCrowbar:Edit(t)
        return;
    end
    if not n.moveAllowed then
        if not Bejeweled.animator.newGameStart then
            if (n.nextSelectedJewel) then
                Se(true)
            else
                if (t.fxType ~= A) then
                    n.nextSelectedJewel = t
                    t.mouseX, t.mouseY = GetCursorPosition()
                    t.selector:Show()
                    t.highlight:SetAlpha(0)
                    Bejeweled.animator:Add(t)
                    Bejeweled.sound:Play("Select");
                end
            end
        end
        return;
    end
    local r = false
    local a
    local l = Bejeweled.animator
    if not BejeweledProfile.settings.disableHints then
        l:Add(l:CreateHint(Q()));
    end
    if n.selectedJewel then
        local o, i
        o = n.selectedJewel.gridX
        i = n.selectedJewel.gridY
        if (t.gridX == o) then
            if (math.abs(t.gridY - i) == 1) then
                r = true;
            end
        elseif (t.gridY == i) then
            if (math.abs(t.gridX - o) == 1) then
                r = true;
            end
        end
        if r == true then
            local o = n.selectedJewel
            l:Add(o)
            l:Add(t)
            o.highlight:SetAlpha(0)
            t.highlight:SetAlpha(0)
            o.mouseX = nil
            o.mouseY = nil
            t.mouseX = nil
            t.mouseY = nil
            if (o.fxType ~= g) then
                o.fxEnd = true
            else
                if not ((t.fxType == g) and (o.fxType == g)) then
                    o.hyperGemContents = t.contents
                    a = true;
                end
            end
            o.moving = _e
            o.xOffset = 0
            o.yOffset = 0
            o.xMove = math.abs(t.gridX - o.gridX)
            o.yMove = math.abs(t.gridY - o.gridY)
            o.xDir = t.gridX - o.gridX
            o.yDir = t.gridY - o.gridY
            o.swapJewel = t
            if (t.fxType ~= g) then
                t.fxType = E
                t.fxFrame = 1
            else
                if not ((t.fxType == g) and (o.fxType == g)) then
                    t.hyperGemContents = o.contents
                    a = true;
                end
            end
            t.moving = _e
            t.xOffset = 0
            t.yOffset = 0
            t.xMove = math.abs(o.gridX - t.gridX)
            t.yMove = math.abs(o.gridY - t.gridY)
            t.xDir = o.gridX - t.gridX
            t.yDir = o.gridY - t.gridY
            t.swapJewel = o
            t.selector:Show()
            n.moveAllowed = nil
            l.movingJewels = 2
            if (bCrowbar) then
                local e = bCrowbar.prevState or {}
                bCrowbar.prevState = e
                local t, t, t, t
                for t = 1, 8 do
                    if not e[t] then
                        e[t] = {};
                    end
                    for n = 1, 8 do
                        if not e[t][n] then
                            e[t][n] = {}
                        else
                            table.wipe(e[t][n]);
                        end
                        for o, i in pairs(bCrowbar.jewelArray[t][n]) do
                            e[t][n][o] = i;
                        end
                    end
                end
            end
            local i
            i = o.contents
            o.contents = t.contents
            t.contents = i
            i = o.bigStar
            o.bigStar = t.bigStar
            t.bigStar = i
            local l
            if ((t.fxType == g) and (o.fxType == g)) then
                l = true
                a = true
                o.hyperGemContents = 9
                t.hyperGemContents = 9;
            end
            if not a then
                local a = he()
                if not a and (not l) then
                    i = o.contents
                    o.contents = t.contents
                    t.contents = i
                    i = o.bigStar
                    o.bigStar = t.bigStar
                    t.bigStar = i
                    t.invalidMove = 1
                    o.invalidMove = 1
                    Bejeweled.sound:Play("Invalid")
                else
                    n.moves = n.moves + 1
                    if n.statDB.mostMoves then
                        if (n.moves > n.statDB.mostMoves) then
                            n.statDB.mostMoves = n.moves;
                        end
                    end
                    if (n.gameMode == c) then
                        if (n.moves == 100) then
                            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_MOVE100);
                        end
                        if (n.moves == 250) then
                            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_CLASSIC, Bejeweled.const.SKILL_MOVE250);
                        end
                    end
                    local t, e
                    t = o.fxType
                    e = o.fxFrame;
                end
            end
        end
    end
    if r == false then
        if (n.selectedJewel) then
            Se()
        else
            n.selectedJewel = t
            t.mouseX, t.mouseY = GetCursorPosition()
            t.selector:Show()
            if (t.fxType ~= g) then
                t.fxType = y
                t.fxEnd = nil
                t.fxFrame = 1;
            end
            t.highlight:SetAlpha(0)
            l:Add(t)
            Bejeweled.sound:Play("Select");
        end
    end
end

local function ee(t)
    if (t.mouseX) then
        if not BejeweledProfile.settings.disableHints then
            Bejeweled.animator:Add(Bejeweled.animator:CreateHint(Q()));
        end
        local e, l = GetCursorPosition()
        local r = e - t.mouseX
        local i = l - t.mouseY
        local d
        if (math.abs(r) > math.abs(i)) then
            r = r / math.abs(r)
            e = t.gridX + r
            if (e > 0) and (e <= h) then
                d = o[t.gridY][e];
            end
        else
            i = i / math.abs(i)
            l = t.gridY - i
            if (l > 0) and (l <= a) then
                d = o[l][t.gridX];
            end
        end
        if (d) then
            Z(d)
        else
            if (t.fxType ~= g) then
                t.fxEnd = true;
            end
            t.selector:Hide()
            t.mouseX = nil
            t.mouseY = nil
            n.selectedJewel = nil;
        end
    end
end

local function U(n)
    local e
    local e = n:GetParent()
    for t = 1, 4 do
        if (e["tab" .. t]) then
            e["tab" .. t .. "Content"]:Hide()
            if (n:GetID() == t) then
                e["tab" .. t]:SetFrameLevel(e:GetFrameLevel() + 1)
                e["tab" .. t].texture:SetVertexColor(1, 1, 1)
                e["tab" .. t .. "Content"]:Show()
            else
                e["tab" .. t]:SetFrameLevel(e:GetFrameLevel() - 1)
                e["tab" .. t].texture:SetVertexColor(.5, .5, .5);
            end
        end
    end
end

local function nt(o, r)
    if IsInGuild() then
        GuildRoster();
    end
    Bejeweled:ScrubLists()
    local t, t, n, i, l
    local h = BejeweledProfile.scoreList[r]
    local a = "|cFF00FFFF"
    local S = "|cFF00FF00"
    local d = UnitName("player")
    local s = GetNumFriends()
    for t = 1, 10 do
        n, i, l = unpack(h.classic[t]) if (n == "PopCap Games") then
            n = "|cFFFFFFFF" .. n
            i = 0;
        end
        l = Bejeweled:NumberWithCommas(l)
        i = D(i)
        if (i > 0) then
            o["classicRank" .. t]:SetTexCoord(((i - 1) * 16 / 128), (i * 16 / 128), 0, 1)
        else
            o["classicRank" .. t]:SetTexCoord(0, 0, 0, 0);
        end
        if (n ~= d) then
            if (r == "friends") then
                o["classicName" .. t]:SetText(a .. n)
            else
                for e = 1, GetNumFriends() do
                    if (n == GetFriendInfo(e)) then
                        o["classicName" .. t]:SetText(a .. n)
                        break;
                    end
                    if (e == s) then
                        o["classicName" .. t]:SetText(S .. n);
                    end
                end
            end
        else
            o["classicName" .. t]:SetText(n);
        end
        if (t == 1) then
            o["classicScore" .. t]:SetText("|cFF00FF00" .. l)
        else
            o["classicScore" .. t]:SetText(l);
        end
        n, i, l = unpack(h.timed[t]) if (n == "PopCap Games") then
            n = "|cFFFFFFFF" .. n
            i = 0;
        end
        l = Bejeweled:NumberWithCommas(l)
        i = D(i)
        if (i > 0) then
            o["timedRank" .. t]:SetTexCoord(((i - 1) * 16 / 128), (i * 16 / 128), 0, 1)
        else
            o["timedRank" .. t]:SetTexCoord(0, 0, 0, 0);
        end
        if (n ~= d) then
            if (r == "friends") then
                o["timedName" .. t]:SetText(a .. n)
            else
                for e = 1, GetNumFriends() do
                    if (n == GetFriendInfo(e)) then
                        o["timedName" .. t]:SetText(a .. n)
                        break;
                    end
                    if (e == s) then
                        o["timedName" .. t]:SetText(S .. n);
                    end
                end
            end
        else
            o["timedName" .. t]:SetText(n);
        end
        if (t == 1) then
            o["timedScore" .. t]:SetFormattedText("|cFF00FF00%.2f", l)
        else
            o["timedScore" .. t]:SetFormattedText("%.2f", l);
        end
    end
end

local function Ne(t, n)
    t.elapsed = t.elapsed + n
    if (t.elapsed < .1) then
        return;
    end
    t.timeElapsed = t.timeElapsed + t.elapsed
    t.timeRemaining = (t.timeRemaining or (0)) - t.elapsed
    t.legJourney = t.legJourney + t.elapsed
    t.elapsed = 0
    local n = Bejeweled.timedWindow
    if (t.learning) and not t.learnEvent and (t.timeElapsed > 4) then
        t.learnEvent = true
        Bejeweled.window:RegisterEvent("PLAYER_MONEY");
    end
    if not Bejeweled.flightOptionWindow.learning and (t.timeRemaining < 60) and not n.flightCheckbox.disabled then
        n.flightCheckbox.disabled = true
        n.flightCheckbox:Hide()
        n.flightCheckboxCaption:Show();
    end
    if (t.timeRemaining <= 0) and not Bejeweled.flightOptionWindow.learning then
        t:Hide()
        if (n:IsVisible()) then
            n:SetHeight(L - 80)
            n.flightCheckbox:Hide()
            n.flightCheckboxCaption:Hide()
            n.flightCheckbox:SetChecked(nil)
            n.timerRemainingCaption:Hide()
            n.timeRemainingValue:Hide();
        end
    end
    if n:IsVisible() then
        if (Bejeweled.flightOptionWindow.learning) then
            Bejeweled.timedWindow.timeRemainingValue:SetText(Bejeweled:TotalTime(d(t.timeElapsed)))
        else
            Bejeweled.timedWindow.timeRemainingValue:SetText(Bejeweled:TotalTime(d(t.timeRemaining)));
        end
    end
end

function Bejeweled:UpdateSavedVariablesDatabase()
    if (bCrowbar) then
        bCrowbar:Hook(o, n, R, he, Bejeweled);
    end
    if (BejeweledData.beta) then
        BejeweledData.beta = nil
        BejeweledData.legalDisplayed = nil
        BejeweledData.firstHyperCube = nil
        BejeweledData.firstPowerGem = nil
        BejeweledData.firstSkillShow = nil
        BejeweledData.firstGame = nil
        BejeweledProfile = {
            ["stats"] = {
                ["classic"] = {
                    ["score"] = 0,
                    ["played"] = 0,
                    ["highestLevel"] = 0
                },
                ["timed"] = {
                    ["score"] = 0,
                    ["played"] = 0,
                    ["mostMoves"] = 0
                },
                ["largestCascade"] = 0,
                ["largestCombo"] = 0,
                ["played"] = 0,
                ["combatPause"] = 0,
                ["totalGemsMatched"] = 0,
                ["totalPowerGems"] = 0,
                ["totalHyperGems"] = 0,
                ["gemMatch"] = { 0, 0, 0, 0, 0, 0, 0, 0 },
            },
            ["skill"] = { ["rank"] = 1, ["skillPoints"] = 0, ["timedGames"] = 0, ["games"] = 0, },
            ["settings"] = {
                ["keybinding"] = nil,
                ["gameAlpha"] = 1,
                ["mouseoffAlpha"] = .3,
                ["publishSkillGains"] = 1,
                ["publishRankGains"] = 1,
                ["newGameFlight"] = 1,
                ["publishScores"] = 1,
                ["enableSounds"] = 1,
                ["disableHints"] = nil,
                ["lockWindow"] = nil,
                ["openFlightStart"] = 1,
                ["closeFlightEnd"] = nil,
                ["openOnDeath"] = 1,
                ["closeReadyCheck"] = 1,
                ["openLogin"] = nil,
                ["closeCombat"] = 1,
                ["showFlightTooltips"] = 1,
                ["defaultPublish"] = "GUILD",
            },
        };
    end
    local i = BejeweledProfile.stats.classic
    local a = BejeweledProfile.stats.timed
    local t = BejeweledProfile.settings.savedState
    local o = UnitName("player")
    if (BejeweledProfile) then
        if not BejeweledProfile.version then
            BejeweledProfile.version = "8.0.1"
            BejeweledProfile.scoresUpdated = nil
            BejeweledProfile.scoresPopup = nil
            BejeweledProfile.settings.defaultPublish = "GUILD"
            if (t) then
                if (t[1][1] and t[1][1] ~= 0) then
                    t[9][9] = P(x(t[9][1], 4), H(o))
                end
            end
        end
    end
    if not BejeweledProfile.settings.defaultPublish then
        BejeweledProfile.settings.defaultPublish = "GUILD";
    end
    o = H(o)
    if not BejeweledProfile.scoreList then
        BejeweledProfile.stats.classic.score = 0
        BejeweledProfile.stats.timed.score = 0
        BejeweledProfile.scoreList = {
            ["friends"] = { ["classic"] = { [1] = { "PopCap Games", 1, 1e3, "9VW``nt" }, [2] = { "PopCap Games", 1, 900, "7Rk``lQ" }, [3] = { "PopCap Games", 1, 800, "zDR``k3" }, [4] = { "PopCap Games", 1, 700, "v>z``j`" }, [5] = { "PopCap Games", 1, 600, "v;a``h=" }, [6] = { "PopCap Games", 1, 500, ";OC``gj" }, [7] = { "PopCap Games", 1, 400, ";MH``eG" }, [8] = { "PopCap Games", 1, 300, "7EM``dt" }, [9] = { "PopCap Games", 1, 200, "7CR``bQ" }, [10] = { "PopCap Games", 1, 100, "z6>``a3" }, }, ["timed"] = { [1] = { "PopCap Games", 1, 2.8, "=H7`d`" }, [2] = { "PopCap Games", 1, 2.6, "wST`cG" }, [3] = { "PopCap Games", 1, 2.4, "<Nm`c3" }, [4] = { "PopCap Games", 1, 2.2, ";ST`cj" }, [5] = { "PopCap Games", 1, 2, "xgl`bQ" }, [6] = { "PopCap Games", 1, 1.8, "=a5`b=" }, [7] = { "PopCap Games", 1, 1.6, "<gl`bt" }, [8] = { "PopCap Games", 1, 1.4, "9BI`b`" }, [9] = { "PopCap Games", 1, 1.2, "=oH`aG" }, [10] = { "PopCap Games", 1, 1, "8H4`a3" }, }, },
            ["guild"] = { ["classic"] = { [1] = { "PopCap Games", 1, 1e3, "9VW``nt" }, [2] = { "PopCap Games", 1, 900, "7Rk``lQ" }, [3] = { "PopCap Games", 1, 800, "zDR``k3" }, [4] = { "PopCap Games", 1, 700, "v>z``j`" }, [5] = { "PopCap Games", 1, 600, "v;a``h=" }, [6] = { "PopCap Games", 1, 500, ";OC``gj" }, [7] = { "PopCap Games", 1, 400, ";MH``eG" }, [8] = { "PopCap Games", 1, 300, "7EM``dt" }, [9] = { "PopCap Games", 1, 200, "7CR``bQ" }, [10] = { "PopCap Games", 1, 100, "z6>``a3" }, }, ["timed"] = { [1] = { "PopCap Games", 1, 2.8, "=H7`d`" }, [2] = { "PopCap Games", 1, 2.6, "wST`cG" }, [3] = { "PopCap Games", 1, 2.4, "<Nm`c3" }, [4] = { "PopCap Games", 1, 2.2, ";ST`cj" }, [5] = { "PopCap Games", 1, 2, "xgl`bQ" }, [6] = { "PopCap Games", 1, 1.8, "=a5`b=" }, [7] = { "PopCap Games", 1, 1.6, "<gl`bt" }, [8] = { "PopCap Games", 1, 1.4, "9BI`b`" }, [9] = { "PopCap Games", 1, 1.2, "=oH`aG" }, [10] = { "PopCap Games", 1, 1, "8H4`a3" }, }, },
        } i[v] = P(x(0, 4), o)
        a[v] = P(x(0, 3), o);
    end
    if not BejeweledProfile.scoresUpdated then
        local n = CreateFrame("Frame", "BejeweledUpdatePopup", Bejeweled.window)
        n:SetWidth(320)
        n:SetHeight(200)
        n:SetPoint("Center")
        n:EnableMouse(true)
        n:SetToplevel(true)
        n:Hide()
        local t = C()
        t.edgeFile = l .. "windowBorder"
        t.bgFile = l .. "windowBackground"
        t.edgeSize = 32
        t.tileSize = 64
        t.insets.right = 3
        n:SetBackdrop(t)
        n:SetBackdropColor(.7, .7, .7, 1)
        local t = CreateFrame("Button", "", n, "UIPanelCloseButton") t:SetToplevel(true)
        t:SetPoint("Topright", n, "Topright", 2, 2) t:SetWidth(32)
        t:SetHeight(32)
        t:SetScript("OnClick", function(e)
            e:GetParent():Hide()
        end)
        local t = n:CreateFontString(nil, "Overlay")
        t:SetFont(STANDARD_TEXT_FONT, 12)
        t:SetShadowColor(0, 0, 0)
        t:SetShadowOffset(1, -1)
        t:SetTextColor(1, 1, 1)
        t:SetPoint("Top", 0, -38)
        t:SetText("The score storage system has been changed in this version. In order to continue to send high scores to other players you must upgrade to the new system, which will wipe your existing scores. If you do not upgrade, you will not broadcast or receive scores. Would you like to upgrade now?")
        t:SetWidth(290)
        t:Show()
        local t = CreateFrame("Button", "BejeweledUpdateYes", n, "OptionsButtonTemplate") t:SetPoint("Bottomleft", 40, 20)
        t:SetText("Yes")
        t:SetWidth(100)
        t:SetHeight(28)
        t:SetScript("OnClick", function(e)
            BejeweledProfile.scoresUpdated = true
            BejeweledProfile.scoreList = nil
            ReloadUI()
        end)
        t = CreateFrame("Button", "BejeweledUpdateNo", n, "OptionsButtonTemplate") t:SetPoint("Bottomright", -40, 20)
        t:SetText("No")
        t:SetWidth(100)
        t:SetHeight(28)
        t:SetScript("OnClick", function(e)
            BejeweledProfile.scoresPopup = true
            e:GetParent():Hide()
        end)
        Bejeweled.updatePopup = n
        t = CreateFrame("Button", "BejeweledUpdateNo", n, "OptionsButtonTemplate") t:SetPoint("Bottomright", -40, 20)
        t:SetText("No")
        t:SetWidth(100)
        t:SetHeight(28)
        t:SetScript("OnClick", function(e)
            BejeweledProfile.scoresPopup = true
            e:GetParent():Hide()
        end)
        if not BejeweledProfile.scoresPopup then
            n:Show();
        end
        Bejeweled.featsOfSkillScreen.tab3Content.friends:Hide()
        Bejeweled.featsOfSkillScreen.tab3Content.guild:Hide()
        t = CreateFrame("Button", "BejeweledUpdateScoresButton", Bejeweled.featsOfSkillScreen.tab3Content, "OptionsButtonTemplate") t:SetPoint("Top", 0, 2)
        t:SetText("Upgrade Score System")
        t:SetWidth(230)
        t:SetHeight(22)
        t:SetScript("OnClick", function(t)
            Bejeweled.updatePopup:Show()
        end)
    else
        xe = "BEJ2a"
        local e = function(e, r, n, d)
            local i = "PopCap Games" local t, t, o
            local l = 0
            local a = H(i)
            for t = 10, 1, -1 do
                o = fe(e[t][4], H(e[t][1]))
                if (o) then
                    e[t][3] = X(o)
                    if not r then
                        e[t][3] = e[t][3] / 100;
                    end
                else
                    l = l + 1
                    for t = t, 9 do
                        e[t][1] = e[t + 1][1]
                        e[t][2] = e[t + 1][2]
                        e[t][3] = e[t + 1][3]
                        e[t][4] = e[t + 1][4]
                        if (e[t][1] == i) then
                            n = e[t][3] - d;
                        end
                    end
                    e[10][1] = i
                    e[10][2] = 1
                    e[10][3] = n
                    if (r) then
                        e[10][4] = P(x(n, 4), a)
                    else
                        e[10][4] = P(x(n * 100, 3), a);
                    end
                end
            end
        end
        e(BejeweledProfile.scoreList.friends.classic, true, 1e3, 100)
        e(BejeweledProfile.scoreList.guild.timed, nil, 2.8, .2)
        e(BejeweledProfile.scoreList.friends.classic, true, 1e3, 100)
        e(BejeweledProfile.scoreList.guild.timed, nil, 2.8, .2)
        local e = fe(i[v], o)
        if (e) then
            i[I] = X(e)
        else
            i[I] = 0
            i[v] = P(x(0, 4), o);
        end
        e = fe(a[v], o)
        if (e) then
            a[I] = X(e) / 100
        else
            a[I] = 0
            a[v] = P(x(0, 3), o);
        end
    end
    Bejeweled.UpdateSavedVariablesDatabase = nil;
end

local function Ze(t)
    local n = t
    local t = n
    local o = string.find(t, " ")
    if (o) then
        t = G(t, 1, o - 1)
        n = G(n, o + 1)
    else
        n = "";
    end
    t = string.lower(t)
    if (t == "reset") then
        BejeweledProfile = {
            ["stats"] = {
                ["classic"] = {
                    ["score"] = 0,
                    ["played"] = 0,
                    ["highestLevel"] = 0
                },
                ["timed"] = {
                    ["score"] = 0,
                    ["played"] = 0,
                    ["mostMoves"] = 0
                },
                ["largestCascade"] = 0,
                ["largestCombo"] = 0,
                ["played"] = 0,
                ["combatPause"] = 0,
                ["totalGemsMatched"] = 0,
                ["totalPowerGems"] = 0,
                ["totalHyperGems"] = 0,
                ["gemMatch"] = { 0, 0, 0, 0, 0, 0, 0, 0 },
            },
            ["skill"] = { ["rank"] = 1, ["skillPoints"] = 0, ["timedGames"] = 0, ["games"] = 0, },
            ["settings"] = {
                ["keybinding"] = nil,
                ["gameAlpha"] = 1,
                ["mouseoffAlpha"] = .3,
                ["publishSkillGains"] = 1,
                ["publishRankGains"] = 1,
                ["newGameFlight"] = 1,
                ["publishScores"] = 1,
                ["enableSounds"] = 1,
                ["disableHints"] = nil,
                ["lockWindow"] = nil,
                ["openFlightStart"] = 1,
                ["closeFlightEnd"] = nil,
                ["openOnDeath"] = 1,
                ["closeReadyCheck"] = 1,
                ["openLogin"] = nil,
                ["closeCombat"] = 1,
                ["showFlightTooltips"] = 1,
            },
            ["scoreList"] = {
                ["friends"] = {
                    ["classic"] = {
                        [1] = { "PopCap Games", 1, 1e3 },
                        [2] = { "PopCap Games", 1, 900 },
                        [3] = { "PopCap Games", 1, 800 },
                        [4] = { "PopCap Games", 1, 700 },
                        [5] = { "PopCap Games", 1, 600 },
                        [6] = { "PopCap Games", 1, 500 },
                        [7] = { "PopCap Games", 1, 400 },
                        [8] = { "PopCap Games", 1, 300 },
                        [9] = { "PopCap Games", 1, 200 },
                        [10] = { "PopCap Games", 1, 100 },
                    },
                    ["timed"] = {
                        [1] = { "PopCap Games", 1, 2.8 },
                        [2] = { "PopCap Games", 1, 2.6 },
                        [3] = { "PopCap Games", 1, 2.4 },
                        [4] = { "PopCap Games", 1, 2.2 },
                        [5] = { "PopCap Games", 1, 2 },
                        [6] = { "PopCap Games", 1, 1.8 },
                        [7] = { "PopCap Games", 1, 1.6 },
                        [8] = { "PopCap Games", 1, 1.4 },
                        [9] = { "PopCap Games", 1, 1.2 },
                        [10] = { "PopCap Games", 1, 1 },
                    },
                },
                ["guild"] = {
                    ["classic"] = {
                        [1] = { "PopCap Games", 1, 1e3 },
                        [2] = { "PopCap Games", 1, 900 },
                        [3] = { "PopCap Games", 1, 800 },
                        [4] = { "PopCap Games", 1, 700 },
                        [5] = { "PopCap Games", 1, 600 },
                        [6] = { "PopCap Games", 1, 500 },
                        [7] = { "PopCap Games", 1, 400 },
                        [8] = { "PopCap Games", 1, 300 },
                        [9] = { "PopCap Games", 1, 200 },
                        [10] = { "PopCap Games", 1, 100 },
                    },
                    ["timed"] = {
                        [1] = { "PopCap Games", 1, 2.8 },
                        [2] = { "PopCap Games", 1, 2.6 },
                        [3] = { "PopCap Games", 1, 2.4 },
                        [4] = { "PopCap Games", 1, 2.2 },
                        [5] = { "PopCap Games", 1, 2 },
                        [6] = { "PopCap Games", 1, 1.8 },
                        [7] = { "PopCap Games", 1, 1.6 },
                        [8] = { "PopCap Games", 1, 1.4 },
                        [9] = { "PopCap Games", 1, 1.2 },
                        [10] = { "PopCap Games", 1, 1 },
                    },
                },
            },
        }
        if (Bejeweled.window:IsVisible()) then
            Bejeweled.window:Hide()
            Bejeweled.window:Show();
        end
    else
        local e = getglobal("BejeweledWindow")
        if (e:IsVisible()) then
            e:Hide() else
            e:Show()
        end
    end
end

function Bejeweled.CreateCheckbox_OnClick(e)
    BejeweledProfile.settings[string.match(e:GetName(), "BejeweledCheckBox(.*)")] = e:GetChecked()
end

function Bejeweled.CreateSlider_OnValueChanged(e)
    if (BejeweledProfile.settings[e.objectSetting]) then
        BejeweledProfile.settings[e.objectSetting] = e:GetValue();
    end
    if (e.usePercent) then
        e.valueCaption:SetFormattedText(": %d%%", (e:GetValue() * 100))
    else
        e.valueCaption:SetFormattedText(": %d", e:GetValue());
    end
    if (e.updateFunc) then
        e:updateFunc();
    end
end

function Bejeweled:CreateSlider(a, l, s, h, n, t, o, d, r, i, S)
    local t = CreateFrame("Slider", "BejeweledSlider" .. n, t, "OptionsSliderTemplate")
    t:SetWidth(s)
    getglobal(t:GetName() .. "Thumb"):Show()
    getglobal(t:GetName() .. "Text"):SetFont(STANDARD_TEXT_FONT, 14)
    getglobal(t:GetName() .. "Text"):SetShadowOffset(1, -1)
    getglobal(t:GetName() .. "Text"):SetText(h)
    getglobal(t:GetName() .. "Text"):SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    getglobal(t:GetName() .. "Low"):SetText("")
    getglobal(t:GetName() .. "Low"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    getglobal(t:GetName() .. "High"):SetText("")
    getglobal(t:GetName() .. "High"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    t.valueCaption = Bejeweled:CreateCaption(0, 0, "", t, 10, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) t.valueCaption:ClearAllPoints()
    t.valueCaption:SetPoint("Topleft", t, "Topright")
    t:SetHitRectInsets(0, 0, 0, 0)
    t:SetMinMaxValues(o, d)
    t:SetValueStep(r)
    if (BejeweledProfile.settings[n]) then
        if (i) then
            t.valueCaption:SetFormattedText(": %d%%", (BejeweledProfile.settings[n] * 100))
        else
            t.valueCaption:SetFormattedText(": %d", BejeweledProfile.settings[n]);
        end
        t:SetValue(BejeweledProfile.settings[n])
    else
        t:SetValue(o)
        if (i) then
            t.valueCaption:SetFormattedText(": %d%%", (o * 100))
        else
            t.valueCaption:SetFormattedText(": %d", o);
        end
    end
    t:SetPoint("Topleft", a, l)
    t:SetScript("OnValueChanged", Bejeweled.CreateSlider_OnValueChanged)
    t.updateFunc = S
    t.objectSetting = n
    t.usePercent = i
    return t
end

function Bejeweled:CreateCheckbox(d, r, a, o, l, t, n, i)
    local t = CreateFrame("CheckButton", "BejeweledCheckBox" .. o, t, "OptionsCheckButtonTemplate")
    t:SetWidth(21)
    t:SetHeight(21)
    getglobal(t:GetName() .. "Text"):SetFont(STANDARD_TEXT_FONT, 13)
    getglobal(t:GetName() .. "Text"):SetShadowOffset(1, -1)
    getglobal(t:GetName() .. "Text"):SetText("|cFFFF9922" .. a)
    if (i) then
        t:SetWidth(16)
        t:SetHeight(16)
        t:SetNormalTexture("Interface\\Buttons\\UI-RadioButton")
        t:GetNormalTexture():SetTexCoord(0, .25, 0, 1)
        t:SetHighlightTexture("Interface\\Buttons\\UI-RadioButton")
        t:GetHighlightTexture():SetTexCoord(.5, .75, 0, 1)
        t:SetCheckedTexture("Interface\\Buttons\\UI-RadioButton")
        t:GetCheckedTexture():SetTexCoord(.25, .5, 0, 1)
        t:SetPushedTexture("Interface\\Buttons\\UI-RadioButton")
        t:GetPushedTexture():SetTexCoord(0, .25, 0, 1);
    end
    t:SetPoint("Topleft", d, r)
    if (BejeweledProfile.settings[o] == l) then
        t:SetChecked(1);
    end
    if (n) then
        t:SetScript("OnClick", n)
    else
        t:SetScript("OnClick", Bejeweled.CreateCheckbox_OnClick);
    end
    return t;
end

local function fe(t, o)
    if (Bejeweled.animator.newGameStart) then
        return;
    end
    if (o > 1) then
        o = .1
    end
    t.elapsed = t.elapsed + o
    if (t.elapsed < .1) then
        return;
    end
    n.statDB.played = n.statDB.played + t.elapsed
    BejeweledProfile.stats.played = BejeweledProfile.stats.played + t.elapsed
    t.timeLeft = t.timeLeft - t.elapsed
    t.timeElapsed = t.timeElapsed + t.elapsed
    t.elapsed = 0
    if (Bejeweled.levelBar.mode ~= c) then
        if (Bejeweled.levelBar.mode == k) then
            if (t.timeLeft <= 0) then
                t.timeLeft = -1
                Bejeweled.flightOptionWindow.learning = true
                if not Bejeweled.flightOptionWindow.timer:IsShown() then
                    Bejeweled.flightOptionWindow.timer:Show();
                end
            else
                local e = Bejeweled.flightOptionWindow.timer
                if e.learning ~= true then
                    if (math.abs(t.timeLeft - e.timeRemaining) > .6) then
                        t.timeLeft = e.timeRemaining
                        t.timeElapsed = e.timeElapsed;
                    end
                end
            end
        else
            if (t.timeLeft <= 0) then
                t.timeLeft = 0
                t.timeElapsed = t.timeStart
                t:Hide()
                Me();
            end
        end
        Bejeweled.levelBar:UpdateBar();
    end
end

local function Le(i)
    if not i.spawnedJewels then
        i.spawnedJewels = true
        n.gemsCleared = n.gemsCleared or (0)
        local s, s, t, d, l, r, s
        for e = 1, h do
            i.columnOffset[e] = p
            if (i.spawningLevel) then
                i.columnOffset[e] = p + m(1, 400);
            end
            for l = a, 1, -1 do
                if o[l][e].contents == 0 then
                    t = o[l][e] if not i.spawningLevel then
                        n.gemsCleared = n.gemsCleared + 1;
                    end
                    u(i.newJewel, t)
                    if i.spawningLevel and we then
                        if t.wasHyper then
                            t.wasHyper = nil
                            n.hyperSpawn = (n.hyperSpawn or (0)) + 1;
                        end
                        if (t.bigStar) then
                            t.bigStar:Hide()
                            n.bigStarSpawn = (n.bigStarSpawn or (0)) + 1
                            t.bigStar:Hide()
                            t.bigStar.fxEnd = nil
                            t.bigStar.explode = nil
                            t.bigStar.fxType = S
                            u(i.bigStarQueue, t.bigStar)
                            t.bigStar = nil
                            t.explode = nil;
                        end
                    end
                    de(e, l, i.spawningLevel)
                    d = m(30, 50)
                    if (i.spawningLevel) then
                        d = d * 2;
                    end
                    t.y = -i.columnOffset[e] - ne - d
                    t.maxYOffset = i.columnOffset[e] + (p * (t.gridY - 1)) + ne + d
                    i.columnOffset[e] = i.columnOffset[e] + p + d
                    t.yOffset = 0
                    if (i.spawningLevel) then
                        t.yVel = 0
                    else
                        t.yVel = t.yVel or 0
                    end
                    t.moving = le
                    t.fxType = W
                    t.fxFrame = 1
                    i:Add(t)
                    t:SetWidth(b)
                    t:SetHeight(p)
                    R(t)
                    t:SetAlpha(1)
                    if (t.lightWaveObj) then
                        t.lightWaveObj:Hide();
                    end
                    t:ClearAllPoints()
                    t:SetPoint("Topleft", t.x, -t.y);
                end
            end
        end
        local d
        if (n.gameMode ~= c) or (n.level == 1) then
            for n = 1, 200 do
                if not Q() then
                    for e = 1, #i.newJewel do
                        i.newJewel[e].contents = 0;
                    end
                    for e = 1, #i.newJewel do
                        de(i.newJewel[e].gridX, i.newJewel[e].gridY, true, true);
                    end
                else
                    break;
                end
                if (n == 50) then
                    t = i:CreateBigStar(0, 0, i.newJewel[1])
                    i.newJewel[1].explode = 1
                    i.newJewel[1].fxType = A
                    i.newJewel[1].bigStar = t
                    i.newJewel[1].forcedExplode = 1
                    i:Add(t)
                    i.forceBlow = true;
                end
            end
        end
        if (i.spawningLevel) then
            if n.bigStarSpawn > 0 then
                for e = 1, n.bigStarSpawn do
                    for e = 1, 6 do
                        l = m(1, h)
                        r = m(1, a)
                        t = o[r][l]
                        if not t.bigStar then
                            t.bigStar = i:CreateBigStar(0, 0, t)
                            t.bigStar:Hide()
                            i:Add(t.bigStar)
                            break;
                        end
                        if (e == 6) then
                            for e = 1, h * a do
                                l = l + 1
                                if (l > h) then
                                    l = 1
                                    r = r + 1
                                    if (r > a) then
                                        r = 1;
                                    end
                                end
                                t = o[r][l]
                                if not t.bigStar then
                                    t.bigStar = i:CreateBigStar(0, 0, t)
                                    t.bigStar:Hide()
                                    i:Add(t.bigStar)
                                    break;
                                end
                            end
                        end
                    end
                end
                n.bigStarSpawn = 0;
            end
            if n.hyperSpawn > 0 then
                for e = 1, n.hyperSpawn do
                    for e = 1, 6 do
                        l = m(1, h)
                        r = m(1, a)
                        t = o[r][l]
                        if not t.bigStar and not t.spawnHyper then
                            t.spawnHyper = true
                            break;
                        end
                        if (e == 6) then
                            for e = 1, h * a do
                                l = l + 1
                                if (l > h) then
                                    l = 1
                                    r = r + 1
                                    if (r > a) then
                                        r = 1;
                                    end
                                end
                                t = o[r][l]
                                if not t.bigStar and not t.spawnHyper then
                                    t.spawnHyper = true
                                    break;
                                end
                            end
                        end
                    end
                end
                n.hyperSpawn = 0;
            end
            i.spawningLevel = nil
            if not i.newGameStart then
                Ue();
            end
        end
        if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE2A] then
            if (BejeweledProfile.stats.totalGemsMatched >= 1e3) then
                Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE2A);
            end
        end
    end
end

local function X(r)
    local e, t, t, t
    for l = a, 1, -1 do
        for t = 1, h do
            if (o[l][t].contents == 0) then
                for i = l - 1, 1, -1 do
                    if (o[i][t].contents ~= 0) then
                        e = o[l][t]
                        e.contents = o[i][t].contents
                        if o[i][t].bigStar then
                            e.bigStar = o[i][t].bigStar
                            o[i][t].bigStar = nil
                            e.bigStar:ClearAllPoints()
                            e.bigStar:SetPoint("Topleft", e, "Topleft")
                            e.bigStar.parent = e;
                        end
                        o[i][t].contents = 0
                        e.maxYOffset = e.y - o[i][t].y
                        e.y = o[i][t].y
                        e.needsOffset = nil
                        e.yOffset = o[i][t].yOffset or (0)
                        e.yVel = o[i][t].yVel or (0)
                        e.moving = le
                        e.fxType = E
                        e.fxFrame = 1
                        if (e.contents == 9) then
                            e.fxType = g;
                        end
                        if (o[i][t] == n.nextSelectedJewel) then
                            Se(true)
                            n.nextSelectedJewel = e
                            e.selector:Show()
                            if (e.fxType ~= g) then
                                e.fxType = y
                                e.fxEnd = nil
                                e.fxFrame = 1;
                            end
                            e.highlight:SetAlpha(0);
                        end
                        r:Add(e)
                        R(e)
                        R(o[i][t])
                        e:ClearAllPoints()
                        e:SetPoint("Topleft", e.x, -e.y)
                        break;
                    end
                end
            end
        end
    end
end

local function ne(t)
    t.countdown = (t.countdown or (0)) - t.elapsed
    if (t.countdown < 0) then
        if (t.hintObj) then
            t.hintObj.fxFrame = 0;
        end
        t.countdown = 1
        t.countdownState = (t.countdownState or (4)) - 1
        if (t.countdownState > 0) then
            if (t.countdownState == 3) then
                Bejeweled.sound:Play("GetReady");
            end
            Bejeweled.gameStatusText:SetText(Y(t.countdownState))
            Bejeweled.gameStatusText:Show()
            Bejeweled.gameStatusText.background:Show()
        else
            t.countdownState = nil
            t.countdown = nil
            t.newGameStart = nil
            Bejeweled.gameStatusText:SetText("Go")
            Bejeweled.sound:Play("Go")
            if not BejeweledProfile.settings.disableHints then
                t:Add(t:CreateHint(Q()));
            end
            if (n.gameMode ~= c) then
                Bejeweled.levelBar:StartTimer();
            end
            local t = {
                mode = "OUT",
                timeToFade = 3,
                startAlpha = 1,
                endAlpha = 0,
                finishedFunc = function()
                    Bejeweled.gameStatusText:SetAlpha(1)
                    Bejeweled.gameStatusText.background:SetAlpha(1)
                    Bejeweled.gameStatusText:Hide()
                    Bejeweled.gameStatusText.background:Hide()
                end
            }
            UIFrameFade(Bejeweled.gameStatusText, t)
            UIFrameFade(Bejeweled.gameStatusText.background, t)
            n.moveAllowed = true;
        end
    end
end

local function de(t, o)
    t.animationStatus = o + 1
    if (t.animationStatus == pe) then
        t.spawnedJewels = nil;
    end
    if (t.animationStatus == ot) and (t.newGameStart) then
        t.animationStatus = V;
    end
    if (t.animationStatus == ot) or (t.animationStatus > Fe) then
        local i, o
        i = he() if i or (t.forceBlow == true) then
            t.animationStatus = Pe
            t.forceBlow = nil
        else
            if (n.gemsCleared or (0)) >= 10 then
                Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_GEMCOMBO, Bejeweled.const.SKILL_CLEAR10);
            end
            if (n.gemsCleared or (0)) >= 15 then
                Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_GEMCOMBO, Bejeweled.const.SKILL_CLEAR15);
            end
            if (n.gemsCleared or (0)) >= 20 then
                Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_GEMCOMBO, Bejeweled.const.SKILL_CLEAR20);
            end
            if (n.gemsCleared or (0)) >= 25 then
                Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_GEMCOMBO, Bejeweled.const.SKILL_CLEAR25);
            end
            n.gemsCleared = 0
            if (n.leveledUp) then
                n.leveledUp = nil
                n.levelingUp = true
                t.animationStatus = Fe
                t.spawningLevel = true
                Ke()
            else
                if (t.animationStatus > Fe) then
                    if (n.gameOver) then
                        Bejeweled.summaryScreen:FillData()
                        Bejeweled.summaryScreen:Show()
                        t.animationStatus = V
                    else
                        t.animationStatus = pe
                        t.spawnedJewels = nil;
                    end
                    t.spawnedJewels = nil
                else
                    if not n.gameOver then
                        if (n.levelingUp) then
                            UIFrameFadeOut(Bejeweled.gameStatusText, 2) UIFrameFadeOut(Bejeweled.gameStatusText.background, 2) else
                            Bejeweled.gameStatusText:Hide()
                            Bejeweled.gameStatusText.background:Hide();
                        end
                    end
                    n.levelingUp = nil
                    t.animationStatus = V
                    if not n.gameOver then
                        n.moveAllowed = true;
                    end
                    if (n.combo > n.largestCombo) then
                        n.largestCombo = n.combo;
                    end
                    if (n.combo > BejeweledProfile.stats.largestCombo) then
                        BejeweledProfile.stats.largestCombo = n.combo;
                    end
                    if (n.nextSelectedJewel) then
                        n.selectedJewel = n.nextSelectedJewel
                        n.nextSelectedJewel = nil
                        if (n.selectedJewel.fxType ~= g) then
                            n.selectedJewel.fxType = y
                            n.selectedJewel.fxEnd = nil
                            n.selectedJewel.fxFrame = 1;
                        end
                        t:Add(n.selectedJewel);
                    end
                    n.combo = 0
                    n.explosions = 0
                    o = Q()
                    if not o then
                        Me()
                    else
                        if not BejeweledProfile.settings.disableHints then
                            t:Add(t:CreateHint(o));
                        end
                        if (n.gameMode == c) then
                            St();
                        end
                    end
                    if (n.currentMouseOver) then
                        Bejeweled:UpdateMouseOver(n.currentMouseOver)
                        n.currentMouseOver = nil;
                    end
                end
            end
        end
    end
end

local function Se(l, w)
    l.elapsed = l.elapsed + w
    if (l.elapsed < l.delay) then
        return;
    end
    if not Bejeweled.isShown then
        l.elapsed = 0
        return;
    end
    local T = Bejeweled.animator
    local K = Bejeweled.gameBoard
    local k = Te * l.elapsed
    local _ = et * l.elapsed
    local P = wt * l.elapsed
    local I = Gt * l.elapsed
    local t = et * .025
    local t = 20
    if (n.levelingUp) then
        if (n.mode ~= c) then
            k = k * 2.5
            P = P * 2;
        end
    end
    local x = l.animationStack
    local r, f, i, C, t, s, j, D, L, U, r
    local c, r
    local m = l.animationStatus
    local G, v
    l.glowFrame = l.glowFrame + (w * re * l.glowFrameDir)
    if (l.glowFrame >= re) then
        l.glowFrameDir = -1
        l.glowFrame = re;
    end
    if (l.glowFrame <= 1) then
        l.glowFrameDir = 1
        l.glowFrame = 1;
    end
    local H = (l.glowFrame / re) * (1 / (z + 4))
    if (n.gameMode) then
        l.lightwaveElapsed = (l.lightwaveElapsed or (0)) + l.elapsed
        if (l.lightwaveElapsed > 25) then
            l.lightwaveElapsed = 0
            for e = 1, a do
                l:Add(l:CreateLightwave(o[e][1], e));
            end
        end
    end
    for e = 1, a do
        for n = 1, h do
            t = o[e][n]
            t.glowLevel = 0
            t.glow:SetAlpha(0);
        end
    end
    f = 1
    if (#l.newJewel > 0) then
        for e = 1, #l.newJewel do
            B(l.newJewel, 1);
        end
    end
    local w = (m ~= V) if (m == pe) then
        l:HandleJewelDropping(l)
    end
    if (m == Ct) then
        m = m + 1
        l:HandleJewelFalling(l);
    end
    for Y = 1, #x do
        t = x[f]
        t.movedOnce = nil
        if (t.fxType == De) then
            i = t.fxFrame + 1
            t.fxFrame = i
            local e = t:GetParent()
            if (i == 1) then
                if (e.gridX < 8) then
                    l:Add(l:CreateLightwave(o[e.gridY][e.gridX + 1], 0));
                end
                t.texture:SetTexCoord(unpack(N[2]))
            elseif (i == 10) then
                t.fxType = S
                u(l.lightwaveQueue, t)
                t:Hide()
                t:GetParent().lightWaveObj = nil;
            end
            if (i > 0) and (e.y >= 0) then
                t:SetAlpha((10 - i) / 10)
            else
                t:SetAlpha(0);
            end
        end
        if (m == V) then
            if (t.fxType == y) then
                i = t.fxFrame + 1
                if (i > Lt) then
                    i = 1
                    if (t.fxEnd) then
                        t.fxEnd = nil
                        t.fxType = E
                        if not t.moving then
                            t.fxType = S;
                        end
                    end
                end
                t.fxFrame = i
                t.texture:SetTexCoord(unpack(F[i]))
            elseif (t.fxType == je) then
                i = t.fxFrame + 1
                if (i > it) then
                    i = 1
                    t.nextGlow = t.nextGlow + 1
                    if (t.nextGlow > 9) then
                        t.nextGlow = 1;
                    end
                    s = t.adj
                    if s and (s.fxType == ke) then
                        s.fxEnd = true;
                    end
                    local n = t.gridX + FX_SHINE_GRIDX[t.nextGlow]
                    local e = t.gridY + FX_SHINE_GRIDY[t.nextGlow]
                    if (n >= 1) and (n <= 8) and (e >= 1) and (e <= 8) and not t.fxEnd then
                        s = o[e][n]
                        if (math.fmod(t.nextGlow, 2) == 1) then
                            s.nextGlow = t.nextGlow + 1
                        else
                            s.nextGlow = t.nextGlow - 1;
                        end
                        if (s.fxType ~= je) and (s.fxType ~= y) and (s.fxType ~= g) and (s.fxType ~= W) and (s.fxType ~= S) and not (s.moving) then
                            T:Add(s)
                            s.fxType = ke
                            s.fxFrame = 1
                            s.fxEnd = nil
                            s.highlight:SetTexCoord(unpack(N[FX_SHINE_KEYFRAME[s.nextGlow]]))
                            s.highlight:SetAlpha(0);
                        end
                    else
                        s = nil;
                    end
                    t.adj = s
                    if (t.fxEnd) then
                        t.fxEnd = nil
                        t.fxType = nil
                        B(x, f)
                        f = f - 1
                        t.animated = nil
                        t.highlight:SetTexCoord(0, 0, 0, 0)
                    else
                        t.highlight:SetTexCoord(unpack(N[FX_SHINE_KEYFRAME[t.nextGlow]]));
                    end
                end
                t.fxFrame = i
                t.highlight:SetAlpha(FX_SHINE_ALPHA[i])
            elseif (t.fxType == ke) then
                i = t.fxFrame + 1
                if (i > Re) then
                    t.fxEnd = true
                    i = 1;
                end
                if (t.fxEnd) then
                    t.fxEnd = nil
                    B(x, f)
                    f = f - 1
                    t.animated = nil
                    t.highlight:SetTexCoord(0, 0, 0, 0);
                end
                t.fxFrame = i
                t.highlight:SetAlpha(FX_SHINE_ALPHA[i]);
            end
        elseif (m == Pe) then
            if (t.fxType == A) then
                t.markX = nil
                t.markY = nil
                if (t.score) then
                    t:Show()
                    t.fxType = te
                    if not t.notScore then
                        Bejeweled.levelBar:AddScore(t.score);
                    end
                    if (t.comboSound) then
                        Bejeweled.sound:Play("Combo", t.comboSound)
                        t.comboSound = nil;
                    end
                elseif (t.bigStarSpawn) then
                    t.fxType = E
                    t.bigStar = t.bigStarSpawn
                    t.bigStarSpawn = nil
                    t.bigStar:Show()
                    Bejeweled.sound:Play("PowerCreate")
                    if not (BejeweledData.firstPowerGem) then
                        BejeweledData.firstPowerGem = true
                        Bejeweled.popup.text:SetText(Bejeweled.popup.text.tip1)
                        Bejeweled.popup.parent = t
                        Bejeweled.popup:Hide()
                        Bejeweled.popup:Show();
                    end
                elseif (t.hyperGemSpawn) then
                    t.hyperGemSpawn = nil
                    T:CreateHyperGem(t)
                    Bejeweled.sound:Play("HyperCreate")
                    if not (BejeweledData.firstHyperCube) then
                        BejeweledData.firstHyperCube = true
                        Bejeweled.popup.text:SetText(Bejeweled.popup.text.tip2)
                        Bejeweled.popup.parent = t
                        Bejeweled.popup:Hide()
                        Bejeweled.popup:Show();
                    end
                elseif (t.hyperGemTrigger) then
                    if not G then
                        G = true
                        if (t.hyperGemDelay == 1) then
                            t.hyperGemDelay = nil
                            Ce(t) if not (t.explode) then
                                t.fxEnd = nil
                                t.fxType = S
                                t.contents = 0
                                R(t);
                            end
                        else
                            t.hyperGemDelay = (t.hyperGemDelay or (0)) + 1;
                        end
                    end
                    w = nil
                elseif (t.bigStar) then
                    if (t.explode) then
                        if not v then
                            v = true
                            if t.explodeDelay then
                                t.fxType = E
                                t.bigStar:Hide()
                                t.bigStar.fxEnd = true
                                t.bigStar = nil
                                t.explode = nil
                                local r = t.forcedExplode
                                t.forcedExplode = nil
                                u(T.animationStack, T:CreateExplosion(0, 0, t))
                                for i = -1, 1 do
                                    if ((t.gridY + i) > 0) and ((t.gridY + i) <= a) then
                                        for e = -1, 1 do
                                            if ((t.gridX + e) > 0) and ((t.gridX + e) <= h) then
                                                T:CreateShardSpawn(0, 0, o[t.gridY + i][t.gridX + e], o[t.gridY + i][t.gridX + e].contents, e, i, r)
                                                if (e == 0) then
                                                    o[t.gridY + i][t.gridX + e].yVel = -20
                                                else
                                                    o[t.gridY + i][t.gridX + e].yVel = o[t.gridY + i][t.gridX + e].yVel or -10;
                                                end
                                                o[t.gridY + i][t.gridX + e].moving = le
                                                o[t.gridY + i][t.gridX + e].yOffset = o[t.gridY + i][t.gridX + e].yOffset or (0)
                                                l:Add(o[t.gridY + i][t.gridX + e])
                                                if (r) then
                                                    n.gemsCleared = n.gemsCleared - 1;
                                                end
                                                if (i == -1) then
                                                    local n
                                                    for n = t.gridY - 1, 1, -1 do
                                                        if (e == 0) then
                                                            o[n][t.gridX + e].yVel = -20
                                                        else
                                                            o[n][t.gridX + e].yVel = o[n][t.gridX + e].yVel or -10;
                                                        end
                                                        o[n][t.gridX + e].moving = le
                                                        o[n][t.gridX + e].yOffset = o[n][t.gridX + e].yOffset or (0)
                                                        l:Add(o[n][t.gridX + e]);
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                t.explodeDelay = 1;
                            end
                        end
                        w = nil;
                    end
                else
                    i = t.fxFrame + 1
                    if (i > se) then
                        i = 1
                        t.fxEnd = nil
                        t.fxType = S
                        t.contents = 0
                        R(t)
                    else
                        w = nil;
                    end
                    t.texture:SetWidth((se - i + 1) / se * b) t.texture:SetHeight((se - i + 1) / se * p) t.fxFrame = i;
                end
            end
        elseif (m == pe) then
            if (t.moving == le) then
                t.movedOnce = true
                t.yVel = t.yVel + P
                r = t.yOffset + t.yVel
                if (r >= t.maxYOffset) then
                    r = t.maxYOffset
                    t.yOffset = 0
                    t.maxYOffset = nil
                else
                    t.yOffset = r;
                end
                w = nil
                if (t.maxYOffset == nil) then
                    t.moving = nil
                    t.y = t.y + r
                    r = 0
                    t.fxFrame = 1
                    t.yVel = nil
                    if (t.fxType ~= W) and (t.fxType ~= g) then
                        if not t.explode then
                            t.fxType = S;
                        end
                    end
                    Bejeweled.sound:Play("GemClick");
                end
                t:ClearAllPoints()
                t:SetPoint("Topleft", t.x, -(t.y + r));
            end
            if (t.fxType == W) then
                r = t.y + t.yOffset
                if (r >= 0) then
                    t.texture:SetTexCoord(unpack(F[1]))
                    t.texture:ClearAllPoints() t.texture:SetPoint("Center") t.fxType = E
                    if (t.explode == 1) then
                        t.fxType = A;
                    end
                    if (t.spawnHyper) then
                        t.spawnHyper = nil
                        l:CreateHyperGem(t);
                    end
                    t.texture:SetHeight(p) if (t.bigStar) then
                        t.bigStar:Show();
                    end
                    if (t.lightWaveObj) then
                        t.lightWaveObj:Show();
                    end
                elseif (r >= -p) then
                    j, D, L, U = unpack(F[1])
                    r = d(r + p)
                    t.texture:ClearAllPoints() t.texture:SetPoint("Bottom") t.texture:SetHeight(r)
                    L = (p - r) / 255
                    t.texture:SetTexCoord(j, D, L, U)
                    if (t.lightWaveObj) then
                        t.lightWaveObj:Hide();
                    end
                else
                    t.texture:SetTexCoord(0, 0, 0, 0)
                    if (t.lightWaveObj) then
                        t.lightWaveObj:Hide();
                    end
                end
            end
        end
        if (t.moving == le) and (not t.movedOnce) then
            t.movedOnce = true
            t.yVel = t.yVel + (math.abs(t.yVel) * .1) + P
            r = t.yOffset + t.yVel
            if (t.maxYOffset) then
                if (r >= t.maxYOffset) then
                    r = t.maxYOffset
                    t.yOffset = 0
                    t.maxYOffset = nil
                else
                    t.yOffset = r;
                end
                if (t.maxYOffset == nil) then
                    t.moving = nil
                    t.y = t.y + r
                    r = 0
                    t.fxFrame = 1
                    t.yVel = nil
                    if (t.fxType ~= W) and (t.fxType ~= g) then
                        if not t.explode then
                            t.fxType = S;
                        end
                    end
                    Bejeweled.sound:Play("GemClick");
                end
            else
                t.yOffset = r;
            end
            t:ClearAllPoints()
            t:SetPoint("Topleft", t.x, -(t.y + r));
        end
        if (t.fxType == g) then
            i = t.fxFrame + 1
            if (i > mt) then
                i = 1
                if (t.fxEnd) then
                    t.fxEnd = nil;
                end
            end
            t.fxFrame = i
            t.texture:SetTexCoord(unpack(O[i]))
            local e
            for i = -2, 2 do
                if ((t.gridY + i) > 0) and ((t.gridY + i) <= a) then
                    for n = -2, 2 do
                        if ((t.gridX + n) > 0) and ((t.gridX + n) <= h) then
                            e = o[t.gridY + i][t.gridX + n]
                            if (math.abs(i) == 2) or (math.abs(n) == 2) then
                                e.glowLevel = math.min(e.glowLevel + 1, z)
                            else
                                e.glowLevel = math.min(e.glowLevel + 2, z);
                            end
                            if (e.fxType == y) or (e.y < -5) then
                                e.glow:SetAlpha(0)
                            else
                                e.glow:SetAlpha(e.glowLevel * H);
                            end
                        end
                    end
                end
            end
        elseif (t.fxType == ye) then
            i = t.fxFrame + .5
            frame2 = t.fxFrame2 - 2.5
            if (i > ve) then
                i = ve - i;
            end
            if (frame2 <= 0) then
                frame2 = ve + frame2;
            end
            if (t.fxEnd) then
                t.fxEnd = nil
                t.fxType = S
                t:Hide()
                u(l.bigStarQueue, t);
            end
            t.fxFrame = i
            t.fxFrame2 = frame2
            l:RotateTexture(t.texture, d(i), .5, .5)
            l:RotateTexture(t.highlight, d(frame2), .5, .5)
            C = t.fxAlpha + t.fxAlphaStep
            if (C > 100) then
                t.fxAlphaStep = -t.fxAlphaStep
                C = 100
            elseif (C < 0) then
                t.fxAlphaStep = -t.fxAlphaStep
                C = 0;
            end
            t.fxAlpha = C
            t.texture:SetAlpha(C / 100)
            t.highlight:SetAlpha((100 - C) / 100)
            local e
            for i = -2, 2 do
                if ((t.parent.gridY + i) > 0) and ((t.parent.gridY + i) <= a) then
                    for n = -2, 2 do
                        if ((t.parent.gridX + n) > 0) and ((t.parent.gridX + n) <= h) then
                            e = o[t.parent.gridY + i][t.parent.gridX + n]
                            if (math.abs(i) == 2) or (math.abs(n) == 2) then
                                e.glowLevel = math.min(e.glowLevel + 1, z)
                            else
                                e.glowLevel = math.min(e.glowLevel + 2, z);
                            end
                            if (e.fxType == y) or (e.y < -5) then
                                e.glow:SetAlpha(0)
                            else
                                e.glow:SetAlpha(e.glowLevel * H);
                            end
                        end
                    end
                end
            end
        elseif (t.fxType == He) then
            i = t.fxFrame + 1
            if (i > Xe) then
                i = 1
                if (t.fxEnd) then
                    t.fxEnd = nil
                    t.fxType = S
                    t:Hide();
                end
            end
            t.x = t.x + t.xVel
            t.y = t.y + t.yVel
            t:ClearAllPoints()
            t:SetPoint("Topleft", t.x, -t.y)
            t.yVel = t.yVel + k
            if (t.xVel > 0) and (t.xVel < 8) then
                t.xVel = t.xVel + .1
            elseif (t.xVel < 0) and (t.xVel > -8) then
                t.xVel = t.xVel - .1;
            end
            if (t.yVel >= Te) then
                t.fxType = S
            elseif (t.yVel > oe) then
                t:SetAlpha(1 - ((t.yVel - oe) / oe))
            end
            if (t.fxType == S) then
                t.fxEnd = nil
                t:Hide()
                u(l.shardQueue, t);
            end
            t.fxFrame = i
            t.texture:SetTexCoord(unpack(ie[i]))
        elseif (t.fxType == Oe) then
            i = t.fxFrame + 1
            if (i > bt) then
                t.fxType = S;
            end
            if (t.fxEnd) then
                t.fxEnd = nil
                t.fxType = S;
            end
            if (t.fxType == S) then
                u(l.explosionQueue, t)
                t:Hide()
            else
                t.fxFrame = i
                t.texture:SetTexCoord(unpack(J[i]));
            end
        elseif (t.fxType == We) then
            i = t.fxFrame + 1
            if (i > Rt) then
                t.fxType = S;
            end
            if (math.fmod(i, 2) == 1) then
                t.highlight:SetAlpha(.2)
            else
                t.highlight:SetAlpha(.6);
            end
            if (t.fxEnd) then
                t.fxEnd = nil
                t.fxType = S;
            end
            if (t.fxType == S) then
                u(l.lightningQueue, t)
                t:Hide()
                t.highlight:Hide()
            else
                t.fxFrame = i;
            end
        elseif (t.fxType == te) then
            i = t.fxFrame + I
            if (i > be) then
                if (i > be * 2) then
                    i = 0
                    u(l.floatingTextQueue, t)
                    t.fxType = S
                    t:Hide()
                else
                    t:SetAlpha(1 - ((i - be) / be));
                end
            end
            if (t.notScore) then
                t.y = t.y + I
            else
                t.y = t.y - I;
            end
            t:ClearAllPoints()
            t:SetPoint("Topleft", K, "Topleft", t.x, -t.y)
            t.fxFrame = i
        elseif (t.fxType == Ve) then
            t.fxFrame = t.fxFrame + l.elapsed
            if (t.fxFrame > yt) then
                t:Show()
                t.bounceY = t.bounceY + t.bounceDir
                if (t.bounceDir == 1) then
                    if (t.bounceY >= 10) then
                        t.bounceDir = -1
                        t.bounceY = 10;
                    end
                else
                    if (t.bounceY <= 0) then
                        t.bounceDir = 1
                        t.bounceY = 0;
                    end
                end
                t:ClearAllPoints()
                t:SetPoint("Topleft", t.x, -t.y + t.bounceY);
            end
        end
        if (t.moving == _e) then
            c = t.xOffset + t.xMove * _
            r = t.yOffset + t.yMove * _
            local e
            if (c >= ue) then
                c = t.xDir * ue
                t.xOffset = 0
                e = true
            else
                t.xOffset = c
                c = t.xDir * c;
            end
            if (r >= ue) then
                r = t.yDir * ue
                t.yOffset = 0
                e = true
            else
                t.yOffset = r
                r = t.yDir * r;
            end
            if (e) then
                if t.invalidMove == 1 then
                    t.xDir = -t.xDir
                    t.x = t.x + c
                    c = 0
                    t.yDir = -t.yDir
                    t.y = t.y + r
                    r = 0
                    t.invalidMove = 2
                else
                    t.moving = nil
                    if (t.invalidMove == 2) then
                        t.invalidMove = nil
                        t.x = t.x + c
                        t.y = t.y + r
                        c = 0
                        r = 0;
                    end
                    t.xOffset = 0
                    t.yOffset = 0
                    t.xMove = 0
                    t.yMove = 0
                    t.xDir = 0
                    t.yDir = 0
                    t.selector:Hide()
                    if (t.bigStar) then
                        t.bigStar:ClearAllPoints()
                        t.bigStar:SetPoint("Topleft", t, "Topleft");
                    end
                    if (t.fxType ~= A) and (t.fxType ~= g) and (t.fxType ~= W) then
                        t.fxType = S
                    end
                    if (t.hyperGemContents) then
                        if (t.swapJewel and (t.swapJewel.contents == 9)) then
                            t.swapJewel.fxType = S
                            t.swapJewel.contents = 0
                            M(1, t.swapJewel, t.hyperGemContents, nil, true, 0, true);
                        end
                        t.fxType = A
                        t.hyperGemTrigger = true
                        m = Pe
                        w = nil;
                    end
                    l.movingJewels = l.movingJewels - 1
                    t.fxFrame = 1
                    R(t)
                    if (l.movingJewels == 0) then
                        n.selectedJewel = nil
                        l.animationStatus = Pe;
                    end
                end
                c = 0
                r = 0;
            end
            t:ClearAllPoints()
            t:SetPoint("Topleft", t.x + c, -(t.y + r))
        elseif (t.moving == at) then
            t.x = t.x + t.xVel
            t.y = t.y + t.yVel
            t:ClearAllPoints()
            t:SetPoint("Topleft", t.x, -t.y)
            t.yVel = t.yVel + k
            if (t.yVel >= Te) then
                t.fxType = S
            elseif (t.yVel > oe) then
                t:SetAlpha(1 - ((t.yVel - oe) / oe))
            end
            if (t.fxType == S) then
                t.fxEnd = nil
                t.contents = 0
                t.x = (t.gridX - 1) * b
                t.y = (t.gridY - 1) * p
                t.yVel = 0
                t:SetAlpha(0)
            else
                w = nil;
            end
        end
        if (t.fxType == S) and not t.lightWave then
            B(x, f)
            t.animated = nil
            t.fxType = E
        else
            f = f + 1;
        end
    end
    if (l.newGameStart == true) then
        l:HandleNewGameCountdown();
    end
    if (w == true) then
        l:HandleAnimatorStatusChange(m);
    end
    l.elapsed = 0;
end

local function A()
    local e = CreateFrame("Frame", "", UIParent)
    e:SetWidth(1)
    e:SetHeight(1)
    e:EnableMouse(false)
    e:SetAlpha(0)
    e.animationStack = {}
    e.elapsed = 0
    e.delay = .025
    e.glowFrameDir = 1
    e.glowFrame = 1
    e:SetScript("OnUpdate", Se)
    e:SetScript("OnEvent", ze)
    e:RegisterEvent("PLAYER_ENTERING_WORLD")
    e.movingGems = 0
    e.animationStatus = V
    e.tableCos = {} e.tableSin = {} for t = 0, 360 do
        i = -math.rad(t - 135)
        e.tableSin[t] = math.sin(i) * .71
        e.tableCos[t] = math.cos(i) * .71
    end
    e:Show()
    e.shardQueue = {}
    e.lightwaveQueue = {}
    e.lightningQueue = {}
    e.explosionQueue = {}
    e.bigStarQueue = {}
    e.floatingTextQueue = {}
    e.columnOffset = {}
    e.newJewel = {}
    e.Add = st
    e.CreateBigStar = Ht
    e.CreateExplosion = Ot
    e.CreateHyperGem = It
    e.CreateImage = At
    e.CreateShard = qe
    e.CreateShardSpawn = Qe
    e.CreateFloatingText = Je
    e.CreateHint = Et
    e.CreateLightwave = vt
    e.CreateLightning = lt
    e.RotateTexture = jt
    e.HandleAnimatorStatusChange = de
    e.HandleJewelDropping = Le
    e.HandleJewelFalling = X
    e.HandleNewGameCountdown = ne
    return e;
end

local function V()
    local o = CreateFrame("Frame", "BejeweledNetwork", UIParent)
    o:SetWidth(1)
    o:SetHeight(1)
    o:SetPoint("Top")
    o:Show()
    o:RegisterEvent("CHAT_MSG_ADDON")
    o.queue = {}
    o.Send = function(l, i, o, n, t)
        if (BejeweledProfile.scoresUpdated) then
            u(Bejeweled.network.queue, i .. "+" .. o .. "~" .. n .. "~" .. (t or ("")));
        end
    end
    o.throttleCount = 0
    o.elapsed = 0
    o:SetScript("OnUpdate", function(t, o)
        if (Bejeweled.resizeUpdate) then
            if not (n.gameOver) then
                Bejeweled.levelBar:SetScore(Bejeweled.levelBar.score or (0))
            else
                Bejeweled.levelBar.bar:SetWidth(Bejeweled.levelBar:GetWidth() - 4);
            end
            Bejeweled.resizeUpdate = nil;
        end
        t.elapsed = t.elapsed + o
        if (t.elapsed < 1) then
            return;
        end
        t.elapsed = 0
        t.throttleCount = 0
        if (#t.queue > 0) then
            if (t.throttleCount < 20) then
                local e, e, e, e
                local i, o, e, n
                while (t.throttleCount < 20) do
                    o, e, n = strsplit("~", B(t.queue, 1))
                    if ((e == "GUILD") and IsInGuild()) then
                        SendAddonMessage(xe, o, e, n)
                        t.throttleCount = t.throttleCount + 1
                    elseif (e == "WHISPER") and (n ~= "") then
                        SendAddonMessage(xe, o, e, n)
                        t.throttleCount = t.throttleCount + 1;
                    end
                    if (#t.queue == 0) then
                        break;
                    end
                end
            end
        end
    end)
    o:SetScript("OnEvent", function(i, i, o, n, t, e)
        if (o == xe) and BejeweledProfile.scoresUpdated then
            local o, i
            o, n = strsplit("+", n)
            if (o == "HSPub") then
                if (t == "WHISPER") then
                    local i, o
                    for i = 1, GetNumFriends() do
                        o = GetFriendInfo(i) if (o == e) then
                            Ee(e, n, t)
                            break;
                        end
                    end
                else
                    Ee(e, n, t);
                end
            elseif (o == "HSSync") then
                Ee(e, n, t)
            elseif (o == "LogSync") and (UnitName("player") ~= e) then
                dt(e, t);
            end
        end
    end)
    Bejeweled.network = o;
end

local function O()
    local n = CreateFrame("Frame", "BejeweledSound", Bejeweled.window)
    n:SetWidth(1)
    n:SetHeight(1)
    n:SetPoint("Top")
    n:Show()
    n.playSound = nil
    n.elapsed = 0
    n.mouseOverElapsed = 0
    n.mouseOver = true
    n.lastClick = 0
    n.Play = function(t, n, o)
        if not BejeweledProfile.settings.disableSounds and Bejeweled.window:IsVisible() then
            t.playSound = true
            if (n == "Combo") then
                if (o > 6) then
                    o = 6
                end
                t[n .. o] = true;
            end
            if (n == "GemClick") then
                if (t.lastClick > .2) then
                    t[n] = true
                    t.lastClick = 0;
                end
            else
                t[n] = true;
            end
        end
    end
    n:SetScript("OnUpdate", function(t, n)
        if BejeweledProfile.settings.disableSounds then
            return;
        end
        t.mouseOverElapsed = t.mouseOverElapsed + n
        t.lastClick = t.lastClick + n
        if (t.mouseOverElapsed > .5) and (BejeweledData.legalDisplayed) then
            t.mouseOverElapsed = 0
            if t.mouseOver and not Bejeweled.window.hiding then
                if not MouseIsOver(Bejeweled.window.mouseBounds) then
                    if not Bejeweled.window.resizing then
                        t.waitMouseOver = nil
                        Bejeweled.const.windowFadeOut.fadeTimer = 0
                        UIFrameFade(Bejeweled.window, Bejeweled.const.windowFadeOut) Bejeweled.window.mouseOverScreen:Show()
                        t.mouseOver = nil
                        t:Hide()
                        if (Bejeweled.paused ~= true) then
                            Bejeweled.mousePaused = true
                            T(true);
                        end
                    end
                end
            end
            if (t.waitMouseOver) then
                if MouseIsOver(Bejeweled.window.mouseBounds) then
                    Bejeweled.window.mouseOverScreen:Hide()
                    t.waitMouseOver = nil
                    t.mouseOver = true;
                end
            end
        end
        if (t.playSound) then
            t.playSound = nil
            local e = ut
            if (BejeweledProfile.settings.quietSounds) then
                e = e .. "q_";
            end
            if (t.Invalid) then
                t.Invalid = nil
                PlaySoundFile(e .. "bad2.mp3");
            end
            if (t.Explosion) then
                t.Explosion = nil
                PlaySoundFile(e .. "bombexplode.mp3");
            end
            if (t.GetReady) then
                t.GetReady = nil
                PlaySoundFile(e .. "Get_ready.mp3");
            end
            if (t.NoMoreMoves) then
                t.NoMoreMoves = nil
                PlaySoundFile(e .. "No_More_Moves.mp3");
            end
            if (t.TimesUp) then
                t.TimesUp = nil
                PlaySoundFile(e .. "Time_Up.mp3");
            end
            if (t.Go) then
                t.Go = nil
                PlaySoundFile(e .. "Go.mp3");
            end
            if (t.Select) then
                t.Select = nil
                PlaySoundFile(e .. "select.mp3");
            end
            if (t.PowerCreate) then
                t.PowerCreate = nil
                PlaySoundFile(e .. "multishot.mp3");
            end
            if (t.HyperCreate) then
                t.HyperCreate = nil
                PlaySoundFile(e .. "hypergem_creation.mp3");
            end
            if (t.HyperDestroy) then
                t.HyperDestroy = nil
                PlaySoundFile(e .. "hypergem_destroyed.mp3");
            end
            if (t.GemClick) then
                t.GemClick = nil
                PlaySoundFile(e .. "gemongem2.mp3");
            end
            if (t.WipeBoard) then
                t.WipeBoard = nil
                PlaySoundFile(e .. "explode2.mp3");
            end
            if (t.ElectroExplode) then
                t.ElectroExplode = nil
                PlaySoundFile(e .. "electro_explode.mp3");
            end
            if (t.LevelUp) then
                t.LevelUp = nil
                PlaySoundFile("Sound\\Spells\\LevelUp.wav");
            end
            if (t.Combo) then
                local n
                for n = 1, 6 do
                    if (t["Combo" .. n]) then
                        if (n == 1) then
                            PlaySoundFile(e .. "gotset2.mp3")
                        else
                            PlaySoundFile(e .. "combo" .. (n + 1) .. "2.mp3");
                        end
                        t["Combo" .. n] = nil
                        break;
                    end
                    if (n == 6) then
                        t.Combo = nil;
                    end
                end
            end
        end
    end)
    Bejeweled.sound = n;
end

local function E()
    local t = CreateFrame("Frame", "BejeweledMinimapIcon", Minimap)
    t:SetWidth(33)
    t:SetHeight(33)
    t:SetFrameStrata("LOW")
    t:EnableMouse(true)
    t:SetClampedToScreen(true)
    t.icon = t:CreateTexture(nil, "BACKGROUND")
    t.icon:SetWidth(26)
    t.icon:SetHeight(26)
    t.icon:SetPoint("Center", -1, 1)
    t.icon:SetTexture(l .. "windowIcon")
    t.border = t:CreateTexture(nil, "ARTWORK")
    t.border:SetWidth(52)
    t.border:SetHeight(52)
    t.border:SetPoint("Topleft")
    t.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    t.highlight = t:CreateTexture(nil, "OVERLAY")
    t.highlight:SetWidth(32)
    t.highlight:SetHeight(32)
    t.highlight:SetPoint("Center")
    t.highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    t.highlight:SetBlendMode("ADD")
    t.highlight:Hide()
    t:SetPoint("Center", -(76 * math.cos(math.rad(0))), (76 * math.sin(math.rad(0))))
    t:Show()
    t:SetScript("OnMouseDown", function(e, t)
        e.icon:SetPoint("Center", 0, 0)
        if (t == "RightButton") then
            e.moving = true
        end
    end)
    t:SetScript("OnMouseUp", function(t, n)
        t.icon:SetPoint("Center", -1, 1)
        t.moving = nil
        if (n == "LeftButton") then
            local t = Bejeweled.window;
            if (t:IsVisible()) then
                if not Bejeweled.popup:IsVisible() then
                    t:Hide()
                end
            else
                t:SetAlpha(BejeweledProfile.settings.mouseoffAlpha);
                if not MouseIsOver(t) then
                    t.mouseOverScreen:Show()
                    Bejeweled.sound.mouseOver = nil;
                    Bejeweled.sound:Hide();
                    if (Bejeweled.paused ~= true) then
                        Bejeweled.mousePaused = true;
                        T(true);
                    end
                end
                t:Show()
            end
        end
    end);
    t:SetScript("OnEnter", function(e)
        e.highlight:Show();
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
        local e = BejeweledProfile.settings.keybinding or "";
        if (e ~= "") then
            e = "(" .. e .. ")";
        end
        GameTooltip:SetText("|cFFFFFFFFBejeweled |r" .. e)
        GameTooltip:AddLine("Left-click to show/hide game.\nRight-click to move icon.");
        GameTooltip:Show();
    end);
    t:SetScript("OnLeave", function(e)
        e.highlight:Hide()
        GameTooltip:Hide()
    end);
    t:SetScript("OnUpdate", function(i)
        if (i.moving) then
            local o, n = GetCursorPosition()
            local a = Minimap:GetLeft() + Minimap:GetWidth() / 2
            local l = Minimap:GetBottom() + Minimap:GetHeight() / 2
            local e = (o / UIParent:GetScale()) - a;
            local t = (n / UIParent:GetScale()) - l;
            if (sqrt(e ^ 2 + t ^ 2) > Minimap:GetWidth()) then
                BejeweledProfile.settings.minimapDetached = true;
                e = o / UIParent:GetScale();
                t = n / UIParent:GetScale();
                BejeweledProfile.settings.minimapX = e;
                BejeweledProfile.settings.minimapY = t;
                i:SetPoint("Center", UIParent, "bottomleft", e, t);
            else
                local e = math.deg(math.atan2((n / UIParent:GetScale()) - l, a - (o / UIParent:GetScale())))
                BejeweledProfile.settings.minimapAngle = e
                BejeweledProfile.settings.minimapDetached = nil
                i:SetPoint("Center", Minimap, "Center", -(76 * math.cos(math.rad(e))), (76 * math.sin(math.rad(e))))
            end
        end
    end)
    Bejeweled.minimap = t;
end

local function g()
    local t = CreateFrame("Frame", "BejeweledWindow", UIParent)
    t:SetWidth(q)
    t:SetHeight(me)
    t:SetPoint("Center")
    t:EnableMouse(true)
    t:SetToplevel(true)
    t:Hide()
    t.mouseBounds = CreateFrame("Frame", "", t)
    t.mouseBounds:SetPoint("Topleft", -20, 20)
    t.mouseBounds:SetPoint("Bottomright", 20, -20)
    t.mouseBounds:Show()
    local a = t:GetFrameLevel()
    local o = C()
    o.edgeFile = l .. "windowBorder"
    o.bgFile = l .. "windowBackground"
    o.edgeSize = 32
    o.tileSize = 64
    o.insets.right = 3
    t:SetBackdrop(o)
    t:SetBackdropColor(.7, .7, .7, 1)
    t:SetMovable(true)
    t:RegisterForDrag("LeftButton")
    t:SetScript("OnDragStart", function(e)
        if not BejeweledProfile.settings.lockWindow then
            e:StartMoving();
        end
    end)
    t:SetScript("OnDragStop", function(e)
        e:StopMovingOrSizing()
    end)
    t:SetScript("OnHide", function(t)
        Bejeweled.isShown = nil
        n.isActive = nil
        n.activeTime = 0
    end)
    t:SetScript("OnShow", function(t)
        Bejeweled.isShown = true
        Bejeweled.window:SetAlpha(BejeweledProfile.settings.gameAlpha)
        if not MouseIsOver(Bejeweled.window) then
            Bejeweled.sound.waitMouseOver = true
            Bejeweled.sound.mouseOver = nil
        else
            Bejeweled.sound.waitMouseOver = nil
            Bejeweled.sound.mouseOver = true;
        end
        Bejeweled.window.mouseOverScreen:Hide()
        Bejeweled.sound:Show()
        if (Bejeweled.summaryScreen:GetAlpha() == 1) then
            T(false);
        end
    end)
    local o = CreateFrame("Button", "", t, "UIPanelCloseButton")
    o:SetToplevel(true)
    o:SetPoint("Topright", t, "Topright", 2, 2)
    o:SetWidth(32)
    o:SetHeight(32)
    o:SetScript("OnClick", function(t)
        if not Bejeweled.popup:IsVisible() then
            Bejeweled.window:Hide();
        end
    end)
    if (bCrowbar) then
        local e = CreateFrame("Frame", "", t)
        e:SetWidth(32)
        e:SetHeight(32)
        e:SetPoint("Right", o, "Left", -2, 0)
        e.art = e:CreateTexture(nil, "Art")
        e.art:SetTexture("Interface\\AddOns\\Bejeweled\\images\\crowbar")
        e.art:SetPoint("Center")
        e.art:SetWidth(32)
        e.art:SetHeight(32)
        e:EnableMouse(true)
        e:SetScript("OnMouseDown", function(e)
            if bCrowbar.window:IsShown() then
                bCrowbar.window:Hide()
            else
                bCrowbar.window:Show();
            end
        end);
    end
    local o = CreateFrame("Button", "", t, "OptionsButtonTemplate")
    o:SetToplevel(true)
    o:SetPoint("Topright", -12, -30)
    o:SetText("Menu")
    o:SetWidth(50)
    o:SetHeight(26)
    o:SetScript("OnClick", function()
        local t = Bejeweled.menuWindow
        if (Bejeweled.aboutScreen:IsVisible() or Bejeweled.featsOfSkillScreen:IsVisible() or Bejeweled.optionsScreen:IsVisible()) then
            Bejeweled.menuWindow.keepScreen = true;
        end
        if (t:IsShown()) then
            t:Hide()
        else
            t:Show();
        end
    end)
    t.menuButton = o
    local o = t:CreateTexture(nil, "Art")
    o:SetTexture(l .. "windowIcon")
    o:SetPoint("Topleft", -12, 4)
    o:SetWidth(64)
    o:SetHeight(64)
    t.icon = o
    local o = Bejeweled.const.largeText["Bejeweled"]
    local i = CreateFrame("Frame", "", t)
    i:SetPoint("Topleft", t)
    i:SetPoint("Topright", t, -8, 0)
    i:SetHeight(o[2])
    local i = i:CreateTexture(nil, "Art")
    i:SetTexture(l .. "artPieces")
    i:SetPoint("Bottom", 0, 0)
    i:SetWidth(o[1])
    i:SetHeight(o[2])
    i:SetTexCoord(o[3], o[4], o[5], o[6])
    t.logo = i
    local o = CreateFrame("Frame", "", t)
    o:SetPoint("Bottomright", 0, 0)
    o:SetWidth(32)
    o:SetHeight(32)
    o:Show()
    o:SetFrameLevel(a + 3)
    o:EnableMouse(true)
    o:SetScript("OnMouseDown", function(n, t)
        if not BejeweledProfile.settings.lockWindow then
            if (t == "RightButton") then
                Bejeweled.window:SetWidth(q)
                Bejeweled.window:SetHeight(w + 4 + 110)
            else
                Bejeweled.window:StartSizing("Right")
                Bejeweled.window.resizing = true;
            end
        end
    end)
    o:SetScript("OnMouseUp", function(t)
        Bejeweled.window:StopMovingOrSizing()
        Bejeweled.window.resizing = nil
    end)
    t:SetMaxResize(q * 1.5, me * 1.5)
    t:SetMinResize(q / 2, me / 2)
    t:SetResizable(true)
    t:SetScript("OnSizeChanged", function(t)
        local o = t:GetWidth() / q
        local a = 1
        local i = 1
        local l = Bejeweled.const.largeText["Bejeweled"]
        if (o < .887) then
            a = o / .827 / (.827 / o)
            if not (t.menuButton.isSmall) then
                t.menuButton.isSmall = true
                t.menuButton:SetWidth(26)
                t.menuButton:SetText("M");
            end
        else
            if (t.menuButton.isSmall) then
                t.menuButton.isSmall = nil
                t.menuButton:SetWidth(50)
                t.menuButton:SetText("Menu");
            end
        end
        if (o < .855) then
            i = o / .855 / (.855 / o)
            if (i < .75) then
                i = .75;
            end
        end
        local r = t:GetWidth() - i * 56 - t.menuButton:GetWidth()
        r = math.min(l[1], r)
        a = r / l[1]
        Bejeweled.gameBoard:SetScale(o)
        Bejeweled.summaryScreen:SetScale(o)
        t:SetHeight((w + 4) * o + 110);
        if not (n.gameOver) and Bejeweled.levelBar then
            Bejeweled.levelBar:SetScore(Bejeweled.levelBar.score or (0));
        elseif Bejeweled.levelBar then
            Bejeweled.levelBar.bar:SetWidth(Bejeweled.levelBar:GetWidth() - 4);
        end
        t.logo:SetWidth(l[1] * a)
        t.logo:SetHeight(l[2] * a)
        t.icon:SetWidth(64 * i)
        t.icon:SetHeight(64 * i)
        Bejeweled.resizeUpdate = true;
    end)
    local n = CreateFrame("Frame", "BejeweledShowHideButton", UIParent)
    n:SetWidth(1)
    n:SetHeight(1)
    n:SetPoint("Bottomright")
    n:SetScript("OnMouseDown", function()
        if (Bejeweled.window:IsShown()) then
            Bejeweled.window:Hide()
        else
            Bejeweled.window:Show();
        end
    end)
    t.showHideButton = n
    n = CreateFrame("Frame", "BejeweledMouseOverScreen", t)
    n:SetPoint("Topleft")
    n:SetPoint("Bottomright")
    n:EnableMouse(true)
    n:SetScript("OnMouseDown", function(t)
        if (Bejeweled.window.hiding) then
            Bejeweled.window.hiding = nil
            Bejeweled.const.windowGameOverFadeOut.timeToFade = -1
            Bejeweled.sound.mouseOver = true
            Bejeweled.sound:Show()
            t:Hide();
        end
    end)
    n:SetScript("OnEnter", function(t)
        if (Bejeweled.window.hiding) then
            return;
        end
        t:Hide()
        Bejeweled.const.windowFadeIn.fadeTimer = 0
        UIFrameFade(Bejeweled.window, Bejeweled.const.windowFadeIn) Bejeweled.sound.mouseOver = true
        Bejeweled.sound:Show()
        if (Bejeweled.mousePaused == true) then
            if (Bejeweled.summaryScreen:GetAlpha() == 1) then
                T(false);
            end
            Bejeweled.mousePaused = nil;
        end
    end)
    n:SetFrameLevel(t:GetFrameLevel() + 80)
    t.mouseOverScreen = n
    n:Show()
    return t;
end

local function P()
    local t = CreateFrame("Frame", "BejeweledMenu", Bejeweled.window)
    t:SetWidth(f)
    t:SetHeight(L - 20)
    t:SetPoint("Center")
    t:EnableMouse(true)
    t:Hide()
    t:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 30)
    if (Bejeweled.updatePopup) then
        Bejeweled.updatePopup:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 50);
    end
    local o = C()
    o.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
    o.bgFile = l .. "windowBackground"
    o.edgeSize = 32
    o.tileSize = 128
    o.insets.top = 3
    t:SetBackdrop(o)
    t:SetBackdropColor(.6, .6, .6, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetMovable(true)
    local o = CreateFrame("Button", "", t, "UIPanelCloseButton")
    o:SetPoint("Topright", t, "Topright", 0, 2)
    o:SetWidth(38)
    o:SetHeight(38)
    local o = t:CreateFontString(nil, "Overlay")
    o:SetFont(STANDARD_TEXT_FONT, 16, "Outline")
    o:SetTextColor(1, 1, 1)
    o:SetPoint("Top", 0, -8)
    o:SetText("Menu")
    o:Show()
    t:SetScript("OnShow", function()
        T(true)
        local t = Bejeweled.menuWindow
        if not n.gameOver and (n.gameMode) then
            t.buttonResume:Show()
            t.buttonNewGame:ClearAllPoints()
            t.buttonNewGame:SetPoint("Bottom", t.buttonResume, "Bottom", 0, -32)
            t:SetHeight(L - 20)
        else
            t.buttonResume:Hide()
            t.buttonNewGame:ClearAllPoints()
            t.buttonNewGame:SetPoint("Top", t, "Top", 2, -30)
            t:SetHeight(L - 32 - 18);
        end
        Bejeweled.timedWindow:Hide()
        Bejeweled.gameModeWindow:Hide();
    end)
    t:SetScript("OnHide", function(t)
        if (t.keepScreen == true) then
            t.keepScreen = nil
        else
            T(false)
            Bejeweled.aboutScreen:Hide()
            Bejeweled.featsOfSkillScreen:Hide()
            Bejeweled.optionsScreen:Hide();
        end
    end)
    local n = CreateFrame("Button", "BejeweledButtonResume", t, "OptionsButtonTemplate")
    n:SetPoint("Top", 2, -30)
    n:SetText("Resume")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow.keepScreen = nil
        Bejeweled.menuWindow:Hide()
        Bejeweled.levelBarButton:Hide()
    end)
    t.buttonResume = n
    local n = CreateFrame("Button", "BejeweledButtonNewGame", n, "OptionsButtonTemplate")
    n:SetPoint("Bottom", 0, -32)
    n:SetParent(t)
    n:SetText("New Game")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow.keepScreen = true
        Bejeweled.menuWindow:Hide()
        Bejeweled.gameModeWindow:Show()
    end)
    t.buttonNewGame = n
    local n = CreateFrame("Button", "BejeweledButtonSkills", n, "OptionsButtonTemplate")
    n:SetPoint("Top", 0, -32)
    n:SetParent(t)
    n:SetText("Feats of Skill")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow:Hide()
        Bejeweled.aboutScreen:Hide()
        Bejeweled.optionsScreen:Hide()
        Bejeweled.featsOfSkillScreen:Show()
        if (Bejeweled.levelBarButton:GetID() == 0) then
            Bejeweled.levelBarButton:SetID(1);
        end
        Bejeweled.levelBarButton:Show();
    end)
    t.buttonSkills = n
    local n = CreateFrame("Button", "BejeweledButtonOptions", n, "OptionsButtonTemplate")
    n:SetPoint("Top", 0, -32)
    n:SetParent(t)
    n:SetText("Options")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow:Hide()
        Bejeweled.aboutScreen:Hide()
        Bejeweled.featsOfSkillScreen:Hide()
        Bejeweled.optionsScreen:Show()
        if (Bejeweled.levelBarButton:GetID() == 0) then
            Bejeweled.levelBarButton:SetID(1);
        end
        Bejeweled.levelBarButton:Show();
    end)
    t.buttonOptions = n
    local n = CreateFrame("Button", "BejeweledButtonAbout", n, "OptionsButtonTemplate")
    n:SetPoint("Top", 0, -32)
    n:SetParent(t)
    n:SetText("About")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow:Hide()
        t.tabClick(Bejeweled.aboutScreen.tab2, true)
        Bejeweled.featsOfSkillScreen:Hide()
        Bejeweled.optionsScreen:Hide()
        Bejeweled.aboutScreen:Show()
        if (Bejeweled.levelBarButton:GetID() == 0) then
            Bejeweled.levelBarButton:SetID(1);
        end
        Bejeweled.levelBarButton:Show();
    end)
    t.buttonAbout = n
    n.tabClick = U
    Bejeweled.menuWindow = t;
end

local function N()
    local t = CreateFrame("Frame", "BejeweledPopup", Bejeweled.window)
    t:SetWidth(f + 60)
    t:SetHeight(L / 1.2)
    t:SetPoint("Center")
    t:EnableMouse(true)
    t:Hide()
    Bejeweled.popup = t
    t:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 23)
    local n = C()
    n.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
    n.bgFile = l .. "windowBackground"
    n.edgeSize = 32
    n.tileSize = 128
    n.insets.top = 3
    t:SetBackdrop(n)
    t:SetBackdropColor(.6, .6, .6, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetMovable(true)
    local n = CreateFrame("Button", "", t, "UIPanelCloseButton")
    n:SetToplevel(true)
    n:SetPoint("Topright", t, "Topright", 0, 2)
    n:SetWidth(38)
    n:SetHeight(38)
    local n = t:CreateFontString(nil, "Overlay")
    n:SetFont(STANDARD_TEXT_FONT, 13, "Outline")
    n:SetTextColor(1, 1, 1)
    n:SetPoint("Top", 0, -28)
    n:SetWidth(f + 40)
    n:SetText("")
    n:Show()
    t.text = n
    t.text.tip1 = "Create a |cFF0070DD[Power Gem]|r by merging 4 gems of the same color. These new gems will explode when matched, scoring extra points!"
    t.text.tip2 = "Create a |cFFA335EE[Hyper Cube]|r by merging 5 gems of the same color. Swap it with a gem to clear all gems of that color onscreen!"
    t.text.tip3 = "Now that you've played a game, check out the Options menu to adjust the settings of Bejeweled, or check out the Feats of Skill area to check out your friend's and guild's high scores, your personal stats, and your Bejeweling Skill progress!"
    t.text.tip4 = "|cFFFFFFFF|rThis is the Skill Tab. Listed are the moves in the game that will up your Bejeweling skill. This follows other tradeskills in WoW: as you go up in skill old actions will stop giving you points and new actions will show up!"
    t:SetScript("OnShow", function(n)
        n.caption:SetText("")
        n:ClearAllPoints()
        if (n.parent) then
            n:SetPoint("Bottom", n.parent, "Top")
            n.parent = nil
        else
            n:SetPoint("Center");
        end
        Bejeweled.popup.parent = obj
        Bejeweled.window.menuButton:Disable()
        if (string.find(t.text:GetText(), "|cFF")) then
            n:SetHeight(t.text:GetHeight() + 50 + 20)
            n.button1:Show()
            n.button2:Hide()
            n.button3:Hide()
        else
            n:SetHeight(t.text:GetHeight() + 86 + 20)
            n.button1:Hide()
            n.button2:Show()
            n.button3:Show();
        end
    end)
    t:SetScript("OnHide", function(t)
        Bejeweled.window.menuButton:Enable()
    end)
    local n = t:CreateFontString(nil, "Overlay")
    n:SetFont(STANDARD_TEXT_FONT, 13, "Outline")
    n:SetTextColor(1, 1, 1)
    n:SetPoint("Top", 0, -8)
    n:SetWidth(f + 40)
    n:SetText("")
    n:Show()
    t.caption = n
    local n = CreateFrame("Button", "", t, "OptionsButtonTemplate")
    n:SetPoint("Bottom", 0, 10)
    n:SetText(OKAY)
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.popup:Hide()
    end)
    t.button1 = n
    local n = CreateFrame("Button", "", t, "OptionsButtonTemplate")
    n:SetPoint("Bottom", 0, 15)
    n:SetText("Feats of Skill")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.popup:Hide()
        Bejeweled.menuWindow.buttonSkills:GetScript("OnClick")(t)
    end)
    t.button2 = n
    local n = CreateFrame("Button", "", t.button2, "OptionsButtonTemplate")
    n:SetPoint("Bottom", t.button2, "Top", 0, 5)
    n:SetText("Options")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.popup:Hide()
        Bejeweled.menuWindow.buttonOptions:GetScript("OnClick")(t)
    end)
    t.button3 = n;
end

local function W()
    local t = CreateFrame("Frame", "BejeweledGameModeMenu", Bejeweled.window)
    t:SetWidth(f)
    t:SetHeight(L - 100)
    t:SetPoint("Center")
    t:EnableMouse(true)
    t:Hide()
    t:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 33)
    local n = C()
    n.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
    n.bgFile = l .. "windowBackground"
    n.edgeSize = 32
    n.tileSize = 128
    n.insets.top = 3
    t:SetBackdrop(n)
    t:SetBackdropColor(.6, .6, .6, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetMovable(true)
    local n = CreateFrame("Button", "", t, "UIPanelCloseButton")
    n:SetToplevel(true)
    n:SetPoint("Topright", t, "Topright", 0, 2)
    n:SetWidth(38)
    n:SetHeight(38)
    local n = t:CreateFontString(nil, "Overlay")
    n:SetFont(STANDARD_TEXT_FONT, 16, "Outline")
    n:SetTextColor(1, 1, 1)
    n:SetPoint("Top", -10, -8)
    n:SetText("Game Type")
    n:Show()
    t:SetScript("OnShow", function()
        T(true)
    end)
    t:SetScript("OnHide", function(t)
        if (t.gameMode) then
            t.gameMode = nil
            T(false)
        else
            Bejeweled.menuWindow:Show();
        end
    end)
    local n = CreateFrame("Button", "BejeweledGameModeNormal", t, "OptionsButtonTemplate")
    n:SetPoint("Top", 2, -30)
    n:SetText("Classic")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.gameModeWindow.gameMode = true
        Bejeweled.gameModeWindow:Hide()
        Bejeweled.classicModeWindow:Show()
    end)
    t.buttonNormal = n
    local n = CreateFrame("Button", "BejeweledGameModeTimed", n, "OptionsButtonTemplate")
    n:SetPoint("Bottom", 0, -36)
    n:SetParent(t)
    n:SetText("Timed")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.gameModeWindow.gameMode = true
        Bejeweled.gameModeWindow:Hide()
        Bejeweled.timedWindow:Show()
    end)
    t.buttonTimed = n
    Bejeweled.gameModeWindow = t;
end

local function F()
    local t = CreateFrame("Frame", "BejeweledClassicMenu", Bejeweled.window)
    t:SetWidth(f)
    t:SetHeight(L - 100)
    t:SetPoint("Center")
    t:EnableMouse(true)
    t:Hide()
    t:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 33)
    local n = C()
    n.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
    n.bgFile = l .. "windowBackground"
    n.edgeSize = 32
    n.tileSize = 128
    n.insets.top = 3
    t:SetBackdrop(n)
    t:SetBackdropColor(.6, .6, .6, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetMovable(true)
    local n = CreateFrame("Button", "", t, "UIPanelCloseButton")
    n:SetToplevel(true)
    n:SetPoint("Topright", t, "Topright", 0, 2)
    n:SetWidth(38)
    n:SetHeight(38)
    local n = t:CreateFontString(nil, "Overlay")
    n:SetFont(STANDARD_TEXT_FONT, 16, "Outline")
    n:SetTextColor(1, 1, 1)
    n:SetPoint("Top", -10, -8)
    n:SetText("Classic Mode")
    n:Show()
    t:SetScript("OnShow", function(e)
        if (BejeweledProfile) and (BejeweledProfile.settings) and (BejeweledProfile.settings.savedState) and (BejeweledProfile.settings.savedState[1][1] ~= 0) then
            T(true)
        else
            e.gameMode = true
            e:Hide()
            j(c, 0);
        end
    end)
    t:SetScript("OnHide", function(t)
        if (t.gameMode) then
            t.gameMode = nil
            T(false)
        else
            Bejeweled.gameModeWindow:Show();
        end
    end)
    local n = CreateFrame("Button", "BejeweledClassicNewGame", t, "OptionsButtonTemplate")
    n:SetPoint("Top", 2, -30)
    n:SetText("Continue")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        j(c, 0, true)
        Bejeweled.classicModeWindow.gameMode = true
        Bejeweled.classicModeWindow:Hide()
    end)
    t.buttonContinue = n
    local n = CreateFrame("Button", "BejeweledClassicContinue", n, "OptionsButtonTemplate")
    n:SetPoint("Bottom", 0, -36)
    n:SetParent(t)
    n:SetText("New Game")
    n:SetWidth(f - 20)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        j(c, 0)
        Bejeweled.classicModeWindow.gameMode = true
        Bejeweled.classicModeWindow:Hide()
    end)
    t.buttonNew = n
    Bejeweled.classicModeWindow = t;
end

local function D()
    local n = CreateFrame("Frame", "BejeweledFlightOptionMenu", UIParent)
    n:SetWidth(f)
    n:SetHeight(L)
    n:SetToplevel(true)
    n:SetFrameStrata("High")
    n:SetPoint("Center")
    n:EnableMouse(true)
    n:Hide()
    n.pathArray = {}
    local t = C()
    t.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border"
    t.bgFile = l .. "windowBackground"
    t.edgeSize = 32
    t.tileSize = 128
    t.insets.top = 3
    n:SetBackdrop(t)
    n:SetBackdropColor(.6, .6, .6, 1)
    n:SetBackdropBorderColor(1, .8, .45)
    n:SetMovable(true)
    local t = CreateFrame("Button", "", n, "UIPanelCloseButton")
    t:SetToplevel(true)
    t:SetPoint("Topright", n, "Topright", 0, 2)
    t:SetWidth(38)
    t:SetHeight(38)
    local t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 16, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", -10, -8)
    t:SetText("Flight Path")
    t:Show()
    t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 12, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -38)
    t:SetText("Remaining path time")
    t:Show()
    n.timerRemainingCaption = t
    t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 18, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -54)
    t:SetText("0 min 0 sec")
    t:Show()
    n.timeRemainingValue = t
    t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 12, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -80)
    t:SetWidth(f - 16)
    t:SetHeight(40)
    t:SetJustifyV("Top")
    t:SetJustifyH("Center")
    t:SetText("Games shorter than 60 seconds don't count.")
    t:Show()
    n:SetScript("OnShow", function(t)
        if not (t.timer.elapsed) then
            t.buttonGo.disabled = nil
            t.buttonGo:Enable()
            t.timer.elapsed = 0
            t.timer.timeElapsed = 0
            t.timer.timeRemaining = t.flightTime or 0 
            t.timer.legJourney = 0
            t.timer.learning = t.learning
            t.timer:Show()
            -- Bejeweled.timedWindow.timeRemainingValue:SetFormattedText("%d min %d sec", Bejeweled:SecondsConvert(t.flightTime)) -- This is the legacy implementation of what attempts to estimate flight path time.
			Bejeweled.timedWindow.timeRemainingValue:SetFormattedText("%d min %d sec", Bejeweled:SecondsConvert(120)) -- FixMe - Workaround:  Setting Default Flight Time to 120 so we don't divide by zero
            if (Bejeweled.timedWindow:IsVisible()) then
                Bejeweled.timedWindow:SetHeight(L - 30)
                Bejeweled.timedWindow.flightCheckbox:Show()
                Bejeweled.timedWindow.flightCheckboxCaption:Hide()
                Bejeweled.timedWindow.flightCheckbox:SetChecked(nil)
                Bejeweled.timedWindow.flightCheckbox:Enable()
                Bejeweled.timedWindow.flightCheckbox.disabled = nil
                Bejeweled.timedWindow.timerRemainingCaption:Show()
                Bejeweled.timedWindow.timeRemainingValue:Show();
            end
            if (t.learning) then
                Bejeweled.timedWindow.timerRemainingCaption:SetText("Recording flight time")
            else
                Bejeweled.timedWindow.timerRemainingCaption:SetText("Remaining flight time");
            end
            if (BejeweledProfile.settings.newGameFlight) and (Bejeweled.window:IsVisible() or BejeweledProfile.settings.openFlightStart) then
                Bejeweled.flightOptionWindow.buttonGo:OnClickScript()
            else
                t:Hide();
            end
            Bejeweled.window:RegisterEvent("PLAYER_CONTROL_GAINED")
            Bejeweled.window:RegisterEvent("PLAYER_LEAVING_WORLD")
            Bejeweled.window.switchingZones = nil;
        end
        t.timer.windowElapsed = 0;
    end)
    local t = CreateFrame("Button", "BejeweledFlightOptionGo", n, "OptionsButtonTemplate") t:SetPoint("Top", 2, -120)
    t:SetText("Start")
    t:SetWidth(f - 20)
    t:SetHeight(28)
    t.OnClickScript = function(t)
        if (Bejeweled.flightOptionWindow.timer.learning) then
            j(k, Bejeweled.flightOptionWindow.timer.timeElapsed)
            Bejeweled.flightOptionWindow.learning = true
        else
            j(k, Bejeweled.flightOptionWindow.timer.timeRemaining);
        end
        Bejeweled.flightOptionWindow:Hide()
        Bejeweled.timedWindow:Hide()
        Bejeweled.gameModeWindow:Hide()
        Bejeweled.menuWindow:Hide()
        Bejeweled.featsOfSkillScreen:Hide()
        Bejeweled.window:Show();
    end
    t:SetScript("OnClick", t.OnClickScript)
    n.buttonGo = t
    local t = CreateFrame("Frame", "BejeweledFlightTimer", UIParent)
    t:SetPoint("Top")
    t:SetWidth(1)
    t:SetHeight(1)
    t:Hide()
    t.timeRemaining = 0
    t:SetScript("OnUpdate", Ne)
    n.timer = t
    Bejeweled.flightOptionWindow = n;
end

local function R()
    local o = CreateFrame("Frame", "BejeweledTimedMenu", Bejeweled.window)
    o:SetWidth(f)
    o:SetHeight(L - 30)
    o:SetPoint("Center")
    o:EnableMouse(true)
    o:Hide()
    o:SetFrameLevel(Bejeweled.window:GetFrameLevel() + 33)
    local t = C()
    t.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" t.bgFile = l .. "windowBackground"
    t.edgeSize = 32
    t.tileSize = 128
    t.insets.top = 3
    o:SetBackdrop(t)
    o:SetBackdropColor(.6, .6, .6, 1)
    o:SetBackdropBorderColor(1, .8, .45)
    o:SetMovable(true)
    local t = CreateFrame("Button", "", o, "UIPanelCloseButton") t:SetToplevel(true)
    t:SetPoint("Topright", o, "Topright", 0, 2) t:SetWidth(38)
    t:SetHeight(38)
    local t = o:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 16, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", -10, -8)
    t:SetText("Timed Mode")
    t:Show()
    o:SetScript("OnShow", function(t)
        T(true)
        t.flightCheckbox.disabled = nil
        t.flightCheckbox:Enable()
        t.flightCheckboxCaption:Hide()
        t.flightCheckbox:SetChecked(nil)
        if (Bejeweled.flightOptionWindow.timer:IsVisible()) then
            t:SetHeight(L - 30)
            t.flightCheckbox:Show()
            t.timerRemainingCaption:Show()
            t.timeRemainingValue:Show()
        else
            t:SetHeight(L - 80)
            t.flightCheckbox:Hide()
            t.timerRemainingCaption:Hide()
            t.timeRemainingValue:Hide();
        end
    end)
    o:SetScript("OnHide", function(t)
        if (t.newGame) then
            t.newGame = nil
            T(false)
            if (n.gameMode == ae) then
                Bejeweled.levelBar:StopTimer()
            elseif (n.gameMode == k) then
                Bejeweled.animator.countdownState = 0
                n.moveAllowed = nil;
            end
        else
            if not o:IsShown() then
                Bejeweled.gameModeWindow:Show();
            end
        end
    end)
    t = o:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 10, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -28)
    t:SetText("Time")
    t:Show()
    t = o:CreateFontString("BejeweledTimeSliderValue", "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 10, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -70)
    t:SetText("1 Minute")
    t:Show()
    local n = CreateFrame("Slider", "BejeweledTimeSlider", o, "OptionsSliderTemplate")
    getglobal(n:GetName() .. "Thumb"):Show()
    getglobal(n:GetName() .. "Text"):SetText(objectText)
    getglobal(n:GetName() .. "Text"):SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    getglobal(n:GetName() .. "Low"):SetText("")
    getglobal(n:GetName() .. "Low"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    getglobal(n:GetName() .. "High"):SetText("")
    getglobal(n:GetName() .. "High"):SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    n:Show()
    n:SetMinMaxValues(2, 10)
    n:SetValueStep(1)
    n:SetPoint("Top", 0, -50)
    n:SetScript("OnValueChanged", function(e)
        getglobal(e:GetName() .. "Value"):SetText(e:GetValue() .. " Minute(s)")
    end)
    n:SetValue(5)
    local n = Bejeweled:CreateCheckbox(14, -88, "Use flightpath time", "useFlightpathTime", 1, o, function()
    end)
    getglobal(n:GetName() .. "Text"):SetFont(STANDARD_TEXT_FONT, 11)
    getglobal(n:GetName() .. "Text"):SetShadowOffset(1, -1)
    o.flightCheckbox = n
    t = o:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 11, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -87)
    t:SetText("|cFFFF9922Flight time is too\nshort for a timed game.")
    t:Show()
    o.flightCheckboxCaption = t
    t = o:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 10, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -118)
    t:SetText("Remaining flight time")
    t:Show()
    o.timerRemainingCaption = t
    t = o:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 10, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Top", 0, -134)
    t:SetText("0s")
    t:Show()
    o.timeRemainingValue = t
    local t = CreateFrame("Button", "BejeweledTimedButtonGo", o, "OptionsButtonTemplate") t:SetPoint("Bottom", 1, 10)
    t:SetText("Go!")
    t:SetWidth(f - 20)
    t:SetHeight(28)
    t:SetScript("OnClick", function(t)
        if (Bejeweled.timedWindow.flightCheckbox:IsVisible() and Bejeweled.timedWindow.flightCheckbox:GetChecked()) then
            Bejeweled.flightOptionWindow.buttonGo:OnClickScript()
        else
            j(ae, getglobal("BejeweledTimeSlider"):GetValue() * 60);
        end
        Bejeweled.timedWindow.newGame = true
        Bejeweled.timedWindow:Hide();
    end)
    Bejeweled.timedWindow = o;
end

local function M(t)
    Bejeweled.window:RegisterEvent("UNIT_FLAGS")
end

local function y(t)
    local i = t:GetID()
    local h = GetNumRoutes(i)
    local C, w, p, f
    local g = TaxiRouteMap:GetWidth()
    local c = TaxiRouteMap:GetHeight()
    local n
    local o
    local a = 0
    local s = 0
    local S
    local r = Bejeweled.flightOptionWindow.pathArray
    local t
    for e = 1, #r do
        B(r, 1);
    end
	-- FixMe:  This triggers when we talk to a flight master.  There is no 'TaxiNodeSetCurrent', 'GetCurrentMapContinent', or 'SetMapToCurrentZone'.  
	--		   As such, we just remove this entirely.  
    -- SetMapToCurrentZone()
    -- local t = ge[GetCurrentMapContinent()] or BejeweledData.flightTimes[GetCurrentMapContinent()]
    -- if not (t) then
    --     BejeweledData.flightTimes[GetCurrentMapContinent()] = {}
    --     t = BejeweledData.flightTimes[GetCurrentMapContinent()];
    -- end
    local m = TaxiNodeGetType(i)
	-- FixMe:    This block of code attempts to determine how much time a flight path will take to complete.
	-- 			 We don't want to ever hit this 'if' block (it's calling funcs that no longer exist), so we just ask it to eval 1 == 0 to avoid it.
    if (m == "REACHABLE" and 1 == 0) then
        TaxiNodeSetCurrent(i)
        if (h > NUM_TAXI_ROUTES) then
            NUM_TAXI_ROUTES = h;
        end
        for l = 1, NUM_TAXI_ROUTES do
            if (l <= h) then
                C = TaxiGetSrcX(i, l) * g
                w = TaxiGetSrcY(i, l) * c
                p = TaxiGetDestX(i, l) * g
                f = TaxiGetDestY(i, l) * c
                n = string.format("%d,%d", C, w)
                o = string.format("%d,%d", p, f)
                s = 0
                if not (t[n]) then
                    t = BejeweledData.flightTimes[GetCurrentMapContinent()]
                    if not t[n] then
                        t[n] = {};
                    end
                end
                if not (t[n][o]) then
                    t = BejeweledData.flightTimes[GetCurrentMapContinent()]
                    if not t then
                        BejeweledData.flightTimes[GetCurrentMapContinent()] = {}
                        t = BejeweledData.flightTimes[GetCurrentMapContinent()];
                    end
                    if not (t[n]) then
                        t = BejeweledData.flightTimes[GetCurrentMapContinent()]
                        if not t[n] then
                            t[n] = {};
                        end
                    end
                end
                if (t == ge) then
                    local e = BejeweledData.flightTimes[GetCurrentMapContinent()]
                    if (e) then
                        if (e[n]) then
                            if (e[n][o]) then
                                t = e;
                            end
                        end
                    end
                end
                t[n][o] = t[n][o] or 0
                s = t[n][o]
                a = a + s
                if (l > 2) then
                    a = a - 1.5;
                end
                if (s == 0) then
                    S = true;
                end
                u(r, n)
                u(r, o)
                u(r, s);
            end
        end
        Bejeweled.flightOptionWindow.flightTime = d(a)
        Bejeweled.flightOptionWindow.learning = S
        if (BejeweledProfile.settings.showFlightTooltips) then
            if (S) then
                GameTooltip:AddLine("Travel time: Unknown (one or more")
                GameTooltip:AddLine("legs of the journey need to be timed)")
            else
                GameTooltip:AddLine("Travel time: " .. Bejeweled:TotalTime(d(a)), 1, 1, 0);
            end
        end
        GameTooltip:Show()
    elseif (m == "CURRENT") then
    end
end

local function B()
    local n = Bejeweled.window
    local o = CreateFrame("Frame", "BejeweledSummaryScreen", getglobal("BejeweledGameBoardAnchor"))
    o:SetPoint("Top", 0, -3) o:SetWidth(s + 6)
    o:SetHeight(w + 6)
    local a = C()
    a.bgFile = l .. "windowBackground"
    a.tileSize = 128
    a.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" a.edgeSize = 32
    o:SetBackdrop(a)
    o:SetBackdropColor(.7, .7, .7, 1)
    o:SetBackdropBorderColor(1, .8, .45)
    o:SetFrameLevel(n:GetFrameLevel() + 20)
    o:Hide()
    Bejeweled.summaryScreen = o
    local t = Bejeweled:CreateCaption(0, 0, "Game Over!", o, 20, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -10)
    t:Show()
    local l = CreateFrame("Frame", "", o)
    l:SetPoint("Top", 0, -36) l:SetWidth(s + 6 - 24)
    l:SetHeight(w + 6 - 48)
    l:SetBackdrop(a)
    l:SetBackdropColor(.2, .2, .2, 1)
    l:SetBackdropBorderColor(1, 1, 1)
    l:SetFrameLevel(n:GetFrameLevel() + 21)
    l:Show()
    o.FillData = _t
    i = 2
    local n = 42
    local r = 20
    t = Bejeweled:CreateCaption(0, 0, "Final Score", l, 14, 1, 1, 0)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + r
    o.scoreCaption = t
    I = string.lower(G(t:GetText(), 7))
    t = Bejeweled:CreateCaption(0, 0, "0", l, 20, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + n
    o.scoreValue = t
    t = Bejeweled:CreateCaption(0, 0, "Time", l, 14, 1, 1, 0)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + r
    o.timeCaption = t
    t = Bejeweled:CreateCaption(0, 0, "1 min 3 sec", l, 20, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + n
    o.timeValue = t
    t = Bejeweled:CreateCaption(0, 0, "Level", l, 14, 1, .7, 0)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + r
    o.levelCaption = t
    t = Bejeweled:CreateCaption(0, 0, "15", l, 20, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + n
    o.levelValue = t
    t = Bejeweled:CreateCaption(0, 0, "Largest Cascade", l, 14, 1, .7, 0)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + r
    o.cascadeCaption = t
    t = Bejeweled:CreateCaption(0, 0, "5", l, 20, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + n
    o.cascadeValue = t
    t = Bejeweled:CreateCaption(0, 0, "Largest Combo", l, 14, 1, .7, 0)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + r
    o.comboCaption = t
    t = Bejeweled:CreateCaption(0, 0, "12", l, 20, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -20 - i)
    i = i + n
    o.comboValue = t
    local n = CreateFrame("Button", "BejeweledSummaryButtonPublish", l, "OptionsButtonTemplate") n:SetPoint("Bottomleft", 8, 10)
    n:SetText("Publish Scores")
    n:SetWidth(120)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        if (t.dataDump) then
            Bejeweled.network:Send("HSPub", t.dataDump, "GUILD", "")
            local o, n
            for o = 1, GetNumFriends() do
                n, _, _, _, online = GetFriendInfo(o) if (online) then
                    Bejeweled.network:Send("HSPub", t.dataDump, "WHISPER", n);
                end
            end
            t.dataDump = nil
            t:Hide()
            Bejeweled.menuWindow.buttonSkills:GetScript("OnClick")(Bejeweled.menuWindow.buttonSkills)
            Bejeweled.featsOfSkillScreen.tab3:GetScript("OnMouseDown")(Bejeweled.featsOfSkillScreen.tab3);
        end
        Bejeweled.popup:Hide();
    end)
    o.publishButton = n
    n = CreateFrame("Button", "BejeweledSummaryButtonViewScores", l, "OptionsButtonTemplate") n:SetPoint("Bottom", 0, 10)
    n:SetText("See High Scores")
    n:SetWidth(128)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        Bejeweled.menuWindow.buttonSkills:GetScript("OnClick")(Bejeweled.menuWindow.buttonSkills)
        Bejeweled.featsOfSkillScreen.tab3:GetScript("OnMouseDown")(Bejeweled.featsOfSkillScreen.tab3)
        Bejeweled.popup:Hide()
    end)
    o.seeScoresButton = n
    n = CreateFrame("Button", "BejeweledSummaryButtonBrag", l, "OptionsButtonTemplate") n:SetPoint("Bottomright", -8, 10)
    n:SetText("Brag!")
    n:SetWidth(120)
    n:SetHeight(28)
    n:SetScript("OnClick", function(t)
        local e = Bejeweled.summaryScreen
        e.bragScreen:Show()
        e.publishButton:Disable()
        e.seeScoresButton:Disable()
        e.bragButton:Disable()
    end)
    o.bragButton = n
    Bejeweled.Dropdown_Item_OnClick = function(t)
        local e = UIDROPDOWNMENU_OPEN_MENU
        UIDropDownMenu_SetText(e, t:GetText(), e)
        UIDropDownMenu_SetSelectedValue(e, t.value)
        BejeweledProfile.settings.defaultPublish = t.value
    end
    local i = function(i, o, r, n, l, s, a, d, s)
        local n = CreateFrame("Frame", "BejeweledDropdown_" .. n, a, "UIDropDownMenuTemplate")
        n:SetHitRectInsets(10, 10, 0, 0)
        if (l) then
            n.text = Bejeweled:CreateCaption(i, o, l, a, 14, 1, 1, 0)
            n.text:SetParent(n)
            n.text:ClearAllPoints()
            n.text:SetPoint("Bottom", n, "Top", 0, 4)
            o = o + 16;
        end
        n.updateFunc = d
        n.menuWidth = r
        n.selectedValue = 1
        n.bejeweledMenu = true
        n.displayMode = "MENU"
        getglobal(n:GetName() .. "Text"):SetFont(n.text:GetFont())
        getglobal(n:GetName() .. "Text"):SetVertexColor(1, 1, 1)
        getglobal(n:GetName() .. "Text"):SetJustifyH("CENTER")
        n.InitializeFunc = function(i)
            if (UIDROPDOWNMENU_MENU_LEVEL == 1) then
                local t
                local t
                local t = Bejeweled.const.dropInfo
                if (i.publish) then
                    table.wipe(t)
                    local o = Bejeweled.const.channels[1]
                    for n = 1, 3 do
                        table.wipe(t)
                        t.text = Bejeweled.const.channelNames[n]
                        t.value = Bejeweled.const.channels[n]
                        if (BejeweledProfile.settings.defaultPublish == t.value) then
                            o = t.value;
                        end
                        t.arg1 = 1
                        t.func = Bejeweled.Dropdown_Item_OnClick
                        UIDropDownMenu_AddButton(t);
                    end
                    local l = string.lower(BejeweledProfile.settings.defaultPublish)
                    local n = i:GetParent()
                    n:refreshChannels(EnumerateServerChannels()) for i = 1, #n.channelNames do
                        table.wipe(t)
                        t.text = n.channelNames[i]
                        if (l == string.lower(t.text)) then
                            o = t.text;
                        end
                        t.value = t.text
                        t.arg1 = 1
                        t.func = Bejeweled.Dropdown_Item_OnClick
                        UIDropDownMenu_AddButton(t);
                    end
                    BejeweledProfile.settings.defaultPublish = o;
                end
            end
        end
        n:SetPoint("Topleft", i - 16, -o)
        n:SetScript("OnShow", function(e)
            UIDropDownMenu_SetAnchor(e, 0, 0, "Top", e, "Bottom")
            UIDropDownMenu_Initialize(e, e.InitializeFunc)
            UIDropDownMenu_SetSelectedValue(e, BejeweledProfile.settings.defaultPublish) UIDropDownMenu_SetWidth(e, e.menuWidth)
            e.selectedValue = BejeweledProfile.settings.defaultPublish
        end)
        return n;
    end
    t = CreateFrame("Frame", "", o)
    t:SetPoint("Center")
    t:SetWidth(340)
    t:SetHeight(200)
    t:EnableMouse(true)
    t:SetFrameLevel(t:GetFrameLevel() + 3)
    o.bragScreen = t
    t:Hide()
    t:SetBackdrop(a)
    t:SetBackdropColor(.7, .7, .7, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t.serverChannels = {}
    t.channelNames = {}
    t.refreshChannels = function(e, ...)
        table.wipe(e.serverChannels)
        local t
        for t = 1, #(...) do
            u(e.serverChannels, (select(t, ...)));
        end
        table.wipe(e.channelNames)
        local t, n
        for n = 1, 15 do
            _, t = GetChannelName(n)
            if (t) then
                for n = 1, #e.serverChannels do
                    if (string.find(t, e.serverChannels[n])) then
                        t = nil
                        break;
                    end
                end
                if (t) then
                    u(e.channelNames, t)
                end
            end
        end
    end
    text = Bejeweled:CreateCaption(0, 0, "What channel would you like to brag to?", t, 17, 1, .82, 0) text:ClearAllPoints()
    text:SetPoint("Top", 0, -36)
    text:SetWidth(290)
    local o = i(40, 72, 240, "defaultPublish", "", nil, t, nil)
    o.publish = true
    n = CreateFrame("Button", "BejeweledBragScreenBrag", t, "OptionsButtonTemplate") n:SetText("Brag!")
    n:SetWidth(120)
    n:SetHeight(28)
    n:ClearAllPoints()
    n:SetPoint("Bottomleft", 16, 16)
    n:SetScript("OnClick", function(t)
        local e = Bejeweled.summaryScreen
        local t = GetChannelName(BejeweledProfile.settings.defaultPublish)
        if (t > 0) then
            SendChatMessage(e.bragString, "CHANNEL", nil, t)
        else
            SendChatMessage(e.bragString, BejeweledProfile.settings.defaultPublish);
        end
        e.bragString = nil
        e.bragScreen:Hide()
        e.bragButton:Hide()
        e.publishButton:Enable()
        e.seeScoresButton:Enable()
        e.bragButton:Enable();
    end)
    n = CreateFrame("Button", "BejeweledBragScreenBack", t, "OptionsButtonTemplate") n:SetText("Back")
    n:SetWidth(120)
    n:SetHeight(28)
    n:ClearAllPoints()
    n:SetPoint("Bottomright", -16, 16)
    n:SetScript("OnClick", function(t)
        t:GetParent():Hide()
        local e = Bejeweled.summaryScreen
        e.publishButton:Enable()
        e.seeScoresButton:Enable()
        e.bragButton:Enable();
    end);
end

local function u()
    local o = Bejeweled.window
    local t
    local t = getglobal("BejeweledGameBoard")
    local a = CreateFrame("Frame", "BejeweledFeatsOfSkillScreen", t)
    a:SetPoint("Top", 0, -3 - 22) a:SetWidth(s + 6)
    a:SetHeight(w + 6 - 22)
    a:EnableMouse(true)
    local d = C()
    d.bgFile = l .. "windowBackground"
    d.tileSize = 128
    d.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" d.edgeSize = 32
    a:SetBackdrop(d)
    a:SetBackdropColor(.43, .43, .43, 1)
    a:SetBackdropBorderColor(1, .8, .45)
    a:SetFrameLevel(o:GetFrameLevel() + 25)
    a:Hide()
    a:SetScript("OnShow", function(t)
        T(true)
        t.tab1:Show()
        t.tab2:Show()
        t.tab3:Show()
        t.tab4:Show()
        getglobal("BejeweledGame"):SetAlpha(0)
        Bejeweled.summaryScreen:SetAlpha(0)
        Bejeweled.animator.hintObj:SetAlpha(0)
    end)
    a:SetScript("OnHide", function(t)
        getglobal("BejeweledGame"):SetAlpha(1)
        Bejeweled.summaryScreen:SetAlpha(1)
        Bejeweled.animator.hintObj:SetAlpha(1)
    end)
    Bejeweled.featsOfSkillScreen = a
    local n = 1.2
    local t = CreateFrame("Frame", "", a)
    t:SetPoint("Bottomleft", a, "Topleft", 4, -14)
    t:SetWidth(88)
    t:SetHeight(32)
    t:SetScale(n) t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft")
    t.texture:SetWidth(88)
    t.texture:SetHeight(30)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(0 / 256, 86 / 256, 0 / 256, 31 / 256)
    t.texture:Show()
    t:EnableMouse(true)
    t:SetID(1)
    t:SetScript("OnMouseDown", U)
    a.tab1 = t
    t = CreateFrame("Frame", "", a)
    t:SetPoint("Topleft", a.tab1, "Topright")
    t:SetWidth(48)
    t:SetHeight(32)
    t:SetScale(n) t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft", a.tab1.texture, "Topright")
    t.texture:SetWidth(48)
    t.texture:SetHeight(30)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(86 / 256, 131 / 256, 0 / 256, 31 / 256)
    t.texture:Show()
    t.texture:SetVertexColor(.5, .5, .5)
    t:SetFrameLevel(o:GetFrameLevel() + 24)
    t:EnableMouse(true)
    t:SetID(2)
    t:SetScript("OnMouseDown", U)
    a.tab2 = t
    t = CreateFrame("Frame", "", a)
    t:SetPoint("Topleft", a.tab2, "Topright")
    t:SetWidth(93)
    t:SetHeight(32)
    t:SetScale(n) t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft", a.tab2.texture, "Topright")
    t.texture:SetWidth(93)
    t.texture:SetHeight(30)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(131 / 256, 221 / 256, 0 / 256, 31 / 256)
    t.texture:Show()
    t.texture:SetVertexColor(.5, .5, .5)
    t:SetFrameLevel(o:GetFrameLevel() + 24)
    t:EnableMouse(true)
    t:SetID(3)
    t:SetScript("OnMouseDown", U)
    a.tab3 = t
    t = CreateFrame("Frame", "", a)
    t:SetPoint("Topleft", a.tab3, "Topright")
    t:SetWidth(104)
    t:SetHeight(32)
    t:SetScale(n) t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft", a.tab3.texture, "Topright")
    t.texture:SetWidth(104)
    t.texture:SetHeight(30)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(0 / 256, 102 / 256, 32 / 256, 63 / 256)
    t.texture:Show()
    t.texture:SetVertexColor(.5, .5, .5)
    t:SetFrameLevel(o:GetFrameLevel() + 24)
    t:EnableMouse(true)
    t:SetID(4)
    t:SetScript("OnMouseDown", U)
    a.tab4 = t
    local i = CreateFrame("Frame", "", a)
    i:SetPoint("Top", 0, -10) i:SetWidth(s + 6 - 24)
    i:SetHeight(w + 6 - 68)
    a.tab1Content = i
    t = Bejeweled:CreateCaption(0, 0, "Bejeweling Skill Rank: ________", i, 16, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -2)
    t:Show()
    i.title = t
    local n = CreateFrame("Frame", "BejeweledSkillBar", i)
    n:SetPoint("Top", 0, -20) n:SetWidth(s + 6 - 24)
    n:SetHeight(32)
    d = C()
    d.edgeFile = "Interface\\Buttons\\UI-SliderBar-Border" d.edgeSize = 8
    d.bgFile = l .. "windowBackground"
    d.tileSize = 64
    d.insets.left = 2
    d.insets.right = 2
    n:SetBackdrop(d)
    n:SetBackdropColor(.1, .1, .1, 0)
    n:SetFrameLevel(i:GetFrameLevel() + 2)
    Bejeweled.skillBar = n
    n.CheckSkill = function(o, t, n, S)
        local r = BejeweledProfile.skill.skillPoints
        local o = Bejeweled.const.skillData
        local l
        local d
        local h
        local s
        local a = 450
        if (Bejeweled.skillLimit) then
            a = 375
        end
        local c = (a == r)
        if (((r >= o[t][n][2]) or (S)) and (r < a)) or ((t >= 6) and (r >= o[t][n][2])) then
            local i = 0
            while ((i < 3) and (r >= o[t][n][3 + i])) do
                i = i + 1;
            end
            if (t >= 6) then
                i = 0;
            end
            if (i < 3) or (S) then
                if (i == 0) then
                    l = 1
                else
                    if (m(1, 100) <= (100 - i * 33)) then
                        l = 1;
                    end
                end
                if (S) then
                    l = 1;
                end
                if (l) then
                    if (t < 6) then
                        BejeweledProfile.skill.skillPoints = BejeweledProfile.skill.skillPoints + 1
                    else
                        if (o[t][n][2] <= r) and (o[t][n][2] < (a - 1)) then
                            h = '[Bejeweled Addon] You just completed "' .. o[t][n][1] .. '."' if (t == Bejeweled.const.SKILLTYPE_FUN) then
                                BejeweledProfile.skill.skillPoints = BejeweledProfile.skill.skillPoints + 3
                                BejeweledProfile.skill["gainFun" .. n] = true
                                d = Bejeweled.animator:CreateFloatingText(50, 0, "+3 Skill", 3, true)
                                s = 3
                                if (n == 14) then
                                    BejeweledData.gainFun14 = true;
                                end
                            elseif (t == Bejeweled.const.SKILLTYPE_ACHIEVEMENT) then
                                BejeweledProfile.skill.skillPoints = BejeweledProfile.skill.skillPoints + 5
                                BejeweledProfile.skill["gainAchieve" .. n] = true
                                d = Bejeweled.animator:CreateFloatingText(50, 0, "+5 Skill", 3, true)
                                s = 5;
                            end
                            if not BejeweledProfile.skill["gainAchieve" .. Bejeweled.const.SKILL_ACHIEVE6A] then
                                local t, t
                                local t = true
                                for e = 1, #o[Bejeweled.const.SKILLTYPE_FUN] do
                                    if not BejeweledProfile.skill["gainFun" .. e] then
                                        t = nil
                                        break;
                                    end
                                end
                                if (t == true) then
                                    for n = 1, #o[Bejeweled.const.SKILLTYPE_ACHIEVEMENT] do
                                        if (n ~= Bejeweled.const.SKILL_ACHIEVE6A) then
                                            if not BejeweledProfile.skill["gainAchieve" .. n] then
                                                t = nil
                                                break;
                                            end
                                        end
                                    end
                                end
                                if (t) then
                                    Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE6A);
                                end
                            end
                        else
                            l = nil;
                        end
                    end
                    if (d) then
                        d.fxType = te
                        d:Show()
                        Bejeweled.animator:Add(d);
                    end
                    if (S) then
                        BejeweledProfile.skill.skillPoints = BejeweledProfile.skill.skillPoints + 4;
                    end
                    if (BejeweledProfile.skill.skillPoints > a) then
                        BejeweledProfile.skill.skillPoints = a;
                    end
                    if (l) and (s or (c ~= true)) then
                        if (BejeweledProfile.settings.publishSkillGains) then
                            if (s) then
                                if (c) then
                                    Bejeweled:Print(h, ChatTypeInfo["SKILL"].r, ChatTypeInfo["SKILL"].g, ChatTypeInfo["SKILL"].b)
                                else
                                    Bejeweled:Print(h .. " +" .. s .. " Skill!", ChatTypeInfo["SKILL"].r, ChatTypeInfo["SKILL"].g, ChatTypeInfo["SKILL"].b);
                                end
                            else
                                if (BejeweledProfile.settings.verboseSkills) then
                                    Bejeweled:Print('[Bejeweled Addon] You just completed "' .. o[t][n][1] .. '."', ChatTypeInfo["SKILL"].r, ChatTypeInfo["SKILL"].g, ChatTypeInfo["SKILL"].b);
                                end
                                Bejeweled:Print("Your skill in Bejeweling has increased to " .. BejeweledProfile.skill.skillPoints .. ".", ChatTypeInfo["SKILL"].r, ChatTypeInfo["SKILL"].g, ChatTypeInfo["SKILL"].b);
                            end
                        end
                        Bejeweled.skillBar.bar:SetWidth((Bejeweled.skillBar:GetWidth() - 4) * ((BejeweledProfile.skill.skillPoints - ((BejeweledProfile.skill.rank - 1) * 75)) / 75) + .5)
                        if (BejeweledProfile.skill.skillPoints >= BejeweledProfile.skill.rank * 75) then
                            if (BejeweledProfile.skill.rank < 6) then
                                if (a == 450) or (BejeweledProfile.skill.rank < 5) then
                                    BejeweledProfile.skill.rank = BejeweledProfile.skill.rank + 1
                                    if (BejeweledProfile.settings.publishSkillGains) then
                                        Bejeweled:Print("Your Bejeweling skill is now of the " .. Bejeweled.const.skillDataRanks[BejeweledProfile.skill.rank] .. " rank.", ChatTypeInfo["SKILL"].r, ChatTypeInfo["SKILL"].g, ChatTypeInfo["SKILL"].b);
                                    end
                                    if (BejeweledProfile.settings.publishRankGains) and (IsInGuild()) then
                                        local t = "[Bejeweled Addon]: I have become a"
                                        local n = BejeweledProfile.skill.rank
                                        if (n == 1) or (n == 3) or (n == 4) then
                                            t = t .. "n "
                                        else
                                            t = t .. " ";
                                        end
                                        SendChatMessage(t .. Bejeweled.const.skillDataRanks[BejeweledProfile.skill.rank] .. " in Bejeweling Skill!", "GUILD");
                                    end
                                end
                            else
                            end
                            Bejeweled.skillBar.leftIcon:SetTexCoord(((BejeweledProfile.skill.rank - 1) * 16 / 128), (BejeweledProfile.skill.rank * 16 / 128), 0, 1)
                            Bejeweled.skillBar.rightIcon:SetTexCoord((BejeweledProfile.skill.rank * 16 / 128), ((BejeweledProfile.skill.rank + 1) * 16 / 128), 0, 1)
                            Bejeweled.skillBar.bar:SetWidth(1);
                        end
                    end
                    Bejeweled.skillBar.text:SetFormattedText("%d / %d", BejeweledProfile.skill.skillPoints, (BejeweledProfile.skill.rank * 75))
                    Bejeweled.featsOfSkillScreen.tab1Content:UpdateSkillScreen()
                    Bejeweled.featsOfSkillScreen.tab4Content:UpdateSkillScreen();
                end
            end
        end
        return l or (0);
    end
    local o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -20) o:SetWidth(s + 6 - 24)
    o:SetHeight(32)
    d = C()
    d.bgFile = l .. "windowBackground"
    d.tileSize = 128
    d.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" d.edgeSize = 32
    d.insets.left = 2
    d.insets.right = 2
    o:SetBackdrop(d)
    o:SetBackdropColor(.1, .1, .1)
    o:SetBackdropBorderColor(0, 0, 0, 0)
    o:SetFrameLevel(i:GetFrameLevel() + 1)
    local o = o:CreateTexture(nil, "OVERLAY")
    o:SetTexture(l .. "barArt")
    o:SetVertexColor(0, .2, 1) o:SetPoint("Topleft", 2, -5)
    o:SetHeight(32)
    n.bar = o
    n.text = Bejeweled:CreateCaption(0, 0, "0 / 75", n, 12, 1, 1, 1, true)
    n.text:ClearAllPoints()
    n.text:SetPoint("Center", 0, 1)
    local o = n:CreateTexture(nil, "OVERLAY")
    o:SetTexture(l .. "rankIcons")
    o:SetPoint("Topleft", 3, -6)
    o:SetWidth(20)
    o:SetHeight(20)
    o:SetTexCoord(0, 0, 0, 0)
    n.leftIcon = o
    o = n:CreateTexture(nil, "OVERLAY")
    o:SetTexture(l .. "rankIcons")
    o:SetPoint("Topright", -3, -6)
    o:SetWidth(20)
    o:SetHeight(20)
    o:SetTexCoord(0, 0, 0, 0)
    n.rightIcon = o
    local o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -52) o:SetWidth(s + 6 - 24)
    o:SetHeight(21 * 15)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    local f = CreateFrame("ScrollFrame", "BejeweledSkillListScroller", o, "UIPanelScrollFrameTemplate")
    f:SetPoint("Topleft", 0, -9)
    f:SetPoint("Bottomright", -32, 9)
    local S = CreateFrame("Frame", "BejeweledSkillList", o)
    S:SetPoint("Top", 0, -9) S:SetWidth(s + 6 - 24)
    S:SetHeight(21 * 15 * 3)
    S:Show()
    f:SetScrollChild(S)
    o = S
    local n
    local c
    local r = function(e)
        e.text:SetVertexColor(1, 1, 1)
    end
    local p = function(e)
        e.text:SetVertexColor(1, .82, 0)
    end
    local m = function(i)
        local t
        local t = Bejeweled.featsOfSkillScreen.tab1Content
        local n = i:GetID()
        local o
        local a = Bejeweled.const.skillData
        local l
        local l = Bejeweled.featsOfSkillScreen.tab1Content.skillTextSize
        if (i.opened) then
            i.opened = nil
            for e = 1, #a[n] do
                o = t["section" .. n .. "Item" .. e]
                o:SetHeight(.01)
                o.text:Hide()
                if (o.hasData) then
                    t.scrollHeight = t.scrollHeight - l;
                end
            end
            if (n < 5) then
                t["section" .. Y(n + 1) .. "Header"]:ClearAllPoints()
                t["section" .. Y(n + 1) .. "Header"]:SetPoint("Topleft", i, "Bottomleft", 0, -2);
            end
            i.expander:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
        else
            i.opened = true
            local e
            for i = 1, #a[n] do
                o = t["section" .. n .. "Item" .. i]
                if (o.hasData) then
                    o:SetHeight(l + 1)
                    o.text:Show()
                    e = o
                    t.scrollHeight = t.scrollHeight + l
                else
                    break;
                end
            end
            if (n < 5) and (e) then
                t["section" .. (n + 1) .. "Header"]:ClearAllPoints()
                t["section" .. (n + 1) .. "Header"]:SetPoint("Topleft", e, "Bottomleft", 0, -2);
            end
            i.expander:SetTexture("Interface\\Buttons\\UI-MinusButton-UP");
        end
        getglobal("BejeweledSkillList"):SetHeight(t.scrollHeight);
    end
    local h = 13
    i.skillTextSize = h
    for n = 1, 5 do
        t = CreateFrame("Frame", "", o)
        t:SetWidth(o:GetWidth())
        t:SetHeight(h + 1)
        t:SetScript("OnEnter", r)
        t:SetScript("OnLeave", p)
        t:SetScript("OnMouseDown", m)
        t:SetID(n)
        t:EnableMouse(true)
        t.expander = t:CreateTexture(nil, "ARTWORK")
        t.expander:SetWidth(14)
        t.expander:SetHeight(14)
        t.expander:SetPoint("Topleft", 10, 0)
        t.expander:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
        t.opened = true
        if (n == 1) then
            t:SetPoint("Topleft", 0, -2)
        else
            t:SetPoint("Topleft", c, "Bottomleft", 0, -2);
        end
        i["section" .. n .. "Header"] = t
        t.text = Bejeweled:CreateCaption(27, 0, Bejeweled.const.skillDataNames[n], t, h, 1, .82, 0)
        c = t
        for l = 1, #Bejeweled.const.skillData[n] do
            t = CreateFrame("Frame", "", o)
            t:SetWidth(o:GetWidth())
            t:SetHeight(h + 1)
            t:SetPoint("Topleft", c, "Bottomleft", 0, -2)
            i["section" .. n .. "Item" .. l] = t
            t.text = Bejeweled:CreateCaption(32, 0, "Item " .. l, t, h, 1, 1, 0)
            t.text:SetVertexColor(.5, .5, .5)
            t.hasData = true
            c = t;
        end
    end
    i.UpdateSkillScreen = function(n)
        local t = BejeweledProfile.skill.rank
        local S = BejeweledProfile.skill.skillPoints
        n.title:SetFormattedText("Bejeweling Skill Rank: %s", Bejeweled.const.skillDataRanks[t])
        Bejeweled.skillBar.text:SetFormattedText("%d / %d", BejeweledProfile.skill.skillPoints, (BejeweledProfile.skill.rank * 75))
        Bejeweled.skillBar.bar:SetWidth((Bejeweled.skillBar:GetWidth() - 4) * ((BejeweledProfile.skill.skillPoints - ((BejeweledProfile.skill.rank - 1) * 75)) / 75) + 1)
        Bejeweled.skillBar.leftIcon:SetTexCoord(((BejeweledProfile.skill.rank - 1) * 16 / 128), (BejeweledProfile.skill.rank * 16 / 128), 0, 1)
        Bejeweled.skillBar.rightIcon:SetTexCoord((BejeweledProfile.skill.rank * 16 / 128), ((BejeweledProfile.skill.rank + 1) * 16 / 128), 0, 1)
        local t
        local l = 1
        local t, t, o, h, s
        local a = Bejeweled.const.skillData
        local d = Bejeweled.featsOfSkillScreen.tab1Content.skillTextSize
        local r = 1
        for e = 1, 5 do
            n["section" .. e .. "Header"].current = 1
            n["section" .. e .. "Header"]:SetHeight(.01)
            n["section" .. e .. "Header"]:Hide()
            for t = 1, #a[e] do
                o = n["section" .. e .. "Item" .. t] o.hasData = nil
                o.text:Hide()
                o:SetHeight(.01);
            end
        end
        for t = 1, 5 do
            if (t > 1) and (h) then
                if (s) then
                    n["section" .. t .. "Header"]:ClearAllPoints()
                    n["section" .. t .. "Header"]:SetPoint("Topleft", s, "Bottomleft", 0, -2);
                end
            end
            h = n["section" .. t .. "Header"].opened
            foundFeat = nil
            for i = #a[t], 1, -1 do
                if (a[t][i]) then
                    if (S >= a[t][i][2]) then
                        l = 1
                        while ((l < 4) and (S >= a[t][i][2 + l])) do
                            l = l + 1;
                        end
                        if (l == 4) then
                            if (S >= a[t][i][5] + 20) then
                                l = nil;
                            end
                        end
                        if (l) then
                            if not foundFeat then
                                foundFeat = true
                                s = nil;
                            end
                            itemID = n["section" .. t .. "Header"].current
                            n["section" .. t .. "Header"].current = itemID + 1
                            o = n["section" .. t .. "Item" .. itemID] o.hasData = true
                            s = o
                            r = r + d
                            o.text:SetText(a[t][i][1])
                            o.text:SetVertexColor(unpack(Bejeweled.const.skillDataColors[l]))
                            if (h) then
                                o:SetHeight(d + 1)
                                o.text:Show();
                            end
                        end
                    end
                end
            end
            if (foundFeat) then
                n["section" .. t .. "Header"]:SetHeight(d + 1)
                n["section" .. t .. "Header"]:Show()
                r = r + d;
            end
        end
        Bejeweled.featsOfSkillScreen.tab1Content.scrollHeight = r
        getglobal("BejeweledSkillList"):SetHeight(r)
        if not (BejeweledData.firstSkillShow) and (n:IsVisible()) then
            BejeweledData.firstSkillShow = true
            Bejeweled.popup.text:SetText(Bejeweled.popup.text.tip4)
            Bejeweled.popup:Hide()
            Bejeweled.popup:SetFrameLevel(Bejeweled.featsOfSkillScreen.tab1Content:GetFrameLevel() + 5)
            Bejeweled.popup:Show()
            Bejeweled.popup.caption:SetText("Bejeweling Skill");
        end
    end
    i:SetScript("OnShow", i.UpdateSkillScreen)
    i = CreateFrame("Frame", "", a)
    i:SetPoint("Top", 0, -10)
    i:SetWidth(s + 6 - 24)
    i:SetHeight(w + 6 - 68)
    i:Hide()
    i:SetScript("OnShow", function(t)
        t.scoreClassic:SetText(Bejeweled:NumberWithCommas(BejeweledProfile.stats.classic.score))
        t.scoreTimed:SetFormattedText("%.2f", BejeweledProfile.stats.timed.score)
        t.highestLevel:SetText(BejeweledProfile.stats.classic.highestLevel)
        t.mostMoves:SetText(BejeweledProfile.stats.timed.mostMoves)
        t.largestCascade:SetText(BejeweledProfile.stats.largestCascade)
        t.largestCombo:SetText(BejeweledProfile.stats.largestCombo)
        t.totalPlayed:SetText(Bejeweled:TotalTime(BejeweledProfile.stats.played))
        t.classicPlayed:SetText(Bejeweled:TotalTime(BejeweledProfile.stats.classic.played))
        t.timedPlayed:SetText(Bejeweled:TotalTime(BejeweledProfile.stats.timed.played))
        t.combatPaused:SetText(BejeweledProfile.stats.combatPause)
        t.totalGems:SetText(BejeweledProfile.stats.totalGemsMatched)
        t.totalGames:SetText(K)
        t.totalHyper:SetText(BejeweledProfile.stats.totalHyperGems)
        t.totalPower:SetText(BejeweledProfile.stats.totalPowerGems)
        local e = 1
        local n
        for t = 2, #BejeweledProfile.stats.gemMatch do
            if (BejeweledProfile.stats.gemMatch[t] > BejeweledProfile.stats.gemMatch[e]) then
                e = t;
            end
        end
        if (e == 1) and (BejeweledProfile.stats.gemMatch[1] == BejeweledProfile.stats.gemMatch[2]) then
            t.favoriteColor:SetText("|cFFFFFFFF" .. NONE)
        else
            t.favoriteColor:SetText(ft[e]);
        end
    end)
    a.tab2Content = i
    t = Bejeweled:CreateCaption(0, 0, "Personal Bests", i, 16, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -2)
    t:Show()
    o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -26) o:SetWidth(s + 6 - 24)
    o:SetHeight(6 * 20 + 6)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    n = 9
    local r = 16
    t = Bejeweled:CreateCaption(10, n, "Best Classic Mode Score |cFFFF9922(Points)", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Best Timed Mode Score |cFFFF9922(PPS)", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Highest Level |cFFFF9922(Classic)", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Most Moves |cFFFF9922(Timed)", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Largest Cascade", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Largest Combo", o, r, 1, .85, .1)
    n = n + 18
    n = 9
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.scoreClassic = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.scoreTimed = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.highestLevel = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.mostMoves = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.largestCascade = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.largestCombo = t
    t = Bejeweled:CreateCaption(0, 0, "Fun Statistics", i, 16, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -24 - 132)
    t:Show()
    o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -36 - 20 - 122) o:SetWidth(s + 6 - 24)
    o:SetHeight(9 * 20 + 4)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    n = 11
    t = Bejeweled:CreateCaption(10, n, "Total Time /Played", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Classic Mode /Played", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Timed Mode /Played", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Times Entered Combat While Playing", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Favorite Color |cFFFF9922(Gem)", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Total Gems Matched", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "Total Games Played", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "|cFFA335EE[Hyper Cube]|r Total", o, r, 1, .85, .1)
    n = n + 18
    t = Bejeweled:CreateCaption(10, n, "|cFF0070DD[Power Gem]|r Total", o, r, 1, .85, .1)
    n = n + 18
    n = 11
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.totalPlayed = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.classicPlayed = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.timedPlayed = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.combatPaused = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.favoriteColor = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.totalGems = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.totalGames = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.totalHyper = t
    t = Bejeweled:CreateCaption(10, n, "0", o, r, 1, 1, 1)
    t:ClearAllPoints()
    t:SetPoint("TopRight", -10, -n) n = n + 18
    i.totalPower = t
    i = CreateFrame("Frame", "", a)
    i:SetPoint("Top", 0, -10) i:SetWidth(s + 6 - 24)
    i:SetHeight(w + 6 - 68)
    i:Hide()
    i:SetID(3)
    i:SetScript("OnShow", function(e)
        local t = e:GetID()
        if (t == 3) then
            e:PopulateScores("friends") elseif (t == 4) then
            e:PopulateScores("guild")
        end
    end)
    i.PopulateScores = nt
    a.tab3Content = i
    local n = function(e)
        local t = string.match(e:GetName(), "BejeweledCheckBox(.*)")
        getglobal("BejeweledCheckBoxviewFriends"):SetChecked(nil)
        getglobal("BejeweledCheckBoxviewGuild"):SetChecked(nil)
        e:SetChecked(true)
        local t = e:GetParent()
        t:SetID(e:GetID())
        t:Hide()
        t:Show()
    end
    t = Bejeweled:CreateCheckbox(10, 0, "Show Friends Scores", "viewFriends", 1, i, n, true)
    getglobal(t:GetName() .. "Text"):SetFont(l .. "Contb___.ttf", 12, "Outline")
    getglobal(t:GetName() .. "Text"):SetTextColor(1, .85, .1)
    getglobal(t:GetName() .. "Text"):SetText("Show Friends Scores")
    t:SetHitRectInsets(0, -130, 0, 0)
    t:SetID(3)
    t:SetChecked(true)
    i.friends = t
    t = Bejeweled:CreateCheckbox(200, 0, "Show Guild Scores", "viewGuild", 1, i, n, true)
    getglobal(t:GetName() .. "Text"):SetFont(l .. "Contb___.ttf", 12, "Outline")
    getglobal(t:GetName() .. "Text"):SetTextColor(1, .85, .1)
    getglobal(t:GetName() .. "Text"):SetText("Show Guild Scores")
    t:SetHitRectInsets(0, -130, 0, 0)
    t:SetID(4)
    i.guild = t
    t = Bejeweled:CreateCaption(0, 0, "Best Classic Mode Score |cFFFF9922(Points)", i, 12, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -2 - 9 - 9 - 2)
    t:Show()
    o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -26 - 9 - 2) o:SetWidth(s + 6 - 24)
    o:SetHeight(150 + 6)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    for n = 1, 10 do
        t = Bejeweled:CreateCaption(10, n * 14 - 7, (n .. "."), o, 12, 1, .53, .13)
        t:ClearAllPoints()
        t:SetPoint("Topright", o, "Topleft", 38, -(n * 14 - 7))
        t = o:CreateTexture(nil, "ARTWORK")
        t:SetTexture(l .. "rankIcons")
        t:SetTexCoord(0, 0, 0, 0)
        t:SetWidth(10)
        t:SetHeight(10)
        t:SetPoint("Topleft", 40, -(n * 14 - 6))
        i["classicRank" .. n] = t
        t = Bejeweled:CreateCaption(54, n * 14 - 7, "Moongaze", o, 12, 1, .85, .1)
        i["classicName" .. n] = t
        t = Bejeweled:CreateCaption(10, n * 14 - 7, "9876543", o, 12, 1, 1, 1)
        t:ClearAllPoints()
        t:SetPoint("Topright", -10, -(n * 14 - 7))
        i["classicScore" .. n] = t;
    end
    t = Bejeweled:CreateCaption(0, 0, "Best Timed Mode Score |cFFFF8822(PPS)", i, 12, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -26 - 154 - 4 - 9)
    t:Show()
    o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -26 - 154 - 26) o:SetWidth(s + 6 - 24)
    o:SetHeight(150 + 6)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    for n = 1, 10 do
        t = Bejeweled:CreateCaption(10, n * 14 - 7, (n .. "."), o, 12, 1, .53, .13)
        t:ClearAllPoints()
        t:SetPoint("Topright", o, "Topleft", 38, -(n * 14 - 7))
        t = o:CreateTexture(nil, "ARTWORK")
        t:SetTexture(l .. "rankIcons")
        t:SetTexCoord(0, 0, 0, 0)
        t:SetWidth(10)
        t:SetHeight(10)
        t:SetPoint("Topleft", 40, -(n * 14 - 6))
        i["timedRank" .. n] = t
        t = Bejeweled:CreateCaption(54, n * 14 - 7, "Moongaze", o, 12, 1, .85, .1)
        i["timedName" .. n] = t
        t = Bejeweled:CreateCaption(10, n * 14 - 7, "9876543", o, 12, 1, 1, 1)
        t:ClearAllPoints()
        t:SetPoint("Topright", -10, -(n * 14 - 7))
        i["timedScore" .. n] = t;
    end
    i = CreateFrame("Frame", "", a)
    i:SetPoint("Top", 0, -10)
    i:SetWidth(s + 6 - 24)
    i:SetHeight(w + 6 - 68)
    i:Hide()
    i:SetID(4)
    i:SetScript("OnShow", function(e)
        local t = e:GetID()
        if (t == 3) then
            e:PopulateScores("friends") elseif (t == 4) then
            e:PopulateScores("guild")
        end
    end)
    a.tab4Content = i
    t = Bejeweled:CreateCaption(0, 0, "Achievements must be completed with the addon shown\nand a game in progress.\nAchievements Unlocked: 2 of 23\nAchievements Completed: 2", i, 12, 1, .85, .1, true)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, 0)
    t:SetWidth(s + 6 - 24)
    t:Show()
    t.caption = "Achievements must be completed with the addon shown\nand a game in progress.\nAchievements Unlocked: %d of %d\nAchievements Completed: %d"
    i.title = t
    o = CreateFrame("Frame", "", i)
    o:SetPoint("Top", 0, -52) o:SetWidth(s + 6 - 24)
    o:SetHeight(21 * 15)
    o:SetBackdrop(d)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:Show()
    f = CreateFrame("ScrollFrame", "BejeweledAchievementListScroller", o, "UIPanelScrollFrameTemplate")
    f:SetPoint("Topleft", 0, -9)
    f:SetPoint("Bottomright", -32, 9)
    S = CreateFrame("Frame", "BejeweledAchievementList", o)
    S:SetPoint("Top", 0, -9) S:SetWidth(s + 6 - 24)
    S:SetHeight(21 * 15 * 3)
    S:Show()
    f:SetScrollChild(S)
    o = S
    h = 13
    i.skillTextSize = h
    c = nil
    for n = 6, 7 do
        for a = 1, #Bejeweled.const.skillData[n] do
            t = CreateFrame("Frame", "", o)
            t:SetWidth(387) t:SetHeight(59) t:SetScale(.87)
            if not c then
                t:SetPoint("Topleft", 14, 0)
            else
                t:SetPoint("Topleft", c, "Bottomleft", 0, 0);
            end
            i["section" .. n .. "Item" .. a] = t
            t.title = Bejeweled:CreateCaption(54, 4, Bejeweled.const.skillData[n][a][6], t, h, 1, 1, 1, nil, true)
            t.title:SetVertexColor(1, 1, 1)
            t.title:SetWidth(280)
            t.title:SetJustifyH("Center")
            t.text = Bejeweled:CreateCaption(54, 22, Bejeweled.const.skillData[n][a][1], t, h, 1, 1, 1, nil, true)
            t.text:SetVertexColor(0, 0, 0)
            t.text:SetWidth(280)
            t.text:SetJustifyH("Center")
            t.texture = t:CreateTexture(nil, "ARTWORK")
            t.texture:SetAllPoints(t)
            t.texture:SetTexture(l .. "achievementplates")
            t.texture:SetTexCoord(0, 401 / 512, 0, 60 / 128)
            t.icon = t:CreateTexture(nil, "OVERLAY")
            t.icon:SetPoint("TopLeft", 10, -10)
            t.icon:SetWidth(32)
            t.icon:SetHeight(32)
            t.icon:SetTexture(Bejeweled.const.skillData[n][a][7])
            t.icon:SetVertexColor(.5, .5, .5)
            t.hasData = true
            c = t;
        end
    end
    i.UpdateSkillScreen = function(r)
        local t = BejeweledProfile.skill.rank
        local f = BejeweledProfile.skill.skillPoints
        local t
        local t = 1
        local n, n, t, n, n
        local n = Bejeweled.const.skillData
        local o = Bejeweled.featsOfSkillScreen.tab4Content.skillTextSize
        local d = 1
        local o
        local l, c, a
        local h = 0
        local s = 0
        local S = 0
        for e = #n, 6, -1 do
            for n = #n[e], 1, -1 do
                t = r["section" .. e .. "Item" .. n] t.hasData = nil
                t.text:Hide()
                t.title:Hide()
                t.texture:Hide()
                t.icon:Hide()
                t:SetHeight(.01)
                s = s + 1;
            end
        end
        for e = 6, #n do
            for o = 1, #n[e] do
                if (n[e][o]) then
                    if (f >= n[e][o][2]) then
                        h = h + 1
                        t = r["section" .. e .. "Item" .. o] t.hasData = true
                        d = d + 51
                        if ((e == 6) and (BejeweledProfile.skill["gainFun" .. o] == true)) or ((e == 7) and (BejeweledProfile.skill["gainAchieve" .. o] == true)) then
                            S = S + 1
                            if not l then
                                t:SetPoint("Topleft", 14, 0)
                            else
                                t:SetPoint("Topleft", l, "Bottomleft", 0, 0);
                            end
                            l = t
                            t.title:SetVertexColor(1, 1, 1)
                            t.text:SetVertexColor(0, 0, 0)
                            t.texture:SetTexCoord(0, 401 / 512, 0, 60 / 128)
                            t.icon:SetVertexColor(1, 1, 1)
                        else
                            if c then
                                t:SetPoint("Topleft", c, "Bottomleft", 0, 0)
                            else
                                a = t;
                            end
                            c = t
                            t.title:SetVertexColor(.7, .7, .7)
                            t.text:SetVertexColor(1, 1, 1)
                            t.texture:SetTexCoord(0, 401 / 512, 60 / 128, 120 / 128)
                            t.icon:SetVertexColor(.5, .5, .5);
                        end
                        t.text:Show()
                        t.title:Show()
                        t.texture:Show()
                        t.icon:Show()
                        t:SetHeight(59);
                    end
                end
            end
        end
        if l then
            if a then
                a:SetPoint("Topleft", l, "Bottomleft", 0, 0);
            end
        else
            if a then
                a:SetPoint("Topleft", 14, 0);
            end
        end
        r.title:SetFormattedText(r.title.caption, h, s, S)
        Bejeweled.featsOfSkillScreen.tab4Content.scrollHeight = d
        getglobal("BejeweledAchievementList"):SetHeight(d)
        if not (BejeweledData.firstSkillShow) and (r:IsVisible()) then
            BejeweledData.firstSkillShow = true
            Bejeweled.popup.text:SetText(Bejeweled.popup.text.tip4)
            Bejeweled.popup:Hide()
            Bejeweled.popup:SetFrameLevel(Bejeweled.featsOfSkillScreen.tab1Content:GetFrameLevel() + 5)
            Bejeweled.popup:Show()
            Bejeweled.popup.caption:SetText("Bejeweling Skill");
        end
    end
    i:SetScript("OnShow", i.UpdateSkillScreen);
end

local function m()
    local n = Bejeweled.window
    local t
    local t = getglobal("BejeweledGameBoard")
    local i = CreateFrame("Frame", "BejeweledAboutScreen", t)
    i:SetPoint("Top", 0, -3 - 22) i:SetWidth(s + 6)
    i:SetHeight(w + 6 - 22)
    i:EnableMouse(true)
    local r = C()
    r.bgFile = l .. "windowBackground"
    r.tileSize = 128
    r.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" r.edgeSize = 32
    i:SetBackdrop(r)
    i:SetBackdropColor(.43, .43, .43, 1)
    i:SetBackdropBorderColor(1, .8, .45)
    i:SetFrameLevel(n:GetFrameLevel() + 25)
    i:Hide()
    i:SetScript("OnShow", function(t)
        T(true)
        t.tab1:Show()
        t.tab2:Show()
        t.tab3:Show()
        getglobal("BejeweledGame"):SetAlpha(0)
        Bejeweled.summaryScreen:SetAlpha(0)
        Bejeweled.animator.hintObj:SetAlpha(0)
    end)
    i:SetScript("OnHide", function(t)
        getglobal("BejeweledGame"):SetAlpha(1)
        Bejeweled.summaryScreen:SetAlpha(1)
        Bejeweled.animator.hintObj:SetAlpha(1)
    end)
    Bejeweled.aboutScreen = i
    local t = CreateFrame("Frame", "", i)
    t:SetPoint("Bottomleft", i, "Topleft", 5, -14)
    t:SetWidth(133)
    t:SetHeight(34)
    t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft")
    t.texture:SetWidth(133)
    t.texture:SetHeight(34)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(0 / 255, 111 / 255, 64 / 255, 95 / 255)
    t.texture:Show()
    t:EnableMouse(true)
    t:SetID(1)
    t:SetScript("OnMouseDown", U)
    i.tab1 = t
    t = CreateFrame("Frame", "", i)
    t:SetPoint("Bottomleft", i, "Topleft", 139, -14)
    t:SetWidth(133)
    t:SetHeight(34)
    t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft")
    t.texture:SetWidth(133)
    t.texture:SetHeight(34)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(112 / 255, 223 / 255, 64 / 255, 95 / 255)
    t.texture:Show()
    t.texture:SetVertexColor(.5, .5, .5)
    t:SetFrameLevel(n:GetFrameLevel() + 24)
    t:EnableMouse(true)
    t:SetID(2)
    t:SetScript("OnMouseDown", U)
    i.tab2 = t
    t = CreateFrame("Frame", "", i)
    t:SetPoint("Bottomright", i, "Topright", -2, -14)
    t:SetWidth(133)
    t:SetHeight(34)
    t:Show()
    t.texture = t:CreateTexture(nil, "ARTWORK") t.texture:SetPoint("Topleft")
    t.texture:SetWidth(133)
    t.texture:SetHeight(34)
    t.texture:SetTexture(l .. "tabs")
    t.texture:SetTexCoord(0 / 255, 111 / 255, 96 / 255, 127 / 255)
    t.texture:Show()
    t.texture:SetVertexColor(.5, .5, .5)
    t:SetFrameLevel(n:GetFrameLevel() + 24)
    t:EnableMouse(true)
    t:SetID(3)
    t:SetScript("OnMouseDown", U)
    i.tab3 = t
    local a = CreateFrame("Frame", "", i)
    a:SetPoint("Top", 0, -10) a:SetWidth(s + 6 - 24)
    a:SetHeight(w + 6 - 68)
    i.tab1Content = a
    local n = CreateFrame("Frame", "", a)
    n:SetPoint("Topleft", 5, -5) n:SetWidth(376)
    n:SetHeight(118)
    n:SetBackdrop(r)
    n:SetBackdropColor(.2, .2, .2, 1)
    n:SetBackdropBorderColor(1, 1, 1)
    n:Show()
    local o = Bejeweled.const.largeText["Tutorial_1"]
    t = n:CreateTexture(nil, "ARTWORK")
    t:SetTexture(l .. "artPieces")
    t:SetTexCoord(o[3], o[4], o[5], o[6])
    t:SetWidth(o[1])
    t:SetHeight(o[2])
    t:ClearAllPoints()
    t:SetPoint("Center", -85, 0)
    t = Bejeweled:CreateCaption(0, 0, "|cFFFF9922Swap adjacent gems to make sets of 3!", n, 14, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Center", 85, 0)
    t:SetWidth(160)
    t:Show()
    n = CreateFrame("Frame", "", a)
    n:SetPoint("Topleft", 5, -5 - 118) n:SetWidth(376)
    n:SetHeight(118)
    n:SetBackdrop(r)
    n:SetBackdropColor(.2, .2, .2, 1)
    n:SetBackdropBorderColor(1, 1, 1)
    n:Show()
    o = Bejeweled.const.largeText["Tutorial_2"]
    t = n:CreateTexture(nil, "ARTWORK")
    t:SetTexture(l .. "artPieces")
    t:SetTexCoord(o[3], o[4], o[5], o[6], o[7], o[8], o[9], o[10])
    t:SetWidth(o[1])
    t:SetHeight(o[2])
    t:ClearAllPoints()
    t:SetPoint("Center", -85, 0)
    t = Bejeweled:CreateCaption(0, 0, "|cFFFF99224 gems will create a |cFF0070DD[Power Gem]|r!", n, 14, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Center", 85, 0)
    t:SetWidth(140)
    t:Show()
    n = CreateFrame("Frame", "", a)
    n:SetPoint("Topleft", 5, -5 - 236) n:SetWidth(376)
    n:SetHeight(118)
    n:SetBackdrop(r)
    n:SetBackdropColor(.2, .2, .2, 1)
    n:SetBackdropBorderColor(1, 1, 1)
    n:Show()
    o = Bejeweled.const.largeText["Tutorial_3"]
    t = n:CreateTexture(nil, "ARTWORK")
    t:SetTexture(l .. "artPieces")
    t:SetTexCoord(o[3], o[4], o[5], o[6])
    t:SetWidth(o[1])
    t:SetHeight(o[2])
    t:ClearAllPoints()
    t:SetPoint("Center", -85, 0)
    t = Bejeweled:CreateCaption(0, 0, "|cFFFF99225 gems will create a |cFFA335EE[Hyper Cube]|r!", n, 14, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Center", 85, 0)
    t:SetWidth(140)
    t:Show()
    a = CreateFrame("Frame", "", i)
    a:SetPoint("Top", 0, -10)
    a:SetWidth(s + 6 - 24)
    a:SetHeight(w + 6 - 86)
    a:Hide()
    i.tab2Content = a
    n = CreateFrame("Frame", "", a)
    n:SetPoint("Topleft", 10, -10) n:SetPoint("Bottomright", -10, -20)
    n:SetBackdrop(r)
    n:SetBackdropColor(.2, .2, .2, 1)
    n:SetBackdropBorderColor(1, 1, 1)
    n:Show()
    o = Bejeweled.const.largeText["Popcap"]
    t = n:CreateTexture(nil, "ARTWORK")
    t:SetTexture(l .. "artPieces")
    t:SetTexCoord(o[3], o[4], o[5], o[6])
    t:SetWidth(o[1] - 20)
    t:SetHeight(o[2] - 20)
    t:ClearAllPoints()
    t:SetPoint("Top", 0, -10)
    t = Bejeweled:CreateCaption(0, 0, "", n, 14, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Topleft", 12, -92)
    t:SetWidth(336)
    t:Show()
    t:SetJustifyH("LEFT")
    t:SetText("Why'd we do it? Many PopCap employees are also hardcore " .. "WoW players, who alt-tab during long flights or queues " .. "to kill time with Bejeweled.\n\n" .. "So when we learned we could actually implement Bejeweled " .. "through an Add-On, we were intrigued. Soon the PopCap 'guild' " .. "was figuring out ways to make the mod even cooler and more " .. "comprehensive. And lots of work later...\n\n" .. "Now, we hope other WoW players will enjoy our 'game within a " .. "game.' Happy Bejeweling!")
    t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 11, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Bottom", 0, 12)
    t:SetText("For Customer Support, email wowaddons@popcap.com")
    t:Show()
    t = n:CreateFontString(nil, "Overlay")
    t:SetFont(STANDARD_TEXT_FONT, 12, "Outline")
    t:SetTextColor(1, 1, 1)
    t:SetPoint("Topright", -12, -12)
    t:SetText(Bejeweled.version)
    t:Show()
    t = Bejeweled:CreateCaption(0, 0, "", n, 16, 1, .4, .8)
    t:SetFont(STANDARD_TEXT_FONT, 16)
    t:SetShadowColor(0, 0, 0)
    t:SetShadowOffset(1, -1)
    t:ClearAllPoints()
    t:SetPoint("Top", n, "Bottom", 0, -2)
    t:SetWidth(386)
    t:Show()
    t:SetJustifyH("CENTER")
    t:SetText("For more great games visit popcap.com|r\n".."Get updates at https://github.com/Nighthawk42/wow_bejeweled")
    a = CreateFrame("Frame", "", i)
    a:SetPoint("Top", 0, -10) a:SetWidth(s + 6 - 24)
    a:SetHeight(w + 6 - 68)
    a:Hide()
    i.tab3Content = a
    n = CreateFrame("Frame", "", a)
    n:SetPoint("Topleft", 10, -10) n:SetPoint("Bottomright", -10, -10)
    n:SetBackdrop(r)
    n:SetBackdropColor(.2, .2, .2, 1)
    n:SetBackdropBorderColor(1, 1, 1)
    n:Show()
    t = Bejeweled:CreateCaption(0, 0, "", n, 16, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Topleft", 12, -12)
    t:SetWidth(336)
    t:Show()
    t:SetText("Bejeweled Addon for WoW") t:SetJustifyH("CENTER")
    t = Bejeweled:CreateCaption(0, 0, "", n, 14, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Topleft", 12, -42)
    t:SetWidth(336)
    t:Show()
    t:SetText("Programmer: |cFFFFFFFFMichael Fromwiller|r\n" .. "Artist: |cFFFFFFFFTysen Henderson|r\n" .. "Producer: |cFFFFFFFFT. Carl Kwoh|r\n" .. "PopCap QA: |cFFFFFFFFShawn Conard, Ryan Newitt,\nJonathan Green|r\n\n" .. "Original Bejeweled:\n|cFFFFFFFFJason Kapalka, Brian Fiete, John Vechey|r\n\n")
    t:SetJustifyH("CENTER")
    t = Bejeweled:CreateCaption(0, 0, "", n, 13, 1, .85, .1)
    t:ClearAllPoints()
    t:SetPoint("Topleft", 17, -175)
    t:SetWidth(326)
    t:Show()
    t:SetText("Special Thanks:\n" .. '|cFFFFFFFFMorphieus "Lothaer" (Spinebreaker-A), Eleya (Eredar-A), Anthony Coleman, Ben Lyon, and Jeff Weinstein.|r\n\n' .. "Beta Testers:\n" .. "|cFFFFFFFFNaiad (Ysera-H), Nie (Ysera-H), BraveOne (Aerie Peak-A), Brutall (Ysera-H), AvaCam (Gurubashi-H), Kepec (Kael'thas-A), Eldurin (Dalaran-A), Fnear (Cenarius-A), Jonsnow (Kael'thas EU-A), Ed|r")
    t:SetJustifyH("LEFT")
end

function Bejeweled:Initialize_OptionsScreen()
    local i = Bejeweled.window
    i:SetAlpha(BejeweledProfile.settings.gameAlpha)
    Bejeweled.const.windowFadeIn.startAlpha = BejeweledProfile.settings.mouseoffAlpha
    Bejeweled.const.windowFadeIn.endAlpha = BejeweledProfile.settings.gameAlpha
    Bejeweled.const.windowFadeOut.startAlpha = BejeweledProfile.settings.gameAlpha
    Bejeweled.const.windowFadeOut.endAlpha = BejeweledProfile.settings.mouseoffAlpha
    local t = CreateFrame("Frame", "BejeweledOptionsScreen", getglobal("BejeweledGameBoard"))
    t:SetPoint("Top", 0, -3) t:SetWidth(s + 6)
    t:SetHeight(w + 6)
    t:EnableMouse(true)
    local a = C()
    a.bgFile = l .. "windowBackground"
    a.tileSize = 128
    a.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" a.edgeSize = 32
    t:SetBackdrop(a)
    t:SetBackdropColor(.7, .7, .7, 1)
    t:SetBackdropBorderColor(1, .8, .45)
    t:SetFrameLevel(i:GetFrameLevel() + 25)
    t:SetScript("OnShow", function(t)
        T(true)
        getglobal("BejeweledGame"):SetAlpha(0)
        Bejeweled.summaryScreen:SetAlpha(0)
        Bejeweled.animator.hintObj:SetAlpha(0)
    end)
    t:SetScript("OnHide", function(t)
        getglobal("BejeweledGame"):SetAlpha(1)
        Bejeweled.summaryScreen:SetAlpha(1)
        Bejeweled.animator.hintObj:SetAlpha(1)
    end)
    t:Hide()
    Bejeweled.optionsScreen = t
    local n = Bejeweled:CreateCaption(0, 0, "Options", t, 20, 1, .85, .1, true)
    n:ClearAllPoints()
    n:SetPoint("Top", 0, -10)
    n:Show()
    local o = CreateFrame("Frame", "", t)
    o:SetPoint("Top", 0, -36) o:SetWidth(s + 6 - 24)
    o:SetHeight(w + 6 - 48)
    o:SetBackdrop(a)
    o:SetBackdropColor(.2, .2, .2, 1)
    o:SetBackdropBorderColor(1, 1, 1)
    o:SetFrameLevel(i:GetFrameLevel() + 26)
    o:Show()
    local a = 5
    n = Bejeweled:CreateCaption(10, a + 20, "|cFFFF9922" .. "Set Keybind for AddOn:", o, 10, 1, .85, .1, nil, true)
    n:ClearAllPoints() n:SetPoint("Topleft", 16, -a - 12)
    n:SetFont(STANDARD_TEXT_FONT, 13)
    n:SetShadowOffset(1, -1)
    local l = CreateFrame("Button", "BejeweledKeybindButton", o, "OptionsButtonTemplate") l:SetPoint("Topleft", 190, -a - 8)
    l:SetText(BejeweledProfile.settings.keybinding or ("None"))
    l:SetWidth(180)
    l:SetHeight(20)
    l:SetScript("OnClick", function(t)
        if (t.savedText) then
            Bejeweled.window:EnableKeyboard(false)
            Bejeweled.window.newKeybindButton = ""
            Bejeweled.window.keybindModifier = ""
            t:UnlockHighlight()
            t:SetText(t.savedText)
            t.savedText = nil
        else
            Bejeweled.window:EnableKeyboard(true)
            Bejeweled.window.newKeybindButton = ""
            Bejeweled.window.keybindModifier = ""
            t:LockHighlight()
            t.savedText = t:GetText()
            t:SetText("Press key or ESC to clear");
        end
    end)
    i.keybindButton = l
    if (BejeweledProfile.settings.keybinding) then
        SetOverrideBindingClick(i, true, BejeweledProfile.settings.keybinding, "BejeweledShowHideButton");
    end
    Bejeweled:CreateSlider(50, -a - 45, 250, "Game Transparency", "gameAlpha", o, .2, 1, .005, true, function(t)
        Bejeweled.const.windowFadeIn.endAlpha = BejeweledProfile.settings.gameAlpha
        Bejeweled.const.windowFadeOut.startAlpha = BejeweledProfile.settings.gameAlpha
        Bejeweled.window:SetAlpha(t:GetValue())
    end)
    Bejeweled:CreateSlider(50, -a - 76, 250, "Mouse-off Transparency", "mouseoffAlpha", o, 0, 1, .005, true, function()
        Bejeweled.const.windowFadeIn.startAlpha = BejeweledProfile.settings.mouseoffAlpha
        Bejeweled.const.windowFadeOut.endAlpha = BejeweledProfile.settings.mouseoffAlpha
    end)
    local t = 100
    Bejeweled:CreateCaption(10, t + 4, "Sounds:", o, 12, 1, .85, .1)
    local l = function(e)
        local t = string.match(e:GetName(), "BejeweledCheckBox(.*)")
        getglobal("BejeweledCheckBoxenableSounds"):SetChecked(nil)
        getglobal("BejeweledCheckBoxquietSounds"):SetChecked(nil)
        getglobal("BejeweledCheckBoxdisableSounds"):SetChecked(nil)
        BejeweledProfile.settings.enableSounds = nil
        BejeweledProfile.settings.quietSounds = nil
        BejeweledProfile.settings.disableSounds = nil
        BejeweledProfile.settings[t] = 1
        e:SetChecked(1)
    end
    n = Bejeweled:CreateCheckbox(70, -t, "Normal", "enableSounds", 1, o, l, true)
    n:SetHitRectInsets(0, -70, 0, 0)
    n = Bejeweled:CreateCheckbox(160, -t, "Quiet", "quietSounds", 1, o, l, true)
    n:SetHitRectInsets(0, -70, 0, 0)
    n = Bejeweled:CreateCheckbox(250, -t, "Off", "disableSounds", 1, o, l, true)
    n:SetHitRectInsets(0, -70, 0, 0)
    t = t + 17
    n = Bejeweled:CreateCheckbox(10, -t, "Hide Minimap Icon", "hideMinimap", 1, o, function(t)
        BejeweledProfile.settings[string.match(t:GetName(), "BejeweledCheckBox(.*)")] = t:GetChecked()
        if not BejeweledProfile.settings.hideMinimap then
            Bejeweled.minimap:Show()
        else
            Bejeweled.minimap:Hide();
        end
    end)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Lock Window", "lockWindow", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Display skill gains in Chat Interface", "publishSkillGains", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(30, -t, "Show full skill-up text", "verboseSkills", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Publish Bejeweling rank-ups to Guild Channel", "publishRankGains", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "New Game on Flight Start", "newGameFlight", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Publish Scores", "publishScores", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "One score per person on High Score lists", "hideDuplicates", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Disable Auto-Hint Arrows", "disableHints", 1, o, function(t)
        BejeweledProfile.settings[string.match(t:GetName(), "BejeweledCheckBox(.*)")] = t:GetChecked()
        if not BejeweledProfile.settings.disableHints then
            Bejeweled.animator:Add(Bejeweled.animator:CreateHint(Q()))
        else
            local e = Bejeweled.animator.hintObj
            e.fxType = S
            e:SetAlpha(0)
            e:Hide()
            e.wasShown = nil
            e.oldAlpha = 0;
        end
    end)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 16
    n = Bejeweled:CreateCheckbox(10, -t, "Show Flight Times on Flight Window Tooltips", "showFlightTooltips", 1, o)
    n:SetHitRectInsets(0, -340, 0, 0)
    t = t + 20
    Bejeweled:CreateCaption(40, t, "Auto-Open:", o, 12, 1, .85, .1)
    Bejeweled:CreateCaption(170, t, "Auto-Close:", o, 12, 1, .85, .1)
    t = t + 14
    Bejeweled:CreateCheckbox(60, -t, "On Flight Start", "openFlightStart", 1, o)
    Bejeweled:CreateCheckbox(190, -t, "On Flight End", "closeFlightEnd", 1, o)
    t = t + 16
    Bejeweled:CreateCheckbox(60, -t, "On Death", "openOnDeath", 1, o)
    Bejeweled:CreateCheckbox(190, -t, "On Ready Check", "closeReadyCheck", 1, o)
    t = t + 16
    Bejeweled:CreateCheckbox(60, -t, "On Log-In", "openLogin", 1, o)
    Bejeweled:CreateCheckbox(190, -t, "On Enter Combat", "closeCombat", 1, o)
    t = t + 16
    i:SetScript("OnKeyUp", function(e, t)
        if (t == "LSHIFT" or t == "RSHIFT" or t == "LCTRL" or t == "RCTRL" or t == "LALT" or t == "RALT") then
            local t = ""
            e.keybindModifier = ""
            if (IsAltKeyDown()) then
                e.keybindModifier = "ALT"
                t = "-";
            end
            if (IsControlKeyDown()) then
                e.keybindModifier = e.keybindModifier .. t .. "CTRL"
                t = "-";
            end
            if (IsShiftKeyDown()) then
                e.keybindModifier = e.keybindModifier .. t .. "SHIFT";
            end
        end
    end)
    i:SetScript("OnKeyDown", function(e, t)
        if (t == "ESCAPE") then
            e:EnableKeyboard(false)
            e.keybindButton:SetText("None")
            e.keybindButton:UnlockHighlight()
            e.keybindButton.savedText = nil
            BejeweledProfile.settings.keybinding = nil
            ClearOverrideBindings(e)
        else
            if (GetBindingFromClick(t) == "SCREENSHOT") then
                RunBinding("SCREENSHOT")
                return;
            end
            if (t == "UNKNOWN") then
                return;
            end
            if (t == "LSHIFT" or t == "RSHIFT" or t == "LCTRL" or t == "RCTRL" or t == "LALT" or t == "RALT") then
                t = G(t, 2)
                if (e.keybindModifier == "") then
                    e.keybindModifier = t
                else
                    if not string.find(e.keybindModifier, t) then
                        e.keybindModifier = e.keybindModifier .. "-" .. t;
                    end
                end
                return
            elseif (e.newKeybindButton ~= "") then
                return;
            end
            local n = ""
            e.keybindModifier = ""
            if (IsAltKeyDown()) then
                e.keybindModifier = "ALT"
                n = "-";
            end
            if (IsControlKeyDown()) then
                e.keybindModifier = e.keybindModifier .. n .. "CTRL"
                n = "-";
            end
            if (IsShiftKeyDown()) then
                e.keybindModifier = e.keybindModifier .. n .. "SHIFT";
            end
            if (e.keybindModifier == "") then
                e.newKeybindButton = t
            else
                e.newKeybindButton = e.keybindModifier .. "-" .. t;
            end
            e:EnableKeyboard(false)
            e.keybindButton:SetText(e.newKeybindButton)
            e.keybindButton:UnlockHighlight()
            e.keybindButton.savedText = nil
            SetOverrideBindingClick(e, true, e.newKeybindButton, "BejeweledShowHideButton")
            BejeweledProfile.settings.keybinding = e.newKeybindButton;
        end
    end);
end

local function S(i, t, l, o)
    local o = Bejeweled.flightOptionWindow
    if (t == "UNIT_FLAGS") and (l == "player") then
        if UnitOnTaxi("player") then
            Bejeweled.window:UnregisterEvent("UNIT_FLAGS")
            Bejeweled.flightOptionWindow:Show()
            if (BejeweledProfile.settings.openFlightStart) then
                Bejeweled.window:Show()
                T(false);
            end
        end
    elseif (t == "FRIENDLIST_UPDATE") then
        Bejeweled.network.friendUpdate = true
    elseif (t == "GUILD_ROSTER_UPDATE") then
        Bejeweled.network.guildUpdate = true
    elseif (t == "PLAYER_CONTROL_GAINED") then
        if (i.switchingZones) then
            i.switchingZones = nil
            return;
        end
        local t = (n.gameMode == k)
        if (o.timer.timeElapsed) then
            o.timer:Hide()
            if (Bejeweled.timedWindow:IsVisible()) then
                Bejeweled.timedWindow:SetHeight(L - 80)
                Bejeweled.timedWindow.flightCheckbox:Hide()
                Bejeweled.timedWindow.flightCheckboxCaption:Hide()
                Bejeweled.timedWindow.flightCheckbox:SetChecked(nil)
                Bejeweled.timedWindow.timerRemainingCaption:Hide()
                Bejeweled.timedWindow.timeRemainingValue:Hide();
            end
            Bejeweled:UpdateFlightTimes()
            Bejeweled.window:UnregisterEvent("PLAYER_MONEY")
            Bejeweled.window:UnregisterEvent("PLAYER_CONTROL_GAINED")
            Bejeweled.window:UnregisterEvent("PLAYER_LEAVING_WORLD")
            if (n.gameMode == k) then
                if (Bejeweled.levelBar.timer.timeElapsed) then
                    if (o.timer.timeElapsed) then
                        if (math.abs(o.timer.timeElapsed - Bejeweled.levelBar.timer.timeElapsed) > 1) then
                            Bejeweled.levelBar.timer.timeElapsed = o.timer.timeElapsed;
                        end
                    end
                    Bejeweled.levelBar.timer:Hide()
                    Me();
                end
            end
            o.timer.learnEvent = nil
            o.timer.elapsed = nil
            o.timer.timeElapsed = nil
            o.learning = nil
            if (BejeweledProfile.settings.closeFlightEnd) and Bejeweled.window:IsShown() then
                if not Bejeweled.popup:IsVisible() then
                    Bejeweled.const.windowGameOverFadeOut.fadeTimer = 0
                    UIFrameFade(Bejeweled.window, Bejeweled.const.windowGameOverFadeOut)
                    Bejeweled.window.mouseOverScreen:Show()
                    Bejeweled.window.hiding = true;
                end
            end
        end
    elseif (t == "PLAYER_MONEY") then
        Bejeweled:UpdateFlightTimes()
    elseif (t == "VARIABLES_LOADED") then
        Bejeweled:VariablesLoaded()
    elseif (t == "PLAYER_LEAVING_WORLD") then
        i.switchingZones = true
    elseif (t == "PLAYER_ENTERING_WORLD") and not Bejeweled.loggedIn then
        Bejeweled.loggedIn = true
        local a = BejeweledProfile.stats.classic
        local l = BejeweledProfile.stats.timed
        local i = a.score
        local o = d(l.score * 100)
        local t = UnitName("player")
        local n = Y(BejeweledProfile.skill.rank) .. t .. "*"
        local t = H(t)
        i = a[v] or ""
        o = l[v] or ""
        local n = n .. i .. "*" .. n .. o
        if IsInGuild() then
            GuildRoster();
        end
        Bejeweled.network:Send("LogSync", "", "GUILD", "")
        Bejeweled.network:Send("HSPub", n, "GUILD", "")
        local o, t
        for o = 1, GetNumFriends() do
            t, _, _, _, online = GetFriendInfo(o) if (online) then
                Bejeweled.network:Send("LogSync", "", "WHISPER", t)
                Bejeweled.network:Send("HSPub", n, "WHISPER", t);
            end
        end
        if not (BejeweledData.legalDisplayed) then
            Bejeweled.window:Show()
            Bejeweled:ShowLegal()
        else
            Bejeweled.window.splash.elapsed = 0;
        end
        Bejeweled.ShowLegal = nil
        if (BejeweledProfile.settings.openLogin) then
            Bejeweled.window:Show();
        end
    elseif (t == "PLAYER_DEAD") then
        if (BejeweledProfile.settings.openOnDeath) then
            Bejeweled.window:Show();
        end
    elseif (t == "READY_CHECK") then
        if (BejeweledProfile.settings.closeReadyCheck) then
            if not Bejeweled.popup:IsVisible() then
                Bejeweled.window:Hide();
            end
        end
    elseif (t == "PLAYER_REGEN_DISABLED") then
        if (Bejeweled.paused ~= true) and (n.gameMode) then
            BejeweledProfile.stats.combatPause = BejeweledProfile.stats.combatPause + 1;
        end
        if (BejeweledProfile.settings.closeCombat) then
            if not Bejeweled.popup:IsVisible() then
                Bejeweled.window:Hide();
            end
        end
    end
end

local function k()
    Bejeweled.skillLimit = true
	
	-- FixMe:  GetMapContinents() no longer exists.  We lose so dynamic information on the map, but that's OK!
    -- if (select(4, GetMapContinents())) then
    --   Bejeweled.skillLimit = nil;
    -- end
	
    hooksecurefunc("TakeTaxiNode", M)
    hooksecurefunc("TaxiNodeOnButtonEnter", y) v = x(1378301, 4)
    local x = A()
    local r = g()
    Bejeweled.animator = x
    Bejeweled.window = r
    P()
    R()
    W()
    F()
    D()
    V()
    O()
    N()
    E()
    r:SetClampedToScreen(true)
    r:RegisterEvent("VARIABLES_LOADED")
    r:RegisterEvent("PLAYER_ENTERING_WORLD")
    r:RegisterEvent("PLAYER_LEAVING_WORLD")
    r:RegisterEvent("PLAYER_DEAD")
    r:RegisterEvent("READY_CHECK")
    r:RegisterEvent("PLAYER_REGEN_DISABLED")
    r:RegisterEvent("FRIENDLIST_UPDATE")
    r:RegisterEvent("GUILD_ROSTER_UPDATE")
    r:SetScript("OnEvent", S)
    SLASH_BEJEWELED1 = "/bejeweled"
    SLASH_BEJEWELED2 = "/bej"
    SlashCmdList["BEJEWELED"] = Ze
    local t, h
    local t = 0
    local t = 0
    local t, t
    local t = CreateFrame("Frame", "BejeweledGameBoardAnchor", r)
    t:SetPoint("Topleft", 20, -60)
    t:SetPoint("Topright", -20, -60)
    t:SetHeight(w + 12)
    gameBoard = CreateFrame("Frame", "BejeweledGameBoard", t)
    gameBoard:SetPoint("Top") gameBoard:SetWidth(s + 14)
    gameBoard:SetHeight(w + 12)
    local t = C()
    t.edgeFile = "Interface\\Glues\\Common\\TextPanel-Border" t.edgeSize = 32
    gameBoard:SetBackdrop(t)
    gameBoard:SetBackdropColor(0, 0, 0, 0)
    gameBoard:SetFrameLevel(r:GetFrameLevel() + 2)
    gameBoard:Show()
    Bejeweled.gameBoard = gameBoard
    B()
    u()
    m()
    local S = CreateFrame("Frame", "BejeweledGame", gameBoard)
    S:SetWidth(s)
    S:SetHeight(w)
    S:SetPoint("Topleft", 8, -4)
    S:EnableMouse(true)
    S:SetFrameLevel(r:GetFrameLevel() + 1)
    local a, a, i
    for t = 0, 3 do
        for e = 0, 3 do
            i = CreateFrame("Frame", "", S)
            i:SetPoint("Topleft", (e * 100), -(t * 100))
            i:SetWidth(s / 4)
            i:SetHeight(w / 4)
            i:Show()
            i.texture = i:CreateTexture(nil, "BACKGROUND")
            i.texture:SetWidth(s / 4)
            i.texture:SetHeight(w / 4)
            i.texture:SetPoint("Center")
            i.texture:Show()
            i.texture:SetTexture(l .. "board")
            i.texture:SetTexCoord(.046875, .828125, .046875, .828125)
            i:SetAlpha(.8)
            i:SetFrameLevel(S:GetFrameLevel());
        end
    end
    Bejeweled.foreground = CreateFrame("Frame", "BejeweledGame", gameBoard)
    Bejeweled.foreground:SetWidth(s + 14)
    Bejeweled.foreground:SetHeight(w + 12)
    Bejeweled.foreground:SetPoint("Topleft", 0, 0)
    local a = CreateFrame("Frame", "", Bejeweled.foreground)
    local d = Bejeweled.const.largeText["Strip"]
    a:ClearAllPoints()
    a:SetPoint("Center") a:SetWidth(1)
    a:SetHeight(1)
    a:Hide()
    a.text = a:CreateTexture(nil, "OVERLAY")
    a.text:SetTexture(l .. "artPieces")
    a.text:ClearAllPoints()
    a.text:SetWidth(1)
    a.text:SetHeight(1)
    a.text:SetPoint("Center")
    a.text:SetTexCoord(0, 0, 0, 0)
    a.text:Show()
    a.background = a:CreateTexture(nil, "ARTWORK")
    a.background:SetPoint("Center")
    a.background:SetPoint("Left", gameBoard, "Left", 8, 0)
    a.background:SetPoint("Right", gameBoard, "Right", -8, 0)
    a.background:SetHeight(84)
    a.background:SetTexture(l .. "artPieces")
    a.background:SetTexCoord(d[3], d[4], d[5], d[6])
    a.background:Hide()
    Bejeweled.gameStatusText = a
    Bejeweled.gameStatusText.SetText = function(n, t)
        local t = Bejeweled.const.largeText[t]
        if (t) then
            n.text:SetWidth(t[1])
            n.text:SetHeight(t[2])
            if (#t > 9) then
                n.text:SetTexCoord(t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10])
                n.background:SetVertexColor(t[11], t[12], t[13])
            else
                n.text:SetTexCoord(t[3], t[4], t[5], t[6])
                n.background:SetVertexColor(t[7], t[8], t[9]);
            end
        end
        n:SetAlpha(1)
        Bejeweled.gameStatusText.background:SetAlpha(1);
    end
    local d = CreateFrame("Frame", "BejeweledStatusBar", r)
    d:SetPoint("Bottomleft", -10, 10)
    d:SetPoint("Bottomright", -32, 10)
    d:SetHeight(32)
    d:SetFrameLevel(r:GetFrameLevel() + 2)
    Bejeweled.statusBar = d
    local a = CreateFrame("Frame", "BejeweledLevelBorder", d)
    a:SetPoint("Bottomleft", 0, 0)
    a:SetHeight(32)
    a:SetWidth(122)
    a:SetWidth(86)
    t = C()
    t.edgeFile = l .. "levelBorder" t.edgeSize = 32
    t.insets.left = 2
    t.insets.right = 2
    a:SetBackdrop(t)
    a:SetBackdropColor(0, 0, 0, 0)
    Bejeweled.levelBorder = a
    Bejeweled.levelText = Bejeweled:CreateCaption(0, 0, "", a, 12, 1, 1, 1, true)
    Bejeweled.levelText:ClearAllPoints()
    Bejeweled.levelText:SetPoint("Topleft", 16, 0)
    Bejeweled.levelText:SetPoint("Bottomright", -46, 1)
    Bejeweled.levelText:SetJustifyH("RIGHT")
    Bejeweled.levelTextCaption = Bejeweled:CreateCaption(0, 0, "", a, 11, 1, 1, 1, true)
    Bejeweled.levelTextCaption:SetWidth(1)
    Bejeweled.levelTextCaption:ClearAllPoints()
    Bejeweled.levelTextCaption:SetJustifyH("LEFT")
    Bejeweled.levelTextCaption:SetPoint("Topleft", Bejeweled.levelText, "Topright", -5, 0)
    Bejeweled.levelTextCaption:SetPoint("Bottomright", -16, 1)
    local s = CreateFrame("Frame", "BejeweledDataBorder", d)
    s:SetPoint("Bottomleft", a, "Bottomright", -40, 0)
    s:SetHeight(32)
    s:SetWidth(72)
    s:SetWidth(128)
    s:SetBackdrop(t)
    s:SetBackdropColor(0, 0, 0, 0)
    Bejeweled.dataBorder = s
    Bejeweled.dataText = Bejeweled:CreateCaption(0, 0, "", s, 10, 1, 1, 1, true)
    Bejeweled.dataText:ClearAllPoints()
    Bejeweled.dataText:SetPoint("Center", 0, 1)
    local a = CreateFrame("Frame", "BejeweledLevelBar", d)
    a:SetPoint("Left", s, "Right", -18, 0)
    a:SetPoint("Bottomright", d, "Bottomright", 0, 0)
    a:SetHeight(32)
    t = C()
    t.edgeFile = "Interface\\Buttons\\UI-SliderBar-Border" t.edgeSize = 8
    t.bgFile = l .. "windowBackground"
    t.tileSize = 64
    t.insets.left = 2
    t.insets.right = 2
    a:SetBackdrop(t)
    a:SetBackdropColor(.1, .1, .1, 0)
    a:SetFrameLevel(d:GetFrameLevel() + 2)
    Bejeweled.levelBar = a
    local f = CreateFrame("Frame", "", d)
    f:SetPoint("Left", s, "Right", -18, 0)
    f:SetPoint("Bottomright", d, "Bottomright", 0, 0)
    f:SetHeight(32)
    t = C()
    t.edgeFile = "Interface\\Buttons\\UI-SliderBar-Border" t.edgeSize = 8
    t.bgFile = l .. "windowBackground"
    t.tileSize = 64
    t.insets.left = 2
    t.insets.right = 2
    f:SetBackdrop(t)
    f:SetBackdropColor(.1, .1, .1)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:SetFrameLevel(d:GetFrameLevel() + 1)
    local s = f:CreateTexture(nil, "OVERLAY")
    s:SetTexture(l .. "barArt")
    s:SetVertexColor(0, .2, 1) s:SetPoint("Topleft", 2, -5)
    s:SetHeight(32)
    s:SetWidth(.01)
    a.bar = s
    a.text = Bejeweled:CreateCaption(0, 0, "", a, 12, 1, 1, 1, true)
    a.text:ClearAllPoints()
    a.text:SetPoint("Center", 0, 1)
    a.SetScore = ht
    a.SetMinMaxScore = Bt
    a.AddScore = xt
    a.SetMode = rt
    a.UpdateBar = Tt
    a.SetTimer = kt
    a.StartTimer = Ft
    a.StopTimer = Pt
    a.timer = CreateFrame("Frame", "", r)
    a.timer:SetWidth(1)
    a.timer:SetHeight(1)
    a.timer:SetPoint("Top")
    a.timer:Hide()
    a.timer:SetScript("OnUpdate", fe)
    local a = CreateFrame("Frame", "BejeweledLevelBarButton", r)
    a:SetPoint("Topleft", d, "Topleft", 50, 0)
    a:SetPoint("Bottomright", d, "Bottomright")
    a:EnableMouse(true)
    a:Hide()
    a:SetFrameLevel(r:GetFrameLevel() + 2)
    a:SetID(2)
    a:SetScript("OnShow", function(t)
        Bejeweled.statusBar:SetAlpha(0)
    end)
    a:SetScript("OnHide", function(t)
        Bejeweled.statusBar:SetAlpha(1)
    end)
    a:SetScript("OnEnter", function(e)
        e.bar:SetVertexColor(1, 0, 0)
    end)
    a:SetScript("OnLeave", function(e)
        e.bar:SetVertexColor(.6, 0, 0)
    end)
    a:SetScript("OnMouseDown", function(t)
        Bejeweled.menuWindow.keepScreen = nil
        Bejeweled.menuWindow:Show()
        Bejeweled.menuWindow:Hide()
        if (t:GetID() == 1) then
            Bejeweled.featsOfSkillScreen:Hide()
            Bejeweled.optionsScreen:Hide()
            Bejeweled.aboutScreen:Hide()
            t:SetID(0)
            t:Hide()
        elseif (t:GetID() == 2) then
            local n = n.lastGameMode
            if (n == ae) then
                Bejeweled.timedWindow:Show()
            elseif (n == c) then
                j(n, 0)
                t:SetID(0)
                t:Hide()
            else
                Bejeweled.gameModeWindow:Show();
            end
        end
    end)
    t = C()
    t.edgeFile = "Interface\\Buttons\\UI-SliderBar-Border" t.edgeSize = 8
    t.bgFile = l .. "windowBackground"
    t.tileSize = 64
    t.insets.left = 2
    t.insets.right = 2
    a:SetBackdrop(t)
    a:SetBackdropColor(.1, .1, .1, 0)
    a:SetFrameLevel(d:GetFrameLevel() + 4)
    Bejeweled.levelBarButton = a
    local f = CreateFrame("Frame", "", a)
    f:SetPoint("Topleft")
    f:SetPoint("Bottomright")
    f:SetHeight(32)
    t = C()
    t.edgeFile = "Interface\\Buttons\\UI-SliderBar-Border" t.edgeSize = 8
    t.bgFile = l .. "windowBackground"
    t.tileSize = 64
    t.insets.left = 2
    t.insets.right = 2
    f:SetBackdrop(t)
    f:SetBackdropColor(.1, .1, .1)
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f:SetFrameLevel(d:GetFrameLevel() + 3)
    s = f:CreateTexture(nil, "OVERLAY")
    s:SetTexture(l .. "barArt")
    s:SetVertexColor(.6, 0, 0) s:SetPoint("Topleft", 2, -5)
    s:SetPoint("Bottomright", -2, -5)
    s:SetHeight(32)
    a.bar = s
    a.text = Bejeweled:CreateCaption(0, 0, "New Game", a, 12, 1, .85, 0)
    a.text:ClearAllPoints()
    a.text:SetPoint("Center", 0, 1)
    local d = CreateFrame("Frame", "", a)
    d:SetPoint("Topright", a, "Topleft", 20, 0)
    d:SetHeight(32)
    d:SetWidth(70)
    d.art = d:CreateTexture(nil, "ARTWORK")
    d.art:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
    d.art:SetPoint("Center", -1, 0)
    d.art:SetWidth(28)
    d.art:SetHeight(28)
    d.art:SetTexCoord(0, .49, 0, .49)
    t = C()
    t.edgeFile = l .. "levelBorder" t.edgeSize = 32
    t.insets.left = 2
    t.insets.right = 2
    d:SetBackdrop(t)
    d:SetBackdropColor(0, 0, 0, 0)
    i = CreateFrame("Frame", "", gameBoard)
    i:SetPoint("Center")
    i:SetWidth(64)
    i:SetHeight(64)
    i.text = Bejeweled:CreateCaption(0, 0, "Paused", i, 40, 1, .85, 0, true)
    i.text:ClearAllPoints()
    i.text:SetPoint("Center", 0, 1)
    i:SetScale(3)
    i:Hide()
    Bejeweled.pausedText = i
    i = CreateFrame("Frame", "BejeweledSplash", gameBoard) i:SetPoint("Topleft")
    i:SetPoint("Bottomright")
    i.art = i:CreateTexture(nil, "ARTWORK")
    i.art:SetPoint("Topleft", gameBoard, "Topleft", 12, -7)
    i.art:SetPoint("Bottomright", gameBoard, "Bottomright", -7, 10)
    i.art:SetTexture(l .. "bejeweled_splash")
    i.text = Bejeweled:CreateCaption(0, 0, "(c) 2000, 2008 PopCap Games Inc. All right reserved", i, 12, 1, 1, 1)
    i.text:ClearAllPoints()
    i.text:SetPoint("Bottomleft", i, "Bottomleft", 14, 14)
    i:SetScript("OnHide", function(t)
        if (K > 1e3) and not BejeweledProfile.skill.gainAchieve7 then
            Bejeweled.skillBar:CheckSkill(Bejeweled.const.SKILLTYPE_ACHIEVEMENT, Bejeweled.const.SKILL_ACHIEVE4B);
        end
    end)
    i:SetScript("OnUpdate", function(t, o)
        if (t.elapsed) then
            if (o > .1) then
                o = .1;
            end
            t.elapsed = t.elapsed + o
            if (t.elapsed >= Bejeweled.splashDisplayTime) then
                t.elapsed = nil
                local e = {
                    mode = "OUT",
                    timeToFade = 1,
                    startAlpha = 1,
                    endAlpha = 0,
                    finishedFunc = function()
                        Bejeweled.window.splash:Hide() local o = Bejeweled.paused
                        Bejeweled.window.menuButton:Enable()
                        if (t.firstGame) then
                            j(c, 120)
                        else
                            if not n.gameMode then
                                if (BejeweledProfile.settings.classicInProgress and BejeweledProfile.settings.savedState) then
                                    j(c, 120, true)
                                    T(false)
                                    if o then
                                        T(true);
                                    end
                                else
                                    BejeweledProfile.settings.classicInProgress = nil
                                    Bejeweled.menuWindow:Show();
                                end
                            end
                        end
                    end,
                }
                UIFrameFade(t, e);
            end
        end
    end)
    i:SetFrameLevel(r:GetFrameLevel() + 5)
    r.splash = i
    i:Show()
    Bejeweled.window.menuButton:Disable()
    Be = (S:GetFrameLevel() + 2)
    FRAME_LEVEL_JEWEL_SWAP = (S:GetFrameLevel() + 3)
    Ie = (S:GetFrameLevel() + 4)
    Ge = (S:GetFrameLevel() + 5)
    Ae = (S:GetFrameLevel() + 6) for t = 0, 7 do
        for e = 0, 7 do
            h = tt(e * b, t * p, S, 1) h:EnableMouse(true)
            h:RegisterForDrag("LeftButton")
            h:SetScript("OnEnter", Ye)
            h:SetScript("OnLeave", ce)
            h:SetScript("OnMouseDown", Z)
            h:SetScript("OnDragStart", ee)
            h:SetFrameLevel(Be)
            o[t + 1][e + 1] = h
            h.gridX = e + 1
            h.gridY = t + 1;
        end
    end
    x:CreateHint()
    tt = nil
    A = nil
    g = nil
    P = nil
    B = nil
    u = nil
    m = nil
    Initialize_OptionsScreen = nil
    F = nil
    k = nil;
end

k()
local e;
