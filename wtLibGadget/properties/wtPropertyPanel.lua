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

Library.Media.AddFont("PropertyFont", AddonId, "fonts/SquareRoman.ttf")

function TestPropertyPanel()

	local ctxPropertyPanel = UI.CreateContext("WTPropertyPanel")
	ctxPropertyPanel:SetStrata("topmost")

	local panel = UI.CreateFrame("Frame", "WTPropertyPanel", ctxPropertyPanel)
	panel:SetBackgroundColor(1,1,1,1)
	panel:SetWidth(150)
	panel:SetHeight(250)
	panel:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, 50)

	local panelBorder = UI.CreateFrame("Frame", "WTPropertyPanel", ctxPropertyPanel)
	panelBorder:SetBackgroundColor(0,0,0,1)
	panelBorder:SetPoint("TOPLEFT", panel, "TOPLEFT", -1, -1)
	panelBorder:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 1, 1)
	panel:SetParent(panelBorder)
	panelBorder:SetAlpha(0.8)

	local panelFont = Library.Media.GetFont("PropertyFont");
	
	local panelTitle = UI.CreateFrame("Text", "WTPanelTitle", panel)
	panelTitle:SetFont(panelFont.addonId, panelFont.filename)
	panelTitle:SetText("Properties")
	panelTitle:SetFontSize(13)
	panelTitle:SetFontColor(0,0,0,1)
	panelTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, 4)

end


TestPropertyPanel()