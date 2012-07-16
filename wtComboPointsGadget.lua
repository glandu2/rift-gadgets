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


-- wtComboPoints provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local deferSetup = {}
local calling = nil

local function Setup(unitFrame, configuration)

	local img = nil
	 
	if calling == "rogue" then 
		img = "img/wtComboBlue.png"
	else
		img = "img/wtComboRed.png"
	end
	
	unitFrame:CreateElement(
	{
		id="imgCombo", type="ImageSet", parent="frame", layer=10,
		attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" }},	
		indexBinding="comboIndex", rows=5, cols=1,
		visibilityBinding="comboIndex",		
		texAddon=AddonId, texFile=img,
	});

end


local function Create(configuration)

	calling = Inspect.Unit.Detail("player").calling 

	local comboPoints = WT.UnitFrame:Create("player")
	comboPoints:SetWidth(193)
	comboPoints:SetHeight(36)

	if calling then
		Setup(comboPoints, configuration)
	else
		table.insert(deferSetup, { unitFrame = comboPoints, configuration = configuration })
	end

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
		name=TXT.gadgetComboPoints_name,
		description=TXT.gadgetComboPoints_desc,
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

local function OnPlayerAvailable()
	calling = Inspect.Unit.Detail("player").calling
	for idx, entry in ipairs(deferSetup) do
		Setup(entry.unitFrame, entry.configuration)
	end
end

table.insert(WT.Event.PlayerAvailable, {OnPlayerAvailable, AddonId, "ComboPointsGadget_OnPlayerAvailable"})	
