Autosaving = {}

Autosaving.TIMER_NAME = "Volitios_Smart_Autosaving"

-- Initialize the guard flag to prevent recursive event handling
local isAdjustingSettings = false

-- Define pairs of maximum and current save settings
local saveSettingsPairs = {
    {
        maxSettingId = "max_nr_of_autosaves",
        currentSettingId = "nr_of_autosaves",
    },
    {
        maxSettingId = "max_nr_of_quicksaves",
        currentSettingId = "nr_of_quicksaves",
    }
}

-- Helper function to handle boundary checks and adjustments
local function HandleSettingChange(pair, changedSettingId, changedValue)
    if not MCM.Get("override_vanilla_limits") then return end

    local maxSettingId = pair.maxSettingId
    local currentSettingId = pair.currentSettingId

    -- Retrieve current values
    local maxValue = MCM.Get(maxSettingId)
    local currentValue = MCM.Get(currentSettingId)

    -- Initialize a table to track changes for logging
    local changes = {}

    if changedSettingId == maxSettingId then
        -- If maximum was changed, ensure current does not exceed new maximum
        if currentValue > changedValue then
            changes[currentSettingId] = changedValue
        end
    elseif changedSettingId == currentSettingId then
        -- If current was changed, ensure maximum is not less than current
        if changedValue > maxValue then
            changes[maxSettingId] = changedValue
        end
    end

    -- Apply necessary boundary adjustments
    for settingId, newValue in pairs(changes) do
        local existingValue = MCM.Get(settingId)
        if existingValue ~= newValue then
            MCM.Set(settingId, newValue)
            SADebug(1, "Adjusting '" .. settingId .. "' to " .. tostring(newValue))
        end
    end

    -- Update global switches after adjustments
    local globalSwitches = Ext.Utils.GetGlobalSwitches()
    globalSwitches.NrOfAutoSaves = MCM.Get("nr_of_autosaves")
    globalSwitches.MaxNrOfAutoSaves = MCM.Get("max_nr_of_autosaves")
    globalSwitches.NrOfQuickSaves = MCM.Get("nr_of_quicksaves")
    globalSwitches.MaxNrOfQuickSaves = MCM.Get("max_nr_of_quicksaves")
end

-- Listener to handle setting changes and ensure consistency between current and max values
Ext.ModEvents.BG3MCM['MCM_Setting_Saved']:Subscribe(function(payload)
    -- Validate payload
    if not payload or payload.modUUID ~= ModuleUUID or not payload.settingId then
        return
    end

    -- If settings are being adjusted programmatically, skip processing to prevent recursion
    if isAdjustingSettings then
        SADebug(2, "Settings adjustment in progress. Ignoring event for settingId: " .. payload.settingId)
        return
    end

    if payload.settingId == "override_vanilla_limits" then Autosaving.ApplyInitialSavingSettings() end

    -- Iterate through each settings pair to find if the changed setting belongs to any pair
    for _, pair in ipairs(saveSettingsPairs) do
        if payload.settingId == pair.maxSettingId or payload.settingId == pair.currentSettingId then
            -- Set the guard flag to indicate programmatic adjustments are in progress
            isAdjustingSettings = true

            -- Handle the setting change
            HandleSettingChange(pair, payload.settingId, payload.value)

            -- Reset the guard flag after adjustments are complete
            isAdjustingSettings = false

            -- Since the changed setting belongs to this pair, no need to check other pairs
            break
        end
    end
end)

-- Function to apply initial boundary checks during mod initialization
function Autosaving.ApplyInitialSavingSettings()
    if not MCM.Get("override_vanilla_limits") then return end

    isAdjustingSettings = true

    for _, pair in ipairs(saveSettingsPairs) do
        local maxValue = MCM.Get(pair.maxSettingId)
        local currentValue = MCM.Get(pair.currentSettingId)

        -- Check if current exceeds max and adjust if necessary
        if currentValue > maxValue then
            MCM.Set(pair.maxSettingId, pair.currentSettingId)
            SADebug(1, "Initial adjustment: '" .. pair.maxSettingId .. "' set to " .. tostring(currentValue))
        end
    end

    -- Update global switches based on validated settings
    local globalSwitches = Ext.Utils.GetGlobalSwitches()
    for _, pair in ipairs(saveSettingsPairs) do
        local updatedMax = MCM.Get(pair.maxSettingId)
        local updatedCurrent = MCM.Get(pair.currentSettingId)

        if pair.maxSettingId == "max_nr_of_autosaves" then
            globalSwitches.NrOfAutoSaves = updatedCurrent
            globalSwitches.MaxNrOfAutoSaves = updatedMax
        elseif pair.maxSettingId == "max_nr_of_quicksaves" then
            globalSwitches.NrOfQuickSaves = updatedCurrent
            globalSwitches.MaxNrOfQuickSaves = updatedMax
        end
    end

    isAdjustingSettings = false
end

function Autosaving.CheckGameAutosavingSettings()
    if not Ext.Net.IsHost() then return end
    local globalSwitches = Ext.Utils.GetGlobalSwitches()
    if globalSwitches == nil then return end

    xpcall(function()
        Autosaving.ApplyInitialSavingSettings()

        if globalSwitches["CanAutoSave"] ~= true then
            Ext.Utils.GetGlobalSwitches().CanAutoSave = true
            SAWarn(0,
                "Autosaving was disabled in the game settings and has been re-enabled, as it is required for Smart Autosaving.")
        end
    end, function(err)
        SAWarn(0, "Error while checking or enabling autosaving: " .. tostring(err))
    end)

    if globalSwitches["MaxNrOfAutoSaves"] < 10 then
        SAWarn(1,
            "The maximum number of autosaves is set to " ..
            globalSwitches["MaxNrOfAutoSaves"] ..
            ".\nIt is recommended to set it to at least 10 to use Smart Autosaving.")
    end
end

function Autosaving.GetAutosavingPeriod()
    local autosavingPeriodInMinutes = MCM.Get("autosaving_period_in_minutes")
    if MCM.Get("timer_in_seconds") then
        return autosavingPeriodInMinutes
    else
        return autosavingPeriodInMinutes * 60
    end
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

    isUsingInventory = false,

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

    if Autosaving.states[state] == value then
        SADebug(1, "State " .. state .. " is already " .. tostring(value))
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
    local idlePostponed = MCM.Get("postpone_on_idle")
    local statesChanged = Autosaving.HasStatesChanged()

    if not idlePostponed or statesChanged then
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
---@return boolean
function Autosaving.ShouldDialogueBlockSaving()
    if MCM.Get("postpone_on_dialogue") == true then
        local entity = Ext.Entity.Get(Osi.GetHostCharacter())
        local success, inDialog = xpcall(function()
            return entity.ServerCharacter.Flags.InDialog
        end, function(err)
            SAWarn(1, "Error checking dialogue block: " .. tostring(err))
            return false
        end)
        return success and inDialog
    end
    return false
end

--- Checks if combat should block saving by checking if player is in combat.
-- Only used if the corresponding option is enabled in the config JSON file.
function Autosaving.ShouldCombatBlockSaving()
    if MCM.Get("postpone_on_combat") == true then
        return Osi.IsInCombat(Osi.GetHostCharacter()) == 1
    end
    return false
end

-- function Autosaving.ShouldInventoryBlockSaving()
--     if MCM.Get("postpone_on_inventory") == true then
--         return Autosaving.states.isUsingInventory
--     end
--     return false
-- end

function Autosaving.ShouldMovementBlockSaving()
    if MCM.Get("postpone_on_movement") == true then
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
    SAPrint(2, "Starting or restarting timer to " .. tostring(Autosaving.GetAutosavingPeriod() * 1000) .. "ms")
    Osi.TimerCancel(Autosaving.TIMER_NAME)
    Osi.TimerLaunch(Autosaving.TIMER_NAME, Autosaving.GetAutosavingPeriod() * 1000)
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

function Autosaving.CanAutosaveServerSide()
    local isRespeccingOrUsingMirror = Autosaving.ProxyIsUsingRespecOrMirror() -- and not Autosaving.states.respecEnded

    -- These checks ensure that players loading a save in combat or dialogue will not autosave (if the corresponding options are set to true)
    -- We could just use this instead of listening to the events, but most logic is done through events (which is also more efficient)
    local combatCheck = Autosaving.ShouldCombatBlockSaving()
    local dialogueCheck = Autosaving.ShouldDialogueBlockSaving()
    local movementCheck = Autosaving.ShouldMovementBlockSaving()
    local inventoryCheck = false --Autosaving.ShouldInventoryBlockSaving()

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
        not inventoryCheck and
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
    if Autosaving.states.waitingForAutosave and Autosaving.CanAutosaveServerSide() then
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
function Autosaving.CheckClientSide()
    if Ext.IsServer() then
        Ext.Net.BroadcastMessage("SA_CheckClientSide", Ext.Json.Stringify({}))
    end
end

return Autosaving
