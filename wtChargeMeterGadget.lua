--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.7.2
      Project Date (UTC)  : 2014-12-06T23:42:32Z
      File Modified (UTC) : 2013-01-04T22:17:01Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


-- wtChargeMeter provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local function Create(configuration)

	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetWidth(170)
	chargeMeter:SetHeight(30)
	chargeMeter:SetBackgroundColor(0,0,0,0.4)
	
	chargeMeter.mediaInterrupt = Library.Media.GetTexture(configuration.texture)
	
	if not configuration.insertBar == true then
	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="barCharge", type="Bar", parent="frame", layer=10,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 },
		},
		binding="chargePercent", color={r=0,g=0.8,b=0.8,a=0.8},
		--texAddon="wtLibUnitFrame", texFile="img/Glaze2.png",
		media=configuration.texture,
		backgroundColor={r=0, g=0, b=0, a=0.4}
	});
	else
		chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="barCharge", type="BarHealth", parent="frame", layer=10,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 },
		},
		binding="chargePercent", color={r=0,g=0.8,b=0.8,a=0.8},
		--texAddon="wtLibUnitFrame", texFile="img/Glaze2.png",
		media=configuration.texture,
		growthDirection="left",
		backgroundColor={r=0, g=0, b=0, a=0.4}
		});
	end
	
	if configuration.chargeLabel == true or configuration.chargeLabel == nil then	
	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTER", element="barCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{chargePercent}%", fontSize=14, font = "blank-Bold", outline=true,
	});
end
	return chargeMeter, { resizable = { 140, 5, 500, 50 } }
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "CastBar", "Reconfigure Gadget is not a castbar")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false

	if gadgetConfig.texture ~= config.texture then
		gadgetConfig.texture = config.texture
		gadget.mediaInterrupt = Library.Media.GetTexture(config.texture)
	end	
end

local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The Charge Meter displays the current charge. Only useful for mages, this gadget exists so that a standard Unit Frame doesn't have to handle the extra bar within it's layout.")
		:Checkbox("chargeLabel", "Show charge text?", true)
		:Checkbox("insertBar", "Insert Bar?", false)
		:TexSelect("texture", "Texture", "Texture 82", "bar")
		end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("ChargeMeter",
	{
		name=TXT.gadgetChargeMeter_name,
		description=TXT.gadgetChargeMeter_desc,
		author="Wildtide",
		version="1.1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCharge.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

