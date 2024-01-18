local Autosaving = Ext.Require("Server/autosaving.lua")
local Config = Ext.Require("config.lua")

local EHandlers = {}

local TIMER_NAME = "Volitios_Smart_Autosaving"
local AUTOSAVING_PERIOD = JsonConfig.TIMER.autosaving_period_in_minutes * 60

function EHandlers.StartOrRestartTimer()
  Osi.TimerCancel(TIMER_NAME)
  Osi.TimerLaunch(TIMER_NAME, AUTOSAVING_PERIOD * 1000)
  Autosaving.waitingForAutosave = false
end

-- Handler when the timer finishes
function EHandlers.OnTimerFinished(timer)
  if timer == TIMER_NAME then
    if Autosaving.CanAutosave() then
      Autosaving.Autosave()
      EHandlers.StartOrRestartTimer()
    else -- timer finished but we can't autosave yet, so we'll wait for the next event to try again
      Autosaving.waitingForAutosave = true
    end
  end
end

function EHandlers.OnGameStateChange(e)
  -- Reset the timer if the game state changes to 'Save'
  -- String comparison isn't ideal, but it should be fine for this
  local toStateStr = tostring(e.ToState)
  if toStateStr == 'Save' then
    EHandlers.StartOrRestartTimer()
  end
end

function EHandlers.SavegameLoaded()
  -- Reset the timer when a save is loaded
  EHandlers.StartOrRestartTimer()
end

function EHandlers.OnDialogStart()
  -- Config.DebugPrint(2, "Dialogue started")
  Autosaving.isInDialogue = true
end

function EHandlers.OnDialogEnd()
  -- Config.DebugPrint(2, "Dialogue ended")

  Autosaving.isInDialogue = false;
  Autosaving.HandlePotentialAutosave()
end

function EHandlers.OnTradeStart()
  Autosaving.isInTrade = true
end

function EHandlers.OnTradeEnd()
  Autosaving.isInTrade = false;
  -- Save regardless of dialogue state
  Autosaving.SaveIfWaiting()
end

function EHandlers.OnCombatStart()
  Autosaving.isInCombat = true
end

-- I didn't manage to get this to work, so I'm using TurnEnded instead
-- function EHandlers.onCombatRoundStarted()
--     Autosaving.combatTurnEnded = true
--     Autosaving.HandlePotentialAutosave()
-- end
function EHandlers.OnCombatEnd()
  Autosaving.isInCombat = false;
  Autosaving.HandlePotentialAutosave()
end

function EHandlers.OnTurnEnded(char)
  -- Potentially save if the turn ended for the avatar or party member (this should not trigger multiplayer or summons)
  if Osi.IsInPartyWith(char, GetHostCharacter()) == 1 then
    Autosaving.combatTurnEnded = true
    Autosaving.HandlePotentialAutosave()
  end
end

function EHandlers.OnLockpickingStart()
  Autosaving.isLockpicking = true
end

function EHandlers.OnLockpickingEnd()
  Autosaving.isLockpicking = false;
  Autosaving.HandlePotentialAutosave()
end

-- This might cause problems if the target is 'owned' (has red highlight)
function EHandlers.onRequestCanLoot(looter, target)
  -- Config.DebugPrint(2, "RequestCanLoot: " .. looter .. " " .. target)
  -- print("RequestCanLoot: " .. looter .. " " .. target)
  Autosaving.isLootingCharacter = true
end

function EHandlers.onCharacterLootedCharacter(player, lootedCharacter)
  -- Config.DebugPrint(2, "CharacterLootedCharacter")
  -- print("CharacterLootedCharacter: " .. player .. " " .. lootedCharacter)
  Autosaving.isLootingCharacter = false
end

-- WIP/looking for means of detection
-- function EHandlers.OnCharacterCreationStart()
    -- Config.DebugPrint(2, "Character creation started")
-- end

function EHandlers.OnUseStarted(character, item)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    -- Config.DebugPrint(2, "UseStarted: " .. character .. " " .. item)
    -- print("UseStarted: " .. character .. " " .. item)
    Autosaving.isUsingItem = true
    -- TODO: ...
  end
end

function EHandlers.OnUseEnded(character, item, result)
  if Osi.IsInPartyWith(character, GetHostCharacter()) == 1 then
    -- Config.DebugPrint(2, "UseEnded: " .. character .. " " .. item .. " " .. result)
    -- print("UseEnded: " .. character .. " " .. item .. " " .. result)
    Autosaving.isUsingItem = false
    Autosaving.HandlePotentialAutosave()
  end
end

-- function EHandlers.onOpened(item)
  -- Config.DebugPrint(2, "Opened item: " .. item)
  -- print("Opened item: " .. item)
--   Autosaving.isInContainer = true
--   -- TODO: ...
-- end

-- function EHandlers.onClosed()
  -- Config.DebugPrint(2, "onClosed")
  -- print("onClosed")
--   Autosaving.isInContainer = false
--   Autosaving.HandlePotentialAutosave()
--   -- TODO: ...
-- end

return EHandlers