local lang = WT.Strings.Language

-- Only load Russian strings if client is set to French
if lang ~= "ru" then return end

-- *** Needs translation

WT.Strings.Load("ru", 
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
