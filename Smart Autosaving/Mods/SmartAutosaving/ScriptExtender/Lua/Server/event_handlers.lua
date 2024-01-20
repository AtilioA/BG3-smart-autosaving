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
  -- Config.DebugPrint(2, "Dialogue started")
  -- entity = Ext.Entity.Get(Osi.GetHostCharacter())
  -- Ext.IO.SaveFile('character-entity.json', Ext.DumpExport(entity:GetAllComponents()))
  -- print(entity:GetAllComponents().ServerCharacter)

  Autosaving.UpdateState("isInDialogue", true)
end

function EHandlers.OnDialogEnd()
  -- Config.DebugPrint(2, "Dialogue ended")

  Autosaving.UpdateState("isInDialogue", false)
end

function EHandlers.OnTradeStart()
  Autosaving.UpdateState("isInTrade", true)
end

function EHandlers.OnTradeEnd()
  Autosaving.UpdateState("isInTrade", false)
  -- Save regardless of dialogue state
  Autosaving.SaveIfWaiting()
end

function EHandlers.OnCombatStart()
  Autosaving.UpdateState("isInCombat", true)
end

-- I didn't manage to get this to work, so I'm using TurnEnded instead
-- function EHandlers.onCombatRoundStarted()
--     Autosaving.UpdateState("combatTurnEnded", true)
--
-- end
function EHandlers.OnCombatEnd()
  Autosaving.UpdateState("isInCombat", false)
end

function EHandlers.OnTurnEnded(char)
  -- Potentially save if the turn ended for the avatar or party member (this should not trigger multiplayer or summons)
  if Osi.IsInPartyWith(char, GetHostCharacter()) == 1 then
    -- Autosaving.UpdateState("isInCombat", true -- hacky way to 'initialize' it if player loads into combat)
    Autosaving.UpdateState("combatTurnEnded", true)
  end
end

function EHandlers.OnLockpickingStart()
  Autosaving.UpdateState("isLockpicking", true)
end

function EHandlers.OnLockpickingEnd()
  Autosaving.UpdateState("isLockpicking", false)
end

-- This might cause problems if the target is 'owned' (has red highlight)
function EHandlers.onRequestCanLoot(looter, target)
  -- Config.DebugPrint(2, "RequestCanLoot: " .. looter .. " " .. target)
  print("RequestCanLoot: " .. looter .. " " .. target)
  Autosaving.UpdateState("isLootingCharacter", true)
end

function EHandlers.onCharacterLootedCharacter(player, lootedCharacter)
  -- Config.DebugPrint(2, "CharacterLootedCharacter")
  print("CharacterLootedCharacter: " .. player .. " " .. lootedCharacter)
  Autosaving.UpdateState("isLootingCharacter", false)
end

-- WIP/looking for means of detection
-- function EHandlers.OnCharacterCreationStart()
-- Config.DebugPrint(2, "Character creation started")
-- end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    -- Config.DebugPrint(2, "UseStarted: " .. character .. " " .. item)
    -- print("UseStarted: " .. character .. " " .. item)
    Autosaving.UpdateState("isUsingItem", true)
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    -- Config.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    -- print("UseEnded: " .. character .. " " .. item .. " " .. result)
    Autosaving.UpdateState("isUsingItem", false)
  end
end

-- function EHandlers.onOpened(ITEMROOT, ITEM, CHARACTER)
-- Config.DebugPrint(2, "Opened item: " .. item)
-- print("Opened (template): ")
-- If in party ...
-- Autosaving.UpdateState("isInContainer", true)
-- end
-- function EHandlers.onClosed()
-- Config.DebugPrint(2, "onClosed")
-- print("onClosed")
--   Autosaving.UpdateState("isInContainer", false)
--
--   -- TODO: ...
-- end

-- Entered and Left Force Turn-Based
function EHandlers.OnEnteredForceTurnBased(object)
  if Object.IsCharacter(object) and Osi.IsInPartyWith(object, GetHostCharacter()) == 1 then
    Autosaving.UpdateState("isInTurnBased", true)
  end
end

function EHandlers.OnLeftForceTurnBased(object)
  if Object.IsCharacter(object) and Osi.IsInPartyWith(object, GetHostCharacter()) == 1 then
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
    -- print("Character creation ended")
    Autosaving.UpdateState("isInCharacterCreation", false)
  end
end

-- Respec Events
function EHandlers.OnRespecCancelled(character)
  Autosaving.UpdateState("respecEnded", true)
end

function EHandlers.OnRespecCompleted(character)
  Autosaving.UpdateState("respecEnded", true)
end

-- TODO:
-- UserEvent
-- function EHandlers.OnUserEvent(userID, userEvent)
--   -- Handler logic for UserEvent
--   print("OnUserEvent called")
--   print("userID:", userID)
--   print("userEvent:", userEvent)
-- end

-- -- Level Loaded
-- function EHandlers.OnLevelLoaded(newLevel)
--   -- Handler logic when a new level is loaded
--   print("OnLevelLoaded called")
--   print("newLevel:", newLevel)
-- end

-- -- Level Template Loaded
-- function EHandlers.OnLevelTemplateLoaded(levelTemplate)
--   -- Handler logic for level template load
--   print("OnLevelTemplateLoaded called")
--   print("levelTemplate:", levelTemplate)
-- end

-- function EHandlers.OnLevelGameplayStarted()
--   -- Handler logic for level template load
--   print("OnLevelGameplayStarted called")
-- end

-- Puzzle UI Events
-- function EHandlers.OnPuzzleUIUsed(character, uIInstance, type, command, elementId)
--   -- Handler logic for puzzle UI use
--   print("OnPuzzleUIUsed called")
--   print("character:", character)
--   print("uIInstance:", uIInstance)
--   print("type:", type)
--   print("command:", command)
--   print("elementId:", elementId)
-- end

-- function EHandlers.OnPuzzleUIClosed(character, uIInstance, type)
--   -- Handler logic when puzzle UI is closed
--   print("OnPuzzleUIClosed called")
--   print("character:", character)
--   print("uIInstance:", uIInstance)
--   print("type:", type)
-- end

-- -- Voice Bark Events
-- function EHandlers.OnVoiceBarkStarted(bark, instanceID)
--   -- Handler logic when a voice bark starts
--   print("OnVoiceBarkStarted called")
--   print("bark:", bark)
--   print("instanceID:", instanceID)
-- end

-- function EHandlers.OnVoiceBarkEnded(bark, instanceID)
--   -- Handler logic when a voice bark ends
--   print("OnVoiceBarkEnded called")
--   print("bark:", bark)
--   print("instanceID:", instanceID)
-- end

-- function EHandlers.OnVoiceBarkFailed(bark)
--   -- Handler logic when a voice bark fails
--   print("OnVoiceBarkFailed called")
--   print("bark:", bark)
-- end

return EHandlers
