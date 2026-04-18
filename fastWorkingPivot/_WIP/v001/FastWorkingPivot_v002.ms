macroScript FaceWorkingPivot Category:"pi3c3's Scripts" toolTip:"FastWorkingPivot" (
	
/*function faceNormalVector = (

	faceSelected = polyop.getFaceSelection $
	faceSelected = faceSelected as array
	
	selectedFaceNormal = polyop.getFaceNormal $ faceSelected[1]

--	if faceSelected.count == 1 then (
--		selectedFaceNormal = polyop.getFaceNormal $ faceSelected[1]
--		)
--		else (messageBox "Please select a single face!")
		
	return selectedFaceNormal
)
*/

function facesAverageNormal = (
	
	normalsAddArray = [0,0,0]
	
	facesSelected = polyop.getFaceSelection $
	facesSelected = facesSelected as array
	
	for i = 1 to facesSelected.count do (
		normalsAddArray = normalsAddArray + polyop.getFaceNormal $ facesSelected[i]
	)
	
	normalsAveraged = normalsAddArray / [facesSelected.count,facesSelected.count,facesSelected.count]
	return normalsAveraged
)

function alignWorkingPivot theNormal = (

	theNormal = matrixFromNormal theNormal
	WorkingPivot.setTM theNormal
	)

--	singleVector = faceNormalVector()
	averageVector = facesAverageNormal()
	alignWorkingPivot averageVector
	toolMode.coordsys #working_pivot
)

toolMode.coordsys #view



