--macroScript rapidVertSplitter2016 Category:"rapidTools2016" toolTip:"rapidVertSplitter2016" silentErrors:false (
	
	global theObj = $
	global vertSelection
	global minDist
	global finalFacesArray = #{}
	global currentMod
	global currentModIndex
	global polyopEP
	
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
	
	mapped function divideEdges edges = (
		polyop.divideEdge theObj edges 0.5
	)
	
	mapped function divideEdgesEP edges = (
		theObj.modifiers[currentModIndex].divideEdge edges 0.5
	)
	
	function minDist mainVertArray neighbourVerts = (
		
		mainVert = (mainVertArray as array)[1]
		neighbourVertsArray = neighbourVerts as array
		
		theCount = neighbourVerts.numberset
			
		dist = for i = 1 to theCount collect distance (polyop.getVert theObj mainVert) (polyop.getVert theObj neighbourVertsArray[i])
		min = amin dist
		
		return min
	)
	
	function minDistEP mainVertArray neighbourVerts = (
		
		mainVert = (mainVertArray as array)[1]
		neighbourVertsArray = neighbourVerts as array
		
		theCount = neighbourVerts.numberset
		dist = for i = 1 to theCount collect distance (theObj.modifiers[currentModIndex].getVertex mainVert) (theObj.modifiers[currentModIndex].getVertex neighbourVertsArray[i])
		min = amin dist
		
		return min
	)
	
	function genTopology theVert = (
		theVert = #{theVert}
		if (polyop.getEdgesUsingVert theObj theVert).numberset == 4 then (
			neighbourArray = (polyop.getVertsUsingEdge theObj (polyop.getEdgesUsingVert theObj theVert)) - theVert
			chamferAmount = minDist theVert neighbourArray
			---- CHAMFERING
			polyop.chamferVerts theObj theVert (chamferAmount/2)
			newNVerts = polyop.getVertSelection theObj
			newNVertsA = newNVerts as array
			---- INSERTING NEW VERTICES
			divideEdges ((polyop.getFaceEdges theObj (polyop.getNumFaces theObj)) as array)
			newIVerts = (polyop.getVertSelection theObj) - newNVerts
			newIVertsA = newIVerts as array
			---- CONNECTING OPPOSITE VERTICES
			firstEdge = polyop.createEdge theObj newNVertsA[1] newNVertsA[3]
			midVert = polyop.divideEdge theObj firstEdge 0.5
			polyop.createEdge theObj midVert newNVertsA[2]
			polyop.createEdge theObj midVert newNVertsA[4]
			---- CONNECTING SIDE VERTICES
			
			for i = 1 to newIVertsA.count do (
				theFaces = (polyop.getFacesUsingVert theObj newIVertsA[i]) as array
				
				local myNgon
				
				if (polyop.getFaceDeg theObj theFaces[1]) > (polyop.getFaceDeg theObj theFaces[2]) then myNGon = theFaces[1] else myNGon = theFaces[2]
				
				nGonVerts = polyop.getFaceVerts theObj myNGon
				nGonVerts = nGonVerts + nGonVerts
				firstVertIndex = findItem nGonVerts newIVertsA[i] -- INDEX
				
				polyop.createEdge theObj nGonVerts[firstVertIndex] nGonVerts[firstVertIndex+3]
			)
			finalFacesArray = finalFacesArray + (polyop.getFacesUsingVert theObj midVert)
		)
	)
	
	function genTopologyEP theVert = (
		theVert = #{theVert}
		if (getEdgesUsingVertEP theObj theVert).numberset == 4 then (
			neighbourArray = (getVertsUsingEdgeEP theObj (getEdgesUsingVertEP theObj theVert)) - theVert
			chamferAmount = minDist theVert neighbourArray
			---- CHAMFERING
			polyopEP.setSelection #Vertex #{}
			polyopEP.chamferVertexAmount = (chamferAmount/2)
			polyopEP.Select #Vertex theVert
			polyopEP.setOperation #ChamferVertex
			polyopEP.Commit()
			newNVerts = polyopEP.getSelection #Vertex 
			newNVertsA = newNVerts as array
			---- INSERTING NEW VERTICES
			polyopEP.setSelection #Vertex #{}
			subobjectlevel = 2
			divideEdgesEP ((getFaceEdgesEP theObj (polyopEP.getNumFaces())) as array)
			polyopEP.Commit()
			subobjectlevel = 1
			newIVerts = (polyopEP.getSelection #Vertex) - newNVerts
			newIVertsA = newIVerts as array
			polyopEP.setSelection #Vertex #{}
			---- CONNECTING OPPOSITE VERTICES
			firstEdge = polyopEP.createEdge newNVertsA[1] newNVertsA[3]
			subobjectlevel = 2
			polyopEP.divideEdge firstEdge 0.5
			polyopEP.Commit()
			subobjectlevel = 1
			midVert = polyopEP.getSelection #Vertex
			polyopEP.createEdge (midVert as array)[1] newNVertsA[2]
			polyopEP.Commit()
			polyopEP.createEdge (midVert as array)[1] newNVertsA[4]
			polyopEP.Commit()
			---- CONNECTING SIDE VERTICES
			
			for i = 1 to newIVertsA.count do (
				theFaces = (getFacesUsingVertEP theObj #(newIVertsA[i])) as array

				local myNgon
				
				if (polyopEP.getFaceDegree theFaces[1]) > (polyopEP.getFaceDegree theFaces[2]) then myNGon = theFaces[1] else myNGon = theFaces[2]
				
				nGonVerts = getFaceVerticesEP theObj myNGon
				nGonVerts = nGonVerts + nGonVerts
				firstVertIndex = findItem nGonVerts newIVertsA[i] -- INDEX
				
				polyopEP.createEdge nGonVerts[firstVertIndex] nGonVerts[firstVertIndex+3]
			)
			finalFacesArray = finalFacesArray + (getFacesUsingVertEP theObj midVert)
		)
	)
	
	ts = timestamp()
	setCommandPanelTaskMode #modify
	currentMod = modpanel.getCurrentObject()
	
	if classOf currentMod == Editable_Poly then (
	
		vertSelection = (getVertSelection theObj) as array
		
		if vertSelection.count > 0 then (
		
			for i = 1 to vertSelection.count do (
				genTopology vertSelection[i]
			)
			
			polyop.setFaceSelection theObj finalFacesArray
			subobjectlevel = 4
			print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
		)
		else print "Select vertices that has independent faces (not sharing them) and has four edges!"
	)
	
	if classOf currentMod == Edit_Poly then (
		
		currentModIndex = modPanel.getModifierIndex theObj (modPanel.getCurrentObject())
		polyopEP = theObj.modifiers[currentModIndex]
		vertSelection = (polyopEP.getSelection #Vertex) as array
			
		if vertSelection.count > 0 then (
			
			for i = 1 to vertSelection.count do (
				genTopologyEP vertSelection[i]
			)
			
			polyopEP.setSelection #Face finalFacesArray
			subobjectlevel = 4
			print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
		)
		 else print "Select vertices that has independent faces and four edges!"
	)
--)