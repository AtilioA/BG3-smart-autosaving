EHandlers = {}

-- Handler when the timer finishes
function EHandlers.OnTimerFinished(timer)
  -- entity = Ext.Entity.Get(Osi.GetHostCharacter())
  -- Ext.IO.SaveFile('character-entity.json', Ext.DumpExport(entity:GetAllComponents()))
  if timer == Autosaving.TIMER_NAME then
    if Autosaving.CanAutosave() then
      Autosaving.Autosave()
      Autosaving.StartOrRestartTimer()
    else -- timer finished but we can't autosave yet, so we'll wait for the next event to try again
      Utils.DebugPrint(2, "OnTimerFinished: Can't autosave yet, waiting for next event")
      Autosaving.UpdateState("waitingForAutosave", true)
    end
  end
end

function EHandlers.OnGameStateChange(e)
  -- Reset the timer if the game state changes to 'Save'
  -- String comparison isn't ideal, but it should be fine for this
  local toStateStr = tostring(e.ToState)
  if toStateStr == 'Save' then
    Autosaving.StartOrRestartTimer()
  end
end

function EHandlers.SavegameLoaded()
  -- Reset the timer when a save is loaded
  Autosaving.StartOrRestartTimer()
end

function EHandlers.OnDialogStart()
  Utils.DebugPrint(2, "Dialogue started")
  -- entity = Ext.Entity.Get(Osi.GetHostCharacter())
  -- Ext.IO.SaveFile('character-entity.json', Ext.DumpExport(entity:GetAllComponents()))
  -- print(entity:GetAllComponents().ServerCharacter)

  Autosaving.UpdateState("isInDialogue", true)
end

function EHandlers.OnDialogEnd()
  Utils.DebugPrint(2, "Dialogue ended")

  Autosaving.UpdateState("isInDialogue", false)
end

function EHandlers.OnTradeStart()
  Utils.DebugPrint(2, "OnTradeStart")
  Autosaving.UpdateState("isInTrade", true)
end

function EHandlers.OnTradeEnd()
  Utils.DebugPrint(2, "OnTradeEnd")
  Autosaving.UpdateState("isInTrade", false)
  -- Save regardless of dialogue state
  Autosaving.SaveIfWaiting()
end

function EHandlers.OnCombatStart()
  Utils.DebugPrint(2, "OnCombatStart")
  Autosaving.UpdateState("isInCombat", true)
end

-- I didn't manage to get this to work, so I'm using TurnEnded instead
-- function EHandlers.onCombatRoundStarted()
  -- Utils.DebugPrint(2, "onCombatRoundStarted")
--     Autosaving.UpdateState("combatTurnEnded", true)
-- end
function EHandlers.OnCombatEnd()
  Utils.DebugPrint(2, "OnCombatEnd")
  Autosaving.UpdateState("isInCombat", false)
end

function EHandlers.OnTurnEnded(char)
  -- Potentially save if the turn ended for the avatar or party member (this should not trigger multiplayer or summons)
  if Osi.IsInPartyWith(char, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "OnTurnEnded: " .. char)
    Autosaving.UpdateState("combatTurnEnded", true)
    Autosaving.HandlePotentialAutosave()
  end
end

function EHandlers.OnLockpickingStart()
  Utils.DebugPrint(2, "Lockpicking started")
  Autosaving.UpdateState("isLockpicking", true)
end

function EHandlers.OnLockpickingEnd()
  Utils.DebugPrint(2, "Lockpicking ended")
  Autosaving.UpdateState("isLockpicking", false)
end

-- This might cause problems if the target is 'owned' (has red highlight)
function EHandlers.onRequestCanLoot(looter, target)
  if Osi.IsInPartyWith(looter, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "RequestCanLoot: " .. looter .. " " .. target)
    Autosaving.UpdateState("isLootingCharacter", true)
  end
end

function EHandlers.onCharacterLootedCharacter(player, lootedCharacter)
  if Osi.IsInPartyWith(player, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "CharacterLootedCharacter: " .. player .. " " .. lootedCharacter)
    Autosaving.UpdateState("isLootingCharacter", false)
  end
end

-- WIP/looking for means of detection
-- function EHandlers.OnCharacterCreationStart()
-- Utils.DebugPrint(2, "Character creation started")
-- end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "UseStarted: " .. character .. " " .. item)
    Autosaving.UpdateState("isUsingItem", true)
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    Autosaving.UpdateState("isUsingItem", false)
  end
end

-- function EHandlers.onOpened(ITEMROOT, ITEM, CHARACTER)
-- Utils.DebugPrint(2, "Opened item: " .. item)
-- If in party ...
-- Autosaving.UpdateState("isInContainer", true)
-- end
-- function EHandlers.onClosed()
-- Utils.DebugPrint(2, "onClosed")
--   Autosaving.UpdateState("isInContainer", false)
--
--   -- TODO: ...
-- end

-- Entered and Left Force Turn-Based
function EHandlers.OnEnteredForceTurnBased(object)
  if Object.IsCharacter(object) and Osi.IsInPartyWith(object, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "Entered force turn-based: " .. object)
    Autosaving.UpdateState("isInTurnBased", true)
  end
end

function EHandlers.OnLeftForceTurnBased(object)
  if Object.IsCharacter(object) and Osi.IsInPartyWith(object, GetHostCharacter()) == 1 then
    Utils.DebugPrint(2, "Left force turn-based: " .. object)
    Autosaving.UpdateState("isInTurnBased", false)
  end
end

function EHandlers.OnLevelGameplayStarted(levelName, isEditorMode)
  -- print("OnLevelGameplayStarted called")
  if levelName == 'SYS_CC_I' then
    Autosaving.UpdateState("isInCharacterCreation", true)
  end
end

function EHandlers.OnLevelUnloading(level)
  if level == 'SYS_CC_I' then
    Autosaving.UpdateState("isInCharacterCreation", false)
  end
end

-- Respec Events
function EHandlers.OnRespecCancelled(character)
  Utils.DebugPrint(2, "Character" .. character .. " cancelled respec")
  -- We can't actually use this, since it will break logic for players who respec then use the mirror
  Autosaving.UpdateState("respecEnded", true)
  Autosaving.SaveIfWaiting()
end

function EHandlers.OnRespecCompleted(character)
  Utils.DebugPrint(2, "Character" .. character .. " completed respec")
  -- We can't actually use this, since it will break logic for players who respec then use the mirror
  Autosaving.UpdateState("respecEnded", true)
  Autosaving.SaveIfWaiting()
end

-- TODO:
-- UserEvent
-- function EHandlers.OnUserEvent(userID, userEvent)
--   -- Handler logic for UserEvent
--   Utils.DebugPrint(2, "OnUserEvent called")
--   Utils.DebugPrint(2, "userID:", userID)
--   Utils.DebugPrint(2, "userEvent:", userEvent)
-- end

-- -- Level Loaded
-- function EHandlers.OnLevelLoaded(newLevel)
--   -- Handler logic when a new level is loaded
--   Utils.DebugPrint(2, "OnLevelLoaded called")
--   Utils.DebugPrint(2, "newLevel:", newLevel)
-- end

-- -- Level Template Loaded
-- function EHandlers.OnLevelTemplateLoaded(levelTemplate)
--   -- Handler logic for level template load
--   Utils.DebugPrint(2, "OnLevelTemplateLoaded called")
--   Utils.DebugPrint(2, "levelTemplate:", levelTemplate)
-- end

-- function EHandlers.OnLevelGameplayStarted()
--   -- Handler logic for level template load
--   Utils.DebugPrint(2, "OnLevelGameplayStarted called")
-- end

-- Puzzle UI Events
-- function EHandlers.OnPuzzleUIUsed(character, uIInstance, type, command, elementId)
--   -- Handler logic for puzzle UI use
--   Utils.DebugPrint(2, "OnPuzzleUIUsed called")
--   Utils.DebugPrint(2, "character:", character)
--   Utils.DebugPrint(2, "uIInstance:", uIInstance)
--   Utils.DebugPrint(2, "type:", type)
--   Utils.DebugPrint(2, "command:", command)
--   Utils.DebugPrint(2, "elementId:", elementId)
-- end

-- function EHandlers.OnPuzzleUIClosed(character, uIInstance, type)
--   -- Handler logic when puzzle UI is closed
--   Utils.DebugPrint(2, "OnPuzzleUIClosed called")
--   Utils.DebugPrint(2, "character:", character)
--   Utils.DebugPrint(2, "uIInstance:", uIInstance)
--   Utils.DebugPrint(2, "type:", type)
-- end

-- -- Voice Bark Events
-- function EHandlers.OnVoiceBarkStarted(bark, instanceID)
--   -- Handler logic when a voice bark starts
--   Utils.DebugPrint(2, "OnVoiceBarkStarted called")
--   Utils.DebugPrint(2, "bark:", bark)
--   Utils.DebugPrint(2, "instanceID:", instanceID)
-- end

-- function EHandlers.OnVoiceBarkEnded(bark, instanceID)
--   -- Handler logic when a voice bark ends
--   Utils.DebugPrint(2, "OnVoiceBarkEnded called")
--   Utils.DebugPrint(2, "bark:", bark)
--   Utils.DebugPrint(2, "instanceID:", instanceID)
-- end

-- function EHandlers.OnVoiceBarkFailed(bark)
--   -- Handler logic when a voice bark fails
--   Utils.DebugPrint(2, "OnVoiceBarkFailed called")
--   Utils.DebugPrint(2, "bark:", bark)
-- end

return EHandlers
