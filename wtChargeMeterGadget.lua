--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- wtChargeMeter provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local function Create(configuration)

	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetWidth(170)
	chargeMeter:SetHeight(30)
	chargeMeter:SetBackgroundColor(0,0,0,0.4)

	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="barCharge", type="Bar", parent="frame", layer=10,
		attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 }},
		binding="chargePercent", width=168, height=28, color={r=0,g=0.8,b=0.8,a=0.8},
		texAddon="wtLibUnitFrame", texFile="img/Glaze2.png",
		backgroundColor={r=0, g=0, b=0, a=0.4}
	});
	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTER", element="barCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{chargePercent}% CHARGE", fontSize=10,
	});

	return chargeMeter
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The Charge Meter displays the current charge. Only useful for mages, this gadget exists so that a standard Unit Frame doesn't have to handle the extra bar within it's layout.")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("ChargeMeter",
	{
		name="Charge Meter",
		description="Display Mage's Charge",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCharge.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

