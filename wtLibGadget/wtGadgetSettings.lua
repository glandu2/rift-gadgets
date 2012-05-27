--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local window = nil
local btnOK = nil
local btnCancel = nil
local txtBlackList = nil

local function OnWindowClosed()
	WT.Utility.ClearKeyFocus(window)
	
	wtxOptions.buffsBlacklist = {}
	local blacklist = txtBlackList:GetText():wtSplit("\r")
	for idx, buff in ipairs(blacklist) do
		local blBuff = buff:wtTrim()
		if blBuff:len() > 0 then
			wtxOptions.buffsBlacklist[blBuff] = true
		end
	end
end

local function GetBlacklistedBuffs()
	local blacklist = ""
	if wtxOptions.buffsBlacklist then
		local sorted = {}
		for buff in pairs(wtxOptions.buffsBlacklist) do
			table.insert(sorted, buff)
		end
		table.sort(sorted)
		for idx, buff in ipairs(sorted) do
			blacklist = blacklist .. buff .. "\n"
		end	
	end
	return blacklist
end

function WT.Gadget.ShowSettings()

	if not window then
	
		window = UI.CreateFrame("SimpleWindow", "winGadgetSettings", WT.Context)
		window:SetCloseButtonVisible(true)		
		window:SetTitle(TXT.Settings)
		window:SetPoint("CENTER", UIParent, "CENTER")
		window:SetLayer(10010)
		window:SetWidth(800)
		window:SetHeight(650)

		window.Event.Close = OnWindowClosed

		local tabs = UI.CreateFrame("SimpleTabView", "buffTabs", window)
		tabs:SetPoint("TOPLEFT", window:GetContent(), "TOPLEFT", 8, 8)
		tabs:SetPoint("BOTTOMRIGHT", window:GetContent(), "BOTTOMRIGHT", -8, -30)
		tabs:SetTabPosition("left")
		
		local contentBuffSettings = UI.CreateFrame("Frame", "contentBuffSettings", tabs.tabContent)
		contentBuffSettings:SetAllPoints(window:GetContent())
		
		local labBlackList = UI.CreateFrame("Text", "txtBlackListHeader", contentBuffSettings)
		labBlackList:SetText(TXT.BuffBlackList)
		labBlackList:SetFontSize(14)
		labBlackList:SetPoint("TOPLEFT", contentBuffSettings, "TOPLEFT", 8, 8)
		
		local frmBlackList = UI.CreateFrame("Frame", "frmBuffBlackList", contentBuffSettings)
		frmBlackList:SetBackgroundColor(1,1,1,1)
		frmBlackList:SetPoint("TOPLEFT", labBlackList, "BOTTOMLEFT", 0, 0)
		frmBlackList:SetPoint("RIGHT", contentBuffSettings, "CENTERX", -8, nil)
		frmBlackList:SetHeight(200)
			
		txtBlackList = UI.CreateFrame("SimpleTextArea", "txtBuffBlackList", frmBlackList)
		txtBlackList:SetBackgroundColor(0.3,0.3,0.3,1.0)
		txtBlackList:SetText(GetBlacklistedBuffs())
		txtBlackList:SetPoint("TOPLEFT", frmBlackList, "TOPLEFT", 1, 1)
		txtBlackList:SetPoint("BOTTOMRIGHT", frmBlackList, "BOTTOMRIGHT", -1, -1)

		tabs:AddTab("Buffs/Debuffs", contentBuffSettings)
	end

	window:SetVisible(true)
end
