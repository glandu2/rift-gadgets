--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]
 
local STR = WT.Strings

-- Setup default (English) localization for this addon
STR.Load("en", 
{
	UnitToTrack = "Unit to Track",
	UnitFrameTemplate = "Unit Frame Template",
	RaidFrameTemplate = "Raid Frame Template",
	ExcludeBuffsNote = "Templates that support this option will not create any Buff panels if this option is selected. This allows you to use a seperate Buff panel gadget instead, which provides more flexibility.",
	ClickThroughNote = "Please be aware, due to restrictions in the Rift API, enabling click functionality for frames means you will not be able to click on units in the world behind the frames, even when they are invisible. For this reason, the Raid Frames will display a dim rectangle behind the frames when clicking is enabled, as a hint that there is something in the way!",
	EnableContextMenu = "Enable context menu on right click",
	EnableClickToTarget = "Enable click to target",
})

-- Google Translate, sorry!
STR.Load("de", 
{
	UnitToTrack = "Einheit zu verfolgen",
	UnitFrameTemplate = "Einheit-Rahmen-Schablone",
	RaidFrameTemplate = "Raid-Rahmen-Schablone",
})

-- Google Translate, sorry!
STR.Load("fr", 
{
	UnitToTrack = "Unité à suivre",
	UnitFrameTemplate = "Modèle Cadre Unité",
	RaidFrameTemplate = "Modèle Cadre Raid",
	EnableContextMenu = "Menu contextuel sur clic droit",
	EnableClickToTarget = "Activer cliquez pour cibler",
})
