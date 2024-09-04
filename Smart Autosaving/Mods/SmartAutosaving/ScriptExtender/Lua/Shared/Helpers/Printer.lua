SAPrinter = VolitionCabinetPrinter:New { Prefix = "Smart Autosaving", ApplyColor = true, DebugLevel = MCMGet("debug_level") }

-- Update the Printer debug level when the setting is changed, since the value is only used during the object's creation
Ext.ModEvents.BG3MCM['MCM_Setting_Saved']:Subscribe(function(payload)
    if not payload or payload.modUUID ~= ModuleUUID or not payload.settingId then
        return
    end

    if payload.settingId == "debug_level" then
        SADebug(0, "Setting debug level to " .. payload.value)
        SAPrinter.DebugLevel = payload.value
    end
end)

function SAPrint(debugLevel, ...)
    SAPrinter:SetFontColor(0, 255, 255)
    SAPrinter:Print(debugLevel, ...)
end

function SATest(debugLevel, ...)
    SAPrinter:SetFontColor(100, 200, 150)
    SAPrinter:PrintTest(debugLevel, ...)
end

function SADebug(debugLevel, ...)
    SAPrinter:SetFontColor(200, 200, 0)
    SAPrinter:PrintDebug(debugLevel, ...)
end

function SAWarn(debugLevel, ...)
    SAPrinter:SetFontColor(255, 100, 50)
    SAPrinter:PrintWarning(debugLevel, ...)
end

function SADump(debugLevel, ...)
    SAPrinter:SetFontColor(190, 150, 225)
    SAPrinter:Dump(debugLevel, ...)
end

function SADumpArray(debugLevel, ...)
    SAPrinter:DumpArray(debugLevel, ...)
end
