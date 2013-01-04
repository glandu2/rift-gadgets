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

local window = nil

local function OnWindowClosed()
	WT.Utility.ClearKeyFocus(window)
end

function WT.Gadget.ShowImportDialog()

	if (Inspect.System.Secure()) then
		print("Cannot import settings while in combat")
		return
	end

	if not window then
		window = UI.CreateFrame("SimpleWindow", "winGadgetImport", WT.Context)
		window:SetCloseButtonVisible(true)		
		window:SetTitle("Import Layout")
		window:SetPoint("CENTER", UIParent, "CENTER")
		window:SetLayer(10010)
		window:SetWidth(280)
		window:SetHeight(650)
		window:SetSecureMode("restricted")
		
		window.Event.Close = OnWindowClosed
		
		local contentImportSettings = UI.CreateFrame("Frame", "contentImportSettings", window)
		contentImportSettings:SetAllPoints(window:GetContent())
		contentImportSettings:SetSecureMode("restricted")
		
		local labImport = UI.CreateFrame("Text", "txtImportHeader", contentImportSettings)
		labImport:SetText("Import Layout from Character:")
		labImport:SetFontSize(14)
		labImport:SetPoint("TOPLEFT", contentImportSettings, "TOPLEFT", 16, 8)

		local lastButton = nil
		
		local charList = {}
		for charId in pairs(wtxLayouts) do table.insert(charList, charId) end
		table.sort(charList)
		
		for idx, charId in ipairs(charList) do
		
			local btnImport = UI.CreateFrame("Frame", "btnFrame", contentImportSettings)
			btnImport:SetWidth(220)
			btnImport:SetHeight(30)
			btnImport:SetBackgroundColor(1,1,1,1)
			btnImport:SetSecureMode("restricted")
			
			if lastButton then
				btnImport:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, 4)
			else
				btnImport:SetPoint("TOPLEFT", labImport, "BOTTOMLEFT", 0, 8)
			end

			local fillImport = UI.CreateFrame("Frame", "btnFrame", btnImport)
			fillImport:SetPoint("TOPLEFT", btnImport, "TOPLEFT", 2, 2)
			fillImport:SetPoint("BOTTOMRIGHT", btnImport, "BOTTOMRIGHT", -2, -2)
			fillImport:SetBackgroundColor(0.2,0.4,0.6,1)
			
			local txtImport = UI.CreateFrame("Text", "txtFrame", fillImport)
			txtImport:SetText(charId)
			txtImport:SetFontColor(1,1,1,1)
			txtImport:SetPoint("CENTER", btnImport, "CENTER")

			btnImport.Event.LeftClick = "gadget import " .. charId .. "\nreloadui"
			btnImport.Event.MouseIn = function() fillImport:SetBackgroundColor(0.4,0.6,0.8,1.0) end
			btnImport.Event.MouseOut = function() fillImport:SetBackgroundColor(0.2,0.4,0.6,1.0) end

			lastButton = btnImport
		end		
	end
	
	window:SetVisible(true)
end
