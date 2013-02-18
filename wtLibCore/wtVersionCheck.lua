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

local versionList = {}

-- Set the addon up to receive version messages from any source
Command.Message.Accept(nil, "GDT:VERSION")

local function SendVersion()
	Command.Message.Broadcast("guild", nil, "GDT:VERSION", toc.toc.Version)
	Command.Message.Broadcast("raid", nil, "GDT:VERSION", toc.toc.Version)
end

local function OnMessageRecieved(from, type, channel, identifier, data)
	if identifier == "GDT:VERSION" then
		versionList[from] = data
	end
end

function WT.Command.versions()
	for name, version in pairs(versionList) do
		print(name .. " = " .. version)
	end
end

local timeLastTick = nil

local function OnVersionTick()

	-- If first tick of the session, send the version and initialise the timer
	if not timeLastTick then
		timeLastTick = Inspect.Time.Frame()
		SendVersion()
		return
	end

	if (Inspect.Time.Frame() - timeLastTick) > 120 then
		SendVersion()
		timeLastTick = Inspect.Time.Frame()
	end

end

table.insert(Event.Message.Receive, { OnMessageRecieved, AddonId, "OnMessageRecieved" } )
table.insert(Event.System.Update.End, { OnVersionTick, AddonId, "OnVersionTick" } )
