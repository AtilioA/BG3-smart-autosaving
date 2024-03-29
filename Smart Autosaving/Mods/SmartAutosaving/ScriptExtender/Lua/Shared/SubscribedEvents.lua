SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
  SAPrint(2, "Subscribing to events with JSON config: " .. Ext.Json.Stringify(Config:getCfg(), { Beautify = true }))

  if Config:getCfg().GENERAL.enabled == true then
    -- Registering general Osiris event listeners
    -- Start the timer when the game is loaded
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", Autosaving.StartOrRestartTimer)
    Ext.Osiris.RegisterListener("TimerFinished", 1, "before", EHandlers.OnTimerFinished)

    -- Subscribe to the GameStateChanged event to detect when saves are created and reset the timer
    -- Note that it will also trigger with the mod's own autosaves, but there shouldn't be any issues with that
    if Config:getCfg().FEATURES.TIMER.save_aware then
      Ext.Events.GameStateChanged:Subscribe(EHandlers.OnGameStateChange)
    end

    if Config:getCfg().FEATURES.TIMER.load_aware then
      Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", EHandlers.SavegameLoaded)
    end

    -- Events that can restrict autosaving
    -- Dialogue
    if Config:getCfg().FEATURES.POSTPONE_ON.dialogue then
      Ext.Osiris.RegisterListener("DialogStartRequested", 2, "before", EHandlers.OnDialogStart)
      Ext.Osiris.RegisterListener("DialogStarted", 2, "before", EHandlers.OnDialogStart)
      Ext.Osiris.RegisterListener("DialogEnded", 2, "before", EHandlers.OnDialogEnd)
    end

    -- Trading
    if Config:getCfg().FEATURES.POSTPONE_ON.trade then
      Ext.Osiris.RegisterListener("RequestTrade", 4, "before", EHandlers.OnTradeStart)
      Ext.Osiris.RegisterListener("TradeEnds", 2, "before", EHandlers.OnTradeEnd)
      Ext.Osiris.RegisterListener("MovedFromTo", 4, "after", EHandlers.OnMovedFromTo)
    end

    -- Combat
    if Config:getCfg().FEATURES.POSTPONE_ON.combat then
      -- REVIEW: I don't know if this event is triggered when combat starts only with the player or with any character, perhaps we should not listen to this at all (combat is already handled with other checks anyways)
      Ext.Osiris.RegisterListener("CombatStarted", 1, "before", EHandlers.OnCombatStart)
      Ext.Osiris.RegisterListener("CombatEnded", 1, "before", EHandlers.OnCombatEnd)
      -- (Not actually working)
      -- Ext.Osiris.RegisterListener("CombatRoundStarted", 1, "before", EHandlers.onCombatRoundStarted)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.combat_turn then
      Ext.Osiris.RegisterListener("TurnEnded", 1, "after", EHandlers.OnTurnEnded)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.lockpicking then
      Ext.Osiris.RegisterListener("StartedLockpicking", 2, "before", EHandlers.OnLockpickingStart)
      Ext.Osiris.RegisterListener("StoppedLockpicking", 2, "before", EHandlers.OnLockpickingEnd)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.using_items then
      Ext.Osiris.RegisterListener("UseStarted", 2, "before", EHandlers.OnUseStarted)
      Ext.Osiris.RegisterListener("UseFinished", 3, "before", EHandlers.OnUseEnded)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.looting_characters then
      Ext.Osiris.RegisterListener("RequestCanLoot", 2, "after", EHandlers.onRequestCanLoot)
      Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", EHandlers.onCharacterLootedCharacter)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.turn_based then
      Ext.Osiris.RegisterListener("EnteredForceTurnBased", 1, "before", EHandlers.OnEnteredForceTurnBased)
      Ext.Osiris.RegisterListener("LeftForceTurnBased", 1, "before", EHandlers.OnLeftForceTurnBased)
      -- I don't know what this is used for, it is not for things like shadow-curse
      -- Ext.Osiris.RegisterListener("EnteredSharedForceTurnBased", 2, "before", EHandlers.OnEnteredSharedForceTurnBased)
    end

    if Config:getCfg().FEATURES.POSTPONE_ON.respec_and_mirror then
      Ext.Osiris.RegisterListener("RespecCancelled", 1, "before", EHandlers.OnRespecCancelled)
      Ext.Osiris.RegisterListener("RespecCompleted", 1, "before", EHandlers.OnRespecCompleted)
    end

    -- Ext.Osiris.RegisterListener("MovedBy", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("MoveCapabilityChanged", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("TextEvent", 1, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("UserEvent", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("ForceMoveEnded", 3, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("ForceMoveStarted", 3, "before", EHandlers.DebugEvent)

    -- Ext.Osiris.RegisterListener("CharacterMadePlayer", 1, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("CharacterMoveFailedUseJump", 1, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("CharacterMoveToAndTalkFailed", 4, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("CharacterMoveToAndTalkRequestDialog", 4, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("CharacterMoveToCancelled", 2, "before", EHandlers.DebugEvent)

    -- Ext.Osiris.RegisterListener("AutomatedDialogEnded", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("AutomatedDialogForceStopping", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("AutomatedDialogRequestFailed", 2, "before", EHandlers.DebugEvent)
    -- Ext.Osiris.RegisterListener("AutomatedDialogStarted", 2, "before", EHandlers.DebugEvent)

    -- Can't be used:
    -- Ext.Osiris.RegisterListener("LeveledUp", 1, "before", EHandlers.OnLeveledUp)
    -- Ext.Osiris.RegisterListener("UserEvent", 2, "before", EHandlers.OnUserEvent)
    -- Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", EHandlers.OnLevelGameplayStarted)
    -- Ext.Osiris.RegisterListener("LevelTemplateLoaded", 1, "before", EHandlers.OnLevelTemplateLoaded)
    -- Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", EHandlers.OnLevelUnloading)

    -- Ext.Osiris.RegisterListener("PuzzleUIUsed", 5, "before", EHandlers.OnPuzzleUIUsed)
    -- Ext.Osiris.RegisterListener("PuzzleUIClosed", 3, "before", EHandlers.OnPuzzleUIClosed)

    -- -- https://www.youtube.com/watch?v=o5LlIdAd5h8
    -- Ext.Osiris.RegisterListener("VoiceBarkEnded", 2, "before", EHandlers.OnVoiceBarkEnded)
    -- Ext.Osiris.RegisterListener("VoiceBarkFailed", 1, "before", EHandlers.OnVoiceBarkFailed)
    -- Ext.Osiris.RegisterListener("VoiceBarkStarted", 2, "before", EHandlers.OnVoiceBarkStarted)
  end
end

return SubscribedEvents
