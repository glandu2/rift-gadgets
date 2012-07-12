local toc, data = ...
local AddonId = toc.identifier

local theme = {} 
WT.Themes["classic"] = theme

function theme.ApplyOverlayTheme(frame, createOptions)

	local handle = frame.gadgetOverlay.handle
	local resizer = frame.gadgetOverlay.resizer
	local box = frame.gadgetOverlay.box

	box:SetBackgroundColor(1,1,1,0.2)

	handle:SetTexture(AddonId, "themes/classic/GadgetHandle.png")
	handle.NormalMode = function(handle) handle:SetTexture(AddonId, "themes/classic/GadgetHandle.png") end
	handle.AlignMode = function(handle) handle:SetTexture(AddonId, "themes/classic/GadgetHandle_Lit.png") end
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, -12)
	
	if resizer then
		resizer:SetTexture(AddonId, "themes/classic/GadgetResizeHandle.png")
		resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, 2)
	end

	if createOptions.caption then
		local uiCaption = UI.CreateFrame("Text", "wtCaption", mvHandle)
		uiCaption:SetText(createOptions.caption)
		uiCaption:SetPoint("CENTERLEFT", handle, "CENTERRIGHT")
		uiCaption:SetFontSize(10)
	end
			
end
