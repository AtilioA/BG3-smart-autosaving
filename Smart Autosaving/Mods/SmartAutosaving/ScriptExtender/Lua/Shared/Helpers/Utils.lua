Utils = {}

function Utils.GetPlayerEntity()
    return Ext.Entity.Get(Osi.GetHostCharacter())
end

--- Very rudimentary check to see if an entity is moving
---@param entity any
---@return boolean
function IsEntityMoving(entity)
    return entity.Pathing.Flags ~= 1 and
        entity.Pathing.PathId ~= -1337 and
        entity.Pathing.PathMovementSpeed ~= 0.0
end

--- Very rudimentary check to see if the player is moving
---@return boolean
function Utils.IsPlayerMoving()
    local playerEntity = Utils.GetPlayerEntity()

    return IsEntityMoving(playerEntity)
end

--- Checks if any party member is moving
function Utils.IsAnyPartyMemberMoving()
    local partyMembers = Osi.DB_Players:Get(nil)

    for _, partyMember in pairs(partyMembers) do
        local partyMemberEntity = Ext.Entity.Get(partyMember[1])
        if IsEntityMoving(partyMemberEntity) then
            return partyMemberEntity
        end
    end

    return false
end

--- Checks if all party members are dead
---@return boolean
function Utils.IsPartyDead()
    local partyMembers = Osi.DB_Players:Get(nil)
    local allDead = true

    for _, partyMember in pairs(partyMembers) do
        if Osi.IsDead(partyMember[1]) == 0 then
            allDead = false
            break
        end
    end

    return allDead
end

return Utils
