--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

local chargeFontSize = 18

-- Displays current Planar Charge count

local function Create(configuration)

	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetWidth(48)
	chargeMeter:SetHeight(48)
	chargeMeter:SetLayer(100)

	chargeMeter.img = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="ImageSet", parent="frame", layer=0, alpha=1.0,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
		},
		texAddon=AddonId, texFile="img/wtVitality.png", rows=10,cols=1,
		indexBinding="vitalityIndex", visibilityBinding="vitalityIndex",width=48,height=48,
	});
	chargeMeter.txtVitality = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="txtVitality", type="Label", parent="imgCharge", layer=20,
		attach = {{ point="CENTER", element="imgCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{vitality}%", fontSize=chargeFontSize,
	});
	chargeMeter.txtVitality:SetVisible(false)

	chargeMeter.Event.MouseIn = function() chargeMeter.txtVitality:SetVisible(true) end
	chargeMeter.Event.MouseOut = function() chargeMeter.txtVitality:SetVisible(false) end

	chargeMeter.OnResize = function(frame, width,height)
		chargeMeter.txtVitality:SetFontSize(height*0.35)
		chargeMeter.img:SetWidth(width)
		chargeMeter.img:SetHeight(height)
	end

	return chargeMeter, { resizable = { 24,24, 64,64 } }
end


WT.Gadget.RegisterFactory("SoulVitality",
	{
		name="Soul Vitality",
		description="Displays Soul Vitality",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtSoulVitality.png",
		["Create"] = Create,
	})

WT.Unit.CreateVirtualProperty("vitalityIndex", {"vitality", "vitalityMax"}, 
	function(unit)
		local vitality = unit.vitality
		if not vitality then return nil end 
		if vitality > 90 then 
			return nil
			elseif vitality > 80 then return 1
			elseif vitality > 70 then return 2
			elseif vitality > 60 then return 3
			elseif vitality > 50 then return 4
			elseif vitality > 40 then return 5
			elseif vitality > 30 then return 6
			elseif vitality > 20 then return 7
			elseif vitality > 10 then return 8
			elseif vitality > 0 then return 9
			else return 10
		end
	end)