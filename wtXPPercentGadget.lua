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


-- wtXPPercent Gadget - a simple % display of current XP

local gadgetIndex = 0
local xpGadgets = {}


local function OnExperience(hEvent, accum, rested, needed)

	if not accum then return end
	if not needed then return end

	local percent = (accum / needed) * 100
	local percentString = string.format("%i", math.floor(percent)) .. "%"
	for idx, gadget in ipairs(xpGadgets) do
		gadget:SetText(percentString)
		gadget.detail:SetText(WT.Utility.NumberDesc(accum) .. "/" .. WT.Utility.NumberDesc(needed))
	end
end


local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtXP"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(64)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local xpHeading = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	xpHeading:SetText("EXPERIENCE")
	xpHeading:SetFontSize(10)

	local xpFrame = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	xpFrame:SetText("")
	xpFrame:SetFontSize(24)
	xpFrame.currText = ""

	local txtDetail = UI.CreateFrame("Text", WT.UniqueName("wtXP"), wrapper)
	txtDetail:SetText("")
	txtDetail:SetFontSize(10)
	xpFrame.detail = txtDetail

	xpHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	xpFrame:SetPoint("TOPCENTER", xpHeading, "BOTTOMCENTER", 0, -5)
	txtDetail:SetPoint("TOPCENTER", xpFrame, "BOTTOMCENTER", 0, -6)

	table.insert(xpGadgets, xpFrame)

	OnExperience(0,Inspect.TEMPORARY.Experience())	

	return wrapper, { resizable={150, 64, 150, 70} }
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The XP Percent gadget has no additional configuration options")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("XPPercent",
	{
		name="XP Percent",
		description="XP Percentage Display",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnPlayerAvailable()
	OnExperience(0, Inspect.TEMPORARY.Experience())
end

Command.Event.Attach(Event.TEMPORARY.Experience, OnExperience, "OnExperience")
Command.Event.Attach(WT.Event.PlayerAvailable, OnPlayerAvailable, "XPPercentGadget_OnPlayerAvailable")	
