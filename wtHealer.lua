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

local HealerGadgets = {}

local function ConfigDialog(container)

	local tabs = UI.CreateFrame("SimpleTabView", "hlTabs", container)
	tabs:SetPoint("TOPLEFT", container, "TOPLEFT")
	tabs:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", 0, -32)
	
	local pageGeneral = UI.CreateFrame("Frame", "ConfigPage_General", tabs)  
	local pageColors = UI.CreateFrame("Frame", "ConfigPage_Colors", tabs)  
	local pageIndicators = UI.CreateFrame("Frame", "ConfigPage_Indicators", tabs)  
	local pageBuffs = UI.CreateFrame("Frame", "ConfigPage_Buffs", tabs)  
	local pageDebuffs = UI.CreateFrame("Frame", "ConfigPage_Debuffs", tabs)  
	
	tabs:SetTabPosition("left")
	tabs:AddTab("General", pageGeneral)
	tabs:AddTab("Colors", pageColors)
	tabs:AddTab("Indicators", pageIndicators)
	tabs:AddTab("Buffs", pageBuffs)
	tabs:AddTab("Debuffs", pageDebuffs)
	
end


local function GetConfiguration()
	return {}
end

local function SetConfiguration(config)
	-- do nothing yet
end

local function ApplyConfig(config)

	local gadgetId = config.id
	local gadget = HealerGadgets[gadgetId]

	-- For testing
	config.borderThickness = 1
	config.borderColor = { 1, 1, 1, 1 }
	config.backgroundColor = { 0, 0, 0, 1 }
	-- config.backgroundTexture = {"Rift", "aa_fire_bg.jpg"}
	config.backgroundTexture = {"Rift", "mtx_window_medium_bg_(blue).png.dds"}
	
	config.cellWidth = 100
	config.cellHeight = 50
	config.cellSpacing = 1
	config.cellBackgroundColor = { 0, 0, 0, 0.6 }
	config.padding = 1
	config.groupOrientation = "horizontal"
	config.groupsReversed = false
	
	--

	local imgTank = "GroupPortrait_IAC.dds"
	local imgHeal = "GroupPortrait_IAE.dds"
	local imgDPS = "GroupPortrait_IB0.dds"
	local imgSupport = "GroupPortrait_IB2.dds"
	
	local cellCountX, cellCountY
	
	if config.groupOrientation == "horizontal" then
		cellCountX = 5
		cellCountY = 4
	else
		cellCountX = 4
		cellCountY = 5
	end 

	local totalWidth = (cellCountX * config.cellWidth) + ((cellCountX - 1) * config.cellSpacing) + (2 * config.padding) + (2 * config.borderThickness)
	local totalHeight = (cellCountY * config.cellHeight) + ((cellCountY - 1) * config.cellSpacing) + (2 * config.padding) + (2 * config.borderThickness)

	-- Begin first time creation of gadget 
	if not gadget then
	
		local ctx = UI.CreateContext("ctxHealer_" .. gadgetId)
		ctx:SetSecureMode("restricted")
		ctx:SetStrata("hud")
	
		gadget = UI.CreateFrame("Frame", "HealerFrame", ctx)
		gadget.UIContext = ctx
		gadget.id = gadgetId
		gadget:SetWidth(totalWidth)
		gadget:SetHeight(totalHeight)
		gadget.Frames = {}
		gadget.UnitFrames = {}
		-- gadget:SetBackgroundColor(0.2, 0.4, 0.6)
		
		gadget.Frames.Border = UI.CreateFrame("Frame", "Border", gadget)
		gadget.Frames.Border:SetLayer(0)
		gadget.Frames.Border:SetBackgroundColor(unpack(config.borderColor))
		gadget.Frames.Border:SetAllPoints(gadget)

		gadget.Frames.Background = UI.CreateFrame("Texture", "Background", gadget)
		gadget.Frames.Background:SetTexture(config.backgroundTexture[1], config.backgroundTexture[2])
		gadget.Frames.Background:SetLayer(10)
		gadget.Frames.Background:SetBackgroundColor(unpack(config.backgroundColor))
		gadget.Frames.Background:SetPoint("TOPLEFT", gadget.Frames.Border, "TOPLEFT", config.borderThickness, config.borderThickness)
		gadget.Frames.Background:SetPoint("BOTTOMRIGHT", gadget.Frames.Border, "BOTTOMRIGHT", -config.borderThickness, -config.borderThickness)
		
		for groupId = 1, 20 do
			local uf = WT.UnitFrame:Create("group" .. string.format("%02d", groupId))
			uf:SetParent(gadget)
			uf:SetLayer(20)
			gadget.UnitFrames[groupId] = uf
			
			-- Add all of the elements from the cell template
			for idx, element in ipairs(data.wtHealer.CellTemplate) do
				uf:CreateElement(element)
			end 
			
		end
		
		HealerGadgets[gadgetId] = gadget
	end
	-- End first time creation of gadget
	
	-- store a copy of the configuration data
	gadget.config = config


	-- Apply the configuration

	-- (Re)position, colour and texture the unit frames based on the configuration
	local groupId = 1
	for y = 1, cellCountY do
		for x = 1, cellCountX do
			local uf = gadget.UnitFrames[groupId]
			uf:SetWidth(config.cellWidth)
			uf:SetHeight(config.cellHeight)
			uf:SetBackgroundColor(unpack(config.cellBackgroundColor))
			uf:SetPoint("TOPLEFT", gadget, "TOPLEFT", config.borderThickness + config.padding + ((config.cellSpacing + config.cellWidth) * (x - 1)), config.borderThickness + config.padding + ((config.cellSpacing + config.cellHeight) * (y - 1)) ) 
			groupId = groupId + 1
		end
	end

	return gadget

end

WT.Gadget.RegisterFactory("Healer",
	{
		name="Healer",
		description="Healer's Raid Frames",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtSoulVitality.png",
		["Create"] = ApplyConfig,
		["Reconfigure"] = ApplyConfig,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})
