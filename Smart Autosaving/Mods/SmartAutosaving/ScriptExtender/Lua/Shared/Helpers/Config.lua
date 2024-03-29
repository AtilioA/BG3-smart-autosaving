Config = VCHelpers.Config:New({
  folderName = "SmartAutosaving",
  configFilePath = "smart_autosaving_config.json",
  currentConfig = {},
  defaultConfig = {
    DEBUG = {
      level = 0,
      timer_in_seconds = false
    },
    FEATURES = {
      POSTPONE_ON = {
        combat = true,
        combat_turn = true,
        dialogue = true,
        idle = true,
        lockpicking = true,
        looting_characters = true,
        movement = true,
        respec_and_mirror = true,
        trade = true,
        turn_based_mode = true,
        using_items = true,
      },
      TIMER = {
        autosaving_period_in_minutes = 10,
        load_aware = true,
        save_aware = true
      },
      -- SAVE_ON_START_OF = {
      --   combat = false,
      --   combat_turn = false,
      --   dialogue = false,
      --   lockpicking = false,
      --   trade = false,
      --   turn_based_mode = false,
      -- },
    },
    GENERAL = {
      enabled = true -- (previously TIMER.enabled)
    }
  }
})

function Config:ConvertConfig()
  if self.currentConfig then
    if self.currentConfig.TIMER ~= nil or self.currentConfig.EVENTS ~= nil then
      local oldConfig = self.currentConfig
      local newConfig = {
        ["DEBUG"] = oldConfig["DEBUG"], -- Copy DEBUG as-is
        ["FEATURES"] = {
          ["POSTPONE_ON"] = {
            ["combat"] = oldConfig["EVENTS"]["combat"],
            ["combat_turn"] = oldConfig["EVENTS"]["combat_turn"],
            ["dialogue"] = oldConfig["EVENTS"]["dialogue"],
            ["idle"] = oldConfig["EVENTS"]["idle"],
            ["lockpicking"] = oldConfig["EVENTS"]["lockpicking"],
            ["looting_characters"] = oldConfig["EVENTS"]["looting_characters"],
            ["movement"] = oldConfig["EVENTS"]["movement"],
            ["respec_and_mirror"] = oldConfig["EVENTS"]["respec_and_mirror"],
            ["trade"] = oldConfig["EVENTS"]["trade"],
            ["turn_based_mode"] = oldConfig["EVENTS"]["turn_based"], -- Renamed from "turn_based" to "turn_based_mode"
            ["using_items"] = oldConfig["EVENTS"]["using_items"],
          },
          ["TIMER"] = {
            ["autosaving_period_in_minutes"] = oldConfig["TIMER"]["autosaving_period_in_minutes"],
            ["load_aware"] = oldConfig["TIMER"]["load_aware"],
            ["save_aware"] = oldConfig["TIMER"]["save_aware"],
          }
        },
        ["GENERAL"] = {
          ["enabled"] = oldConfig["TIMER"]["enabled"] -- Moved from TIMER.enabled to GENERAL.enabled
        }
      }

      if newConfig then
        self:SaveConfig(self.configFilePath, newConfig)
      end
    end
  end
end

-- Update the config file to v3 structure
Config:ConvertConfig()
Config:UpdateCurrentConfig()

Config:AddConfigReloadedCallback(function(configInstance)
  SAPrinter.DebugLevel = configInstance:GetCurrentDebugLevel()
  SAPrint(0, "Config reloaded: " .. Ext.Json.Stringify(configInstance:getCfg(), { Beautify = true }))
end)
Config:RegisterReloadConfigCommand("sa")
