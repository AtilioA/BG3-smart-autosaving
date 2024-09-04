ClientSideChecks = {}


function ClientSideChecks.HasPaperdoll()
    return not table.isEmpty(Ext.Entity.GetAllEntitiesWithComponent("ClientPaperdoll"))
end

---@return table<string, boolean> reasons
function ClientSideChecks.VerifyClientSideAutosavingStates()
    local reasons = {}
    reasons["hasPaperdoll"] = ClientSideChecks.HasPaperdoll()

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
