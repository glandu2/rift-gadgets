--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            Lifeismystery@yandex.ru
                           Lifeismystery: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : v0.4.92
      Project Date (UTC)  : 2013-09-17T18:45:13Z
      File Modified (UTC) : 2013-09-14T08:23:02Z (Lifeismystery)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate

local StatsTemp = {}
local Stats = Inspect.Stat()
	
local function Create(configuration)	

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtStatText"), WT.Context)
	wrapper:SetHeight(30)
	wrapper:SetWidth(700)
	wrapper:SetSecureMode("restricted")
	
	if configuration.showBackground == nil then
		Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		wrapper:SetBackgroundColor(0.07,0.07,0.07,0.85)		
	elseif configuration.showBackground == true then
			Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 1)
		if configuration.BackgroundColor == nil then
			configuration.BackgroundColor = {0.07,0.07,0.07,0.85}
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		else 
			wrapper:SetBackgroundColor(configuration.BackgroundColor[1],configuration.BackgroundColor[2],configuration.BackgroundColor[3],configuration.BackgroundColor[4])
		end
	else 	
		Library.LibSimpleWidgets.SetBorder("plain", wrapper, 1, 0, 0, 0, 0)
		wrapper:SetBackgroundColor(0,0,0,0)
	end
--------------------------------------------------------------------------------------------------------------
------------------------------MANE_STAT-----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
------------------------------Stat_Strength-------------------------------------------------------------------
	local StatStrength = UI.CreateFrame("Text", WT.UniqueName("wtStatStrength"), wrapper)
	StatStrength:SetText("")
	StatStrength:SetFontSize(13)
	StatStrength:SetFontColor(1,0.97,0.84,1)
	StatStrength:SetEffectGlow({ strength = 3 })
	StatStrength:SetPoint("CENTERLEFT", wrapper, "CENTERLEFT", 10, 0)	
	
------------------------------Stat_Dexterity-------------------------------------------------------------------
	local StatDexterity = UI.CreateFrame("Text", WT.UniqueName("wtStatDexterity"), wrapper)
	StatDexterity:SetText("")
	StatDexterity:SetFontSize(13)
	StatDexterity:SetFontColor(1,0.97,0.84,1)
	StatDexterity:SetEffectGlow({ strength = 3 })
	StatDexterity:SetPoint("CENTERLEFT", StatStrength , "CENTERRIGHT", 10, 0)	
		    
------------------------------Stat_Intelligence-------------------------------------------------------------------
	local StatIntelligence = UI.CreateFrame("Text", WT.UniqueName("wtStatIntelligence"), wrapper)
	StatIntelligence:SetText("")
	StatIntelligence:SetFontSize(13)
	StatIntelligence:SetFontColor(1,0.97,0.84,1)
	StatIntelligence:SetEffectGlow({ strength = 3 })
	StatIntelligence:SetPoint("CENTERLEFT", StatDexterity , "CENTERRIGHT", 10, 0)	
	 		
------------------------------Stat_Wisdom,-------------------------------------------------------------------
	local StatWisdom = UI.CreateFrame("Text", WT.UniqueName("wtStatWisdom"), wrapper)
	StatWisdom:SetText("")
	StatWisdom:SetFontSize(13)
	StatIntelligence:SetFontColor(1,0.97,0.84,1)
	StatWisdom:SetEffectGlow({ strength = 3 })
	StatWisdom:SetPoint("CENTERLEFT", StatIntelligence , "CENTERRIGHT", 10, 0)	
	 	
------------------------------Stat_Endurance-------------------------------------------------------------------
	local StatEndurance = UI.CreateFrame("Text", WT.UniqueName("wtStatEndurance"), wrapper)
	StatEndurance:SetText("")
	StatEndurance:SetFontSize(13)
	StatEndurance:SetFontColor(1,0.97,0.84,1)
	StatEndurance:SetEffectGlow({ strength = 3 })
	StatEndurance:SetPoint("CENTERLEFT", StatWisdom , "CENTERRIGHT", 10, 0)	
	 	
------------------------------Stat_Armor-------------------------------------------------------------------
	local StatArmor = UI.CreateFrame("Text", WT.UniqueName("wtStatArmor"), wrapper)
	StatArmor:SetText("")
	StatArmor:SetFontSize(13)
	StatArmor:SetFontColor(1,0.97,0.84,1)
	StatArmor:SetEffectGlow({ strength = 3 })
	StatArmor:SetPoint("CENTERLEFT", StatEndurance , "CENTERRIGHT", 10, 0)
	 				
-----------------------------------------------------------------------------------------------------------
------------------------------OFFINSE_STAT--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------		
------------------------------Stat_PowerAttack-------------------------------------------------------------------
	local StatPowerAttack = UI.CreateFrame("Text", WT.UniqueName("wtStatPowerAttack"), wrapper)
	StatPowerAttack:SetText("")
	StatPowerAttack:SetFontSize(13)
	StatPowerAttack:SetFontColor(1,0.97,0.84,1)
	StatPowerAttack:SetEffectGlow({ strength = 3 })
	StatPowerAttack:SetPoint("CENTERLEFT", StatArmor, "CENTERRIGHT", 10, 0)	

------------------------------Stat_CritAttack-------------------------------------------------------------------
	local StatCritAttack = UI.CreateFrame("Text", WT.UniqueName("wtStatCritAttack"), wrapper)
	StatCritAttack:SetText("")
	StatCritAttack:SetFontSize(13)
	StatCritAttack:SetFontColor(1,0.97,0.84,1)
	StatCritAttack:SetEffectGlow({ strength = 3 })
	StatCritAttack:SetPoint("CENTERLEFT", StatPowerAttack, "CENTERRIGHT", 10, 0)		

------------------------------Stat_PowerSpell-------------------------------------------------------------------
	local StatPowerSpell = UI.CreateFrame("Text", WT.UniqueName("wtStatPowerSpell"), wrapper)
	StatPowerSpell:SetText("")
	StatPowerSpell:SetFontSize(13)
	StatPowerSpell:SetFontColor(1,0.97,0.84,1)
	StatPowerSpell:SetEffectGlow({ strength = 3 })
	StatPowerSpell:SetPoint("CENTERLEFT", StatCritAttack, "CENTERRIGHT", 10, 0)		
			
------------------------------Stat_CritSpell-------------------------------------------------------------------
	local StatCritSpell = UI.CreateFrame("Text", WT.UniqueName("wtStatCritSpell"), wrapper)
	StatCritSpell:SetText("")
	StatCritSpell:SetFontSize(13)
	StatCritSpell:SetFontColor(1,0.97,0.84,1)
	StatCritSpell:SetEffectGlow({ strength = 3 })
	StatCritSpell:SetPoint("CENTERLEFT", StatPowerSpell, "CENTERRIGHT", 10, 0)	
			
------------------------------Stat_CritPower-------------------------------------------------------------------
	local StatCritPower = UI.CreateFrame("Text", WT.UniqueName("wtStatCritPower"), wrapper)
	StatCritPower:SetText("")
	StatCritPower:SetFontSize(13)
	StatCritPower:SetFontColor(1,0.97,0.84,1)
	StatCritPower:SetEffectGlow({ strength = 3 })
	StatCritPower:SetPoint("CENTERLEFT", StatCritSpell, "CENTERRIGHT", 10, 0)	
		
------------------------------Stat_Hit-------------------------------------------------------------------
	local StatHit = UI.CreateFrame("Text", WT.UniqueName("wtStatHit"), wrapper)
	StatHit:SetText("")
	StatHit:SetFontSize(13)
	StatHit:SetFontColor(1,0.97,0.84,1)
	StatHit:SetEffectGlow({ strength = 3 })
	StatHit:SetPoint("CENTERLEFT", StatCritPower, "CENTERRIGHT", 10, 0)	
		
-----------------------------------------------------------------------------------------------------------
------------------------------DEFENSE_STAT--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------	
------------------------------Stat_Block-------------------------------------------------------------------
	local StatBlock = UI.CreateFrame("Text", WT.UniqueName("wtStatBlock"), wrapper)
	StatBlock:SetText("")
	StatBlock:SetFontSize(13)
	StatBlock:SetFontColor(1,0.97,0.84,1)
	StatBlock:SetEffectGlow({ strength = 3 })
	StatBlock:SetPoint("CENTERLEFT", StatHit, "CENTERRIGHT", 10, 0)	
	
------------------------------Stat_Guard-------------------------------------------------------------------
	local StatGuard = UI.CreateFrame("Text", WT.UniqueName("wtStatGuard"), wrapper)
	StatGuard:SetText("")
	StatGuard:SetFontSize(13)
	StatGuard:SetFontColor(1,0.97,0.84,1)
	StatGuard:SetEffectGlow({ strength = 3 })
	StatGuard:SetPoint("CENTERLEFT", StatBlock, "CENTERRIGHT", 10, 0)
		
------------------------------Stat_Dodge-------------------------------------------------------------------
	local StatDodge = UI.CreateFrame("Text", WT.UniqueName("wtStatDodge"), wrapper)
	StatDodge:SetText("")
	StatDodge:SetFontSize(13)
	StatDodge:SetFontColor(1,0.97,0.84,1)
	StatDodge:SetEffectGlow({ strength = 3 })
	StatDodge:SetPoint("CENTERLEFT", StatHit, "CENTERRIGHT", 10, 0)	--3.0
		
------------------------------Stat_Toughness-------------------------------------------------------------------
	--[[local StatToughness = UI.CreateFrame("Text", WT.UniqueName("wtStatToughness"), wrapper)
	StatToughness:SetText("")
	StatToughness:SetFontSize(13)
	StatToughness:SetFontColor(1,0.97,0.84,1)
	StatToughness:SetEffectGlow({ strength = 3 })
	StatToughness:SetPoint("CENTERLEFT", StatDodge, "CENTERRIGHT", 10, 0)	]]   -- 3.0
		
-----------------------------------------------------------------------------------------------------------
------------------------------RESISTENCE_STAT--------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------		
------------------------------Stat_ResistLife-------------------------------------------------------------------
	local StatResistLife = UI.CreateFrame("Text", WT.UniqueName("wtStatResistLife"), wrapper)
	StatResistLife:SetText("")
	StatResistLife:SetFontSize(13)
	StatResistLife:SetFontColor(1,0.97,0.84,1)
	StatResistLife:SetEffectGlow({ strength = 3 })
	StatResistLife:SetPoint("CENTERLEFT", StatDodge, "CENTERRIGHT", 10, 0)			
	
------------------------------Stat_ResistDeath-------------------------------------------------------------------
	local StatResistDeath = UI.CreateFrame("Text", WT.UniqueName("wtStatResistDeath"), wrapper)
	StatResistDeath:SetText("")
	StatResistDeath:SetFontSize(13)
	StatResistDeath:SetFontColor(1,0.97,0.84,1)
	StatResistDeath:SetEffectGlow({ strength = 3 })
	StatResistDeath:SetPoint("CENTERLEFT", StatResistLife, "CENTERRIGHT", 10, 0)			
	
------------------------------Stat_ResistFire-------------------------------------------------------------------
	local StatResistFire = UI.CreateFrame("Text", WT.UniqueName("wtStatResistFire"), wrapper)
	StatResistFire:SetText("")
	StatResistFire:SetFontSize(13)
	StatResistFire:SetFontColor(1,0.97,0.84,1)
	StatResistFire:SetEffectGlow({ strength = 3 })
	StatResistFire:SetPoint("CENTERLEFT", StatResistDeath, "CENTERRIGHT", 10, 0)			
	
------------------------------Stat_ResistWater-------------------------------------------------------------------
	local StatResistWater = UI.CreateFrame("Text", WT.UniqueName("wtStatResistWater"), wrapper)
	StatResistWater:SetText("")
	StatResistWater:SetFontSize(13)
	StatResistWater:SetFontColor(1,0.97,0.84,1)
	StatResistWater:SetEffectGlow({ strength = 3 })
	StatResistWater:SetPoint("CENTERLEFT", StatResistFire, "CENTERRIGHT", 10, 0)				
	
------------------------------Stat_ResistEarth-------------------------------------------------------------------
	local StatResistEarth = UI.CreateFrame("Text", WT.UniqueName("wtStatResistEarth"), wrapper)
	StatResistEarth:SetText("")
	StatResistEarth:SetFontSize(13)
	StatResistEarth:SetFontColor(1,0.97,0.84,1)
	StatResistEarth:SetEffectGlow({ strength = 3 })
	StatResistEarth:SetPoint("CENTERLEFT", StatResistWater, "CENTERRIGHT", 10, 0)		
	
------------------------------Stat_ResistAir-------------------------------------------------------------------
	local StatResistAir = UI.CreateFrame("Text", WT.UniqueName("wtStatResistAir"), wrapper)
	StatResistAir:SetText("")
	StatResistAir:SetFontSize(13)
	StatResistAir:SetFontColor(1,0.97,0.84,1)
	StatResistAir:SetEffectGlow({ strength = 3 })
	StatResistAir:SetPoint("CENTERLEFT", StatResistEarth, "CENTERRIGHT", 10, 0)			
		
-----------------------------------------------------------------------------------------------------------
------------------------------PLAYER_VERSUS_PLAYER_STAT----------------------------------------------------
-----------------------------------------------------------------------------------------------------------	
------------------------------Stat_Vengeance-------------------------------------------------------------------
	--[[local StatVengeance = UI.CreateFrame("Text", WT.UniqueName("wtStatVengeance"), wrapper)
	StatVengeance:SetText("")
	StatVengeance:SetFontSize(13)
	StatVengeance:SetFontColor(1,0.97,0.84,1)
	StatVengeance:SetEffectGlow({ strength = 3 })
	StatVengeance:SetPoint("CENTERLEFT", StatResistAir, "CENTERRIGHT", 10, 0)	]]
			
			 
------------------------------Stat_Valor-------------------------------------------------------------------
	--[[local StatValor = UI.CreateFrame("Text", WT.UniqueName("wtStatValor"), wrapper)
	StatValor:SetText("")
	StatValor:SetFontSize(13)
	StatValor:SetFontColor(1,0.97,0.84,1)
	StatValor:SetEffectGlow({ strength = 3 })
	StatValor:SetPoint("CENTERLEFT", StatResistEarth, "CENTERRIGHT", 10, 0)	]]
	
-----------------------------------------------------------------------------------------------------------
------------------------------Deflect??_STAT----------------------------------------------------
-----------------------------------------------------------------------------------------------------------		 
------------------------------Stat_Deflect-------------------------------------------------------------------
	--[[local StatDeflect = UI.CreateFrame("Text", WT.UniqueName("wtStatDeflect"), wrapper)
	StatDeflect:SetText("")
	StatDeflect:SetFontSize(13)
	StatDeflect:SetFontColor(1,0.97,0.84,1)
	StatDeflect:SetEffectGlow({ strength = 3 })
	StatDeflect:SetPoint("CENTERLEFT", StatValor, "CENTERRIGHT", 10, 0)]]-- 3.0
					
----------------------------------------------------------------------------------------------------------------
	if configuration.showStrength == false then
	    StatStrength:SetVisible(false)	
		StatStrength:SetWidth(-10)
	end	
	
	if configuration.showDexterity == false then
	    StatDexterity:SetVisible(false)
		StatDexterity:SetWidth(-10)
	end
	
	if configuration.showIntelligence == false then
	    StatIntelligence:SetVisible(false)
		StatIntelligence:SetWidth(-10)	
	end	
	
	if configuration.showWisdom == false then
	    StatWisdom:SetVisible(false)	
		StatWisdom:SetWidth(-10)
	end	
		
	if configuration.showEndurance == false then
	    StatEndurance:SetVisible(false)	
		StatEndurance:SetWidth(-10)
	end

	if configuration.showArmor == false then
	    StatArmor:SetVisible(false)
		StatArmor:SetWidth(-10)
	end

	if configuration.showPowerAttack == false then
	    StatPowerAttack:SetVisible(false)
		StatPowerAttack:SetWidth(-10)
	end	

	if configuration.showCritAttack == false then
	    StatCritAttack:SetVisible(false)
		StatCritAttack:SetWidth(-10)
	end	
		
	if configuration.showPowerSpell == false then
	    StatPowerSpell:SetVisible(false)
		StatPowerSpell:SetWidth(-10)
	end
	
	if configuration.showCritSpell == false then
	    StatCritSpell:SetVisible(false)
		StatCritSpell:SetWidth(-10)
	end	
	
	if configuration.showCritPower == false then
	    StatCritPower:SetVisible(false)
		StatCritPower:SetWidth(-10)
	end	
	
	if configuration.showHit == false then
	    StatHit:SetVisible(false)
		StatHit:SetWidth(-10)
	end	
	
	if configuration.showBlock == false then
	    StatBlock:SetVisible(false)
		StatBlock:SetWidth(-10)
	end	
	
	if configuration.showGuard == false then
	    StatGuard:SetVisible(false)
		StatGuard:SetWidth(-10)
	end
	
	if configuration.showDodge == false then
	    StatDodge:SetVisible(false)
		StatDodge:SetWidth(-10)
	end	
	
	--[[if configuration.showToughness == false then
	    StatToughness:SetVisible(false)
		StatToughness:SetWidth(-10)
	end	]]   -- 3.0
	
	if configuration.showResistLife == false then
	    StatResistLife:SetVisible(false)
		StatResistLife:SetWidth(-10)
	end	
	
	if configuration.showResistDeath == false then
	    StatResistDeath:SetVisible(false)
		StatResistDeath:SetWidth(-10)
	end
	
	if configuration.showResistFire == false then
	    StatResistFire:SetVisible(false)
		StatResistFire:SetWidth(-10)
	end	

	if configuration.showResistWater == false then
	    StatResistWater:SetVisible(false)
		StatResistWater:SetWidth(-10)
	end	
	
	if configuration.showResistEarth == false then
	    StatResistEarth:SetVisible(false)
		StatResistEarth:SetWidth(-10)
	end	
	
	if configuration.showResistAir == false then
	    StatResistAir:SetVisible(false)
		StatResistAir:SetWidth(-10)
	end	
	
	--[[if configuration.showVengeance == false then
	    StatVengeance:SetVisible(false)
		StatVengeance:SetWidth(-10)
	end]]
	
	--[[if configuration.showValor == false then
	    StatValor:SetVisible(false)
		StatValor:SetWidth(-10)
	end	]]	
	
	--[[if configuration.showDeflect == false then
	    StatDeflect:SetVisible(false)
		StatDeflect:SetWidth(-10)
	end]]-- 3.0

	Stats = Inspect.Stat()
	if Stats ~= nil then	
			Strength = Inspect.Stat("strength")
			Dexterity = Inspect.Stat("dexterity")
			Intelligence = Inspect.Stat("intelligence")
			Wisdom = Inspect.Stat("wisdom")
			Endurance = Inspect.Stat("endurance")
			Armor = Inspect.Stat("armor")
			PowerAttack = Inspect.Stat("powerAttack")
			CritAttack = Inspect.Stat("critAttack")
			PowerSpell = Inspect.Stat("powerSpell")
			CritSpell = Inspect.Stat("critSpell")
			CritPower = Inspect.Stat("critPower")
			Hit = Inspect.Stat("hit")
			Block = Inspect.Stat("block")
			Guard = Inspect.Stat("guard")
			Dodge = Inspect.Stat("dodge")
			--Toughness = Inspect.Stat("toughness")   -- 3.0
			ResistLife = Inspect.Stat("resistLife")
			ResistDeath = Inspect.Stat("resistDeath")
			ResistFire = Inspect.Stat("resistLife")
			ResistWater = Inspect.Stat("resistWater")
			ResistEarth = Inspect.Stat("resistEarth")
			ResistAir = Inspect.Stat("resistAir")
			--Vengeance = Inspect.Stat("vengeance")
			--Valor = Inspect.Stat("valor")
			--Deflect = Inspect.Stat("deflect") -- 3.0
		
			if configuration.showStrength == true then
				StatStrength:SetText("Strength:" .. " " .. Strength)
			end
			if configuration.showDexterity == true then
				StatDexterity:SetText("Dexterity:" .. " " .. Dexterity)	
			end
			if configuration.showIntelligence == true then
				StatIntelligence:SetText("Intelligence:" .. " " .. Intelligence)
			end
			if configuration.showWisdom == true then
				StatWisdom:SetText("Wisdom:" .. " " .. Wisdom)	
			end
			if configuration.showEndurance == true then	
				StatEndurance:SetText("Endurance:" .. " " .. Endurance)
			end
			if configuration.showArmor == true then
				StatArmor:SetText("Armor:" .. " " .. Armor)
			end
			if configuration.showPowerAttack == true then
				StatPowerAttack:SetText("AP:" .. " " .. PowerAttack)
			end
			if configuration.showCritAttack == true then
				StatCritAttack:SetText("Physical Crit:" .. " " .. CritAttack)
			end
			if configuration.showPowerSpell == true then
				StatPowerSpell:SetText("SP:" .. " " .. PowerSpell)
			end
			if configuration.showCritSpell == true then
				StatCritSpell:SetText("Spell Crit:" .. " " .. CritSpell)
			end
			if configuration.showCritPower == true then
				StatCritPower:SetText("CP:" .. " " .. CritPower)
			end
			if configuration.showHit == true then
				StatHit:SetText("Hit:" .. " " .. Hit)
			end
			if configuration.showBlock == true then
				StatBlock:SetText("Block:" .. " " .. Armor)
			end
			if configuration.showGuard == true then
				StatGuard:SetText("Guard:" .. " " .. Guard)
			end
			if configuration.showDodge == true then
				StatDodge:SetText("Dodge:" .. " " .. Dodge)
			end
			--[[if configuration.showToughness == true then
				StatToughness:SetText("Toughness:" .. " " .. Toughness)
			end]]   -- 3.0
			if configuration.showResistLife == true then
				StatResistLife:SetText("Life Resist:" .. " " .. ResistLife)
			end
			if configuration.showResistDeath == true then
				StatResistDeath:SetText("Death Resist:" .. " " .. ResistDeath)
			end
			if configuration.showResistFire == true then
				StatResistFire:SetText("Fire Resist:" .. " " .. ResistFire)
			end
			if configuration.showResistWater == true then
				StatResistWater:SetText("Water Resist:" .. " " .. ResistWater)
			end
			if configuration.showResistEarth == true then
				StatResistEarth:SetText("Earth Resist:" .. " " .. ResistEarth)
			end
			if configuration.showResistAir == true then
				StatResistAir:SetText("Air Resist:" .. " " .. ResistAir)
			end
			--[[if configuration.showVengeance == true then
				StatVengeance:SetText("Vengeance:" .. " " .. Vengeance)
			end]]
			--[[if configuration.showValor == true then
				StatValor:SetText("Valor:" .. " " .. Valor)
			end]]
			--[[if configuration.showDeflect == true then
				StatDeflect:SetText("Deflect:" .. " " .. Deflect)
			end]]-- 3.0
			local width = 10
			width = width + StatStrength:GetWidth()	+ 10
			width = width + StatDexterity:GetWidth() + 10
			width = width + StatIntelligence:GetWidth() + 10
			width = width + StatWisdom:GetWidth() + 10
			width = width + StatEndurance:GetWidth() + 10
			width = width + StatArmor:GetWidth() + 10
			width = width + StatPowerAttack:GetWidth()	+ 10
			width = width + StatCritAttack:GetWidth() + 10
			width = width + StatPowerSpell:GetWidth() + 10
			width = width + StatCritSpell:GetWidth() + 10
			width = width + StatCritPower:GetWidth() + 10
			width = width + StatHit:GetWidth() + 10
			width = width + StatBlock:GetWidth() + 10
			width = width + StatGuard:GetWidth() + 10
			width = width + StatDodge:GetWidth() + 10
			--width = width + StatToughness:GetWidth() + 10
			width = width + StatResistLife:GetWidth() + 10
			width = width + StatResistDeath:GetWidth() + 10	
			width = width + StatResistFire:GetWidth() + 10
			width = width + StatResistWater:GetWidth() + 10
			width = width + StatResistEarth:GetWidth() + 10	
			width = width + StatResistAir:GetWidth() + 10
			--width = width + StatVengeance:GetWidth() + 10
			--width = width + StatValor:GetWidth() + 10
			--width = width + StatDeflect:GetWidth() + 10	 -- 3.0

		if not  configuration.width then	
			configuration.width = width 	
		elseif width > configuration.width then 
			configuration.width = width 
		end	
	end		
	
function stat (handle, stat)

	Stats = Inspect.Stat()
	if Stats ~= nil then
			Strength = Inspect.Stat("strength")
			Dexterity = Inspect.Stat("dexterity")
			Intelligence = Inspect.Stat("intelligence")
			Wisdom = Inspect.Stat("wisdom")
			Endurance = Inspect.Stat("endurance")
			Armor = Inspect.Stat("armor")
			PowerAttack = Inspect.Stat("powerAttack")
			CritAttack = Inspect.Stat("critAttack")
			PowerSpell = Inspect.Stat("powerSpell")
			CritSpell = Inspect.Stat("critSpell")
			CritPower = Inspect.Stat("critPower")
			Hit = Inspect.Stat("hit")
			Block = Inspect.Stat("block")
			Guard = Inspect.Stat("guard")
			Dodge = Inspect.Stat("dodge")
			--Toughness = Inspect.Stat("toughness") --3.0
			ResistLife = Inspect.Stat("resistLife")
			ResistDeath = Inspect.Stat("resistDeath")
			ResistFire = Inspect.Stat("resistLife")
			ResistWater = Inspect.Stat("resistWater")
			ResistEarth = Inspect.Stat("resistEarth")
			ResistAir = Inspect.Stat("resistAir")
			--Vengeance = Inspect.Stat("vengeance")
			--Valor = Inspect.Stat("valor")
			--Deflect = Inspect.Stat("deflect")   -- 3.0
			
			if configuration.showStrength == true then
				StatStrength:SetText("Strength:" .. " " .. Strength)
			end
			if configuration.showDexterity == true then
				StatDexterity:SetText("Dexterity:" .. " " .. Dexterity)	
			end
			if configuration.showIntelligence == true then
				StatIntelligence:SetText("Intelligence:" .. " " .. Intelligence)
			end
			if configuration.showWisdom == true then
				StatWisdom:SetText("Wisdom:" .. " " .. Wisdom)	
			end
			if configuration.showEndurance == true then	
				StatEndurance:SetText("Endurance:" .. " " .. Endurance)
			end
			if configuration.showArmor == true then
				StatArmor:SetText("Armor:" .. " " .. Armor)
			end
			if configuration.showPowerAttack == true then
				StatPowerAttack:SetText("AP:" .. " " .. PowerAttack)
			end
			if configuration.showCritAttack == true then
				StatCritAttack:SetText("Physical Crit:" .. " " .. CritAttack)
			end
			if configuration.showPowerSpell == true then
				StatPowerSpell:SetText("SP:" .. " " .. PowerSpell)
			end
			if configuration.showCritSpell == true then
				StatCritSpell:SetText("Spell Crit:" .. " " .. CritSpell)
			end
			if configuration.showCritPower == true then
				StatCritPower:SetText("CP:" .. " " .. CritPower)
			end
			if configuration.showHit == true then
				StatHit:SetText("Hit:" .. " " .. Hit)
			end
			if configuration.showBlock == true then
				StatBlock:SetText("Block:" .. " " .. Armor)
			end
			if configuration.showGuard == true then
				StatGuard:SetText("Guard:" .. " " .. Guard)
			end
			if configuration.showDodge == true then
				StatDodge:SetText("Dodge:" .. " " .. Dodge)
			end
			--[[if configuration.showToughness == true then
				StatToughness:SetText("Toughness:" .. " " .. Toughness)
			end]]   -- 3.0
			if configuration.showResistLife == true then
				StatResistLife:SetText("Life Resist:" .. " " .. ResistLife)
			end
			if configuration.showResistDeath == true then
				StatResistDeath:SetText("Death Resist:" .. " " .. ResistDeath)
			end
			if configuration.showResistFire == true then
				StatResistFire:SetText("Fire Resist:" .. " " .. ResistFire)
			end
			if configuration.showResistWater == true then
				StatResistWater:SetText("Water Resist:" .. " " .. ResistWater)
			end
			if configuration.showResistEarth == true then
				StatResistEarth:SetText("Earth Resist:" .. " " .. ResistEarth)
			end
			if configuration.showResistAir == true then
				StatResistAir:SetText("Air Resist:" .. " " .. ResistAir)
			end
			--[[if configuration.showVengeance == true then
				StatVengeance:SetText("Vengeance:" .. " " .. Vengeance)
			end]]
			--[[if configuration.showValor == true then
				StatValor:SetText("Valor:" .. " " .. Valor)
			end]]
			--[[if configuration.showDeflect == true then
				StatDeflect:SetText("Deflect:" .. " " .. Deflect)
			end]]-- 3.0
	end		
end	
	
	table.insert(StatsTemp, Stats)
	table.insert(Event.Stat,{ stat, AddonId, "_stat" })
	
	return wrapper, { resizable={50, 30, 2560, 30} }
	
end

	
local dialog = false

local function ConfigDialog(container)	
	
	dialog = WT.Dialog(container)
		:Label("This gadget displays StatText bar with all player stats ")
		
		:Title("MANE ")	
		:Checkbox("showStrength", "Show strength", true)
		:Checkbox("showDexterity", "Show dexterity", true)		
		:Checkbox("showIntelligence", "Show intelligence", true)		
		:Checkbox("showWisdom", "Show wisdom", true)
		:Checkbox("showEndurance", "Show endurance", true)
		:Checkbox("showArmor", "Show armor", true)
		:Title("OFFINSE")			
		:Checkbox("showPowerAttack", "Show Attack Power", true)
		:Checkbox("showCritAttack", "Show Physical Crit", false)
		:Checkbox("showPowerSpell", "Show Spell Power", true)
		:Checkbox("showCritSpell", "Show Spell Crit", false)
		:Checkbox("showCritPower", "Show Crit Power", true)
		:Checkbox("showHit", "Show Hit", true)
		:Title("DEFENSE")			
		:Checkbox("showBlock", "Show Block", false)
		:Checkbox("showGuard", "Show Guard", false)
		:Checkbox("showDodge", "Show dodge", false)
		--:Checkbox("showToughness", "Show toughness", false)
		:Title("RESISTENCE")			
		:Checkbox("showResistLife", "Show Life resist", false)		
		:Checkbox("showResistDeath", "Show Death resist", false)		
		:Checkbox("showResistFire", "Show Fire resist", false)
		:Checkbox("showResistWater", "Show Water resist", false)
		:Checkbox("showResistEarth", "Show Earth resist", false)
		:Checkbox("showResistAir", "Show Air resist", false)
		:Title("PLAYER VERSUS PLAYER")			
		--:Checkbox("showVengeance", "Show vengeance", false)
		--:Checkbox("showValor", "Show valor", false)
		--:Title("Deflect")			
		--:Checkbox("showDeflect", "Show deflect", false) -- 3.0
		:TitleY("Gadgets Options")					
		:Checkbox("showBackground", "Show Background frame", true)
		:ColorPicker("BackgroundColor", "Background Color", 0.07,0.07,0.07,0.85)

end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end

	
WT.Gadget.RegisterFactory("StatTextBar",
	{
		name=TXT.gadgetStatTextBar_name,
		description=TXT.gadgetStatTextBar_desc,
		author="Lifeismystery",
		version="1.0.0",
		iconTexAddon="Rift",
		iconTexFile="tumblr.png.dds",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})