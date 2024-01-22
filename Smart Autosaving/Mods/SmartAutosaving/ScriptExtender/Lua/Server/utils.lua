Utils = {}

--- Prints a debug message to the console if the debug level is set to a high enough level
---@param level number The debug level of the message
---@param ... any Additional arguments to print
---@return nil
function Utils.DebugPrint(level, ...)
  if JsonConfig and JsonConfig.DEBUG and JsonConfig.DEBUG.level >= level then
    if (JsonConfig.DEBUG.level == 0) then
      print(...)
    else
      print("[Smart Autosaving][DEBUG LEVEL " .. level .. "]: " .. ...)
    end
  end
end

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

return Utils
