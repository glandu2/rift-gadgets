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
		anchorPoint = "BOTTOMLEFT", -- used when collapsing rows/columns
		borderThickness = 2,
		borderColor = { 0, 0, 0, 0.7 },
		borderPadding = 1,
		backgroundColor = { 0.5, 0.5, 0.5, 1 },
		backgroundMedia = "HealerBackdrop01",
	},
	
	groups = 
	{
		orientation = "horizontal",
		collapseEmptyGroups = true,
	},

	cells =
	{	
		width = 100,
		height = 40,
		spacing = 1,
		backgroundColor = { 0, 0, 0, 0.6 },
		backgroundMedia = nil,
	
		outerBorderThickness = 1,
		outerBorderColor = GX.Constants.Colors.Gray,
		outerBorderIndicator = "target",
		outerBorderIndicatorColor = GX.Constants.Colors.White,
	
		innerBorderThickness = 1,
		innerBorderColor = GX.Constants.Colors.Black,
		innerBorderIndicator = "aggro",
		innerBorderIndicatorColor = GX.Constants.Colors.Red,
		
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
			color = GX.Constants.Colors.White,
			alpha = 0.5,
			thickness = 4,
			margin = { 0, 0 }, -- either L/R or T/B
			orientation = "horizontal",
			offset = 30,
		},
		
		hotbar02 = 
		{
			enabled = true,
			color = GX.Constants.Colors.White,
			alpha = 0.5,
			thickness = 4,
			margin = { 0, 0 },
			orientation = "horizontal",
			offset = 36,
		},
		
		hotbar03 = 
		{
			enabled = true,
			color = GX.Constants.Colors.White,
			alpha = 0.5,
			thickness = 4,
			margin = { 0, 0 },
			orientation = "horizontal",
			offset = 42,
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
	return {}
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
	config.borderThickness = 2
	config.borderColor = { 0, 0, 0, 0.7 }
	config.borderPadding = 1
	config.backgroundColor = { 0.5, 0.5, 0.5, 1 }
	config.backgroundTexture = {"Rift", "mtx_window_medium_bg_(blue).png.dds"}
	
	config.cellWidth = 100
	config.cellHeight = 40
	config.cellSpacing = 1
	config.cellBackgroundColor = { 0, 0, 0, 0.6 }

	config.cellOuterBorderThickness = 1
	config.cellOuterBorderColor = GX.Constants.Colors.Gray
	config.cellOuterBorderIndicator = "playerTarget"
	config.cellOuterBorderIndicatorColor = GX.Constants.Colors.White

	config.cellInnerBorderThickness = 1
	config.cellInnerBorderColor = GX.Constants.Colors.Black
	config.cellInnerBorderIndicator = "aggro"
	config.cellInnerBorderIndicatorColor = GX.Constants.Colors.Red

	config.groupOrientation = "horizontal"
	config.collapseEmptyRows = true
	config.collapseEmptyCols = true
	config.anchorPoint = "BOTTOMLEFT"

	-- Begin first time creation of gadget 
	if not gadget then
	
		local ctx = UI.CreateContext("ctxHealer_" .. gadgetId)
		ctx:SetSecureMode("restricted")
		ctx:SetStrata("hud")
	
		gadget = UI.CreateFrame("Frame", "HealerFrame", ctx)
		gadget.UIContext = ctx
		gadget.id = gadgetId
		gadget.healerConfig = config
		gadget:SetSecureMode("restricted")
		gadget.Frames = {}
		gadget.UnitFrames = {}
		gadget.Macros = {}
		-- gadget:SetBackgroundColor(0.2, 0.4, 0.6)
		
		gadget.Frames.Border = UI.CreateFrame("Frame", "Border", gadget)
		gadget.Frames.Border:SetLayer(0)
		gadget.Frames.Border:SetBackgroundColor(unpack(config.borderColor))
		gadget.Frames.Border:SetAllPoints(gadget)

		gadget.Frames.Background = UI.CreateFrame("Texture", "Background", gadget)
		gadget.Frames.Background:SetTexture(config.backgroundTexture[1], config.backgroundTexture[2])
		gadget.Frames.Background:SetLayer(10)
		gadget.Frames.Background:SetAlpha(0.4)
		gadget.Frames.Background:SetBackgroundColor(unpack(config.backgroundColor))
		gadget.Frames.Background:SetPoint("TOPLEFT", gadget.Frames.Border, "TOPLEFT", config.borderThickness, config.borderThickness)
		gadget.Frames.Background:SetPoint("BOTTOMRIGHT", gadget.Frames.Border, "BOTTOMRIGHT", -config.borderThickness, -config.borderThickness)
		
		local DEBUG = true
		
		for groupId = 1, 20 do

			local unitSpec

			if not DEBUG then
				unitSpec = "group" .. string.format("%02d", groupId)
			else
				if groupId == 1 then
					unitSpec = "player"
				else
					unitSpec = "player.target"
				end
			end

			local uf = WT.UnitFrame:Create(unitSpec)
			uf.gadget = gadget
			uf:SetParent(gadget)
			uf:SetLayer(20)
			gadget.UnitFrames[groupId] = uf

			-- To seperate mouse handling from graphical display, the secure frame is going to be separated
			-- and overlaid.
			
			uf.secureOverlay = UI.CreateFrame("Frame", "SecureFrame", gadget)
			uf.secureOverlay.unitFrame = uf
			uf.secureOverlay:SetSecureMode("restricted")
			uf.secureOverlay:SetMouseoverUnit(unitSpec)
			uf.secureOverlay:SetLayer(30)
			uf.secureOverlay:SetAllPoints(uf)
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Left.Down, OnCellClickLeft, "OnCellClickLeft") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Middle.Down, OnCellClickMiddle, "OnCellClickMiddle") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Right.Down, OnCellClickRight, "OnCellClickRight") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Mouse4.Down, OnCellClickMouse4, "OnCellClickMouse4") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Mouse5.Down, OnCellClickMouse5, "OnCellClickMouse5") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Wheel.Forward, OnCellWheelForward, "OnCellWheelForward") 
			uf.secureOverlay:EventAttach(Event.UI.Input.Mouse.Wheel.Back, OnCellWheelBack, "OnCellWheelBack") 
			if DEBUG then 
				uf.secureOverlay:SetBackgroundColor(1,0,0,0.1)
			end
			
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
	local cellCountX, cellCountY	
	
	if config.groupOrientation == "horizontal" then
		cellCountX = 5
		cellCountY = 4
	else
		cellCountX = 4
		cellCountY = 5
	end 

	local totalWidth = (cellCountX * config.cellWidth) + ((cellCountX - 1) * config.cellSpacing) + (2 * config.borderPadding) + (2 * config.borderThickness)
	local totalHeight = (cellCountY * config.cellHeight) + ((cellCountY - 1) * config.cellSpacing) + (2 * config.borderPadding) + (2 * config.borderThickness)

	gadget:SetWidth(totalWidth)
	gadget:SetHeight(totalHeight)

	-- (Re)position, colour and texture the unit frames based on the configuration
	local groupId = 1
	for y = 1, cellCountY do
		for x = 1, cellCountX do
			local uf = gadget.UnitFrames[groupId]
			uf:SetWidth(config.cellWidth)
			uf:SetHeight(config.cellHeight)
			uf:SetBackgroundColor(unpack(config.cellBackgroundColor))
			uf:SetPoint("TOPLEFT", gadget, "TOPLEFT", config.borderThickness + config.borderPadding + ((config.cellSpacing + config.cellWidth) * (x - 1)), config.borderThickness + config.borderPadding + ((config.cellSpacing + config.cellHeight) * (y - 1)) ) 
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
