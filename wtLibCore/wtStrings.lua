--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	wtStrings provides the localization mechanism, for retrieving strings in the current language
	of the Rift client.
--]]

local toc, data = ...
local AddonId = toc.identifier

-- "English", "French", "German", "Korean", "Russian"
local language = Inspect.System.Language()
local lang = "en"
if language == "French" then lang = "fr" end
if language == "German" then lang = "de" end
if language == "Korean" then lang = "ko" end
if language == "Russian" then lang = "ru" end

WT.Strings = {}
WT.Strings.en = {}
WT.Strings.fr = {}
WT.Strings.de = {}
WT.Strings.ko = {}
WT.Strings.ru = {}

WT.Strings.Language = lang

local lookupSelected = WT.Strings[lang]
local lookupDefault = WT.Strings["en"]

local function stringsRead(tbl, id)
	return (lookupSelected[id]) or (lookupDefault[id]) or ("#" .. id .. "#")
end

setmetatable(WT.Strings, { __index=stringsRead })

function WT.Strings.Load(language, stringList)
	for id,text in pairs(stringList) do
		WT.Strings[language][id] = text
	end
end
