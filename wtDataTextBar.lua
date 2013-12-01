--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            Lifeismystery@yandex.ru
                           Lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.4.92
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


local gadgetIndex = 0
local fpsGadgets = {}
local cpuGadgets = {}
local MoneyGadgets = {}

local function Create(configuration)	

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtDataText"), WT.Context)
	wrapper:SetWidth(570)
	wrapper:SetHeight(30)
	wrapper:SetSecureMode("restricted")
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85)		
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		if configuration.BackgroundColor == nil then
			configuration.BackgroundColor = {0.07,0.07,0.07,0.85}
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		else 
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		end
	else 	
		Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 0)
		wrapper:SetBackgroundColor(0,0,0,0)
	end
------------------------FPS---------------------------------------------------------------
	local fpsFrame = UI.CreateFrame("Text", WT.UniqueName("wtFPS"), wrapper)
	fpsFrame:SetText("FPS:" .. "")
	fpsFrame:SetFontSize(13)
	fpsFrame:SetEffectGlow({ strength = 3 })
	--fpsFrame:SetFontColor(0.2,0.4,0.7)
	fpsFrame:SetPoint("CENTERLEFT", wrapper, "CENTERLEFT", 10, 0)
	if configuration.showFPS == false then
		fpsFrame:SetVisible(false)	
		fpsFrame:SetWidth(-10)
	end
----------------------CPU------------------------------------------------------------------
	local cpuFrame = UI.CreateFrame("Text", WT.UniqueName("wtCPU"), wrapper)
	cpuFrame:SetText("")
	cpuFrame:SetFontSize(13)
	cpuFrame.currText = ""
	cpuFrame:SetEffectGlow({ strength = 3 })
	--cpuFrame:SetFontColor(0.2,0.4,0.7)
	cpuFrame:SetPoint("CENTERLEFT", fpsFrame, "CENTERRIGHT", 10, 0)
	if configuration.showCPU == false then
		cpuFrame:SetVisible(false)	
		cpuFrame:SetWidth(-10)
	end
----------------------PlanarCharge----------------------------------------------------------
	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetLayer(100)
	chargeMeter:SetPoint("CENTERLEFT", cpuFrame, "CENTERRIGHT", 10, 0)
	chargeMeter:CreateElement(
	{
		id="imgCharge", type="Image", parent="frame", layer=10, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT" },
		},
		texAddon="Rift", texFile="chargedstone_on.png.dds",
		backgroundColor={r=1, g=1, b=1, a=1},
		width = 22, height = 22,
	});
	chargeMeter:CreateElement(
	{
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTERLEFT", element="imgCharge", targetPoint="CENTERLEFT", offsetX=20, offsetY=0}},
		outline=true,
		text="{planar}/{planarMax}", fontSize=13,
	});
	if configuration.showCharge == false then
		chargeMeter:SetWidth(-10)
		chargeMeter:SetVisible(false)
	end
----------------------SoulVitality----------------------------------------------------------
	local vitalityMeter = WT.UnitFrame:Create("player")
	vitalityMeter:SetLayer(100)
	vitalityMeter:SetPoint("CENTERLEFT", chargeMeter, "CENTERRIGHT", 10, 0)
	
	vitalityMeter:CreateElement(
	{
		id="imgVitality", type="Image", parent="frame", layer=10, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=0, offsetY=7},
		},
		texAddon="Rift", texFile="death_icon_(grey).png.dds",
		backgroundColor={r=1, g=1, b=1, a=1},
		width = 40, height = 40,
	});
	vitalityMeter:CreateElement(
	{
		id="imgZVitality", type="Image", parent="frame", layer=15, alpha=1,
		attach = {
			{ point="CENTERLEFT", element="frame", targetPoint="CENTERLEFT", offsetX=0, offsetY=7 },
		},
		texAddon="Rift", texFile="death_icon_(red).png.dds",
		visibilityBinding="zVitality",
		backgroundColor={r=1, g=1, b=1, a=0},
		width = 40, height = 40,
	});
	vitalityMeter:CreateElement(
	{
		id="txtVitality", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTERLEFT", element="imgVitality", targetPoint="CENTERLEFT", offsetX=30, offsetY=-8 }},
		text="{vitality}%", fontSize=13, outline=true,
	});
	if configuration.showVitality == false then
		vitalityMeter:SetWidth(-40)
		vitalityMeter:SetVisible(false)
	end
------------------------------ShardName-------------------------------------------------------------------
	local shard = Inspect.Shard()
	local shardName = UI.CreateFrame("Text", WT.UniqueName("wtshardName"), wrapper)
	shardName:SetText("")
	shardName:SetFontSize(13)
	shardName:SetEffectGlow({ strength = 3 })
	shardName:SetPoint("CENTERLEFT", vitalityMeter, "CENTERRIGHT", 40, 0)	
	
	if shard["name"] then
	shardName:SetText(shard["name"])
	end 
	
	if configuration.showShard == false then
		shardName:SetVisible(false)
		shardName:SetWidth(-10)	
	end	
----------------------Money----------------------------------------------------------	
	

	local MoneyPlatIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyPlatIcon "), wrapper)
	MoneyPlatIcon:SetTexture("Rift", "coins_platinum.png.dds")
	MoneyPlatIcon:SetPoint("CENTERLEFT", shardName, "CENTERRIGHT", 10, 0)
	MoneyPlatIcon:SetWidth(15)
	MoneyPlatIcon:SetHeight(15)	
	
	local MoneyPlatFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyPlat"), wrapper)
	MoneyPlatFrame:SetText("")
	MoneyPlatFrame:SetFontSize(13)
	MoneyPlatFrame:SetEffectGlow({ strength = 3 })
	MoneyPlatFrame:SetPoint("CENTERLEFT", MoneyPlatIcon, "CENTERRIGHT", 0, 0)
	
	local MoneyGoldIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneyGoldIcon "), wrapper)
	MoneyGoldIcon:SetTexture("Rift", "coins_gold.png.dds")
	MoneyGoldIcon:SetPoint("CENTERLEFT", MoneyPlatFrame, "CENTERRIGHT", 0, 0)
	MoneyGoldIcon:SetWidth(15)
	MoneyGoldIcon:SetHeight(15)

	local MoneyGoldFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneyGold"), wrapper)
	MoneyGoldFrame:SetText("")
	MoneyGoldFrame:SetFontSize(13)
	MoneyGoldFrame:SetEffectGlow({ strength = 3 })
	MoneyGoldFrame:SetPoint("CENTERLEFT", MoneyGoldIcon, "CENTERRIGHT", 0, 0)	
	
	local MoneySilverIcon = UI.CreateFrame("Texture", WT.UniqueName("wtMoneySilverIcon "), wrapper)
	MoneySilverIcon:SetTexture("Rift", "coins_Silver.png.dds")
	MoneySilverIcon:SetPoint("CENTERLEFT", MoneyGoldFrame, "CENTERRIGHT", 0, 0)
	MoneySilverIcon:SetWidth(15)
	MoneySilverIcon:SetHeight(15)
	
	local MoneySilverFrame = UI.CreateFrame("Text", WT.UniqueName("wtMoneySilver"), wrapper)
	MoneySilverFrame:SetText("")
	MoneySilverFrame:SetFontSize(13)
	MoneySilverFrame:SetEffectGlow({ strength = 3 })
	MoneySilverFrame:SetPoint("CENTERLEFT", MoneySilverIcon, "CENTERRIGHT", 0, 0)
	
	
	if configuration.showMoney == false then
		MoneyPlatIcon:SetWidth(-25)
			MoneyPlatIcon:SetVisible(false)
		MoneyGoldIcon:SetWidth(0)
			MoneyGoldIcon:SetVisible(false)
		MoneySilverIcon:SetWidth(0)	
			MoneySilverIcon:SetVisible(false)
		MoneyPlatFrame:SetFontSize(0)
			MoneyPlatFrame:SetVisible(false)
		MoneyGoldFrame:SetFontSize(0)
			MoneyGoldFrame:SetVisible(false)
		MoneySilverFrame:SetFontSize(0)		
			MoneySilverFrame:SetVisible(false)
	end
	
	currencyTemp = Inspect.Currency.Detail("coin")
	if currencyTemp.stack ~= nil then	
	len = string.len(currencyTemp.stack)	
		if len > 0 then
			MoneySilverFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-1, len))	
			if len > 2 then
				MoneyGoldFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-3, len-2))
				if len > 4 then
					MoneyPlatFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, 1, len-4))
				else
					MoneyPlatFrame:SetText("0")
				end
			else
				MoneyGoldFrame:SetText("0")
				MoneyPlatFrame:SetText("0")
			end
		else
			MoneySilverFrame:SetText("0")
			MoneyGoldFrame:SetText("0")
			MoneyPlatFrame:SetText("0")
		end
	end	
function currency (handle, currency)
	len = string.len(Inspect.Currency.Detail("coin").stack)	
			
		if len > 0 then
			MoneySilverFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-1, len))	
			if len > 2 then
				MoneyGoldFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, len-3, len-2))
				if len > 4 then
					MoneyPlatFrame:SetText(string.sub(Inspect.Currency.Detail("coin").stack, 1, len-4))
				else
					MoneyPlatFrame:SetText("0")
				end
			else
				MoneyGoldFrame:SetText("0")
				MoneyPlatFrame:SetText("0")
			end
		else
			MoneySilverFrame:SetText("0")
			MoneyGoldFrame:SetText("0")
			MoneyPlatFrame:SetText("0")
		end
end
------------------------------ReloadUI-------------------------------------------------------------------

	local btnReloadUI = UI.CreateFrame("Frame", WT.UniqueName("wtReloadUI"), wrapper)
	btnReloadUI:SetWidth(90)
	btnReloadUI:SetHeight(20)
	btnReloadUI:SetBackgroundColor(0,0,0,0)
	Library.LibSimpleWidgets.SetBorder("plain", btnReloadUI, 1, 0, 0, 0, 1)
	btnReloadUI:SetPoint("CENTERLEFT", MoneySilverFrame, "CENTERRIGHT", 10, 0)	
	btnReloadUI:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self, h)
		btnReloadUI:SetBackgroundColor(0.5,0.4,0.7, 0.85)
	end, "Event.UI.Input.Mouse.Cursor.In")
	btnReloadUI:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self, h)
		btnReloadUI:SetBackgroundColor(0,0,0,0)
	end, "Event.UI.Input.Mouse.Cursor.Out")
	btnReloadUI:SetSecureMode("restricted")
	btnReloadUI:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "reloadui")
	
	local txtReloadUI = UI.CreateFrame("Text", WT.UniqueName("wttxtReloadUI"), btnReloadUI)
	txtReloadUI:SetText("Reload UI")
	txtReloadUI:SetFontSize(13)
	txtReloadUI.currText = ""
	txtReloadUI:SetEffectGlow({ strength = 3 })
	txtReloadUI:SetPoint("CENTERLEFT", btnReloadUI, "CENTERLEFT", 15, 0)
	txtReloadUI:SetLayer(100)
	
	if configuration.showReloadUI == false then
		btnReloadUI:SetVisible(false)
		btnReloadUI:SetWidth(-10)	
	end	
-----------------------------------------------------------------------------------------------------------	
	
	table.insert(fpsGadgets, fpsFrame)
	table.insert(cpuGadgets, cpuFrame)
	table.insert(MoneyGadgets, MoneyPlatFrame)
	table.insert(MoneyGadgets, MoneyGoldFrame)
	table.insert(MoneyGadgets, MoneySilverFrame)
	table.insert(Event.Currency,{ currency, AddonId, "_currency" })

	return wrapper, { resizable={70, 30, 3000, 30} }
	
end

	
local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("This gadget displays DataText bar with FRS, CPU, Planar charge, Soul vitality, Money and button 'ReloadUI' ")
		:Checkbox("showFPS", "Show FPS", true)
		:Checkbox("showCPU", "Show CPU", true)
		:Checkbox("showCharge", "Show Planar Charge", true)		
		:Checkbox("showVitality", "Show Soul Vitality", true)
		:Checkbox("showShard", "Show Shard Name", true)			
		:Checkbox("showMoney", "Show Money", true)			
		:Checkbox("showReloadUI", "Show ReloadUI", true)
		:TitleY("Gadgets Options")					
		:Checkbox("showBackground", "Show Background frame", true)
		:ColorPicker("BackgroundColor", "Background Color", 0.07,0.07,0.07,0.85)
		
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

local delta = 0
	
local function OnTick(hEvent, frameDeltaTime, frameIndex)
	local fpsText = "FPS:" .. " " .. tostring(math.ceil(WT.FPS))
	for idx, gadget in ipairs(fpsGadgets) do
		if gadget.currText ~=fpsText then
			gadget:SetText(fpsText)
			gadget.currText = fpsText
		end
	end
	
		delta = delta + frameDeltaTime
	if (delta >= 1) then
		delta = 0
		local addons = {}
		local grandTotal = 0
		local renderTotal = 0
		for addonId, cpuData in pairs(Inspect.Addon.Cpu()) do
			if cpuData then
				local total = 0
				for k,v in pairs(cpuData) do
					total = total + v
					if string.find(k, "render time") then renderTotal = renderTotal + v end
					if string.find(k, "update time") then renderTotal = renderTotal + v end
				end
				grandTotal = grandTotal + total
				addons[addonId] = total
			end
		end

		local cpuText = "CPU:" .. " " .. string.format("%.02f%%", grandTotal * 100)

		for idx, gadget in ipairs(cpuGadgets) do
			gadget:SetText(cpuText)
		end
	end
end

Command.Event.Attach(WT.Event.Tick, OnTick, AddonId .. "_OnTick")

WT.Unit.CreateVirtualProperty("zVitality", {"vitality" },
	function(unit)
		if unit.vitality and unit.vitality > 11 then
			return false
		else
			return true
		end
end)

WT.Gadget.RegisterFactory("DataTextBar",
	{
		name=TXT.gadgetDataTextBar_name,
		description=TXT.gadgetDataTextBar_desc,
		author="Lifeismystery",
		version="1.0.0",
		iconTexAddon="Rift",
		iconTexFile="tumblr.png.dds",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})