--macroScript FastWorkingPivot Category:"rapidTools" toolTip:"FastWorkingPivot" (

function facesAverageNormal = (

	setCommandPanelTaskMode #modify	
	currentMod = modPanel.getCurrentObject()
	
	normalsAddArray = [0,0,0]
	
	if classOf currentMod == Edit_Poly do (
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		facesSelected = $.modifiers[currentModIndex].getselection #Face	
		facesSelected = facesSelected as array
		
		for i = 1 to facesSelected.count do (
			normalsAddArray = normalsAddArray + $.modifiers[currentModIndex].getFaceNormal facesSelected[i]
		)
	
	y = normalsAddArray.y
	z = normalsAddArray.z
	normalsAddArray.z = y
	normalsAddArray.y = z
	
	)

	if classOf currentMod == Editable_Poly do (
		facesSelected = polyop.getFaceSelection $
		facesSelected = facesSelected as array
	
		for i = 1 to facesSelected.count do (
			normalsAddArray = normalsAddArray + polyop.getFaceNormal $ facesSelected[i]
		)
	)

	normalsAveraged = normalsAddArray / [facesSelected.count,facesSelected.count,facesSelected.count]
	return normalsAveraged
)

function edgeToNormal = (
	setCommandPanelTaskMode #modify	
	currentMod = modpanel.getCurrentObject()
	
	local direction 
	
	if classOf currentMod == Editable_Poly then (
		a = polyop.getEdgeSelection $
		b = polyop.getVertsUsingEdge $ a

		v1 = polyop.getVert $ (b as array)[1]
		v2 = polyop.getVert $ (b as array)[2]
		global direction = v1 - v2
	)
		
	else if classOf currentMod == Edit_Poly then (
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())	
		
		a = (($.modifiers[currentModIndex].getSelection #edge) as array)[1]
		b = $.modifiers[currentModIndex].GetEdgeVertex a 1
		c = $.modifiers[currentModIndex].GetEdgeVertex a 2

		v1EP = $.modifiers[currentModIndex].getVertex b
		v2EP = $.modifiers[currentModIndex].getVertex c
		direction = v1EP - v2EP
	)
	return direction
)

function splineSegToNormal = (

	splines = numSplines $
	theSegment = #()
	local a
	local b
	for i = 1 to splines do (
		seg = getSegSelection $ i
		append theSegment seg[1]
	)
	
	theSegmentCount = theSegment.count
	
	for i = 1 to theSegmentCount do (
		if theSegment[i] != undefined then (
			a = getKnotPoint $ i theSegment[i]
			b = getKnotPoint $ i (theSegment[i]+1)
		)
	)
	direction = a - b

	return direction
)

function alignWorkingPivot theDirection = (
	theDirection = matrixFromNormal (normalize theDirection)
	WorkingPivot.setTM theDirection
)

---------------------------------------- PROGRAM FLOW ----------------------------------------

if subobjectlevel == 4 then (
	dirVector = facesAverageNormal()
	alignWorkingPivot dirVector
	toolMode.coordsys #working_pivot
)
else if subobjectlevel == 2 then (
	if classof $ == Edit_poly or classof $ == Editable_Poly then (
		dirVector = edgeToNormal()
	)
	else if classof $ == SplineShape or classof $ == Line then (
		dirVector = splineSegToNormal()
	)
	alignWorkingPivot dirVector
	toolMode.coordsys #working_pivot
)
