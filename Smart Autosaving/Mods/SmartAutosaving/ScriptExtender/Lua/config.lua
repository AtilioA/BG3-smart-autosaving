local Config = {}

FolderName = "SmartAutosaving"
Config.configFilePath = "smart_autosaving_config.json"

-- TODO: update player config file on load to add new options
Config.defaultConfig = {
    TIMER = {
        enabled = true,                    -- Effectively disable the whole mod
        autosaving_period_in_minutes = 10, -- 10 minutes
        save_aware = true,                 -- Reset timer when manual/quick/autosaves are made
        load_aware = true                  -- Reset timer when loading a save
    },
    EVENTS = {                             -- If save is due, postpone to...
        dialogue = true,                   -- after dialogue
        trade = true,                      -- after trade
        combat = true,                     -- after combat
        combat_turn = true,                -- after party member turn ends (not mutually exclusive with combat)
        turn_based = true,                 -- after exiting turn-based mode
        lockpicking = true,                -- after lockpicking
        using_items = true,                -- after using an item (you use a container while looting)
        looting_characters = true,         -- after looting characters
        looting_containers = true,         -- after closing containers (not currently used)
        respec_and_mirror = true,          -- after respeccing or using mirror
    },
    DEBUG = {
        level = 0 -- 0 = no debug, 1 = minimal, 2 = verbose logs
    }
}

function Config.DebugPrint(level, ...)
    if Config.jsonConfig and Config.jsonConfig.DEBUG and Config.jsonConfig.DEBUG.level >= level then
        print(...)
    end
end

function Config.GetModPath(filePath)
    return FolderName .. '/' .. filePath
end

-- Load a JSON configuration file and return a table or nil
function Config.LoadConfig(filePath)
    local configFileContent = Ext.IO.LoadFile(Config.GetModPath(filePath))
    if configFileContent and configFileContent ~= "" then
        -- Config.DebugPrint(1, "Loaded config file: " .. filePath)
        return Ext.Json.Parse(configFileContent)
    else
        -- Config.DebugPrint(1, "File not found: " .. filePath)
        return nil
    end
end

-- Save a config table to a JSON file
function Config.SaveConfig(filePath, config)
    local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
    Ext.IO.SaveFile(Config.GetModPath(filePath), configFileContent)
end

function Config.LoadJSONConfig()
    -- Try to load the config file
    local jsonConfig = Config.LoadConfig(Config.configFilePath)
    if not jsonConfig then
        -- Load default config if the file doesn't exist
        jsonConfig = Config.defaultConfig
        -- Config.DebugPrint(1, "Default config file loaded.")
        Config.SaveConfig(Config.configFilePath, jsonConfig)
    else
        -- Config.DebugPrint(1, "Config file loaded.")
    end

    return jsonConfig
end

JsonConfig = Config.LoadJSONConfig()

return Config
