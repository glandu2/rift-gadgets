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

--[[
	WT.UnitDatabase
	
		Manages a collection of all currently available units, and maintains unit properties to automatically
		keep them in sync with the client. 

	API
	
		Static Methods
		
			WT.UnitDatabase.GetUnit(unitId)
				Returns a unit from the database, or nil if the unit was not found
				
			WT.UnitDatabase.CreateVirtualProperty(propertyName, dependencies, fn)
				Create a virtual unit property. This will appear to be a normal property to the client.
				propertyName: the unique name of the virtual property to create.
				dependencies: an array of property IDs. A change in any of these properties will trigger the 
				              calculation of the virtual property.
				fn:           a function that returns the value of the property. The function receives the
				              Unit instance as it's only argument.
				              
		Events
		
			WT.Event.UnitAdded(unitId)
				A unit was added to the database

			WT.Event.UnitRemoved(unitId)
				A unit was removed from the database

			WT.Event.BuffAdded(unitId, buffId)
				A buff was added to a unit

			WT.Event.BuffChanged(unitId, buffId)
				A buff was changed on a unit

			WT.Event.BuffRemoved(unitId, buffId)
				A buff was removed from a unit

			WT.Event.CastbarShow(unitId, castbarDetails)
				A unit's castbar has changed or become visible

			WT.Event.CastbarHide(unitId)
				A unit's castbar was hidden

--]]

-- Global store of all WT.Unit instances
WT.Units = {}

-- Hold a reference to the player
local playerId = Inspect.Unit.Lookup("player")
WT.Player = { id = playerId }

-- Container for database methods
WT.UnitDatabase = {}
WT.UnitDatabase.Casting = {}

-- Events --------------------------------------------------------------------
WT.Event.Trigger.UnitAdded, WT.Event.UnitAdded = Utility.Event.Create(AddonId, "UnitAdded")
WT.Event.Trigger.UnitRemoved, WT.Event.UnitRemoved = Utility.Event.Create(AddonId, "UnitRemoved")
WT.Event.Trigger.PlayerAvailable, WT.Event.PlayerAvailable = Utility.Event.Create(AddonId, "PlayerAvailable")
WT.Event.Trigger.BuffUpdates, WT.Event.BuffUpdates = Utility.Event.Create(AddonId, "BuffUpdates")
WT.Event.Trigger.CastbarShow, WT.Event.CastbarShow = Utility.Event.Create(AddonId, "CastbarShow")
WT.Event.Trigger.CastbarHide, WT.Event.CastbarHide = Utility.Event.Create(AddonId, "CastbarHide")

WT.Event.Trigger.GroupAdded, WT.Event.GroupAdded = Utility.Event.Create(AddonId, "GroupAdded")
WT.Event.Trigger.GroupRemoved, WT.Event.GroupRemoved = Utility.Event.Create(AddonId, "GroupRemoved")
WT.Event.Trigger.GroupModeChanged, WT.Event.GroupModeChanged = Utility.Event.Create(AddonId, "GroupModeChanged")

local function IsBlackListed(buff)
	if wtxOptions.buffsBlacklist and wtxOptions.buffsBlacklist[buff.name] then
		return true
	else
		return false
	end 
end


local function TriggerBuffUpdates(unitId, changes)
	local unit = WT.Units[unitId]
	WT.Unit.UpdateCleanseStatus(unit)
	WT.Event.Trigger.BuffUpdates(unitId, changes)
end


local function OnBuffAdd(unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local bdesc = Inspect.Buff.Detail(unitId, buffs)
	local changes = { add = {} }
	
	for buffId, buff in pairs(bdesc) do
	
		if not IsBlackListed(buff) then 
			if not WT.Units[unitId].Buffs[buffId] then
				changes.add[buffId] = buff
				WT.Units[unitId].Buffs[buffId] = buff
			end
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local function OnBuffRemove(unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local changes = { remove = {} }
	
	for buffId in pairs(buffs) do
		if WT.Units[unitId].Buffs[buffId] then
			changes.remove[buffId] = WT.Units[unitId].Buffs[buffId]
			WT.Units[unitId].Buffs[buffId] = nil
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local function OnBuffChange(unitId, buffs)

	if not buffs then return end
	if not WT.Units[unitId] then return end

	local changes = { update = {} }

	local bdesc = Inspect.Buff.Detail(unitId, buffs)
	
	for buffId, buff in pairs(bdesc) do
		if not IsBlackListed(buff) then 
			changes.update[buffId] = buff
			WT.Units[unitId].Buffs[buffId] = buff
		end
	end

	TriggerBuffUpdates(unitId, changes)

end


local castColorUninterruptable = { r=0.8, g=0.4, b=0, a=1 }
local castColorInterruptable = { r=0, g=0.7, b=0.7, a=1 }

local function UpdateCastbarDetails(unitId, cb)
	if cb then
		local unit = WT.Units[unitId] 
		unit.castUninterruptible = cb.uninterruptible or false
		if cb.uninterruptible then
			unit.castColor = castColorUninterruptable
		else
			unit.castColor = castColorInterruptable
		end
		-- Need to store some extra data to handle pushback properly
		WT.Units[unitId].castUpdated = Inspect.Time.Frame()
		WT.Units[unitId].castRemaining = cb.remaining
		WT.Units[unitId].castDuration = cb.duration
		unit.castName = cb.abilityName or ""
	else
		WT.Units[unitId].castPercent = nil
		WT.Units[unitId].castColor = nil
		WT.Units[unitId].castUninterruptible = nil
		WT.Units[unitId].castUpdated = nil
		WT.Units[unitId].castDuration = nil
		WT.Units[unitId].castRemaining = nil
		WT.Units[unitId].castName = nil
	end
end


local function CalculateCastChanges()
	local currTime = Inspect.Time.Frame()
	for unitId, castbar in pairs(WT.UnitDatabase.Casting) do
		local unit = WT.Units[unitId]			
		if unit then
			local cb = Inspect.Unit.Castbar(unitId)
			UpdateCastbarDetails(unitId, cb)
			local percent = 0
			pcall(
				function() 
					percent = (1 - (cb.remaining / cb.duration)) * 100 
					if cb.channeled then percent = 100 - percent end
					unit.castTime = string.format("%.1f/%.1fs", cb.duration - cb.remaining, cb.duration)
				end)
			unit.castPercent = percent
		end
	end
end


local function OnUnitCastbar(units)
	for unitId, cbVisible in pairs(units) do
		if WT.Units[unitId] then
			if cbVisible then
				local cb = Inspect.Unit.Castbar(unitId)			
				if cb then 
					WT.Event.Trigger.CastbarShow(unitId, cb)
					WT.UnitDatabase.Casting[unitId] = cb
					UpdateCastbarDetails(unitId, cb)
				end
			else
				WT.Event.Trigger.CastbarHide(unitId)
				WT.UnitDatabase.Casting[unitId] = nil
				WT.Units[unitId].castPercent = nil
				WT.Units[unitId].castName = nil
				WT.Units[unitId].castColor = nil
				WT.Units[unitId].castUninterruptible = nil
				WT.Units[unitId].castUpdated = nil
				WT.Units[unitId].castDuration = nil
				WT.Units[unitId].castRemaining = nil
			end
		end
	end
end


local playerAvailableFired = false

-- This is where the Unit instance is created if unitObject == nil
local function PopulateUnit(unitId, unitObject, omitBuffScan)

	local detail = Inspect.Unit.Detail(unitId)
	if detail then

		local unit = ((unitObject or WT.Units[unitId]) or WT.Unit:Create(unitId)) 
			
		for k,v in pairs(detail) do
			unit[k] = v
		end 
		if not unit.healthMax then 
			unit.partial = true
		else
			unit.partial = false
		end

		if detail["manaMax"] then 
			unit["resourceName"] = "mana"
			unit["resourceText"] = TXT.Mana
			unit["resourceColor"] = { r = 0.1, g = 0.3, b = 1.0, a = 1.0 }
		elseif detail["energyMax"] then 
			unit["resourceName"] = "energy" 
			unit["resourceText"] = TXT.Energy
			unit["resourceColor"] = { r = 1.0, g = 0.0, b = 1.0, a = 1.0 }
		elseif detail["power"] then 
			unit["resourceName"] = "power"
			unit["resourceText"] = TXT.Power
			unit["resourceColor"] = { r = 1.0, g = 1.0, b = 0.0, a = 1.0 }
		else 
			unit["resourceName"] = "" 
			unit["resourceText"] = ""
			unit["resourceColor"] = { r = 1, g = 1, b = 1, a = 1.0 }
		end

		if detail.calling == "mage" then
			unit.callingColor = { r = 0.6, g = 0.0, b = 0.8, a = 1.0 }
			unit.callingText = TXT.Mage
		elseif detail.calling == "cleric" then
			unit.callingColor = { r = 0.0, g = 0.8, b = 0.0, a = 1.0 }
			unit.callingText = TXT.Cleric
		elseif detail.calling == "rogue" then
			unit.callingColor = { r = 0.7, g = 0.6, b = 0.0, a = 1.0 }
			unit.callingText = TXT.Rogue
		elseif detail.calling == "warrior" then
			unit.callingColor = { r = 0.8, g = 0.0, b = 0.0, a = 1.0 }
			unit.callingText = TXT.Warrior
		else
			unit.callingColor = { r = 0.2, g = 0.4, b = 0.6, a = 1.0 }
			unit.callingText = ""
		end

		if unit.name:len() > 14 then
			unit.nameShort = unit.name:sub(1, 12) .. "..."
		else
			unit.nameShort = unit.name
		end

		-- remap the coordinate fields into a single table property
		unit.coord = { detail.coordX or 0, detail.coordY or 0, detail.coordZ or 0 }
		WT.Units[unitId] = unit
		
		if not unit.Buffs then unit.Buffs = {} end
		
		-- Fire player available if required
		if unitId == Inspect.Unit.Lookup("player") then 
			WT.Player = unit
			if not playerAvailableFired then
				WT.Event.Trigger.PlayerAvailable()
				playerAvailableFired = true
			end 
		end

		if unitId == Inspect.Unit.Lookup("player.target") then
			unit.playerTarget = true
		end 
		
		
		-- Add all buffs currently on the unit
		if not omitBuffScan then
			OnBuffRemove(unitId, unit.Buffs)
			OnBuffAdd(unitId, Inspect.Buff.List(unitId))
		end
			
		local needsCleanse = false	
		for buffId, buffDetail in pairs(unit.Buffs) do	
			if buffDetail.curse or buffDetail.disease or buffDetail.poison then
				needsCleanse = true
			end
		end
		unit.cleansable = needsCleanse
				
		return unit
	else
		return nil
	end
end


function WT.UnitDatabase.GetUnit(unitId)

	if WT.Units[unitId] then 
		return WT.Units[unitId]
	else
		return PopulateUnit(unitId)
	end 
	
end

local function OnUnitAvailablePartial(units)
	for unitId, spec in pairs(units) do
		if not WT.Units[unitId] then
			local unit = PopulateUnit(unitId, nil, true)
			if unit then 
				WT.Event.Trigger.UnitAdded(unitId) 	
			end
		else
			WT.Units[unitId].partial = true
		end
	end		
end

local function OnUnitAvailable(units)
	for unitId, spec in pairs(units) do		
		local unit = PopulateUnit(unitId)
		if unit then
			WT.Event.Trigger.UnitAdded(unitId)			
		end
	end
end

local function OnUnitUnavailable(units)
	for unitId in pairs(units) do
		WT.Units[unitId] = nil
		WT.Event.Trigger.UnitRemoved(unitId)
	end
end


-- Sets the property against the relevant unit in the database
local function SetProperty(unitId, property, value)
	if WT.Units[unitId] then
		if property == "healthMax" and WT.Units[unitId].partial then
			-- We now have the full detail for a partially populated unit 
			WT.Units[unitId].partial = false -- we clear the partial details flag when we get healthMax
			PopulateUnit(unitId, WT.Units[unitId]) 
		end 
		WT.Units[unitId][property] = value	
	end
end

local function OnUnitDetailAbsorb(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "absorb", value) end
end

local function OnUnitDetailHealth(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "health", value) end
end

local function OnUnitDetailHealthCap(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "healthCap", value) end
end

local function OnUnitDetailHealthMax(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "healthMax", value) end
end

local function OnUnitDetailMana(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "mana", value) end
end

local function OnUnitDetailManaMax(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "manaMax", value) end
end

local function OnUnitDetailPower(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "power", value) end
end

local function OnUnitDetailEnergy(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "energy", value) end
end

local function OnUnitDetailEnergyMax(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "energyMax", value) end
end

local function OnUnitDetailCharge(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "charge", value) end
end

local function OnUnitDetailChargeMax(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "chargeMax", value) end
end

local function OnUnitDetailAfk(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "afk", value) end
end

local function OnUnitDetailAggro(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "aggro", value) end
end

local function OnUnitDetailBlocked(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "blocked", value) end
end

local function OnUnitDetailCombat(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "combat", value) end
end

local function OnUnitDetailCombo(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "combo", value) end
end

local function OnUnitDetailComboUnit(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "comboUnit", value) end
end

local function OnUnitDetailGuild(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "guild", value) end
end

local function OnUnitDetailLevel(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "level", value) end
end

local function OnUnitDetailLocationName(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "locationName", value) end
end

local function OnUnitDetailMark(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "mark", value) end
end

local function OnUnitDetailName(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "name", value) end
end

local function OnUnitDetailOffline(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "offline", value) end
end

local function OnUnitDetailPlanar(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "planar", value) end
end

local function OnUnitDetailPlanarMax(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "planarMax", value) end
end

local function OnUnitDetailPublicSize(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "publicSize", value) end
end

local function OnUnitDetailPvp(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "pvp", value) end
end

local function OnUnitDetailReady(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "ready", value) end
end

local function OnUnitDetailRole(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "role", value) end
end

local function OnUnitDetailTagged(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "tagged", value) end
end

local function OnUnitDetailTitlePrefix(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefix", value) end
end

local function OnUnitDetailTitlePrefixId(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefixId", value) end
end

local function OnUnitDetailTitlePrefixName(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titlePrefixName", value) end
end

local function OnUnitDetailTitleSuffix(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffix", value) end
end

local function OnUnitDetailTitleSuffixId(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffixId", value) end
end

local function OnUnitDetailTitleSuffixName(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "titleSuffixName", value) end
end

local function OnUnitDetailVitality(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "vitality", value) end
end

local function OnUnitDetailWarfront(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "warfront", value) end
end

local function OnUnitDetailZone(unitsValue)
	for unitId,value in pairs(unitsValue) do SetProperty(unitId, "zone", value) end
end

local function OnUnitDetailCoord(xValues, yValues, zValues)
	local maps = {}	
	for unitId,value in pairs(xValues) do
		maps[unitId] = {}
		table.insert(maps[unitId], value)
	end
	for unitId,value in pairs(yValues) do
		table.insert(maps[unitId], value)
	end
	for unitId,value in pairs(zValues) do
		table.insert(maps[unitId], value)
	end
	for unitId,map in pairs(maps) do
		SetProperty(unitId, "coord", {map[1],map[2],map[3]}) -- create an additional property to allow single property position tracking
		SetProperty(unitId, "coordX", map[1])
		SetProperty(unitId, "coordY", map[2])
		SetProperty(unitId, "coordZ", map[3])
	end
end

local lastRangeCalc = nil
local rangeThrottle = 0.5

local function CalculateRanges()

	if (lastRangeCalc and ((Inspect.Time.Frame() - lastRangeCalc) < rangeThrottle)) then
		return
	end

	lastRangeCalc = Inspect.Time.Frame()

	if not WT.Player or not WT.Player.coord then return end

	local px = WT.Player.coord[1]
	local py = WT.Player.coord[2]
	local pz = WT.Player.coord[3]
	
	for unitId,details in pairs(WT.Units) do
	
	    -- Force a recalculation of the cleansable status
	    WT.Unit.UpdateCleanseStatus(details)
	
		if details.coord then
		
			local ux = details.coord[1] 			
			local uy = details.coord[2] 			
			local uz = details.coord[3]

			local radiusDiff = (WT.Player.radius or 0.5) + (details.radius or 0.5)	
		
			local dx = px - ux  			
			local dy = py - uy 			
			local dz = pz - uz			

			local rangeSqr = (dx * dx + dy * dy + dz * dz)
			local oor = not (rangeSqr < ((35+radiusDiff)*(35+radiusDiff)))
			
			if oor and not details.outOfRange then
				details.outOfRange = true
			end
			if not oor and details.outOfRange then
				details.outOfRange = nil
			end
			
			local blocked = details.blocked or details.outOfRange
			if not details.blockedOrOutOfRange and blocked then
				details.blockedOrOutOfRange = true
			end
			if details.blockedOrOutOfRange and not blocked then
				details.blockedOrOutOfRange = nil
			end
			
			details.rangeSqr = rangeSqr
			details.range = math.sqrt(rangeSqr)
			
		end
	end
end

local function OnSystemUpdateBegin()
	CalculateCastChanges()
	CalculateRanges()
end

-- Setup Event Handlers
table.insert(Event.Unit.Availability.Full,		{ OnUnitAvailable, AddonId, AddonId .. "_OnUnitAvailable" })
table.insert(Event.Unit.Availability.Partial,	{ OnUnitAvailablePartial, AddonId, AddonId .. "_OnUnitAvailablePartial" })
table.insert(Event.Unit.Availability.None,		{ OnUnitUnavailable, AddonId, AddonId .. "_OnUnitUnavailable" })


-- Register the handlers that will deal with groups being added and removed
local groupMode = "solo"
local groupExists = { }

local function OnGroupMemberChange(unitId)
	local g = {}
	for i = 1,20 do
		local grpid = math.floor(((i-1)/5)+1)
		local uid = Inspect.Unit.Lookup("group" .. string.format("%02d", i))
		if uid then
			g[grpid] = true
		end  
	end
	for grp = 1,4 do
		if g[grp] and not groupExists[grp] then 
			groupExists[grp] = true
			WT.Event.Trigger.GroupAdded(grp)
		end
		if not g[grp] and groupExists[grp] then 
			groupExists[grp] = false
			WT.Event.Trigger.GroupRemoved(grp)
		end
	end

	local mode = "solo"
	if groupExists[1] then mode = "party" end
	if groupExists[2] then mode = "raid10" end
	if groupExists[3] or groupExists[4] then mode = "raid20" end
	
	if mode ~= groupMode then
		local oldMode = groupMode
		groupMode = mode
		WT.Event.Trigger.GroupModeChanged(groupMode, oldMode) -- changed(newMode, oldMode)			
	end 

end

WT.RegisterInitializer(OnGroupMemberChange)

local groupEventTables = {}
for i = 1,20 do 
	groupEventTables[i] = Library.LibUnitChange.Register("group" .. string.format("%02d", i))
	table.insert(groupEventTables[i], { OnGroupMemberChange, AddonId, "OnGroupMemberChange" } )
end


function WT.GroupExists(groupId)
	if groupExists[groupId] then
		return true
	else
		return false
	end
end

function WT.GetGroupMode()
	return groupMode
end


local playerTargetId = nil
local function OnPlayerTargetChange(unitId)
	if playerTargetId and WT.Units[playerTargetId] then
		WT.Units[playerTargetId].playerTarget = nil
	end
	playerTargetId = unitId
	if playerTargetId and WT.Units[playerTargetId] then
		WT.Units[playerTargetId].playerTarget = true
	end	
end


-- Register the event handlers for every changeable property

-- Env 1.11+ Only
if Event.Unit.Detail.Absorb then
	table.insert(Event.Unit.Detail.Absorb,			{ OnUnitDetailAbsorb, AddonId, AddonId .. "_OnUnitDetailAbsorb" })
end

table.insert(Event.Unit.Detail.Afk,				{ OnUnitDetailAfk, AddonId, AddonId .. "_OnUnitDetailAfk" })
table.insert(Event.Unit.Detail.Aggro,			{ OnUnitDetailAggro, AddonId, AddonId .. "_OnUnitDetailAggro" })
table.insert(Event.Unit.Detail.Blocked,			{ OnUnitDetailBlocked, AddonId, AddonId .. "_OnUnitDetailBlocked" })
table.insert(Event.Unit.Detail.Charge,			{ OnUnitDetailCharge, AddonId, AddonId .. "_OnUnitDetailCharge" })
table.insert(Event.Unit.Detail.ChargeMax,		{ OnUnitDetailChargeMax, AddonId, AddonId .. "_OnUnitDetailChargeMax" })
table.insert(Event.Unit.Detail.Combat,			{ OnUnitDetailCombat, AddonId, AddonId .. "_OnUnitDetailCombat" })
table.insert(Event.Unit.Detail.Combo,			{ OnUnitDetailCombo, AddonId, AddonId .. "_OnUnitDetailCombo" })
table.insert(Event.Unit.Detail.Energy,			{ OnUnitDetailEnergy, AddonId, AddonId .. "_OnUnitDetailEnergy" })
table.insert(Event.Unit.Detail.EnergyMax,		{ OnUnitDetailEnergyMax, AddonId, AddonId .. "_OnUnitDetailEnergyMax" })
table.insert(Event.Unit.Detail.Guild,			{ OnUnitDetailGuild, AddonId, AddonId .. "_OnUnitDetailGuild" })
table.insert(Event.Unit.Detail.Health,			{ OnUnitDetailHealth, AddonId, AddonId .. "_OnUnitDetailHealth" })
table.insert(Event.Unit.Detail.HealthCap,		{ OnUnitDetailHealthCap, AddonId, AddonId .. "_OnUnitDetailHealthCap" })
table.insert(Event.Unit.Detail.HealthMax,		{ OnUnitDetailHealthMax, AddonId, AddonId .. "_OnUnitDetailHealthMax" })
table.insert(Event.Unit.Detail.Level,			{ OnUnitDetailLevel, AddonId, AddonId .. "_OnUnitDetailLevel" })
table.insert(Event.Unit.Detail.LocationName,	{ OnUnitDetailLocationName, AddonId, AddonId .. "_OnUnitDetailLocationName" })
table.insert(Event.Unit.Detail.Mana,			{ OnUnitDetailMana, AddonId, AddonId .. "_OnUnitDetailMana" })
table.insert(Event.Unit.Detail.ManaMax,			{ OnUnitDetailManaMax, AddonId, AddonId .. "_OnUnitDetailManaMax" })
table.insert(Event.Unit.Detail.Mark,			{ OnUnitDetailMark, AddonId, AddonId .. "_OnUnitDetailMark" })
table.insert(Event.Unit.Detail.Name,			{ OnUnitDetailName, AddonId, AddonId .. "_OnUnitDetailName" })
table.insert(Event.Unit.Detail.Offline,			{ OnUnitDetailOffline, AddonId, AddonId .. "_OnUnitDetailOffline" })
table.insert(Event.Unit.Detail.Planar,			{ OnUnitDetailPlanar, AddonId, AddonId .. "_OnUnitDetailPlanar" })
table.insert(Event.Unit.Detail.PlanarMax,		{ OnUnitDetailPlanarMax, AddonId, AddonId .. "_OnUnitDetailPlanarMax" })
table.insert(Event.Unit.Detail.Power,			{ OnUnitDetailPower, AddonId, AddonId .. "_OnUnitDetailPower" })
table.insert(Event.Unit.Detail.PublicSize,		{ OnUnitDetailPublicSize, AddonId, AddonId .. "_OnUnitDetailPublicSize" })
table.insert(Event.Unit.Detail.Pvp,				{ OnUnitDetailPvp, AddonId, AddonId .. "_OnUnitDetailPvp" })
table.insert(Event.Unit.Detail.Ready,			{ OnUnitDetailReady, AddonId, AddonId .. "_OnUnitDetailReady" })
table.insert(Event.Unit.Detail.Role,			{ OnUnitDetailRole, AddonId, AddonId .. "_OnUnitDetailRole" })
table.insert(Event.Unit.Detail.Tagged,			{ OnUnitDetailTagged, AddonId, AddonId .. "_OnUnitDetailTagged" })
table.insert(Event.Unit.Detail.TitlePrefixId,	{ OnUnitDetailTitlePrefixId, AddonId, AddonId .. "_OnUnitDetailTitlePrefixId" })
table.insert(Event.Unit.Detail.TitleSuffixId,	{ OnUnitDetailTitleSuffixId, AddonId, AddonId .. "_OnUnitDetailTitleSuffixId" })
table.insert(Event.Unit.Detail.Vitality,		{ OnUnitDetailVitality, AddonId, AddonId .. "_OnUnitDetailVitality" })
table.insert(Event.Unit.Detail.Warfront,		{ OnUnitDetailWarfront, AddonId, AddonId .. "_OnUnitDetailWarfront" })
table.insert(Event.Buff.Add,					{ OnBuffAdd, AddonId, AddonId .. "_OnBuffAdd" })
table.insert(Event.Buff.Change,					{ OnBuffChange, AddonId, AddonId .. "_OnBuffChange" })
table.insert(Event.Buff.Remove,					{ OnBuffRemove, AddonId, AddonId .. "_OnBuffRemove" })
table.insert(Event.Unit.Castbar,				{ OnUnitCastbar, AddonId, AddonId .. "_OnUnitCastbar" })
table.insert(Event.Unit.Detail.Zone,			{ OnUnitDetailZone, AddonId, AddonId .. "_OnUnitDetailZone" })
table.insert(Event.Unit.Detail.Coord,			{ OnUnitDetailCoord, AddonId, AddonId .. "_OnUnitDetailCoord" })

table.insert(Event.System.Update.Begin,			{ OnSystemUpdateBegin, AddonId, AddonId .. "_DB_OnSystemUpdateBegin" })


table.insert(Library.LibUnitChange.Register("player.target"), { OnPlayerTargetChange,  AddonId, AddonId .. "_OnPlayerTargetChange" })