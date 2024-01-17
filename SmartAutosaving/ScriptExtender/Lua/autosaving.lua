local jsonConfig = Ext.Json.Parse(Ext.IO.LoadFile("config.json"))

local TIMER = "Volitios_Smart_Autosaving"
local AUTOSAVING_PERIOD = jsonConfig.AUTOSAVING_PERIOD

local Autosaving = {}

-- State tracking variables
-- These will never be set to true if the corresponding event is disabled in the config
Autosaving.isInDialogue = false
Autosaving.isInTrade = false
Autosaving.isInCombat = false
Autosaving.isLockpicking = false
Autosaving.waitingForAutosave = false
Autosaving.combatTurnEnded = false

-- Function to start or restart the timer
function Autosaving.StartOrRestartTimer()
  Osi.TimerCancel(TIMER)
  Osi.TimerLaunch(TIMER, AUTOSAVING_PERIOD * 1000)
  Autosaving.waitingForAutosave = false
end

function Autosaving.Autosave()
  Osi.AutoSave()
  print("Smart Autosaving: Game saved")
  Autosaving.waitingForAutosave = false
  Autosaving.StartOrRestartTimer()
end

function Autosaving.CanAutosave()
  -- We can autosave if we're at the start of a combat round, or if we're not in combat, dialogue, lockpicking or trading
  return Autosaving.combatTurnEnded or (not Autosaving.isInDialogue and not Autosaving.isInCombat and not Autosaving.isLockpicking and not Autosaving.isInTrade)
end


-- Handlers to update states and check for delayed autosave
-- Function to handle potential autosave after actions
function Autosaving.HandlePotentialAutosave()
  -- Do not autosave if the states are true, even if we're waiting for an autosave
  if Autosaving.waitingForAutosave and Autosaving.CanAutosave() then
    Autosaving.Autosave()
      -- Set this to false regardless; if we're in combat, we'll set it to true again when a new round ends
      Autosaving.combatTurnEnded = false
  end
end

function Autosaving.SaveIfWaiting()
  if Autosaving.waitingForAutosave then
    Autosaving.Autosave()
  end
end

-- Handler when the timer finishes
function Autosaving.OnTimerFinished(timer)
  if timer == TIMER then
      if Autosaving.CanAutosave() then
        Autosaving.Autosave()
      else -- timer finished but we can't autosave yet, so we'll wait for the next event to try again
          Autosaving.waitingForAutosave = true
      end
  end
end

return Autosaving
