local EHandlers = Ext.Require("Server/event_handlers.lua")
-- For some reason I'm not able to use Config.jsonConfig here
local Config = Ext.Require("config.lua")

local function SubscribeToEvents()
  -- Config.DebugPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))
  -- print("Subscribing to events with JSON config: " .. Ext.Json.Stringify(JsonConfig, { Beautify = true }))
  -- Registering general Osiris event listeners
  -- Start the timer when the game is loaded
  Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.StartOrRestartTimer)
  Ext.Osiris.RegisterListener("TimerFinished", 1, "before", EHandlers.OnTimerFinished)

  -- Subscribe to the GameStateChanged event to detect when saves are created and reset the timer
  -- Note that it will also trigger with the mod's own autosaves, but there shouldn't be any issues with that
  if JsonConfig.TIMER.save_aware then
    Ext.Events.GameStateChanged:Subscribe(EHandlers.OnGameStateChange)
  end

  -- TODO: reset timer
  if JsonConfig.TIMER.load_aware then
    Ext.Osiris.RegisterListener("SavegameLoaded", 0, "before", EHandlers.SavegameLoaded)
  end

  -- Events that can restrict autosaving
  -- Dialogue
  if JsonConfig.EVENTS.dialogue then
    Ext.Osiris.RegisterListener("DialogStartRequested", 2, "before", EHandlers.OnDialogStart)
    Ext.Osiris.RegisterListener("DialogStarted", 2, "before", EHandlers.OnDialogStart)
    Ext.Osiris.RegisterListener("DialogEnded", 2, "before", EHandlers.OnDialogEnd)
  end

  -- Trading
  if JsonConfig.EVENTS.trade then
    Ext.Osiris.RegisterListener("RequestTrade", 4, "before", EHandlers.OnTradeStart)
    Ext.Osiris.RegisterListener("TradeEnds", 2, "before", EHandlers.OnTradeEnd)
  end

  -- Combat
  if JsonConfig.EVENTS.combat then
    Ext.Osiris.RegisterListener("CombatStarted", 1, "before", EHandlers.OnCombatStart)
    Ext.Osiris.RegisterListener("CombatEnded", 1, "before", EHandlers.OnCombatEnd)
    -- (Not actually working)
    -- Ext.Osiris.RegisterListener("CombatRoundStarted", 1, "before", EHandlers.onCombatRoundStarted)
  end

  if JsonConfig.EVENTS.combat_turn then
    Ext.Osiris.RegisterListener("TurnEnded", 1, "before", EHandlers.OnTurnEnded)
  end

  if JsonConfig.EVENTS.lockpicking then
    Ext.Osiris.RegisterListener("StartedLockpicking", 2, "before", EHandlers.OnLockpickingStart)
    Ext.Osiris.RegisterListener("StoppedLockpicking", 2, "before", EHandlers.OnLockpickingEnd)
  end

  if JsonConfig.EVENTS.using_items then
    Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
    Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)
  end

  -- if JsonConfig.EVENTS.looting_containers then
  --   Ext.Osiris.RegisterListener("Opened", 1, "before", EHandlers.onOpened)
  --   Ext.Osiris.RegisterListener("Closed", 1, "before", EHandlers.onClosed)
  -- end

  -- I still gotta try out event trigger in-game
  if JsonConfig.EVENTS.looting_characters then
    Ext.Osiris.RegisterListener("RequestCanLoot", 2, "before", EHandlers.onRequestCanLoot)
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", EHandlers.onCharacterLootedCharacter)
  end

  -- Events to investigate further
  -- Osi.UserEvent(userID, userEvent)

  -- Osi.EnteredForceTurnBased(object) and Osi.LeftForceTurnBased(object)
  -- Osi.EnteredSharedForceTurnBased(object, zoneId)

  -- Osi.AnimationEvent(object, eventName, wasFromLoad)

  -- Osi.LevelGameplayStarted(levelName, isEditorMode)
  -- Osi.LevelLoaded(newLevel)
  -- Osi.LevelTemplateLoaded(levelTemplate)
  -- Osi.LevelUnloading(level)
  -- Osi.RespecCancelled(character)
  -- Osi.RespecCompleted(character)

  --  Osi.PuzzleUIUsed(character, uIInstance, type, command, elementId),  Osi.PuzzleUIClosed(character, uIInstance, type)

  -- Osi.Falling(entity, cause) and Osi.Fell(entity, cause)

  -- Osi.RequestCanCombine(character, item1, item2, item3, item4, item5, requestID)
  -- Osi.Combined(item1, item2, item3, item4, item5, character, newItem)
  -- Osi.StoppedCombining(character, item1, item2, item3, item4, item5)

  -- https://www.youtube.com/watch?v=o5LlIdAd5h8
  -- Osi.VoiceBarkEnded(bark, instanceID)
  -- Osi.VoiceBarkFailed(bark)
  -- Osi.VoiceBarkStarted(bark, instanceID)
end

return {
  SubscribeToEvents = SubscribeToEvents
}