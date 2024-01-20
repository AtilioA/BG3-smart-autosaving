Ext.Require("config.lua")
Ext.Require("Server/autosaving.lua")
Ext.Require("Server/event_handlers.lua")
Ext.Require("Server/utils.lua")
Ext.Require("Server/Helpers/Object.lua")

MOD_UUID = "0c8bb2e9-aa96-4de7-b793-a733d68ee6f0"
local MODVERSION = Ext.Mod.GetMod(MOD_UUID).Info.ModVersion

if MODVERSION == nil then
    print("Smart Autosaving loaded (version unknown)")
else
    -- Remove the last element (build/revision number) from the MODVERSION table
    table.remove(MODVERSION)

    local versionNumber = table.concat(MODVERSION, ".")
    print("Smart Autosaving: version " .. versionNumber .. " loaded")
end

local EventSubscription = Ext.Require("Server/subscribed_events.lua")
EventSubscription.SubscribeToEvents()
