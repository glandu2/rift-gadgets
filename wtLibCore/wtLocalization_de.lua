local lang = WT.Strings.Language

-- Only load German strings if client is set to French
if lang ~= "de" then return end

-- *** Needs translation

WT.Strings.Load("de", 
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
