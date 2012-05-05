--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier


WT.Control.ComboBox = {}
WT.Control.ComboBox_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.ComboBox[name] then return WT.Control.ComboBox[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

function WT.Control.ComboBox.Create(parent, label, default, listItems, sort)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.ComboBox_mt) 

	local tfValue = UI.CreateFrame("RiftTextfield", WT.UniqueName("GadgetControlUnitSpecSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetBackgroundColor(0.2,0.2,0.2,0.9)

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end	

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture(AddonId, "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	local menu = WT.Control.Menu.Create(parent, listItems, function(value) tfValue:SetText(value) end, sort)
	menu:SetPoint("TOPRIGHT", dropDownIcon, "BOTTOMCENTER")

	dropDownIcon.Event.LeftClick = function() menu:Toggle() end

	control.GetText = function() return tfValue:GetText() end
	control.SetText = function(ctrl, value) tfValue:SetText(tostring(value)) end
		
	control:SetHeight(20)
		
	return control
			
end
