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

data.wtHealer = data.wtHealer or {}

data.wtHealer.CellTemplate =
{
	{
		id="frameBlocked", 
		type="Frame", 
		parent="frame", 
		layer=15, 
		visibilityBinding="blockedOrOutOfRange",
		color={r=0,g=0,b=0},
		alpha=0.6,
		attach = 
		{ 
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 } 
		},
	},
	 
	{
		id="barResource", 
		type="Bar", 
		parent="frame", 
		layer=10,
		attach = {
			{ point="BOTTOMLEFT", element="frame", targetPoint="BOTTOMLEFT", offsetX=2, offsetY=-2 },
			{ point="TOPRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-2, offsetY=-4 },
		},
		binding="resourcePercent", 
		height=raidFrameBottomBarHeight, 
		colorBinding="resourceColor",
		media="wtBantoBar",
		backgroundColor={r=0, g=0, b=0, a=1}
	},
	
	{
		id="barHealth", 
		type="Bar", 
		parent="frame", 
		layer=10,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=2, offsetY=2 },
			{ point="BOTTOMRIGHT", element="barResource", targetPoint="TOPRIGHT", offsetX=0, offsetY=0 },
		},
		growthDirection="right",
		binding="healthPercent", 
		colorBinding="raidHealthColor",
		media="wtHealbot",
		backgroundColor={r=0, g=0, b=0, a=1},
	},
	
	{
		id="barAbsorb", 
		type="Bar", 
		parent="frame", 
		layer=11,
		attach = {
			{ point="BOTTOMLEFT", element="barHealth", targetPoint="BOTTOMLEFT", offsetX=0, offsetY=0 },
			{ point="TOPRIGHT", element="barHealth", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-4 },
		},
		growthDirection="right",
		binding="absorbPercent", 
		color={r=0,g=1,b=1,a=1},
		media="wtBantoBar", 
		backgroundColor={r=0, g=0, b=0, a=0},
	},
	
	{
		id="imgRole", 
		type="MediaSet", 
		parent="frame", 
		layer=20,
		attach = {
			{ point="CENTER", element="barHealth", targetPoint="TOPLEFT", offsetX=2, offsetY=2 }
		}, 
		visibilityBinding="role",
		nameBinding="role", 
		names = { 
			["tank"] = "octanusTank", 
			["heal"] = "octanusHeal", 
			["dps"] = "octanusDPS", 
			["support"] = "octanusSupport" 
		},
	},	
		
	{
		id="labelName", 
		type="Label", 
		parent="frame", 
		layer=20,
		attach = {
			{ point="CENTER", element="barHealth", targetPoint="CENTER", offsetX=0, offsetY=0 }
		},
		visibilityBinding="name",
		text="{name}", 
		maxLength=5, 
		default="", 
		fontSize=12, 
		outline=true,
		colorBinding="callingColor",
	},
	
	{
		id="labelStatus", 
		type="Label", 
		parent="frame", 
		layer=20,
		attach = {
			{ point="BOTTOMCENTER", element="frame", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-4 }
		},
		visibilityBinding="raidStatus",
		text=" {raidStatus}", 
		default="", 
		fontSize=11,
	},
	
	{
	    id="imgMark", 
	    type="MediaSet", 
	    parent="frame", 
	    layer=30,
	    attach = {
	    	{ point="TOPRIGHT", element="frame", targetPoint="TOPRIGHT", offsetX=-3, offsetY=4 }
	    },
	    width = 12, 
	    height = 12,
	    nameBinding="mark",
	    names = 
	    {
	        ["1"] = "riftMark01_mini",
	        ["2"] = "riftMark02_mini",
	        ["3"] = "riftMark03_mini",
	        ["4"] = "riftMark04_mini",
	        ["5"] = "riftMark05_mini",
	        ["6"] = "riftMark06_mini",
	        ["7"] = "riftMark07_mini",
	        ["8"] = "riftMark08_mini",
	        ["9"] = "riftMark09_mini",
	        ["10"] = "riftMark10_mini",
	        ["11"] = "riftMark11_mini",
	        ["12"] = "riftMark12_mini",
	        ["13"] = "riftMark13_mini",
	        ["14"] = "riftMark14_mini",
	        ["15"] = "riftMark15_mini",
	        ["16"] = "riftMark16_mini",
	        ["17"] = "riftMark17_mini",
	    },
	    visibilityBinding="mark",
	    alpha=1.0,
	},
	
	{
		id="imgReady", 
		type="ImageSet", 
		parent="frame", 
		layer=30,
		attach = {
			{ point="CENTER", element="frame", targetPoint="CENTER" }
		},
		texAddon=AddonId, 
		texFile="img/wtReady.png", 
		nameBinding="readyStatus", 
		cols=1, 
		rows=2, 
		names = { 
			["ready"] = 0, 
			["notready"] = 1 
		}, 
		defaultIndex = "hide",
	},
	
	{
		id="buffPanelDebuffs", 
		type="BuffPanel", 
		parent="frame", 
		layer=30,
		attach = {
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 }
		},
		rows=1, 
		cols=3, 
		iconSize=16, 
		iconSpacing=1, 
		borderThickness=1, 
		acceptLowPriorityBuffs=false, 
		acceptMediumPriorityBuffs=false, 
		acceptHighPriorityBuffs=false, 
		acceptCriticalPriorityBuffs=false,
		acceptLowPriorityDebuffs=true, 
		acceptMediumPriorityDebuffs=true, 
		acceptHighPriorityDebuffs=true, 
		acceptCriticalPriorityDebuffs=true,
		growthDirection = "left_up"
	},
	
}
