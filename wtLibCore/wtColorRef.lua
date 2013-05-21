--[[
                                 GX LIBRARY
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : @project-version@
      Project Date (UTC)  : @project-date-iso@
      File Modified (UTC) : @file-date-iso@ (@file-author@)
      -----------------------------------------------------------------     
--]]

--[[
		Note: This file has been borrowed from LibGX and retrofitted
		to Gadgets. It therefore creates the GX namespace if necessary.

		The GX namespace will replace the WT namespace when LibGX is
		complete.
--]]

local toc, data = ...
local AddonId = toc.identifier

GX = GX or {}
GX.Settings = GX.Settings or {}
GX.Settings.Colors = GX.Settings.Colors or {}
GX.Constants = GX.Constants or {}
GX.Constants.Colors = GX.Constants.Colors or {}

local function ColorString(col)
	if col:sub(1, 1) == "#" then
		col = col:sub(2)
	end
	if col:len() == 6 then
		col = "FF" .. col
	end
	if col:len() ~= 8 then
		error("Invalid colour string")
	end

	local ret = {}
	
	ret.a = tonumber(col:sub(1,2), 16) / 255
	ret.r = tonumber(col:sub(3,4), 16) / 255
	ret.g = tonumber(col:sub(5,6), 16) / 255
	ret.b = tonumber(col:sub(7,8), 16) / 255

	--ret[1] = r
	--ret[2] = g
	--ret[3] = b
	--ret[4] = a

	return ret
end

-- Colours are defined as arrays in the order ARGB

GX.Settings.Colors.CallingCleric = ColorString("#77ef00")
GX.Settings.Colors.CallingMage = ColorString("#c85eff")
GX.Settings.Colors.CallingRogue = ColorString("#ffdb00")
GX.Settings.Colors.CallingWarrior = ColorString("#ff2828")
GX.Settings.Colors.CallingNone = ColorString("#446688")

GX.Settings.Colors.ResourceEnergy = ColorString("#cd64da")
GX.Settings.Colors.ResourceMana = ColorString("#46ade8")
GX.Settings.Colors.ResourcePower = ColorString("#d8d24a")

GX.Settings.Colors.FactionGuardian = ColorString("#806fe6")
GX.Settings.Colors.FactionDefiant = ColorString("#368dee")
GX.Settings.Colors.FactionNeutral = ColorString("#bbbab4")

GX.Settings.Colors.RelationHostile = ColorString("#f30000")
GX.Settings.Colors.RelationNeutral = ColorString("#fde72b")
GX.Settings.Colors.RelationFriendly = ColorString("#65e200")

GX.Settings.Colors.ItemTrash = ColorString("#888888")
GX.Settings.Colors.ItemCommon = ColorString("#ffffff")
GX.Settings.Colors.ItemUncommon = ColorString("#00cc00")
GX.Settings.Colors.ItemRare = ColorString("#2681fe")
GX.Settings.Colors.ItemEpic = ColorString("#b049ff")
GX.Settings.Colors.ItemRelic = ColorString("#ff9900")
GX.Settings.Colors.ItemQuest = ColorString("#fff600")

GX.Settings.Colors.DifficultyImpossible = ColorString("#cf1313")
GX.Settings.Colors.DifficultyHard = ColorString("#de8e03")
GX.Settings.Colors.DifficultyMedium = ColorString("#d5c300")
GX.Settings.Colors.DifficultyEasy = ColorString("#51c412")
GX.Settings.Colors.DifficultyTrivial = ColorString("#b4b4b4")

GX.Settings.Colors.Aggro = ColorString("#aa0000")
GX.Settings.Colors.Target = ColorString("#ffffff")

GX.Constants.Colors.Black = ColorString("#000000")
GX.Constants.Colors.White = ColorString("#ffffff")
