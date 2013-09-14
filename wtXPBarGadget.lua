--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.3.100
      Project Date (UTC)  : 2013-03-01T00:08:19Z
      File Modified (UTC) : 2013-02-28T08:20:03Z (Wildtide)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local XBG = {}

-- wtXPPercent Gadget - a simple % display of current XP

local xpGadgets = {}
local paGadgets = {}
local prGadgets = {}

local prDetails = nil
local paDetails = nil

local iconRestedAddon = "Rift"
local iconRestedFile = "indicator_friendlyNPC.png.dds"

local MAX_CH_LEVEL = 60

local PA_T2_CAP = 628
local PA_T3_CAP = 1079

local PA_T2_EXP = PA_T2_CAP*((PA_T2_CAP*1219)+98781)
local PA_T3_EXP = PA_T3_CAP*((PA_T3_CAP*1219)+98781)

local PA_T3_ONLY = PA_T3_EXP - PA_T2_EXP

local MAX_PA_LEVEL = PA_T3_CAP
local MAX_PAXP_REQ = PA_T3_EXP

function XBG.OnPAChange(h, accum)
	if not accum then return end
	if paDetails == nil then
		paDetails = Inspect.Attunement.Progress()
	end
	if paDetails.needed == nil then
		for idx, gadget in ipairs(paGadgets) do
			gadget.bar:SetPoint("BOTTOMRIGHT", gadget, 1.0, 1.0)
			if gadget.text then
				gadget.text:SetText(string.format("MAX Planar Attunement Points: %d", paDetails.available+paDetails.spent))
			end
		end
	else
		local percent
		local percentRested = 0
		if paDetails.rested and paDetails.rested > accum then percentRested = (paDetails.rested / paDetails.needed) end

		for idx, gadget in ipairs(paGadgets) do
			if percentRested > 0 then
				if gadget.barRested then
					gadget.barRested:SetPoint("BOTTOMRIGHT", gadget, percentRested, 1.0)
					gadget.barRested:SetVisible(true)
				end
			else
				if gadget.barRested then gadget.barRested:SetVisible(false) end
			end		
			if gadget.text then
				local unspent = ""	
				local pa_cur = 0
				local pa_req = 0
				if paDetails.available then
					unspent = string.format("[%d] ", paDetails.available)
				end
				if gadget.xpType == "PAXP" then
					pa_cur = accum
					pa_req = paDetails.needed
				else
					local pa_pts = paDetails.spent+paDetails.available					
					pa_cur = (pa_pts*((pa_pts*1219)+98781))+accum
					
					if gadget.pat3 then
						pa_req = PA_T3_ONLY
						if pa_cur >= PA_T2_EXP then
							pa_cur = pa_cur - PA_T2_EXP
						else
							pa_cur = 0
						end
					else
						pa_req = MAX_PAXP_REQ
					end
				end
				
				percent = (pa_cur / pa_req)
				gadget.bar:SetPoint("BOTTOMRIGHT", gadget, percent, 1.0)
				percent = percent*100
				if gadget.textType then
					gadget.text:SetText(string.format("[PA#: %d] %s/%s %s(%.2f%%)", paDetails.spent+paDetails.available+1, WT.Utility.NumberComma(pa_cur), WT.Utility.NumberComma(pa_req), unspent, percent))
				else
					gadget.text:SetText(string.format("[PA#: %d] %s/%s %s(%.2f%%)", paDetails.spent+paDetails.available+1, WT.Utility.NumberDesc(pa_cur), WT.Utility.NumberDesc(pa_req), unspent, percent))
				end				
			end
		end
	end
end

function XBG.PAPtChange(h)
	paDetails = Inspect.Attunement.Progress()
	XBG.OnPAChange(0, paDetails.accumulated)
end

function XBG.OnPrestige(h, accum)
	if not accum then return end
	if prDetails == nil then
		prDetails = Inspect.Pvp.Prestige()
		if not prDetails then
			prDetails.needed=1
		else
			if prDetails.rank == 1 and prDetails.needed == nil and accum==0 then
				prDetails.needed=1
			end
		end
	end
	-- Fix for strange error with nil needed value (API bug?)
	prDetails.needed = prDetails.needed or 1
	
	local percent = (accum/prDetails.needed) * 100
	for idx, gadget in ipairs(prGadgets) do
		gadget.bar:SetPoint("BOTTOMRIGHT", gadget, accum/prDetails.needed, 1.0)
		if gadget.text then
			if gadget.textType then
				gadget.text:SetText(string.format("[Rank: %d] %s/%s (%.2f%%)", prDetails.rank, WT.Utility.NumberComma(accum), WT.Utility.NumberComma(prDetails.needed), percent))
			else
				gadget.text:SetText(string.format("[Rank: %d] %s/%s (%.2f%%)", prDetails.rank, WT.Utility.NumberDesc(accum), WT.Utility.NumberDesc(prDetails.needed), percent))
			end
		end
	end
end

function XBG.RankChange(h)
	prDetails = Inspect.Pvp.Prestige()
	XBG.OnPrestige(0, prDetails.accumulated)	
end

function XBG.OnExperience(h, accum, rested, needed)
	if not accum then return end
	
	local pLevel = Inspect.Unit.Detail("player").level
	if pLevel == MAX_CH_LEVEL then
		needed = -1
	end
	
	if needed == -1 then
		for idx, gadget in ipairs(xpGadgets) do
			gadget.bar:SetPoint("BOTTOMRIGHT", gadget, 1.0, 1.0)
			if gadget.text then
				gadget.text:SetText(string.format("MAX Level: %d", pLevel))
			end
		end
	else
		local percent = (accum / needed) * 100
		
		local percentRested = 0
		if rested and rested > accum then percentRested = (rested / needed) end
		
		local percentString = string.format("%i", math.floor(percent)) .. "%"
		for idx, gadget in ipairs(xpGadgets) do
			gadget.bar:SetPoint("BOTTOMRIGHT", gadget, accum / needed, 1.0)
			if percentRested > 0 then
				if gadget.barRested then
					gadget.barRested:SetPoint("BOTTOMRIGHT", gadget, percentRested, 1.0)
					gadget.barRested:SetVisible(true)
				end

				gadget.iconRested:SetPoint("TOPCENTER", gadget, percentRested, 1.0, 0, -18)
				-- gadget.iconRested:SetVisible(true)
				-- Icon doesn't look right yet, will fix later
			else
				if gadget.barRested then gadget.barRested:SetVisible(false) end
				gadget.iconRested:SetVisible(false)
			end
			if gadget.text then
				if gadget.textType then
					gadget.text:SetText(string.format("[Level: %d] %s/%s (%.2f%%)", pLevel, WT.Utility.NumberComma(accum), WT.Utility.NumberComma(needed), percent))
				else
					gadget.text:SetText(string.format("[Level: %d] %s/%s (%.2f%%)", pLevel, WT.Utility.NumberDesc(accum), WT.Utility.NumberDesc(needed), percent))
				end
			end
		end
	end
end


function XBG.Create(configuration)
	local wrapper = UI.CreateFrame("Texture", WT.UniqueName("wtXP"), WT.Context)
	wrapper:SetWidth(512)
	wrapper:SetHeight(15)
	wrapper:SetTexture("Gadgets", "img/wtXPBar.tga")

	local bar = UI.CreateFrame("Frame", WT.UniqueName("wtXP"), wrapper)
	bar:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	bar:SetPoint("BOTTOMRIGHT", wrapper, 0.5, 1.0)
	wrapper.bar = bar
	
	if configuration.xpType == nil then
		configuration.xpType = "XP"
	end
	
	if configuration.colBar == nil then
		configuration.colBar = {0,0.8,0,0.4}
	end
	
	bar:SetBackgroundColor(unpack(configuration.colBar))

	if configuration.tintRested then
		local barRested = UI.CreateFrame("Frame", WT.UniqueName("wtXPRested"), wrapper)
		barRested:SetPoint("TOPLEFT", bar, "CENTERRIGHT")
		barRested:SetPoint("BOTTOMRIGHT", wrapper, 0.5, 1.0)
		barRested:SetBackgroundColor(0.0,0.6,0.0,0.2)
		barRested:SetVisible(false)
		wrapper.barRested = barRested
	end

	local rested = UI.CreateFrame("Texture", "texRested", bar)
	rested:SetPoint("TOPCENTER", wrapper, "BOTTOMLEFT", 0, -18)
	rested:SetTexture(iconRestedAddon, iconRestedFile)
	rested:SetVisible(false)
	wrapper.iconRested = rested
	
	if configuration.showText then
		local txt = UI.CreateFrame("Text", WT.UniqueName("wtXP"), bar)
		txt:SetFontColor(1,1,1,1)
		txt:SetPoint("CENTER", wrapper, "CENTER")
		txt:SetText("-/- (0%)")
		txt:SetEffectGlow({ strength = 1 })
		wrapper.textType = configuration.showFullText
		wrapper.text = txt
		bar:EventAttach(Event.UI.Layout.Size, function(self, h)
			if configuration.largeText then
				txt:SetFontSize(bar:GetHeight() * 0.9)
			else
				txt:SetFontSize(bar:GetHeight() * 0.6)
			end
		end, "Event.UI.Layout.Size")
	end

	if configuration.xpType == "XP" then
		table.insert(xpGadgets, wrapper)
	elseif configuration.xpType == "PAXP" or configuration.xpType == "PAXPCAP" then
		wrapper.xpType = configuration.xpType
		wrapper.pat3 = configuration.pat3
		table.insert(paGadgets, wrapper)
	elseif configuration.xpType == "PRXP" then
		table.insert(prGadgets, wrapper)
	end

	return wrapper, { resizable={100, 8, 1500, 40 } }	
end

local dialog = false

function XBG.ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("Resizable XP Bar Gadget")
		:Checkbox("showText", "Show Text", false)
		:Checkbox("largeText", "Large Text", false)
		:Checkbox("showFullText", "Show Full XP Values", false)
		:Checkbox("tintRested", "Tint Rested XP on Bar", false)
		:Combobox("xpType", "XP Type", "XP",
			{
				{text="XP", value="XP"},
				{text="PA XP", value="PAXP"},
				{text="PA XP to cap", value="PAXPCAP"},
				{text="Prestige", value="PRXP"}
			})
		:Checkbox("pat3", "Show PA Cap for T3 only", false)
		:ColorPicker("colBar", "Bar Color", 0, 0.8, 0, 0.4)
end

function XBG.GetConfiguration()
	return dialog:GetValues()
end

function XBG.SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("XPBar",
	{
		name="XP Bar",
		description="XP Bar",
		author="Wildtide/Adelea",
		version="1.1.0",
		["Create"] = XBG.Create,
		["ConfigDialog"] = XBG.ConfigDialog,
		["GetConfiguration"] = XBG.GetConfiguration, 
		["SetConfiguration"] = XBG.SetConfiguration, 
	})

function XBG.OnPlayerAvailable(h)
	XBG.OnExperience(0, Inspect.TEMPORARY.Experience())
	
	local prestige = Inspect.Pvp.Prestige()
	if prestige and prestige.accumulated then
		XBG.OnPrestige(0,prestige.accumulated)
	else
		XBG.OnPrestige(0,0)
	end
	
	local attunement = Inspect.Attunement.Progress()
	if attunement and attunement.accumulated then
		XBG.OnPAChange(0,attunement.accumulated)
	else
		XBG.OnPAChange(0,0)
	end	
end

Command.Event.Attach(WT.Event.PlayerAvailable, XBG.OnPlayerAvailable, "XPBarGadget_OnPlayerAvailable")	

Command.Event.Attach(Event.TEMPORARY.Experience, XBG.OnExperience, "OnExperienceBar")
Command.Event.Attach(Event.Pvp.Prestige.Accumulated, XBG.OnPrestige, "Event.Pvp.Prestige.Accumulated")
Command.Event.Attach(Event.Pvp.Prestige.Rank, XBG.RankChange, "Event.Pvp.Prestige.Rank")
Command.Event.Attach(Event.Attunement.Progress.Accumulated, XBG.OnPAChange, "Inspect.Attunement.Progress")
Command.Event.Attach(Event.Attunement.Progress.Available, XBG.PAPtChange, "Event.Attunement.Progress.Available")