--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Icewatch (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

-- wtFPSGadget creates a really simple "FPS" gadget for displaying Frames Per Second

local gadgetIndex = 0
local dpsGadgets = {}

local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFPS"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(52)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local dpsHeading = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	dpsHeading:SetText("LIVE DPS")
	dpsHeading:SetFontSize(10)

	local dpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	dpsFrame:SetText("")
	dpsFrame:SetFontSize(24)
	dpsFrame.currText = ""

	dpsHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	dpsFrame:SetPoint("TOPCENTER", dpsHeading, "BOTTOMCENTER", 0, -5)

	table.insert(dpsGadgets, dpsFrame)
	return wrapper, { resizable={150, 52, 150, 70} }
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("This gadget displays a live measure of the player's DPS")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("DPS",
	{
		name="DPS:Live",
		description="Displays Live DPS",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})


local dmgAccum = 0
local runningSeconds = 10
local runningCursor = 1
local runningDamage = {}
local lastSecond = math.floor(Inspect.Time.Frame())
for i = 1,runningSeconds do runningDamage[i] = 0 end

local function OnTick()
	local currSecond = math.floor(Inspect.Time.Frame())
	if currSecond ~= lastSecond then
		runningDamage[runningCursor] = dmgAccum
		dmgAccum = 0
		runningCursor = runningCursor + 1
		if runningCursor > runningSeconds then runningCursor = 1 end
		local total = 0
		for i = 1, runningSeconds do
			total = total + runningDamage[i]
		end
		local dps = math.floor((total / runningSeconds) + 0.5)
		for idx, frame in ipairs(dpsGadgets) do
			frame:SetText(tostring(dps))
		end
		lastSecond = currSecond
	end
end


local function OnDamage(info)
	if info.caster ~= WT.Player.id then return end
	dmgAccum = dmgAccum + info.damage
end

table.insert(Event.System.Update.Begin, { OnTick, AddonId, AddonId .. "_OnTick" })
table.insert(Event.Combat.Damage, { OnDamage, AddonId, AddonId .. "_OnDamage" })