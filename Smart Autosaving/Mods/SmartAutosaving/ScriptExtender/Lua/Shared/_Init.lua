setmetatable(Mods.SmartAutosaving, { __index = Mods.VolitionCabinet })

local deps = {
    VCModuleUUID = "f97b43be-7398-4ea5-8fe2-be7eb3d4b5ca",
    MCMModuleUUID = "755a8a72-407f-4f0d-9a33-274ac0f0b53d"
}
if not Ext.Mod.IsModLoaded(deps.VCModuleUUID) then
    Ext.Utils.Print(
    "Volition Cabinet is missing and is a hard requirement. PLEASE MAKE SURE IT IS ENABLED IN YOUR MOD MANAGER.")
end

if not Ext.Mod.IsModLoaded(deps.MCMModuleUUID) then
    Ext.Utils.Print(
    "BG3 Mod Configuration Menu is missing and is a hard requirement. PLEASE MAKE SURE IT IS ENABLED IN YOUR MOD MANAGER.")
end

function MCMGet(settingID)
    return Mods.BG3MCM.MCMAPI:GetSettingValue(settingID, ModuleUUID)
end

---Ext.Require files at the path
---@param path string
---@param files string[]
function RequireFiles(path, files)
    for _, file in pairs(files) do
        Ext.Require(string.format("%s%s.lua", path, file))
    end
end

RequireFiles("Shared/", {
    "Helpers/_Init",
    "EventHandlers",
    "SubscribedEvents",
})

local MODVERSION = Ext.Mod.GetMod(ModuleUUID).Info.ModVersion
if MODVERSION == nil then
    SAWarn(0, "Volitio's Smart Autosaving loaded (version unknown)")
else
    -- Remove the last element (build/revision number) from the MODVERSION table
    table.remove(MODVERSION)

    local versionNumber = table.concat(MODVERSION, ".")
    SAPrint(0, "Volitio's Smart Autosaving version " .. versionNumber .. " loaded")
end

-- AutosavingHandlerInstance = AutosavingHandler:New()

SubscribedEvents.SubscribeToEvents()
