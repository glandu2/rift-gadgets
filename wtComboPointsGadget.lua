--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- wtComboPoints provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local calling = ""

local function Create(configuration)

	calling = Inspect.Unit.Detail("player").calling 

	local comboPoints = WT.UnitFrame:Create("player")
	comboPoints:SetWidth(193)
	comboPoints:SetHeight(36)

	local img = "img/wtComboRed.png"

	if calling == "rogue" then img = "img/wtComboBlue.png" end
	
	comboPoints:CreateElement(
	{
		id="imgCombo", type="ImageSet", parent="frame", layer=10,
		attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" }},	
		indexBinding="comboIndex", rows=5, cols=1,
		visibilityBinding="comboIndex",		
		texAddon=AddonId, texFile=img,
	});
	

	return comboPoints
end

local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The Combo Points gadget displays current combo (Rogue) or attack (Warrior) points for the player.")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("ComboPoints",
	{
		name="Combo Points",
		description="Combo or Attack Points",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtComboPoints.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})


WT.Unit.CreateVirtualProperty("comboIndex", { "combo", "comboUnit" },
	function(unit)
		if not unit.combo or unit.combo == 0 then
			return nil
		else
			return unit.combo - 1
		end
	end)
	
table.insert(Library.LibUnitChange.Register("player.target"), 
{ 
	function(unitId) 
		if not WT.Player then return end
		if calling ~= "rogue" then return end
		if unitId and unitId == WT.Player.comboUnit and WT.Player.combo and WT.Player.combo > 0 then 
			WT.Player.comboIndex = WT.Player.combo - 1
		else
			WT.Player.comboIndex = nil
		end 
	end,  AddonId, AddonId .. "_ComboUnitChange" 
})

	
