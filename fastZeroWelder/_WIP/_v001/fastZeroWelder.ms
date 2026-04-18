--macroScript fastZeroWelder Category:"rapidTools" toolTip:"fastZeroWelder" (
	
	global currentModIndex = undefined
	global currentMod = modpanel.getCurrentObject()
	global verts = #()
	
	function zeroWeld = (
	
	if classOf currentMod == Editable_Poly then (
		$.weldThreshold = 0.001
		verts = polyop.getVertSelection $
		polyop.weldVertsByThreshold $ verts
	)

	else if classOf currentMod == Edit_Poly then (
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())	
		$.modifiers[currentModIndex].weldVertexThreshold = 0.001
		$.modifiers[currentModIndex].ButtonOp #WeldVertex
	)
	
	else (
		print "NYEH"
	)
)
zeroWeld()
--)