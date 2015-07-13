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


local tooltip = nil

function data.ShowBuffTooltip(unitSpec, buffId)
	if buffId then
		tooltipIcon = buffId
		Command.Tooltip(unitSpec, buffId)
	end
end

function data.HideBuffTooltip(buffId)
	if tooltipIcon == buffId then Command.Tooltip(nil) end
end
