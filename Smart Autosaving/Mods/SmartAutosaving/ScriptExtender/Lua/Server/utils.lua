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

return Utils
