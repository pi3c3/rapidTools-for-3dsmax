--macroScript Bridge category:"rapidTools" tooltip:"Bridge" (
		
	setCommandPanelTaskMode #modify
	CurrentMod = modpanel.getCurrentObject()
	
	if classOf CurrentMod == Editable_Poly do (
		$.bridgeSelected = 1
		$.EditablePoly.Bridge ()
	)
	
	if classOf CurrentMod == Edit_Poly do (
		theMod = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		if subobjectlevel == 4 do $.modifiers[theMod].ButtonOp #BridgePolygon
		if subobjectlevel == 3 do $.modifiers[theMod].ButtonOp #BridgeBorder
		if subobjectlevel == 2 do $.modifiers[theMod].ButtonOp #BridgeEdge
	)
		
--)