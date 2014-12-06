--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.5.4
      Project Date (UTC)  : 2013-10-06T09:26:25Z
      File Modified (UTC) : 2013-10-06T09:26:25Z (lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local controls = {}

local ufDialog = false
local ufAppearance = false
local function ufConfigDialog(container)

	local templateListItems = {}
	for templateId, template in pairs(WT.UnitFrame.Templates) do
		table.insert(templateListItems, { text=templateId .. " (" .. template.Configuration.Name .. ")", value=templateId } )
	end

	local ufTabs = UI.CreateFrame("SimpleTabView", "ufTabs", container)
	ufTabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	ufTabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local frmConfig = UI.CreateFrame("Frame", "ufConfig", ufTabs.tabContent)
	local frmConfigInner = UI.CreateFrame("Frame", "ufConfigInner", frmConfig)
	frmConfigInner:SetPoint("TOPLEFT", frmConfig, "TOPLEFT", 12, 12)
	frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfig, "BOTTOMRIGHT", -12, -12)
	
	local frmOverride = UI.CreateFrame("Frame", "frmOverride", ufTabs.tabContent)
	local frmOverrideInner = UI.CreateFrame("Frame", "frmOverrideInner", frmOverride)
	frmOverrideInner:SetPoint("TOPLEFT", frmOverride, "TOPLEFT", 4, 4)
	frmOverrideInner:SetPoint("BOTTOMRIGHT", frmOverride, "BOTTOMRIGHT", -4, -4)

	ufTabs:SetTabPosition("top")
	ufTabs:AddTab("Configuration", frmConfig)
	ufTabs:AddTab("Appearance", frmOverride)	
	
	ufDialog = WT.Dialog(frmConfigInner)
		:Combobox("unitSpec", TXT.UnitToTrack, "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		:Select("template", TXT.UnitFrameTemplate, "LifeUnitFrame1", templateListItems, true)
		:Checkbox("excludeBuffs", "Hide Buffs on Frame", false)
		:Checkbox("excludeCasts", "Hide Castbars on Frame", false)
		:Checkbox("ownBuffs", "Only show my buffs", true)
		:Checkbox("ownDebuffs", "Only show my debuffs", false)
		:Checkbox("clickToTarget", TXT.EnableClickToTarget, true)
		:Checkbox("contextMenu", TXT.EnableContextMenu, true)
		:Checkbox("showBackground", TXT.ShowBackground, false)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)
		:Checkbox("showLeftPortrait", "Fake Portrait on Left", false)
		:Checkbox("showRightPortrait", "Fake Portrait on Right", false)
		:Checkbox("shortname", "Short name", true)
		:Checkbox("showRadius", "Show HitBox", false)
		:Checkbox("showCombo", "Show Combo points", true)
		:Checkbox("showRankIcon", "Show Rank Icon", false)

	ufAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "Texture 39", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.5, 0, 0.85)
		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
		:TexSelect("texResource", "Resource Texture", "Texture 69", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)
--		:Checkbox("ovAbsorbTexture", "Override Absorb Texture?", false)
--		:TexSelect("texAbsorb", "Absorb Texture", "Texture 69", "bar")
		:Checkbox("ovCastTexture", "Override Cast bar Texture?", false)
		:TexSelect("texCast", "Cast bar Texture", "Texture 69", "bar")
--		:Checkbox("ovHealthBackgroundColor", "Override Health Back color?", false)
--		:ColorPicker("colHealthBackground", "Health Background Color", 0.07, 0.07, 0.07, 0.85)
		
end

local function ufGetConfiguration()
	local config = ufDialog:GetValues()
	local config2 = ufAppearance:GetValues()
	for k,v in pairs(config2) do
		config[k] = v
	end
	return config
end

local function ufSetConfiguration(config)
	ufDialog:SetValues(config)
	ufAppearance:SetValues(config)
end

local rfEditors = {}
local macroTypes = { "Left", "Middle", "Right", "Mouse4", "Mouse5", "WheelForward", "WheelBack" } 
local macroNames = { "Left", "Middle", "Right", "Button 4", "Button 5", "Wheel Forward", "Wheel Back" } 

local rfDialog = false
local rfAppearance = false


local function rf_OnTemplateChange(templateId)
	if rfDialog == false then return end
	local templateConfig = WT.UnitFrame.Templates[templateId].Configuration
	if templateConfig.SupportsHoTTracking then
		rfDialog:GetControl("showHoTTrackers"):SetVisible(true)
	else
		rfDialog:GetControl("showHoTTrackers"):SetVisible(false)
	end
	if templateConfig.SupportsHoTPanel then
		rfDialog:GetControl("showHoTPanel"):SetVisible(true)
	else
		rfDialog:GetControl("showHoTPanel"):SetVisible(false)
	end
	
	if templateConfig.SupportsDebuffPanel then
		rfDialog:GetControl("showDebuffPanel"):SetVisible(true)
	else
		rfDialog:GetControl("showDebuffPanel"):SetVisible(false)
	end
end


local function rfConfigDialog(container)
	
	container.Reset = function()
		for idx, editor in ipairs(rfEditors) do editor:SetText("") end
		rfEditors[1]:SetText("target @unit")
		rfEditors[3]:SetText("menu")
	end

	local templateListItems = {}
	for templateId, template in pairs(WT.UnitFrame.Templates) do
		if template.Configuration.RaidSuitable then
			table.insert(templateListItems, { text=templateId .. " (" .. template.Configuration.Name .. ")", value=templateId } )
		end
	end

	local rfTabs = UI.CreateFrame("SimpleTabView", "rfTabs", container)
	rfTabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	rfTabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local frmConfig = UI.CreateFrame("Frame", "rfConfig", rfTabs.tabContent)
	local frmConfigInner = UI.CreateFrame("Frame", "rfConfigInner", frmConfig)
	frmConfigInner:SetPoint("TOPLEFT", frmConfig, "TOPLEFT", 12, 12)
	frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfig, "BOTTOMRIGHT", -12, -12)
	
	local frmMacros = UI.CreateFrame("Frame", "rfMacros", rfTabs.tabContent)
	local frmMacrosInner = UI.CreateFrame("Frame", "rfMacrosInner", frmMacros)
	frmMacrosInner:SetPoint("TOPLEFT", frmMacros, "TOPLEFT", 4, 4)
	frmMacrosInner:SetPoint("BOTTOMRIGHT", frmMacros, "BOTTOMRIGHT", -4, -4)

	local frmOverride = UI.CreateFrame("Frame", "rfMacros", rfTabs.tabContent)
	local frmOverrideInner = UI.CreateFrame("Frame", "rfMacrosInner", frmOverride)
	frmOverrideInner:SetPoint("TOPLEFT", frmOverride, "TOPLEFT", 4, 4)
	frmOverrideInner:SetPoint("BOTTOMRIGHT", frmOverride, "BOTTOMRIGHT", -4, -4)

	rfTabs:SetTabPosition("top")
	rfTabs:AddTab("Configuration", frmConfig)
	rfTabs:AddTab("Mouse Macros", frmMacros)	
	rfTabs:AddTab("Appearance", frmOverride)	

	rfDialog = WT.Dialog(frmConfigInner)
		:Select("template", TXT.RaidFrameTemplate, "Heal Frame", templateListItems, true, rf_OnTemplateChange)
		:Select("layout", "Layout", "4 x 5", { "4 x 5", "5 x 4", "2 x 10", "10 x 2", "1 x 20", "20 x 1" }, false)
		:Select("growthDirection", "Growth direction", "right", { "right", "left", "up", "down" }, false)
		:Checkbox("hideWhenEmpty", "Hide When Raid Is Empty", false)
		:Checkbox("showBackground", TXT.ShowBackground, false)
		:FieldNote(TXT.ShowBackgroundNote)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)
		:Checkbox("reverseGroups", TXT.ReverseGroups, false)
		:Checkbox("reverseUnits", TXT.ReverseUnits, false)
		:Checkbox("showHoTTrackers", "Show HoT Trackers", false)
		:Checkbox("showHoTPanel", "Show HoTs", true)
		:Checkbox("showDebuffPanel", "Show Debuffs", true)
		
	local templateControl = rfDialog:GetControl("template")
	local templateId = templateControl.getValue()

	local hotTrack = WT.UnitFrame.Templates[templateId].Configuration.SupportsHoTTracking
	if hotTrack then
		rfDialog:GetControl("showHoTTrackers"):SetVisible(true)
	else
		rfDialog:GetControl("showHoTTrackers"):SetVisible(false)
	end

	local hotPanel = WT.UnitFrame.Templates[templateId].Configuration.SupportsHoTPanel
	if hotPanel then
		rfDialog:GetControl("showHoTPanel"):SetVisible(true)
	else
		rfDialog:GetControl("showHoTPanel"):SetVisible(false)
	end

	local debuffPanel = WT.UnitFrame.Templates[templateId].Configuration.SupportsDebuffPanel
	if debuffPanel then
		rfDialog:GetControl("showDebuffPanel"):SetVisible(true)
	else
		rfDialog:GetControl("showDebuffPanel"):SetVisible(false)
	end
	
	local macroTabs = UI.CreateFrame("SimpleTabView", "macroTabs", frmMacrosInner)
	macroTabs:SetTabPosition("left")
	macroTabs:SetAllPoints(frmMacrosInner)

	rfAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "Texture 68", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.5, 0, 0.85)
--		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
--		:TexSelect("texResource", "Resource Texture", "wtBantoBar", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)
--		:Checkbox("ovAbsorbTexture", "Override Absorb Texture?", false)
--		:TexSelect("texAbsorb", "Absorb Texture", "Texture 69", "bar")
		:Checkbox("ovHealthBackgroundColor", "Override Health Back color?", false)
		:ColorPicker("colHealthBackground", "Health Background Color", 0.07, 0.07, 0.07, 0.85)
	
	for idx, name in ipairs(macroNames) do
	
		local tabContent = UI.CreateFrame("Frame", "content", macroTabs.tabContent)
		macroTabs:AddTab(name, tabContent)
	
		local txt = UI.CreateFrame("SimpleTextArea", "text", tabContent)
		txt:SetPoint("TOPLEFT", tabContent, "TOPLEFT", 16, 16)
		txt:SetPoint("BOTTOMRIGHT", tabContent, "BOTTOMRIGHT", -16, -16)
		txt:SetText("")
		txt:SetBackgroundColor(0.4,0.4,0.4,1)
		rfEditors[idx] = txt
		
	end
	
end


local function rfGetConfiguration()
	local conf = rfDialog:GetValues()
	local conf2 = rfAppearance:GetValues()
	for k,v in pairs(conf2) do conf[k] = v end
	conf.macros = {}
	for idx, editor in ipairs(rfEditors) do
		local macroText = rfEditors[idx]:GetText()
		if macroText and (macroText:len() > 0) then
			conf.macros[macroTypes[idx]] = macroText
		else
			conf.macros[macroTypes[idx]] = nil 
		end
	end
	return conf
end

local function rfSetConfiguration(config)
	rfDialog:SetValues(config)
	rfAppearance:SetValues(config)
	if not config.macros then config.macros = {} end
	
	for idx, editor in ipairs(rfEditors) do
		local macroText = config.macros[macroTypes[idx]]
		if macroText and (macroText:len() > 0) then
			rfEditors[idx]:SetText(macroText)
		else
			rfEditors[idx]:SetText("")
		end
	end

end


local gfEditors = {}
local gfDialog = false
local gfAppearance = false
local function gfConfigDialog(container)

	local templateListItems = {}
	for templateId, template in pairs(WT.UnitFrame.Templates) do
		if template.Configuration.RaidSuitable then
			table.insert(templateListItems, { text=templateId .. " (" .. template.Configuration.Name .. ")", value=templateId } )
		end
	end

	local ufTabs = UI.CreateFrame("SimpleTabView", "gfTabs", container)
	ufTabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	ufTabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local frmConfig = UI.CreateFrame("Frame", "ufConfig", ufTabs.tabContent)
	local frmConfigInner = UI.CreateFrame("Frame", "ufConfigInner", frmConfig)
	frmConfigInner:SetPoint("TOPLEFT", frmConfig, "TOPLEFT", 12, 12)
	frmConfigInner:SetPoint("BOTTOMRIGHT", frmConfig, "BOTTOMRIGHT", -12, -12)

	local frmMacros = UI.CreateFrame("Frame", "rfMacros", ufTabs.tabContent)
	local frmMacrosInner = UI.CreateFrame("Frame", "rfMacrosInner", frmMacros)
	frmMacrosInner:SetPoint("TOPLEFT", frmMacros, "TOPLEFT", 4, 4)
	frmMacrosInner:SetPoint("BOTTOMRIGHT", frmMacros, "BOTTOMRIGHT", -4, -4)
	
	local frmOverride = UI.CreateFrame("Frame", "frmOverride", ufTabs.tabContent)
	local frmOverrideInner = UI.CreateFrame("Frame", "frmOverrideInner", frmOverride)
	frmOverrideInner:SetPoint("TOPLEFT", frmOverride, "TOPLEFT", 4, 4)
	frmOverrideInner:SetPoint("BOTTOMRIGHT", frmOverride, "BOTTOMRIGHT", -4, -4)

	ufTabs:SetTabPosition("top")
	ufTabs:AddTab("Configuration", frmConfig)
	ufTabs:AddTab("Mouse Macros", frmMacros)	
	ufTabs:AddTab("Appearance", frmOverride)	
	
	gfDialog = WT.Dialog(frmConfigInner)
		:Select("group", "Select Group", "Group 1", { "Group 1", "Group 2", "Group 3", "Group 4" }, false)
		:Select("template", TXT.RaidFrameTemplate, "Heal Frame", templateListItems, true)
		:Select("layout", "Layout", "Vertical", { "Vertical", "Horizontal", "LifeismysteryGroupFrame", }, false)
		:Checkbox("hideWhenEmpty", "Hide When Group Is Empty", false)
		:Checkbox("clickToTarget", TXT.EnableClickToTarget, true)
		:Checkbox("contextMenu", TXT.EnableContextMenu, true)
		:Checkbox("showBackground", TXT.ShowBackground, false)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)
		:FieldNote(TXT.ShowBackgroundNote)
		:Checkbox("reverseUnits", TXT.ReverseUnits, false)
		:Checkbox("showHoTPanel", "Show HoTs (if template allows)", false)
		:Checkbox("showDebuffPanel", "Show Debuffs (if template allows)", false)
		
	local macroTabs = UI.CreateFrame("SimpleTabView", "macroTabs", frmMacrosInner)
	macroTabs:SetTabPosition("left")
	macroTabs:SetAllPoints(frmMacrosInner)

	gfAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "Texture 68", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.5, 0, 0.85)
		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
		:TexSelect("texResource", "Resource Texture", "Texture 19", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)
--		:Checkbox("ovAbsorbTexture", "Override Absorb Texture?", false)
--		:TexSelect("texAbsorb", "Absorb Texture", "Texture 69", "bar")
		:Checkbox("ovHealthBackgroundColor", "Override Health Back color?", false)
		:ColorPicker("colHealthBackground", "Health Background Color", 0.07, 0.07, 0.07, 0.85)

	for idx, name in ipairs(macroNames) do
	
		local tabContent = UI.CreateFrame("Frame", "content", macroTabs.tabContent)
		macroTabs:AddTab(name, tabContent)
	
		local txt = UI.CreateFrame("SimpleTextArea", "text", tabContent)
		txt:SetPoint("TOPLEFT", tabContent, "TOPLEFT", 16, 16)
		txt:SetPoint("BOTTOMRIGHT", tabContent, "BOTTOMRIGHT", -16, -16)
		txt:SetText("")
		txt:SetBackgroundColor(0.4,0.4,0.4,1)
		gfEditors[idx] = txt
		
	end

end


local function gfGetConfiguration()
	local conf = gfDialog:GetValues()
	local conf2 = gfAppearance:GetValues()
	for k,v in pairs(conf2) do conf[k] = v end
	conf.macros = {}
	for idx, editor in ipairs(gfEditors) do
		local macroText = gfEditors[idx]:GetText()
		if macroText and (macroText:len() > 0) then
			conf.macros[macroTypes[idx]] = macroText
		else
			conf.macros[macroTypes[idx]] = nil 
		end
	end
	return conf
end

local function gfSetConfiguration(config)
	gfDialog:SetValues(config)
	gfAppearance:SetValues(config)

	if not config.macros then config.macros = {} end
	
	for idx, editor in ipairs(gfEditors) do
		local macroText = config.macros[macroTypes[idx]]
		if macroText and (macroText:len() > 0) then
			gfEditors[idx]:SetText(macroText)
		else
			gfEditors[idx]:SetText("")
		end
	end

end


local function CreateUnitFrame(config)

	local uf, options = WT.UnitFrame.CreateFromConfiguration(config)
	
	if config.showLeftPortrait then
	
		local elPortBorder = uf:CreateElement(
		{
			id="portraitBorder", type="Frame", parent="frameBackdrop", layer=1,
			attach=
			{
				{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPLEFT" },
				{ point="BOTTOM", element="frameBackdrop", targetPoint="BOTTOM" },
			},
			visibilityBinding="id",
			color={r=0, g=0, b=0, a=1},
		})
		
		local elPortBackdrop = uf:CreateElement(		
		{
			id="portraitBackdrop", type="MediaSet", parent="portraitBorder", layer=5, 
			attach=
			{
				{ point="TOPLEFT", element="portraitBorder", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
				{ point="BOTTOMRIGHT", element="portraitBorder", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-1 },
			},
			visibilityBinding="hostility",
			nameBinding="hostility",
			names = 
			{
				["friendly"] = "Portrait_BG_Friendly",
				["hostile"] = "Portrait_BG_Hostile",
				["neutral"] = "Portrait_BG_Neutral",
			},			
		})
		
		local elPortCalling = uf:CreateElement(
		{
			id="portraitImage", type="MediaSet", parent="portraitBorder", layer=10,
			attach=
			{
				{ point="TOPLEFT", element="portraitBackdrop", targetPoint="TOPLEFT" },
				{ point="BOTTOMRIGHT", element="portraitBackdrop", targetPoint="BOTTOMRIGHT" },
			},
			visibilityBinding="calling",
			nameBinding="calling",
			names = 
			{
				["cleric"] = "Portrait_Calling_Cleric",
				["mage"] = "Portrait_Calling_Mage",
				["rogue"] = "Portrait_Calling_Rogue",
				["warrior"] = "Portrait_Calling_Warrior",
			},			
		})

	 	local elPortElite = uf:CreateElement(
	 	{
	 		id="portraitElite", type="Image", parent="portraitBorder", layer=20,
			attach=
			{
				{ point="TOPLEFT", element="portraitBackdrop", targetPoint="TOPLEFT", offsetX=-5, offsetY=-5 },
				{ point="BOTTOMRIGHT", element="portraitBackdrop", targetPoint="BOTTOMRIGHT", offsetX=5, offsetY=5 },
			},
	 		texAddon="Rift", texFile="UpgradableNPC_I18.dds",
	 		visibilityBinding="tier",
	 	})
	 
	 	elPortBorder:EventAttach(Event.UI.Layout.Size, function(self, h)
			elPortBorder:SetWidth(elPortBorder:GetHeight())
		end, "Event.UI.Layout.Size")
	end

	if config.showRightPortrait then
	
		local elPortBorderR = uf:CreateElement(
		{
			id="portraitBorderR", type="Frame", parent="frameBackdrop", layer=1,
			attach=
			{
				{ point="TOPLEFT", element="frameBackdrop", targetPoint="TOPRIGHT" },
				{ point="BOTTOM", element="frameBackdrop", targetPoint="BOTTOM" },
			},
			visibilityBinding="id",
			color={r=0, g=0, b=0, a=1},
		})
		
		local elPortBackdropR = uf:CreateElement(		
		{
			id="portraitBackdropR", type="MediaSet", parent="portraitBorderR", layer=5,
			attach=
			{
				{ point="TOPLEFT", element="portraitBorderR", targetPoint="TOPLEFT", offsetX=0, offsetY=1 },
				{ point="BOTTOMRIGHT", element="portraitBorderR", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 },
			},
			visibilityBinding="hostility",
			nameBinding="hostility",
			names = 
			{
				["friendly"] = "Portrait_BG_Friendly",
				["hostile"] = "Portrait_BG_Hostile",
				["neutral"] = "Portrait_BG_Neutral",
			},			
		})
		
		local elPortCallingR = uf:CreateElement(
		{
			id="portraitImageR", type="MediaSet", parent="portraitBorderR", layer=10,
			attach=
			{
				{ point="TOPLEFT", element="portraitBackdropR", targetPoint="TOPLEFT" },
				{ point="BOTTOMRIGHT", element="portraitBackdropR", targetPoint="BOTTOMRIGHT" },
			},
			visibilityBinding="calling",
			nameBinding="calling",
			names = 
			{
				["cleric"] = "Portrait_Calling_Cleric",
				["mage"] = "Portrait_Calling_Mage",
				["rogue"] = "Portrait_Calling_Rogue",
				["warrior"] = "Portrait_Calling_Warrior",
			},			
		})
	 
	 	local elPortEliteR = uf:CreateElement(
	 	{
	 		id="portraitEliteR", type="Image", parent="portraitBorderR", layer=20,
			attach=
			{
				{ point="TOPLEFT", element="portraitBackdropR", targetPoint="TOPLEFT", offsetX=-5, offsetY=-5 },
				{ point="BOTTOMRIGHT", element="portraitBackdropR", targetPoint="BOTTOMRIGHT", offsetX=5, offsetY=5 },
			},
	 		texAddon="Rift", texFile="UpgradableNPC_I18.dds",
	 		visibilityBinding="tier",
	 	})
	 
	 	elPortBorderR:EventAttach(Event.UI.Layout.Size, function(self, h)
			elPortBorderR:SetWidth(elPortBorderR:GetHeight())
		end, "Event.UI.Layout.Size")
	end
	
	return uf, options
	
end


-- Register as a gadget factory for creating unit frames from templates
WT.Gadget.RegisterFactory("UnitFrame",
	{
		name=TXT.gadgetUnitFrame_name,
		description=TXT.gadgetUnitFrame_desc,
		author="Wildtide",
		version="0.1.3",
		["Create"] = CreateUnitFrame, -- WT.UnitFrame.CreateFromConfiguration,
		["ConfigDialog"] = ufConfigDialog,
		["GetConfiguration"] = ufGetConfiguration,
		["SetConfiguration"] = ufSetConfiguration,
	})

WT.Gadget.RegisterFactory("RaidFrames",
	{
		name=TXT.gadgetRaidFrames_name,
		description=TXT.gadgetRaidFrames_desc,
		author="Wildtide",
		version="0.1.3",
		["Create"] = WT.UnitFrame.CreateRaidFramesFromConfiguration,
		["ConfigDialog"] = rfConfigDialog,
		["GetConfiguration"] = rfGetConfiguration,
		["SetConfiguration"] = rfSetConfiguration,
	})

WT.Gadget.RegisterFactory("GroupFrames",
	{
		name=TXT.gadgetGroupFrames_name,
		description=TXT.gadgetGroupFrames_desc,
		author="Wildtide",
		version="1.0.0",
		["Create"] = WT.UnitFrame.CreateGroupFramesFromConfiguration,
		["ConfigDialog"] = gfConfigDialog,
		["GetConfiguration"] = gfGetConfiguration,
		["SetConfiguration"] = gfSetConfiguration,
	})

