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


-- This is going to be a biggie!
-- Need to ask the user to select a gadget type (ie. a factory), and then present configuration options
-- that are relevant to that particular gadget type.
-- Then, for things like UnitFrame gadgets, there is a further selection of template and then the template
-- options also need to be displayed. Gets complicated!
function WT.Gadget.ShowCreationUI()
	if not WT.Gadget.CreateGadgetWindow then
		local window  = UI.CreateFrame("SimpleWindow", "WTGadgetCreate", WT.Context)
		window:SetCloseButtonVisible(true)
		window:SetPoint("CENTER", UIParent, "CENTER")
		-- window:SetController("content")
		window:SetWidth(800)
		window:SetHeight(600)
		window:SetLayer(11000)
		window:SetTitle(TXT.CreateGadget)
		WT.Gadget.CreateGadgetWindow = window
		
		local content = window:GetContent()

		local frameTypeList = UI.CreateFrame("Mask", "WTGadgetCreateTypeList", content)
		frameTypeList:SetPoint("TOPLEFT", content, "TOPLEFT")
		frameTypeList:SetPoint("BOTTOMRIGHT", content, "BOTTOMLEFT", 250, 0) -- 40% of the width given over to the type list
		frameTypeList:SetBackgroundColor(0,0,0,0.3) -- Set the type list to an almost completely transparent white color, to seperate it from the options panel

		local frameScrollAnchor = UI.CreateFrame("Frame", "WTGadgetScrollAnchor", content)
		frameScrollAnchor:SetPoint("TOPLEFT", frameTypeList, "TOPLEFT", 0, 0)

		local typeListScrollbar = UI.CreateFrame("RiftScrollbar", "WTGadgetTypeScroll", content)
		typeListScrollbar:SetPoint("TOPRIGHT", frameTypeList, "TOPRIGHT", -1, 1)
		typeListScrollbar:SetPoint("BOTTOM", frameTypeList, "BOTTOM", nil, -1)	

		local frameOptions = UI.CreateFrame("Frame", "WTGadgetOptions", content)
		frameOptions:SetPoint("TOPLEFT", frameTypeList, "TOPRIGHT", 0, 0)
		frameOptions:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT" ,0, 0)		

		local btnCancel = UI.CreateFrame("RiftButton", "WTGadgetBtnCancel", frameOptions)
		btnCancel:SetText(TXT.Cancel)
		btnCancel:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
		btnCancel.Event.LeftPress = function() window:SetVisible(false); WT.Utility.ClearKeyFocus(window); end
		
		local btnOK = UI.CreateFrame("RiftButton", "WTGadgetBtnOK", frameOptions)
		btnOK:SetText(TXT.Create)
		btnOK:SetPoint("CENTERRIGHT", btnCancel, "CENTERLEFT", 8, 0)
		btnOK:SetEnabled(false)
		btnOK.Event.LeftPress = 
			function()
			
				-- Give the creation enough time to run
				Command.System.Watchdog.Quiet()			
			
				local gadget = window.selected.gadgetConfig
				local config = {}
				if gadget.GetConfiguration then
				 	config = gadget.GetConfiguration()
				end
				config.type = gadget.gadgetType
				-- Generate a unique ID for the gadget
				local idx = 1
				while WT.Gadgets[gadget.gadgetType .. idx] do idx = idx + 1 end
				config.id = gadget.gadgetType .. idx
				
				-- WT.Gadget.InitializePropertyConfig(config)
				
				WT.Gadget.Create(config)
				WT.Utility.ClearKeyFocus(window)
				window:SetVisible(false)
				
				WT.Gadget.UnlockAll() -- Always unlock gadgets when adding a new one through the dialog, so it can be moved
				 
				return
			end
		
		-- frameOptions will host the dialog provided by the gadget factory assuming one is available

		local frameOptionsHeading = UI.CreateFrame("Text", "WTGadgetOptionsHeading", frameOptions)
		frameOptionsHeading:SetFontSize(18)
		frameOptionsHeading:SetText(TXT.SelectGadgetType)
		frameOptionsHeading:SetPoint("TOPLEFT", frameOptions, "TOPLEFT", 8, 8)

		local gadgetDetails = UI.CreateFrame("Text", "WTGadgetDetails", frameOptions)
		gadgetDetails:SetFontSize(10)
		gadgetDetails:SetText("Gadgets, " .. TXT.Version .. "0.3.4")
		gadgetDetails:SetPoint("TOPLEFT", frameOptionsHeading, "BOTTOMLEFT", 0, -4)
		gadgetDetails:SetFontColor(0.8, 0.8, 0.8, 1.0)

		-- Now populate the frameTypeList with all available gadget types.
		-- Let's give gadget factories an icon that can be used in this list to make it prettier 

		local listItems = {}
		local listItemCount = 0

		local wrapperWidth = frameTypeList:GetWidth() - 16

		-- sort the gadgets into name order ready for display
		local sorted = {}
		for gadgetType, config in pairs(WT.GadgetFactories) do table.insert(sorted, config) end
		table.sort(sorted, function(a,b) return a.name < b.name end)

		local numListItems = 0
		for idx, config in ipairs(sorted) do
			local gadgetType = config.gadgetType
			local name = config.name
			local description = config.description
			local author = config.author
			local version = config.version
			local iconTexAddon = config.iconTexAddon
			local iconTexFile = config.iconTexFile
						
			numListItems = numListItems + 1						
						
			local wrapper = UI.CreateFrame("Frame", "WTGadgetCreate_wrapper_" .. gadgetType, frameTypeList)

			listItemCount = listItemCount + 1
			listItems[listItemCount] = wrapper
			
			if listItemCount == 1 then
				wrapper:SetPoint("TOPLEFT", frameScrollAnchor, "TOPLEFT", 8, 8)
			else
				wrapper:SetPoint("TOPLEFT", listItems[listItemCount-1], "BOTTOMLEFT", 0, 8)
			end
			wrapper:SetWidth(250-30)
			wrapper:SetHeight(40)
			
			local icon = UI.CreateFrame("Texture", "WTGadgetCreate_icon_" .. gadgetType, wrapper)
			icon:SetTexture(iconTexAddon, iconTexFile)
			icon:SetWidth(32)
			icon:SetHeight(32)
			icon:SetPoint("TOPLEFT", wrapper, "TOPLEFT", 4 ,4)
			wrapper.icon = icon
			
			local label = UI.CreateFrame("Text", "WTGadgetCreate_label_" .. gadgetType, wrapper)
			label:SetText(name)
			label:SetFontSize(15)
			label:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -2)
			wrapper.label = label

			local label2 = UI.CreateFrame("Text", "WTGadgetCreate_label2_" .. gadgetType, wrapper)
			label2:SetText(description)
			label2:SetFontSize(10)
			label2:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
			wrapper.label2 = label2
			
			wrapper.gadgetConfig = config
			
			wrapper.Event.MouseIn = 
				function() 
					if (not window.selected) or (window.selected ~= wrapper) then
						wrapper:SetBackgroundColor(0.1, 0.2, 0.3, 0.6)
					end 
				end

			wrapper.Event.MouseOut = 
				function() 
					if (not window.selected) or (window.selected ~= wrapper) then
						wrapper:SetBackgroundColor(0, 0, 0, 0) 
					end 
				end
			
			wrapper.Event.LeftClick = 
				function()
					local gadget = wrapper.gadgetConfig
					if (window.selected) then
						window.selected:SetBackgroundColor(0, 0, 0, 0)
					end 
					wrapper:SetBackgroundColor(0.2, 0.4, 0.6, 0.8)
					window.selected = wrapper
					frameOptionsHeading:SetText(gadget.name)
					gadgetDetails:SetText(TXT.Version .. " " .. gadget.version .. ", " .. TXT.writtenBy .. " " .. gadget.author)
					
					if window.dialog then
						window.dialog:SetVisible(false)
						window.dialog = nil
					end
					
					if gadget.ConfigDialog then
						if not gadget._configDialog then
							local container = UI.CreateFrame("Frame", WT.UniqueName("gadgetOptionsContainer"), frameOptions)
							container:SetPoint("TOPLEFT", gadgetDetails, "BOTTOMLEFT", 0, 8)
							container:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
							container:SetVisible(false)
							gadget.ConfigDialog(container)
							gadget._configDialog = container
						end
						window.dialog = gadget._configDialog 
						
						window.dialog:SetParent(frameOptions)
						window.dialog:SetPoint("TOPLEFT", gadgetDetails, "BOTTOMLEFT", 0, 8)
						window.dialog:SetPoint("BOTTOMRIGHT", frameOptions, "BOTTOMRIGHT", -8, -8)
						window.dialog:SetVisible(true)
					end
					
					btnOK:SetEnabled(true)					
				end			
		end

		-- there are 48 pixels per entry in the list (total height of wrapper + margin)
		local wrappersHeight = numListItems * 48
		local listHeight = frameTypeList:GetHeight()
		local maxMoveDistance = math.max(0, wrappersHeight - listHeight)
		typeListScrollbar:SetRange(0, maxMoveDistance + 16)
		typeListScrollbar.Event.ScrollbarChange = 
			function()
				frameScrollAnchor:SetPoint("TOPLEFT", frameTypeList, "TOPLEFT", 0, -typeListScrollbar:GetPosition())
			end

	else
		WT.Gadget.CreateGadgetWindow:SetVisible(true)
	end
end
