--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Element
	
		Provides a basic implementation for Elements. All Element classes should be subclasses of
		this.

--]]


WT.Element = {}
WT.Element.Count = 0

function WT.Element.MetaIndex(table, name)
	if table._baseFrame[name] then return table._baseFrame[name] end 
	if table._class[name] then return table._class[name] end
	return nil 
end
WT.Element_mt = { __index = WT.Element.MetaIndex }

function WT.Element:Subclass(elementTypeName, baseFrameType)
	local obj = {}
	obj.ElementType = elementTypeName
	obj.BaseFrameType = baseFrameType or "Frame"
	setmetatable(obj, { __index = self })
	WT.ElementFactories[elementTypeName] = obj
	WT.Log.Debug("Registered element factory: " .. elementTypeName) 
	return obj
end

function WT.Element:Create(unitFrame, configuration, overrideParent)
	local obj = UI.CreateFrame(self.BaseFrameType, WT.UniqueName("WT_ELEM", configuration.id), overrideParent or unitFrame)
	obj._class = self
	obj._baseFrame = getmetatable(obj).__index 
	obj.UnitFrame = unitFrame
	obj.Configuration = configuration
	setmetatable(obj, WT.Element_mt)
	
	-- Validate configuration
	local valid = true
	if self.ConfigDefinition then
		for k,v in pairs(self.ConfigDefinition.required) do
			if (v == "required") and (not config[k]) then
				WT.Log.Error(self.ElementType .. " missing required configuration item: " .. tostring(k))
				valid = false
			end
		end
	end
	if valid then
		obj:Construct()
		return obj
	else
		return nil
	end
end
