global currentModIndex = undefined
global currentMod = modpanel.getCurrentObject()
global polyopEP

if classOf currentMod == Editable_Poly then (

	if subobjectlevel == 1 then (
		$.ConvertSelectionToBorder #vertex #edge
		subobjectlevel = 2
	)
	else if subobjectlevel == 4 do (
		$.ConvertSelectionToBorder #face #edge
		subobjectlevel = 2
	)
)
else if classOf currentMod == Edit_Poly then (
	
	currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())	
	polyopEP = $.modifiers[currentModIndex]
	
	if subobjectlevel == 1 then (
		polyopEP.ConvertSelectionToBorder #vertex #edge
		subobjectlevel = 2
	)
	else if subobjectlevel == 4 do (
		polyopEP.ConvertSelectionToBorder #face #edge
		subobjectlevel = 2
	)
)