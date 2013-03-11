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

--[[
	wtGadget
	Core Gadget functionality
	
	This provides a mechanism for placing things on the screen, and automatically saving
	their location between sessions. The intention is to expand the concept of a 'Gadget'
	to do more in future, allowing for functionality to be available automatically across
	all Gadgets.
	
	Change 1: 	Altered the movement handle to be a child of WT.Context and increased it's
				layer to 9999. This should hopefully allow movement handles to always appear
				above all other frames.
				
	Change 2: 	Right clicking a movement handle will allow the gadget to be deleted from
				a popup menu.
				
	Change 3:	Abandoned the concept of a seperate configuration dialog for making changes to
				an existing gadget. Instead, gadgets are deleted and recreated with a new
				configuration when changes are made. This has the potential to generate an
				enormous number of dead frames. Therefore also added the 'Recommend a Reload'
				functionality which allows for a pop up box with a Reload UI button whenever
				the user should ideally reload.
--]]


local GRAB_KEYBOARD_ON_UNLOCK = false

-- Events -----------------------------------------------------------------------------------------------------
WT.Event.Trigger.GadgetsLocked, WT.Event.GadgetsLocked = Utility.Event.Create(AddonId, "GadgetsLocked")
WT.Event.Trigger.GadgetsUnlocked, WT.Event.GadgetsUnlocked = Utility.Event.Create(AddonId, "GadgetsUnlocked")
WT.Event.Trigger.GadgetSelected, WT.Event.GadgetSelected = Utility.Event.Create(AddonId, "GadgetSelected")
---------------------------------------------------------------------------------------------------------------

WT.Gadget = {}

WT.Gadgets = {}
wtxGadgets = wtxGadgets or {}
WT.Themes = {}

WT.GadgetFactories = {}

local gadgetsLocked = true

-- Register a Gadget Factory by providing a configuration table
-- The descriptive elements of the configuration will be used in configuration dialogs when they become available  
function WT.Gadget.RegisterFactory(gadgetType, configuration)
	-- Copy and establish defaults for the configuration
	local config = {}
	for k,v in pairs(configuration) do config[k] = v end
	config.gadgetType = gadgetType
	config.name = config.name or gadgetType
	config.description = config.description or "No description available for " .. gadgetType .. " gadgets."
	config.author = config.author or "Unknown Author"
	if config.version then
		config.version = tostring(config.version)
	else
		config.version ="Unknown Version"
	end
	
	config.iconTexAddon = config.iconTexAddon or AddonId 
	config.iconTexFile = config.iconTexFile or "img/wtGadget.png" -- should be a 32x32 image
	
	if config.CreateDialog then
		-- This is a function that returns a frame for use during creation of a gadget of this type. It will be included
		-- within an existing RiftWindow, so this should not be a full window in itself - just a frame that wraps the controls
		-- necessary to collect creation data. 
	end

	if config.AlterDialog then
		-- This is a function that returns a frame for use during alteration of an existing gadget of this type. It will be
		-- displayed when a user chooses to alter an existing gadget, called with the relevant Gadget instance.
	end
	
	if not config.Create then
		WT.Log.Error("No Create function in registration for gadget " .. gadgetType)
		return
	end
	
	if WT.GadgetFactories[gadgetType:lower()] then
		WT.Log.Error("Attempted to create duplicate factory for gadget " .. gadgetType)
		return
	end
	
	WT.GadgetFactories[gadgetType:lower()] = config
	WT.Log.Info("Registered gadget factory: " .. gadgetType)
end


-- Create a gadget given a gadget configuration table
-- This is a paranoid call, as an uncaught error here stops all subsequent gadgets loading
function WT.Gadget.Create(configuration)

	if not configuration or type(configuration) ~= "table" then
		WT.Log.Warning("Invalid configuration when creating gadget")
		return nil
	end

	local gadgetId = configuration.id
	local gadgetType = configuration.type

	if not gadgetId then
		WT.Log.Warning("Gadget configuration missing required field: id")
		return nil
	end

	if WT.Gadgets[gadgetId] then
		WT.Log.Warning("Attempted to create gadget with duplicate id: " .. gadgetId)
		return WT.Gadgets[gadgetId]
	end

	if not gadgetType then
		WT.Log.Warning("Gadget configuration missing required field: type")
		return nil
	end
	
	local gadgetFactory = WT.GadgetFactories[gadgetType:lower()]
	if not gadgetFactory then
		WT.Log.Warning("Could not find a factory for gadget type: " .. gadgetType)
		return nil
	end

	local gadget = nil
	local createOptions = nil

	local success, errMessage = pcall(
		function()
			gadget, createOptions = gadgetFactory.Create(configuration)
			if not createOptions then createOptions = {} end
			if not gadget then
				WT.Log.Warning("Factory for gadget type " .. gadgetType .. " failed to create gadget")
				return
			end		
			
			if createOptions.resizable and configuration.width then
				if (configuration.width < createOptions.resizable[1]) then configuration.width = createOptions.resizable[1] end  
				if (configuration.width > createOptions.resizable[3]) then configuration.width = createOptions.resizable[3] end  
			end 

			if createOptions.resizable and configuration.height then
				if (configuration.height < createOptions.resizable[2]) then configuration.height = createOptions.resizable[2] end  
				if (configuration.height > createOptions.resizable[4]) then configuration.height = createOptions.resizable[4] end  
			end 
			
			if configuration.width then gadget:SetWidth(configuration.width) end
			if configuration.height then gadget:SetHeight(configuration.height) end
			
			if configuration.width or configuration.height then 
				if gadget.OnResize then gadget:OnResize(configuration.width, configuration.height) end
			end 	
			
			WT.Gadgets[gadgetId] = gadget
			
			-- "Gadgetize" the returned frame, giving it a movement handle 
			WT.Gadget.AttachHandle(gadgetId, gadget, createOptions)
			
			WT.Log.Debug("Created gadget " .. gadgetId .. " of type " .. gadgetType)
			
			-- For now, default all gadgets to (200,200) on creation
			if not gadget.xpos then gadget.xpos = configuration.xpos or 200 end 
			if not gadget.ypos then gadget.ypos = configuration.ypos or 200 end 
			gadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", gadget.xpos, gadget.ypos) 
			
			-- Give the gadget a display root
			-- gadget.displayRoot = UI.CreateFrame("Frame", "displayRoot", gadget:GetParent())
			gadget.displayRoot = UI.CreateFrame("Frame", "displayRoot", WT.UnitFrameContext)
			-- Note: forcing all gadgets onto the same context so that layering can work
			
			gadget.displayRoot:SetSecureMode(gadget:GetSecureMode())
			gadget:SetParent(gadget.displayRoot)
			gadget.displayRoot:SetLayer(gadget:GetLayer())
			
			gadget.showGroup = {}
			
			gadget.showGroup.solo = configuration.show_Solo
			if gadget.showGroup.solo == nil then gadget.showGroup.solo = true end
			gadget.showGroup.party = configuration.show_Party
			if gadget.showGroup.party == nil then gadget.showGroup.party = true end
			gadget.showGroup.raid10 = configuration.show_Raid10
			if gadget.showGroup.raid10 == nil then gadget.showGroup.raid10 = true end
			gadget.showGroup.raid20 = configuration.show_Raid20
			if gadget.showGroup.raid20 == nil then gadget.showGroup.raid20 = true end
			gadget.alpha_IC = configuration.alpha_IC
			if gadget.alpha_IC == nil then gadget.alpha_IC = 100 end
			gadget.alpha_OOC = configuration.alpha_OOC
			if gadget.alpha_OOC == nil then gadget.alpha_OOC = 100 end
			
			gadget.displayRoot:SetAlpha(gadget.alpha_OOC / 100)
			
			WT.Gadget.SetGadgetGroupVisible(gadget, WT.GetGroupMode())
			
			-- store the configuration table
			wtxGadgets[gadgetId] = configuration
		end
	)		
	if not success then
		WT.Log.Warning("Error creating gadget " .. gadgetId .. ": " .. errMessage)
		return nil
	else
		return gadget
	end
end


local menuHandle = false
local menuHandleForGadget = false

local function OnMenuHandleClick(value)
	if value == "delete" then
	 	WT.Gadget.Command.delete(menuHandleForGadget)
	end
	if value == "modify" then
	 	WT.Gadget.Modify(menuHandleForGadget)
	end
	if value == "copy" then
	 	WT.Gadget.Command.copy(menuHandleForGadget)
	end
end

local function handleShowMenu()
	if not menuHandle then
		menuHandle =  WT.Control.Menu.Create(WT.Context, { 
			{text=TXT.ModifyGadget, value="modify"}, {text=TXT.CopyGadget, value="copy"}, {text=TXT.DeleteGadget, value="delete"}, {text=TXT.Cancel, value="cancel"} }, OnMenuHandleClick)
	end
	menuHandle:Show()
end

-- Initialises a gadget, configuring the frame to include the movement handle
function WT.Gadget.AttachHandle(gadgetId, frame, createOptions)

	-- Create the default (unthemed) movement handle
	local mvHandle = UI.CreateFrame("Texture", frame:GetName() .. "_mvHandle", WT.Context)
	mvHandle:SetLayer(9999)

	-- Create the overlay frame to highlight the gadget when unlocked
	local mvBox = UI.CreateFrame("Frame", frame:GetName() .. "_mvBox", mvHandle)
	mvBox:SetLayer(9998)
	mvBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
	mvBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	mvBox:SetBackgroundColor(1,1,1,0.2)

	-- Get the current frame position
	local currX = frame:GetLeft()
	local currY = frame:GetTop()

	-- Configure the default (unthemed) movement handle
	mvHandle:SetVisible(false)
	mvHandle.Event.MouseMove = function() WT.Gadget.DragMove(mvHandle) end
	mvHandle.Event.LeftDown = function() WT.Gadget.DragStart(mvHandle) end
	mvHandle.Event.LeftUp = function() WT.Gadget.DragStop(mvHandle) end
	mvHandle.Event.LeftUpoutside = function() WT.Gadget.DragStop(mvHandle) end
	mvHandle.Event.RightClick = function() handleShowMenu(); menuHandle:SetPoint("TOPLEFT", mvHandle, "BOTTOMLEFT"); menuHandleForGadget=gadgetId; end
	mvHandle.frame = frame
	mvHandle.gadgetId = gadgetId
	mvHandle:SetPoint("TOPLEFT", frame, "TOPLEFT")

	-- Setup the default mode assignment methods (these are replaced by the theme)
	mvHandle.NormalMode = function(handle) end
	mvHandle.AlignMode = function(handle) end

	frame.gadgetOverlay = {}
	frame.gadgetOverlay.box = mvBox
	frame.gadgetOverlay.handle = mvHandle

	-- Setup the resizing handle if required
	if createOptions.resizable then
		local szHandle = UI.CreateFrame("Texture", frame:GetName() .. "_szHandle", mvHandle) -- child of mvHandle, so will show/hide automatically 
		szHandle:SetLayer(9999)
		szHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		szHandle.Event.MouseMove = function() WT.Gadget.SizeMove(szHandle) end
		szHandle.Event.LeftDown = function() WT.Gadget.SizeStart(szHandle) end
		szHandle.Event.LeftUp = function() WT.Gadget.SizeStop(szHandle) end
		szHandle.Event.LeftUpoutside = function() WT.Gadget.SizeStop(szHandle) end
		szHandle.frame = frame
		szHandle.gadgetId = gadgetId
		szHandle.minX, szHandle.minY, szHandle.maxX, szHandle.maxY = unpack(createOptions.resizable)  
		frame.gadgetOverlay.resizer = szHandle
	end
	
	--[[
	if createOptions.caption then
		local uiCaption = UI.CreateFrame("Text", "wtCaption", mvHandle)
		uiCaption:SetText(createOptions.caption)
		uiCaption:SetPoint("CENTERLEFT", mvHandle, "CENTERRIGHT")
		uiCaption:SetFontSize(10)
	end
	--]]
	
	--table.insert(WT.Gadgets, mvHandle)
	WT.Gadgets[gadgetId].mvHandle = mvHandle

	-- Apply the selected theme to the overlay here
	local selectedTheme = "subtle" or wtxOptions.overlayTheme or "classic"
	local theme = WT.Themes[selectedTheme] or WT.Themes["classic"]
	theme.ApplyOverlayTheme(frame, createOptions) 

	-- If a saved position exists for this gadget, apply it on creation.
	-- This allows the 'gadgetization' of a frame that isn't actually a WT Gadget
	if wtxGadgets[gadgetId] then
		local saved = wtxGadgets[gadgetId]
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", saved.xpos or 0, saved.ypos or 0)
	end

	if not gadgetsLocked then
		mvHandle:SetVisible(true)
	end

end

function WT.Gadget:DragStart()
	if not WT.Gadget.InDragMode then
		self.dragging = true	
		WT.Gadget.InDragMode = true
		WT.Gadget.Dragging = self
		local mouse = Inspect.Mouse()
		self.startX = self.frame:GetLeft()
		self.startY = self.frame:GetTop()
		self.mouseStartX = mouse.x
		self.mouseStartY = mouse.y	
		WT.Log.Debug("DragStart " .. self.startX .. "," .. self.startY)
		WT.Event.Trigger.GadgetSelected(self.gadgetId)
		WT.Log.Info("Gadget Selected: " .. self.gadgetId) 
	end
end

function WT.Gadget:DragStop()
	if self.dragging then 
		WT.Log.Debug("DragStop")
		self.dragging = false
		WT.Gadget.Dragging = nil
		WT.Gadget.InDragMode = false
		
		wtxGadgets[self.gadgetId] = wtxGadgets[self.gadgetId] or {}
		
		wtxGadgets[self.gadgetId].xpos = self.frame:GetLeft()
		wtxGadgets[self.gadgetId].ypos = self.frame:GetTop()

		if WT.Gadget.alignTo then
			WT.Gadget.alignTo:NormalMode()
			WT.Gadget.alignTo = nil
			WT.Log.Debug("Alignment Mode Disengaged")
		end
	end 
end

function WT.Gadget:DragMove()
	if self.dragging then
		local mouse = Inspect.Mouse()
		local x = math.ceil(mouse.x - self.mouseStartX + self.startX)
		local y = math.ceil(mouse.y - self.mouseStartY + self.startY)
			
		local gs = WT.Gadget.GetGridSize()
		x = math.floor(x / gs) * gs
		y = math.floor(y / gs) * gs
			
		if WT.Gadget.alignTo then
			local alignTop = WT.Gadget.alignTo.frame:GetTop()
			local alignLeft = WT.Gadget.alignTo.frame:GetLeft()
			local deltaX = math.abs(x - alignLeft)
			local deltaY = math.abs(y - alignTop)
			
			-- check which axis we may be aligning to
			local lockAxis = ""
			if (deltaY <= 50) then lockAxis = "y" end
			if (deltaX <= 50) and (deltaX < deltaY) then lockAxis = "x" end			
			if lockAxis == "x" then 
				x = alignLeft
			elseif lockAxis == "y" then 
				y = alignTop
			else
				WT.Gadget.alignTo:NormalMode()
				WT.Gadget.alignTo = nil
				WT.Log.Debug("Alignment Mode Disengaged")
			end
		else
				-- mouseIn doesn't work if the frame isn't top level, so need to scan instead
			for idx, hnd in pairs(WT.Gadgets) do
				if hnd.mvHandle ~= self then
					local hndX = hnd.mvHandle:GetLeft()
					local hndY = hnd.mvHandle:GetTop()
					if (hndX <= x) and (hndX + 24 > x) and (hndY <= y) and (hndY + 24 > y) then
						WT.Gadget.MouseIn(hnd.mvHandle)
					end 
				end			
			end
 		end
 		
		self.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
		wtxGadgets[self.gadgetId].xpos = x
		wtxGadgets[self.gadgetId].ypos = y
		WT.Log.Verbose("DragMove " .. x .. "," .. y)
			
	end
end

function WT.Gadget:MouseIn()
	if WT.Gadget.InDragMode and not WT.Gadget.alignTo then
		if WT.Gadget.Dragging ~= self then
			-- Go into alignment mode
			WT.Gadget.alignTo = self
			self:AlignMode()
			WT.Log.Debug("Alignment Mode Engaged")
		end
	end
end



-- RESIZING FUNCTIONALITY

local origWidth = 0
local origHeight = 0
local constrainProportions = false


function WT.Gadget:SizeStart()
	if not WT.Gadget.InSizeMode then
		self.sizing = true	
		WT.Gadget.InSizeMode = true
		WT.Gadget.Sizing = self
		local mouse = Inspect.Mouse()
		self.startX = self.frame:GetRight()
		self.startY = self.frame:GetBottom()
		self.mouseStartX = mouse.x
		self.mouseStartY = mouse.y	
		WT.Log.Debug("SizeStart " .. self.startX .. "," .. self.startY)
		
		origWidth = self.frame:GetWidth()
		origHeight = self.frame:GetHeight()
	end
end

function WT.Gadget:SizeStop()
	if self.sizing then 
		WT.Log.Debug("SizeStop")
		self.sizing = false
		WT.Gadget.Sizing = nil
		WT.Gadget.InSizeMode = false	
		wtxGadgets[self.gadgetId] = wtxGadgets[self.gadgetId] or {}
		wtxGadgets[self.gadgetId].width = self.frame:GetWidth()
		wtxGadgets[self.gadgetId].height = self.frame:GetHeight()
	end 
end

function WT.Gadget:SizeMove()
	if self.sizing then
		local mouse = Inspect.Mouse()
		local x = mouse.x - self.mouseStartX + self.startX
		local y = mouse.y - self.mouseStartY + self.startY
		
		local gs = WT.Gadget.GetGridSize()
		x = math.floor(x / gs) * gs
		y = math.floor(y / gs) * gs		
		
		local newWidth = math.ceil(x - self.frame:GetLeft() + 1)		
		local newHeight = math.ceil(y - self.frame:GetTop() + 1)
			
		if newWidth < self.minX then newWidth = self.minX end
		if newWidth > self.maxX then newWidth = self.maxX end
		if newHeight < self.minY then newHeight = self.minY end
		if newHeight > self.maxY then newHeight = self.maxY end
		
		if constrainProportions then
			local deltaW = newWidth - origWidth
			local deltaH = newHeight - origHeight
			if math.abs(deltaH) > math.abs(deltaW) then
				-- moved mainly vertically
				local frac = newHeight / origHeight
				newWidth = origWidth * frac				
			else
				-- moved mainly horizontally
				local frac = newWidth / origWidth
				newHeight = origHeight * frac 			
			end 
		end
		
		self.frame:SetWidth(newWidth)
		self.frame:SetHeight(newHeight)
		wtxGadgets[self.gadgetId].width = newWidth
		wtxGadgets[self.gadgetId].height = newHeight
		if self.frame.OnResize then self.frame:OnResize(newWidth, newHeight) end
	end
end


local keyFocusFrame = nil
local escMessageShown = false

local function GadgetKeyDown(frame, hEvent, key)

	if (key == "Left Shift") or (key == "Shift") then
		constrainProportions = true
		print("Contrain On")
	end

end

local function GadgetKeyUp(frame, hEvent, key)

	if (key == "Left Shift") or (key == "Shift") then
		constrainProportions = false
		print("Contrain Off")
	end

	if key == "Escape" then
		WT.Gadget.LockAll()
	else
		if not escMessageShown then
			print("To lock gadgets and get your keyboard back, press [ESC] or click the Gadget button")
			escMessageShown = true
		end 
	end
end

function WT.Gadget.UnlockAll()
	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end
	
	for gadgetId, gadget in pairs(WT.Gadgets) do
		gadget.mvHandle:SetVisible(true)
	end
	gadgetsLocked = false

	if GRAB_KEYBOARD_ON_UNLOCK then
		if not keyFocusFrame then
			keyFocusFrame = UI.CreateFrame("Frame", "Gadgets_KeyHandler", WT.Context)
			keyFocusFrame:SetAllPoints(UIParent)
			keyFocusFrame:SetLayer(9900)
			keyFocusFrame:EventAttach(Event.UI.Input.Key.Down, GadgetKeyDown, "GdtKeyDown")
			keyFocusFrame:EventAttach(Event.UI.Input.Key.Up, GadgetKeyUp, "GdtKeyUp")
		end
		keyFocusFrame:SetVisible(true)
		keyFocusFrame:SetKeyFocus(true)	
		escMessageShown = false
	end
	
	WT.Event.Trigger.GadgetsUnlocked()
end


function WT.Gadget.LockAll()
	for idx, gadget in pairs(WT.Gadgets) do
		gadget.mvHandle:SetVisible(false)
	end
	gadgetsLocked = true

	if keyFocusFrame then
		keyFocusFrame:SetVisible(false)
		keyFocusFrame:SetKeyFocus(false)
	end
	
	WT.Event.Trigger.GadgetsLocked()
end


function WT.Gadget.ToggleAll()
	if gadgetsLocked then
		WT.Gadget.UnlockAll()
	else
		WT.Gadget.LockAll()
	end
end


function WT.Gadget.Modify(gadgetId)
	if not gadgetId then
		print("Missing <gadgetid>, cannot modify")
		return
	end
	if not wtxGadgets[gadgetId] then
		print("Gadget not found. Use '/gadget list' to display all gadgets")
		return
	end
	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end
	WT.Gadget.ShowModifyUI(gadgetId)
end

function WT.Gadget.Delete(gadgetId)
	if not gadgetId then
		print("Missing <gadgetid>, cannot delete")
		return
	end
	if not wtxGadgets[gadgetId] then
		print("Gadget not found. Use '/gadget list' to display all gadgets")
		return
	end
	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end
	
	if WT.Gadgets[gadgetId] then
		WT.Gadgets[gadgetId]:SetVisible(false)
		WT.Gadgets[gadgetId].mvHandle:SetVisible(false)
		WT.Gadgets[gadgetId] = nil
	end
	wtxGadgets[gadgetId] = nil
		
	-- Recommend a reload following deletions 
	WT.Gadget.RecommendReload()
end


function WT.Gadget.Copy(gadgetId)

	if not gadgetId then
		print("Missing <gadgetid>, cannot copy")
		return
	end
	if not wtxGadgets[gadgetId] then
		print("Gadget not found. Use '/gadget list' to display all gadgets")
		return
	end
	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end
	
	local newIdx = 1
	local newId = gadgetId .. "_Copy_" .. newIdx
	while wtxGadgets[newId] do
		newIdx = newIdx + 1
		newId = gadgetId .. "_Copy_" .. newIdx
	end
	local gadgetConfig = wtxGadgets[gadgetId]
	local newConfig = {}
	for k,v in pairs(gadgetConfig) do newConfig[k] = v end
	newConfig.id = newId
	newConfig.xpos = (gadgetConfig.xpos or 200) + 50
	newConfig.ypos = (gadgetConfig.ypos or 200) + 50
	WT.Gadget.Create(newConfig)
	
	return newId
end


function WT.Gadget.Locked()
	return gadgetsLocked
end


local function SetGadgetCombatAlpha(gadget, inCombat)

	local alpha = gadget.alpha_OOC
	if inCombat then alpha = gadget.alpha_IC end
	
	if alpha == 0 or gadget.showGroup[WT.GetGroupMode()] == false then
		gadget.displayRoot:SetVisible(false)
	else
		gadget.displayRoot:SetVisible(true)
		gadget.displayRoot:SetAlpha(alpha / 100)
	end

end


function WT.Gadget.SetGadgetGroupVisible(gadget, groupMode)
	local visible = gadget.showGroup[groupMode]
	if visible then
		WT.ShowSecureFrame(gadget.displayRoot)
	else
		WT.HideSecureFrame(gadget.displayRoot)
	end
end


local function OnGroupModeChanged(groupMode)
	for gadgetId, gadget in pairs(WT.Gadgets) do
		WT.Gadget.SetGadgetGroupVisible(gadget, groupMode)
	end
end


function WT.Gadget.SecureEnter()
	WT.Gadget.isSecure = true
	-- lock gadgets when the environment goes secure (can't move secure frames in secure mode) 
	if not gadgetsLocked then
		WT.Gadget.Command.lock()
	end
	
	-- We're entering combat, so set the IC alpha on all gadgets
	for gadgetId, gadget in pairs(WT.Gadgets) do
		SetGadgetCombatAlpha(gadget, true)
	end
end

function WT.Gadget.SecureLeave()
	WT.Gadget.isSecure = false

	-- We're entering combat, so set the IC alpha on all gadgets
	for gadgetId, gadget in pairs(WT.Gadgets) do
		SetGadgetCombatAlpha(gadget, false)
	end
end


local function Initialize()
	if not wtxGadgets then wtxGadgets = {} end
	for id, config in pairs(wtxGadgets) do
		WT.Log.Info("Loading Gadget: " .. config.id)
		WT.Gadget.Create(config)
	end 

	local gadgetList = ""
	for k,v in pairs(WT.GadgetFactories) do gadgetList = gadgetList .. v.name .. "; " end
	Command.Console.Display("general", true, "<font color='#6688cc'>Gadgets Initialised</font> ", true)
	-- Command.Console.Display("general", true, "<font color='#cccccc'>" .. gadgetList .. "</font> ", true)
end


local function OnSaveVariables(saveAddonId)
	if saveAddonId == AddonId then
		if not wtxLayouts then wtxLayouts = {} end
		local layoutId = WT.Player.name .. "@" .. Inspect.Shard().name 
		wtxLayouts[layoutId] = wtxGadgets 
	end
end

-- Register an initializer to handle loading of gadgets
WT.RegisterInitializer(Initialize)


table.insert(Event.System.Secure.Enter, { WT.Gadget.SecureEnter, AddonId, AddonId .. "_Gadget_SecureEnter" })
table.insert(Event.System.Secure.Leave, { WT.Gadget.SecureLeave, AddonId, AddonId .. "_Gadget_SecureLeave" })

table.insert(Event.Addon.SavedVariables.Save.Begin, { OnSaveVariables, AddonId, AddonId .. "_Gadget_OnSaveVariables" })

table.insert(WT.Event.GroupModeChanged, { OnGroupModeChanged, AddonId, AddonId .. "_OnGroupModeChanged" })