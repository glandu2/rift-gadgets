local lang = WT.Strings.Language

-- Only load Korean strings if client is set to French
if lang ~= "ko" then return end

-- *** Needs translation

WT.Strings.Load("ko", 
{
	Mana 		= "Mana",
	Energy 		= "Energy",
	Power 		= "Power",
	Charge 		= "Charge",
	Health 		= "Health",
	Mage		= "Mage",
	Cleric		= "Cleric",
	Rogue		= "Rogue",
	Warrior		= "Warrior",
})
