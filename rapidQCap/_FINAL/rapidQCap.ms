-- time stamp to measure execution time
ts = timestamp()

-- global baseObject
global theObj = $.baseObject

-- cache polyop methods
global gVS = polyop.getVertSelection
global gES = polyop.getEdgeSelection
global gFS = polyop.getFaceSelection
global gVUE = polyop.getVertsUsingEdge
global gEUV = polyop.getEdgesUsingVert
global gV = polyop.getVert
global sES = polyop.setEdgeSelection
global cV = polyop.createVert
global cF = polyop.createPolygon
global gNF = polyop.getNumFaces
global cHBE = polyop.capHolesByEdge
global gFE = polyop.getFaceEdges
global gFV = polyop.getFaceVerts
global dF = polyop.deleteFaces

-- cache arary methods
global app = append
global fI = findItem
global iI = insertItem
global dI = deleteItem
global dC = deepCopy
global app = append

-- cache custom functions
global reverseArray
global pairGridSide
global getBestVertsByAngle
global getSeparatedSubs
global orderVertLoop
global isLoopConsistent
global getVertexPairs
global findCorners
global capToQuads

-- global variable
global consistencyFlag = True

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
	k = 1

	-------------------- GENERATING MESH FROM HERE -------------------
	for i = 1 to gridW do ( -- LINES
		for j = 1 to gridH do ( -- ROWS
			
			------------------ COLLECTING NECESSARY VERTICES AND BASE POINT ------------------
			c1 = gV theObj orderedCornerArray[1]
			c2 = gV theObj orderedCornerArray[2]
			c3 = gV theObj orderedCornerArray[3]
			c4 = gV theObj orderedCornerArray[4]
			
			A = gV theObj segmentsArray[1][i]
			B = gV theObj segmentsArray[2][j]
			C = gV theObj segmentsArray[3][i]
			D = gV theObj segmentsArray[4][j]
			
			sp = ((A+B+C+D)/4)
			cp = ((c1+c2+c3+c4)/4)
						
			height = sp - cp
			p = sp + height
			
			------------------ BI-LINEAR INTERPOLATION ----------------			
			aw = (gridH+1-j) / sumH
			bw = i / sumW
			cw = j / sumH
			dw = (gridW+1-i) / sumW
			
			an = (p-A)*aw
			bn = (p-B)*bw
			cn = (p-C)*cw
			dn = (p-D)*dw
			
			------------------ HEIGHT OFFSET --------------------
			c1w = (gridW+1-i) * (gridH+1-j) / sum
 			c2w = i * (gridH+1-j) / sum
			c3w = i * j / sum
			c4w = j * (gridW+1-i) / sum
			
			c1n = (p-c1)*c1w
			c2n = (p-c2)*c2w
			c3n = (p-c3)*c3w
			c4n = (p-c4)*c4w

			cornerHeight = (c1n + c2n + c3n + c4n) * gS / 4
			uvPos = ( ( ((an + bn + cn + dn) * gS) + ((an+cn)*(gridH*gridH) + (bn+dn)*(gridW*gridW)) ) / 2) / (gridH+gridW)
			
			------------------ FINAL MATH HERE -------------------
			vert = p+cornerHeight-uvPos
			newVert = cV theObj vert pointInLocalCoords:false
						
			------------------ GENERATING MESH HERE ------------------
			if gridH != 1 and gridW != 1 then (
				if i > 1 and i < gridW then ( -- GENERATING MID ROWS
					if j == 1 then (
						cF theObj #(lastRow[k], newVert, startVertArr[i+1], startVertArr[i])
					)
					else if j > 1 and j <= gridH-1 then (
						cF theObj #(lastVert, newVert, lastRow[k], lastRow[k-1])
					)
					else if j == gridH then (
						cF theObj #(newVert, lastRow[k], endVertArr[i], endVertArr[i+1])
						cF theObj #(lastVert, newVert, lastRow[k], lastRow[k-1])
					)
					k = k + 1
					app lastRow newVert
				)
				
				else if i == gridW then ( -- GENERATING LAST TWO ROWS
					if j == 1 then (
						cF theObj #(lastRow[k], newVert, startVertArr[i+1], startVertArr[i])
						cF theObj #(newVert, leftVertArr[j], startVertArr[i+2], startVertArr[i+1])
					)
					else if j > 1 and j <= gridH-1 then (
						cF theObj #(lastVert, newVert, lastRow[k], lastRow[k-1])
						cF theObj #(lastVert, newVert, leftVertArr[j], leftVertArr[j-1])
					)
					else if j == gridH then (
						cF theObj #(lastVert, newVert, lastRow[k], lastRow[k-1])
						cF theObj #(lastVert, newVert, leftVertArr[j], leftVertArr[j-1])
						cF theObj #(newVert, lastRow[k], endVertArr[i], endVertArr[i+1])
						cF theObj #(newVert, leftVertArr[j], endVertArr[i+2], endVertArr[i+1])
					)
					k = k + 1 -- ITERATOR FOR 'lastRow' ARRAY
				)
				
				else if i == 1 then ( -- GENERATING FIRST ROW
					if j == 1 then (
						cF theObj #(rightVertArr[i], newVert, startVertArr[i+1], startVertArr[i])
					)
					else if j > 1 and j <= gridH-1 then (
						cF theObj #(lastVert, newVert, rightVertArr[j], rightVertArr[j-1])
					)
					else if j == gridH then (
						cF theObj #(newVert, rightVertArr[j], endVertArr[i], endVertArr[i+1])
						cF theObj #(lastVert, newVert, rightVertArr[j], rightVertArr[j-1] )
					)
					app lastRow newVert
				)
			lastVert = newVert
			)
			else if gridW == 1 or gridH == 1 then ( -- SINGLE ROW / COLUMN / POINT SOLVERS
				if gridW > gridH then ( -- SINGLE COLUMN SOLVER
					if j == 1 and i == 1 then (
						cF theObj #(newVert, rightVertArr[i], endVertArr[i], endVertArr[i+1])
						cF theObj #(newVert, rightVertArr[i], startVertArr[i], startVertArr[i+1])
					)
					else if i > 1 and i < gridW then (
						cF theObj #(newVert, lastVert, endVertArr[i], endVertArr[i+1])
						cF theObj #(newVert, lastVert, startVertArr[i], startVertArr[i+1])
					)
					else if i == gridW then (
						cF theObj #(newVert, lastVert, endVertArr[i], endVertArr[i+1])
						cF theObj #(newVert, lastVert, startVertArr[i], startVertArr[i+1])
						cF theObj #(newVert, leftVertArr[j], endVertArr[i+2], endVertArr[i+1])
						cF theObj #(newVert, leftVertArr[j], startVertArr[i+2], startVertArr[i+1])
					)
				)
				else if gridW < gridH then ( -- SINGLE ROW SOLVER
					if i == 1 and j == 1 then (
						cF theObj #(newVert, startVertArr[i+1], startVertArr[i], rightVertArr[j])
						cF theObj #(newVert, startVertArr[i+1], startVertArr[i+2], leftVertArr[j])
					)
					else if j > 1 and j < gridH then (
						cF theObj #(newVert, lastVert, rightVertArr[j-1], rightVertArr[j])
						cF theObj #(newVert, lastVert, leftVertArr[j-1], leftVertArr[j])
					)
					else if j == gridH then (
						cF theObj #(newVert, lastVert, rightVertArr[j-1], rightVertArr[j])
						cF theObj #(newVert, lastVert, leftVertArr[j-1], leftVertArr[j])
						cF theObj #(newVert, endVertArr[i+1], endVertArr[i], rightVertArr[j])
						cF theObj #(newVert, endVertArr[i+1], endVertArr[i+2], leftVertArr[j])
					)
				)
				else if gridH == 1 and gridW == 1 then ( -- SINGLE POINT SOLVER
 					cF theObj #(newVert, endVertArr[i+1], endVertArr[i], rightVertArr[i])
					cF theObj #(newVert, endVertArr[i+1], endVertArr[i+2], leftVertArr[i])
					cF theObj #(newVert, startVertArr[i+1], startVertArr[i], rightVertArr[i])
					cF theObj #(newVert, startVertArr[i+1], startVertArr[i+2], leftVertArr[i])
				)
			lastVert = newVert
			)
		)
	)	
)

------------------- FLOW CONTROL STARTS HERE -------------------------
vertices = #{}
edgeArray = #{}
verts = #{}

------------------- TEST IF SELECTION IS BILINEAR CAPABLE -------------------
if subobjectlevel == 1 then ( -- get all selection in vertices and edges as well
	verts = gVS theObj
	theObj.convertSelection #vertex #border
	edgeArray = gES theObj
)
	
else if subobjectlevel == 3 then ( -- get all selection in vertices and edges as well
	edgeArray = gES theObj
	theObj.convertSelection #border #vertex
	verts = gVS theObj
)

else if subobjectlevel == 4 then ( -- get all selection in vertices and edges as well
	face = gFS theObj
	theObj.ConvertSelectionToBorder #face #edge
	dF theObj face
	edgeArray = gES theObj
	theObj.convertSelection #border #vertex
	verts = gVS theObj
)

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
					capToQuads theObj vertices sepVertLoops[i]
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

redrawViews()
print ("Time needed for Bi-Linear capping: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")