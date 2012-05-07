local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local raidFrameWidth = 100
local raidFrameTopBarHeight = 32
local raidFrameBottomBarHeight = 5
local raidFrameMargin = 2
local raidFrameHeight = raidFrameTopBarHeight + raidFrameBottomBarHeight 
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local RaidFrame = WT.UnitFrame:Template("RaidFrame")
RaidFrame.Configuration.Name = "Default Raid Frame"
RaidFrame.Configuration.RaidSuitable = true
RaidFrame.Configuration.FrameType = "Frame"
RaidFrame.Configuration.Width = raidFrameWidth + 2
RaidFrame.Configuration.Height = raidFrameHeight + 2
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
function RaidFrame:GetBuffPriority(buff)
	if not buff then return 2 end
	return buffPriorities[buff.name] or 2
end
---------------------------------------------------------------------------------

function RaidFrame:Construct(options)

	local template =
	{
		elements = 
		{
			{
				-- Generic Element Configuration
				id="frameBackdrop", type="Frame", parent="frame", layer=0, alpha=0.8,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id",
				color={r=0,g=0,b=0,a=1}, colorBinding="aggroColor",
			}, 
			{
				-- Generic Element Configuration
				id="frameBlocked", type="Frame", parent="frameBackdrop", layer=15, visibilityBinding="blocked",
				color={r=0,g=0,b=0},alpha=0.6,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 } 
				},
			}, 
			{
				-- Generic Element Configuration
				id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
				attach = {{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 }},
				-- visibilityBinding="id",
				growthDirection="right",
				-- Type Specific Element Configuration
				binding="healthPercent", width=raidFrameWidth, height=raidFrameTopBarHeight, colorBinding="callingColor",
				texAddon=AddonId, texFile="img/Diagonal.png",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="imgRole", type="ImageSet", parent="frameBackdrop", layer=20,
				attach = {{ point="TOPLEFT", element="barHealth", targetPoint="TOPLEFT", offsetX=3, offsetY=4 }}, visibilityBinding="role",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/Roles12.png", nameBinding="role", cols=1, rows=5, 
				names = { ["tank"] = 0, ["heal"] = 1, ["dps"] = 2, ["support"] = 3 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="labelName", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="CENTERLEFT", element="imgRole", targetPoint="CENTERRIGHT" }},
				visibilityBinding="name",
				-- Type Specific Element Configuration
				text="{nameShort}", default="", fontSize=11
			},
			{
				-- Generic Element Configuration
				id="labelStatus", type="Label", parent="frameBackdrop", layer=20,
				attach = {{ point="BOTTOMCENTER", element="frameBackdrop", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-4 }},
				visibilityBinding="name",
				-- Type Specific Element Configuration
				text=" {raidStatus}", default="", fontSize=12
			},
			{
				-- Generic Element Configuration
				id="barResource", type="Bar", parent="frameBackdrop", layer=10,
				attach = {{ point="TOPLEFT", element="barHealth", targetPoint="BOTTOMLEFT" }},
				-- visibilityBinding="id",
				-- Type Specific Element Configuration
				binding="resourcePercent", width=raidFrameWidth, height=raidFrameBottomBarHeight, colorBinding="callingColor",
				texAddon=AddonId, texFile="img/BantoBar.png",
				backgroundColor={r=0, g=0, b=0, a=1}
			},
			{
				-- Generic Element Configuration
				id="labelMark", type="Label", parent="frameBackdrop", layer=30,
				attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-1, offsetY=2 }},
				visibilityBinding="mark",alpha=0.6,
				-- Type Specific Element Configuration
				text="{mark}", default="X", fontSize=18
			},
			{
				-- Generic Element Configuration
				id="imgReady", type="ImageSet", parent="frameBackdrop", layer=30,
				attach = {{ point="CENTER", element="frame", targetPoint="CENTER" }}, -- visibilityBinding="id",
				-- Type Specific Element Configuration
				texAddon=AddonId, texFile="img/wtReady.png", nameBinding="readyStatus", cols=1, rows=2, 
				names = { ["ready"] = 0, ["notready"] = 1 }, defaultIndex = "hide"
			},
			{
				-- Generic Element Configuration
				id="buffPanel02", type="BuffPanel", parent="frameBackdrop", layer=30,
				attach = {{ point="BOTTOMRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-2 }},
				--visibilityBinding="id",
				-- Type Specific Element Configuration
				rows=1, cols=5, iconSize=16, iconSpacing=1, borderThickness=1, 
				acceptLowPriorityBuffs=false, acceptMediumPriorityBuffs=false, acceptHighPriorityBuffs=false, acceptCriticalPriorityBuffs=false,
				acceptLowPriorityDebuffs=true, acceptMediumPriorityDebuffs=true, acceptHighPriorityDebuffs=true, acceptCriticalPriorityDebuffs=true,
				growthDirection = "left_up"
			},
		}
	}

	for idx,element in ipairs(template.elements) do
		self:CreateElement(element) 
	end
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self:SetMouseMasking("limited")
	if options.clickToTarget then
		self.Event.LeftClick = "target @" .. self.UnitSpec
	end
	if options.contextMenu then
		self.Event.RightClick = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	end

end



WT.Unit.CreateVirtualProperty("raidStatus", { "offline", "afk", "dead" },
	function(unit)
		if unit.offline then
			return "OFFLINE"
		elseif unit.afk then
			return "AFK"
		elseif unit.dead then
			return "DEAD"
		else
			return nil
		end
	end)
