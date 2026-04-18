(
-- time stamp to measure execution time
ts = timestamp()

-- local baseObject
-- local theObj = $.baseObject
local theObj = $

-- cache polyop methods
local gVS = polyop.getVertSelection
local gES = polyop.getEdgeSelection
local gFS = polyop.getFaceSelection
local gFN = polyop.getFaceNormal
local sFS = polyop.setFaceSelection
local gVUE = polyop.getVertsUsingEdge
local gEUV = polyop.getEdgesUsingVert
local gEUF = polyop.getEdgesUsingFace
local gELUF = polyop.getElementsUsingFace
local gOE = polyOp.getOpenEdges
local gV = polyop.getVert
local sV = polyop.setVert
local sES = polyop.setEdgeSelection
local cV = polyop.createVert
local cF = polyop.createPolygon
local cE = polyop.collapseEdges
local gNF = polyop.getNumFaces
local gNV = polyop.getNumVerts
local cHBE = polyop.capHolesByEdge
local gFE = polyop.getFaceEdges
local gFV = polyop.getFaceVerts
local dF = polyop.deleteFaces
local cHBV = polyop.capHolesByVert
local fNo = polyop.flipNormals
local fIM = polyop.fillInMesh
local att = polyop.attach
local aSM = polyop.autosmooth
local sSG = polyop.setFaceSmoothGroup
local upd = update

local mSV = meshop.setVert

local bI = rtLib.bilinearInterpolate

-- cache arary methods
local app = append
local fI = findItem
local iI = insertItem
local dI = deleteItem
local dC = deepCopy
local app = append

-- cache custom functions
local reverseArray
local pairGridSide
local getBestVertsByAngle
local getSeparatedSubs
local orderVertLoop
local isLoopConsistent
local getVertexPairs
local findCorners
local capToQuads

-- local variable
local consistencyFlag = True

function reverseArray &refArray = (  
    local last = refArray.count  
    local half = last / 2  
      
    for i = 1 to half do  
        swap refArray[i] refArray[last - i + 1]  
)  

function pairGridSide &borderArray = (
	bACount = borderArray.count
	halfData = (bACount/2)
	for i = (1 + halfData) to bACount do (
		reverseArray &borderArray[i]	
	)	
)

function getBestVertsByAngle vertLoop = (
	vertLoopCount = vertLoop.count
	angleArray = #()
	angleArray[vertLoopCount] = 0
	
	for i = 1 to vertLoopCount do (
		if i == 1 then (
			vector1 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[vertLoopCount])
			vector2 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[i+1])
			theAngle = cos (dot (normalize vector1) (normalize vector2))
		)
		else if i == vertLoopCount then (
			vector1 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[i-1])
			vector2 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[1])
			theAngle = cos (dot (normalize vector1) (normalize vector2))
		)
		else (
			vector1 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[i-1])
			vector2 = (gV theObj vertLoop[i]) - (gV theObj vertLoop[i+1])
			theAngle = cos (dot (normalize vector1) (normalize vector2))
		)
		angleArray[i] = theAngle
	)

	maxValIndexArr = #()
	for i = 1 to 4 do (
		maxVal = amax angleArray
		maxValIndex = fI angleArray maxVal
		app maxValIndexArr vertLoop[maxValIndex]
		angleArray[maxValIndex] = 0
	)
	maxValIndexArr
)

function getSeparatedSubs theObj allEdgesArray type: = (
	old = gNF theObj
	cHBE theObj allEdgesArray
	new = gNF theObj
	newFaceCount = new - old
	newIDstart = new - newFaceCount + 1
	newIDend = new
	
	if type == #edgeLoop then (
		orderedEdgeLoopArray = #()
		for i = newIDstart to newIDend do (
			orderedEdgeLoop = gFE theObj i
			app orderedEdgeLoopArray orderedEdgeLoop 
		)
		faceList = #()
		for i = newIDstart to newIDend do (
			app faceList i
		)
		dF theObj faceList
		orderedArray = orderedEdgeLoopArray
	)
	
	if type == #vertLoop then (
		orderedVertLoopArray = #()
		for i = newIDstart to newIDend do (
			orderedVertLoop = gFV theObj i
			app orderedVertLoopArray orderedVertLoop 
		)
		faceList = #()
		for i = newIDstart to newIDend do (
			app faceList i
		)
		dF theObj faceList
		orderedArray = orderedVertLoopArray
	)
	orderedArray
)

function orderVertLoop cornVerts edgeArr vertArr = (
	orderedVertLoop = dC vertArr 
	orderedVertLoop = orderedVertLoop + orderedVertLoop
	vertices = cornVerts
	vertices = vertices as array
	verticesCount = vertices.count
	cornerIndices = #()
	cornerIndices[verticesCount] = 0
	
	for i = 1 to verticesCount do (
		cornerIndices[i] = fI orderedVertLoop vertices[i]
	)
	sort cornerIndices

	orderedCornerVertices = for i = 1 to verticesCount collect orderedVertLoop[cornerIndices[i]]

	orderedCornerVertices
)

function isLoopConsistent vertArray edgeArray cornerArr = ( --sepVertLoop and Vertices
	mainArray = dC vertArray
	testArray = dC cornerArr
	testArray = orderVertLoop testArray edgeArray vertArray
	if (fI mainArray testArray[1]) > (fI mainArray testArray[4]) then (
		reverseArray testArray
	)

	mainArray = mainArray + mainArray
	consistencyFlag = True
	
	firstIndex = fI mainArray testArray[1]
	secondIndex = fI mainArray testArray[2]
	thirdIndex = fI mainArray testArray[3]
	fourthIndex = fI mainArray testArray[4]
	
	dist12 = secondIndex - firstIndex
	dist23 = thirdIndex - secondIndex
	dist34 = fourthIndex - thirdIndex
	dI mainArray firstIndex
	firstIndex = fI mainArray testArray[1]
	fourthIndex = fI mainArray testArray[4]
	dist41 = firstIndex - fourthIndex
	
	if dist12 == dist34 and dist23 == dist41 then (
		consistencyFlag = true
	)
	else (
		consistencyFlag = false
	)
	consistencyFlag
)

function getVertexPairs vA cornerVerts = (
	vertArray = dC vA
	vertArrayCount = vertArray.count
	vertArray = vertArray + vertArray
	vertAIndex = fI vertArray cornerVerts[1]
	vertBIndex = fI vertArray cornerVerts[2]
	
 	distA = abs(vertAIndex - vertBIndex)
 	distB = vertArrayCount - abs(vertAIndex - vertBIndex)
	
	if distA > 1 and distB > 1 then (
		if distA != distB then (
			vertA = vertArray[vertAIndex]
			vertB = vertArray[vertBIndex]
			vertC = vertArray[vertAIndex + vertArrayCount / 2]
			vertD = vertArray[vertAIndex + vertArrayCount / 2 + distA]
			if vertD == undefined then (
				vertD = vertArray[vertAIndex + vertArrayCount / 2 + distB]
			)
			else if vertD == vertB then (
				vertArray = vertArray + vertArray
				vertD = vertArray[vertAIndex + vertArrayCount / 2 + distB]
			)
		)
		else if distA == distB then (
			vertA = vertArray[vertAIndex]
			vertC = vertArray[vertBIndex]
			vertB = vertArray[vertAIndex+(distA/2)]
			vertD = vertArray[vertBIndex+(distB/2)]
		)
		cornerArray = #(vertA, vertB, vertC, vertD)
		corners = cornerArray
	)
	else if distA <= 1 or distB <= 1 then (
		corners = cornerVerts
	)
	corners
)

function findCorners theObj vertArr edgeArr cornverts: = (
	if cornverts == unsupplied then (
		corners = for i in vertArr where (gEUV theObj i).numberset == 4 collect i -- if all corners has been found based on VERT DEGREE
		if corners.count != 4 then (
			angleCorners = getBestVertsByAngle vertArr  -- getting the four greatest angled vertices, they are probably corner verts
			consistencyFlag = isLoopConsistent vertArr edgeArr angleCorners -- testing if these corners are consistent
			if consistencyFlag == true then (
				corners = angleCorners
			)
			if consistencyFlag == false then (
				pairedCorners = getVertexPairs vertArr angleCorners
				consistencyFlag = isLoopConsistent vertArr edgeArr pairedCorners  -- testing if these corners are consistent
				if consistencyFlag == true then (
					corners = pairedCorners
				)
			)
			if consistencyFlag == false then (
				if ((mod vertArr.count 4) as integer) == 0 then ( -- randomly selects the base verts with equal side segments
					corners = #()
					corners[4] = 0
					vertArrCount = vertArr.count
					vertArr = vertArr as array
					corners[1] = vertArr[(vertArrCount/4)]
					corners[2] = vertArr[(vertArrCount/4)*2]
					corners[3] = vertArr[(vertArrCount/4)*3]
					corners[4] = vertArr[(vertArrCount/4)*4]
				)
				else if ((mod vertArr.count 4) as integer) == 2 then ( -- if the side count can't be divided by four without reminder
					corners = #()
					corners[4] = 0
					vertArrCount = vertArr.count
					vertArr = vertArr as array
					corners[1] = vertArr[(vertArrCount/4)]
					corners[2] = vertArr[((vertArrCount/4)*2)+1]
					corners[3] = vertArr[((vertArrCount/4)*3)+1]
					corners[4] = vertArr[((vertArrCount/4)*4)+2]
				)
			consistencyFlag = isLoopConsistent vertArr edgeArr corners
			)
		)
	)
	else if cornverts != unsupplied then ( -- if the corner vertices are selected, then this part runs
		if cornverts.numberset == 4 then (
			corners = #()
			vertArr = vertArr as array
			corners = cornverts as array
			orderedCornerVerts = orderVertLoop cornVerts edgeArr vertArr
			corners = orderedCornerVerts
		)
		if cornverts.numberset == 2 then (
			corners = #()
			vertArr = vertArr as array
			corners = cornverts as array
			orderedCornerVerts = orderVertLoop corners edgeArr vertArr
			pairedCorners = getVertexPairs vertArr orderedCornerVerts
			corners = orderVertLoop pairedCorners edgeArr vertArr
		)
	)
	corners
)

fn areFloatsEquivalent f1 f2 eps:1e-6 = (
	f1 == f2 OR abs (f1 - f2) <= eps
)

fn areVectorsEquivalent v1 v2 eps:0.99 = (
	dot (normalize v1) (normalize v2) > eps
)

function getInEdgesUsingFace theObj faces =
(
	if (((classOf theObj) == Editable_Poly) and ((classOf faces) == BitArray)) then
    (
		if (faces.isEmpty == true) then ( return #{} )

		baEdgeSet01 = gEUF theObj faces
		baFaceSet01 = #{1..(gNF theObj)} - faces
		baEdgeSet02 = gEUF theObj baFaceSet01

		baEdgeSet03 = gOE theObj

		(baEdgeSet01 - baEdgeSet02 - baEdgeSet03)
    )
)

function mergeGrid theObj vert1 vert2 = (
	cHBV theObj vert1
	cHBV theObj vert2

	newFace1 = gNF theObj
	newFace2 = (gNF theObj)-1

	newFaceNormal1 = gFN theObj newFace1
	newFaceNormal2 = gFN theObj newFace2

	if areVectorsEquivalent newFaceNormal1 newFaceNormal2 then (
		gridFaces = gELUF theObj newFace1
		---------------------------------------
 		fNo theObj gridFaces
		fIM theObj
 		upd theObj
		---------------------------------------
		sFS theObj #{newFace1, newFace2}
		theObj.EditablePoly.Bridge()
		newFaces = gFS theObj
		connectionEdges = getInEdgesUsingFace theObj newFaces
	)
	else (
		sFS theObj #{newFace1, newFace2}
		theObj.EditablePoly.Bridge()
		newFaces = gFS theObj
		connectionEdges = getInEdgesUsingFace theObj newFaces
	)
	connectionEdges
)

function capToQuads theObj vertices orderedVertLoop = ( -- generate an array containing the loop vertexes successively in order
	firstVert = (vertices as array)[1]
	edgeLoop = gES $ as array
	if firstVert == undefined do ( -- if firstVert is undefined it sets the firs vert value to the firs element of the edge loop
		firstVert = ((gVUE theObj edgeLoop[1] as array)[1])
	)
	
	orderedVertLoop = orderedVertLoop + orderedVertLoop

	vertices = vertices as array
	verticesCount = vertices.count
	cornerIndices = #()
	cornerIndices[verticesCount] = 0
	
	for i = 1 to verticesCount do (
		cornerIndices[i] = fI orderedVertLoop vertices[i]
	)
	
	sort cornerIndices
	
	segmentsArray = #()
	if verticesCount > 2 then (
		cornerIndices[(cornerIndices.count)+1] = cornerIndices[cornerIndices.count] + (cornerIndices[3] - cornerIndices[2])
			
		for i = 1 to verticesCount do (
			vertArray = #()
			k = 1
			for j = (cornerIndices[i]) to (cornerIndices[i+1]-1) do (
				vertArray[k] = orderedVertLoop[j]
				k = k + 1 
			)
			segmentsArray[i] = vertArray
			k = 1
		)
	)

	segmentsArrayCount = segmentsArray.count
	orderedCornerArray = #()
	orderedCornerArray[segmentsArrayCount] = 0
	
	for i = 1 to segmentsArrayCount do (
		orderedCornerArray[i] = segmentsArray[i][1]
		dI segmentsArray[i] 1
	)
	
	pairGridSide segmentsArray
	
	gridW = (segmentsArray[1].count)
	gridH = (segmentsArray[2].count)
	sum = 0.0
	sumW = 0.0
	sumH = 0.0
	gS = gridW*gridH
	for i = 1 to gridW do (
		for j = 1 to gridH do (
			pointValue = i*j
			sum = sum + pointValue
		)
	)
	
	for i = 1 to gridW do (
		sumW = sumW + i
	)
	
	for j = 1 to gridH do (
		sumH = sumH + j
	)
	
	-------------------- BASIC ARRAYS FOR MESH GENERATION --------------------
	startVertArr = dC segmentsArray[1]
	iI orderedCornerArray[1] startVertArr 1
	iI orderedCornerArray[2] startVertArr ((startVertArr.count)+1)
	endVertArr = dC segmentsArray[3]
	iI orderedCornerArray[4] endVertArr 1
	iI orderedCornerArray[3] endVertArr ((endVertArr.count)+1)
	leftVertArr = dC segmentsArray[2]
	rightVertArr = dC segmentsArray[4] 
	lastVert = 0
	lastRow = #()
	v = 1

	-------------------- BASIC ARRAYS FOR MESH GENERATION --------------------
	
	c1 = gV theObj orderedCornerArray[1]
	c2 = gV theObj orderedCornerArray[2]
	c3 = gV theObj orderedCornerArray[3]
	c4 = gV theObj orderedCornerArray[4]

	------------------------- GENERATING MESH FROM HERE ----------------------
	newMesh = mesh lengthsegs:(gridW+1) widthsegs:(gridH+1)

	vertIndexList = #()
	vertPosList = #()

	for i = 1 to gridW do ( -- LINES
		for j = 1 to gridH do ( -- ROWS
			
			------------------ COLLECTING NECESSARY VERTICES AND BASE POINT ------------------
			A = gV theObj segmentsArray[1][i]
			B = gV theObj segmentsArray[2][j]
			C = gV theObj segmentsArray[3][i]
			D = gV theObj segmentsArray[4][j]
			
			---------------------- MOVING POINTS TO THEIR PROPER PLACES ----------------------

			vert = bI A B C D c1 c2 c3 c4 gridW gridH sum sumW sumH i j
			
			if gridH != 1 and gridW != 1 then (
				if i > 1 and i < gridW then ( -- GENERATING MID ROWS
					if j == 1 then (
						app vertIndexList (v+gridH+3) 
						app vertPosList A
						app vertIndexList (v+gridH+4) 
						app vertPosList vert
						v = v + 1					
					)
					else if j > 1 and j <= gridH-1 then (
						app vertIndexList (v+gridH+3) 
						app vertPosList vert
					)
					else if j == gridH then (
						app vertIndexList (v+gridH+4) 
						app vertPosList C
						app vertIndexList (v+gridH+3) 
						app vertPosList vert
						v = v + 1
					)
				)
				else if i == gridW then ( -- GENERATING LAST TWO ROWS
					if j == 1 then (
						app vertIndexList (v+gridH+3) 
						app vertPosList A
						app vertIndexList (v+gridH+4) 
						app vertPosList vert
						app vertIndexList (v+gridH+gridH+5) 
						app vertPosList c2
						app vertIndexList (v+gridH+gridH+6) 
						app vertPosList B
					)
					else if j > 1 and j <= gridH-1 then (
						app vertIndexList (v+gridH+gridH+6) 
						app vertPosList B
						app vertIndexList (v+gridH+4) 
						app vertPosList vert
					)
					else if j == gridH then (
						app vertIndexList (v+gridH+5) 
						app vertPosList C
						app vertIndexList (v+gridH+4) 
						app vertPosList vert
						app vertIndexList (v+gridH+gridH+7) 
						app vertPosList c3
						app vertIndexList (v+gridH+gridH+6) 
						app vertPosList B					
					)
				)
				else if i == 1 then ( -- GENERATING FIRST ROW
					if j == 1 then (
						app vertIndexList v
						app vertPosList c1
						app vertIndexList (v+1) 
						app vertPosList D
						app vertIndexList (v+gridH+2) 
						app vertPosList A
						app vertIndexList (v+gridH+3)
 						app vertPosList vert
					)
					else if j > 1 and j <= gridH-1 then (
						app vertIndexList (v+gridH+3) 
						app vertPosList vert
						app vertIndexList (v+1) 
						app vertPosList D
					)
					else if j == gridH then (
						app vertIndexList (v+2) 
						app vertPosList c4
						app vertIndexList (v+1) 
						app vertPosList D
						app vertIndexList (v+gridH+4) 
						app vertPosList C
						app vertIndexList (v+gridH+3) 
						app vertPosList vert
						v = v + 1
					)
				)
			)
			else if gridW == 1 or gridH == 1 then ( -- SINGLE ROW / COLUMN / POINT SOLVERS
				if gridW > gridH then ( -- SINGLE COLUMN SOLVER
					if j == 1 and i == 1 then (
						app vertIndexList v
						app vertPosList c1
						app vertIndexList (v+1) 
						app vertPosList D
						app vertIndexList (v+2)
						app vertPosList c4
						app vertIndexList (v+3) 
						app vertPosList A
						app vertIndexList (v+4)
 						app vertPosList vert
						app vertIndexList (v+5)
 						app vertPosList C
 						v = v + 5
					)
					else if i > 1 and i < gridW then (
						app vertIndexList (v)
						app vertPosList A
						app vertIndexList (v+1)
						app vertPosList vert
						app vertIndexList (v+2)
						app vertPosList C
						v = v + 2
					)
					else if i == gridW then (
						app vertIndexList (v) 
						app vertPosList A
						app vertIndexList (v+1)
 						app vertPosList vert
						app vertIndexList (v+2)
 						app vertPosList C
						app vertIndexList (v+3)
						app vertPosList c2
						app vertIndexList (v+4) 
						app vertPosList B
						app vertIndexList (v+5)
						app vertPosList c3
					)
				)
				else if gridW < gridH then ( -- SINGLE ROW SOLVER
					if i == 1 and j == 1 then (
						app vertIndexList v
						app vertPosList c2
						app vertIndexList (v+gridH+2) 
						app vertPosList A
						app vertIndexList (v+gridH+gridH+4)
						app vertPosList c1
						app vertIndexList (v+1) 
						app vertPosList B
						app vertIndexList (v+gridH+3)
 						app vertPosList vert
						app vertIndexList (v+gridH+gridH+5)
 						app vertPosList D
 						v = v + 1
					)
					else if j > 1 and j < gridH then (
						app vertIndexList (v)
						app vertPosList B
						app vertIndexList (v+gridH+2)
						app vertPosList vert
						app vertIndexList (v+gridH+gridH+4)
						app vertPosList D
					)
					else if j == gridH then (
						app vertIndexList (v)
						app vertPosList B
						app vertIndexList (v+gridH+2)
						app vertPosList vert
						app vertIndexList (v+gridH+gridH+4)
						app vertPosList D
						app vertIndexList (v+1)
						app vertPosList c3
						app vertIndexList (v+gridH+3)
						app vertPosList C
						app vertIndexList (v+gridH+gridH+5)
						app vertPosList c4
					)
				)
				else if gridH == 1 and gridW == 1 then ( -- SINGLE POINT SOLVER
					app vertIndexList (v)
					app vertPosList c1
					app vertIndexList (v+1)
					app vertPosList D
					app vertIndexList (v+2)
					app vertPosList c4
					app vertIndexList (v+3)
					app vertPosList A
					app vertIndexList (v+4)
					app vertPosList vert
					app vertIndexList (v+5)
					app vertPosList C
					app vertIndexList (v+6)
					app vertPosList c2
					app vertIndexList (v+7)
					app vertPosList B
					app vertIndexList (v+8)
					app vertPosList c3
				)
			)
			v = v + 1
		)
	)
	-- setting up the vertex positions
	mSV newMesh vertIndexList vertPosList
	-- attaching the newMesh to the base object
	att theObj newMesh
	-- merge the border edges
	connectionEdge = mergeGrid theObj orderedVertLoop[1] (gNV theObj)
)

sublevel = subobjectlevel

-----------------------------------------------------------------------
-- before 3dsmax 2018 the Command panel name was: "Command Panel"
-- from 3dsmax 2018 it has been renamed due to the change of the
-- Qt5 system... From that version it's called: "CommandPanelWindow"
-----------------------------------------------------------------------
WM_SETREDRAW=0xB
commandHWND = windows.getChildHWND #max "Command Panel"
if commandHWND == undefined then (
	commandHWND = windows.getChildHWND #max "CommandPanelWindow"
)
windows.sendmessage commandHWND[1]  WM_SETREDRAW 0 0
-----------------------------------------------------------------------

-- BASE BIT ARRAYS
---------------------------
vertices = #{}
edgeArray = #{}
verts = #{}
connEdges = #{}
oldFaceCount = 0

-- FLOW CONTROL STARTS HERE
---------------------------
if subobjectlevel == 1 then ( -- get all selection in vertices and edges as well
	verts = gVS theObj
	oldFaceCount = gNF theObj 
	theObj.convertSelection #vertex #border
	edgeArray = gES theObj
)
else if subobjectlevel == 3 then ( -- get all selection in vertices and edges as well
	edgeArray = gES theObj
	oldFaceCount = gNF theObj 
	theObj.convertSelection #border #vertex
	verts = gVS theObj
)
else if subobjectlevel == 4 then ( -- get all selection in vertices and edges as well
	face = gFS theObj
	theObj.ConvertSelectionToBorder #face #edge
	dF theObj face
	oldFaceCount = gNF theObj 
	edgeArray = gES theObj
	theObj.convertSelection #border #vertex
	verts = gVS theObj
)
else windows.sendmessage commandHWND[1]  WM_SETREDRAW 1 0

try (

sepVertLoops = getSeparatedSubs theObj edgeArray type:#vertLoop -- separate those selections in to individual border selections
sepEdgeLoops = getSeparatedSubs theObj edgeArray type:#edgeLoop -- separate those selections in to individual border selections

	for i = 1 to sepVertLoops.count do (
		if sepVertLoops[i].count != 4 then (
			if subobjectlevel == 3 or subobjectlevel == 4 then ( -- if the base selection is in face or border mode, then it uses the find corner algorithm to identifie the base corner vertices.
				vertices = findCorners theObj sepVertLoops[i] sepEdgeLoops[i]
			)
			else if subobjectlevel == 1 then ( -- if the base selection was vert than, the script take the base corner selection in count 
				if verts.numberset == 2 or verts.numberset == 4 then (
					vertices = findCorners theObj sepVertLoops[i] sepEdgeLoops[i] cornverts:verts
				)
			)
			if consistencyFlag == True then (
				vertices = vertices as array
				verticesCount = vertices.count
				edges = #{}
				for j = 1 to verticesCount do (
					edges = edges + ((gEUV theObj vertices[j]) as bitarray)
				)
				
				------------------- CORNER BASED FLOW CONTROL --------------------
				if vertices.count == 4 then (
					if (edgeArray * edges).numberset == 8 then (
						subobjectlevel = 4 -- it has to be changed to 4, as certain tests are not working without this
						connEdges = connEdges + (capToQuads theObj vertices sepVertLoops[i])
					)
					else if (edgeArray * edges).numberset == 6 then (
						edgeArr = ((edges*edgeArray) as array)
						sideEdgeArr = #()
						for i = 1 to edgeArr.count do (
							if ((gVUE theObj edgeArr[i]) * (vertices as bitarray)).numberset == 2 then (
								app sideEdgeArr edgeArr[i]
							)
						)
						sideEdges = (sepEdgeLoops[i] as bitarray) - (sideEdgeArr as bitarray)
						sES theObj sideEdges
						theObj.bridge selLevel:#edge
					)
				)
				else messageBox "Please select two or four corner vertices,\nwith equal vertex count on opposite sides!"
			)
			else messageBox "Side segments are not consistent!"
		)
		else cF theObj sepVertLoops[i]
	)

	if connEdges.count != 0 then (
		cE theObj connEdges
	)

	newFaceCount = gNF theObj
	selFaces = #{oldFaceCount+1..newFaceCount}

	sFS theObj selFaces
	$.autosmooth()
	$.ConvertSelectionToBorder #face #edge

	subobjectlevel = sublevel
	windows.sendmessage commandHWND[1]  WM_SETREDRAW 1 0
	redrawViews()
	print ("Time needed for Bi-Linear capping: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
)
catch windows.sendmessage commandHWND[1]  WM_SETREDRAW 1 0
)