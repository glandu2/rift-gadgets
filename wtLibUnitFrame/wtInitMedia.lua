--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- Load all of the built in media -----------------------------------------------------------------
Library.Media.AddTexture("wtBantoBar", AddonId, "img/BantoBar.png", {"bar", "colorize"})
Library.Media.AddTexture("wtDiagonal", AddonId, "img/Diagonal.png", {"bar", "colorize"})
Library.Media.AddTexture("wtGlaze2", AddonId, "img/Glaze2.png", {"bar", "colorize"})
Library.Media.AddTexture("wtHealbot", AddonId, "img/Healbot.png", {"bar", "colorize"})
Library.Media.AddTexture("wtOrbGreen", AddonId, "img/orb_green.tga", {"orb"})
Library.Media.AddTexture("wtOrbBlue", AddonId, "img/orb_blue.tga", {"orb"})
Library.Media.AddTexture("wtReadyCheck", AddonId, "img/wtReady.png", {"imgset", "readycheck"})
Library.Media.AddTexture("wtRankPips", AddonId, "img/wtRankPips.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks24", AddonId, "img/wtRanks24.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks38", AddonId, "img/wtRanks38.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtSweep", AddonId, "img/Sweep.png", {"imgset", "sweep"})

Library.Media.AddTexture("octanusHeal", AddonId, "img/octanusHeal.png", {"roleHeal"})
Library.Media.AddTexture("octanusDPS", AddonId, "img/octanusDPS.png", {"roleDPS"})
Library.Media.AddTexture("octanusTank", AddonId, "img/octanusTank.png", {"roleTank"})
Library.Media.AddTexture("octanusSupport", AddonId, "img/octanusSupport.png", {"roleSupport"})

Library.Media.AddTexture("octanusHP", AddonId, "img/octanusHP.png", {"bar", "healthBar"})
Library.Media.AddTexture("octanusMana", AddonId, "img/octanusMana.png", {"bar", "manaBar"})
Library.Media.AddTexture("octanusEnergy", AddonId, "img/octanusEnergy.png", {"bar", "energyBar"})

Library.Media.AddFont("ArmWrestler", AddonId, "font/ArmWrestler.ttf")
Library.Media.AddFont("Bazooka", AddonId, "font/Bazooka.ttf")
Library.Media.AddFont("BlackChancery", AddonId, "font/BlackChancery.ttf")
Library.Media.AddFont("Collegia", AddonId, "font/Collegia.ttf")
Library.Media.AddFont("Disko", AddonId, "font/Disko.ttf")
Library.Media.AddFont("DorisPP", AddonId, "font/DorisPP.ttf")
Library.Media.AddFont("Enigma", AddonId, "font/Enigma.ttf")
Library.Media.AddFont("LiberationSans", AddonId, "font/LiberationSans.ttf")
Library.Media.AddFont("SFAtarianSystem", AddonId, "font/SFAtarianSystem.ttf")

---------------------------------------------------------------------------------------------------
