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

local function OnExperience(accum, rested, needed)
	if not accum then return end
	local percent = (accum / needed) * 100
	local percentString = string.format("%i", math.floor(percent)) .. "%"
	for idx, gadget in ipairs(xpGadgets) do
		gadget.bar:SetPoint("BOTTOMRIGHT", gadget, accum / needed, 1.0)
		if gadget.text then
			gadget.text:SetText(WT.Utility.NumberDesc(accum) .. "/" .. WT.Utility.NumberDesc(needed) .. " (" .. percentString .. ")")
		end
	end
end


local function Create(configuration)

	local wrapper = UI.CreateFrame("Texture", WT.UniqueName("wtXP"), WT.Context)
	wrapper:SetWidth(512)
	wrapper:SetHeight(15)
	wrapper:SetTexture(AddonId, "img/wtXPBar.tga")

	local bar = UI.CreateFrame("Frame", WT.UniqueName("wtXP"), wrapper)
	bar:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	bar:SetPoint("BOTTOMRIGHT", wrapper, 0.5, 1.0)
	bar:SetBackgroundColor(0,0.8,0,0.4)
	wrapper.bar = bar

	if configuration.showText then
		local txt = UI.CreateFrame("Text", WT.UniqueName("wtXP"), bar)
		txt:SetFontColor(1,1,1,1)
		txt:SetPoint("CENTER", wrapper, "CENTER")
		txt:SetText("-/- (0%)")
		wrapper.text = txt
		bar.Event.Size = 
			function()
				txt:SetFontSize(bar:GetHeight() * 0.6)
			end
	end

	table.insert(xpGadgets, wrapper)

	OnExperience(Inspect.TEMPORARY.Experience())

	return wrapper, { resizable={100, 8, 1500, 40 } }
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("Resizable XP Bar Gadget")
		:Checkbox("showText", "Show Text", false)
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("XPBar",
	{
		name="XP Bar",
		description="XP Bar",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnPlayerAvailable()
	OnExperience(Inspect.TEMPORARY.Experience())
end

table.insert(Event.TEMPORARY.Experience, { OnExperience, AddonId, "OnExperienceBar" })
table.insert(WT.Event.PlayerAvailable, {OnPlayerAvailable, AddonId, "XPBarGadget_OnPlayerAvailable"})	
