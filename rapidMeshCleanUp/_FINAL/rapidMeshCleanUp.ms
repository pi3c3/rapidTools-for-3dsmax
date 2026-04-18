--macroScript rapidMeshCleanUp Category:"dTools" toolTip:"rapidMeshCleanUp" (

global areaThresh = 0.0001 as float
global edgeThresh = 0.0001 as float
global nullArray = #{}
global gH = 72

fn selectBy MCUname MCUsub MCUType MCUselection = (
	
	addModifier $ (Edit_Poly name: MCUname); $.modifiers[MCUname].setSelection MCUType #{} ; subObjectLevel = MCUsub; $.modifiers[MCUname].select MCUType MCUselection
)

fn findConcave = (

concaveArray = #{}
		
	for i in $.faces as bitarray do (
		if polyop.getSafeFaceCenter $ i !=  polyop.getFaceCenter $ i do 
			append concaveArray i
	)
	if concaveArray.count != nullArray.count then selectBy "concaveFaces" 4 #Face concaveArray else (messageBox "No more concaves" title: "FINISHED" beep:true)
)

fn findZeroAreaFaces = (

smallFaceArray = #{}
	
	for i in $.faces as bitarray do (
		faceArea = polyop.getFaceArea $ i
		if faceArea < areaThresh do append smallFaceArray i
	)
	if smallFaceArray.count != nullArray.count then selectBy "zeroFaceArea" 4 #Face smallFaceArray else (messageBox "No more zero area faces" title:"FINISHED" beep:true)
)

fn findZeroLengthEdges = (

shortEdgeArray = #{}
	
	for i in $.edges as bitarray do (
		edgeVerts = polyop.getedgeverts $ i
		vert1 = polyop.getVert $ edgeVerts[1]
		vert2 = polyop.getVert $ edgeVerts[2]
		edgeLength = distance vert1 vert2
		if edgeLength < edgeThresh do append shortEdgeArray i
	)
		if shortEdgeArray.count != nullArray.count then selectBy "zeroEdgeLength" 2 #Edge shortEdgeArray else (messageBox "No more zero length edges" title:"FINISHED" beep:true)
)

fn findMidEdgeVertices = (
	undo off (
	ts = timestamp()
	getEdgesUsingVert = polyop.getEdgesUsingVert
	midEdgeVertArray = #{}
	vertCount = $.verts.count
		
	for i = 1 to vertCount do (
		if (getEdgesUsingVert $ i).numberset == 2 do (
			midEdgeVertArray[i] = true
		)
		getEdgesUsingVert $ i
	)
	if midEdgeVertArray.count != nullArray.count then selectBy "midEdgeVertices" 1 #Vertex midEdgeVertArray else (messageBox "No more mid edge Vertexes" title:"FINISHED" beep:true)
	print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
)
)

fn findTriangles = (
	
triangleArray = #{}
		
	for i in $.faces as bitarray do (
		if polyop.getFaceDeg $ i == 3 do 
			append triangleArray i
	)
	if triangleArray.count != nullArray.count then selectBy "triangles" 4 #Face triangleArray else (messageBox "No triangles" title: "FINISHED" beep:true)
)

fn findNGons = (
	
nGonArray = #{}
		
	for i in $.faces as bitarray do (
		if polyop.getFaceDeg $ i > 4 do 
			append nGonArray i
	)
	if nGonArray.count != nullArray.count then selectBy "nGons" 4 #Face nGonArray else (messageBox "No nGons" title: "FINISHED" beep:true)
)

if MeshCleanUp == undefined then (
	rollout MeshCleanUp "Mesh CleanUp" width:352 height:(520+gH)
	(
		bitmap meshCleanUpHeader "MCUBitmap" pos:[8,8] width:336 height:64 fileName:((getdir #userscripts) + "\\rapidTools\\rapidMeshCleanUp_header.png")
		
		groupBox concave "Concave Faces" pos:[8,8+gH] width:336 height:64
		button findConcaves "Find Concave Faces" pos:[24,32+gH] width:168 height:32
		groupBox zeroAreaFaces "Zero Area Faces" pos:[8,80+gH] width:336 height:64
		button findZeroFace "Find Zero Area Faces" pos:[24,104+gH] width:168 height:32
		spinner zeroFaceSpn "threshold:  " pos:[240,112+gH] width:88 height:16 range:[0.0001,10,0.0001] scale: 0.0001 type:#float
		groupBox zeroLengthEdges "Zero Length Edges" pos:[8,152+gH] width:336 height:64
		button findZeroEdge "Find Zero Length Edges" pos:[24,176+gH] width:168 height:32
		spinner zeroEdgeSpn "threshold:  " pos:[240,184+gH] width:88 height:16 enabled:true range:[0.0001,10,0.0001] scale: 0.0001 type:#float
		groupBox triangles "Triangles" pos:[8,224+gH] width:336 height:64
		button findTris "Find Triangles" pos:[24,248+gH] width:168 height:32
		groupBox nGons "nGons" pos:[8,296+gH] width:336 height:64
		button findMyNGons "Find nGons" pos:[24,320+gH] width:168 height:32
		groupBox midEdgeVertices "Mid-Edge Vertices" pos:[8,368+gH] width:336 height:64
		button findMidEdgeVert "Find Mid-Edge Vertices" pos:[24,392+gH] width:168 height:32
		button MEGAFIND "MEGAFIND" pos:[8,444+gH] width:336 height:64
		
		on  zeroFaceSpn changed val do
		(
			areaThresh = val
		)
		
		on zeroEdgeSpn changed val do
		(
			edgeThresh = val
		)
		
		on findConcaves pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findConcave() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findConcave()) else print "cancelled")) else messageBox "No object selected or multiple objects selected"
		)
		
		on findZeroFace pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findZeroAreaFaces() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findZeroAreaFaces()) else print "cancelled")) else messageBox "No object selected or multiple objects selected"
		)
		
		on findZeroEdge pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findZeroLengthEdges() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findZeroLengthEdges()) else print "cancelled")) else messageBox "No object selected or multiple objects selected"
		)
		
		on findMidEdgeVert pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findMidEdgeVertices() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findMidEdgeVertices()) else print "cancelled" )) else messageBox "No object selected or multiple objects selected"
		)
		
		on findTris pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findTriangles() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findTriangles()) else print "cancelled" )) else messageBox "No object selected or multiple objects selected"
		)
		
		on findMyNGons pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then findNGons() else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); findNGons()) else print "cancelled" )) else messageBox "No object selected or multiple objects selected"
		)
		
		on MEGAFIND pressed do
		(
			if selection.count == 1 then (if (classof $ == editable_poly) or (classof $ == PolyMeshObject) then (findConcave(); findZeroAreaFaces(); findZeroLengthEdges(); findMidEdgeVertices(); findTriangles(); findNGons()) else (if queryBox "Not an Editable poly object! Do you want to convert?" beep:false then (convertToPoly($); (findConcave(); findZeroAreaFaces(); findZeroLengthEdges(); findMidEdgeVertices(); findTriangles(); findNGons())) else print "cancelled" )) else messageBox "No object selected or multiple objects selected"
		)
	)
)

if MeshCleanUp.open != True then (
	createDialog MeshCleanUp
)
else (
	destroyDialog MeshCleanUp
	createDialog MeshCleanUp
) 
--)