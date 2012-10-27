--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Frame
	
		Provides a Frame element

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtFrame = WT.Element:Subclass("Frame", "Frame")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtFrame:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	if config.color then 
		self:SetBackgroundColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1) 
	end

	if config.colorBinding then
		unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end

	if config.width then self:SetWidth(config.width) end
	if config.height then self:SetHeight(config.height) end

end


function wtFrame:BindColor(color)
	if color then
		self:SetBackgroundColor(color.r or 0, color.g or 0, color.b or 0, color.a or 1)
	else
		self:SetBackgroundColor(0, 0, 0, 1)
	end
end
