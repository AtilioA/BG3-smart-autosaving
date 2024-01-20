Utils = {}

function Utils.DebugPrint(level, ...)
  if JsonConfig and JsonConfig.DEBUG and JsonConfig.DEBUG.level >= level then
      print(...)
  end
end

return Utils
