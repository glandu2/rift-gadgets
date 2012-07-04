--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

local exampleBuff = "Data/\\UI\\ability_icons\\discombobulate2a.dds"

local function Create(configuration)

	local buffsPanel = WT.UnitFrame:Create(configuration.unitSpec)
	buffsPanel:SetWidth(128)
	buffsPanel:SetHeight(128)

	local showBuffs = WT.Utility.ToBoolean(configuration.showBuffs)
	local showDebuffs = WT.Utility.ToBoolean(configuration.showDebuffs)

	buffsPanel.panel = buffsPanel:CreateElement(
	{
		id="buffPanel", type="BuffPanel", parent="HorizontalBar", layer=30,
		attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=0, offsetY=0 }},
		rows=4, cols=4, iconSize=32, iconSpacingHorizontal=0, iconSpacingVertical=13, borderThickness=1,
		acceptLowPriorityBuffs=showBuffs, acceptMediumPriorityBuffs=showBuffs, acceptHighPriorityBuffs=showBuffs, acceptCriticalPriorityBuffs=showBuffs,
		acceptLowPriorityDebuffs=showDebuffs, acceptMediumPriorityDebuffs=showDebuffs, acceptHighPriorityDebuffs=showDebuffs, acceptCriticalPriorityDebuffs=showDebuffs,
		growthDirection = "right_down", selfCast=false,
		timerSize=10, timerOffsetX=0, timerOffsetY=19,
		stackSize=12, stackOffsetX=0, stackOffsetY=0, stackBackgroundColor={r=0,g=0,b=0,a=0.7},
		borderColor={r=0,g=0,b=0,a=1},
		sweepOverlay=true,
	})

	return buffsPanel
end

local dialog = false

local function ConfigDialog(container)

	dialog = WT.Dialog(container)
		:Label("The buffs gadget shows buffs or debuffs on a unit")
		:Combobox("unitSpec", TXT.UnitToTrack, "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		:Checkbox("showBuffs", "Show Buffs", true)
		:Checkbox("showDebuffs", "Show Debuffs", false)
	
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("BuffsPanel",
	{
		name="Buffs Gadget",
		description="Buffs and Debuffs",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

