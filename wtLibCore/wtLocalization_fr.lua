local lang = WT.Strings.Language

-- Only load French strings if client is set to French
if lang ~= "fr" then return end

-- *** Needs translation 

WT.Strings.Load("fr", 
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
