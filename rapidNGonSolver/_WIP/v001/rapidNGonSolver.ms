macroScript RapidNGonSolver Category:"rapidTools" toolTip:"RapidNGonSolver" (
	
--- BASIC FUNCTIONS START ---  POLYOP
	
	escapeEnable = true
	setCommandPanelTaskMode #modify
	
	global hexagons = #()
	global hexagonsEP = #()
	global octagons = #()
	global octagonsEP = #()
	global hexaoctagons = #()
	global hexaoctagonsEP = #()
	global concaves = #()
	global concavesEP = #()
	global sharedVertices = #()
	global sharedVerticesEP = #()
	global concaveFaces = #()
	global edgesToRemoveArray = #()
	global currentModIndex = undefined
	global currentMod = modpanel.getCurrentObject()

function getHexagons theObj = ( -- HATSZÖGEK ARRAY-ÉT ADJA VISSZA -- POLY KIJELÖLÉS A BEMENET THE OBJECT
	hexagons = #()
	selectedFaces = polyop.getFaceSelection theObj -- kijelölt face-ek
	selectedFaces = selectedFaces as array -- array-é alakítás
	for i = 1 to selectedFaces.count do  -- 1-tõl a kielölt face-ek számáig
		if polyop.getFaceDeg theObj selectedFaces[i] == 6 do append hexagons selectedFaces[i] -- ellenõrzi, hogy 6 vertexe van-e
		return hexagons as array -- ha igen, append a hexagons-ba és visszaadja eredményül
)

function getOctagons theObj = (
	octagons = #()
	selectedFaces = polyop.getFaceSelection theObj -- kijelölt face-ek
	selectedFaces = selectedFaces as array -- array-é alakítás
	for i = 1 to selectedFaces.count do  -- 1-tõl a kielölt face-ek számáig
		if polyop.getFaceDeg theObj selectedFaces[i] == 8 do append octagons selectedFaces[i] -- ellenõrzi, hogy 8 vertexe van-e
		return octagons as array -- ha igen, append a octagons-ba és visszaadja eredményül
)

function getFaceVertices theFace theObj = ( -- EGY FACE VERTEXEIT ADJA VISSZA -- FACE A BEMENET INTEGER
	vertices = polyop.getFaceVerts theObj theFace -- put the vertices in order in the face
	return vertices
) -- THIS SCRIPT DOES NOT NECESSARY. IT CAN BE SUBSTITUTE BY polyop.getFaceVerts

function getVertexEdgeCount theVert theObj = ( -- EGY VERTEX ÉLSZÁMÁT ADJA VISSZA -- VERTEX A BEMENET INTEGER
	edges = polyop.getEdgesUsingVert theObj theVert
	edges = edges as array
	edgeCount = edges.count
	return edgeCount
)

function getNPole theFaceVertices theObj = ( -- MEGKERESI AZ NPOLE-T ÉS EREDMÉNYÜL ADJA A VERTEX SORSZÁMÁT
	nPole = #()
	for i = 1 to theFaceVertices.count do (
		if (getVertexEdgeCount theFaceVertices[i] theObj) == 3 do append nPole theFaceVertices[i]
	)
	return nPole
)

function getEPole theFaceVertices theObj = ( -- MEGKERESI AZ NPOLE-T ÉS EREDMÉNYÜL ADJA A VERTEX SORSZÁMÁT
	ePole = #()
	for i = 1 to theFaceVertices.count do (
		if (getVertexEdgeCount theFaceVertices[i] theObj) == 5 do append ePole theFaceVertices[i]
	)
	return ePole
)

function getSharedVertices theObj thePolygons = (
	global allVerticesArray = #()
	global sharedVerticesArray = #()
		
	for i = 1 to thePolygons.count do (
		global faceVertices = polyop.getFaceVerts theObj thePolygons[i]
		for j = 1 to faceVertices.count do (
			append allVerticesArray faceVertices[j]
		)
	)
	allVerticesArray = sort allVerticesArray
	for k = 1 to allVerticesArray.count do (
		if allVerticesArray[k] == allVerticesArray[k+1] do (
			append sharedVerticesArray allVerticesArray[k]
		)
	)
return sharedVerticesArray
)

function getConcaves theObj = (
	concaveArray = #()
	faceCount = polyop.getFaceSelection theObj --kijelölt face-k
	faceCount = faceCount as array
	for i = 1 to faceCount.count do (
		if polyop.getSafeFaceCenter theObj faceCount[i] !=  polyop.getFaceCenter theObj faceCount[i] do (
			append concaveArray faceCount[i] )
	)
return concaveArray
)

--- BASIC FUNCTIONS END ---

--- SOLVER FUNCTIONS STARTS HERE ---

function solveHexagons theObj = ( -- SZIMPLA NPOLE-OS HATSZÖGEKET OLDJA MEG
	
	for i = 1 to hexagons.count do ( -- végiglépkedünk a hexagonokon
		faceVertices = getFaceVertices hexagons[i] theObj -- kivesszük a hatszög vertexeit
		faceVertices = faceVertices as array -- array-é alakítjuk		
		nPole = getNPole faceVertices theObj -- megkeressük benne az nPole-t
	
		for j = 1 to sharedVertices.count do (
			sharedFaceIndex = findItem nPole sharedVertices[j]
			if sharedFaceIndex != 0 then deleteItem nPole sharedFaceIndex
		)
	
		faceVertices = join faceVertices faceVertices
		firstVertex = nPole[1]
		secondVertex = findItem faceVertices firstVertex
		secondVertex = faceVertices[secondVertex+3]
		polyop.createEdge theObj firstVertex secondVertex  -- összekötjük az elsõ és a 4. vertexet
		)
)

function solveOctagons theObj = ( -- DUPLA NPOLE-ES NYOLCSZÖGEKET ODLJA MEG
	
	for i = 1 to octagons.count do (
		faceVertices = getFaceVertices octagons[i] theObj
		faceVertices = faceVertices as array
		nPole = getNPole faceVertices theObj
		faceVerticesArray = faceVertices
		
		for j = 1 to sharedVertices.count do (
			sharedFaceIndex = findItem nPole sharedVertices[j]
			if sharedFaceIndex != 0 then deleteItem nPole sharedFaceIndex
		)
		
		faceVerticesArray = join faceVerticesArray faceVertices
		faceVerticesArray = join faceVerticesArray faceVertices
		firstVertex = nPole[1]
		secondVertex = nPole [2]
		polyop.createEdge theObj firstVertex secondVertex
		thirdVertex = findItem faceVertices firstVertex			-- indexet ad vissza
		fourthVertex = findItem faceVertices secondVertex	-- indexet ad vissza
		firstThirdVertex = faceVertices[thirdVertex+8+1]
		firstFourthVertex = faceVertices[fourthVertex+8-1]
		polyop.createEdge theObj firstThirdVertex firstFourthVertex
		secondThirdVertex = faceVertices[thirdVertex+8-1]
		secondFourthVertex = faceVertices[fourthVertex+8+1]
		polyop.createEdge theObj secondThirdVertex secondFourthVertex
	)
)

function solveConcaves theObj = (

	for i = 1 to concaves.count do (
		faceVertices = getFaceVertices concaves[i] theObj
		faceVertices = faceVertices as array
		faceVerticesDouble = faceVertices + faceVertices
		theNPole = getNPole faceVertices theObj
		nPoleIndex = findItem faceVertices theNPole[i]
		/*
		theEPole = #()
		EPoleA = getEPole faceVertices theObj
		EPoleB = #(faceVerticesDouble[nPoleIndex+2])
		if EPoleA != EPoleB then (
			theEPole = EPoleB
		)
		else (
			theEPole = EPoleA
		)
		*/
		theEPole = getEPole faceVertices theObj
		vertEdges = polyop.getEdgesUsingVert theObj theEPole 		-- A VERTEX ÉLEIT ADJA VISSZA
		vertEdges = vertEdges as bitarray
		concaveFaceEdges = polyop.getFaceEdges theObj concaves[i]	-- A FACE-T HATÁROLÓ ÉLEKET ADJA VISSZA
		concaveFaceEdges = concaveFaceEdges as bitarray
		edgesArrayABIntersect = vertEdges*concaveFaceEdges -- a vertEdges és a concaveFaceEdges metszetét adja vissza.
		firstStepEdgeArray = vertEdges-edgesArrayABIntersect 
		firstStepEdgeArray = firstStepEdgeArray as array
		edgesToRemove = (vertEdges as bitarray) * (concaveFaceEdges as bitarray)
		edgesToRemoveArray = edgesToRemoveArray + edgesToRemove
		
		insertedVertArray = #()
		
		-- Getting the length ratio of the newly divided edges
		
		for j = 1 to firstStepEdgeArray.count do (
			insVert = polyop.divideEdge theObj firstStepEdgeArray[j] 0.5
			append insertedVertArray insVert 
		)
		
		ePoleFaces = polyop.getFacesUsingVert theObj theEPole[1]
		ePoleFaces = ePoleFaces as array
		mainFacesArray = #()
		mainFaceVertArray = #()
		
		for k = 1 to ePoleFaces.count do (
			currVerts = polyop.getFaceVerts theObj ePoleFaces[k]
			if currVerts.count == 6 do (
				currVerts = currVerts + currVerts
				append mainFaceVertArray currVerts
			)
		)

		for l = 1 to mainFaceVertArray.count do (
			firstIndex = (findItem mainFaceVertArray[l] theEPole[1])+1
			secondIndex = firstIndex+2
			thirdIndex = firstIndex+4
			
			firstEdge = polyop.createEdge theObj mainFaceVertArray[l][firstIndex] mainFaceVertArray[l][secondIndex]
			secondEdge = polyop.createEdge theObj mainFaceVertArray[l][secondIndex] mainFaceVertArray[l][thirdIndex]
			thirdEdge = polyop.createEdge theObj mainFaceVertArray[l][firstIndex] mainFaceVertArray[l][thirdIndex]
			
			firstVert = polyop.divideEdge theObj firstEdge 0.5
			secondVert = polyop.divideEdge theObj secondEdge 0.5
			thirdVert = polyop.divideEdge theObj thirdEdge 0.5
			
			polyop.createEdge theObj firstVert secondVert
			polyop.createEdge theObj firstVert thirdVert
			polyop.createEdge theObj secondVert thirdVert
			
			polyop.collapseVerts theObj #(firstVert, secondVert, thirdVert)
			
			concaveVerts = polyop.getFaceVerts theObj concaves[i]
			lastConcaveVerts = (concaveVerts as bitarray) - ((theEPole as bitarray) + (theNPole as bitarray))
			lastConcaveVerts = lastConcaveVerts as array
			theVertArray = #(mainFaceVertArray[l][firstIndex], mainFaceVertArray[l][secondIndex], mainFaceVertArray[l][thirdIndex])
			
			for m = 1 to theVertArray.count do (
				for n = 1 to lastConcaveVerts.count do (
					polyop.createEdge theObj theVertArray[m] lastConcaveVerts[n]
				)
			)
		)
		polyop.createEdge theObj theEPole[1] theNPole[1]
	)
	edgesToRemoveArray = edgesToRemoveArray as array
	polyop.setEdgeSelection theObj edgesToRemoveArray
	theObj.EditablePoly.remove selLevel:#Edge	
)

--- SOLVER FUNCTIONS END HERE --- POLYOP

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- BASIC FUNCTIONS START --- EDIT POLY

setCommandPanelTaskMode #modify
CurrentMod = modpanel.getCurrentObject()

function getHexagonsEP theObj = ( -- HATSZÖGEK ARRAY-ÉT ADJA VISSZA -- POLY KIJELÖLÉS A BEMENET THE OBJECT
	hexagonsEP = #()
	selectedFaces = theObj.modifiers[currentModIndex].getSelection #Face -- kijelölt face-ek
	selectedFaces = selectedFaces as array -- array-é alakítás
	for i = 1 to selectedFaces.count do  -- 1-tõl a kielölt face-ek számáig
		if theObj.modifiers[currentModIndex].getFaceDegree selectedFaces[i] == 6 do append hexagonsEP selectedFaces[i] -- ellenõrzi, hogy 6 vertexe van-e
		return hexagonsEP as array -- ha igen, append a hexagons-ba és visszaadja eredményül
)

function getOctagonsEP theObj = ( -- NYOLCSZÖGEK ARRAY-ÉT ADJA VISSZA -- POLY KIJELÖLÉS A BEMENET THE OBJECT
	octagonsEP = #()
	selectedFaces = theObj.modifiers[currentModIndex].getSelection #Face -- kijelölt face-ek
	selectedFaces = selectedFaces as array -- array-é alakítás
	for i = 1 to selectedFaces.count do  -- 1-tõl a kielölt face-ek számáig
		if theObj.modifiers[currentModIndex].getFaceDegree selectedFaces[i] == 8 do append octagonsEP selectedFaces[i] -- ellenõrzi, hogy 6 vertexe van-e
		return octagonsEP as array -- ha igen, append a octagons-ba és visszaadja eredményül
)

function getConcavesEP theObj = (
	concaveArrayEP = #()
	faceCount = theObj.modifiers[currentModIndex].getSelection #Face --polyop.getFaceSelection theObj --kijelölt face-k
	faceCount = faceCount as array
	for i = 1 to faceCount.count do 
		if polyop.getSafeFaceCenter theObj faceCount[i] !=  polyop.getFaceCenter theObj faceCount[i] do append concaveArrayEP faceCount[i]
		return concaveArrayEP
)

---------------------------------- polyop GET FUNCTIONS  to EDIT POLY-----------------------------------

function getVertEdgesEP theVertex theObj = ( -- Egy Vertex éleit adja vissza, sorrendben
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

function getVertFacesEP theVertex theObj = ( -- Egy Vertex éleit adja vissza, sorrendben
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

function getFaceVerticesEP theFace theObj = ( -- EGY FACE VERTEXEIT ADJA VISSZA -- FACE A BEMENET INTEGER
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

function getFaceEdgesEP theFace theObj = ( -- Egy Face éleit adja vissza sorrendben
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

---------------------------------- polyop GET FUNCTIONS  to EDIT POLY-----------------------------------

function getVertexEdgeCountEP theVert theObj = ( -- EGY VERTEX ÉLSZÁMÁT ADJA VISSZA -- VERTEX A BEMENET INTEGER
	edgeCount = theObj.modifiers[currentModIndex].getVertexEdgeCount theVert
	return edgeCount
)

function getNPoleEP theFaceVertices theObj = ( -- MEGKERESI AZ NPOLE-T ÉS EREDMÉNYÜL ADJA A VERTEX SORSZÁMÁT
	nPole = #()
	for i = 1 to theFaceVertices.count do (
		if (getVertexEdgeCountEP theFaceVertices[i] theObj) == 3 do append nPole theFaceVertices[i]
	)
	return nPole
)

function getEPoleEP theFaceVertices theObj = ( -- MEGKERESI AZ NPOLE-T ÉS EREDMÉNYÜL ADJA A VERTEX SORSZÁMÁT
	nPole = #()
	for i = 1 to theFaceVertices.count do (
		if (getVertexEdgeCountEP theFaceVertices[i] theObj) == 5 do append nPole theFaceVertices[i]
	)
	return nPole
)

function getSharedVerticesEP theObj thePolygons = (
	allVerticesArrayEP = #()
	sharedVerticesArrayEP = #()
		
	for i = 1 to thePolygons.count do (
		global faceVertices = getFaceVerticesEP thePolygons[i] theObj
		for j = 1 to faceVertices.count do (
			append allVerticesArrayEP faceVertices[j]
		)
	)
	allVerticesArrayEP = sort allVerticesArrayEP
	for k = 1 to allVerticesArrayEP.count do (
		if allVerticesArrayEP[k] == allVerticesArrayEP[k+1] do (
			append sharedVerticesArrayEP allVerticesArrayEP[k]
		)
	)
return sharedVerticesArrayEP
)

function getNewArrayEP before after = (
	difference = after - before
	newArray = #{}
	for i = 1 to difference do (
		append newArray (before + i)
	)
return newArray
)


--- BASIC FUNCTIONS END --- EDIT POLY

--- SOLVER FUNCTIONS STARTS HERE --- EDIT POLY

function solveHexagonsEP theObj = ( -- SZIMPLA NPOLE-OS HATSZÖGEKET OLDJA MEG
	
	for i = 1 to hexagonsEP.count do ( -- végiglépkedünk a hexagonokon
		faceVertices = getFaceVerticesEP hexagonsEP[i] theObj -- kivesszük a hatszög vertexeit
		faceVertices = faceVertices as array -- array-é alakítjuk		
		nPole = getNPoleEP faceVertices theObj -- megkeressük benne az nPole-t
	
		for j = 1 to sharedVerticesEP.count do (
			sharedFaceIndex = findItem nPole sharedVerticesEP[j]
			if sharedFaceIndex != 0 then deleteItem nPole sharedFaceIndex
		)
	
		faceVertices = join faceVertices faceVertices
		firstVertex = nPole[1]
		secondVertex = findItem faceVertices firstVertex
		secondVertex = faceVertices[secondVertex+3]
		theObj.modifiers[currentModIndex].createEdge firstVertex secondVertex  -- összekötjük az elsõ és a 4. vertexet
		)
	theObj.modifiers[currentModIndex].commit()
)

function solveOctagonsEP theObj = ( -- DUPLA NPOLE-ES NYOLCSZÖGEKET ODLJA MEG
	
	for i = 1 to octagonsEP.count do (
		faceVertices = getFaceVerticesEP octagonsEP[i] theObj
		faceVertices = faceVertices as array
		nPole = getNPole faceVertices theObj
		faceVerticesArray = faceVertices
		
		for j = 1 to sharedVerticesEP.count do (
			sharedFaceIndex = findItem nPole sharedVerticesEP[j]
			if sharedFaceIndex != 0 then deleteItem nPole sharedFaceIndex
		)
		
		faceVerticesArray = join faceVerticesArray faceVertices
		faceVerticesArray = join faceVerticesArray faceVertices
		firstVertex = nPole[1]
		secondVertex = nPole [2]
		theObj.modifiers[currentModIndex].createEdge firstVertex secondVertex
		thirdVertex = findItem faceVertices firstVertex			-- indexet ad vissza
		fourthVertex = findItem faceVertices secondVertex	-- indexet ad vissza
		firstThirdVertex = faceVertices[thirdVertex+8+1]
		firstFourthVertex = faceVertices[fourthVertex+8-1]
		theObj.modifiers[currentModIndex].createEdge firstThirdVertex firstFourthVertex
		secondThirdVertex = faceVertices[thirdVertex+8-1]
		secondFourthVertex = faceVertices[fourthVertex+8+1]
		theObj.modifiers[currentModIndex].createEdge secondThirdVertex secondFourthVertex
	)
	theObj.modifiers[currentModIndex].commit()
)

function solveConcavesEP theObj = (

	for i = 1 to concavesEP.count do (
		faceVertices = getFaceVerticesEP concavesEP[i] theObj
		faceVertices = faceVertices as array
		faceVerticesDouble = faceVertices + faceVertices
		theNPole = getNPoleEP faceVertices theObj
		nPoleIndex = findItem faceVertices theNPole[1]
		/*
		theEPole = #()
		EPoleA = getEPole faceVertices theObj
		EPoleB = #(faceVerticesDouble[nPoleIndex+2])
		if EPoleA != EPoleB then (
			theEPole = EPoleB
		)
		else (
			theEPole = EPoleA
		)
		*/
		theEPole = getEPoleEP faceVertices theObj
		vertEdges = getVertEdgesEP theEPole[1] theObj		-- A VERTEX ÉLEIT ADJA VISSZA
		vertEdges = vertEdges as bitarray
		concaveFaceEdges = getFaceEdgesEP concavesEP[i] theObj	-- A FACE-T HATÁROLÓ ÉLEKET ADJA VISSZA
		concaveFaceEdges = concaveFaceEdges as bitarray
		edgesArrayABIntersect = vertEdges*concaveFaceEdges -- a vertEdges és a concaveFaceEdges metszetét adja vissza.
		firstStepEdgeArray = vertEdges-edgesArrayABIntersect 
		firstStepEdgeArray = firstStepEdgeArray as array
		edgesToRemove = (vertEdges as bitarray) * (concaveFaceEdges as bitarray)
		append edgesToRemoveArray edgesToRemove

		-- Getting the length ratio of the newly divided edges
		
		theObj.modifiers[currentModIndex].ToggleCommandMode #DivideEdge
		
		for j = 1 to firstStepEdgeArray.count do (
			insVert = theObj.modifiers[currentModIndex].divideEdge firstStepEdgeArray[j] 0.5
		)
		
		theObj.modifiers[currentModIndex].commit()
		
		ePoleFaces = getVertFacesEP theEPole[1] theObj
		ePoleFaces = ePoleFaces as array
		mainFacesArray = #()
		mainFaceVertArray = #()
		
		for k = 1 to ePoleFaces.count do (
			currVerts = getFaceVerticesEP ePoleFaces[k] theObj
			if currVerts.count == 6 do (
				currVerts = currVerts + currVerts
				append mainFaceVertArray currVerts
			)
		)

		for l = 1 to mainFaceVertArray.count do (
			firstIndex = (findItem mainFaceVertArray[l] theEPole[1])+1
			secondIndex = firstIndex+2
			thirdIndex = firstIndex+4
			
			firstEdge = theObj.modifiers[currentModIndex].createEdge mainFaceVertArray[l][firstIndex] mainFaceVertArray[l][secondIndex]
			secondEdge = theObj.modifiers[currentModIndex].createEdge mainFaceVertArray[l][secondIndex] mainFaceVertArray[l][thirdIndex]
			thirdEdge = theObj.modifiers[currentModIndex].createEdge mainFaceVertArray[l][firstIndex] mainFaceVertArray[l][thirdIndex]
			
			theObj.modifiers[currentModIndex].commit()
			
			beforeArray = theObj.modifiers[currentModIndex].getNumVertices()
			theObj.modifiers[currentModIndex].EnterCommandMode #DivideEdge
			
			theObj.modifiers[currentModIndex].divideEdge firstEdge 0.5
			theObj.modifiers[currentModIndex].divideEdge secondEdge 0.5
			theObj.modifiers[currentModIndex].divideEdge thirdEdge 0.5
			
			theObj.modifiers[currentModIndex].ToggleCommandMode #DivideEdge
			theObj.modifiers[currentModIndex].commit()
			afterArray = theObj.modifiers[currentModIndex].getNumVertices()
			
			vertSet = getNewArrayEP beforeArray afterArray
			insVertArray = vertSet as array
			
			firstEdgeColl = theObj.modifiers[currentModIndex].createEdge insVertArray[1] insVertArray[2]
			secondEdgeColl = theObj.modifiers[currentModIndex].createEdge insVertArray[1] insVertArray[3]
			thirdEdgeColl = theObj.modifiers[currentModIndex].createEdge insVertArray[2] insVertArray[3]
			
			theObj.modifiers[currentModIndex].commit()
			
			edgeCollArray = #{firstEdgeColl, secondEdgeColl, thirdEdgeColl}
			
			theObj.modifiers[currentModIndex].setSelection #Edge #{}
			theObj.modifiers[currentModIndex].select #Edge edgeCollArray
			theObj.modifiers[currentModIndex].ButtonOp #CollapseEdge
			
			theObj.modifiers[currentModIndex].commit()
			
			concaveVerts = getFaceVerticesEP concavesEP[i] theObj
			
			lastConcaveVerts = (concaveVerts as bitarray) - ((theEPole as bitarray) + (theNPole as bitarray))
			lastConcaveVerts = lastConcaveVerts as array
			
			theVertArray = #(mainFaceVertArray[l][firstIndex], mainFaceVertArray[l][secondIndex], mainFaceVertArray[l][thirdIndex])
			
			for m = 1 to theVertArray.count do (
				for n = 1 to lastConcaveVerts.count do (
					theObj.modifiers[currentModIndex].createEdge theVertArray[m] lastConcaveVerts[n]
					theObj.modifiers[currentModIndex].commit()
				)
			)
		)
		theObj.modifiers[currentModIndex].createEdge theEPole[1] theNPole[1]
		theObj.modifiers[currentModIndex].commit()
	)		
	edgesToRemoveArray = edgesToRemoveArray as array
	theObj.modifiers[currentModIndex].setSelection #Edge #{}
	for p = 1 to edgesToRemoveArray.count do (
		theObj.modifiers[currentModIndex].select #Edge edgesToRemoveArray[p]
	)
	theObj.modifiers[currentModIndex].ButtonOp #RemoveEdge
	theObj.modifiers[currentModIndex].commit()
	theObj.modifiers[currentModIndex].SetEPolySelLevel #face
)


--- SOLVER FUNCTIONS END HERE --- EDIT POLY

--- EXECUTE SOLVERS ---

------------------------------------------------- ------------------------------------------------- GETTING PARAMETERS ------------------------------------------------- ------------------------------------------------- 

function executeSolver = (

makeDir (getDir #plugcfg + "\\" + "dTools" + "\\")
iniFile = getDir #plugcfg + "\\" + "dTools" + "\\" + "nGonSolver.ini"
	
	if doesFileExist iniFile != true do (
		setINISetting iniFile "states" "hexagon" "true"
		setINISetting iniFile "states" "octagon" "true"
		setINISetting iniFile "states" "concave" "true"
	)
	
	if hasINISetting iniFile "states" "hexagon" != true do (
		setINISetting iniFile "states" "hexagon" "true"
	)
	
	if hasINISetting iniFile "states" "octagon" != true do (
		setINISetting iniFile "states" "octagon" "true"
	)
	
	if hasINISetting iniFile "states" "concave" != true do (
		setINISetting iniFile "states" "concave" "true"
	)
	
global hexagonState = getINISetting iniFile "states" "hexagon"
global octagonState = getINISetting iniFile "states" "octagon"
global concaveState = getINISetting iniFile "states" "concave"
	
------------------------------------------------- ------------------------------------------------- MAIN SXECUTION CONTROL ------------------------------------------------- ------------------------------------------------- 
	
	theObj = $
	if theObj != undefined then (
	
		if classOf currentMod == Editable_Poly then (
			startTime = timeStamp()
			global hexagons = getHexagons theObj -- megkerestetjük a hexagonokat -- array-t kapunk
			global octagons = getOctagons theObj -- megkeressük a nyolcszögeket is -- array
			global hexaoctagons = hexagons + octagons
			global sharedVertices = getSharedVertices theObj hexaoctagons
			if hexagonState == "true" do solveHexagons theObj
			if octagonState == "true" do solveOctagons theObj
			free octagons
			free hexagons
			free hexaoctagons
			if concaveState == "true" do (
				global concaves = getConcaves theObj
				solveConcaves theObj
				free concaves
			)
			endTime = timeStamp()
			print ("Execution has taken about " + (endTime - startTime) as string + " milliseconds") 
		)
		else if classOf currentMod == Edit_Poly then (
			startTime = timeStamp()
			global currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
			global hexagonsEP = getHexagonsEP theObj -- megkerestetjük a hexagonokat -- array-t kapunk
			global octagonsEP = getOctagonsEP theObj -- megkeressük a nyolcszögeket is -- array
			global hexaoctagonsEP = hexagonsEP + octagonsEP
			global sharedVerticesEP = getSharedVerticesEP theObj hexaoctagonsEP
			if hexagonState == "true" do solveHexagonsEP theObj
			if octagonState == "true" do solveOctagonsEP theObj
			free octagons
			free hexagons
			free hexaoctagons
			if concaveState == "true" do (
				global concavesEP = getConcavesEP theObj
				solveConcavesEP theObj
				free concavesEP
			)
			endTime = timeStamp()
			print ("Execution has taken about " + (endTime - startTime) as string + " milliseconds") 
		)
		else (messageBox "Select an Editable Poly or Edit Poly Object")
	)
	else (messageBox "Select an Editable Poly or Edit Poly Object")
)

executeSolver()

) --- SCRIPT END