macroScript FaceWorkingPivot Category:"pi3c3's Scripts" toolTip:"FastWorkingPivot" (

global selectedFaceNormal = [0,0,0]
	
	function faceNormalVector = (

	faceSelected = polyop.getFaceSelection $
	faceSelected = faceSelected as array
	
	if faceSelected.count == 1 then (
		selectedFaceNormal = polyop.getFaceNormal $ faceSelected[1]
		)
		else (messageBox "Please select a single face!")
	)

	function alignWorkingPivot = (

	selectedFaceNormal = matrixFromNormal selectedFaceNormal
	WorkingPivot.setTM selectedFaceNormal
	)

	faceNormalVector()
	alignWorkingPivot()
	toolMode.coordsys #working_pivot
)

toolMode.coordsys #view