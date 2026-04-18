--macroScript pubObject Category:"rapidTools" toolTip:"pubObject" (

theObj = $

function meshFilt obj = (superClassOf obj == GeometryClass) -- pickObject needs this function
	
	if subobjectlevel != 0 or subobjectlevel != undefined and classof theObj == Editable_Poly then (
		sblevel = subobjectlevel
		theTarget = pickObject count:1 filter:meshFilt 
		
		case sblevel of (
			5: theObj.convertSelection #element #vertex
			4: theObj.convertSelection #face #vertex
			3: theObj.convertSelection #border #vertex
			2: theObj.convertSelection #border #vertex
			1: theObj.convertSelection #vertex #vertex
		)
		
		theTriMesh = snapshotAsMesh theObj
		meshop.autoSmooth theTrimesh #ALL 180.0
		verts = polyop.getVertSelection theObj as array
		vertCount = verts.count
		
		vertPositions = #()
		vertPositions[vertCount] = 0
		gV = polyop.getVert
		for i = 1 to vertCount do vertPositions[i] = gV theObj verts[i]
		
		vertNormals = #()
		vertNormals[vertCount] = 0
		gn = getNormal
		for i = 1 to vertCount do vertNormals[i] = gN theTriMesh verts[i]
		delete theTriMesh
		
		for i = 1 to vertCount do (
			inst = instance theTarget
			inst.pos = vertPositions[i]
			inst.dir = vertNormals[i]
		)
	)