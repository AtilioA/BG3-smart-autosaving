local Utils = {}

function Utils.isAnotherPartyMember(char)
  return string.sub(char, 1, 8) == "S_PLAYER"
end

function Utils.isHost(char)
  return string.sub(char, -36) == GetHostCharacter()
end

-- Probably will get deprecated in favor of Osi.IsInPartyWith
function Utils.isPartyMember(char)
  return Utils.isHost(char) or Utils.isAnotherPartyMember(char)
end

return Utils
