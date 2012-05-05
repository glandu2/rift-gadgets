--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.HorizontalBar
	
		Provides a horizontal bar element, which is used to display a bar bound to a percentage field
		
		*Change: The bar's mask is now contained within a Frame which is set to the element width/height. 
		This allows other elements to be attached to the bar without moving around as the bar shrinks/grows.
		Previously the bar was represented by the Mask frame itself.

--]]

-- Create the class.
-- This will be automatically registered as an Element factory with the name "Label"
-- The base frame type is "Text"
local wtBar = WT.Element:Subclass("Bar", "Frame")

wtBar.ConfigDefinition = 
{
	description = "A bar element. This must be bound to a percentage property (returns a number between 0 and 100).",
	required = 
	{
		width = "The width of the bar",
		height = "The height of the bar",
		binding = "The property to bind to. Must be a percentage property (0..100)",
		texAddon = "The addon ID for the addon containing the bar texture",
		texFile = "The filename of the texture for the bar",
	},
	optional = 
	{
		colorBinding = "A binding to allow a colour to be auto assigned to the bar (e.g. roleColor, callingColor)",
		color = "A table containing {r,g,b,a} members (0..1)",
		growthDirection = "the direction the bar grows in, up, down, left or right (default is right)",
	},
}

-- The Construct method builds the element up. The element (self) is an instance of the relevant
-- UI.Frame as specified in the Subclass() call above
function wtBar:Construct()

	-- Because we have provided a ConfigDefinition above, we already know that all of the required configuration items are
	-- available within self.Configuration, so there is no need to check them again here.

	local config = self.Configuration
	local unitFrame = self.UnitFrame

	self.Mask = UI.CreateFrame("Mask", WT.UnitFrame.UniqueName(), self)

	self:SetWidth(config.width)
	self:SetHeight(config.height)

	self.growthDirection = config.growthDirection or "right"

	self.Mask:SetWidth(config.width)
	self.Mask:SetHeight(config.height)
	
	if self.growthDirection == "left" then
		self.Mask:SetPoint("TOPRIGHT", self, "TOPRIGHT")
	elseif self.growthDirection == "up" then
		self.Mask:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
	elseif self.growthDirection == "down" then
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
	else
		self.Mask:SetPoint("TOPLEFT", self, "TOPLEFT")
	end
	
	self.MaxWidth = config.width	
	self.MaxHeight = config.height	
	
	self.Image = UI.CreateFrame("Texture", WT.UnitFrame.UniqueName(), self.Mask)
	self.Image:SetWidth(config.width)
	self.Image:SetHeight(config.height)
	self.Image:SetTexture(config.texAddon, config.texFile)
	self.Image:SetPoint("TOPLEFT", self, "TOPLEFT")
		
	unitFrame:CreateBinding(config.binding, self, self.BindPercent, 0)
	
	if config.colorBinding then
		unitFrame:CreateBinding(config.colorBinding, self, self.BindColor, nil)
	end

	if config.color then
		self:SetBarColor(config.color.r or 0, config.color.g or 0, config.color.b or 0, config.color.a or 1)
	end

	if config.backgroundColor then
		self:SetBackgroundColor(config.backgroundColor.r or 0, config.backgroundColor.g or 0, config.backgroundColor.b or 0, config.backgroundColor.a or 1)
	end
		
end

function wtBar:BindPercent(percentage)
	WT.Log.Verbose("Bar percent binding triggered")
	if (self.growthDirection == "up") or (self.growthDirection == "down") then 
		self.Mask:SetHeight((percentage / 100) * self.MaxHeight)
	else
		self.Mask:SetWidth((percentage / 100) * self.MaxWidth)
	end
end

function wtBar:BindColor(color)
	if color then
		WT.Log.Debug(string.format("Bar Color Binding: %d %d %d %d", color.r or 0, color.g or 0, color.b or 0, color.a or 1))
		self:SetBarColor(color.r or 0, color.g or 0, color.b or 0, color.a or 1)
	else
		self:SetBarColor(0, 0, 0, 1)
	end
end

function wtBar:SetBarColor(r,g,b,a)
	self.Image:SetBackgroundColor(r, g, b, a or 1)
end
