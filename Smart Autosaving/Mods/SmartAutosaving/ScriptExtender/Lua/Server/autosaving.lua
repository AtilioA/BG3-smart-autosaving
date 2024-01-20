Autosaving = {}

Autosaving.TIMER_NAME = "Volitios_Smart_Autosaving"
Autosaving.AUTOSAVING_PERIOD = JsonConfig.TIMER.autosaving_period_in_minutes

-- State tracking variables
-- These would never be set to true if the corresponding event is disabled in the config
Autosaving.states = {
  isInDialogue = false,
  isInTrade = false,

  isInTurnBased = false,
  isInCombat = false,
  combatTurnEnded = false,

  isUsingItem = false,
  -- isInContainer = false,
  isLootingCharacter = false,

  isLockpicking = false,

  isInCharacterCreation = false,

  respecEnded = false,

  waitingForAutosave = false,
}

function Autosaving.UpdateState(state, value)
  -- Check if 'value' is a boolean
  if type(value) ~= "boolean" then
    error("Value must be a boolean")
    return
  end

  -- Check if 'state' is a valid key in 'Autosaving.states'
  if Autosaving.states[state] == nil then
    error("Invalid state: " .. tostring(state))
    return
  end

  -- Update the state
  Autosaving.states[state] = value

  -- Handle potential autosaves if player leaves a state
  -- print(value)
  if value == false then
    Autosaving.HandlePotentialAutosave()
  end
end

function Autosaving.Autosave()
  Osi.AutoSave()
  print("Smart Autosaving: Game saved")
  Autosaving.UpdateState("waitingForAutosave", false)
end

function Autosaving.ShouldDialogueBlockSaving()
  if JsonConfig.EVENTS.dialogue == true then
    local entity = Ext.Entity.Get(Osi.GetHostCharacter())
    return entity.ServerCharacter.Flags.InDialog
  end
  return false
end

function Autosaving.ShouldCombatBlockSaving()
  if JsonConfig.EVENTS.combat == true then
    return Osi.IsInCombat(GetHostCharacter()) == 1
  end
  return false
end

function Autosaving.StartOrRestartTimer()
  Osi.TimerCancel(Autosaving.TIMER_NAME)
  Osi.TimerLaunch(Autosaving.TIMER_NAME, Autosaving.AUTOSAVING_PERIOD * 1000)
  Autosaving.UpdateState("waitingForAutosave", false)
end

function Autosaving.ProxyIsUsingRespecOrMirror()
  -- Does not seem to work:
  -- local rows = Osi.DB_InCharacterRespec:Get(nil, nil)

  -- So let's use a proxy for that:
  -- If entity has CCState, use HasDummy. If it doesn't, it is still on character creation, so return true
  local respecProxy = false
  local entity = Ext.Entity.Get(Osi.GetHostCharacter())
  if entity.CCState then
    respecProxy = entity.CCState.HasDummy
  else
    respecProxy = true
  end

  -- print("Is respeccing or using mirror? " .. tostring(respecProxy))

  return respecProxy
end

function Autosaving.CanAutosave()
  local isRespeccingOrUsingMirror = Autosaving.ProxyIsUsingRespecOrMirror() and not Autosaving.states.respecEnded

  -- These checks ensure that players loading a save in combat or dialogue will not autosave (if the corresponding options are set to true)
  -- We could just use this instead of listening to the events, but most logic is done through events (which is also more efficient)
  local combatCheck = Autosaving.ShouldCombatBlockSaving()
  local dialogueCheck = Autosaving.ShouldDialogueBlockSaving()

  local notInAnyBlockingState = not Autosaving.states.isInDialogue and
      not Autosaving.states.isInCombat and
      not Autosaving.states.isLockpicking and
      not Autosaving.states.isInTurnBased and
      not Autosaving.states.isInTrade and
      not Autosaving.states.isUsingItem and
      not Autosaving.states.isInCharacterCreation and
      not combatCheck and
      not dialogueCheck and
      not isRespeccingOrUsingMirror

  return (Autosaving.states.combatTurnEnded or notInAnyBlockingState)
end

-- Handlers to update states and check for delayed autosave
-- Function to handle potential autosave after actions
function Autosaving.HandlePotentialAutosave()
  -- Do not autosave if the states are true, even if we're waiting for an autosave
  if Autosaving.states.waitingForAutosave and Autosaving.CanAutosave() then
    Autosaving.Autosave()
  end
  -- Set this to false regardless; if we're in combat, we'll set it to true again when a new round ends
  -- Also don't use the function to update the state to avoid recursion
  Autosaving.combatTurnEnded = false
end

function Autosaving.SaveIfWaiting()
  if Autosaving.states.waitingForAutosave then
    Autosaving.Autosave()
  end
end

return Autosaving
