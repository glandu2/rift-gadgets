local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local simpleFrameWidth = 140
local simpleFrameTopBarHeight = 30
local simpleFrameBottomBarHeight = 16
local simpleFrameMargin = 2
local simpleFrameHeight = simpleFrameTopBarHeight + simpleFrameBottomBarHeight 
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local SimpleFrame = WT.UnitFrame:Template("SimpleFrame")
SimpleFrame.Configuration.Name = "Simple Unit Frame"
SimpleFrame.Configuration.RaidSuitable = true
SimpleFrame.Configuration.FrameType = "Frame"
SimpleFrame.Configuration.Width = simpleFrameWidth + 2
SimpleFrame.Configuration.Height = simpleFrameHeight + 2
---------------------------------------------------------------------------------

-- Override the buff filter to hide some buffs ----------------------------------
local buffPriorities = 
{
	["Track Wood"] = 0,
	["Track Ore"] = 0,
	["Track Plants"] = 0,
	["Rested"] = 0,
	["Prismatic Glory"] = 0,
	["Looking for Group Cooldown"] = 0,
}
function SimpleFrame:GetBuffPriority(buff)
	if not buff then return 2 end
	return buffPriorities[buff.name] or 2
end
---------------------------------------------------------------------------------

function SimpleFrame:Construct(options)

	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
				id="frameBackdrop", type="Frame", parent="frame", layer=0,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id",
				-- Type Specific Element Configuration
				texAddon = AddonId, texFile = "img/wtMiniFrame_bg.png", alpha=0.8,
				color={r=0,g=0,b=0,a=0.6}, colorBinding="aggroColor",
			}, 
			{
				-- Generic Element Configuration
				id="frameBlocked", type="Frame", parent="frameBackdrop", layer=15, visibilityBinding="blocked",
				color={r=0,g=0,b=0},alpha=0.6,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=3, offsetY=3 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-3, offsetY=-3 } 
				},
			}, 
			{
				-- Generic Element Configuration
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 }},
				-- visibilityBinding="id",
				growthDirection="right",
				-- Type Specific Element Configuration
				binding="healthPercent", width=simpleFrameWidth, height=simpleFrameTopBarHeight,color={r=0,g=0.7,b=0,a=1}, 
				texAddon=AddonId, texFile="img/Diagonal.png", 
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="labelHealthR", type="Label", parent="barHealth", layer=20,
				attach = {{ point="CENTERRIGHT", element="barHealth", targetPoint="CENTERRIGHT" }},
				visibilityBinding="health",
				-- Type Specific Element Configuration
				text="{health}", default="", fontSize=12
			},
			{
				-- Generic Element Configuration
				id="imgRank", type="ImageSet", parent="frame", layer=50, 
				--attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=2, offsetY=2 }}, visibilityBinding="rank",
				--attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPCENTER", offsetX=0, offsetY=2 }}, visibilityBinding="rank",
				attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-2, offsetY=2 }}, visibilityBinding="rank",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/RankPips.png", nameBinding="rank", cols=3, rows=3, 
				names ={ 
					["neutralnormal"] = 0, ["neutralgroup"] = 1, ["neutralraid"] = 2,
					["hostilenormal"] = 3, ["hostilegroup"] = 4, ["hostileraid"] = 5,
					["friendlynormal"] = 6, ["friendlygroup"] = 7, ["friendlyraid"] = 8,
					 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="barHealth", targetPoint="CENTERLEFT", offsetX=2, offsetY=0 }},
				visibilityBinding="name",
				-- Type Specific Element Configuration
				text="{nameShort}", default="", fontSize=12
			},
			{
				-- Generic Element Configuration
				id="barResource", type="Bar", parent="frameBackdrop", layer=10,
				attach = {{ point="TOPLEFT", element="barHealth", targetPoint="BOTTOMLEFT" }},
				-- visibilityBinding="id",
				-- Type Specific Element Configuration
				binding="resourcePercent", width=simpleFrameWidth, height=simpleFrameBottomBarHeight, colorBinding="resourceColor",
				texAddon=AddonId, texFile="img/Diagonal.png",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="labelresource", type="Label", parent="barResource", layer=20,
				attach = {{ point="CENTERLEFT", element="barResource", targetPoint="CENTERLEFT" }},
				visibilityBinding="resource",
				-- Type Specific Element Configuration
				text=" {resource}/{resourceMax}", default="", fontSize=10
			},
			{
				-- Generic Element Configuration
				id="labelresourceR", type="Label", parent="barResource", layer=20,
				attach = {{ point="CENTERRIGHT", element="barResource", targetPoint="CENTERRIGHT" }},
				visibilityBinding="resource",
				-- Type Specific Element Configuration
				text="{resourcePercent}%", default="", fontSize=10
			},			
		}
	}
	
	for idx,element in ipairs(template.elements) do
		if options.excludeBuffs and element.type=="BuffPanel" then
			-- Don't add buff panels if excluding them
		else
			self:CreateElement(element)
		end 
	end
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self.Event.LeftClick = "target @" .. self.UnitSpec
	self.Event.RightClick = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	
end
