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

local dockerIntegration = false

local btnGadget = UI.CreateFrame("Texture", AddonId .. "_btnGadget", WT.Context)
btnGadget:SetTexture(AddonId, "img/btnGadgetMenu.png")

local btnDragging = false
local btnStartX = 0
local btnStartY = 0
local btnMouseStartX = 0
local btnMouseStartY = 0
local btnDragged = false

local function btnDragStart()
	if dockerIntegration then return end
	WT.Utility.DeAnchor(btnGadget)
	local mouse = Inspect.Mouse()
	btnDragging = true
	btnStartX = btnGadget:GetLeft()
	btnStartY = btnGadget:GetTop()
	btnMouseStartX = mouse.x
	btnMouseStartY = mouse.y
	btnDragged = false	
end

local draggedEnough = false
local function btnDragMove()
	if btnDragging then
		local mouse = Inspect.Mouse()

		if not draggedEnough then
			local deltaX = math.abs(mouse.x - btnMouseStartX)
			local deltaY = math.abs(mouse.y - btnMouseStartY)
			if deltaX > 8 or deltaY > 8 then
				draggedEnough = true
			end
		end

		if not draggedEnough then return end

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
	draggedEnough = false
	-- try to detect a left click instead of a drag
	if not btnDragged then
		if WT.Gadget.Locked() then
			WT.Gadget.UnlockAll()
		else
			WT.Gadget.LockAll()
		end
	end
end

local menuItems = {}
local menuItemsAdd = 1
local menuItemsToggleLock = 2
local menuItemsSettings = 3
local menuItemsImport = 4
menuItems[menuItemsAdd] = {text=TXT.AddGadget, value=function() WT.Gadget.ShowCreationUI() end } 
menuItems[menuItemsToggleLock] = {text=TXT.UnlockGadgets, value=function() WT.Gadget.ToggleAll() end }
menuItems[menuItemsSettings] = {text=TXT.Settings, value=function() WT.Gadget.ShowSettings() end }
menuItems[menuItemsImport] = {text="Import Layout", value=function() WT.Gadget.ShowImportDialog() end }

local btnMenu = WT.Control.Menu.Create(btnGadget, menuItems)
btnMenu:SetPoint("TOPRIGHT", btnGadget, "CENTER")

local function btnShowMenu()
	btnMenu:Toggle()
end

function btnMenu:OnOpen()
	if dockerIntegration then
		MINIMAPDOCKER.AUTOHIDE_DOCKED = false
	end
end

function btnMenu:OnClose()
	if dockerIntegration then
		MINIMAPDOCKER.AUTOHIDE_DOCKED = true
	end
end


btnGadget.Event.LeftDown = btnDragStart
btnGadget.Event.MouseMove = btnDragMove
btnGadget.Event.LeftUp = btnDragStop
btnGadget.Event.LeftUpoutside = btnDragStop
btnGadget.Event.RightClick = btnShowMenu



-- API METHODS

function WT.Gadget.ResetButton()
	WT.Utility.DeAnchor(btnGadget)
	btnGadget:ClearPoint("LEFT")
	btnGadget:ClearPoint("TOP")
	btnGadget:SetPoint("CENTER", UIParent, "CENTER")
	wtxOptions.btnGadgetX = btnGadget:GetLeft()
	wtxOptions.btnGadgetY = btnGadget:GetTop()
end



local function Initialize()

	-- Docker integration
	if MINIMAPDOCKER then
		dockerIntegration = true
		MINIMAPDOCKER.Register("Gadgets", btnGadget)
	else
		dockerIntegration = false
		if (wtxOptions.btnGadgetX and wtxOptions.btnGadgetY) then
			btnGadget:SetPoint("TOPLEFT", UIParent, "TOPLEFT", wtxOptions.btnGadgetX, wtxOptions.btnGadgetY)
		else
			btnGadget:SetPoint("CENTER", UIParent, "CENTER")
		end
	end
end


-- Register an initializer to handle loading of gadgets
table.insert(WT.Initializers, Initialize)

table.insert(WT.Event.GadgetsLocked, 
{
	function()
		menuItems[menuItemsToggleLock].text = TXT.UnlockGadgets
		btnMenu:SetItems(menuItems)
	end, 
	AddonId, AddonId .. "_GadgetsLocked"
})

table.insert(WT.Event.GadgetsUnlocked, 
{
	function()
		menuItems[menuItemsToggleLock].text = TXT.LockGadgets
		btnMenu:SetItems(menuItems)
	end, 
	AddonId, AddonId .. "_GadgetsUnlocked"
})
