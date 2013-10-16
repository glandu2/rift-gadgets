local toc, data = ...
local AddonId = toc.identifier

-- Set up standard virtual properties

WT.Unit.CreateVirtualProperty("resource", { "mana", "power", "energy" }, 
	function(unit) 
		return unit.mana or unit.energy or unit.power 
	end)
	
WT.Unit.CreateVirtualProperty("resourceMax", { "manaMax", "power", "energyMax" }, 
	function(unit)
		if unit.power then
			return 100
		else 
			return unit.manaMax or unit.energyMax
		end 
	end)

WT.Unit.CreateVirtualProperty("healthPercent", { "health", "healthMax" }, 
	function(unit)
		if unit.health and unit.healthMax and unit.healthMax > 0 then
			return (unit.health / unit.healthMax) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("healthCapPercent", { "healthCap", "healthMax" }, 
	function(unit)
		if unit.healthCap and unit.healthMax and unit.healthCap > 0 then
			return (1 - unit.healthCap / unit.healthMax) * 100 
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("chargePercent", { "charge", "chargeMax" }, 
	function(unit)
		if unit.charge then
			return (unit.charge / (unit.chargeMax or 100)) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("resourcePercent", { "mana", "power", "energy", "manaMax", "energyMax" }, 
	function(unit)
		if unit.mana and unit.manaMax and unit.manaMax > 0 then
			return (unit.mana / unit.manaMax) * 100 
		elseif unit.energy and unit.energyMax and unit.energyMax > 0 then
			return (unit.energy / unit.energyMax) * 100 
		elseif unit.power then
			return unit.power 
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("readyStatus", { "ready" }, 
	function(unit)
		if unit.ready == true then 
			return "ready"
		elseif unit.ready == false then
			return "notready"
		else
			return nil
		end
	end)
	
WT.Unit.CreateVirtualProperty("aggroColor", { "aggro", "combat" },
	function(unit)
		if unit.aggro then
			return { r = 0.8, g=0, b = 0, a=1 }
		--elseif unit.combat then
			--return { r = 0.8, g=0.8, b = 0, a=0.6 }
		else
			return { r = 0, g=0, b = 0, a=0.8 }
		end
	end)

WT.Unit.CreateVirtualProperty("dead", { "health", "combat" },
	function(unit)
		if unit.health and unit.health == 0 then
			return "Dead"
		else
			return nil
		end
	end)

WT.Unit.CreateVirtualProperty("rank", { "relation", "tier" },
	function(unit)
		local rel = unit.relation or "neutral"
		local tier = unit.tier or "normal"
		return rel .. tier
	end)

WT.Unit.CreateVirtualProperty("hostility", { "id", "relation" },
	function(unit)
		if not unit.id then return nil end
		return unit.relation or "neutral"
	end)

WT.Unit.CreateVirtualProperty("pvpAlliance", { "alliance", "pvp" },
	function(unit)
		if not unit.pvp then
			return nil
		else
			return unit.alliance
		end
	end)
	
WT.Unit.CreateVirtualProperty("taggedColor", { "tagged", "relation" },
	function(unit)
		if unit.tagged == "other" and unit.relation == "hostile" then
			return { r = 0.4, g = 0.4, b = 0.4, a = 1.0 }
		else
			return { r = 0, g = 0.7, b = 0, a = 1.0 }
		end
	end)
	
WT.Unit.CreateVirtualProperty("absorbPercent", { "absorb", "healthMax" },
	function(unit)
		if unit.absorb and unit.healthMax and unit.healthMax > 0 then
			local absorb = (unit.absorb / unit.healthMax) * 100
			if absorb > 100 then
				return 100
			else
				return absorb
			end
		else 
			return nil
		end 
	end)
	
WT.Unit.CreateVirtualProperty("healthAbsorbPercent", { "health", "healthMax", "absorb", "absorbPercent" }, 
	function(unit)
		if unit.health and unit.healthMax and unit.absorbPercent and unit.healthMax > 0 and unit.absorbPercent > 0 then
			return ((unit.health / unit.healthMax) * 100 ) + unit.absorbPercent
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("healthAbsorbPercent2", { "health", "healthMax", "absorb", "absorbPercent" }, 
    function(unit)
      if unit.health and unit.healthMax and unit.healthMax > 0 then
         if unit.absorbPercent and unit.absorbPercent > 0 then
            return ((unit.health / unit.healthMax) * 100 ) + unit.absorbPercent
         else 
            return (unit.health / unit.healthMax) * 100
         end
      else
         return nil
      end 
   end)

   -----------------------------------------------------------
   
WT.Unit.CreateVirtualProperty("BorderTextureAggroVisible", {"id", "aggro"},
	function(unit)
		if not unit.id then
			return false
		elseif unit.aggro then
			return true
		else 
			return false
		end
    end)
	
WT.Unit.CreateVirtualProperty("BorderColor", { "playerTarget", "id", "aggro"},
	function(unit)			
		if unit.playerTarget and unit.calling == "mage" then
			return { r = 0.6, g = 0.0, b = 0.8, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "cleric" then
			return { r = 0.0, g = 0.8, b = 0.0, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "rogue" then
			return { r = 0.7, g = 0.6, b = 0.0, a = 1.0 }
		elseif unit.playerTarget and unit.calling == "warrior" then
			return { r = 0.8, g = 0.0, b = 0.0, a = 1.0 }
		elseif not unit.playerTarget and unit.id then
		    if unit.aggro then return { r=1, g=0, b =0, a=1 }
			else return { r=0, g=0, b=0, a=1 } end
		else
			return { r=0, g=0, b=0, a=0 }
		end
	end)
	   
WT.Unit.CreateVirtualProperty("BorderTextureTargetVisible", {"playerTarget"},
	function(unit)
		if unit.playerTarget then
			return true
		else 
			return false
		end
    end)

WT.Unit.CreateVirtualProperty("backgroundColorUnit", { "id", "cleansable"},
	function(unit)
		if unit.cleansable then
			return { r=0.2, g=0.15, b=0.4, a=0.8 }
		else
			return {r=0.07,g=0.07,b=0.07, a=0.85}
		end
	end)

WT.Unit.CreateVirtualProperty("FrameAlpha", { "id", "blockedOrOutOfRange"},
	function(unit)
		if unit.blockedOrOutOfRange then
			return {alpha=0.4}	
		else	
			return {alpha=1}
		end
	end)

WT.Unit.CreateVirtualProperty("UnitStatus", { "offline", "afk", "health" },
	function(unit)
		if unit.offline then
			return "offline"
		elseif unit.afk then
			return "afk"
		elseif unit.health and unit.health == 0 then
			return "dead"
		else
			return ""
		end
	end)	