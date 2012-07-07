local toc, data = ...
local AddonId = toc.identifier

local theme = {} 
WT.Themes["subtle"] = theme

function theme.ApplyOverlayTheme(frame)

	local handle = frame.gadgetOverlay.handle
	local resizer = frame.gadgetOverlay.resizer
	local box = frame.gadgetOverlay.box

	box:SetBackgroundColor(1,1,1,0.2)

	handle:SetTexture(AddonId, "themes/subtle/GadgetCornerTL.png")
	handle.NormalMode = function(handle) handle:SetTexture(AddonId, "themes/subtle/GadgetCornerTL.png") end
	handle.AlignMode = function(handle) handle:SetTexture(AddonId, "themes/subtle/GadgetCornerTL_Lit.png") end
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	
	if resizer then
		resizer:SetTexture(AddonId, "themes/subtle/GadgetCornerBR_Resize.png")
		resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)		
	else
		local cornerBR = UI.CreateFrame("Texture", "GadgetCornerBR", handle)
		cornerBR:SetTexture(AddonId, "themes/subtle/GadgetCornerBR.png")
		cornerBR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	end

	local cornerTR = UI.CreateFrame("Texture", "GadgetCornerTR", handle)
	cornerTR:SetTexture(AddonId, "themes/subtle/GadgetCornerTR.png")
	cornerTR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

	local cornerBL = UI.CreateFrame("Texture", "GadgetCornerBL", handle)
	cornerBL:SetTexture(AddonId, "themes/subtle/GadgetCornerBL.png")
	cornerBL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
			
end
