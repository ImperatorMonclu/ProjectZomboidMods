local ADJUST_DAY_AND_NIGHT_TIME_DAWN_OFFSET = 0.0
local ADJUST_DAY_AND_NIGHT_TIME_DUSK_OFFSET = 0.0
local ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR = 0
local ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR = 0
local ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT = false
local ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY = false
local ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_DAY = 0.01
local ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_NIGHT = 0.01

local function AdjustDayAndNightTime_EveryHours()
    local game_hour = getGameTime():getHour()
    if (ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY and game_hour >= ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR and
        game_hour < ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR) or (not ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY and
        (game_hour >= ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR or game_hour < ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR)) then
        if not ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT then
            getGameTime():setMinutesPerDay(ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_NIGHT)
            ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT = true
        end
    else
        if ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT then
            getGameTime():setMinutesPerDay(ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_DAY)
            ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT = false
        end
    end
end

local function AdjustDayAndNightTime_EveryDays()
    local season = getClimateManager():getSeason()
    ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR =
        math.floor(season:getDawn() + ADJUST_DAY_AND_NIGHT_TIME_DAWN_OFFSET + 0.5) % 24
    ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR = math.floor(season:getDusk() + ADJUST_DAY_AND_NIGHT_TIME_DUSK_OFFSET +
                                                                0.5) % 24
    ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY = ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR >
                                                       ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR
end

-- local function AdjustDayAndNightTime_OnDawn()
--     print("AdjustDayAndNightTime_OnDawn UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
-- end

-- local function AdjustDayAndNightTime_OnDusk()
--     print("AdjustDayAndNightTime_OnDusk UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
-- end

local function AdjustDayAndNightTime_OnGameTimeLoaded()
    local sandbox_options = getSandboxOptions()
    if sandbox_options:getOptionByName("AdjustDayAndNightTime.UseModdedTime"):getValue() then
        ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_DAY = sandbox_options:getOptionByName(
            "AdjustDayAndNightTime.HourInDayTime"):getValue() * 24
        ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_NIGHT = sandbox_options:getOptionByName(
            "AdjustDayAndNightTime.HourInNightTime"):getValue() * 24
        ADJUST_DAY_AND_NIGHT_TIME_DAWN_OFFSET = sandbox_options:getOptionByName("AdjustDayAndNightTime.DawnOffsetHours")
            :getValue()
        ADJUST_DAY_AND_NIGHT_TIME_DUSK_OFFSET = sandbox_options:getOptionByName("AdjustDayAndNightTime.DuskOffsetHours")
            :getValue()
        ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY = ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR >
                                                           ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR
        local season = getClimateManager():getSeason()
        ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR = math.floor(
            season:getDawn() + ADJUST_DAY_AND_NIGHT_TIME_DAWN_OFFSET + 0.5) % 24
        ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR = math.floor(
            season:getDusk() + ADJUST_DAY_AND_NIGHT_TIME_DUSK_OFFSET + 0.5) % 24
        local game_time = getGameTime()
        local game_hour = game_time:getHour()
        ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT = (ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY and game_hour >=
                                                 ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR and game_hour <
                                                 ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR) or
                                                 (not ADJUST_DAY_AND_NIGHT_TIME_NIGHT_HOUR_NEW_DAY and
                                                     (game_hour >= ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR or
                                                         game_hour < ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR))
        -- if game_hour >= ADJUST_DAY_AND_NIGHT_TIME_NIGHT_START_HOUR or game_hour < ADJUST_DAY_AND_NIGHT_TIME_DAY_START_HOUR then
        if ADJUST_DAY_AND_NIGHT_TIME_IS_NIGHT then
            game_time:setMinutesPerDay(ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_NIGHT)
        else
            game_time:setMinutesPerDay(ADJUST_DAY_AND_NIGHT_TIME_DAY_TIME_IN_DAY)
        end
        Events.EveryHours.Add(AdjustDayAndNightTime_EveryHours)
        Events.EveryDays.Add(AdjustDayAndNightTime_EveryDays)
        -- Events.OnDawn.Add(AdjustDayAndNightTime_OnDawn)
        -- Events.OnDusk.Add(AdjustDayAndNightTime_OnDusk)
    end
end

Events.OnGameTimeLoaded.Add(AdjustDayAndNightTime_OnGameTimeLoaded)
