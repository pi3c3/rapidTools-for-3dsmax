macroScript EditPoly_RegularizeEdgeLoop buttonText:"Regularize(EditPoly)" category:"rapidTools" toolTip:"Regularize Edge Loop (EditPoly)" (
	
	global theObj
	global theObject
	global theEdges
	global theLoops
	global baseSubLevel
	global currentMod
	global currentModIndex
		
	--on IsEnabled return Filters.Is_EditPolySpecifyLevel #{3..5}
	--on IsVisible return Filters.Is_EditPolySpecifyLevel #{3..5}
		
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
---------------------------------------------------------------------------------------------------------------- EDITABLE POLY ----------------------------------------------------------------------------------------------------------------------
		--check for validity / build one vertex array per loop
	function buildTheLoops = (
		--shorthands/optimization
		local v2e = polyOp.getEdgesUsingVert 
		local e2v = polyOp.getVertsUsingEdge
		
		while not theEdges.isEmpty do
		(
			local theEdge = (theEdges as array)[1]
			local theVerts = polyOp.getEdgeVerts theObject theEdge
			theEdges -= #{theEdge}
			local vertA = theVerts[1]
			local vertB = theVerts[2]
			
			while true do
			(
				vertA = vertB
				local theConnected = (v2e theObject vertA) * theEdges
				local cnt = theConnected.numberSet
				if cnt > 1 do return 1  --branching edges
				if cnt == 0 then
				(
					if theVerts[1] != theVerts[theVerts.count] do return 2  --open loop
					deleteItem theVerts theVerts.count
					exit
				)
				else theEdge = (theConnected as array)[1]
				vertB = (((e2v theObject theEdge) - #{vertA}) as array)[1]
				append theVerts vertB
				theEdges -= #{theEdge}
				
			)--end while true
			
			append theLoops theVerts
			
		)--end while not theEdges.isEmpty
		
		return 0  --edge loops valid
		
	)-- end function buildTheVerts
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--make edge loops regular
	function makeRegular = (
		--shorthands/optimization
		local getPos = polyOp.getVert
		local setPos = polyOp.setVert
		
		for theLoop in theLoops do
		(
			local theCount = theLoop.count
			if theCount < 3 do return 1  --no need to rearrange 2 edges

			--average position of all vertices
			local theCenter = [0,0,0]
			for i = 1 to theCount do theCenter += getPos theObject theLoop[i]
			theCenter /= theCount

			--triangles formed by each edge in loop and theCenter
			--average of their normals, weighted by their surfaces
			local theDir = [0,0,0]
			for i = 1 to theCount do
				theDir += cross (getPos theObject theLoop[i] - theCenter) (getPos theObject theLoop[mod i theCount + 1] - theCenter)
			
			--coordinate system local to the loop
			local theLocalTM = matrixFromNormal (normalize theDir)
			theLocalTM.translation = theCenter

			in coordSys theLocalTM
			(
				local theCoords = for i = 1 to theCount collect
					(getPos theObject theLoop[i]) * [1,1,0]  --make planar in theLocalTM (z = 0)

				local theRadius = 0  --average distance from theCenter
				local theDelta = 360.0 / theCount  --average angle variation
				local theOffset = 0  --average variations of ith vector from i * theDelta
				
				for i = 1 to theCount do
				(
					local p = theCoords[i]
					theRadius += length p
					local theAngle = atan2 p.y p.x
					theOffset += mod (720 + theAngle - theDelta * i) 360  --needs to be positive
				)
				
				theRadius /= theCount
				theOffset /= theCount
				
				for i = 1 to theCount do
				(
					local theAngle = theOffset + theDelta * i
					setPos theObject theLoop[i] ((theRadius * [cos theAngle, sin theAngle, 0]))
				)
				
			)--end in coordSys theLocalTM
			
		)--end for theLoop in theLoops
		
	)--end function makeRegular()
	
---------------------------------------------------------------------------------------------------------------- EDITABLE POLY ----------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------- EDIT POLY --------------------------------------------------------------------------------------------------------------------------
	
-------------------------------------------------------------------------------------------------- BASE FUNCTIONS FOR EDIT POLY -------------------------------------------------------------------------------------------------------
	
	function getVertEdgesEP theVertex theObj = ( -- Egy Vertex éleit adja vissza, sorrendben
		if 	theVertex != undefined then (
			edgeArrayEP = #()
			getVertEdge = theObj.modifiers[currentModIndex].GetVertexEdge
			i = 1 
			do (
				edgeIndex = getVertEdge theVertex i
				append edgeArrayEP edgeIndex
				i=i+1
			)
			while (edgeIndex != 0)
			deleteItem edgeArrayEP (edgeArrayEP.count)
			return edgeArrayEP
			)
		else return undefined
	)
	
	function getEdgeVertsEP theEdge theObj = ( -- Egy Vertex éleit adja vissza, sorrendben
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
	
	function getVertsUsingEdgeEP theEdges theObj = (
	theVertices = #()
	theEdges = theEdges as array
	theEdgesCount = theEdges.count
		for i = 1 to theEdgesCount do (
			theVertices = theVertices + (getEdgeVertsEP theEdges[i] theObj)
		)
		return theVertices as bitarray
	)
	
	function getEdgesUsingVertEP theVerts theObj = (
	theEdges = #()
	theVerts = theVerts as array
	theVertsCount = theVerts.count
		for i = 1 to  theVertsCount do (
			theEdges = theEdges + (getVertEdgesEP theVerts[i] theObj)
		)
		return theEdges as bitarray
	)
	
	function setVertEP theVertex destination theObject  = ( -- this one generates an offset array from the actual and destination position -- returns into an array
		
		theMod = $.modifiers[currentModIndex]
		
		theMod.select #Vertex #{theVertex}
		actual = theObject.modifiers[currentModIndex].getVertex theVertex
		newPos = destination - actual
		theMod.MoveSelection newPos
		theMod.Commit()
		theMod.setSelection #Vertex #{}
		
		--return newPos
	)
	
	function getVertEP theVertex theObject = (
	
		actual = theObject.modifiers[currentModIndex].getVertex theVertex 
		return actual
	)
	

-------------------------------------------------------------------------------------------------- BASE FUNCTIONS FOR EDIT POLY -------------------------------------------------------------------------------------------------------
	
			--check for validity / build one vertex array per loop
	function buildTheLoopsEP = (

		while not theEdges.isEmpty do
		(
			local theEdge = (theEdges as array)[1]
			local theVerts = getEdgeVertsEP theEdge theObject
			theEdges -= #{theEdge}
			local vertA = theVerts[1]
			local vertB = theVerts[2]
			
			while true do
			(
				vertA = vertB
				local theConnected = ((getVertEdgesEP vertA theObject) as bitarray) * (theEdges as bitarray)
				local cnt = theConnected.numberSet
				if cnt > 1 do return 1  --branching edges
				if cnt == 0 then
				(
					if theVerts[1] != theVerts[theVerts.count] do return 2  --open loop
					deleteItem theVerts theVerts.count
					exit
				)
				else theEdge = (theConnected as array)[1]
				vertB = ((((getEdgeVertsEP theEdge theObject as bitarray)) - #{vertA}) as array)[1]
				append theVerts vertB
				theEdges -= #{theEdge}
				
			)--end while true
			
			append theLoops theVerts
			
		)--end while not theEdges.isEmpty
		
		return 0  --edge loops valid
		
	)-- end function buildTheVerts
		
	--make edge loops regular
	function makeRegularEP = (
		--shorthands/optimization
		
		theObject.modifiers[currentModIndex].enabled = false
		with redraw off (
		subobjectlevel = 1
		for theLoop in theLoops do
		(
		
			local theCount = theLoop.count
			if theCount < 3 do return 1  --no need to rearrange 2 edges
				
			--average position of all vertices
			local theCenter = [0,0,0]
			for i = 1 to theCount do theCenter += getVertEP theLoop[i] theObject
			theCenter /= theCount

			--triangles formed by each edge in loop and theCenter
			--average of their normals, weighted by their surfaces
			local theDir = [0,0,0]
			for i = 1 to theCount do
				theDir += cross ((getVertEP theLoop[i] theObject) - theCenter) ((getVertEP (theLoop[(mod i theCount) + 1]) theObject) - theCenter)

			--coordinate system local to the loop
			local theLocalTM = matrixFromNormal (normalize theDir)
			(theLocalTM.translation = theCenter)

			---------------> in coordSys theLocalTM <--------------- doing it manually

				local theCoords = for i = 1 to theCount collect (getVertEP theLoop[i] theObject) * (inverse thelocalTM) * [1,1,0]  --make planar in theLocalTM (z = 0)
				local theRadius = 0  --average distance from theCenter
				local theDelta = 360.0 / theCount  --average angle variation
				local theOffset = 0  --average variations of ith vector from i * theDelta
				
				for i = 1 to theCount do
				(
					local p = theCoords[i]
					theRadius += length p
					local theAngle = atan2 p.y p.x
					theOffset += mod (720 + theAngle - theDelta * i) 360  --needs to be positive
				)
				
				theRadius /= theCount
				theOffset /= theCount
				
				for i = 1 to theCount do
				(
					local theAngle = theOffset + theDelta * i
					setVertEP theLoop[i] ((theRadius * [cos theAngle, sin theAngle, 0]) * (thelocalTM)) theObject --tm:theLocalTM
				)
			---------------> in coordSys theLocalTM <--------------- doing it manually
				
		)--end for theLoop in theLoops
	)
	theObject.modifiers[currentModIndex].enabled = true
	
	)--end function makeRegular()
	
-------------------------------------------------------------------------------------------------------------------- EDIT POLY --------------------------------------------------------------------------------------------------------------------------
	
-------------------------------------------------------------------------------------------------------- MAIN EXECUTION CONTROL -----------------------------------------------------------------------------------------------------------
	
	-- macro body
	ts = timestamp()
	setCommandPanelTaskMode #modify
	global currentMod = modpanel.getCurrentObject()
	
	if classOf currentMod == Editable_Poly then (
		theLoops =#()
		theObject = $
		if subobjectLevel == 4 do theObject.editablePoly.convertSelectionToBorder #face #edge
		if (theEdges = polyOp.getEdgeSelection theObject).isEmpty then (
			MessageBox "Selection is Empty" Title:"Poly Editing" )
		else if (polyOp.getVertsUsingEdge theObject theEdges).numberSet != theEdges.numberSet then (
			MessageBox "Invalid Edge Loop(s)" Title:"Poly Editing" )
		else case buildTheLoops() of (
			1: MessageBox "Branching Edge Loop(s)" Title:"Poly Editing"
			2: MessageBox "Open Edge Loop(s)" Title:"Poly Editing"
			0: makeRegular()
		)
		print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
		
	if classOf currentMod == Edit_Poly then (
		theLoops =#()
		theObject = $
		currentModIndex = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		
		---------------------- STORE SELECTION STATE ----------------------
			
		baseSubLevel = subobjectlevel -- storeing the base subobject level
		baseVertSelection = theObject.modifiers[currentModIndex].getSelection #Vertex
		theObject.modifiers[currentModIndex].setSelection #Vertex #{}
			
		---------------------- STORE SELECTION STATE ----------------------
			
			if subobjectLevel == 4 do theObject.modifiers[currentModIndex].convertSelectionToBorder #face #edge
		theEdges = (theObject.modifiers[currentModIndex].getSelection #edge)
		if theEdges.isEmpty then (
			MessageBox "Selection is Empty" Title:"Poly Editing" )
		else if (getVertsUsingEdgeEP theEdges theObject).numberSet != theEdges.numberSet then (
			MessageBox "Invalid Edge Loop(s)" Title:"Poly Editing" )
		else case buildTheLoopsEP() of (
			1: MessageBox "Branching Edge Loop(s)" Title:"Poly Editing"
			2: MessageBox "Open Edge Loop(s)" Title:"Poly Editing"
			0: makeRegularEP()
		)
	theObject.modifiers[currentModIndex].select #Vertex baseVertSelection
	subobjectlevel = baseSubLevel -- restore the base subobject level
	print ("Time to solve: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
)--end script