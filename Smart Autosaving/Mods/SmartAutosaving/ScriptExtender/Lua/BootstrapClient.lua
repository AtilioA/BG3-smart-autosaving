Ext.Require("Client/_Init.lua")

Ext.RegisterNetListener("SA_CheckClientSide", function(call, payload)
    local canAutosave, reasons = ClientSideChecks.CanAutosave()

    Ext.Net.PostMessageToServer("SA_ClientAutosaveStatus", Ext.Json.Stringify({ canAutosave = canAutosave, reasons = reasons }))
end)
