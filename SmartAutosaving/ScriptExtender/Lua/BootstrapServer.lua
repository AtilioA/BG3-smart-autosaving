-- Config file for setting the autosaving period and enabling/disabling events
local Config = Ext.Require("config.lua")

print("Smart Autosaving: version 1.0.0 loaded")

local TIMER = "Volitios_Smart_Autosaving"
local AUTOSAVING_PERIOD = Config.AUTOSAVING_PERIOD

-- State tracking variables
-- These will never be set to true if the corresponding event is disabled in the config
local isInDialogue = false
local isInTrade = false
local isInCombat = false
local isLockpicking = false
local waitingForAutosave = false
local combatTurnEnded = false

-- Function to start or restart the timer
local function StartOrRestartTimer()
    Osi.TimerCancel(TIMER)
    Osi.TimerLaunch(TIMER, AUTOSAVING_PERIOD * 1000)
    waitingForAutosave = false
end

local function Autosave()
    Osi.AutoSave()
    print("Smart Autosaving: Game saved")
    waitingForAutosave = false
    StartOrRestartTimer()
end

local function CanAutosave()
    -- We can autosave if we're at the start of a combat round, or if we're not in combat, dialogue, lockpicking or trading
    return combatTurnEnded or (not isInDialogue and not isInCombat and not isLockpicking and not isInTrade)
end


-- Handlers to update states and check for delayed autosave
-- Function to handle potential autosave after actions
local function HandlePotentialAutosave()
    -- Do not autosave if the states are true, even if we're waiting for an autosave
    if waitingForAutosave and CanAutosave() then
        Autosave()
        -- Set this to false regardless; if we're in combat, we'll set it to true again when a new round ends
        combatTurnEnded = false
    end
end

local function SaveIfWaiting()
    if waitingForAutosave then
        Autosave()
    end
end

-- Handler when the timer finishes
local function OnTimerFinished(timer)
    if timer == TIMER then
        if CanAutosave() then
            Autosave()
        else -- timer finished but we can't autosave yet, so we'll wait for the next event to try again
            waitingForAutosave = true
        end
    end
end

local function OnDialogStart()
    print("Dialogue started")
    isInDialogue = true
end
local function OnDialogEnd()
    isInDialogue = false;
    HandlePotentialAutosave()
end

local function OnTradeStart()
    isInTrade = true
end
local function OnTradeEnd()
    isInTrade = false;
    SaveIfWaiting()
end

local function OnCombatStart()
    isInCombat = true
end
-- I didn't manage to get this to work, so I'm using TurnEnded instead
-- local function onCombatRoundStarted()
--     combatTurnEnded = true
--     HandlePotentialAutosave()
-- end
local function OnCombatEnd()
    isInCombat = false;
    HandlePotentialAutosave()
end
local function OnTurnEnded(char)
    local function isPartyMember(char)
        return string.sub(char, 1, 8) == "S_PLAYER"
    end
    local function isHost(char)
        return string.sub(char, -36) == GetHostCharacter()
    end

    -- Potentially save if the turn ended for the avatar or party member (this should not trigger multiplayer or summons)
    if isHost(char) or isPartyMember(char) then
        combatTurnEnded = true
        HandlePotentialAutosave()
    end
end

local function OnLockpickingStart()
    isLockpicking = true
end
local function OnLockpickingEnd()
    isLockpicking = false;
    HandlePotentialAutosave()
end

local function OnGameStateChange(e)
    -- Reset the timer if the game state changes to 'Save'
    -- String comparison isn't ideal, but it should be fine for this
    local toStateStr = tostring(e.ToState)
    if toStateStr == 'Save' then
        StartOrRestartTimer()
    end
end


-- Subscribe to the GameStateChanged event to detect when saves are created and reset the timer
-- Note that it will also trigger with the mod's own autosaves, but there shouldn't be any issues with that
Ext.Events.GameStateChanged:Subscribe(OnGameStateChange)

-- Registering general Osiris event listeners
-- Start the timer when the game is loaded
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "before", StartOrRestartTimer)
Ext.Osiris.RegisterListener("TimerFinished", 1, "before", OnTimerFinished)

-- Events that can restrict autosaving
-- Dialogue
if Config.EVENTS.dialogue then
    Ext.Osiris.RegisterListener("DialogStartRequested", 2, "before", OnDialogStart)
    Ext.Osiris.RegisterListener("DialogStarted", 2, "before", OnDialogStart)
    Ext.Osiris.RegisterListener("DialogEnded", 2, "before", OnDialogEnd)
end

-- Trading
if Config.EVENTS.trade then
    Ext.Osiris.RegisterListener("RequestTrade", 4, "before", OnTradeStart)
    Ext.Osiris.RegisterListener("TradeEnds", 2, "before", OnTradeEnd)
end

-- Combat
if Config.EVENTS.combat then
    Ext.Osiris.RegisterListener("CombatStarted", 1, "before", OnCombatStart)
    Ext.Osiris.RegisterListener("CombatEnded", 1, "before", OnCombatEnd)
    Ext.Osiris.RegisterListener("TurnEnded", 1, "before", OnTurnEnded)
    -- (Not actually working)
    -- Ext.Osiris.RegisterListener("CombatRoundStarted", 1, "before", onCombatRoundStarted)
end

-- Lockpicking (always enabled since it's so quick)
Ext.Osiris.RegisterListener("StartedLockpicking", 2, "before", OnLockpickingStart)
Ext.Osiris.RegisterListener("StoppedLockpicking", 2, "before", OnLockpickingEnd)
