--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.8.0
      Project Date (UTC)  : 2015-04-08T17:43:33Z
      File Modified (UTC) : 2013-09-14T09:22:53Z (Adelea)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate



WT.Control.Slider = {}
WT.Control.Slider_mt = 
{ 
	__index = function(tbl,name)
		if tbl.frameIndex[name] then return tbl.frameIndex[name] end
		if WT.Control.Slider[name] then return WT.Control.Slider[name] end  
		if WT.Control[name] then return WT.Control[name] end
		return nil  
	end 
}

function WT.Control.Slider.Create(parent, id, label, default, onchange)

	local control = UI.CreateFrame("SimpleSlider", WT.UniqueName("Control"), parent)
	control.frameIndex = getmetatable(control).__index
	setmetatable(control, WT.Control.Slider_mt) 

	control:SetRange(6, 48)
	control:SetWidth(150)
	control:SetPosition(default)
	
	return control
			
end
