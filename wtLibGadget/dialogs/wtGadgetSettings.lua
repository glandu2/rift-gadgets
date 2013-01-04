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

-- Events ---------------------------------------------------------------------
WT.Event.Trigger.SettingsChanged, WT.Event.SettingsChanged = WT.CreateEvent(AddonId, "SettingsChanged")
-------------------------------------------------------------------------------

local window = nil
local btnOK = nil
local btnCancel = nil
local txtBlackList = nil

local radFormatShort = nil
local radFormatLong = nil
local radFormatNone = nil

local function OnWindowClosed()
	WT.Utility.ClearKeyFocus(window)		
end

local function SaveSettings()

	wtxOptions.buffsBlacklist = {}
	local blacklist = txtBlackList:GetText():wtSplit("\r")
	for idx, buff in ipairs(blacklist) do
		local blBuff = buff:wtTrim()
		if blBuff:len() > 0 then
			wtxOptions.buffsBlacklist[blBuff] = true
		end
	end
	
	if radFormatLong:GetSelected() then
		wtxOptions.numberFormat = "long"
	elseif radFormatNone:GetSelected() then
		wtxOptions.numberFormat = "none"
	else
		wtxOptions.numberFormat = "short"
	end

	OnWindowClosed()
	window:SetVisible(false)
	
	WT.Event.Trigger.SettingsChanged()

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
		tabs:SetPoint("BOTTOMRIGHT", window:GetContent(), "BOTTOMRIGHT", -8, -50)
		tabs:SetTabPosition("left")

		local btnOK = UI.CreateFrame("RiftButton", "btnOK", window)
		btnOK:SetPoint("TOPLEFT", tabs, "BOTTOMLEFT", 0, 4)
		btnOK:SetText("Save")
		btnOK.Event.LeftPress = SaveSettings

		local contentOptions = UI.CreateFrame("Frame", "contentOptions", tabs.tabContent)
		contentOptions:SetAllPoints(window:GetContent())
		
		local labNumberFormat = UI.CreateFrame("Text", "txtNumberFormat", contentOptions)
		labNumberFormat:SetText("Number Format:")
		labNumberFormat:SetFontSize(14)
		labNumberFormat:SetPoint("TOPLEFT", contentOptions, "TOPLEFT", 8, 8)
		
		radFormatShort = UI.CreateFrame("SimpleRadioButton", "radFormatShort", contentOptions)
		radFormatShort:SetText("Abbreviated (1.2K)")
		radFormatShort:SetPoint("TOPLEFT", labNumberFormat, "TOPLEFT", 150, 0)

		radFormatLong = UI.CreateFrame("SimpleRadioButton", "radFormatLong", contentOptions)
		radFormatLong:SetText("Comma Separated (1,234)")
		radFormatLong:SetPoint("TOPLEFT", radFormatShort, "BOTTOMLEFT", 0, 4)

		radFormatNone = UI.CreateFrame("SimpleRadioButton", "radFormatLong", contentOptions)
		radFormatNone:SetText("No Formatting (1234)")
		radFormatNone:SetPoint("TOPLEFT", radFormatLong, "BOTTOMLEFT", 0, 4)
		
		local radGroupNumFormat = Library.LibSimpleWidgets.RadioButtonGroup("radGroupNumFormat")
		radGroupNumFormat:AddRadioButton(radFormatShort)
		radGroupNumFormat:AddRadioButton(radFormatLong)
		radGroupNumFormat:AddRadioButton(radFormatNone)
		
		local selOption = wtxOptions.numberFormat or "short"
		if selOption == "none" then
			radFormatNone:SetSelected(true)
		elseif selOption == "long" then
			radFormatLong:SetSelected(true)
		else
			radFormatShort:SetSelected(true)
		end
		
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

		tabs:AddTab("General", contentOptions)
		tabs:AddTab("Buffs/Debuffs", contentBuffSettings)
	end

	window:SetVisible(true)
end
