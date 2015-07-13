--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.7
      Project Date (UTC)  : 2013-12-01T08:25:42Z
      File Modified (UTC) : 2013-09-17T18:45:13Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

-- Events ---------------------------------------------------------------------
WT.Event.Trigger.SettingsChanged, WT.Event.SettingsChanged = Utility.Event.Create(AddonId, "SettingsChanged")
-------------------------------------------------------------------------------
wtxGadgets = wtxGadgets or {}

local window = nil
local btnOK = nil
local btnCancel = nil
local txtBlackList = nil

local radFormatShort = nil
local radFormatLong = nil
local radFormatNone = nil
local ProfileRoles = nil
local ufDialog = false

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
	
	if ProfileRoles:GetChecked() == true then
		wtxOptions.prRoles = true
	else  
		wtxOptions.prRoles = false 
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
	
		window  = UI.CreateFrame("Texture", "WTGadgetCreate", WT.Context)
		window:SetTexture(AddonId, "img/495.png")	
		window:SetBackgroundColor(0.07,0.07,0.07,0)		
		window:SetPoint("CENTER", UIParent, "CENTER")
		window:SetWidth(900)
		window:SetHeight(900)
		window:SetLayer(11000)
		window:SetAlpha(0.98)
		
	   Library.LibDraggable.draggify(window, nil)	
		
		local closeButton = UI.CreateFrame("Texture", window:GetName().."CloseButton", window)
		closeButton:SetTexture(AddonId, "img/Ignore.png" )
		closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -40, 40)
				  
		function closeButton.fnc1_LeftClick()	
			window:SetVisible(false)
				if window.Event.Close then
				 window.Event.Close(window)
				end		
		end			
		closeButton:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
				closeButton.fnc1_LeftClick()
			end, "Event.UI.Input.Mouse.Left.Click")
			
		local content = window
		
		local labSettingsTitle = UI.CreateFrame("Texture", "ModifyTitle", content)
		labSettingsTitle:SetTexture(AddonId, "img/Settings.png")
		labSettingsTitle:SetPoint("TOPLEFT", content, "TOPRIGHT", -550, 10)
		labSettingsTitle:SetLayer(10000)
		
		local tabs = UI.CreateFrame("SimpleTabView", "buffTabs", window)
		tabs:SetPoint("TOPLEFT", content, "TOPLEFT", 120, 120)
		tabs:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -120, -120)
		tabs:SetTabPosition("left")
		tabs:SetBackgroundColor(0.07,0.07,0.07,0)	


		local btnOK = UI.CreateFrame("RiftButton", "btnOK", window)
		btnOK:SetPoint("TOPLEFT", tabs, "BOTTOMLEFT", 0, 4)
		btnOK:SetText("Save")
		--btnOK.Event.LeftPress = SaveSettings
		btnOK:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
			SaveSettings()
		end, "Event.UI.Input.Mouse.Left.Click")

		local contentOptions = UI.CreateFrame("Frame", "contentOptions", tabs.tabContent)
		contentOptions:SetAllPoints(content)
		
		local labNumberFormat = UI.CreateFrame("Text", "txtNumberFormat", contentOptions)
		labNumberFormat:SetText("Number Format:")
		labNumberFormat:SetFontSize(16)
		labNumberFormat:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labNumberFormat:SetFontColor(1,0.97,0.84,1)
		labNumberFormat:SetFont(AddonId, "blank-Bold")
		labNumberFormat:SetPoint("TOPLEFT", contentOptions, "TOPLEFT", 8, 8)
		
		radFormatShort = UI.CreateFrame("SimpleRadioButton", "radFormatShort", contentOptions)
		radFormatShort:SetText("Abbreviated (1.2K)")
		--[[labNumberFormat:SetFontSize(16)
		labNumberFormat:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labNumberFormat:SetFontColor(1,0.97,0.84,1)
		labNumberFormat:SetFont(AddonId, "blank-Bold")]]
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
		contentBuffSettings:SetAllPoints(content)

		local labBlackList = UI.CreateFrame("Text", "txtBlackListHeader", contentBuffSettings)
		labBlackList:SetText(TXT.BuffBlackList)
		labBlackList:SetFontSize(16)
		labBlackList:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labBlackList:SetFontColor(1,0.97,0.84,1)
		labBlackList:SetFont(AddonId, "blank-Bold")
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
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------Profile settings--------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
		local contentProfileSettings = UI.CreateFrame("Frame", "contentProfileSettings", tabs.tabContent)
		contentProfileSettings:SetAllPoints(content)
-------------------------------Save Profile----------------------------------------------
		local labProfile = UI.CreateFrame("Text", "txtProfile", contentProfileSettings)
		labProfile:SetText("Enter name to save Profile")
		labProfile:SetFontSize(16)
		labProfile:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labProfile:SetFontColor(1,0.97,0.84,1)
		labProfile:SetFont(AddonId, "blank-Bold")
		labProfile:SetPoint("TOPLEFT", contentProfileSettings, "TOPLEFT", 8, 8)
			
		txtProfile = UI.CreateFrame("RiftTextfield", "txtProfile", labProfile)
		txtProfile:SetBackgroundColor(0.2, 0.2, 0.2, 1.0)
		txtProfile:SetText("")
		txtProfile:SetPoint("TOPLEFT", labProfile, "TOPLEFT", 200, 1)
		txtProfile:SetWidth(200)
		local n = txtProfile:GetText()
		
		local btnSaveProfile = UI.CreateFrame("Frame", "btnSaveProfile", contentProfileSettings)
		btnSaveProfile:SetWidth(100)
		btnSaveProfile:SetHeight(20)
		btnSaveProfile:SetBackgroundColor(0.2,0.4,0.6,1.0)
		btnSaveProfile:SetPoint("TOPLEFT", txtProfile, "TOPLEFT", 220, 0)	
		btnSaveProfile:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			btnSaveProfile:SetBackgroundColor(0.4,0.6,0.8,1.0)
		end, "Event.UI.Input.Mouse.Cursor.In")
		btnSaveProfile:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			btnSaveProfile:SetBackgroundColor(0.2,0.4,0.6,1.0)
		end, "Event.UI.Input.Mouse.Cursor.Out")
		btnSaveProfile:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
			local layoutName = txtProfile:GetText()
			if layoutName == nil then
				print("Please enter profile name.")
			else
				wtxLayouts[layoutName] = wtxGadgets
				print("Profile "..layoutName.." has been saved.")
				WT.Gadget.RecommendReload()	

			end		
		end, "Event.UI.Input.Mouse.Left.Click")
			
		local btnSaveProfileTxt = UI.CreateFrame("Text", "txtbtnSaveProfileTxt", btnSaveProfile)
		btnSaveProfileTxt:SetText("Save profile")
		btnSaveProfileTxt:SetFontSize(16)
		btnSaveProfileTxt:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		btnSaveProfileTxt:SetFontColor(1,0.97,0.84,1)
		btnSaveProfileTxt:SetFont(AddonId, "blank-Bold")
		btnSaveProfileTxt:SetPoint("TOPLEFT", btnSaveProfile, "TOPLEFT", 10, 0)
-------------------------------Delete Profile--------------------------------------------		
		local labProfileDelete = UI.CreateFrame("Text", "txtProfileDelete", contentProfileSettings)
		labProfileDelete:SetText("Select profile for delete")
		labProfileDelete:SetFontSize(16)
		labProfileDelete:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labProfileDelete:SetFontColor(1,0.97,0.84,1)
		labProfileDelete:SetFont(AddonId, "blank-Bold")
		labProfileDelete:SetPoint("TOPLEFT", contentProfileSettings, "TOPLEFT", 8, 35)

		layoutNameList = UI.CreateFrame("SimpleSelect", "Profile List", contentProfileSettings)
		layoutNameList:SetPoint("TOPLEFT", labProfileDelete, "TOPLEFT", 200, 1)
		layoutNameList:SetHeight(25)
		layoutNameList:SetLayer(3)
		layoutNameList:SetFontSize(16)
		--layoutNameList:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		--layoutNameList:SetFontColor(1,0.97,0.84,1)
		--layoutNameList:SetFont(AddonId, "blank-Bold")
		getlayoutNameList(layoutName)
		layoutNameList:ResizeToFit()
		
		local btnDeleteProfile = UI.CreateFrame("Frame", "btnDeleteProfile", contentProfileSettings)
		btnDeleteProfile:SetWidth(100)
		btnDeleteProfile:SetHeight(20)
		btnDeleteProfile:SetBackgroundColor(0.2,0.4,0.6,1.0)
		btnDeleteProfile:SetPoint("TOPLEFT", labProfileDelete, "TOPLEFT", 420, 1)	
		btnDeleteProfile:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
			btnDeleteProfile:SetBackgroundColor(0.4,0.6,0.8,1.0)
		end, "Event.UI.Input.Mouse.Cursor.In")
		btnDeleteProfile:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
			btnDeleteProfile:SetBackgroundColor(0.2,0.4,0.6,1.0)
		end, "Event.UI.Input.Mouse.Cursor.Out")
		btnDeleteProfile:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self, h)
			if layoutNameList:GetSelectedItem()  then
				local layoutName = layoutNameList:GetSelectedItem()
				wtxLayouts[layoutName] = nil
				print("Profile "..layoutName.." has been deleted.")
				WT.Gadget.RecommendReload()	
			end
		end, "Event.UI.Input.Mouse.Left.Click")
					
		local btnDeleteProfileTxt = UI.CreateFrame("Text", "txtbtnDeleteProfileTxt", btnDeleteProfile)
		btnDeleteProfileTxt:SetText("Delete profile")
		btnDeleteProfileTxt:SetFontSize(16)
		btnDeleteProfileTxt:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		btnDeleteProfileTxt:SetFontColor(1,0.97,0.84,1)
		btnDeleteProfileTxt:SetFont(AddonId, "blank-Bold")
		btnDeleteProfileTxt:SetPoint("TOPLEFT", btnDeleteProfile, "TOPLEFT", 10, 0)	
-------------------------------Profile - Roles--------------------------------------------	
		local labProfileRoles = UI.CreateFrame("Text", "txtProfileRoles", contentProfileSettings)
		labProfileRoles:SetText("__________________________Profile - Roles_____________________________")
		labProfileRoles:SetFontSize(20)
		labProfileRoles:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		labProfileRoles:SetFontColor(1,0.97,0.84,1)
		labProfileRoles:SetFont(AddonId, "blank-Bold")
		labProfileRoles:SetPoint("TOPLEFT", contentProfileSettings, "TOPLEFT", 8, 70)
		
		ProfileRoles = UI.CreateFrame("SimpleCheckbox", "ProfileRoles", contentProfileSettings)
		ProfileRoles:SetPoint("TOPLEFT", labProfileRoles, "TOPLEFT", 8, 50)
		ProfileRoles:SetFontSize(16)
		ProfileRoles:SetEffectGlow({ colorR = 0.23, colorG = 0.17, colorB = 0.027, strength = 3, })
		ProfileRoles:SetFontColor(1,0.97,0.84,1)
		ProfileRoles:SetFont(AddonId, "blank-Bold")
		ProfileRoles:SetText("Show window Importlayout when you change role")	
		ProfileRoles:EventAttach(Event.UI.Checkbox.Change, function(self, h)
			if ProfileRoles:GetChecked() == true then
				wtxOptions.prRoles = true
			end
			if ProfileRoles:GetChecked() == false then
				wtxOptions.prRoles  = false
			end
		end, "Event.UI.Checkbox.Change")
		if wtxOptions.prRoles == true then 
			ProfileRoles:SetChecked(true) 
		else  
			ProfileRoles:SetChecked(false) 
		end
			
------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
		tabs:AddTab("General", contentOptions)
		tabs:AddTab("Buffs/Debuffs", contentBuffSettings)
		tabs:AddTab("Profiles", contentProfileSettings)
		
	end

	window:SetVisible(true)
end

function getlayoutNameList(layoutName)
	addlist = nil
	addlist = {}
	for i, v in pairs(wtxLayouts) do
		table.insert(addlist, ""..i)	-- Concatenated to a string incase the user saves thier entry as a number
	end
	layoutNameList:SetItems(addlist)
	layoutNameList:SetSelectedItem(layoutName, silent)
end

local CURRENT_ROLE_TYPE = nil

local function Event_Unit_Availability_Full(h,t)
	for k,v in pairs(t) do
		if v == "player" then
			local pd = Inspect.Unit.Detail("player")
			CURRENT_ROLE_TYPE = pd.role
			Command.Event.Detach(Event.Unit.Availability.Full, nil, nil, nil, AddonId)
		end
	end
end

local function RoleChange(hEvent, unitId)
	if wtxOptions.prRoles == true then
		if unit == player then
			local pd = Inspect.Unit.Detail("player")
			if pd.role ~= CURRENT_ROLE_TYPE then
				WT.Gadget.ShowImportDialog()
				CURRENT_ROLE_TYPE = pd.role
			end
		end
	end
end	

Command.Event.Attach(Event.Unit.Detail.Role, RoleChange, "RoleChange")
Command.Event.Attach(Event.Unit.Availability.Full, Event_Unit_Availability_Full, "Event.Unit.Availability.Full")