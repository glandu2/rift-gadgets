--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

-- A gadget can call this function to recommend to the user that they reload the UI (/reloadui)
-- This could be called every time a gadget is deleted, for example
-- It will display a small window somewhere not *too* obtrusive, with a button to reload the UI
function WT.Gadget.Message(title, message)

	if not WT.Gadget.MessageDialog then
		local dialog = UI.CreateFrame("Texture", "WTMessageDialog", WT.Context)
		dialog:SetLayer(9020)
		dialog:SetTexture(AddonId, "img/wtGoldFrame.png")
		dialog:SetPoint("TOPCENTER", UIParent, "TOPCENTER", 0, 25)
		dialog:SetSecureMode("restricted")
		
		local heading = UI.CreateFrame("Text", "WTMessageDialog", dialog)
		heading:SetFontSize(17)
		heading:SetPoint("TOPCENTER", dialog, "TOPCENTER", 0, 17)
		dialog.heading = heading
		
		local detail =  UI.CreateFrame("Text", "WTMessageDialog", dialog)
		detail:SetFontSize(12)
		detail:SetWordwrap(true)
		detail:SetPoint("TOP", heading, "BOTTOM")
		detail:SetPoint("LEFT", dialog, "LEFT", 16, nil)
		detail:SetPoint("RIGHT", dialog, "RIGHT", -16, nil)
		dialog.detail = detail
		
		local btnOK = UI.CreateFrame("RiftButton", "WTMessageDialog", dialog)
		btnOK:SetText(TXT.OK)
		btnOK:SetPoint("TOPCENTER", detail, "BOTTOMCENTER", 0, 3) 
		btnOK.Event.LeftClick = function() WT.FadeOut(dialog, 0.5) end

		WT.Gadget.MessageDialog = dialog
		
	end

	local dialog = WT.Gadget.MessageDialog

	dialog.heading:SetText(title)
	dialog.detail:SetText(message)

	WT.FadeIn(dialog, 0.5)
	
end