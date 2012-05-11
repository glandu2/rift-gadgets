--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

local chargeFontSize = 18

-- Displays current Planar Charge count

local function Create(configuration)

	local vitalityMeter = WT.UnitFrame:Create("player")
	vitalityMeter:SetWidth(48)
	vitalityMeter:SetHeight(48)
	vitalityMeter:SetLayer(100)

	vitalityMeter.img = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="ImageSet", parent="frame", layer=0, alpha=1.0,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
		},
		texAddon=AddonId, texFile="img/wtVitality.png", rows=10,cols=1,
		indexBinding="vitalityIndex", visibilityBinding="vitalityIndex",width=48,height=48,
	});
	vitalityMeter.txtVitality = vitalityMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="txtVitality", type="Label", parent="imgCharge", layer=20,
		attach = {{ point="CENTER", element="imgCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{vitality}%", fontSize=chargeFontSize,
	});
	vitalityMeter.txtVitality:SetVisible(false)

	vitalityMeter.Event.MouseIn = function() vitalityMeter.txtVitality:SetVisible(true) end
	vitalityMeter.Event.MouseOut = function() vitalityMeter.txtVitality:SetVisible(false) end

	vitalityMeter.OnResize = function(frame, width,height)
		vitalityMeter.txtVitality:SetFontSize(height*0.35)
		vitalityMeter.img:SetWidth(width)
		vitalityMeter.img:SetHeight(height)
	end

	vitalityMeter:ApplyBindings()

	return vitalityMeter, { resizable = { 24,24, 64,64 } }
end


WT.Gadget.RegisterFactory("SoulVitality",
	{
		name=TXT.gadgetSoulVitality_name,
		description=TXT.gadgetSoulVitality_desc,
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