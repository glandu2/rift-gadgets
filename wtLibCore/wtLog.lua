--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- Logging
-- Nothing clever, just allows conditional output of messages based on which severities are enabled below
-- Changed to a log level type approach - "/wt log level 5" etc

WT.Log = {}
WT.Log.Level = 0

table.insert(Event.Addon.SavedVariables.Load.End, {
	function(addonId)
		if addonId == AddonId then
			WT.Log.Level = wtxLogLevel or 2
		end
	end,
	AddonId, "LoadSavedVariables"
})

table.insert(Event.Addon.SavedVariables.Save.Begin, {
	function(addonId)
		if addonId == AddonId then
			wtxLogLevel = WT.Log.Level
		end
	end,
	AddonId, "LoadSavedVariables"
})

-- Write a log entry
-- This just prints the message to the chat console if the relevant severity has been enabled
-- Custom severities can be added by defining WT.Log.<Severity>
local function LogWrite(severity, message)
	print(severity .. ": " .. tostring(message))
end

-- Provide explicit calls for the built in severities (for cleaner code)

function WT.Log.Verbose(msg)
	if WT.Log.Level >= 5 then LogWrite("VRB", msg) end
end

function WT.Log.Debug(msg)
	if WT.Log.Level >= 4 then LogWrite("DBG", msg) end
end

function WT.Log.Info(msg)
	if WT.Log.Level >= 3 then LogWrite("INF", msg) end
end

function WT.Log.Warning(msg)
	if WT.Log.Level >= 2 then LogWrite("WRN", msg) end
end

function WT.Log.Error(msg)
	if WT.Log.Level >= 1 then LogWrite("ERR", msg) end
end


function WT.Command.log(args)

	local numArgs = table.getn(args)

	if numArgs == 2 and string.lower(args[1]) == "level" then
		local num =  tonumber(args[2])
		if not num or num > 5 or num < 0 then
			print("Invalid log level specified, must be a number between 0 and 5")
			return
		end
		WT.Log.Level = math.floor(num)
	end

	local level = "None"
	if WT.Log.Level == 1 then level = "Error" end
	if WT.Log.Level == 2 then level = "Warning" end
	if WT.Log.Level == 3 then level = "Information" end
	if WT.Log.Level == 4 then level = "Debug" end
	if WT.Log.Level >= 5 then level = "Verbose" end
	print(string.format("WT Log Level %d - %s", WT.Log.Level, level))

end

