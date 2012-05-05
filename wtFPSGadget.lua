--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- wtFPSGadget creates a really simple "FPS" gadget for displaying Frames Per Second

local gadgetIndex = 0
local fpsGadgets = {}

local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFPS"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(52)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local fpsHeading = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsHeading:SetText("FRAMES PER SECOND")
	fpsHeading:SetFontSize(10)

	local fpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsFrame:SetText("")
	fpsFrame:SetFontSize(24)
	fpsFrame.currText = ""

	fpsHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	fpsFrame:SetPoint("TOPCENTER", fpsHeading, "BOTTOMCENTER", 0, -5)

	table.insert(fpsGadgets, fpsFrame)
	return wrapper
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("This gadget displays the current number of Frames Per Second for the Rift client, updated once per second.")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("FPS",
	{
		name="FPS Monitor",
		description="Display Frames Per Second",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtFPS.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnTick(frameDeltaTime, frameIndex)
	local fpsText = tostring(math.ceil(WT.FPS))
	for idx, gadget in ipairs(fpsGadgets) do
		if gadget.currText ~= fpsText then
			gadget:SetText(fpsText)
			gadget.currText = fpsText
		end
	end
end

table.insert(WT.Event.Tick, { OnTick, AddonId, AddonId .. "_OnTick" })