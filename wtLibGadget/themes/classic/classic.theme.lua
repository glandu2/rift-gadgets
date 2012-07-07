local theme = {} 
WT.Themes["classic"] = theme

theme.gadgetOverlay = 
{
	overlayColor = {1,1,1,0.2},
	
	topLeft = 
	{
		addonId = "wtLibGadget",
		image = "themes/classic/GadgetHandle.png",
		alignmentModeImage = "themes/classic/GadgetHandle_Lit.png",
		offset = {-12, -12},
	},
	
	topRight = nil,
	
	bottomLeft = nil,
	
	bottomRight = 
	{
		addonId = "wtLibGadget",
		image = nil,
		resizableImage = "themes/classic/GadgetResizeHandle.png",
		offset = {2, 2},
	},
}