SubscribedEvents = {}

function SubscribedEvents.SubscribeToEvents()
    -- Not needed for this mod cause ... lmao
    -- local function conditionalWrapper(handler)
    --     return function(...)
    --         if MCM.Get("mod_enabled") then
    --             handler(...)
    --         else
    --             WIEGDebug(1, "Event handling is disabled.")
    --         end
    --     end
    -- end

    SAPrint(2,
        "Subscribing to events with JSON config: " ..
        Ext.Json.Stringify(Mods.BG3MCM.MCMAPI:GetAllModSettings(ModuleUUID), { Beautify = true }))

    -- Registering general Osiris event listeners
    -- Start the timer when the game is loaded
    Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", function(levelName, isEditorMode)
        if MCM.Get("mod_enabled") then
            Autosaving.CheckGameAutosavingSettings()
            Autosaving.StartOrRestartTimer()
        end
    end)
    Ext.Osiris.RegisterListener("TimerFinished", 1, "before", function(timer)
        if MCM.Get("mod_enabled") then
            EHandlers.OnTimerFinished(timer)
        end
    end)

    -- Subscribe to the GameStateChanged event to detect when saves are created and reset the timer
    -- Note that it will also trigger with the mod's own autosaves, but there shouldn't be any issues with that
    Ext.Events.GameStateChanged:Subscribe(function(e)
        if MCM.Get("mod_enabled") and MCM.Get("save_aware") then
            EHandlers.OnGameStateChange(e)
        end
    end)

    -- Events that can restrict autosaving
    -- Dialogue
    Ext.Osiris.RegisterListener("DialogStartRequested", 2, "before", function()
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_dialogue") then
            EHandlers.OnDialogStart()
        end
    end)
    Ext.Osiris.RegisterListener("DialogStarted", 2, "before", function()
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_dialogue") then
            EHandlers.OnDialogStart()
        end
    end)
    Ext.Osiris.RegisterListener("DialogEnded", 2, "before", function()
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_dialogue") then
            EHandlers.OnDialogEnd()
        end
    end)

    -- Trading
    Ext.Osiris.RegisterListener("RequestTrade", 4, "before", function(character, target, tradeMode, itemsTagFilter)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_trade") then
            EHandlers.OnTradeStart()
        end
    end)
    Ext.Osiris.RegisterListener("TradeEnds", 2, "before", function(character, target)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_trade") then
            EHandlers.OnTradeEnd()
        end
    end)
    Ext.Osiris.RegisterListener("MovedFromTo", 4, "after", function(movedObject, fromObject, toObject, isTrade)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_trade") then
            EHandlers.OnMovedFromTo(movedObject, fromObject, toObject, isTrade)
        end
    end)

    -- Combat
    -- REVIEW: I don't know if this event is triggered when combat starts only with the player or with any character, perhaps we should not listen to this at all (combat is already handled with other checks anyways)
    Ext.Osiris.RegisterListener("CombatStarted", 1, "before", function(combatGuid)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_combat") then
            EHandlers.OnCombatStart()
        end
    end)
    Ext.Osiris.RegisterListener("CombatEnded", 1, "before", function(combatGuid)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_combat") then
            EHandlers.OnCombatEnd()
        end
    end)
    -- (Not actually working)
    -- Ext.Osiris.RegisterListener("CombatRoundStarted", 1, "before", EHandlers.onCombatRoundStarted)
    Ext.Osiris.RegisterListener("TurnEnded", 1, "after", function(character)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_combat_turn") then
            EHandlers.OnTurnEnded(character)
        end
    end)

    Ext.Osiris.RegisterListener("StartedLockpicking", 2, "before", function(character, item)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_lockpicking") then
            EHandlers.OnLockpickingStart()
        end
    end)
    Ext.Osiris.RegisterListener("StoppedLockpicking", 2, "before", function(character, item)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_lockpicking") then
            EHandlers.OnLockpickingEnd()
        end
    end)

    Ext.Osiris.RegisterListener("UseStarted", 2, "before", function(character, item)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_using_items") then
            EHandlers.OnUseStarted(character, item)
        end
    end)
    Ext.Osiris.RegisterListener("UseFinished", 3, "before", function(character, item, result)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_using_items") then
            EHandlers.OnUseEnded(character, item, result)
        end
    end)

    Ext.Osiris.RegisterListener("RequestCanLoot", 2, "after", function(looter, target)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_looting_characters") then
            EHandlers.onRequestCanLoot(looter, target)
        end
    end)
    Ext.Osiris.RegisterListener("CharacterLootedCharacter", 2, "before", function(player, lootedCharacter)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_looting_characters") then
            EHandlers.onCharacterLootedCharacter(player, lootedCharacter)
        end
    end)

    Ext.Osiris.RegisterListener("EnteredForceTurnBased", 1, "before", function(object)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_turn_based_mode") then
            EHandlers.OnEnteredForceTurnBased(object)
        end
    end)
    Ext.Osiris.RegisterListener("LeftForceTurnBased", 1, "before", function(object)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_turn_based_mode") then
            EHandlers.OnLeftForceTurnBased(object)
        end
    end)

    -- I don't know what this is used for, it is not for things like shadow-curse
    -- Ext.Osiris.RegisterListener("EnteredSharedForceTurnBased", 2, "before", EHandlers.OnEnteredSharedForceTurnBased)
    Ext.Osiris.RegisterListener("RespecCancelled", 1, "before", function(character)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_respec_and_mirror") then
            EHandlers.OnRespecCancelled(character)
        end
    end)
    Ext.Osiris.RegisterListener("RespecCompleted", 1, "before", function(character)
        if MCM.Get("mod_enabled") and MCM.Get("postpone_on_respec_and_mirror") then
            EHandlers.OnRespecCompleted(character)
        end
    end)

    Ext.RegisterNetListener("SA_ClientAutosaveStatus", function(call, payload)
        local data = Ext.Json.Parse(payload)
        if MCM.Get("mod_enabled") then
            EHandlers.OnClientMayAutosave(data)
        end
    end)

    Ext.RegisterNetListener("SA_LastPaperdollDestroyed", function(call, payload)
        if MCM.Get("mod_enabled") then
            EHandlers.OnLastPaperdollDestroyed()
        end
    end)

    -- This would require ModVars and I don't want to implement that for such an uneeded feature
    -- if MCM.Get("load_aware") then
    --   Ext.Osiris.RegisterListener("SavegameLoaded", 0, "after", EHandlers.SavegameLoaded)
    -- end
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
    -- Ext.Osiris.RegisterListener("LeveledUp", 1, "before", conditionalWrapper(EHandlers.OnLeveledUp))
    -- Ext.Osiris.RegisterListener("UserEvent", 2, "before", conditionalWrapper(EHandlers.OnUserEvent))
    -- Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", conditionalWrapper(EHandlers.OnLevelGameplayStarted))
    -- Ext.Osiris.RegisterListener("LevelTemplateLoaded", 1, "before", conditionalWrapper(EHandlers.OnLevelTemplateLoaded))
    -- Ext.Osiris.RegisterListener("LevelUnloading", 1, "before", conditionalWrapper(EHandlers.OnLevelUnloading))

    -- Ext.Osiris.RegisterListener("PuzzleUIUsed", 5, "before", conditionalWrapper(EHandlers.OnPuzzleUIUsed))
    -- Ext.Osiris.RegisterListener("PuzzleUIClosed", 3, "before", conditionalWrapper(EHandlers.OnPuzzleUIClosed))

    -- -- https://www.youtube.com/watch?v=o5LlIdAd5h8
    -- Ext.Osiris.RegisterListener("VoiceBarkEnded", 2, "before", conditionalWrapper(EHandlers.OnVoiceBarkEnded))
    -- Ext.Osiris.RegisterListener("VoiceBarkFailed", 1, "before", conditionalWrapper(EHandlers.OnVoiceBarkFailed))
    -- Ext.Osiris.RegisterListener("VoiceBarkStarted", 2, "before", conditionalWrapper(EHandlers.OnVoiceBarkStarted))
end

return SubscribedEvents
