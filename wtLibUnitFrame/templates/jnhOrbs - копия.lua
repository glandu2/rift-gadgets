local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local scale = 1.0
local LifeOrbWidth = 256 * scale
local LifeOrbHeight = 256 * scale
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local LifeOrb = WT.UnitFrame:Template("LifeOrb")
LifeOrb.Configuration.Name = "Health+Mana+lvl Orb Unit Frame"
LifeOrb.Configuration.RaidSuitable = false
LifeOrb.Configuration.FrameType = "Frame"
LifeOrb.Configuration.Width = LifeOrbWidth
LifeOrb.Configuration.Height = LifeOrbHeight
LifeOrb.Configuration.Resizable = { LifeOrbWidth / 4, LifeOrbHeight / 4, LifeOrbWidth * 2, LifeOrbHeight * 2 } 
---------------------------------------------------------------------------------


function LifeOrb:Construct(options)

	local template =
	{
		elements = 
		{
	
	-- HP ORB =====================================================================================
			-- ORB back BG
			{
				id="orbBACK", type="Image", parent="frame", layer=10, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/jnhOrb_back.png"	
			}, 

			-- ORB filling BG
			{
				id="orbFILLING", type="Bar", parent="frame", layer=11, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, visibilityBinding="id", binding="healthPercent", growthDirection="up",
				texAddon = "Rift", texFile = "RiftMeter_I103.dds"	, 
				--height=142, width=142,		
			},
			-- ORB filling BG
			-- ORB filling BG
			--"CTF_Shield_Bkgnd.png.dds"
			--"RiftMeter_I100.dds" зеленый
			--"RiftMeter_I103.dds"
			--"RiftMeter_I27.dds" absorb
			--"RiftMeter_IF4.dds"
			--"RiftMeter_IF7.dds"
			--"RiftMeter_IFA.dds"
			--"TargetPortrait_I146.dds" aggro
			--"UpgradableNPC_I1B.dds"
			--"player_portrait_bg_defiant.png.dds" 256*128
			--"player_portrait_bg_guardian.png.dds"
			--"portrait_bg.png.dds"
			---"round_progbar.png.dds" absorb
			--"round_yellow_base.png.dds"
			{
				id="orbHealpCap", type="Bar", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=0, offsetY=0 } 
				}, 				
				visibilityBinding="healthCap",
				binding="healthCapPercent", growthDirection="down",
				texAddon = "Rift", texFile = "RiftMeter_IFD.dds",
			--	height=142, width=142,		
			},
			{
				id="orbAbsord", type="Bar", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=-5, offsetY=5 },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-5, offsetY=5 } 
				},
				visibilityBinding="id", 
				binding="health", 
				--binding="absorbPercent", 
				--growthDirection="up",
				texAddon = "Rift", texFile = "round_progbar.png.dds"	,
				height=256, width=256,		
			},
			-- ORB ring on top
			--[[{
				id="orbRING", type="Image", parent="frame", layer=12, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="id", texAddon = AddonId, texFile = "img/jnhOrb_ring.png"		
			},]]
			
			-- HP (%)
			{
				id="healthPERCENT", type="Label", parent="frame", layer=13,
				attach = 
				{ 
					{ point="CENTER", element="orbFILLING", targetPoint="CENTER", offsetX=0, offsetY=-5 },
				}, visibilityBinding="id", text="{healthPercent}%",fontSize=36,	outline=true
			}, 
			
			-- HP (num)
			{
				id="healthNUM", type="Label", parent="frame", layer=14,
				attach = 
				{ 
					{ point="TOPCENTER", element="healthPERCENT", targetPoint="CENTER", offsetX=0, offsetY=15 },
				}, visibilityBinding="id", text="{health}",fontSize=16,	outline=true
			},
			
	-- MP ORB =====================================================================================
			-- ORB back BG
			--[[{
				id="orbBACK2", type="Image", parent="frame", layer=5, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="resource", texAddon = AddonId, texFile = "img/LifeOrb2_back.png"		
			}, 
			
			-- ORB filling BG
			{
				id="orbFILLING2", type="Bar", parent="frame", layer=6, alpha=1,
				attach = 
				{ 
					{ point="CENTER", element="frame", targetPoint="CENTER", offsetX=-68, offsetY=35 } 
				}, visibilityBinding="resource", binding="resourcePercent", growthDirection="up",
				media="LifeOrb2_BLEU", 
				height=106, width=105,		
			},
			
			-- ORB ring on top
			{
				id="orbRING2", type="Image", parent="frame", layer=7, alpha=1,
				attach = 
				{ 
					{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
					{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
				}, 				
				visibilityBinding="resource", texAddon = AddonId, texFile = "img/LifeOrb2_ring.png"		
			},
			
			-- MP (%)
			{
				id="manaPERCENT", type="Label", parent="frame", layer=8,
				attach = 
				{ 
					{ point="CENTER", element="orbFILLING2", targetPoint="CENTER", offsetX=0, offsetY=-2 },
				}, visibilityBinding="id", text="{resourcePercent}%",fontSize=26,	outline=true
			}, 
			
			-- MP (num)
			{
				id="manaNUM", type="Label", parent="frame", layer=9,
				attach = 
				{ 
					{ point="TOPCENTER", element="manaPERCENT", targetPoint="CENTER", offsetX=0, offsetY=8 },
				}, visibilityBinding="id", text="{resource}",fontSize=16,	outline=true
			},]]
	
	-- LVL + NAME =====================================================================================
		--[[	{
				id="TxtName", type="Label", parent="frame", layer=20,
				attach = 
				{ 
					{ point="TOPCENTER", element="orbBACK", targetPoint="BOTTOMCENTER", offsetX=30, offsetY=-20 },
				}, visibilityBinding="id", text="{nameShort} - {level}",fontSize=20, outline=true
			},]]
		}
	}
	
	WT.UnitFrame.EnableResizableTemplate(self, LifeOrbWidth, LifeOrbHeight, template.elements)
	
	for idx,element in ipairs(template.elements) do
		self:CreateElement(element) 
	end
	
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self:EventMacroSet(Event.UI.Input.Mouse.Left.Click, "target @" .. self.UnitSpec)
	self:EventAttach(Event.UI.Input.Mouse.Right.Click, function(self, h)
		if self.UnitId then Command.Unit.Menu(self.UnitId) end
	end, "Event.UI.Input.Mouse.Right.Click")

	
end
