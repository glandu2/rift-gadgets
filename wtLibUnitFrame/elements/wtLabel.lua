--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Label
	
		Provides a Label element, which is used to display text within a UnitFrame.
		
		The text must contain tokens that map to properties on the associated unit. If a value is unavailable
		for ANY token, the default value is displayed instead. If the text contains no tokens, no bindings will
		ever fire and the default text will always be used instead.
		
		Example: Setting text = "{health}/{healthMax} ({healthPercent}%)", with a default of "", will give you a label that
		makes sense over the top of a health bar. If any of the values are not available (generally because no unit is available),
		the label displays nothing (the default).

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtLabel = WT.Element:Subclass("Label", "Text")

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above ("Text")
function wtLabel:Construct()

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	-- Validate configuration
	if not config.text then error("Label missing required configuration item: text") end
	
	unitFrame:CreateTokenBinding(config.text, self, self.SetText, config.default or "")
	
		if config.fontSize then
		self:SetFontSize(config.fontSize)
	end
	
	if config.color then
		self:SetFontColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1) 
	end
	
end
