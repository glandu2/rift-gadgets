--[[ 
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

WT.Gadget.Command = {}

local TXT = Library.Translate

function WT.Gadget.Command.add()
	if WT.Gadget.isSecure then
		print(TXT.CannotAlterGadgetsInCombat)
		return
	end
	WT.Gadget.ShowCreationUI()
end

function WT.Gadget.Command.copy(gadgetId)
	WT.Gadget.Copy(gadgetId)
end

function WT.Gadget.Command.list()
	for gadgetId,config in pairs(wtxGadgets) do
		print(string.format("Gadget: %s (%s)", gadgetId, config.type)) 
	end
end

function WT.Gadget.Command.delete(gadgetId)
	WT.Gadget.Delete(gadgetId)
end


function WT.Gadget.Command.modify(gadgetId)
	WT.Gadget.Modify(gadgetId)
end


function WT.Gadget.Command.reset()
	WT.Gadget.ResetButton()
end


function WT.Gadget.Command.unlock()
	WT.Gadget.UnlockAll()
end

function WT.Gadget.Command.lock()
	WT.Gadget.LockAll()
end

function WT.Gadget.Command.toggle()
	WT.Gadget.ToggleAll()
end


function WT.Gadget.OnSlashCommand(cmd)
	local words = {}
	for word in string.gmatch(cmd, "[^%s]+") do table.insert(words, word) end
	local numWords = table.getn(words)
	if numWords > 0 then
		local command = string.lower(words[1])
		local args = {}
		for i = 2, numWords do table.insert(args, words[i]) end
		WT.Log.Debug("Command received: " .. command .. " with " .. table.getn(args) .. " args")
		if WT.Gadget.Command[command] then
			WT.Gadget.Command[command](unpack(args))
		end
	end
end

table.insert(Command.Slash.Register("gadget"), { WT.Gadget.OnSlashCommand, AddonId, AddonId .. "_OnSlashCommand" })
