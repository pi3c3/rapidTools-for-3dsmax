macroScript FastWorkingPivot Category:"pi3c3's Scripts" toolTip:"FastWorkingPivot" (

function facesAverageNormal = (
	
	normalsAddArray = [0,0,0]
	
	CurrentMod = modpanel.getCurrentObject()
	CurrentMod = CurrentMod as string
	
	if CurrentMod == "Edit_Poly:Edit Poly" do (
		facesSelected = $.modifiers[#Edit_Poly].getselection #Face	
		facesSelected = facesSelected as array
	
		for i = 1 to facesSelected.count do (
			normalsAddArray = normalsAddArray + $.modifiers[#Edit_Poly].getFaceNormal facesSelected[i]
	)
	
	y = normalsAddArray.y
	z = normalsAddArray.z
	normalsAddArray.z = y
	normalsAddArray.y = -1*z
)

	if CurrentMod == "Editable Poly" do (
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
)