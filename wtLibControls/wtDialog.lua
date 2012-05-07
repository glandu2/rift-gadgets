--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- This allows for fluent building of a dialog, consisting of a vertical stack of controls

local CDialog = {}
local CDialog_mt = { __index = CDialog }

function CDialog:add(id, label, control, labelFontSize, stretch, iconFile)

	local lbl = false
	local frm = UI.CreateFrame("Frame", "DialogFormRow", self.container)
	if label then

		lbl = UI.CreateFrame("Text", "DialogFieldLbl", frm)
	
		if iconFile then
			local icon = UI.CreateFrame("Texture", "DialogIcon", frm)
			icon:SetTexture(AddonId, iconFile)
			icon:SetPoint("TOPLEFT", frm, "TOPLEFT")
			lbl:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, -3)
		else
			lbl:SetPoint("TOPLEFT", frm, "TOPLEFT")
		end
	
		if (not control) then
			lbl:SetPoint("RIGHT", frm, "RIGHT")
		else
			lbl:SetPoint("RIGHT", frm, "LEFT", self.labelWidth - 16, nil)
		end
		lbl:SetWordwrap(true)
		if labelFontSize then
			lbl:SetFontSize(labelFontSize)
		else
			lbl:SetFontSize(12)
		end
		lbl:SetText(label)
	end
	
	frm.control = control
	frm.id = id

	if #self.fields == 0 then
		frm:SetPoint("TOPLEFT", self.container, "TOPLEFT")
	else
		frm:SetPoint("TOPLEFT", self.fields[#self.fields], "BOTTOMLEFT", 0, 8)
	end
	frm:SetPoint("RIGHT", self.container, "RIGHT")

	if control then
		control:SetPoint("TOPLEFT", frm, "TOPLEFT", self.labelWidth, 0)
		if stretch then
			control:SetPoint("RIGHT", frm, "RIGHT")
		end
		frm:SetPoint("BOTTOM", control, "BOTTOM")
	else
		if lbl then
			frm:SetPoint("BOTTOM", lbl, "BOTTOM")
		else
			frm:SetHeight(8)
		end
	end

	table.insert(self.fields, frm)

	return frm
end

function CDialog:Label(label)
	self:add(nil, label, nil, 12)
	return self
end

function CDialog:Heading(label)
	self:add(nil, label, nil, 18)
	return self
end

function CDialog:FieldNote(note)
	-- Double span notes... (note - setting stretch to true with no control will make the label span the full width)
	self:add(nil, note, nil, 11, true, "img/wtInfo12.png")	
	return self
end

function CDialog:Textfield(id, label, text)
	local control = UI.CreateFrame("RiftTextfield", "DialogField", self.container)
	control:SetBackgroundColor(0.2,0.2,0.2,0.9)
	control:SetText(text)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:Checkbox(id, label, checked)
	local control = UI.CreateFrame("RiftCheckbox", "DialogField", self.container)
	control:SetChecked(checked)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetChecked
	frm.setValue = control.SetChecked
	return self
end

function CDialog:Combobox(id, label, default, listItems)
	local control = WT.Control.ComboBox.Create(self.container, nil, default, listItems)
	control:SetText(default)
	local frm = self:add(id, label, control)
	frm.getValue = control.GetText
	frm.setValue = control.SetText
	return self
end

function CDialog:FontSize(value)
	local item = self.fields[#self.fields].control
	item:SetFontSize(value)
	return self
end

function CDialog:Width(value)
	local item = self.fields[#self.fields].control
	item:SetWidth(value)
	return self
end

function CDialog:Height(value)
	local item = self.fields[#self.fields].control
	item:SetHeight(value)
	return self
end

function CDialog:GetValue(id)
	for idx,field in ipairs(self.fields) do
		if field.id == id then
			local ctrl = field.control
			if field.getValue then
				return field.getValue(ctrl)
			else
				return nil
			end
		end
	end
end

function CDialog:GetValues()
	local vals = {}
	for idx,field in ipairs(self.fields) do
		if field.id then
			if field.getValue then
				vals[field.id] = field.getValue(field.control)
			end
		end
	end
	return vals
end


function CDialog:SetValues(tbl)
	for idx,field in ipairs(self.fields) do
		if field.id then
			local ctrl = field.control
			if field.setValue and tbl[field.id] ~= nil then
				field.setValue(ctrl, tbl[field.id])
			end
		end
	end
end


function WT.Dialog(container, labelWidth)
	local obj = {}
	obj.labelWidth = labelWidth or 200
	obj.container = container
	obj.fields = {}
	setmetatable(obj, CDialog_mt)
	return obj
end
