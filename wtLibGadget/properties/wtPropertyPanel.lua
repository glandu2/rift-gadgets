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
local MEDIA = Library.Media

MEDIA.AddFont("PropertyFont", AddonId, "fonts/SquareRoman.ttf")

local ctxPropertyPanel = UI.CreateContext("WTPropertyPanel")
ctxPropertyPanel:SetStrata("topmost")


local function ToolWindow_GetContentHeight(window) 
	local cheight = 0
	for idx, band in ipairs(window.Bands) do
		cheight = cheight + band:GetHeight()
	end
	return cheight
end

local function ToolWindow_AddBand(window, band)
	band:SetWidth(window.Content:GetWidth())
	band:SetParent(window.Content)
	table.insert(window.Bands, band)

	local newHeight = window:GetContentHeight()
	local scrollDistance = math.max(0, newHeight - window.Content:GetHeight())
	window.Scrollbar:SetRange(0, scrollDistance)
	
	if #window.Bands == 1 then
		band:SetPoint("TOPLEFT", window.Anchor, "TOPLEFT", 0, 0)
	else
		band:SetPoint("TOPLEFT", window.Bands[#window.Bands - 1], "BOTTOMLEFT", 0, 0)
	end

end

local function ToolWindow_ClearBands(window)
	for idx = 1, #window.Bands do
		window.Bands[idx]:SetVisible(false)
		window.Bands[idx] = nil			
	end
	window.Scrollbar:SetRange(0, 0)
end

local function ToolWindow_Show(window)
	window:SetVisible(true)
end

local function ToolWindow_Hide(window)
	window:SetVisible(false)
end


-- Creates a tool window with no current content
function WT.Gadget.ToolWindow(caption, xpos, ypos, contentWidth, contentHeight)

	local window = UI.CreateFrame("Frame", "frmWindow", ctxPropertyPanel)
	window:SetBackgroundColor(0.2,0.2,0.2,1.0)
	window:SetWidth(contentWidth + 16 + 4)
	window:SetHeight(contentHeight + 20 + 4)
	window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", xpos, ypos)
	window:SetVisible(false)

	local title = UI.CreateFrame("Text", "frmPanelTitle", window)
	MEDIA.SetFont(title, "PropertyFont", 12)
	title:SetText(caption)
	title:SetPoint("TOPLEFT", window, "TOPLEFT", 4, 2)
	title:SetPoint("RIGHT", window, "RIGHT", -4, nil)

	local content = UI.CreateFrame("Mask", "frmContent", window)
	content:SetBackgroundColor(0.4,0.4,0.4,1.0)
	content:SetWidth(contentWidth)
	content:SetHeight(contentHeight)
	content:SetPoint("TOPLEFT", window, "TOPLEFT", 2, 22)

	local anchor = UI.CreateFrame("Frame", "anchor", window)
	anchor:SetWidth(contentWidth)
	anchor:SetHeight(0)
	anchor:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)

	local scroll = UI.CreateFrame("RiftScrollbar", "frmPanelScroll", window)
	scroll:SetPoint("TOPLEFT", content, "TOPRIGHT", 2, 0)
	scroll:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 16, 0)
	scroll:SetRange(0,0)
	scroll.Event.ScrollbarChange = 
		function()
			anchor:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -scroll:GetPosition())
		end

	window.Content = content
	window.Title = title
	window.Scrollbar = scroll
	window.Anchor = anchor
	window.Bands = {}
	
	window.GetContentHeight = ToolWindow_GetContentHeight 
	window.AddBand = ToolWindow_AddBand 
	window.ClearBands = ToolWindow_ClearBands
	window.Show = ToolWindow_Show
	window.Hide = ToolWindow_Hide

	return window

end


local panel = UI.CreateFrame("Frame", "frmPanel", ctxPropertyPanel)
panel:SetBackgroundColor(0.2,0.2,0.2,1.0)
panel:SetWidth(250)
panel:SetHeight(400)

local panelInner = UI.CreateFrame("Mask", "frmPanelInner", panel)
panelInner:SetBackgroundColor(1,1,1,1)
panelInner:SetPoint("TOPLEFT", panel, "TOPLEFT", 2, 2)
panelInner:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -19, -2)

local panelScroll = UI.CreateFrame("RiftScrollbar", "frmPanelScroll", panel)
panelScroll:SetPoint("TOPLEFT", panelInner, "TOPRIGHT", 1, 0)
panelScroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -2, -2)
panelScroll:SetRange(0,0)

local panelTitleBar = UI.CreateFrame("Frame", "frmPanelTitle", panel)
panelTitleBar:SetPoint("BOTTOMLEFT", panel, "TOPLEFT")
panelTitleBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -20)
panelTitleBar:SetBackgroundColor(0.2,0.2,0.2,1.0)

local panelTitle = UI.CreateFrame("Text", "frmPanelTitle", panelTitleBar)
MEDIA.SetFont(panelTitle, "PropertyFont", 12)
panelTitle:SetText("UnitFrame1")
panelTitle:SetPoint("CENTERLEFT", panelTitleBar, "CENTERLEFT", 4, 1)
panelTitle:SetPoint("RIGHT", panelTitleBar, "RIGHT", -4, nil)

panel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, 50)

local panelAnchor = UI.CreateFrame("Frame", "frmPanelAnchor", panelInner)
panelAnchor:SetPoint("TOPLEFT", panelInner, "TOPLEFT", 0, 0)
panelAnchor:SetHeight(0)
panelAnchor:SetVisible(false)

local lastRow = panelAnchor
local rowHeight = 18
local currRow = 0
local maxRows = math.floor(panelInner:GetHeight() / rowHeight)

local rows = {}

panelScroll.Event.ScrollbarChange = function()
	panelAnchor:SetPoint("TOPLEFT", panelInner, "TOPLEFT", 0, -panelScroll:GetPosition())
end

local function EditRowValue(row)
	if row.key ~= "" then
		print("Edit Property: " .. row.key)
	end
end

local function AppendNewRow()

	local row = UI.CreateFrame("Frame", "frmPanelInner", panelInner)
	
	-- Setup the plain grey background for the new row (is this needed?)
	row:SetBackgroundColor(0.7,0.7,0.7,1.0)
	row:SetHeight(rowHeight)
	row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT")
	row:SetPoint("RIGHT", panelInner, "RIGHT")
	row:SetVisible(false)
	row.key = ""

	-- Create the key cell and assume it's being used for standard property display
	local txtKey = UI.CreateFrame("Text", "frmTxtKey", row)
	txtKey:SetText("")
	txtKey:SetFontColor(0,0,0,1)
	txtKey:SetBackgroundColor(1,1,1,1)
	txtKey:SetPoint("TOPLEFT", row, "TOPLEFT", 20, 0)
	txtKey:SetPoint("BOTTOMRIGHT", row, "BOTTOMCENTER", 0,-1)
	txtKey.Event.MouseIn = function() if row.key ~= "" then row.cellKey:SetBackgroundColor(0.8,0.9,1.0,1.0) row.cellValue:SetBackgroundColor(0.8,0.9,1.0,1.0) end end
	txtKey.Event.MouseOut = function() if row.key ~= "" then row.cellKey:SetBackgroundColor(1,1,1,1) row.cellValue:SetBackgroundColor(1,1,1,1) end end
	txtKey.Event.LeftClick = function() EditRowValue(row) end
	MEDIA.SetFont(txtKey, "PropertyFont", 11)

	-- Create the value cell
	local txtValue = UI.CreateFrame("Text", "frmTxtValue", row)
	txtValue:SetText("")
	txtValue:SetFontColor(0,0,0,1)
	txtValue:SetBackgroundColor(1,1,1,1)
	txtValue:SetPoint("TOPLEFT", row, "TOPCENTER", 1, 0)
	txtValue:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT",0,-1)
	txtValue.Event.LeftClick = function() EditRowValue(row) end
	txtValue.Event.MouseIn = function() if row.key ~= "" then row.cellKey:SetBackgroundColor(0.8,0.9,1.0,1.0) row.cellValue:SetBackgroundColor(0.8,0.9,1.0,1.0) end end
	txtValue.Event.MouseOut = function() if row.key ~= "" then row.cellKey:SetBackgroundColor(1,1,1,1) row.cellValue:SetBackgroundColor(1,1,1,1) end end
	txtValue.Event.LeftClick = function() EditRowValue(row) end
	MEDIA.SetFont(txtValue, "PropertyFont", 11)

	row.cellKey = txtKey
	row.cellValue = txtValue

	-- Add to the rows table
	rows[#rows + 1] = row

	-- Update the row count and the scroll bar values
	panelScroll:SetRange(0, math.max((#rows - 20), 0) * rowHeight)
	lastRow = row

end

local function HideAllRows()
	for idx, row in ipairs(rows) do
		row:SetVisible(false)
	end
	currRow = 0
end


local function addGroup(name)

	currRow = currRow + 1

	if currRow > #rows then
		AppendNewRow()
	end

	local row = rows[currRow]
	row:SetVisible(true)

	row.cellKey:SetText(name)
	row.cellKey:SetFontColor(0.2,0.2,0.2,1)
	row.cellKey:SetBackgroundColor(0,0,0,0)
	row.cellKey:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0,-1)
	row.key = ""
	
	row.cellValue:SetVisible(false)

	panelScroll:SetRange(0, math.max((currRow - maxRows), 0) * rowHeight)

end

local function addRow(key, keyName, value)

	currRow = currRow + 1

	if currRow > #rows then
		AppendNewRow()
	end

	local row = rows[currRow]
	row:SetVisible(true)

	row.cellKey:SetText(keyName)
	row.cellKey:SetFontColor(0,0,0,1)
	row.cellKey:SetBackgroundColor(1,1,1,1)
	row.cellKey:SetPoint("BOTTOMRIGHT", row, "BOTTOMCENTER", 0,-1)
	row.key = key

	row.cellValue:SetVisible(true)
	row.cellValue:SetText(value)

	panelScroll:SetRange(0, math.max((currRow - maxRows), 0) * rowHeight)

end

HideAllRows()

addGroup("General")
addRow("xpos", "X Coord", "150")
addRow("ypos", "Y Coord", "200")
addRow("oocAlpha", "Alpha","50%")
addRow("icAlpha", "Alpha (Combat)","100%")

addGroup("Unit Frame")
addRow("unitSpec", "Unit to Track", "player.target")

addGroup("Health Bar")
addRow("hpTexture", "Texture", "Example 01")
addRow("hpTextLeft", "Left Text", "{health}/{maxHealth}")
addRow("hpTextCenter", "Center Text", "")
addRow("hpTextRight", "Right Text", "{healthPercent}")

addGroup("Resource Bar")
addRow("resTexture", "Texture", "Example 02")
addRow("resTextLeft", "Left Text", "{resource}/{maxResource}")
addRow("resTextCenter", "Center Text", "")
addRow("resTextRight", "Right Text", "{resourcePercent}")

addGroup("Buffs")
addRow("buffLocation", "Location", "Below Left")
addRow("buffDirection", "Direction", "Right, Down")
addRow("buffRows", "Rows", "3")
addRow("buffCols", "Columns", "4")
addRow("buffShowTimer", "Show Timer", "Yes")
addRow("buffTimerPos", "Timer Position", "Below")
addRow("buffTimerSize", "Timer Size", "12")
addRow("buffShowStacks", "Show Stacks", "Yes")
addRow("buffStacksPos", "Stacks Position", "Center")
addRow("buffStacksSize", "Stacks Size", "15")

addGroup("Debuffs")
addRow("debuffLocation", "Location", "Below Right")
addRow("debuffDirection", "Direction", "Left, Down")
addRow("debuffRows", "Rows", "3")
addRow("debuffCols", "Columns", "2")
addRow("debuffShowTimer", "Show Timer", "Yes")
addRow("debuffTimerPos", "Timer Position", "Below")
addRow("debuffTimerSize", "Timer Size", "12")
addRow("debuffShowStacks", "Show Stacks", "Yes")
addRow("debuffStacksPos", "Stacks Position", "Center")
addRow("debuffStacksSize", "Stacks Size", "15")

local window = WT.Gadget.ToolWindow("Tool Window", 500, 200, 230, 300)
window:SetPoint("TOPLEFT", panel, "BOTTOMLEFT") 

for j = 1,10 do

	local frame = UI.CreateFrame("Frame", "test", ctxPropertyPanel)
	frame:SetWidth(230)
	frame:SetHeight(65)
	frame:SetBackgroundColor(1,0,0,1)
	window:AddBand(frame)
	
	local frame2 = UI.CreateFrame("Frame", "test", ctxPropertyPanel)
	frame2:SetWidth(230)
	frame2:SetHeight(20)
	frame2:SetBackgroundColor(0,0,1,1)
	window:AddBand(frame2)

end

window:Show()
