--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]
 
-- Setup default (English) localization for this addon
Library.Translate.En( 
{
	-- Gadget Names and Descriptions
	gadgetChargeMeter_name = "Charge Meter",
	gadgetChargeMeter_desc = "The Charge Meter displays the current charge. Only useful for mages, this gadget exists so that a standard Unit Frame doesn't have to handle the extra bar within it's layout.",

	gadgetComboPoints_name = "Combo Points",
	gadgetComboPoints_desc = "Combo or Attack Points",

	gadgetCPU_name = "CPU Monitor",
	gadgetCPU_desc = "Displays Addon CPU Usage",
	
	gadgetFPS_name = "FPS Monitor",
	gadgetFPS_desc = "Displays Frames per Second",

	gadgetPlanarCharge_name = "Planar Charge",
	gadgetPlanarCharge_desc = "Displays Planar Charge",

	gadgetRangeFinder_name = "Range Finder",
	gadgetRangeFinder_desc = "Displays Range to Target",

	gadgetReloadUI_name = "Reload UI",
	gadgetReloadUI_desc = "Reload UI Button",

	gadgetSoulVitality_name = "Soul Vitality",
	gadgetSoulVitality_desc = "Displays Soul Vitality",

	gadgetUnitFrame_name = "Unit Frame",
	gadgetUnitFrame_desc = "Unit Frame Gadget",

	gadgetRaidFrames_name = "Raid Frames",
	gadgetRaidFrames_desc = "Raid Frames Gadget",

	UnitToTrack = "Unit to Track",
	UnitFrameTemplate = "Unit Frame Template",
	RaidFrameTemplate = "Raid Frame Template",
	ExcludeBuffsNote = "Templates that support this option will not create any Buff panels if this option is selected. This allows you to use a seperate Buff panel gadget instead, which provides more flexibility.",
	ClickThroughNote = "Please be aware, due to restrictions in the Rift API, enabling click functionality for frames means you will not be able to click on units in the world behind the frames, even when they are invisible. For this reason, the Raid Frames will display a dim rectangle behind the frames when clicking is enabled, as a hint that there is something in the way!",
	EnableContextMenu = "Enable context menu on right click",
	EnableClickToTarget = "Enable click to target",
})

Library.Translate.De( 
{
})

Library.Translate.Fr( 
{
})
