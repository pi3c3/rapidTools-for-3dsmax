theObj = $
currentModIndex = undefined
currentMod = modpanel.getCurrentObject()
polyopEP

function getVertEdgesEP theObj theVertex = ( -- Egy Vertex éleit adja vissza, sorrendben
		if 	theVertex != undefined then (
			edgeArrayEP = #()
			i = 1 
			do (
				edgeIndex = theObj.modifiers[currentModIndex].GetVertexEdge theVertex i
				append edgeArrayEP edgeIndex
				i=i+1
			)
			while (edgeIndex != 0)
			deleteItem edgeArrayEP (edgeArrayEP.count)
			return edgeArrayEP
		)
		else return undefined
	)

function getVertFacesEP theObj theVertex = ( -- Egy Vertex éleit adja vissza, sorrendben
	if 	theVertex != undefined then (
		faceArrayEP = #()
		i = 1 
		do (
			faceIndex = theObj.modifiers[currentModIndex].GetVertexFace theVertex i
			append faceArrayEP faceIndex
			i=i+1
		)
		while (faceIndex != 0)
		deleteItem faceArrayEP (faceArrayEP.count)
		return faceArrayEP
	)
	else return undefined
)

function getFaceVerticesEP theObj theFace = ( -- EGY FACE VERTEXEIT ADJA VISSZA -- FACE A BEMENET INTEGER
	if 	theFace != undefined then (
		vertArrayEP = #()
		i = 1 
		do (
			vertIndex = theObj.modifiers[currentModIndex].GetFaceVertex theFace i
			append vertArrayEP vertIndex
			i=i+1
		)
		while (vertIndex != 0)
		deleteItem vertArrayEP (vertArrayEP.count)
		return vertArrayEP
	)
	else return undefined
)

function getFaceEdgesEP theObj theFace = ( -- Egy Face éleit adja vissza sorrendben
	if 	theFace != undefined then (
		edgeArrayEP = #()
		i = 1 
		do (
			edgeIndex = theObj.modifiers[currentModIndex].GetFaceEdge theFace i
			append edgeArrayEP edgeIndex
			i=i+1
		)
		while (edgeIndex != 0)
		deleteItem edgeArrayEP (edgeArrayEP.count)
		return edgeArrayEP
	)
	else return undefined
)

function getVertEdgesEP theObj theVertex = ( -- Egy Vertex éleit adja vissza, sorrendben
	if 	theVertex != undefined then (
		edgeArrayEP = #()
		i = 1 
		do (
			edgeIndex = theObj.modifiers[currentModIndex].GetVertexEdge theVertex i
			append edgeArrayEP edgeIndex
			i=i+1
		)
		while (edgeIndex != 0)
		deleteItem edgeArrayEP (edgeArrayEP.count)
		return edgeArrayEP
		)
	else return undefined
)

function getEdgeVertsEP theObj theEdge = ( -- Egy Vertex éleit adja vissza, sorrendben
	if 	theEdge != undefined then (
		vertArrayEP = #()
		getEdgeVert = theObj.modifiers[currentModIndex].GetEdgeVertex
		i = 1 
		do (
			edgeIndex = getEdgeVert theEdge i
			append vertArrayEP edgeIndex
			i=i+1
		)
		while (edgeIndex != 0)
		deleteItem vertArrayEP (vertArrayEP.count)
		return vertArrayEP
		)
	else return undefined
)

function getEdgeFacesEP theObj theEdge = ( -- Egy él vertexeit adja vissza sorrendben
	if 	theEdge != undefined then (
		faceArrayEP = #()
		getEdgeFace = theObj.modifiers[currentModIndex].GetEdgeFace
		i = 1 
		do (
			edgeIndex = getEdgeFace theEdge i
			append faceArrayEP edgeIndex
			i=i+1
		)
		while (edgeIndex != 0)
		deleteItem faceArrayEP (faceArrayEP.count)
		return faceArrayEP
		)
	else return undefined
)

function getVertsUsingEdgeEP theObj theEdges = (
	theVertices = #()
	theEdges = theEdges as array
	theEdgesCount = theEdges.count
	for i = 1 to theEdgesCount do (
		theVertices = theVertices + (getEdgeVertsEP theObj theEdges[i])
	)
	return theVertices as bitarray
)

function getEdgesUsingVertEP theObj theVerts = (
	theEdges = #()
	theVerts = theVerts as array
	theVertsCount = theVerts.count
	for i = 1 to  theVertsCount do (
		theEdges = theEdges + (getVertEdgesEP theObj theVerts[i])
	)
	return theEdges as bitarray
)

function getFacesUsingVertEP theObj theVerts = (
	theFaces = #()
	theVerts = theVerts as array
	theVertsCount = theVerts.count
	for i = 1 to  theVertsCount do (
		theFaces = theFaces + (getVertFacesEP theObj theVerts[i])
	)
	return theFaces as bitarray
)

function getFacesUsingEdgeEP theObj theEdges = (
	theFaces = #()
	theEdges = theEdges as array
	theEdgesCount = theEdges.count
	for i = 1 to  theEdgesCount do (
		theFaces = theFaces + (getEdgeFacesEP theObj theEdges[i])
	)
	return theFaces as bitarray
)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if classOf currentMod == Editable_Poly then (

	if subobjectlevel == 1 then (
		theObj.ConvertSelectionToBorder #vertex #edge
		subobjectlevel = 2
	)
	else if subobjectlevel == 4 do (
		theObj.ConvertSelectionToBorder #face #edge
		subobjectlevel = 2
	)

	if fastPanelizer != undefined then (
		theWidth = fastPanelizer.width.value
		theHeight = fastPanelizer.height.value
	)
	else (
		theWidth = 0
		theHeight = -3.0
	)
	
	theObj.edgeExtrudeHeight = theHeight -- world units; Edge_Extrude_Height
	theObj.edgeExtrudeWidth = theWidth -- float; Edge_Extrude_Width
	theObj.EditablePoly.buttonOp #Extrude

	mainEdges = polyop.getEdgeSelection theObj
	innerFaces = polyop.getFacesUsingEdge theObj (polyop.getEdgesUsingVert theObj (polyop.getVertsUsingEdge theObj (polyop.getEdgeSelection theObj)))
	polyop.setFaceSelection theObj innerFaces
	theObj.convertSelectionToBorder #face #edge
	topEdges = polyop.getEdgeSelection theObj

	topEdges = topEdges as array
	topEdgesCount = topEdges.count
	cornerEdges = #()
	nPoles = #()
	for i = 1 to topEdgesCount do (
		faces = polyop.getEdgeFaces theObj topEdges[i]
		
		faceDeg = #()
		for j = 1 to faces.count do (
			append faceDeg (polyop.getFaceDeg theObj faces[j])
		)

		if (faceDeg[1] == 3 or faceDeg[1] >= 5) and (faceDeg[2] >= 5 or faceDeg[2] == 3) then (
			append cornerEdges topEdges[i]
		)
	)

	polyop.collapseEdges theObj cornerEdges
	polyop.setEdgeSelection theObj mainEdges --Alsó elvágandó él lista
	sideFaces = polyop.getFacesUsingEdge theObj mainEdges -- alsó elvágandó élek vertexei
	theObj.autoSmoothThreshold = 45
	polyop.autoSmooth theObj
	polyop.splitEdges theObj mainEdges
)

else if classOf currentMod == Edit_Poly then (
	
	currentModIndex = modPanel.getModifierIndex theObj (modPanel.getCurrentObject())	
	polyopEP = theObj.modifiers[currentModIndex]
	
	if subobjectlevel == 1 then (
		polyopEP.ConvertSelectionToBorder #vertex #edge
		subobjectlevel = 2
	)
	else if subobjectlevel == 4 do (
		polyopEP.ConvertSelectionToBorder #face #edge
		subobjectlevel = 2
	)

	if fastPanelizer != undefined then (
		theWidth = fastPanelizer.width.value
		theHeight = fastPanelizer.height.value
	)
	else (
		theWidth = 0
		theHeight = -3.0
	)
	
	polyopEP.extrudeEdgeHeight = theHeight -- world units; Edge_Extrude_Height
	polyopEP.extrudeEdgeWidth = theWidth -- float; Edge_Extrude_Width
	polyopEP.buttonOp #ExtrudeEdge

	mainEdges = polyopEP.getSelection #edge
	innerFaces = getFacesUsingEdgeEP theObj (getEdgesUsingVertEP theObj (getVertsUsingEdgeEP theObj (polyopEP.getSelection #edge)))
	polyopEP.setSelection #face innerFaces
	polyopEP.convertSelectionToBorder #face #edge
	topEdges = polyopEP.getSelection #edge

	topEdges = topEdges as array
	topEdgesCount = topEdges.count
	cornerEdges = #{}
	nPoles = #()
	for i = 1 to topEdgesCount do (
		faces = getEdgeFacesEP theObj topEdges[i]
		
		faceDeg = #()
		for j = 1 to faces.count do (
			append faceDeg (polyopEP.getFaceDegree faces[j])
		)

		if (faceDeg[1] == 3 or faceDeg[1] >= 5) and (faceDeg[2] >= 5 or faceDeg[2] == 3) then (
			append cornerEdges topEdges[i]
		)
	)
	
	polyopEP.setSelection #Edge #{}
	polyopEP.Select #Edge cornerEdges
	polyopEP.buttonOp #collapseEdge
	polyopEP.Select #Edge mainEdges
	sideFaces = getFacesUsingEdgeEP theObj mainEdges -- alsó elvágandó élek vertexei
	polyopEP.autoSmoothThreshold = 45
	polyopEP.buttonOp #Autosmooth
	polyopEP.buttonOp #SplitEdges
)
