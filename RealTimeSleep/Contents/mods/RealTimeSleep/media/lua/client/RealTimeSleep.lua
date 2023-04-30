local REAL_TIME_SLEEP_FATIGUE_MULTIPLIER = 0.01
local REAL_TIME_SLEEP_ENDURANCE_MULTIPLIER = 0.01

local function RealTimeSleep_EveryTenMinutes()
    if getPlayer():isAsleep() then
        local game_time = getGameTime()
        local real_time_day_per_day = game_time:getMinutesPerDay() / (1440.0 * game_time:getMultiplier())
        local player_stats = getPlayer():getStats()
        player_stats:setFatigue(math.max(0.0, player_stats:getFatigue() -
            (real_time_day_per_day * REAL_TIME_SLEEP_FATIGUE_MULTIPLIER)))
        player_stats:setEndurance(math.min(1.0, player_stats:getEndurance() +
            (real_time_day_per_day * REAL_TIME_SLEEP_ENDURANCE_MULTIPLIER)))
    end
end

local function RealTimeSleep_OnGameStart()
    local sandbox_options = getSandboxOptions()
    if sandbox_options:getOptionByName("RealTimeSleep.UseModdedSleep"):getValue() then
        REAL_TIME_SLEEP_FATIGUE_MULTIPLIER = sandbox_options:getOptionByName("RealTimeSleep.FatigueMultiplier")
            :getValue()
        REAL_TIME_SLEEP_ENDURANCE_MULTIPLIER = sandbox_options:getOptionByName("RealTimeSleep.EnduranceMultiplier")
            :getValue()
        Events.EveryTenMinutes.Add(RealTimeSleep_EveryTenMinutes)
    end
end

Events.OnGameStart.Add(RealTimeSleep_OnGameStart)
