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


-- wtRangeFinder creates a simple Range to Target UnitFrame

local gadgetIndex = 0

local playerFrame = WT.UnitFrame:Create("player")
local rangeFinders = {}

local function OnNameChange(rangeFinder, name)
	if not name then
		rangeFinder.txtRange:SetVisible(false)
		rangeFinder.txtName:SetVisible(false)
		if rangeFinder.hideWhenNoTarget then
			rangeFinder.background:SetVisible(false)
		end
	else
		rangeFinder.txtRange:SetVisible(true)
		rangeFinder.txtName:SetVisible(true)
		rangeFinder.background:SetVisible(true)
		local nm = name:upper()
		if nm:len() > 25 then nm = nm:sub(1, 25) end
		rangeFinder.txtName:SetText(nm)
	end
end

local function OnCoordChange(rangeFinder, unitCoord)
	if not WT.Player then return end
	if not WT.Player.coord then return end
	if not unitCoord then return end

	if WT.Player.coord and unitCoord then
		local range = WT.Utility.MeasureDistance(
			WT.Player.coord[1], WT.Player.coord[2], WT.Player.coord[3],
			unitCoord[1], unitCoord[2], unitCoord[3])  
		rangeFinder.txtRange:SetLabelText(string.format("%.01f", range) .. "m")
	else
		rangeFinder.txtRange:SetLabelText("--")
	end
end

local function OnPlayerCoordChange(rangeFinder, playerCoord)
	for idx,rangeFinder in ipairs(rangeFinders) do
		rangeFinder:ApplyBindings()		
	end
end

local function Create(configuration)

	local rfHeight = 70

	local rangeFinder = WT.UnitFrame:Create("player.target")
	rangeFinder:SetWidth(150)

	local rfBackground = UI.CreateFrame("Frame", "rfBackground", rangeFinder)
	rfBackground:SetAllPoints(rangeFinder)
	if configuration.showBackground then
		rfBackground:SetBackgroundColor(0,0,0,0.4)
	end

	rangeFinder.background = rfBackground

	local txtHeading = UI.CreateFrame("Text", WT.UniqueName("RangeFinder"), rfBackground)
	txtHeading:SetText("RANGE TO TARGET")
	txtHeading:SetPoint("TOPCENTER", rangeFinder, "TOPCENTER", 0, 6)
	txtHeading:SetFontSize(10)
	txtHeading:SetFontColor(0.6, 1.0, 0.6, 1.0)
		
	--[[
	local txtRange = UI.CreateFrame("Text", WT.UniqueName("RangeFinder"), rfBackground)
	txtRange:SetText("--")
	txtRange:SetPoint("TOPCENTER", txtHeading, "BOTTOMCENTER", 0, -5)
	txtRange:SetFontSize(24)
	txtRange:SetFontColor(0.6, 1.0, 0.6, 1.0)
	--]]
	
	local txtRange = rangeFinder:CreateElement({
		id="txtRange", type="Label", parent=rfBackground, layer=20,
		attach = {{ point="TOPCENTER", element=txtHeading, targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-5 }},
		visibilityBinding="name", text="--", default="", fontSize=24, outline=true,
		color={ r=0.6, g=1.0, b=0.6, a=1.0 },
	});

	local txtName = UI.CreateFrame("Text", WT.UniqueName("RangeFinder"), rfBackground)
	txtName:SetText("")
	txtName:SetPoint("TOPCENTER", txtRange, "BOTTOMCENTER", 0, -5)
	txtName:SetFontSize(10)
	txtName:SetFontColor(0.6, 1.0, 0.6, 1.0)
	rangeFinder.txtName = txtName

	if not configuration.showTargetName then
		txtName:SetHeight(0) 
		rfHeight = rfHeight - 17
	end

	if not configuration.showTitle then
		txtHeading:SetHeight(0) 
		rfHeight = rfHeight - 17
	end

	rangeFinder.hideWhenNoTarget = configuration.hideWhenNoTarget 
	rangeFinder:SetHeight(rfHeight)
	rangeFinder.txtRange = txtRange
	
	rangeFinder:CreateBinding("name", rangeFinder, OnNameChange, nil)
	rangeFinder:CreateBinding("coord", rangeFinder, OnCoordChange, nil)
	playerFrame:CreateBinding("coord", playerFrame, OnPlayerCoordChange, nil)
	
	table.insert(rangeFinders, rangeFinder)
	
	return rangeFinder
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The Range Finder dispays the distance, in meters, between you and your target. It reports the distance from the center of your character to the center of the target. An option will be added in future to take the radius of the characters into account.")
		:Checkbox("showTitle", TXT.ShowTitle, true)
		:Checkbox("showTargetName", TXT.ShowTargetName, true)
		:Checkbox("hideWhenNoTarget", TXT.HideWhenNoTarget, false)
		:Checkbox("showBackground", TXT.ShowBackground, true)
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("RangeFinder",
	{
		name=TXT.gadgetRangeFinder_name,
		description=TXT.gadgetRangeFinder_desc,
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtRangeFinder.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

