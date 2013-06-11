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

local defaultConfig = 
{
	frame = 
	{
		-- NOT IMPLEMENTED YET: anchorPoint = "BOTTOMLEFT", -- used when collapsing groups
		borderThickness = 2,
		borderColor = { 0, 0, 0, 0.7 },
		borderPadding = 2,
		backgroundColor = { 0.5, 0.5, 0.5, 1 },
		backgroundMedia = "HealerBackdrop01",
	},
	
	groups = 
	{
		orientation = "horizontal",
		-- NOT IMPLEMENTED YET: collapseEmptyGroups = true,
	},

	cells =
	{	
		width = 100,
		height = 40,
		spacing = 1,
		backgroundColor = { 0.3, 0.3, 0.3, 0.6 },
		backgroundMedia = "RaidFrameBackdrop01",
	
		outerBorderThickness = 1,
		outerBorderColor = GX.Constants.Colors.Gray,
		-- NOT IMPLEMENTED YET: outerBorderIndicator = "target",
		-- NOT IMPLEMENTED YET: outerBorderIndicatorColor = GX.Constants.Colors.White,
	
		innerBorderThickness = 1,
		innerBorderColor = GX.Constants.Colors.Black,
		-- NOT IMPLEMENTED YET: innerBorderIndicator = "aggro",
		-- NOT IMPLEMENTED YET: innerBorderIndicatorColor = GX.Constants.Colors.Red,
		
		healthBarColor = GX.Constants.Colors.Green,
		healthBarMedia = "riftRaidHealthBar",
		healthBarIndicator = "cleansable",
		healthBarIndicatorColor = GX.Constants.Colors.Purple,

		resourceBarColor = "resourceColor",
		resourceBarMedia = nil,
		resourceBarIndicator = nil,
		resourceBarIndicatorColor = nil,
		resourceBarThickness = 4,

		absorbBarColor = GX.Constants.Colors.Cyan,
		absorbBarThickness = 2,
	},

	-- These are macro IDs, they reference the macro system
	-- (when that exists)	
	macros = 
	{
		Left = "_target",
		Middle = "",
		Right = "_menu",
		Mouse4 = "",
		Mouse5 = "",
		WheelForward = "",
		WheelBack = "",
		
	},
	
	hotbars = 
	{
		hotbar01 = 
		{
			enabled = true,
			color = { r = 1, g = 1, b = 1, a = 0.7 },
			thickness = 2,
			margin = { 3, 7 }, -- either L/R or T/B
			orientation = "vertical",
			offset = 89,
		},
		
		hotbar02 = 
		{
			enabled = true,
			color = { r = 0.0, g = 1.0, b = 1.0, a = 0.7 },
			thickness = 2,
			margin = { 3, 7 },
			orientation = "vertical",
			offset = 92,
		},
		
		hotbar03 = 
		{
			enabled = true,
			color = { r = 0.0, g = 0.0, b = 1.0, a = 0.7 },
			thickness = 2,
			margin = { 3, 7 },
			orientation = "vertical",
			offset = 95,
		},
		
		assignments = 
		{
			role01 = 
			{
				hotbar01 = "Healing Spray",
				hotbar02 = "Healing Flood",
				hotbar03 = "",
			}
		}
	},
	
	hotindicators = 
	{
		{
			anchor = "BOTTOMLEFT",
			offset = {1, -1},
			size = 16,
			textSize = 12,
			textColor = GX.Constants.Colors.White,
			textOutline = true,
			text = "stack",
			showIcon = true,
			color = GX.Constants.Colors.Cyan,
			assignments = 
			{
				role01 = "Healing Spray",
			}
		},
		{
			anchor = "BOTTOMLEFT",
			offset = {18, -1},
			size = 16,
			textSize = 12,
			textColor = GX.Constants.Colors.White,
			textOutline = true,
			text = "time",
			showIcon = true,
			color = GX.Constants.Colors.Green,
			assignments = 
			{
				role01 = "Healing Flood",
			}
		},
		{
			anchor = "BOTTOMLEFT",
			offset = {35, -1},
			size = 16,
			textSize = 12,
			textColor = GX.Constants.Colors.White,
			textOutline = true,
			text = "",
			showIcon = true,
			color = GX.Constants.Colors.Yellow,
			assignments = 
			{
				role01 = "Healing Current",
			}
		},
	},
	
	indicator_mark = {
		enabled = true,
		anchor = "TOPRIGHT",
		size = 13,
		offset = { -1, 1 },
	},
	
	indicator_role = {
		enabled = true,
		anchor = "TOPLEFT",
		size = 13,
		offset = { 1, 1 },
	},

	indicator_ready = {
		enabled = true,
		anchor = "CENTER",
		size = 16,
		offset = { 40, 0 },
	},

	indicator_dead = {
		enabled = true,
		anchor = "CENTER",
		size = 32,
		offset = { 0, 0 },
	},

	indicator_cleansable = {
		enabled = false,
		anchor = "CENTER",
		size = 32,
		offset = { 0, 0 },
	},

	indicator_afk = {
		enabled = false,
		anchor = "CENTER",
		size = 16,
		offset = { -40, 0 },
	},

	indicator_disconnected = {
		enabled = false,
		anchor = "TOPCENTER",
		size = 16,
		offset = { 0, 1 },
	},

	indicator_aggro = {
		enabled = false,
		anchor = "CENTER",
		size = 16,
		offset = { 0, 0 },
	},

	indicator_target = {
		enabled = false,
		anchor = "CENTER",
		size = 16,
		offset = { 0, 0 },
	},
		
	blocked = {
		enabled = true,
		alpha = 0.6,
		color = GX.Constants.Colors.Black,
	},
	
	labels = 
	{
		name = 
		{
			anchor = "CENTER",
			offset = { 0, 0 },
			maxlength = 8,
			font = nil,
			fontsize = 12,
			outline = true,
			color = "calling",
		},
		
		status = 
		{
			anchor = "CENTER",
			offset = { 0, 12 },
			maxlength = nil,
			fontsize = 10,
			font = nil,
			outline = true,
			color = GX.Constants.Colors.White,
		}
	},
		
}


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
	return defaultConfig
end

local function SetConfiguration(config)
	-- do nothing yet
end


local started = false

local isSecure = false

local function OnSecureModeEnter()
	isSecure = true
end

local function OnSecureModeLeave()
	isSecure = false
end

local function Startup()
	Command.Event.Attach(Event.System.Secure.Enter, OnSecureModeEnter, "OnSecureModeEnter")
	Command.Event.Attach(Event.System.Secure.Leave, OnSecureModeLeave, "OnSecureModeLeave")
end

local function OnCellClick(unitFrame, button)
	local gadget = unitFrame.gadget
	local macroId = gadget.Macros[button]
	if not macroId then
		return
	end
	-- Need to link into the macro database, to pick up the actual
	-- macro to run.
	print("Execute macro ID: " .. macroId)
end

local function OnCellClickLeft(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "Left")
end

local function OnCellClickMiddle(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "Middle")
end

local function OnCellClickRight(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "Right")
end

local function OnCellClickMouse4(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "Mouse4")
end

local function OnCellClickMouse5(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "Mouse5")
end

local function OnCellWheelForward(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "WheelForward")
end

local function OnCellWheelBack(ufOverlay, hEvent)
	OnCellClick(ufOverlay.unitFrame, "WheelBack")
end


local function ApplyConfig(config)

	if not started then
		Startup()
	end

	local gadgetId = config.id
	local gadget = HealerGadgets[gadgetId]

	-- For testing
	
	for k,v in pairs(defaultConfig) do
		if k ~= id then
			config[k] = v
		end
	end

	
	-- Begin first time creation of gadget
	-- This just creates the frame hierarchy, the actual layout comes after
	if not gadget then
	
		local ctx = UI.CreateContext("ctxHealer_" .. gadgetId)
		ctx:SetSecureMode("restricted")
		ctx:SetStrata("hud")
	
		gadget = UI.CreateFrame("Frame", "HealerFrame", ctx)
		gadget.context = ctx
		gadget.id = gadgetId
		gadget.healerConfig = config
		gadget:SetSecureMode("restricted")
		gadget.Frames = {}
		gadget.UnitFrames = {}
		gadget.Macros = {}
		-- gadget:SetBackgroundColor(0.2, 0.4, 0.6)
		
		gadget.Frames.Border = UI.CreateFrame("Frame", "Border", gadget)
		gadget.Frames.Border:SetLayer(0)
		gadget.Frames.Border:SetAllPoints(gadget)

		gadget.Frames.Background = UI.CreateFrame("Texture", "Background", gadget)
		gadget.Frames.Background:SetLayer(10)
		
		local DEBUG = false
		
		for groupId = 1, 20 do

			local unitSpec

			if not DEBUG then
				unitSpec = "group" .. string.format("%02d", groupId)
			else
				if groupId >= 1 and groupId <= 5 then
					unitSpec = "player"
				elseif groupId >= 6 and groupId <= 10 then
					unitSpec = "focus"
				elseif groupId >= 11 and groupId <= 15 then
					unitSpec = "player.target"
				else
					unitSpec = "group" .. string.format("%02d", groupId)
				end
			end

			local uf = WT.UnitFrame:Create(unitSpec)
			uf.gadget = gadget
			uf:SetParent(gadget)
			uf:SetLayer(20)
			uf.background = UI.CreateFrame("Texture", "UFBackground", uf)
			uf.background:SetLayer(2)
			uf.background:SetAllPoints(uf)
			gadget.UnitFrames[groupId] = uf

			uf.hotbar01 = UI.CreateFrame("Frame", "Hotbar01", uf)
			uf.hotbar02 = UI.CreateFrame("Frame", "Hotbar02", uf)
			uf.hotbar03 = UI.CreateFrame("Frame", "Hotbar03", uf)			

			-- To seperate mouse handling from graphical display, the secure frame is going to be separated
			-- and overlaid.
			
			uf.secureOverlay = UI.CreateFrame("Frame", "SecureFrame", gadget)
			uf.secureOverlay.unitFrame = uf
			uf.secureOverlay:SetSecureMode("restricted")
			uf.secureOverlay:SetMouseoverUnit(unitSpec)
			uf.secureOverlay:SetLayer(30)
			uf.secureOverlay:SetAllPoints(uf)
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Left.Down, OnCellClickLeft, "OnCellClickLeft") 
			uf.secureOverlay:EventMacroSet(Event.UI.Input.Mouse.Left.Down, "target @" .. unitSpec)
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Middle.Down, OnCellClickMiddle, "OnCellClickMiddle") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Right.Down, OnCellClickRight, "OnCellClickRight") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Mouse4.Down, OnCellClickMouse4, "OnCellClickMouse4") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Mouse5.Down, OnCellClickMouse5, "OnCellClickMouse5") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, OnCellWheelForward, "OnCellWheelForward") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Wheel.Back, OnCellWheelBack, "OnCellWheelBack") 
			
			uf:CreateBinding("id", uf, function(frm, id) if id then frm:SetVisible(true) else frm:SetVisible(false) end end)
			
			-- Add all of the elements from the cell template
			for idx, element in ipairs(data.wtHealer.CellTemplate) do
				uf:CreateElement(element)
			end 
			
			uf:ApplyDefaultBindings()
			
			-- Create bindings for everything we need to monitor when dynamically
			-- altering the cell's appearance. Can't effectively use normal template 
			-- bindings because of the need to change what is being bound.
			data.wtHealer.RegisterForChanges(uf)			
		end
		
		HealerGadgets[gadgetId] = gadget
	end
	-- End first time creation of gadget
	
	-- store a copy of the configuration data
	gadget.config = config


	-- Apply the configuration

	gadget.Frames.Background:SetBackgroundColor(unpack(config.frame.backgroundColor))
	if config.frame.backgroundMedia and (config.frame.backgroundMedia ~= "") then
		local bgtex = Library.Media.GetTexture(config.frame.backgroundMedia)
		if bgtex then
			gadget.Frames.Background:SetTexture(bgtex.addonId, bgtex.filename)
		else
			gadget.Frames.Background:SetTexture("Rift", "")
		end
	end 

	gadget.Frames.Background:SetAlpha(0.4)
	gadget.Frames.Background:SetBackgroundColor(unpack(config.frame.backgroundColor))
	gadget.Frames.Background:SetPoint("TOPLEFT", gadget.Frames.Border, "TOPLEFT", config.frame.borderThickness, config.frame.borderThickness)
	gadget.Frames.Background:SetPoint("BOTTOMRIGHT", gadget.Frames.Border, "BOTTOMRIGHT", -config.frame.borderThickness, -config.frame.borderThickness)

	gadget.Frames.Border:SetBackgroundColor(unpack(config.frame.borderColor))

	local cellCountX, cellCountY	
	
	if config.groups.orientation == "horizontal" then
		cellCountX = 5
		cellCountY = 4
	else
		cellCountX = 4
		cellCountY = 5
	end 

	local totalWidth = (cellCountX * config.cells.width) + ((cellCountX - 1) * config.cells.spacing) + (2 * config.frame.borderPadding) + (2 * config.frame.borderThickness)
	local totalHeight = (cellCountY * config.cells.height) + ((cellCountY - 1) * config.cells.spacing) + (2 * config.frame.borderPadding) + (2 * config.frame.borderThickness)

	gadget:SetWidth(totalWidth)
	gadget:SetHeight(totalHeight)

	local function cellPos(x,y)
		return config.frame.borderThickness + config.frame.borderPadding + ((config.cells.spacing + config.cells.width) * (x - 1)),
			   config.frame.borderThickness + config.frame.borderPadding + ((config.cells.spacing + config.cells.height) * (y - 1))
	end

	-- (Re)position, colour and texture the unit frames based on the configuration
	local cellBgMedia = nil
	if config.cells.backgroundMedia and (config.cells.backgroundMedia ~= "") then
		cellBgMedia = Library.Media.GetTexture(config.cells.backgroundMedia)
	end
	
	local groupId = 1
	for y = 1, 4 do
		for x = 1, 5 do
			local uf = gadget.UnitFrames[groupId]
			uf:SetWidth(config.cells.width)
			uf:SetHeight(config.cells.height)
			
			local borderThickness = config.cells.outerBorderThickness + config.cells.innerBorderThickness 
			
			uf.background:SetBackgroundColor(unpack(config.cells.backgroundColor))
			uf.background:ClearAll()
			uf.background:SetPoint("TOPLEFT", uf, "TOPLEFT", borderThickness, borderThickness)   
			uf.background:SetPoint("BOTTOMRIGHT", uf, "BOTTOMRIGHT", -borderThickness, -borderThickness)   
			if cellBgMedia then						
				uf.background:SetTexture(cellBgMedia.addonId, cellBgMedia.filename)
			else
				uf.background:SetTexture("Rift", "")
			end
			
			--outerBorderThickness = 1,
			--outerBorderColor = GX.Constants.Colors.Gray,			
		
			local healthBar = uf.Elements["barHealth"]
			healthBar:ClearAll()
			healthBar:SetPoint("TOPLEFT", uf, "TOPLEFT", borderThickness, borderThickness)   
			healthBar:SetPoint("BOTTOMRIGHT", uf, "BOTTOMRIGHT", -borderThickness, -(borderThickness + config.cells.resourceBarThickness))   

			local resourceBar = uf.Elements["barResource"]
			resourceBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT")   
			resourceBar:SetPoint("BOTTOMRIGHT", uf, "BOTTOMRIGHT", -borderThickness, -borderThickness)   

			local outerBorder = uf.Elements["outerBorder"]
			outerBorder:SetBackgroundColor(config.cells.outerBorderColor.r, config.cells.outerBorderColor.g, config.cells.outerBorderColor.b, config.cells.outerBorderColor.a)

			local innerBorder = uf.Elements["innerBorder"]
			innerBorder:ClearAll()
			innerBorder:SetPoint("TOPLEFT", uf, "TOPLEFT", config.cells.outerBorderThickness, config.cells.outerBorderThickness)
			innerBorder:SetPoint("BOTTOMRIGHT", uf, "BOTTOMRIGHT", -config.cells.outerBorderThickness, -config.cells.outerBorderThickness)
			innerBorder:SetBackgroundColor(config.cells.innerBorderColor.r, config.cells.innerBorderColor.g, config.cells.innerBorderColor.b, config.cells.innerBorderColor.a)

			local function setupHotBar(ufrm, bar, conf)
				bar:SetVisible(conf.enabled)
				bar:SetLayer(35)
				if conf.orientation == "horizontal" then
					bar:SetPoint("TOPLEFT", ufrm, "TOPLEFT", conf.margin[1], conf.offset) 
					bar:SetPoint("BOTTOMRIGHT", ufrm, "TOPRIGHT", -conf.margin[2], conf.offset + conf.thickness)
				else 
					bar:SetPoint("TOPLEFT", ufrm, "TOPLEFT", conf.offset, conf.margin[1]) 
					bar:SetPoint("BOTTOMRIGHT", ufrm, "BOTTOMLEFT", conf.offset + conf.thickness, -conf.margin[2])
				end
				bar:SetBackgroundColor(conf.color.r, conf.color.g, conf.color.b, conf.color.a)
			end

			setupHotBar(uf, uf.hotbar01, config.hotbars.hotbar01)
			setupHotBar(uf, uf.hotbar02, config.hotbars.hotbar02)
			setupHotBar(uf, uf.hotbar03, config.hotbars.hotbar03)
						
			if config.groups.orientation == "horizontal" then
				uf:SetPoint("TOPLEFT", gadget, "TOPLEFT", cellPos(x, y) )
			else
				uf:SetPoint("TOPLEFT", gadget, "TOPLEFT", cellPos(y, x) )
			end 
			
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
