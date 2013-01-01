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


local castBars = {}


-- wtCastBar provides a simple bar for the player's charge
-- Only useful for mages, and it only exists because I didn't want to add a charge bar to the standard frame

local function OnCastName(unitFrame, castname)
	if castname then
		local unit = unitFrame.Unit
		if unit.castUninterruptible then
			unitFrame.barCast.Image:SetTexture(unitFrame.mediaNoInterrupt.addonId, unitFrame.mediaNoInterrupt.filename)  
		else
			unitFrame.barCast.Image:SetTexture(unitFrame.mediaInterrupt.addonId, unitFrame.mediaInterrupt.filename)  
		end
	end
end

local function Create(configuration)

	local castBar = WT.UnitFrame:Create(configuration.unitSpec)
	castBar:SetWidth(170)
	castBar:SetHeight(24)
	if not configuration.hideNotCasting then
		castBar:SetBackgroundColor(0,0,0,0.4)
	end

	castBar.mediaInterrupt = Library.Media.GetTexture(configuration.texture)
	castBar.mediaNoInterrupt = Library.Media.GetTexture(configuration.textureNoInterrupt)

	castBar.barCast = castBar:CreateElement(
	{
		id="barCast", type="Bar", parent="frame", layer=25,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
		visibilityBinding="castName",
		binding="castPercent",
		media=configuration.texture, colorBinding="castColor",
		backgroundColor={r=0, g=0, b=0, a=1}
	})

	castBar.labelCast = castBar:CreateElement(
	{
		id="labelCast", type="Label", parent="frame", layer=26,
		attach = {{ point="CENTERLEFT", element="barCast", targetPoint="CENTERLEFT", offsetX=6, offsetY=0 }},
		visibilityBinding="castName",
		text="{castName}", default="", fontSize=12
	})

	if configuration.showCastTime then
		castBar.labelTime = castBar:CreateElement(
		{
			id="labelTime", type="Label", parent="frame", layer=26,
			attach = {{ point="CENTERRIGHT", element="barCast", targetPoint="CENTERRIGHT", offsetX=-6, offsetY=0 }},
			visibilityBinding="castName",
			text="{castTime}", default="", fontSize=10
		})
	end

	castBar.barCast.Event.Size = 
		function(frame)
			castBar.labelCast:SetFontSize(frame:GetHeight() * 0.5)
			if castBar.labelTime then
				castBar.labelTime:SetFontSize(frame:GetHeight() * 0.4)
			end
		end

	if configuration.gcdSparkAbove then
		castBar.gcdTrack = UI.CreateFrame("Frame", "gcdTrack", castBar)
		castBar.gcdTrack:SetLayer(100)
		castBar.gcdTrack:SetPoint("BOTTOMLEFT", castBar, "TOPLEFT")
		castBar.gcdTrack:SetPoint("TOPRIGHT", castBar, "TOPRIGHT", 0, -3)
		if configuration.showCooldownTrack then
			castBar.gcdTrack:SetBackgroundColor(0,0,0,0.6)
		else
			castBar.gcdTrack:SetBackgroundColor(0,0,0,0.0)
		end
	else
		castBar.gcdTrack = UI.CreateFrame("Frame", "gcdTrack", castBar)
		castBar.gcdTrack:SetLayer(100)
		castBar.gcdTrack:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT")
		castBar.gcdTrack:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 0, 3)
		castBar.gcdTrack:SetBackgroundColor(0,0,0,0.6)
		if configuration.showGCDTrack then
			castBar.gcdTrack:SetBackgroundColor(0,0,0,0.6)
		else
			castBar.gcdTrack:SetBackgroundColor(0,0,0,0.0)
		end
	end
	
	castBar.gcdSpark = UI.CreateFrame("Texture", "gcdSpark", castBar.gcdTrack)
	castBar.gcdSpark:SetTexture("Rift", "LightOrb_Yellow.png.dds")
	castBar.gcdSpark:SetPoint("CENTER", castBar.gcdTrack, 0.0, 0.5, 1, 1)
	castBar.gcdSpark:SetHeight(12)
	castBar.gcdSpark:SetWidth(12)
	castBar.gcdSpark:SetAlpha(0.6)
	castBar.gcdSpark:SetVisible(false)

	if not configuration.showGCDSpark then
		castBar.gcdTrack:SetVisible(false)
	end

	castBar:CreateBinding("castName", castBar, OnCastName, nil)

	castBar.barCast:SetVisible(false)

	table.insert(castBars, castBar)

	return castBar, { resizable = { 140, 15, 1000, 300 } }
end

local dialog = false

local function ConfigDialog(container)

	local lMedia = Library.Media.FindMedia("bar")
	local listMedia = {}
	for mediaId, media in pairs(lMedia) do
		table.insert(listMedia, { ["text"]=mediaId, ["value"]=mediaId })
	end
	
	dialog = WT.Dialog(container)
		:Label("The cast bar gadget shows a cast bar for the unit selected.")
		:Combobox("unitSpec", TXT.UnitToTrack, "player",
			{
				{text="Player", value="player"},
				{text="Target", value="player.target"},
				{text="Target's Target", value="player.target.target"},
				{text="Focus", value="focus"},
				{text="Focus's Target", value="focus.target"},
				{text="Pet", value="player.pet"},
			}, false) 
		:TexSelect("texture", TXT.Texture, "wtCastInterruptable", "bar")
		:TexSelect("textureNoInterrupt", TXT.TextureNoInterrupt, "wtCastUninterruptable", "bar")
		:Checkbox("hideNotCasting", TXT.HideWhenNotCasting, true)
		:Checkbox("showCastTime", TXT.ShowCastTime, true)
		:Checkbox("showGCDSpark", "Show Cooldown Spark", false)
		:Checkbox("showGCDTrack", "Show Cooldown Track", false)
		:Checkbox("gcdSparkAbove", "Cooldown Spark Above", false)
	
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

local function Reconfigure(config)

	assert(config.id, "No id provided in reconfiguration details")
	
	local gadgetConfig = wtxGadgets[config.id]
	local gadget = WT.Gadgets[config.id]
	
	assert(gadget, "Gadget id does not exist in WT.Gadgets")
	assert(gadgetConfig, "Gadget id does not exist in wtxGadgets")
	assert(gadgetConfig.type == "CastBar", "Reconfigure Gadget is not a castbar")
	
	-- Detect changes to config and apply them to the gadget
	
	local requireRecreate = false
	
	if gadgetConfig.unitSpec ~= config.unitSpec then
		gadgetConfig.unitSpec = config.unitSpec
		requireRecreate = true
	end

	if gadgetConfig.texture ~= config.texture then
		gadgetConfig.texture = config.texture
		gadget.mediaInterrupt = Library.Media.GetTexture(config.texture)
	end

	if gadgetConfig.textureNoInterrupt ~= config.textureNoInterrupt then
		gadgetConfig.textureNoInterrupt = config.textureNoInterrupt
		gadget.mediaNoInterrupt = Library.Media.GetTexture(config.textureNoInterrupt)
	end
	
	if gadgetConfig.hideNotCasting ~= config.hideNotCasting then
		gadgetConfig.hideNotCasting = config.hideNotCasting
		if not config.hideNotCasting then
			gadget:SetBackgroundColor(0,0,0,0.4)
		else
			gadget:SetBackgroundColor(0,0,0,0)
		end
	end

	if gadgetConfig.showCastTime ~= config.showCastTime then
		gadgetConfig.showCastTime = config.showCastTime
		requireRecreate = true
	end


	if config.gcdSparkAbove then
		gadget.gcdTrack:SetPoint("BOTTOMLEFT", gadget, "TOPLEFT")
		gadget.gcdTrack:SetPoint("TOPRIGHT", gadget, "TOPRIGHT", 0, -3)
		gadget.gcdTrack:SetBackgroundColor(0,0,0,0.6)
	else
		gadget.gcdTrack:SetPoint("TOPLEFT", gadget, "BOTTOMLEFT")
		gadget.gcdTrack:SetPoint("BOTTOMRIGHT", gadget, "BOTTOMRIGHT", 0, 3)
		gadget.gcdTrack:SetBackgroundColor(0,0,0,0.6)
	end

	if config.showGCDTrack then
		gadget.gcdTrack:SetBackgroundColor(0,0,0,0.6)
	else
		gadget.gcdTrack:SetBackgroundColor(0,0,0,0.0)
	end
	
	if not config.showGCDSpark then
		gadget.gcdTrack:SetVisible(false)
	else
		gadget.gcdTrack:SetVisible(true)
	end

	if requireRecreate then
		WT.Gadget.Delete(gadgetConfig.id)
		WT.Gadget.Create(gadgetConfig)
	end		
	
end

WT.Gadget.RegisterFactory("CastBar",
	{
		name=TXT.gadgetCastBar_name,
		description=TXT.gadgetCastBar_desc,
		author="Wildtide",
		version="1.1.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCastBar.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
		["Reconfigure"] = Reconfigure,
	})

local trackingCD = nil
local trackingStart = nil
local trackingDuration = nil

local function cdBegin(list)
	for abilityId, cooldown in pairs(list) do
		if (cooldown >= 0.9) and (cooldown <= 1.51) then
			trackingCD = abilityId
			trackingStart = Inspect.Time.Frame()
			trackingDuration = cooldown
			for idx, castbar in ipairs(castBars) do
				castbar.gcdSpark:SetVisible(true)
			end
			break
		end
	end
end

local function cdEnd(list)
	if trackingCD and list[trackingCD] then
		-- GCD has ended
		trackingCD = nil
		for idx, castbar in ipairs(castBars) do
			castbar.gcdSpark:SetVisible(false)
		end
	end
end

local function cdUpdate()
	if not trackingCD then return end
	local elapsed = Inspect.Time.Frame() - trackingStart
	local percent = elapsed / trackingDuration
	if percent > 1.0 then percent = 1.0 end
	for idx, castBar in ipairs(castBars) do
		castBar.gcdSpark:SetPoint("CENTER", castBar.gcdTrack, percent, 0.5, 1, 1)	
	end	
end


table.insert(Event.Ability.New.Cooldown.Begin, { cdBegin, AddonId, AddonId .. "_CooldownBegin" })
table.insert(Event.Ability.New.Cooldown.End, { cdEnd, AddonId, AddonId .. "_CooldownEnd"  })
table.insert(Event.System.Update.Begin, { cdUpdate, AddonId, AddonId .. "_CooldownUpdate" })
