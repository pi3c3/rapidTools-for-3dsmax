--macroScript FastWorkingPivot Category:"rapidTools" toolTip:"FastWorkingPivot" (

function facesAverageNormal = (

	setCommandPanelTaskMode #modify	
	normalsAddArray = [0,0,0]
	
	if classOf $ == Edit_Poly do (
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		facesSelected = $.modifiers[currentModIndex].getselection #Face	
		facesSelected = facesSelected as array
	
		for i = 1 to facesSelected.count do (
			normalsAddArray = normalsAddArray + $.modifiers[currentModIndex].getFaceNormal facesSelected[i]
	)
	
	y = normalsAddArray.y
	z = normalsAddArray.z
	normalsAddArray.z = y
	normalsAddArray.y = -1*z
)

	if classOf $ == Editable_Poly do (
		facesSelected = polyop.getFaceSelection $
		facesSelected = facesSelected as array
	
		for i = 1 to facesSelected.count do (
			normalsAddArray = normalsAddArray + polyop.getFaceNormal $ facesSelected[i]
	)
)

	normalsAveraged = normalsAddArray / [facesSelected.count,facesSelected.count,facesSelected.count]
	return normalsAveraged
)

function alignWorkingPivot theNormal = (
	theNormal = matrixFromNormal theNormal
	WorkingPivot.setTM theNormal
)
	
	averageVector = facesAverageNormal()
	alignWorkingPivot averageVector
	toolMode.coordsys #working_pivot
--)