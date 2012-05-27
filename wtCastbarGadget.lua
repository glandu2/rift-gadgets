--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT=Library.Translate

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
			castBar.labelTime:SetFontSize(frame:GetHeight() * 0.4)
		end

	castBar:CreateBinding("castName", castBar, OnCastName, nil)

	return castBar, { resizable = { 140, 15, 300, 50 } }
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
	
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("CastBar",
	{
		name=TXT.gadgetCastBar_name,
		description=TXT.gadgetCastBar_desc,
		author="Wildtide",
		version="1.1.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

