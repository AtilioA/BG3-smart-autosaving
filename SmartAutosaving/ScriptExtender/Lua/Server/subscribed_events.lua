
local EHandlers = Ext.Require("Server/event_handlers.lua")

-- Handler when the timer finishes
local function OnTimerFinished(timer)
  print("Timer finished: " .. timer)
end

local function StartOrRestartTimer()
  Osi.TimerCancel(TIMER)
  Osi.TimerLaunch(TIMER, AUTOSAVING_PERIOD * 1000)
  Autosaving.waitingForAutosave = false
end

local function SubscribeToEvents(jsonConfig)
  print("Subscribing to events with config: " .. Ext.Json.Stringify(jsonConfig, {Beautify = true}))
  -- Registering general Osiris event listeners
  -- Start the timer when the game is loaded
  Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", StartOrRestartTimer)
  Ext.Osiris.RegisterListener("TimerFinished", 1, "before", OnTimerFinished)

  -- Subscribe to the GameStateChanged event to detect when saves are created and reset the timer
  -- Note that it will also trigger with the mod's own autosaves, but there shouldn't be any issues with that
  if jsonConfig.TIMER.save_aware then
    Ext.Events.GameStateChanged:Subscribe(EHandlers.OnGameStateChange)
  end

  -- TODO: reset timer
  if jsonConfig.TIMER.load_aware then
    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "before", EHandlers.SavegameLoaded)
  end

  -- Events that can restrict autosaving
  -- Dialogue
  if jsonConfig.EVENTS.dialogue then
      Ext.Osiris.RegisterListener("DialogStartRequested", 2, "before", EHandlers.OnDialogStart)
      Ext.Osiris.RegisterListener("DialogStarted", 2, "before", EHandlers.OnDialogStart)
      Ext.Osiris.RegisterListener("DialogEnded", 2, "before", EHandlers.OnDialogEnd)
  end

  -- Trading
  if jsonConfig.EVENTS.trade then
      Ext.Osiris.RegisterListener("RequestTrade", 4, "before", EHandlers.OnTradeStart)
      Ext.Osiris.RegisterListener("TradeEnds", 2, "before", EHandlers.OnTradeEnd)
  end

  -- Combat
  if jsonConfig.EVENTS.combat then
      Ext.Osiris.RegisterListener("CombatStarted", 1, "before", EHandlers.OnCombatStart)
      Ext.Osiris.RegisterListener("CombatEnded", 1, "before", EHandlers.OnCombatEnd)
      -- (Not actually working)
      -- Ext.Osiris.RegisterListener("CombatRoundStarted", 1, "before", EHandlers.onCombatRoundStarted)
  end

  if jsonConfig.EVENTS.turnEnd then
      Ext.Osiris.RegisterListener("TurnEnded", 2, "before", EHandlers.OnTurnEnded)
  end

  if jsonConfig.EVENTS.lockpicking then
    Ext.Osiris.RegisterListener("StartedLockpicking", 2, "before", EHandlers.OnLockpickingStart)
    Ext.Osiris.RegisterListener("StoppedLockpicking", 2, "before", EHandlers.OnLockpickingEnd)
  end

  -- WIP:
  -- Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
  -- Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)

  -- Ext.Osiris.RegisterListener("Opened", 1, "before", EHandlers.onOpened)
  -- Ext.Osiris.RegisterListener("Closed", 1, "before", EHandlers.onClosed)

  -- I still gotta try out event trigger in-game
  if jsonConfig.EVENTS.looting_character then
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", EHandlers.onCharacterLootedCharacter)
  end
end

return {
  SubscribeToEvents = SubscribeToEvents
}
