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

local XBG = {}

-- wtXPPercent Gadget - a simple % display of current XP

local xpGadgets = {}
local paGadgets = {}
local prGadgets = {}

local prDetails = nil
local paDetails = nil

local iconRestedAddon = "Rift"
local iconRestedFile = "indicator_friendlyNPC.png.dds"

function XBG.OnPAChange(accum)
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
		local percent = (accum / paDetails.needed) * 100
		local percentRested = 0
		if paDetails.rested and paDetails.rested > accum then percentRested = (paDetails.rested / paDetails.needed) end

		for idx, gadget in ipairs(paGadgets) do
			gadget.bar:SetPoint("BOTTOMRIGHT", gadget, accum / paDetails.needed, 1.0)
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
				if paDetails.available then
					unspent = string.format("[%d] ", paDetails.available)
				end
				if gadget.textType then
					gadget.text:SetText(string.format("[PA#: %d] %s/%s %s(%.2f%%)", paDetails.spent+paDetails.available+1, WT.Utility.NumberComma(accum), WT.Utility.NumberComma(paDetails.needed), unspent, percent))
				else
					gadget.text:SetText(string.format("[PA#: %d] %s/%s %s(%.2f%%)", paDetails.spent+paDetails.available+1, WT.Utility.NumberDesc(accum), WT.Utility.NumberDesc(paDetails.needed), unspent, percent))
				end
			end
		end
	end
end

function XBG.PAPtChange()
	paDetails = Inspect.Attunement.Progress()
	XBG.OnPAChange(paDetails.accumulated)
end

function XBG.OnPrestige(accum)
	if not accum then return end
	if prDetails == nil then
		prDetails = Inspect.Pvp.Prestige()
		if prDetails.rank == 1 and prDetails.needed == nil and accum==0 then
			prDetails.needed=1
		end
	end
	
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

function XBG.RankChange()
	prDetails = Inspect.Pvp.Prestige()
	XBG.OnPrestige(prDetails.accumulated)	
end

function XBG.OnExperience(accum, rested, needed)
	if not accum then return end
	
	local pLevel = Inspect.Unit.Detail("player").level
	
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
		wrapper.textType = configuration.showFullText
		wrapper.text = txt
		bar.Event.Size = 
			function()
				if configuration.largeText then
					txt:SetFontSize(bar:GetHeight() * 0.9)
				else
					txt:SetFontSize(bar:GetHeight() * 0.6)
				end
			end
	end

	if configuration.xpType == "XP" then
		table.insert(xpGadgets, wrapper)
	elseif configuration.xpType == "PAXP" then
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
				{text="Prestige", value="PRXP"}
			})
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

function XBG.OnPlayerAvailable()
	XBG.OnExperience(Inspect.TEMPORARY.Experience())
	XBG.OnPrestige(Inspect.Pvp.Prestige().accumulated or 0)
	XBG.OnPAChange(Inspect.Attunement.Progress().accumulated or 0)	
end

table.insert(Event.TEMPORARY.Experience, { XBG.OnExperience, AddonId, "OnExperienceBar" })
table.insert(WT.Event.PlayerAvailable, {XBG.OnPlayerAvailable, AddonId, "XPBarGadget_OnPlayerAvailable"})	
table.insert(Event.Pvp.Prestige.Accumulated,{XBG.OnPrestige, AddonId, "Event.Pvp.Prestige.Accumulated"})
table.insert(Event.Pvp.Prestige.Rank, { XBG.RankChange, AddonId, "Event.Pvp.Prestige.Rank"})
table.insert(Event.Attunement.Progress.Accumulated, { XBG.OnPAChange, AddonId, "Inspect.Attunement.Progress" })
table.insert(Event.Attunement.Progress.Available, { XBG.PAPtChange, AddonId, "Event.Attunement.Progress.Available" })