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

WT.Gadget.PropertyTypeHandlers = {}


function WT.Gadget.SetProperty(gadgetId, propertyId, value)

	local gadget = WT.Gadgets[gadgetId]

	if not gadget then
		error("Attempt to set property " .. propertyId .. " on non-existent gadget " .. gadgetId)
	end

	if not gadget.properties[propertyId] then
		error("Attempt to set non-existent property " .. propertyId .. " on gadget " .. gadgetId)
		return 
	end
	
	local propertyDef = gadget.properties[propertyId]
	local propertyType = propertyDef.type
	local typeHandler = WT.Gadget.PropertyTypeHandlers[propertyType]
	if not typeHandler then
		error("Unknown property type on property " .. propertyId .. ": " .. tostring(propertyType))
	end
	
	local val = typeHandler(propertyDef, value)
	
	wtxGadgets[gadgetId][propertyId] = val
	propertyDef.apply(val)

end


function WT.Gadget.GetProperty(gadgetId, propertyId)

	local gadget = WT.Gadgets[gadgetId]

	if not gadget then
		WT.Log.Warning("Attempt to get property " .. propertyId .. " from non-existent gadget " .. gadgetId)
		return 
	end

	return wtxGadgets[gadgetId][propertyId]

end
