local theme = {} 
WT.Themes["subtle"] = theme

theme.gadgetOverlay = 
{
	overlayColor = {1,1,1,0.2},
	
	topLeft = 
	{
		addonId = "wtLibGadget",
		image = "themes/subtle/GadgetCornerTL.png",
		alignmentModeImage = "themes/subtle/GadgetCornerTL_Lit.png",
	},
	
	topRight =
	{
		addonId = "wtLibGadget",
		image = "themes/subtle/GadgetCornerTR.png",
	},
	
	bottomLeft =
	{
		addonId = "wtLibGadget",
		image = "themes/subtle/GadgetCornerBL.png",
	},
	
	bottomRight = 
	{
		addonId = "wtLibGadget",
		image = "themes/subtle/GadgetCornerBR.png",
		resizableImage = "themes/subtle/GadgetCornerBR_Resize.png",
	},
}