local Object = {}

-- Courtesy of Focus/Focus Core (https://www.nexusmods.com/baldursgate3/mods/5972)
function Object.IsCharacter(object)
  local objectType = type(object)
  if objectType == "userdata" then
    local mt = getmetatable(object)
    local userdataType = Ext.Types.GetObjectType(object)
    if mt == "EntityProxy" and object.IsCharacter ~= nil then
      return true
    elseif userdataType == "esv::CharacterComponent"
        or userdataType == "ecl::CharacterComponent"
        or userdataType == "esv::Character"
        or userdataType == "ecl::Character" then
      return true
    end
  elseif objectType == "string" or objectType == "number" then
    local entity = Ext.Entity.Get(object)
    return entity ~= nil and entity.IsCharacter ~= nil
  end
  return false
end

return Object
