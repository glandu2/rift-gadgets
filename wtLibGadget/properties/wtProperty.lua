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

-- Add the relevant information to a Gadget's configuration when first created
function WT.Gadget.InitializePropertyConfig(config)
	config.Properties = {}
	config.Properties["general"].xpos = 200
	config.Properties["general"].ypos = 200
end

-- Attach a property to a Gadget
function WT.Gadget.AddProperty(gadgetId, propertyId, name, type, group, options)
	
	local gadget = WT.Gadgets[gadgetId]
	local config = wtxGadgets[gadgetId]

	if not gadget then
		WT.Log.Warning("Attempt to attach property " .. propertyId .. " to non-existent gadget " .. gadgetId)
		return 
	end
	
	if not gadget._properties then
		gadget._properties = {}
	end

	if not gadget._properties[group] then
		gadget._properties[group] = {}
	end
	
	if gadget._properties[group][propertyId] then
		WT.Log.Warning("Attempt to attach duplicate property " .. group .. "/" .. propertyId .. " to gadget " .. gadgetId)
		return 
	end
	
	local propertyTable = {}
	
	propertyTable.id = propertyId
	propertyTable.type = type
	propertyTable.name = name
	propertyTable.options = {}
	for k,v in pairs(options) do
		propertyTable.options[k] = v 
	end 

	gadget._properties[propertyId][group] = propertyTable
	
end


function WT.Gadget.SetProperty(gadgetId, group, propertyId, value)

	local gadget = WT.Gadgets[gadgetId]

	if not gadget then
		WT.Log.Warning("Attempt to set property " .. propertyId .. " on non-existent gadget " .. gadgetId)
		return 
	end

	if gadget._properties[propertyId] and gadget._properties[propertyId][group] then
		gadget._properties[propertyId][group].value = value
	else
		WT.Log.Warning("Attempt to set non-existent property " .. group .. "/" .. propertyId .. " on gadget " .. gadgetId)
		return 
	end

end


function WT.Gadget.GetProperty(gadgetId, group, propertyId)

	local gadget = WT.Gadgets[gadgetId]

	if not gadget then
		WT.Log.Warning("Attempt to get property " .. propertyId .. " from non-existent gadget " .. gadgetId)
		return 
	end

	if gadget._properties[propertyId] and gadget._properties[propertyId][group] then
		return gadget._properties[propertyId][group].value
	else
		WT.Log.Warning("Attempt to get non-existent property " .. group .. "/" .. propertyId .. " on gadget " .. gadgetId)
		return nil
	end

end
