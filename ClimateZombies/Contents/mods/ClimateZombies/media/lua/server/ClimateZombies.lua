-- local CLIMATE_ZOMBIES_DAWN_OFFSET = 0.0
-- local CLIMATE_ZOMBIES_DUSK_OFFSET = 0.0
-- local CLIMATE_ZOMBIES_DAY_START_TIME = 0.0
-- local CLIMATE_ZOMBIES_NIGHT_START_TIME = 0.0
-- local CLIMATE_ZOMBIES_IS_NIGHT = false
-- local CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY = false
-- local CLIMATE_ZOMBIES_COMPUTE_MOON = false
local CLIMATE_ZOMBIES_ZOMBIES_MODE = -1
local CLIMATE_ZOMBIES_MAX_ATTEMPS_IDS = 10
local CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES = {}
local CLIMATE_ZOMBIES_CURRENT_CLOUD_INTENSITY_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_NIGHT_STRENGTH_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_DAY_LIGHT_STRENGTH_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_TEMPERATURE_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_FOG_INTENSITY_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_WIND_INTENSITY_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_SNOW_STRENGTH_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_RAIN_INTENSITY_MODE = nil
local CLIMATE_ZOMBIES_CURRENT_SNOW_INTENSITY_MODE = nil
local CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE = false
-- local CLIMATE_ZOMBIES_CURRENT_PRECIPITATION_INTENSITY_MODE = nil
-- print("getClimateManager():getCloudIntensity()")
-- print(getClimateManager():getCloudIntensity())
-- print("getClimateManager():getNightStrength()")
-- print(getClimateManager():getNightStrength())
-- print("getClimateManager():getDayLightStrength()")
-- print(getClimateManager():getDayLightStrength())
-- print("getClimateManager():getTemperature()")
-- print(getClimateManager():getTemperature())
-- print("getClimateManager():getFogIntensity()")
-- print(getClimateManager():getFogIntensity())
-- print("getClimateManager():getRainIntensity()")
-- print(getClimateManager():getRainIntensity())
-- print("getClimateManager():getSnowIntensity()")
-- print(getClimateManager():getSnowIntensity())
-- print("getClimateManager():isRaining()")
-- print(getClimateManager():isRaining())
-- print("getClimateManager():isSnowing()")
-- print(getClimateManager():isSnowing())
-- print("getClimateManager():getPrecipitationIntensity()")
-- print(getClimateManager():getPrecipitationIntensity())
-- print("getClimateManager():getWindIntensity()")
-- print(getClimateManager():getWindIntensity())
-- print("getClimateManager():getIsThunderStorming()")
-- print(getClimateManager():getIsThunderStorming())
-- print("getClimateManager():getSnowStrength()")
-- print(getClimateManager():getSnowStrength())
-- local climate_moon = getClimateMoon()
-- if climate_moon then
--     print("climate_moon:getCurrentMoonPhase()")
--     print(climate_moon:getCurrentMoonPhase())
-- climate_zombies_easter_egg_duration

ClimateZombies_ZombiesModeStatus = {}
ClimateZombies_ZombiesModeStatus.__index = ClimateZombies_ZombiesModeStatus

function ClimateZombies_ZombiesModeStatus:new(zombies_modes, ranges)
    local self = setmetatable({}, ClimateZombies_ZombiesModeStatus)
    self.zombies_modes = zombies_modes
    self.ranges = ranges
    self.current_idx = 1
    return self
end

function ClimateZombies_ZombiesModeStatus:compareValue(value)
    local current_range = self.ranges[self.current_idx]
    if current_range.upper_value ~= nil and current_range.upper_value < value then
        self.current_idx = self.current_idx + 1
        local current_zombies_mode = {}
        for key, value in pairs(self.zombies_modes[self.current_idx]) do
            current_zombies_mode[key] = value
        end
        return current_zombies_mode
    elseif current_range.lower_value ~= nil and current_range.lower_value > value then
        local current_zombies_mode = self.zombies_modes[self.current_idx]
        self.current_idx = self.current_idx - 1
        local zombies_mode_result = {}
        for key, value in pairs(current_zombies_mode) do
            zombies_mode_result[key] = -value
        end
        return zombies_mode_result
    end
end

local function ClimateZombies_updateZombiesMode(zombies_mode)
    local attemp_id = 0
    local find_it = false
    local zombies_mode_value = 0
    local game_time_mod_data = getGameTime():getModData()
    while CLIMATE_ZOMBIES_MAX_ATTEMPS_IDS > attemp_id and not find_it do
        find_it = true
        zombies_mode_value = math.floor(ZombRand(100000000))
        for i, value in ipairs(game_time_mod_data.climate_zombies_zombies_mode_ids) do
            if value == zombies_mode_value and CLIMATE_ZOMBIES_MAX_ATTEMPS_IDS < attemp_id then
                attemp_id = 1 + attemp_id
                find_it = false
                break
            end
        end
    end
    table.insert(game_time_mod_data.climate_zombies_zombies_mode_ids, zombies_mode_value)
    local sandbox_options = getSandboxOptions()
    for key, value in pairs(zombies_mode) do
        CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES[key] = value +
                                                                  CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES[key]
        sandbox_options:set(key, math.min(3, math.max(1, CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES[key])))
    end
    CLIMATE_ZOMBIES_ZOMBIES_MODE = zombies_mode_value
end

local function ClimateZombies_EveryTenMinutes()
    local accumulated_zombies_modes = {}
    if CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE then
        local game_time_mod_data = getGameTime():getModData()
        if game_time_mod_data.climate_zombies_easter_egg_duration then
            if game_time_mod_data.climate_zombies_easter_egg_duration <= 0 then
                CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE = false
                game_time_mod_data.climate_zombies_easter_egg_duration = 0
                table.insert(accumulated_zombies_modes, {
                    ["ZombieLore.Speed"] = 1,
                    ["ZombieLore.Strength"] = 1,
                    ["ZombieLore.Toughness"] = 1,
                    ["ZombieLore.Cognition"] = 1,
                    ["ZombieLore.Memory"] = 1,
                    ["ZombieLore.Sight"] = 1,
                    ["ZombieLore.Hearing"] = 1
                })
            end
            game_time_mod_data.climate_zombies_easter_egg_duration =
                game_time_mod_data.climate_zombies_easter_egg_duration - 1
        end
    end
    -- local game_time_of_day = getGameTime():getTimeOfDay()
    -- if (CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY and game_time_of_day >= CLIMATE_ZOMBIES_NIGHT_START_TIME and game_time_of_day <
    --     CLIMATE_ZOMBIES_DAY_START_TIME) or (not CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY and
    --     (game_time_of_day >= CLIMATE_ZOMBIES_NIGHT_START_TIME or game_time_of_day < CLIMATE_ZOMBIES_DAY_START_TIME)) then
    --     if not CLIMATE_ZOMBIES_IS_NIGHT then
    --         CLIMATE_ZOMBIES_IS_NIGHT = true
    --         -- PUT DAY CONDITION LESS NIGHT CONDITION
    --     end
    --     if not CLIMATE_ZOMBIES_COMPUTE_MOON then
    --         local climate_moon = getClimateMoon()
    --         if climate_moon then
    --             CLIMATE_ZOMBIES_COMPUTE_MOON = true
    --             -- PUT CONDITION OF MOON HERE
    --         end
    --     end
    -- else
    --     if CLIMATE_ZOMBIES_IS_NIGHT then
    --         CLIMATE_ZOMBIES_IS_NIGHT = false
    --         -- PUT NIGHT CONDITION LESS DAY CONDITION
    --     end
    --     if CLIMATE_ZOMBIES_COMPUTE_MOON then
    --         CLIMATE_ZOMBIES_COMPUTE_MOON = false
    --         -- PUT NEGATIVE CONDITION OF MOON HERE
    --     end
    -- end
    local climate_manager = getClimateManager()
    if climate_manager then
        if CLIMATE_ZOMBIES_CURRENT_CLOUD_INTENSITY_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_CLOUD_INTENSITY_MODE:compareValue(
                climate_manager:getCloudIntensity())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_NIGHT_STRENGTH_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_NIGHT_STRENGTH_MODE:compareValue(
                climate_manager:getNightStrength())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_DAY_LIGHT_STRENGTH_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_DAY_LIGHT_STRENGTH_MODE:compareValue(
                climate_manager:getDayLightStrength())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_TEMPERATURE_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_TEMPERATURE_MODE:compareValue(
                climate_manager:getTemperature())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_FOG_INTENSITY_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_FOG_INTENSITY_MODE:compareValue(
                climate_manager:getFogIntensity())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_WIND_INTENSITY_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_WIND_INTENSITY_MODE:compareValue(
                climate_manager:getWindIntensity())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_SNOW_STRENGTH_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_SNOW_STRENGTH_MODE:compareValue(
                climate_manager:getSnowStrength())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_RAIN_INTENSITY_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_RAIN_INTENSITY_MODE:compareValue(
                climate_manager:getRainIntensity())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        if CLIMATE_ZOMBIES_CURRENT_SNOW_INTENSITY_MODE ~= nil then
            local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_SNOW_INTENSITY_MODE:compareValue(
                climate_manager:getSnowIntensity())
            if climate_mode_result ~= nil then
                table.insert(accumulated_zombies_modes, climate_mode_result)
            end
        end
        -- if CLIMATE_ZOMBIES_CURRENT_PRECIPITATION_INTENSITY_MODE ~= nil then
        --     local climate_mode_result = CLIMATE_ZOMBIES_CURRENT_PRECIPITATION_INTENSITY_MODE:compareValue(
        --         climate_manager:getPrecipitationIntensity())
        --     if climate_mode_result ~= nil then
        --         table.insert(accumulated_zombies_modes, climate_mode_result)
        --     end
        -- end
    end
    if #accumulated_zombies_modes ~= 0 then
        local zombies_mode_result = {}
        for i, zombies_mode in ipairs(accumulated_zombies_modes) do
            for key, value_mode in pairs(zombies_mode) do
                if zombies_mode_result[key] ~= nil then
                    zombies_mode_result[key] = zombies_mode_result[key] + value_mode
                else
                    zombies_mode_result[key] = value_mode
                end
            end
        end
        ClimateZombies_updateZombiesMode(zombies_mode_result)
    end
    local string_test = ""
    for key, value in pairs(CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES) do
        string_test = string_test .. key .. ":" .. value .. ", "
    end
    print(string.sub(string_test, 1, -3))
end

-- local function ClimateZombies_EveryDays()
--     local season = getClimateManager():getSeason()
--     CLIMATE_ZOMBIES_DAY_START_TIME = (season:getDawn() + CLIMATE_ZOMBIES_DAWN_OFFSET) % 24
--     CLIMATE_ZOMBIES_NIGHT_START_TIME = (season:getDusk() + CLIMATE_ZOMBIES_DUSK_OFFSET) % 24
--     CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY = CLIMATE_ZOMBIES_DAY_START_TIME > CLIMATE_ZOMBIES_NIGHT_START_TIME
-- end

-- local function ClimateZombies_OnDawn()
--     print("ClimateZombies_OnDawn UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
-- end

-- local function ClimateZombies_OnDusk()
--     print("ClimateZombies_OnDusk UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU")
-- end

local function ClimateZombies_OnZombieUpdate(zombie)
    if CLIMATE_ZOMBIES_ZOMBIES_MODE ~= zombie:getModData().climate_zombies_mode then
        zombie:makeInactive(true)
        zombie:makeInactive(false)
        zombie:getModData().climate_zombies_mode = CLIMATE_ZOMBIES_ZOMBIES_MODE
    end
end

local function ClimateZombies_OnThunderEvent(x, y, strike, light, rumble)
    if strike and light and rumble then
        if not CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE then
            CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE = true
            ClimateZombies_updateZombiesMode({
                ["ZombieLore.Speed"] = -1,
                ["ZombieLore.Strength"] = -1,
                ["ZombieLore.Toughness"] = -1,
                ["ZombieLore.Cognition"] = -1,
                ["ZombieLore.Memory"] = -1,
                ["ZombieLore.Sight"] = -1,
                ["ZombieLore.Hearing"] = -1
            })
        end
        local game_time_mod_data = getGameTime():getModData()
        if game_time_mod_data.climate_zombies_easter_egg_duration then
            game_time_mod_data.climate_zombies_easter_egg_duration =
                game_time_mod_data.climate_zombies_easter_egg_duration + 2
        end
    end
end

local function ClimateZombies_generateZombiesModeByOptions(climate_feature, num, sandbox_options)
    local zombies_mode = {}
    local speed = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "SpeedValue" .. num)
        :getValue()
    if speed ~= 3 then
        zombies_mode["ZombieLore.Speed"] = 3 - speed
    end
    local strength = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "StrengthValue" .. num)
        :getValue()
    if strength ~= 3 then
        zombies_mode["ZombieLore.Strength"] = 3 - strength
    end
    local toughness = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "ToughnessValue" .. num)
        :getValue()
    if toughness ~= 3 then
        zombies_mode["ZombieLore.Toughness"] = 3 - toughness
    end
    local cognition = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "CognitionValue" .. num)
        :getValue()
    if cognition ~= 3 then
        zombies_mode["ZombieLore.Cognition"] = 3 - cognition
    end
    local memory = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "MemoryValue" .. num)
        :getValue()
    if memory ~= 3 then
        zombies_mode["ZombieLore.Memory"] = 3 - memory
    end
    local sight = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "SightValue" .. num)
        :getValue()
    if sight ~= 3 then
        zombies_mode["ZombieLore.Sight"] = 3 - sight
    end
    local hearing = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "HearingValue" .. num)
        :getValue()
    if hearing ~= 3 then
        zombies_mode["ZombieLore.Hearing"] = 3 - hearing
    end
    return zombies_mode
end

local function ClimateZombies_generateZombiesModeStatus(climate_feature, sandbox_options)
    local zombie_modes = {ClimateZombies_generateZombiesModeByOptions(climate_feature, "1", sandbox_options),
                          ClimateZombies_generateZombiesModeByOptions(climate_feature, "2", sandbox_options)}
    local range_value1 = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "Limit1"):getValue()
    local ranges = {{
        upper_value = range_value1,
        lower_value = nil
    }, {
        upper_value = nil,
        lower_value = range_value1
    }}
    -- if range_enable1 then
    table.insert(zombie_modes, ClimateZombies_generateZombiesModeByOptions(climate_feature, "3", sandbox_options))
    local range_value2 = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "Limit2"):getValue()
    ranges[2].upper_value = range_value2
    table.insert(ranges, {
        upper_value = nil,
        lower_value = range_value2
    })
    -- if range_enable2 then
    table.insert(zombie_modes, ClimateZombies_generateZombiesModeByOptions(climate_feature, "4", sandbox_options))
    local range_value3 = sandbox_options:getOptionByName("ClimateZombies." .. climate_feature .. "Limit3"):getValue()
    ranges[3].upper_value = range_value3
    table.insert(ranges, {
        upper_value = nil,
        lower_value = range_value3
    })
    -- end
    -- end
    return ClimateZombies_ZombiesModeStatus:new(zombie_modes, ranges)
end

local function ClimateZombies_OnGameTimeLoaded()
    local sandbox_options = getSandboxOptions()
    if sandbox_options:getOptionByName("ClimateZombies.UseModdedZombies"):getValue() then
        -- CLIMATE_ZOMBIES_DAWN_OFFSET = sandbox_options:getOptionByName("ClimateZombies.DawnOffsetHours"):getValue()
        -- CLIMATE_ZOMBIES_DUSK_OFFSET = sandbox_options:getOptionByName("ClimateZombies.DuskOffsetHours"):getValue()

        local zombie_speed_default = sandbox_options:getOptionByName("ClimateZombies.DefaultSpeed"):getValue()
        local zombie_strength_default = sandbox_options:getOptionByName("ClimateZombies.DefaultStrength"):getValue()
        local zombie_toughness_default = sandbox_options:getOptionByName("ClimateZombies.DefaultToughness"):getValue()
        local zombie_cognition_default = sandbox_options:getOptionByName("ClimateZombies.DefaultCognition"):getValue()
        local zombie_memory_default = sandbox_options:getOptionByName("ClimateZombies.DefaultMemory"):getValue()
        local zombie_sight_default = sandbox_options:getOptionByName("ClimateZombies.DefaultSight"):getValue()
        local zombie_hearing_default = sandbox_options:getOptionByName("ClimateZombies.DefaultHearing"):getValue()

        sandbox_options:set("ZombieLore.Speed", zombie_speed_default)
        sandbox_options:set("ZombieLore.Strength", zombie_strength_default)
        sandbox_options:set("ZombieLore.Toughness", zombie_toughness_default)
        sandbox_options:set("ZombieLore.Cognition", zombie_cognition_default)
        sandbox_options:set("ZombieLore.Memory", zombie_memory_default)
        sandbox_options:set("ZombieLore.Sight", zombie_sight_default)
        sandbox_options:set("ZombieLore.Hearing", zombie_hearing_default)

        sandbox_options:set("ZombieLore.ActiveOnly", 1)

        CLIMATE_ZOMBIES_ACCUMULATED_ZOMBIES_PROPERTIES = {
            ["ZombieLore.Speed"] = zombie_speed_default,
            ["ZombieLore.Strength"] = zombie_strength_default,
            ["ZombieLore.Toughness"] = zombie_toughness_default,
            ["ZombieLore.Cognition"] = zombie_cognition_default,
            ["ZombieLore.Memory"] = zombie_memory_default,
            ["ZombieLore.Sight"] = zombie_sight_default,
            ["ZombieLore.Hearing"] = zombie_hearing_default
        }

        if sandbox_options:getOptionByName("ClimateZombies.CloudIntensityEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_CLOUD_INTENSITY_MODE = ClimateZombies_generateZombiesModeStatus("CloudIntensity",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.NightStrengthEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_NIGHT_STRENGTH_MODE = ClimateZombies_generateZombiesModeStatus("NightStrength",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.DayLightStrengthEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_DAY_LIGHT_STRENGTH_MODE =
                ClimateZombies_generateZombiesModeStatus("DayLightStrength", sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.TemperatureEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_TEMPERATURE_MODE = ClimateZombies_generateZombiesModeStatus("Temperature",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.FogIntensityEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_FOG_INTENSITY_MODE = ClimateZombies_generateZombiesModeStatus("FogIntensity",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.WindIntensityEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_WIND_INTENSITY_MODE = ClimateZombies_generateZombiesModeStatus("WindIntensity",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.SnowStrengthEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_SNOW_STRENGTH_MODE = ClimateZombies_generateZombiesModeStatus("SnowStrength",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.RainIntensityEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_RAIN_INTENSITY_MODE = ClimateZombies_generateZombiesModeStatus("RainIntensity",
                sandbox_options)
        end
        if sandbox_options:getOptionByName("ClimateZombies.SnowIntensityEnable"):getValue() then
            CLIMATE_ZOMBIES_CURRENT_SNOW_INTENSITY_MODE = ClimateZombies_generateZombiesModeStatus("SnowIntensity",
                sandbox_options)
        end

        -- local precipitation_intensity_enable = false
        -- if precipitation_intensity_enable then
        --     CLIMATE_ZOMBIES_CURRENT_PRECIPITATION_INTENSITY_MODE =
        --         ClimateZombies_generateZombiesModeStatus("SnowIntensity", sandbox_options)
        -- end
        -- TIME 
        -- THUNDER
        -- THUNDER_STORMING
        -- RAIN
        -- SNOW
        -- MOON_PHASE
        -- MOON PROCEDURAL
        -- DAY PROCEDURAL
        -- NIGHT PROCEDURAL
        -- FOG PROCEDURAL
        -- CLOUD PROCEDURAL
        -- RAIN PROCEDURAL
        -- SNOW PROCEDURAL
        -- TEMPERATURE PROCEDURAL
        -- WIND PROCEDURAL
        -- local season = getClimateManager():getSeason()
        -- CLIMATE_ZOMBIES_DAY_START_TIME = (season:getDawn() + CLIMATE_ZOMBIES_DAWN_OFFSET) % 24
        -- CLIMATE_ZOMBIES_NIGHT_START_TIME = (season:getDusk() + CLIMATE_ZOMBIES_DUSK_OFFSET) % 24
        -- local game_time_of_day = getGameTime():getTimeOfDay()
        -- CLIMATE_ZOMBIES_IS_NIGHT = (CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY and game_time_of_day >=
        --                                CLIMATE_ZOMBIES_NIGHT_START_TIME and game_time_of_day <
        --                                CLIMATE_ZOMBIES_DAY_START_TIME) or (not CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY and
        --                                (game_time_of_day >= CLIMATE_ZOMBIES_NIGHT_START_TIME or game_time_of_day <
        --                                    CLIMATE_ZOMBIES_DAY_START_TIME))
        -- CLIMATE_ZOMBIES_NIGHT_HOUR_NEW_DAY = CLIMATE_ZOMBIES_DAY_START_TIME > CLIMATE_ZOMBIES_NIGHT_START_TIME
        -- if CLIMATE_ZOMBIES_IS_NIGHT then
        --     local climate_moon = getClimateMoon()
        --     if climate_moon then
        --         CLIMATE_ZOMBIES_COMPUTE_MOON = true
        --         -- PUT CONDITION OF MOON HERE
        --     end
        -- end

        local game_time_mod_data = getGameTime():getModData()
        if game_time_mod_data.climate_zombies_zombies_mode_ids == nil then
            game_time_mod_data.climate_zombies_zombies_mode_ids = {}
        end

        local easter_egg_enable = true -- sandbox_options:getOptionByName("ClimateZombies.EasterEggEnable"):getValue()
        if easter_egg_enable then
            if game_time_mod_data.climate_zombies_easter_egg_duration and
                game_time_mod_data.climate_zombies_easter_egg_duration > 0 then
                CLIMATE_ZOMBIES_EASTER_EGG_ACTIVATE = true
                ClimateZombies_updateZombiesMode({
                    ["ZombieLore.Speed"] = -1,
                    ["ZombieLore.Strength"] = -1,
                    ["ZombieLore.Toughness"] = -1,
                    ["ZombieLore.Cognition"] = -1,
                    ["ZombieLore.Memory"] = -1,
                    ["ZombieLore.Sight"] = -1,
                    ["ZombieLore.Hearing"] = -1
                })
                game_time_mod_data.climate_zombies_easter_egg_duration =
                    game_time_mod_data.climate_zombies_easter_egg_duration - 2
            else
                game_time_mod_data.climate_zombies_easter_egg_duration = 0
            end
            Events.OnThunderEvent.Add(ClimateZombies_OnThunderEvent)
        end

        Events.EveryTenMinutes.Add(ClimateZombies_EveryTenMinutes)
        -- Events.EveryDays.Add(ClimateZombies_EveryDays)
        -- Events.OnDawn.Add(ClimateZombies_OnDawn)
        -- Events.OnDusk.Add(ClimateZombies_OnDusk)
        Events.OnZombieUpdate.Add(ClimateZombies_OnZombieUpdate)

        ClimateZombies_EveryTenMinutes()
        ClimateZombies_EveryTenMinutes()
        ClimateZombies_EveryTenMinutes()
    end
end

Events.OnGameTimeLoaded.Add(ClimateZombies_OnGameTimeLoaded)
