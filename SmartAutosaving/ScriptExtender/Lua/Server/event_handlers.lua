local Autosaving = Ext.Require("Server/autosaving.lua")
local Config = Ext.Require("Server/config_utils.lua")

local EHandlers = {}

local TIMER = "Volitios_Smart_Autosaving"
local AUTOSAVING_PERIOD = Config.jsonConfig.autosaving_period_in_minutes -- * 60

function EHandlers.StartOrRestartTimer()
  Osi.TimerCancel(TIMER)
  Osi.TimerLaunch(TIMER, AUTOSAVING_PERIOD * 1000)
  Autosaving.waitingForAutosave = false
end

-- Handler when the timer finishes
function EHandlers.OnTimerFinished(timer)
  if timer == TIMER then
      if Autosaving.CanAutosave() then
        Autosaving.Autosave()
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
  print("Dialogue started")
  Autosaving.isInDialogue = true
end
function EHandlers.OnDialogEnd()
  print("Dialogue ended")

  Autosaving.isInDialogue = false;
  Autosaving.HandlePotentialAutosave()
end

function EHandlers.OnTradeStart()
  Autosaving.isInTrade = true
end
function EHandlers.OnTradeEnd()
  Autosaving.isInTrade = false;
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
  if Osi.IsInPartyWith(char) then
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

function EHandlers.onCharacterLootedCharacter()
  print("CharacterLootedCharacter")
end

-- TODO:
  -- function EHandlers.OnCharacterCreationStart()
--     print("Character creation started")
-- end

-- function EHandlers.OnUseStarted(character, item)
--     if (Utils.IsInPartyWith(character)) then
--         print("UseStarted: " .. character .. " " .. item)
--     end
-- end
-- function EHandlers.OnUseEnded(character, item, result)
--     if (Utils.IsInPartyWith(character)) then
--         print("UseEnded: " .. character .. " " .. item .. " " .. result)
--     end
-- end
-- function EHandlers.onOpened(item)
--     print("Opened item: " .. item)
-- end

-- function EHandlers.onClosed()
--     print("onClosed")
-- end

return EHandlers
