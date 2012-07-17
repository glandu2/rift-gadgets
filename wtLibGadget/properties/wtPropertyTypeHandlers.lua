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

WT.Gadget.PropertyTypeHandlers.integer = function(typeDef, value)

	local val = math.floor(tonumber(value) + 0.5)
	
	if not val then
		error("Invalid integer: " .. tostring(value))
	end

	if typeDef.min and val < typeDef.min then
		error("Integer is less than minimum value: " .. tostring(typeDef.min))
	end	

	if typeDef.max and val > typeDef.max then
		error("Integer is greater than maximum value: " .. tostring(typeDef.max))
	end	
	
	return val
	
end


WT.Gadget.PropertyTypeHandlers.number = function(typeDef, value)

	local val = tonumber(value)
	
	if not val then
		error("Invalid number: " .. tostring(value))
	end

	if typeDef.min and val < typeDef.min then
		error("Number is less than minimum value: " .. tostring(typeDef.min))
	end	

	if typeDef.max and val > typeDef.max then
		error("Number is greater than maximum value: " .. tostring(typeDef.max))
	end	
	
	return val
	
end


WT.Gadget.PropertyTypeHandlers.string = function(typeDef, value)

	local val = tostring(value)
	
	if typeDef.maxLength and val:len() > maxLength then
		error("String is longer than maximum length of " .. tostring(typeDef.maxLength))
	end	

	return val
	
end
