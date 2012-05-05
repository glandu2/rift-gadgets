--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

WT.Control.Menu = {}
WT.Control.Menu_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.Menu[name] then return WT.Control.ComboBox[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

local currMenu = false

local function OnClickOutside()
	if currMenu then
		currMenu:Hide()
	end
end

local catchAllClicks = UI.CreateFrame("Frame", WT.UniqueName("Menu"), WT.Context)
catchAllClicks:SetLayer(10000)
catchAllClicks:SetVisible(false)
catchAllClicks:SetAllPoints(UIParent)
catchAllClicks.Event.LeftClick = OnClickOutside
catchAllClicks.Event.RightClick = OnClickOutside

function WT.Control.Menu.Create(parent, listItems, callback, sort)

	local sorted = sort
	if sorted == nil then sorted = false end

	if sort then
		table.sort(listItems, 
			function(a,b)
				 local aVal = a
				 local bVal = b
				 if type(aVal) == "table" then aVal = aVal.text end
				 if type(bVal) == "table" then bVal = bVal.text end
				 return aVal < bVal
			end)
	end

	local control = UI.CreateFrame("Frame", WT.UniqueName("Menu"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.Menu_mt) 
	control:SetLayer(10001)
	control:SetVisible(false)
	control:SetBackgroundColor(1,1,1,1)

	local dropDownBackground = UI.CreateFrame("Frame", WT.UniqueName("MenuBG"), control)
	dropDownBackground:SetBackgroundColor(0,0,0,1)
	dropDownBackground:SetPoint("TOPLEFT", control, "TOPLEFT", 1, 1)
	dropDownBackground:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", -1, -1)

	local value = nil

	local last = nil
	local maxWidth = 0
	local items = {}
	for i,v in ipairs(listItems) do
		local txtOption = UI.CreateFrame("Text", WT.UniqueName("ComboOption"), dropDownBackground)
		if type(v) == "table" then
			txtOption:SetText(v.text or v.value)
		else
			txtOption:SetText(v)
		end
		local w = txtOption:GetWidth()
		if w > maxWidth then maxWidth = w end 
		if not last then
			txtOption:SetPoint("TOPLEFT", dropDownBackground, "TOPLEFT", 4, 4)
		else
			txtOption:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, 2)
		end
		txtOption.Event.LeftClick = 
			function()
				if type(v) == "table" then
					value = v.value or v.text
					if type(v.value) == "function" then v.value(v.text) end 
				else
					value = v
				end			
				if callback then callback(value) end
				control.Hide()
			end
		last = txtOption
		table.insert(items, txtOption)
	end
	
	local top = control:GetTop()
	local bottom = last:GetBottom() + 5 
	control:SetHeight(bottom-top)
	control:SetWidth(maxWidth + 10)
	
	for idx,item in ipairs(items) do
		item:SetWidth(maxWidth)
		item.Event.MouseIn = function() item:SetBackgroundColor(0.2, 0.4, 0.6, 1.0) end
		item.Event.MouseOut = function() item:SetBackgroundColor(0.0, 0.0, 0.0, 0.0) end
	end
	
	control.GetValue = function() return value end
		
	control.Show = 
		function() 
			if currMenu then currMenu:Hide() end 
			catchAllClicks:SetParent(control:GetParent())
			catchAllClicks:SetVisible(true) 
			currMenu = control 
			WT.FadeIn(control, 0.2) -- fade in
		end
		
	control.Hide = 
		function() 
			control:SetVisible(false)
			catchAllClicks:SetVisible(false) 
			if control == currMenu then
				currMenu = false
			end 
			WT.FadeOut(control, 0.2) -- fade out
		end

	control.Toggle = 
		function() 
			if control == currMenu then
				control.Hide()
			else
				control.Show()
			end 
		end
		
	return control

end

