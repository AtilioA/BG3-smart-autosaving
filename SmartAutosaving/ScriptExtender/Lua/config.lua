local Config = {}

Config.AUTOSAVING_PERIOD = 10 * 60 -- 10 minutes
Config.EVENTS = {
    dialogue = true,         -- Postpone autosaving if the player is in dialogue
    trade = true,            -- Postpone autosaving if the player is trading
    combat = true,           -- Postpone autosaving if the player is in combat
    lockpicking = true       -- Postpone autosaving if the player is lockpicking
}

return Config
