--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : @project-version@
      Project Date (UTC)  : @project-date-iso@
      File Modified (UTC) : @file-date-iso@ (@file-author@)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

--[[

The event system wraps native event tables, giving more control over registering and removing events.

Usage:
  WT.CreateEvent() -> eventTable, triggerFunction
  WT.RegisterEventHandler(nativeEventTable, handler)
  WT.UnregisterEventHandler(nativeEventTable, handler)

--]]

local nativeEventHandlers = {}

local function HandleEvent(eventTable, ...)
	local wtHandler = nativeEventHandlers[eventTable]
	for handler, enabled in pairs(wtHandler) do
		if enabled then
			handler(...)
		end
	end
end

local function RegisterEventHandler(eventTable, fnHandler)

	assert(eventTable, "Native event table does not exist")

	-- Registered for the native handler if not done already
	if not nativeEventHandlers[eventTable] then
		table.insert(eventTable, { function(...) HandleEvent(eventTable, ...) end, AddonId, "NativeEventHandler" })
		nativeEventHandlers[eventTable] = {}
	end

	-- Add the new handler as a key in the nativeEventHandlers table
	nativeEventHandlers[eventTable][fnHandler] = true
	
end

local function UnregisterEventHandler(eventTable, fnHandler)
	if nativeEventHandlers[eventTable] then
		nativeEventHandlers[eventTable][fnHandler] = nil
	end
end

-- Creates a custom event, returning the event trigger and table
-- Note - the arguments are completely ignored at the moment
local function CreateEvent(addonid, eventHandlerName)

	local evTable = {}

	local evTrigger = 
		function(...)
			for _, entryTable in pairs(evTable) do
				entryTable[1](...)
			end
		end
		
	return evTrigger, evTable 

end


-- Declare the external API -------------------------------------------------
WT.CreateEvent = CreateEvent
WT.RegisterEventHandler = RegisterEventHandler
WT.UnregisterEventHandler = UnregisterEventHandler
-----------------------------------------------------------------------------
