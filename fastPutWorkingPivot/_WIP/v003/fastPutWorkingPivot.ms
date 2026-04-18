--macroScript PutWorkingPivot Category:"rapidTools" toolTip:"PutWorkingPivot" (

	function getSubobjectPosition = (
		selectedVertices = polyop.getVertSelection $ as array
		positionArray = #()
		sumPosition = [0,0,0]
		
		for i = 1 to selectedVertices.count do (
			sumPosition = sumPosition + polyop.getVert $ selectedVertices[i]
		)
		
		averagePosition = sumPosition / [selectedVertices.count,selectedVertices.count,selectedVertices.count]
		
		return averagePosition
	)

	function getSubobjectPositionEP = (
		
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		polyopEP = $.modifiers[currentModIndex]
		selectedVertices = polyopEP.getSelection #Vertex as array
		positionArray = #()
		sumPosition = [0,0,0]
		
		for i = 1 to selectedVertices.count do (
			sumPosition = sumPosition + polyopEP.getVertex selectedVertices[i]
		)
		
		averagePosition = sumPosition / [selectedVertices.count,selectedVertices.count,selectedVertices.count]
		
		return averagePosition
	)

	function putWPivot = (
		
		setCommandPanelTaskMode #modify	
		currentMod = modPanel.getCurrentObject()
		
		avgP3 = [0,0,0]
		
		if classOf currentMod == Editable_Poly do (
			avgP3 =  getSubobjectPosition()
		)
		
		if classOf currentMod == Edit_Poly do (
			avgP3 =  getSubobjectPositionEP()
		)	
		
		avgTM = transMatrix avgP3
		WorkingPivot.setTM avgTM
		WorkingPivot.UseMode = true
	)

	if $ != undefined then (
		if WorkingPivot.UseMode == false then (
			putWPivot()
		)
		else (
			WorkingPivot.UseMode = false
		)
	)
	else (
		print "Please select an Editable Poly object!"
	)
--)