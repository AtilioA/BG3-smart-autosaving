setmetatable(Mods.SmartAutosaving, { __index = Mods.VolitionCabinet })

ClientSideChecks = {}

function ClientSideChecks.HasPaperdoll()
    return not table.isEmpty(Ext.Entity.GetAllEntitiesWithComponent("ClientPaperdoll"))
end

---@return table<string, boolean> reasons
function ClientSideChecks.VerifyClientSideAutosavingStates()
    local reasons = {}
    reasons["isUsingInventory"] = ClientSideChecks.HasPaperdoll()

    return reasons
end

function ClientSideChecks.CanAutosave()
    local reasons = ClientSideChecks.VerifyClientSideAutosavingStates()
    local canAutosave = true

    for _reason, value in pairs(reasons) do
        if value == true then
            canAutosave = false
            break
        end
    end

    return canAutosave, reasons
end


--- Client Events
Ext.RegisterNetListener("SA_CheckClientSide", function(call, payload)
    local canAutosave, reasons = ClientSideChecks.CanAutosave()

    Ext.Net.PostMessageToServer("SA_ClientAutosaveStatus",
        Ext.Json.Stringify({ canAutosave = canAutosave, reasons = reasons }))
end)

-- NOTE: technically would create problems if more client checks are added, but we're (afterwards) doing a roundtrip check with the server anyways
Ext.Entity.OnDestroy("ClientPaperdoll", function(entity)
    -- Timing bullshit :prayge:
    VCHelpers.Timer:OnTicks(5, function()
        if not ClientSideChecks.HasPaperdoll() then
            Ext.Net.PostMessageToServer("SA_LastPaperdollDestroyed", Ext.Json.Stringify({}))
        end
    end)
end)
