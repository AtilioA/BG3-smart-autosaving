local Config = {}

Config.configFilePath = "config.json"
Config.defaultConfig = {
    TIMER = {
        autosaving_period_in_minutes = 10, -- 10 minutes
        save_aware = true,                 -- Reset timer when manual/quick/autosaves are made
        load_aware = true                  -- Reset timer when loading a save
    },
    EVENTS = {                             -- If save is due, postpone to...
        dialogue = true,                   -- after dialogue
        trade = true,                      -- after trade
        combat = true,                     -- after combat
        combat_turn = true,                -- after turn ends (not mutually exclusive with combat)
        lockpicking = true,                -- after lockpicking
        looting_containers = true,            -- after closing containers
        using_items = true,                -- after using an item
        looting_characters = true          -- after looting characters
    },
    DEBUG = {
        level = 0 -- 0 = no debug, 1 = minimal, 2 = verbose logs
    }
}


-- Load a JSON configuration file and return a table or nil
function Config.LoadConfig(filePath)
    local configFileContent = Ext.IO.LoadFile(filePath)
    if configFileContent and configFileContent ~= "" then
        Config.DebugPrint(1, "Loaded config file: " .. filePath)
        return Ext.Json.Parse(configFileContent)
    else
        Config.DebugPrint(1, "File not found: " .. filePath)
        return nil
    end
end

-- Save a config table to a JSON file
function Config.SaveConfig(filePath, config)
    local configFileContent = Ext.Json.Stringify(config, { Beautify = true })
    Ext.IO.SaveFile(filePath, configFileContent)
end

function Config.LoadJSONConfig()
    -- Try to load the config file
    local jsonConfig = Config.LoadConfig(Config.configFilePath)
    if not jsonConfig then
        -- Load default config if the file doesn't exist
        jsonConfig = Config.defaultConfig
        Config.DebugPrint(1, "Default config file loaded.")
        Config.SaveConfig(Config.configFilePath, jsonConfig)
    else
        Config.DebugPrint(1, "Config file loaded.")
    end

    return jsonConfig
end

Config.jsonConfig = Config.LoadJSONConfig()

function Config.DebugPrint(level, ...)
    if Config.jsonConfig.DEBUG.level >= level then
        print(...)
    end
end