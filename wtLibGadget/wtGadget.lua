--[[ 
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

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

local toc, data = ...
local AddonId = toc.identifier

WT.Gadget = {}
WT.Gadget.Command = {}

WT.Gadgets = {}
wtxGadgets = wtxGadgets or {}

WT.GadgetFactories = {}

local btnGadget = UI.CreateFrame("Texture", AddonId .. "_btnGadget", WT.Context)
btnGadget:SetTexture(AddonId, "img/btnGadgetMenu.png")

local btnDragging = false
local btnStartX = 0
local btnStartY = 0
local btnMouseStartX = 0
local btnMouseStartY = 0
local btnDragged = false
local gadgetsLocked = true

local function btnDragStart()
	WT.Utility.DeAnchor(btnGadget)
	local mouse = Inspect.Mouse()
	btnDragging = true
	btnStartX = btnGadget:GetLeft()
	btnStartY = btnGadget:GetTop()
	btnMouseStartX = mouse.x
	btnMouseStartY = mouse.y
	btnDragged = false	
end

local function btnDragMove()
	if btnDragging then
		local mouse = Inspect.Mouse()
		local x = mouse.x - btnMouseStartX + btnStartX
		local y = mouse.y - btnMouseStartY + btnStartY
		btnGadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
		wtxOptions.btnGadgetX = x
		wtxOptions.btnGadgetY = y
		btnDragged = true	
	end
end

local function btnDragStop()
	btnDragging = false
	-- try to detect a left click instead of a drag
	if not btnDragged then
		if gadgetsLocked then
			WT.Gadget.Command.unlock()
		else
			WT.Gadget.Command.lock()
		end
	end
end

local btnMenu = nil
local menuItems = 
{
	{text="Add Gadget", value=function() WT.Gadget.ShowCreationUI() end },
	{text="Lock Gadgets", value=function() WT.Gadget.Command.lock() end },
	{text="Unlock Gadgets", value=function() WT.Gadget.Command.unlock() end },
}

local function btnShowMenu()
	if not btnMenu then
		btnMenu =  WT.Control.Menu.Create(btnGadget, menuItems)
		btnMenu:SetPoint("TOPRIGHT", btnGadget, "CENTER") 
	end
	btnMenu:Toggle()
end

btnGadget.Event.LeftDown = btnDragStart
btnGadget.Event.MouseMove = btnDragMove
btnGadget.Event.LeftUp = btnDragStop
btnGadget.Event.LeftUpoutside = btnDragStop
btnGadget.Event.RightClick = btnShowMenu

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
function WT.Gadget.Create(configuration)

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

	local gadget = gadgetFactory.Create(configuration)
	if not gadget then
		WT.Log.Warning("Factory for gadget type " .. gadgetType .. " failed to create gadget")
		return nil
	end
	
	WT.Gadgets[gadgetId] = gadget
	
	-- "Gadgetize" the returned frame, giving it a movement handle 
	WT.Gadget.AttachHandle(gadgetId, gadget)
	
	WT.Log.Debug("Created gadget " .. gadgetId .. " of type " .. gadgetType)
	
	-- For now, default all gadgets to (200,200) on creation
	if not gadget.xpos then gadget.xpos = configuration.xpos or 200 end 
	if not gadget.ypos then gadget.ypos = configuration.ypos or 200 end 
	gadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", gadget.xpos, gadget.ypos) 
	
	-- store the configuration table
	wtxGadgets[gadgetId] = configuration
	
	return gadget
end


local menuHandle = false
local menuHandleForGadget = false

local function OnMenuHandleClick(value)
	if value == "delete" then
	 	WT.Gadget.Command.remove(menuHandleForGadget)
	end
	if value == "modify" then
	 	WT.Gadget.Command.modify(menuHandleForGadget)
	end
end

local function handleShowMenu()
	if not menuHandle then
		menuHandle =  WT.Control.Menu.Create(WT.Context, { {text="Modify Gadget", value="modify"}, {text="Delete Gadget", value="delete"}, "Cancel"}, OnMenuHandleClick)
	end
	menuHandle:Show()
end

-- Initialises a gadget, configuring the frame to include the movement handle
function WT.Gadget.AttachHandle(gadgetId, frame)

	local currX = frame:GetLeft()
	local currY = frame:GetTop()

	local mvHandle = UI.CreateFrame("Texture", frame:GetName() .. "_mvHandle", WT.Context)
	mvHandle:SetLayer(9999)
	mvHandle:SetWidth(24)
	mvHandle:SetHeight(24)
	mvHandle:SetTexture(AddonId, "img/wtGadgetHandle.png")
	mvHandle:SetPoint("TOPLEFT", UIParent, "TOPLEFT", currX-12, currY-12)
	mvHandle:SetVisible(false)
	mvHandle.Event.MouseMove = function() WT.Gadget.DragMove(mvHandle) end
	mvHandle.Event.LeftDown = function() WT.Gadget.DragStart(mvHandle) end
	mvHandle.Event.LeftUp = function() WT.Gadget.DragStop(mvHandle) end
	mvHandle.Event.LeftUpoutside = function() WT.Gadget.DragStop(mvHandle) end
	mvHandle.Event.RightClick = function() handleShowMenu(); menuHandle:SetPoint("TOPLEFT", mvHandle, "BOTTOMLEFT"); menuHandleForGadget=gadgetId; end
	mvHandle.frame = frame
	mvHandle.gadgetId = gadgetId
	
	--table.insert(WT.Gadgets, mvHandle)
	WT.Gadgets[gadgetId].mvHandle = mvHandle
	
	mvHandle:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, -12)

	local mvBox = UI.CreateFrame("Frame", frame:GetName() .. "_mvBox", mvHandle)
	mvBox:SetLayer(9998)
	mvBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
	mvBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
	mvBox:SetBackgroundColor(1,1,1,0.2)

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
			WT.Gadget.alignTo:SetTexture(AddonId, "img/wtGadgetHandle.png")			
			WT.Gadget.alignTo = nil
			WT.Log.Debug("Alignment Mode Disengaged")
		end
	end 
end

function WT.Gadget:DragMove()
	if self.dragging then
		local mouse = Inspect.Mouse()
		local x = mouse.x - self.mouseStartX + self.startX
		local y = mouse.y - self.mouseStartY + self.startY
			
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
				WT.Gadget.alignTo:SetTexture(AddonId, "img/wtGadgetHandle.png")			
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
			self:SetTexture(AddonId, "img/wtGadgetHandle_Lit.png")
			WT.Log.Debug("Alignment Mode Engaged")
		end
	end
end

function WT.Gadget.Command.unlock()
	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end
	for gadgetId, gadget in pairs(WT.Gadgets) do
		gadget.mvHandle:SetVisible(true)
	end
	gadgetsLocked = false
end

function WT.Gadget.Command.lock()
	for idx, gadget in pairs(WT.Gadgets) do
		gadget.mvHandle:SetVisible(false)
	end
	gadgetsLocked = true
end


-- e.g. /gadget add UnitFrame ufPlayer unit player
function WT.Gadget.Command.add(gadgetType, gadgetId, ...)

	if WT.Gadget.isSecure then
		print("Cannot alter gadgets in combat")
		return
	end

	if not gadgetType then
		WT.Gadget.ShowCreationUI()
		return
	end

	local arg = { ... }
	arg.n = #arg

	local config = {}
	config.type = gadgetType
	config.id = gadgetId

	local i = 1
	while i < arg.n do
		config[arg[i]] = arg[i+1]
		i = i + 2
	end
	WT.Gadget.Create(config)
	
end

function WT.Gadget.Command.list()
	for gadgetId,config in pairs(wtxGadgets) do
		print(string.format("Gadget: %s (%s)", gadgetId, config.type)) 
	end
end

function WT.Gadget.Command.remove(gadgetId)
	if not gadgetId then
		print("Syntax: /gadget remove <gadgetid>")
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
	
	WT.Gadgets[gadgetId]:SetVisible(false)
	WT.Gadgets[gadgetId].mvHandle:SetVisible(false)
	WT.Gadgets[gadgetId] = nil
	wtxGadgets[gadgetId] = nil
	
	-- Recommend a reload following deletions 
	WT.Gadget.RecommendReload()
	
end


function WT.Gadget.Command.modify(gadgetId)
	if not gadgetId then
		print("Syntax: /gadget modify <gadgetid>")
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


function WT.Gadget.Command.reset()
	WT.Utility.DeAnchor(btnGadget)
	btnGadget:ClearPoint("LEFT")
	btnGadget:ClearPoint("TOP")
	btnGadget:SetPoint("CENTER", UIParent, "CENTER")
	wtxOptions.btnGadgetX = btnGadget:GetLeft()
	wtxOptions.btnGadgetY = btnGadget:GetTop()
end


function WT.Gadget.OnSlashCommand(cmd)
	local words = {}
	for word in string.gmatch(cmd, "[^%s]+") do table.insert(words, word) end
	local numWords = table.getn(words)
	if numWords > 0 then
		local command = string.lower(words[1])
		local args = {}
		for i = 2, numWords do table.insert(args, words[i]) end
		WT.Log.Debug("Command received: " .. command .. " with " .. table.getn(args) .. " args")
		if WT.Gadget.Command[command] then
			WT.Gadget.Command[command](unpack(args))
		end
	end
end

function WT.Gadget.SecureEnter()
	WT.Gadget.isSecure = true
	-- lock gadgets when the environment goes secure (can't move secure frames in secure mode) 
	if not gadgetsLocked then
		WT.Gadget.Command.lock()
	end
end

function WT.Gadget.SecureLeave()
	WT.Gadget.isSecure = false
end


function WT.Gadget.Initializer()
	if (wtxOptions.btnGadgetX and wtxOptions.btnGadgetY) then
		btnGadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", wtxOptions.btnGadgetX, wtxOptions.btnGadgetY)
	else
		btnGadget:SetPoint("CENTER", UIParent, "CENTER")
	end
	for id, config in pairs(wtxGadgets) do
		WT.Log.Info("Loading Gadget: " .. config.id)
		WT.Gadget.Create(config)
	end 

	local gadgetList = ""
	for k,v in pairs(WT.GadgetFactories) do gadgetList = gadgetList .. v.name .. "; " end
	print("Gadgets initialized: " .. gadgetList)

end


-- Register an initializer to handle loading of gadgets
table.insert(WT.Initializers, WT.Gadget.Initializer)


--table.insert(Event.Addon.SavedVariables.Load.End, { WT.Gadget.LoadVariables, AddonId, AddonId .. "_Gadget_LoadVariables" })
table.insert(Command.Slash.Register("gadget"), { WT.Gadget.OnSlashCommand, AddonId, AddonId .. "_OnSlashCommand" })
table.insert(Event.System.Secure.Enter, { WT.Gadget.SecureEnter, AddonId, AddonId .. "_Gadget_SecureEnter" })
table.insert(Event.System.Secure.Leave, { WT.Gadget.SecureLeave, AddonId, AddonId .. "_Gadget_SecureLeave" })

