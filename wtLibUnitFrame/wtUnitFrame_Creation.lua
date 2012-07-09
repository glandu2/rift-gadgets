local toc, data = ...
local AddonId = toc.identifier

-- Gadget Factory Function for single UnitFrame
function WT.UnitFrame.CreateFromConfiguration(configuration)
	local template = configuration.template
	local unitSpec = configuration.unitSpec
	
	if not template then print("Missing required configuration item: template") return end
	if not unitSpec then print("Missing required configuration item: unitSpec") return end
	
	WT.Log.Debug("Creating UnitFrame from configuration: template=" .. template .. " unitSpec=" .. unitSpec)
	return WT.UnitFrame.CreateFromTemplate(template, unitSpec, configuration)
end

-- Gadget Factory Function for grid of 20 UnitFrames
function WT.UnitFrame.CreateRaidFramesFromConfiguration(configuration)

	local sequenceDefault = 
	{
		"group01","group02","group03","group04","group05",
		"group06","group07","group08","group09","group10",
		"group11","group12","group13","group14","group15",
		"group16","group17","group18","group19","group20",
	}

	local sequenceReverse = 
	{
		"group20","group19","group18","group17","group16",
		"group15","group14","group13","group12","group11",
		"group10","group09","group08","group07","group06",
		"group05","group04","group03","group02","group01",
	}

	local sequenceInnerGroupReverse = 
	{
		"group05","group04","group03","group02","group01",
		"group10","group09","group08","group07","group06",
		"group15","group14","group13","group12","group11",
		"group20","group19","group18","group17","group16",
	}

	local sequenceGroupReverse = 
	{
		"group16","group17","group18","group19","group20",
		"group11","group12","group13","group14","group15",
		"group06","group07","group08","group09","group10",
		"group01","group02","group03","group04","group05",
	}

	local sequence = sequenceDefault
	
	if configuration.reverseGroups and configuration.reverseUnits then
		sequence = sequenceReverse
	elseif configuration.reverseGroups then
		sequence = sequenceGroupReverse
	elseif configuration.reverseUnits then
		sequence = sequenceInnerGroupReverse
	end

	local template = configuration.template
	local layout = configuration.layout or "4 x 5"
	WT.Log.Debug("Creating RaidFrames from configuration: template=" .. template)
	
	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("RaidFrames"), WT.Context)
	
	if configuration.showBackground then
		wrapper:SetBackgroundColor(0,0,0,0.2)
	end
	
	
	wrapper:SetSecureMode("restricted")
	-- Pass through our clickToTarget preference to the template to allow it to set itself up appropriately
	--if not configuration.templateOptions then configuration.templateOptions = {} end
	--configuration.templateOptions.clickToTarget = configuration.clickToTarget 
	
	local frames = {}
	
	local _debug = false
	
	
	if not _debug then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, sequence[1], configuration)
	else
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
		--local debugDesc = UI.CreateFrame("Text", "TXT", WT.Context)
		--debugDesc:SetText(sequence[1])
		--debugDesc:SetLayer(500)
		--debugDesc:SetPoint("BOTTOMLEFT", frames[1], "BOTTOMLEFT")
	end
	
	frames[1]:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	frames[1]:SetParent(wrapper)
	frames[1]:SetLayer(1)
	
	for i = 2,20 do
		if not _debug then
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, sequence[i], configuration)
		else
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
			--local debugDesc = UI.CreateFrame("Text", "TXT", WT.Context)
			--debugDesc:SetText(sequence[i])
			--debugDesc:SetLayer(500)
			--debugDesc:SetPoint("BOTTOMLEFT", frames[i], "BOTTOMLEFT")
		end
		frames[i]:SetParent(wrapper)
		frames[i]:SetLayer(i)
	end
	
	local xCols = 4
	local xRows = 5
	
	-- Layout the frames appropriately
	if layout == "5 x 4" then
		xCols = 5
		xRows = 4
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "BOTTOMLEFT") 
			end
		end
	elseif layout == "2 x 10" then
		xCols = 2
		xRows = 10
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "TOPRIGHT") 
			end
		end
	elseif layout == "10 x 2" then
		xCols = 10
		xRows = 2
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "BOTTOMLEFT") 
			end
		end
	elseif layout == "1 x 20" then
		xCols = 1
		xRows = 20
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
		end
	elseif layout == "20 x 1" then
		xCols = 20
		xRows = 1
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
		end
	else -- "4 x 5"
		xCols = 4
		xRows = 5
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "TOPRIGHT") 
			end
		end
	end
	
	local left = frames[1]:GetLeft()
	local top = frames[1]:GetTop()
	local right = frames[20]:GetRight()
	local bottom = frames[20]:GetBottom()
		
	wrapper:SetWidth(right - left + 1)	
	wrapper:SetHeight(bottom - top + 1)	
	
	wrapper.OnResize = 
		function(frame, width,height)
			local frmWidth = math.ceil(width / xCols)
			local frmHeight = math.ceil(height / xRows)
			wrapper:SetWidth(frmWidth * xCols)
			wrapper:SetHeight(frmHeight * xRows)
			for i=1,20 do
				frames[i]:SetWidth(frmWidth)
				frames[i]:SetHeight(frmHeight)
				frames[i]:OnResize(frmWidth, frmHeight)
			end
		end
	
	return wrapper, { resizable = { right - left + 1, bottom - top + 1, (right - left + 1) * 2, (bottom - top + 1) * 2,  } }
end


-- Gadget Factory Function for grid of 20 UnitFrames
function WT.UnitFrame.CreateGroupFramesFromConfiguration(configuration)

	local group = 1
	if configuration.group == "Group 2" then
		group = 2
	elseif configuration.group == "Group 3" then
		group = 3
	elseif configuration.group == "Group 4" then
		group = 4
	end	
	
	local firstId = ((group - 1) * 5) + 1
	local sequence = {}
	
	if configuration.reverseUnits then
		sequence[1] = "group" .. string.format("%02d", firstId+4)
		sequence[2] = "group" .. string.format("%02d", firstId+3)
		sequence[3] = "group" .. string.format("%02d", firstId+2)
		sequence[4] = "group" .. string.format("%02d", firstId+1)
		sequence[5] = "group" .. string.format("%02d", firstId+0)
	else
		sequence[1] = "group" .. string.format("%02d", firstId+0)
		sequence[2] = "group" .. string.format("%02d", firstId+1)
		sequence[3] = "group" .. string.format("%02d", firstId+2)
		sequence[4] = "group" .. string.format("%02d", firstId+3)
		sequence[5] = "group" .. string.format("%02d", firstId+4)
	end
	
	local xCols = 1
	local xRows = 5
	
	local template = configuration.template
	local layout = configuration.layout or "Vertical"
	WT.Log.Debug("Creating GroupFrames from configuration: template=" .. template)
	
	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("GroupFrames"), WT.Context)
	
	if configuration.showBackground then
		wrapper:SetBackgroundColor(0,0,0,0.2)
	end
	
	
	wrapper:SetSecureMode("restricted")
	-- Pass through our clickToTarget preference to the template to allow it to set itself up appropriately
	--if not configuration.templateOptions then configuration.templateOptions = {} end
	--configuration.templateOptions.clickToTarget = configuration.clickToTarget 
	
	local frames = {}
	
	local _debug = true
	
	if not _debug then
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, sequence[1], configuration)
	else
		frames[1] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
	end
	
	frames[1]:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	frames[1]:SetParent(wrapper)
	frames[1]:SetLayer(1)
	
	for i = 2,5 do
		if not _debug then
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, sequence[i], configuration)
		else
			frames[i] = WT.UnitFrame.CreateFromTemplate(template, "player.target", configuration)
		end
		frames[i]:SetParent(wrapper)
		frames[i]:SetLayer(i)
	end
	
	-- Layout the frames appropriately
	if layout == "Horizontal" then
		xCols = 5
		xRows = 1
		for i = 2,5 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT") 
		end
	else
		xCols = 1
		xRows = 5
		for i = 2,5 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT") 
		end
	end
	
	local left = frames[1]:GetLeft()
	local top = frames[1]:GetTop()
	local right = frames[5]:GetRight()
	local bottom = frames[5]:GetBottom()
		
	wrapper:SetWidth(right - left + 1)	
	wrapper:SetHeight(bottom - top + 1)	
	
	wrapper.OnResize = 
		function(frame, width,height)
			local frmWidth = math.ceil(width / xCols)
			local frmHeight = math.ceil(height / xRows)
			wrapper:SetWidth(frmWidth * xCols)
			wrapper:SetHeight(frmHeight * xRows)
			for i=1,5 do
				frames[i]:SetWidth(frmWidth)
				frames[i]:SetHeight(frmHeight)
				frames[i]:OnResize(frmWidth, frmHeight)
			end
		end
	
	return wrapper, { resizable = { right - left + 1, bottom - top + 1, (right - left + 1) * 2, (bottom - top + 1) * 2,  } }
end



function WT.UnitFrame.CreateFromTemplate(templateName, unitSpec, options)
	WT.Log.Info("Creating unit frame from template " .. tostring(templateName) .. " for unit " .. tostring(unitSpec))
	local template = WT.UnitFrame.Templates[templateName]
	if not template then return nil end
	return template:Create(unitSpec, options)
end

