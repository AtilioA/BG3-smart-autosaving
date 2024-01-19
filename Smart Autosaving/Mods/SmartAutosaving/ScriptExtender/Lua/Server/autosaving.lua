local Config = Ext.Require("config.lua")
local Autosaving = {}

-- State tracking variables
-- These will never be set to true if the corresponding event is disabled in the config
Autosaving.isInDialogue = false
Autosaving.isInTrade = false

Autosaving.isInTurnBased = false
Autosaving.isInCombat = false
Autosaving.combatTurnEnded = false

Autosaving.isUsingItem = false
-- Autosaving.isInContainer = false
Autosaving.isLootingCharacter = false

Autosaving.isLockpicking = false

Autosaving.isInCharacterCreation = false

Autosaving.respecEnded = false

Autosaving.waitingForAutosave = false

function Autosaving.Autosave()
  Osi.AutoSave()
  print("Smart Autosaving: Game saved")
  Autosaving.waitingForAutosave = false
end

function Autosaving.ShouldCombatBlockSaving()
  if JsonConfig.EVENTS.combat == true then
    return Osi.IsInCombat(GetHostCharacter()) == 1
  end
  return false
end

function Autosaving.ProxyIsUsingRespecOrMirror()
  -- Does not work
  -- local rows = Osi.DB_InCharacterRespec:Get(nil, nil)

  -- If entity has CCState, use HasDummy. If it doesn't, it is still on character creation, so return true
  local respecProxy = false
  if entity.CCState then
    respecProxy = entity.CCState.HasDummy
  else
    respecProxy = true
  end


  -- print("Is respeccing or using mirror? " .. tostring(respecProxy))

  return respecProxy
end

function Autosaving.CanAutosave()
  local isRespeccingOrUsingMirror = Autosaving.ProxyIsUsingRespecOrMirror() and not Autosaving.respecEnded
  local combatCheck = Autosaving.ShouldCombatBlockSaving()

  local notInAnyBlockingState = not Autosaving.isInDialogue and
      not Autosaving.isInCombat and
      not Autosaving.isLockpicking and
      not Autosaving.isInTurnBased and
      not Autosaving.isInTrade and
      not Autosaving.isUsingItem and
      not Autosaving.isInCharacterCreation and
      not combatCheck and
      not isRespeccingOrUsingMirror

  return (Autosaving.combatTurnEnded or notInAnyBlockingState)
end

-- Handlers to update states and check for delayed autosave
-- Function to handle potential autosave after actions
function Autosaving.HandlePotentialAutosave()
  -- Do not autosave if the states are true, even if we're waiting for an autosave
  if Autosaving.waitingForAutosave and Autosaving.CanAutosave() then
    Autosaving.Autosave()
  end
  -- Set this to false regardless; if we're in combat, we'll set it to true again when a new round ends
  Autosaving.combatTurnEnded = false
end

function Autosaving.SaveIfWaiting()
  if Autosaving.waitingForAutosave then
    Autosaving.Autosave()
  end
end

return Autosaving
