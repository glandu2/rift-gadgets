--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

local STR = WT.Strings

local controls = {}

local ufDialog = false
local function ufConfigDialog(container)

	local templateListItems = {}
	for templateId, template in pairs(WT.UnitFrame.Templates) do
		table.insert(templateListItems, { text=templateId .. " (" .. template.Configuration.Name .. ")", value=templateId } )
	end

	ufDialog = WT.Dialog(container)
		:Combobox("unitSpec", STR.UnitToTrack, "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		:Combobox("template", STR.RaidFrameTemplate, "StandardFrame", templateListItems, true)
		:Checkbox("excludeBuffs", "Hide Buffs on Frame", false)
		:FieldNote(STR.ExcludeBuffsNote)
		:Checkbox("clickToTarget", STR.EnableClickToTarget, true)
		:Checkbox("contextMenu", STR.EnableContextMenu, true)
		:FieldNote(STR.ClickThroughNote)
end

local function ufGetConfiguration()
	local config = ufDialog:GetValues()
	return config
end

local function ufSetConfiguration(config)
	ufDialog:SetValues(config)
end

local rfDialog = false
local function rfConfigDialog(container)

	local templateListItems = {}
	for templateId, template in pairs(WT.UnitFrame.Templates) do
		if template.Configuration.RaidSuitable then
			table.insert(templateListItems, { text=templateId .. " (" .. template.Configuration.Name .. ")", value=templateId } )
		end
	end

	rfDialog = WT.Dialog(container)
		:Combobox("template", STR.RaidFrameTemplate, "RaidFrame", templateListItems, true)
		:Combobox("layout", "Layout", "4 x 5", { "4 x 5", "5 x 4", "2 x 10", "10 x 2", "1 x 20", "20 x 1" }, false)
		:Checkbox("clickToTarget", STR.EnableClickToTarget, true)
		:Checkbox("contextMenu", STR.EnableContextMenu, true)
			:FieldNote(STR.ClickThroughNote)

end


local function rfGetConfiguration()
	return rfDialog:GetValues()
end

local function rfSetConfiguration(config)
	rfDialog:SetValues(config)
end

-- Register as a gadget factory for creating unit frames from templates
WT.Gadget.RegisterFactory("UnitFrame",
	{
		name="Unit Frame",
		description="Unit Frame gadget",
		author="Wildtide",
		version="0.1.3",
		["Create"] = WT.UnitFrame.CreateFromConfiguration,
		["ConfigDialog"] = ufConfigDialog,
		["GetConfiguration"] = ufGetConfiguration,
		["SetConfiguration"] = ufSetConfiguration,
	})

WT.Gadget.RegisterFactory("RaidFrames",
	{
		name="Raid Frames",
		description="Raid frames gadget",
		author="Wildtide",
		version="0.1.3",
		["Create"] = WT.UnitFrame.CreateRaidFramesFromConfiguration,
		["ConfigDialog"] = rfConfigDialog,
		["GetConfiguration"] = rfGetConfiguration,
		["SetConfiguration"] = rfSetConfiguration,
	})

