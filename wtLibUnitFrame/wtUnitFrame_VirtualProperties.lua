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
	