--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local gadgetDetails = false
local frameOptions = false
local gadgetFactory = false
local gadgetConfig = false
local gadgetId = false

local function OnModifyClick()
	if gadgetFactory.GetConfiguration then
	 	local config = gadgetFactory.GetConfiguration()
		for k,v in pairs(config) do gadgetConfig[k] = v end
	
		-- Delete the existing gadget
		WT.Gadget.Delete(gadgetId)
						
		-- Then recreate the gadget with the updated configuration options
		WT.Gadget.Create(gadgetConfig)
	end

	WT.Utility.ClearKeyFocus(WT.Gadget.ModifyGadgetWindow)
	WT.Gadget.ModifyGadgetWindow:SetVisible(false) 
	return
end

function WT.Gadget.ShowModifyUI(id)

	gadgetId = id
	gadgetConfig =  wtxGadgets[gadgetId]
	gadgetFactory = WT.GadgetFactories[gadgetConfig.type:lower()]

	if not WT.Gadget.ModifyGadgetWindow then
		local window  = UI.CreateFrame("SimpleWindow", "WTGadgetModify", WT.Context)
		window:SetPoint("CENTER", UIParent, "CENTER")
		--window:SetController("content")
		window:SetWidth(800)
		window:SetHeight(600)
		window:SetLayer(11000)
		window:SetTitle(TXT.ModifyGadget)
		WT.Gadget.ModifyGadgetWindow = window
		
		local content = window:GetContent()

		frameOptions = UI.CreateFrame("Frame", "WTGadgetOptions", content)
		frameOptions:SetPoint("TOPLEFT", content, "TOPLEFT", 8, 8)
		frameOptions:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT" ,0, 0)		

		local btnCancel = UI.CreateFrame("RiftButton", "WTGadgetBtnCancel", frameOptions)
		btnCancel:SetText(TXT.Cancel)
		btnCancel:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
		btnCancel.Event.LeftPress = function() window:SetVisible(false); WT.Utility.ClearKeyFocus(window); end
		
		local btnOK = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", frameOptions)
		btnOK:SetText(TXT.Modify)
		btnOK:SetPoint("CENTERRIGHT", btnCancel, "CENTERLEFT", 8, 0)
		btnOK:SetEnabled(true)
		btnOK.Event.LeftPress = OnModifyClick 
		
		-- frameOptions will host the dialog provided by the gadget factory assuming one is available

		local frameOptionsHeading = UI.CreateFrame("Text", "WTGadgetOptionsHeading", frameOptions)
		frameOptionsHeading:SetFontSize(18)
		frameOptionsHeading:SetText(TXT.ModifyGadget)
		frameOptionsHeading:SetPoint("TOPLEFT", frameOptions, "TOPLEFT", 8, 8)

		gadgetDetails = UI.CreateFrame("Text", "WTGadgetDetails", frameOptions)
		gadgetDetails:SetFontSize(10)
		gadgetDetails:SetText(TXT.ModifyMessage)
		gadgetDetails:SetPoint("TOPLEFT", frameOptionsHeading, "BOTTOMLEFT", 0, -4)
		gadgetDetails:SetFontColor(0.8, 0.8, 0.8, 1.0)
	else
		WT.Gadget.ModifyGadgetWindow:SetVisible(true)
	end

	local window = WT.Gadget.ModifyGadgetWindow

	-- Hide any pre-existing dialog frame
	if window.dialog then
		window.dialog:SetVisible(false)
		window.dialog = nil
	end
	
	-- Apply the current configuration to the dialog
	if gadgetFactory.ConfigDialog then
		if not gadgetFactory._configDialog then
			local container = UI.CreateFrame("Frame", WT.UniqueName("gadgetOptionsContainer"), gadgetDetails)
			container:SetPoint("TOPLEFT", gadgetDetails, "TOPLEFT", 0, 8)
			container:SetPoint("BOTTOMRIGHT", gadgetDetails, "BOTTOMRIGHT", -8, -8)
			container:SetVisible(false)
			gadgetFactory.ConfigDialog(container)
			gadgetFactory._configDialog = container
		end
		window.dialog = gadgetFactory._configDialog 
		
		window.dialog:SetParent(gadgetDetails)
		window.dialog:SetPoint("TOPLEFT", gadgetDetails, "BOTTOMLEFT", 0, 8)
		window.dialog:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
		
		if gadgetFactory.SetConfiguration then
			gadgetFactory.SetConfiguration(gadgetConfig)
		end

		window.dialog:SetVisible(true)
	end

end