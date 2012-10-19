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
		:Select("template", TXT.UnitFrameTemplate, "StandardFrame", templateListItems, true)
		:Checkbox("excludeBuffs", "Hide Buffs on Frame", false)
		:Checkbox("excludeCasts", "Hide Castbars on Frame", false)
		:Checkbox("ownBuffs", "Only show my buffs", true)
		:Checkbox("ownDebuffs", "Only show my debuffs", false)
		:FieldNote(TXT.ExcludeBuffsNote)
		:Checkbox("clickToTarget", TXT.EnableClickToTarget, true)
		:Checkbox("contextMenu", TXT.EnableContextMenu, true)
		:Checkbox("showBackground", TXT.ShowBackground, true)
		:FieldNote(TXT.ShowBackgroundNote)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)

	ufAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "wtDiagonal", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.7, 0, 1)
		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
		:TexSelect("texResource", "Resource Texture", "wtBantoBar", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)
		
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
		:Select("template", TXT.RaidFrameTemplate, "OctanusRaidFrame", templateListItems, true)
		:Select("layout", "Layout", "4 x 5", { "4 x 5", "5 x 4", "2 x 10", "10 x 2", "1 x 20", "20 x 1" }, false)
		:Checkbox("showBackground", TXT.ShowBackground, true)
		:FieldNote(TXT.ShowBackgroundNote)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)
		:Checkbox("reverseGroups", TXT.ReverseGroups, false)
		:Checkbox("reverseUnits", TXT.ReverseUnits, false)

	local macroTabs = UI.CreateFrame("SimpleTabView", "macroTabs", frmMacrosInner)
	macroTabs:SetTabPosition("left")
	macroTabs:SetAllPoints(frmMacrosInner)

	rfAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "wtDiagonal", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.7, 0, 1)
		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
		:TexSelect("texResource", "Resource Texture", "wtBantoBar", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)
	
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
	
	local frmOverride = UI.CreateFrame("Frame", "frmOverride", ufTabs.tabContent)
	local frmOverrideInner = UI.CreateFrame("Frame", "frmOverrideInner", frmOverride)
	frmOverrideInner:SetPoint("TOPLEFT", frmOverride, "TOPLEFT", 4, 4)
	frmOverrideInner:SetPoint("BOTTOMRIGHT", frmOverride, "BOTTOMRIGHT", -4, -4)

	ufTabs:SetTabPosition("top")
	ufTabs:AddTab("Configuration", frmConfig)
	ufTabs:AddTab("Appearance", frmOverride)	
	
	gfDialog = WT.Dialog(frmConfigInner)
		:Select("group", "Select Group", "Group 1", { "Group 1", "Group 2", "Group 3", "Group 4" }, false)
		:Select("template", TXT.RaidFrameTemplate, "OctanusRaidFrame", templateListItems, true)
		:Select("layout", "Layout", "Vertical", { "Vertical", "Horizontal" }, false)
		:Checkbox("clickToTarget", TXT.EnableClickToTarget, true)
		:Checkbox("contextMenu", TXT.EnableContextMenu, true)
		:Checkbox("showBackground", TXT.ShowBackground, true)
		:Checkbox("showAbsorb", TXT.ShowAbsorb, true)
		:FieldNote(TXT.ShowBackgroundNote)
		:Checkbox("reverseUnits", TXT.ReverseUnits, false)

	gfAppearance = WT.Dialog(frmOverrideInner)
		:Checkbox("ovHealthTexture", "Override Health Texture?", false)
		:TexSelect("texHealth", "Health Texture", "wtDiagonal", "bar")
--		:Checkbox("ovHealthColor", "Override Health Color?", false)
--		:ColorPicker("colHealth", "Health Color", 0, 0.7, 0, 1)
		:Checkbox("ovResourceTexture", "Override Resource Texture?", false)
		:TexSelect("texResource", "Resource Texture", "wtBantoBar", "bar")
--		:Checkbox("ovResourceColor", "Override Resource Color?", false)
--		:ColorPicker("colResource", "Resource Color", 0.4, 0.6, 0.8, 1)

end


local function gfGetConfiguration()
	local conf = gfDialog:GetValues()
	local conf2 = gfAppearance:GetValues()
	for k,v in pairs(conf2) do conf[k] = v end
	return conf
end

local function gfSetConfiguration(config)
	gfDialog:SetValues(config)
	gfAppearance:SetValues(config)
end


-- Register as a gadget factory for creating unit frames from templates
WT.Gadget.RegisterFactory("UnitFrame",
	{
		name=TXT.gadgetUnitFrame_name,
		description=TXT.gadgetUnitFrame_desc,
		author="Wildtide",
		version="0.1.3",
		["Create"] = WT.UnitFrame.CreateFromConfiguration,
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

