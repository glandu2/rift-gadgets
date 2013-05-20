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

data.wtHealer = data.wtHealer or {}


local function OnChange_Aggro(frame, value)
	local gadget = frame.gadget
	local config = gadget.healerConfig
	if config.showAggroBorder then
		if value then
			frame.Elements["aggroBorder"]:SetBackgroundColor(GX.Settings.Colors.Aggro)
		else
			frame.Elements["aggroBorder"]:SetBackgroundColor(GX.Constants.Colors.Black)
		end
	end
end

local function OnChange_Calling(frame, value)
end

local function OnChange_Combat(frame, value)
end

local function OnChange_Dead(frame, value)
end

local function OnChange_ResourceName(frame, value)
end

local function OnChange_PlayerTarget(frame, value)
end


function data.wtHealer.RegisterForChanges(uf)
	uf:CreateBinding("aggro", uf, OnChange_Aggro)
	uf:CreateBinding("calling", uf, OnChange_Calling)
	uf:CreateBinding("combat", uf, OnChange_Combat)
	uf:CreateBinding("dead", uf, OnChange_Dead)
	uf:CreateBinding("resourceName", uf, OnChange_ResourceName)
	uf:CreateBinding("playerTarget", uf, OnChange_PlayerTarget)
end
