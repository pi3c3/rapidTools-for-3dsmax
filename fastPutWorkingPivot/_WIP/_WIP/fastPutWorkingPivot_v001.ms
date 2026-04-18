macroScript PutWorkingPivot Category:"rapidTools" toolTip:"PutWorkingPivot" (

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

function putWPivot = (
	avgP3 =  getSubobjectPosition()
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
)