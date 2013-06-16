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


local gadgetIndex = 0
local factionGadgets = {}

local details = nil

local function UpdatePanel(panel, showAll)

	local filters = panel.config.filters

	if not panel.Categories then panel.Categories = {} end
	for factionId, detail in pairs(details) do
	
		if not panel.Categories[detail.categoryName] then
			local catText = UI.CreateFrame("Text", "categoryText", panel)
			catText:SetText(detail.categoryName)
			catText:SetFontSize(12)
			panel.Categories[detail.categoryName] = catText
		end
		local catText = panel.Categories[detail.categoryName]
		if not catText.Factions then catText.Factions = {} end
		if not catText.Factions[detail.name] then
		
			local factionBar = UI.CreateFrame("Frame", "factionBar", catText)
			factionBar:SetHeight(16)
			factionBar:SetBackgroundColor(0,0.6,0,0.8)
		
			local factionText = UI.CreateFrame("Text", "factionText", factionBar)
			factionText:SetText(detail.name)
			factionText:SetFontSize(11)
			factionText:SetPoint("CENTERLEFT", factionBar, "CENTERLEFT", 0, 0)
			
			catText.Factions[detail.name] = factionBar
			
			local notorietyText = UI.CreateFrame("Text", "notorietyText", factionBar)
			notorietyText:SetFontSize(11)
			factionBar.NotorietyText = notorietyText
		end
		
		local notor = detail.notoriety - 23000
		
		local notorNames = { "Neutral", "Friendly", "Decorated", "Honored", "Revered", "Glorified", "Venerated" }
		local notorPoints = { 3000, 10000, 20000, 35000, 60000, 90000, 90000 }
		
		local notorIdx = 0
		for idx, name in ipairs(notorNames) do
			local points = notorPoints[idx]
			if notor < points then
				notorIdx = idx
				break
			else
				notor = notor - points
			end
		end
		
		
		local notString = notorNames[notorIdx] .. " " .. tostring(notor) .. "/" .. notorPoints[notorIdx]
		local percent = notor / notorPoints[notorIdx]
		if notor == 0 then
			notString = notorNames[notorIdx]
			percent = 1.0
		end
		
		catText.Factions[detail.name]:SetWidth((panel:GetWidth() - 20) * percent)
		
		--notString = tostring(detail.notoriety) 
		catText.Factions[detail.name].NotorietyText:SetText(notString)		
			
	end
	
	local anchor = nil
	
	local sortedCats = {}
	for category in pairs(panel.Categories) do
		table.insert(sortedCats, category)
	end
	table.sort(sortedCats)
	
	for _, category, frame in ipairs(sortedCats) do	
		local frame = panel.Categories[category]
		
		local include = false
		for faction in pairs(frame.Factions) do
			if filters[faction] ~= false then 
				include = true
				break
			end
		end
		
		if include or showAll then
		
			frame:SetVisible(true)
		
			if not anchor then
				frame:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, 4)
			else
				frame:SetPoint("TOP", anchor, "BOTTOM", nil, 4)
				frame:SetPoint("LEFT", panel, "LEFT", 4, nil)
			end
			anchor = frame
			
			local sortedFacts = {}
			for faction in pairs(frame.Factions) do
				table.insert(sortedFacts, faction)
			end
			table.sort(sortedFacts)
			
			for _, faction in ipairs(sortedFacts) do			
				factFrame = frame.Factions[faction]
				if (filters[faction] == false) and (not showAll) then
					factFrame:SetVisible(false)
				else
					factFrame:SetVisible(true)
					factFrame:SetPoint("TOP", anchor, "BOTTOM", nil, 4)
					factFrame:SetPoint("LEFT", panel, "LEFT", 10, nil)
					factFrame.NotorietyText:SetPoint("TOP", anchor, "BOTTOM", nil, 4)
					factFrame.NotorietyText:SetPoint("RIGHT", panel, "RIGHT", -10, nil)
					anchor = factFrame
				end
			end

		else
		
			frame:SetVisible(false)		
			
		end
		
	end 
	
	if anchor then
		panel:SetHeight(anchor:GetBottom() - panel:GetTop() + 8)
	else
		panel:SetHeight(100)
	end
	
end


local function UpdatePanels(showAll)
	local list = Inspect.Faction.List()
	if list then
		details = Inspect.Faction.Detail(list)
		for idx, panel in ipairs(factionGadgets) do
			UpdatePanel(panel, showAll)	
		end
	end
end


local function OnNotoriety(hEvent, notoriety)
	UpdatePanels()
end


local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtFaction"), WT.Context)
	wrapper:SetWidth(270)
	wrapper:SetHeight(100)
	wrapper:SetBackgroundColor(0,0,0,0.4)
	
	wrapper.config = configuration
	if not configuration.filters then 
		configuration.filters = {} 
	end

	table.insert(factionGadgets, wrapper)

	UpdatePanels()

	return wrapper
	
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The Faction Panel has no additional configuration options")
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

WT.Gadget.RegisterFactory("FactionPanel",
	{
		name="Faction Panel",
		description="Faction Panel",
		author="Wildtide",
		version="1.0.0",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function OnPlayerAvailable(hEvent)
	UpdatePanels()
end

local function OnUnlocked()
	for idx, panel in ipairs(factionGadgets) do
		-- Create the tick boxes if needed	
		if not panel.filters then
			panel.filters = true
			local filters = panel.config.filters
			for _, category in pairs(panel.Categories) do
				for factionName, bar in pairs(category.Factions) do
					local check = UI.CreateFrame("RiftCheckbox", "check", panel.mvHandle)
					check:SetPoint("CENTERRIGHT", bar, "CENTERLEFT", -2, 0)
					if filters[factionName] == false then
						check:SetChecked(false)
					else
						check:SetChecked(true)
					end
					bar.Filter = check
				end
			end
		end
	end
	UpdatePanels(true)
end

local function OnLocked()
	for idx, panel in ipairs(factionGadgets) do
		if panel.filters then
			for _, category in pairs(panel.Categories) do
				for factionName, bar in pairs(category.Factions) do
					if bar.Filter then
						panel.config.filters[factionName] = bar.Filter:GetChecked()
					end 
				end
			end
		end
	end
	-- Now that the filters have been updated, update the panels
	UpdatePanels()
end

Command.Event.Attach(Event.Faction.Notoriety, OnNotoriety, "OnNotoriety")
Command.Event.Attach(WT.Event.PlayerAvailable, OnPlayerAvailable, "FactionPanel_OnPlayerAvailable")	

table.insert(WT.Event.GadgetsUnlocked, {OnUnlocked, AddonId, "FactionPanel_OnUnlocked"})
table.insert(WT.Event.GadgetsLocked, {OnLocked, AddonId, "FactionPanel_OnLocked"})
