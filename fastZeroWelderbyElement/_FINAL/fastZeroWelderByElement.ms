macroScript fastZeroVertWelderSafe Category:"rapidTools" toolTip:"fastZeroVertWelder" (

	global currentModIndex = undefined
	global currentMod = modpanel.getCurrentObject()
	global polyopEP

function zeroWeld = (
	
	if classOf currentMod == Editable_Poly then (
		ts = timestamp()
		
		faceCountBefore = polyop.getNumFaces $
		vertCount = polyop.getNumVerts $
		polyop.setFaceSelection $ #{1..faceCountBefore}
		polyop.capHolesByEdge $ (polyop.getOpenEdges $)
		$.weldThreshold = 0.001
		polyop.weldVertsByThreshold $ #{1..vertCount}
		capFaces = #{1..polyop.getNumFaces $}
		mainFaces = polyop.getFaceSelection $
		polyop.setFaceSelection $ (capFaces - mainFaces)
		polyop.deleteFaces $ (polyop.getFaceSelection $)
		
		print ("Solved in: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
	
	else if classOf currentMod == Edit_Poly then (
		ts = timestamp()
		
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())	
		polyopEP = $.modifiers[currentModIndex]
		
		polyopEP.setEPolySelLevel #Face
		faceCountBefore = polyopEP.getNumFaces()
		vertCount = polyopEP.getNumVertices()
		polyopEP.setSelection #Face #{}
		polyopEP.Select #Face #{1..faceCountBefore}
		polyopEP.setEPolySelLevel #Border
		polyopEP.convertSelection #Face #Border
		polyopEP.buttonOp #cap
		polyopEP.setEPolySelLevel #Vertex
		polyopEP.setSelection #Vertex #{}
		polyopEP.Select #Vertex #{1..vertCount}
		polyopEP.weldVertexThreshold = 0.001
		polyopEP.buttonOp #weldVertex
		capFaces = #{1..polyopEP.getNumFaces()}
		polyopEP.setEPolySelLevel #Face
		mainFaces = polyopEP.getSelection #Face
		polyopEP.setSelection #Face #{}
		polyopEP.Select #Face (capFaces - mainFaces)
		polyopEP.buttonOp #DeleteFace
		
		print ("Solved in: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
	else (
		messageBox "Please apply the welder on an Editable/Edit Poly Object!"
	)
)
zeroWeld()
)