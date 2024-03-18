Autosaving = {}

Autosaving.TIMER_NAME = "Volitios_Smart_Autosaving"

Autosaving.AUTOSAVING_PERIOD = Config:getCfg().FEATURES.TIMER.autosaving_period_in_minutes * 60
if Config:getCfg().DEBUG.timer_in_seconds then
  Autosaving.AUTOSAVING_PERIOD = Config:getCfg().FEATURES.TIMER.autosaving_period_in_minutes
end

-- State tracking variables
-- These would never be set to true if the corresponding event is disabled in the config
Autosaving.states = {
  isInDialogue = false,
  isInTrade = false,

  isInTurnBased = false,
  isInCombat = false,
  combatTurnEnded = false,

  isUsingItem = false,
  isLootingCharacter = false,

  isLockpicking = false,

  isInCharacterCreation = false,

  respecEnded = false,

  waitingForAutosave = false,
}

Autosaving.changedStates = {}

-- Function to check if any state has changed
function Autosaving.HasStatesChanged()
  for state, value in pairs(Autosaving.states) do
    if Autosaving.changedStates[state] == true and state ~= "waitingForAutosave" then
      SAPrint(2, "State " .. state .. " has changed: " .. tostring(Autosaving.changedStates[state]))
      return true
    end
  end
  return false
end

-- Function to copy current states to changedStates
function Autosaving.ResetChangedStates()
  for state, value in pairs(Autosaving.states) do
    Autosaving.changedStates[state] = false
  end
end

Autosaving.ResetChangedStates()

--- Updates the state of Autosaving
--- @param state string The key of `states` to update (e.g., 'isInDialogue', 'isInTrade', ...)
--- @param value boolean The new value for the state
--- @return nil
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
  Autosaving.changedStates[state] = true

  -- Handle potential autosaves if player leaves a state
  -- print(value)
  if value == false then
    SAPrint(2, "State " .. state .. " has changed to false, checking for potential autosave")
    Autosaving.HandlePotentialAutosave()
  end
end

--- Executes an autosave operation.
--- Calls the Osi.AutoSave() function to save the game.
--- Prints a debug message indicating that the game has been saved.
--- Updates the state of the autosaving process.
--- Restarts the autosave timer for the next autosave attempt.
function Autosaving.Autosave()
  -- Check if idle detection is enabled and if any state has changed since the last autosave
  if not Config:getCfg().FEATURES.POSTPONEMENTS.idle or Autosaving.HasStatesChanged() then
    Osi.AutoSave()
    SAPrint(0, "Game saved")
    Autosaving.UpdateState("waitingForAutosave", false)
    Autosaving.ResetChangedStates()
    -- Autosaving.StartOrRestartTimer()
  else
    SAPrint(0, "Idle detection active: no significant activity, skipping autosave")
    Autosaving.UpdateState("waitingForAutosave", true)
  end
end

--- Checks if dialogue should block saving by checking if player is in dialogue.
-- Only used if the corresponding option is enabled in the config JSON file.
function Autosaving.ShouldDialogueBlockSaving()
  if Config:getCfg().FEATURES.POSTPONEMENTS.dialogue == true then
    local entity = Ext.Entity.Get(Osi.GetHostCharacter())
    return entity.ServerCharacter.Flags.InDialog
  end
  return false
end

--- Checks if combat should block saving by checking if player is in combat.
-- Only used if the corresponding option is enabled in the config JSON file.
function Autosaving.ShouldCombatBlockSaving()
  if Config:getCfg().FEATURES.POSTPONEMENTS.combat == true then
    return Osi.IsInCombat(Osi.GetHostCharacter()) == 1
  end
  return false
end

function Autosaving.ShouldMovementBlockSaving()
  if Config:getCfg().FEATURES.POSTPONEMENTS.movement == true then
    local partyMemberMoving = Utils.IsAnyPartyMemberMoving()
    if partyMemberMoving then
      SAPrint(2, partyMemberMoving.CharacterCreationStats.Name .. " is moving")
      return true
    else
      return false
    end
  end
  return false
end

function Autosaving.StartOrRestartTimer()
  SAPrint(2, "Starting or restarting timer to " .. tostring(Autosaving.AUTOSAVING_PERIOD * 1000) .. "ms")
  Osi.TimerCancel(Autosaving.TIMER_NAME)
  Osi.TimerLaunch(Autosaving.TIMER_NAME, Autosaving.AUTOSAVING_PERIOD * 1000)
  -- Autosaving.UpdateState("waitingForAutosave", false)
end

function Autosaving.ProxyIsUsingRespecOrMirror()
  -- Neither seem to work:
  -- local rows = Osi.DB_InCharacterRespec:Get(nil, nil)
  -- local rows2 = Osi.DB_RelaunchCharacterRespec:Get(nil)

  -- So let's use a proxy for that:
  -- If entity has CCState, use HasDummy. If it doesn't, it is still on character creation, so return true
  local respecProxy = false
  local entity = Utils.GetPlayerEntity()
  if entity.CCState then
    respecProxy = entity.CCState.HasDummy
  else
    respecProxy = true
  end

  SAPrint(3, "Is respeccing or using mirror? " .. tostring(respecProxy))

  return respecProxy
end

function Autosaving.CanAutosave()
  local isRespeccingOrUsingMirror = Autosaving.ProxyIsUsingRespecOrMirror() -- and not Autosaving.states.respecEnded

  -- These checks ensure that players loading a save in combat or dialogue will not autosave (if the corresponding options are set to true)
  -- We could just use this instead of listening to the events, but most logic is done through events (which is also more efficient)
  local combatCheck = Autosaving.ShouldCombatBlockSaving()
  local dialogueCheck = Autosaving.ShouldDialogueBlockSaving()
  local movementCheck = Autosaving.ShouldMovementBlockSaving()

  local notInAnyBlockingState = not Autosaving.states.isInDialogue and
      -- not Autosaving.states.isInCombat and -- Temporarily disabled since this event does not check players involved in combat
      not Autosaving.states.isLockpicking and
      not Autosaving.states.isInTurnBased and
      not Autosaving.states.isInTrade and
      not Autosaving.states.isUsingItem and
      not Autosaving.states.isInCharacterCreation and
      not Autosaving.states.isLootingCharacter and
      not combatCheck and
      not dialogueCheck and
      not movementCheck and
      not isRespeccingOrUsingMirror

  return (Autosaving.states.combatTurnEnded or notInAnyBlockingState)
end

-- Handlers to update states and check for delayed autosave
-- Function to handle potential autosave after actions
function Autosaving.HandlePotentialAutosave()
  -- Do not autosave if the states are true, even if we're waiting for an autosave
  -- SAPrint(2,
  --   "Checking if we should autosave: " ..
  --   tostring(Autosaving.states.waitingForAutosave) .. " and " .. tostring(Autosaving.CanAutosave()))
  if Autosaving.states.waitingForAutosave and Autosaving.CanAutosave() then
    Autosaving.Autosave()
  end
  -- Set this to false regardless; if we're in combat, we'll set it to true again when a new round ends
  -- Also don't use the function to update the state to avoid recursion
  Autosaving.states.combatTurnEnded = false
end

function Autosaving.SaveIfWaiting()
  if Autosaving.states.waitingForAutosave then
    Autosaving.Autosave()
  end
end

return Autosaving
