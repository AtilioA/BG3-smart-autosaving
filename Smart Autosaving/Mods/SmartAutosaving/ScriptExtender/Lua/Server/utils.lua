Utils = {}

function Utils.DebugPrint(level, ...)
  if JsonConfig and JsonConfig.DEBUG and JsonConfig.DEBUG.level >= level then
    if (JsonConfig.DEBUG.level == 0) then
      print(...)
    else
      print("[Smart Autosaving][DEBUG LEVEL " .. level .. "]: " .. ...)
    end
  end
end

return Utils
