--macroScript fastQuadConnect Category:"rapidTools" toolTip:"fastQuadConnect" silentErrors:true (

global theObj = $
global currentMod
global currentModIndex
global polyopEP

	function quadConnect edgeSel = (

		theObj.EditablePoly.ConnectEdges()

		newLoop = (polyop.getEdgeSelection theObj) as array
		newLoopCount = newLoop.count
			
		theObj.EditablePoly.ConnectEdges()

		crosses = polyop.getEdgeSelection theObj
		polyop.collapseEdges theObj crosses
			
		for i = 1 to newLoopCount do (
			faces = polyop.getEdgeFaces theObj newLoop[i]
			
			if faces.count == 2 then (
				faceDegA = polyop.getfacedeg theObj faces[1]
				faceDegB = polyop.getfacedeg theObj faces[2]
				
				if (faceDegA == 3 and faceDegB == 5) or (faceDegA == 5 and faceDegB == 3) then (
					if faceDegA > faceDegB then pentaFace = faces[1] else pentaFace = faces[2]
					newVert = polyop.divideEdge theObj newLoop[i] 0.5
					pentaVerts = polyop.getFaceVerts theObj pentaFace
					pentaVerts = pentaVerts + pentaVerts
					IVertIndex = findItem pentaVerts newVert
					
					polyop.createEdge theObj pentaVerts[IVertIndex] pentaVerts[(IVertIndex + 3)]
				)
			)
		)
		redrawViews()
	)

	----------------------------------------------------------- EDITABLE POLY ------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------- EDIT POLY ----------------------------------------------------------------
	
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
	
	function getEdgeFacesEP theObj theEdge = ( -- Egy Vertex éleit adja vissza, sorrendben
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

	function quadConnectEP edgeSel = (

	polyopEP.buttonOp #ConnectEdges

	newLoop = polyopEP.getSelection #Edge
	newLoopCount = newLoop.numberset
		
	polyopEP.buttonOp #ConnectEdges
		
	crosses = polyopEP.getSelection #Edge
	
	diffArray = crosses * newLoop
	diffArrayCount = diffArray.numberset
		
	if newLoopCount != diffArrayCount then (
		polyopEP.setSelection #Edge #{}
		polyopEP.Select #Edge crosses
		polyopEP.buttonOp #CollapseEdge
	)
	
	newLoop = newLoop as array
	
	for i = 1 to newLoopCount do (
		faces = getEdgeFacesEP theObj newLoop[i]
		
		if faces.count == 2 then (
			faceDegA = polyopEP.getFaceDegree faces[1]
			faceDegB = polyopEP.getFaceDegree faces[2]
			
			if (faceDegA == 3 and faceDegB == 5) or (faceDegA == 5 and faceDegB == 3) then (
				if faceDegA > faceDegB then pentaFace = faces[1] else pentaFace = faces[2]
				polyopEP.setSelection #Vertex #{}
				polyopEP.divideEdge newLoop[i] 0.5
				polyopEP.commit()
				newVert = ((polyopEP.getSelection #Vertex) as array)[1]
				pentaVerts = getFaceVerticesEP theObj pentaFace
				pentaVerts = pentaVerts + pentaVerts
				IVertIndex = findItem pentaVerts newVert
				
				polyopEP.createEdge pentaVerts[IVertIndex] pentaVerts[(IVertIndex + 3)]
				polyopEP.commit()
			)
		)
	)
	redrawViews()
)

	ts = timestamp()
	setCommandPanelTaskMode #modify
	currentMod = modpanel.getCurrentObject()
	
	if classOf currentMod == Editable_Poly then (
	
		theEdgeSelection = (polyop.getEdgeSelection theObj) as array
		
		if theEdgeSelection.count > 0 then (
			quadConnect theEdgeSelection
			print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
		)
		else print "Select edges!"
	)
	
	if classOf currentMod == Edit_Poly then (
		
		currentModIndex = modPanel.getModifierIndex theObj (modPanel.getCurrentObject())
		polyopEP = theObj.modifiers[currentModIndex]
		theEdgeSelection = (polyopEP.getSelection #Edge) as array
			
		if theEdgeSelection.count > 0 then (			
			quadConnectEP theEdgeSelection
			print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
		)
		else print "Select edges!"
	)
--)