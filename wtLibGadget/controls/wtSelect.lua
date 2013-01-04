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



WT.Control.Select = {}
WT.Control.Select_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.Select[name] then return WT.Control.Select[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

function WT.Control.Select.Create(parent, label, default, listItems, sort, onchange)

	local control = UI.CreateFrame("Frame", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.Select_mt) 

	local tfValue = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_TextField"), control)
	tfValue:SetText(default or "")
	tfValue:SetWidth(200)
	tfValue:SetBackgroundColor(0.2,0.2,0.2,0.9)

	if label then
		local txtLabel = UI.CreateFrame("Text", WT.UniqueName("GadgetControlUnitSpecSelector_Label"), control)
		txtLabel:SetText(label)
		txtLabel:SetPoint("TOPLEFT", control, "TOPLEFT")
		tfValue:SetPoint("CENTERLEFT", txtLabel, "CENTERRIGHT", 8, 0)
		control.Label = txtLabel
	else
		tfValue:SetPoint("TOPLEFT", control, "TOPLEFT", 0, 0)
	end	

	local dropDownIcon = UI.CreateFrame("Texture", WT.UniqueName("GadgetControlUnitSpecSelector_Dropdown"), tfValue)
	dropDownIcon:SetTexture(AddonId, "img/wtDropDown.png")
	dropDownIcon:SetHeight(tfValue:GetHeight())
	dropDownIcon:SetWidth(tfValue:GetHeight())
	dropDownIcon:SetPoint("TOPLEFT", tfValue, "TOPRIGHT", -10, 0)

	local menu = WT.Control.Menu.Create(parent, listItems, function(value) tfValue:SetText(value); if onchange then onchange(tostring(value)) end; end, sort)
	menu:SetPoint("TOPRIGHT", dropDownIcon, "BOTTOMCENTER")

	dropDownIcon.Event.LeftClick = function() menu:Toggle() end

	control.GetText = function() return tfValue:GetText() end
	control.SetText = 
		function(ctrl, value) 
			tfValue:SetText(tostring(value))
			if onchange then onchange(tostring(value)) end 
		end
		
	control:SetHeight(20)
		
	return control
			
end
