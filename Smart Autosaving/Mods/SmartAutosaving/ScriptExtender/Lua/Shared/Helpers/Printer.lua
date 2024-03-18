SAPrinter = VolitionCabinetPrinter:New { Prefix = "Smart Autosaving", ApplyColor = true, DebugLevel = Config:GetCurrentDebugLevel() }

function SAPrint(debugLevel, ...)
  SAPrinter:SetFontColor(0, 255, 255)
  SAPrinter:Print(debugLevel, ...)
end

function SATest(debugLevel, ...)
  SAPrinter:SetFontColor(100, 200, 150)
  SAPrinter:PrintTest(debugLevel, ...)
end

function SADebug(debugLevel, ...)
  SAPrinter:SetFontColor(200, 200, 0)
  SAPrinter:PrintDebug(debugLevel, ...)
end

function SAWarn(debugLevel, ...)
  SAPrinter:SetFontColor(255, 100, 50)
  SAPrinter:PrintWarning(debugLevel, ...)
end

function SADump(debugLevel, ...)
  SAPrinter:SetFontColor(190, 150, 225)
  SAPrinter:Dump(debugLevel, ...)
end

function SADumpArray(debugLevel, ...)
  SAPrinter:DumpArray(debugLevel, ...)
end
