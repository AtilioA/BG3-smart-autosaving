local Autosaving = {}

-- State tracking variables
-- These will never be set to true if the corresponding event is disabled in the config
Autosaving.isInDialogue = false
Autosaving.isInTrade = false

Autosaving.isLootingCharacter = false
-- Autosaving.isInContainer = false
Autosaving.isUsingItem = false
Autosaving.isLockpicking = false

Autosaving.combatTurnEnded = false

Autosaving.waitingForAutosave = false

function Autosaving.Autosave()
  Osi.AutoSave()
  print("Smart Autosaving: Game saved")
  Autosaving.waitingForAutosave = false
end

-- TODO: fix combat detection (i.e. when loading into combat)
function Autosaving.CanAutosave()
  -- We can autosave if we're at the start of a combat round, or if none of the other states are true
  return Autosaving.combatTurnEnded or (not Autosaving.isInDialogue and
    not Autosaving.isInCombat and
    not Autosaving.isLockpicking and
    not Autosaving.isInTrade and
    -- not Autosaving.isInContainer and
    not Autosaving.isUsingItem)
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
