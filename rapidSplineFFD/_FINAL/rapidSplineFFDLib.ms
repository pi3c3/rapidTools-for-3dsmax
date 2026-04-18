global rtsFFD
global rapidSplineFFDSettings
global rapidSDActive
global rapidSplineFFD

struct rapidTools_SFFD (
	
	--------------------- SETTINGS VARIABLES ---------------------
	iniFile = undefined,
	theSegmentsState = undefined,
	theSplineMethodState = undefined,
	theLoopMethodState = undefined,
	theDynVertRateState = undefined,
	theSimpleModeState = undefined,
	theAdvancedModeState = undefined,

	----------------------- MESH VARIABLES -----------------------
	theObject = undefined,
	theSelection = undefined,
	theSpline = undefined,
	firstVert = undefined,
	firstEdge = undefined,

	--------------------------- FLAGS ----------------------------
	isClosedLoop = false,
	splineFlag = false,
	fixedState = false, -- this one will control the vertexRatio --> fixed to the spline or to the original loop 
	softSelFlag = false,
	GUIUpdateFlag = true,
	isSDActive = false,

	------------------------ DATA ARRAYS -------------------------
	sublevel = 0,
	vertLoop = #(),
	edgeLoop = #(),
	orderedVertLoop = #(),
	mainSelWeights = #(),
	weightMap = #(),
	baseSplineKnotPosArray = #(),
	baseVertLoopPosArray = #(),
	vertRateFixed = #(),

	-------------------- FUNCTINOS FROM HERE ---------------------
	
	function getSimpAdvState = (
		if (getUserProp theSpline "storedSimpleModeState") == true then (
			setUserProp theSpline "storedSimpleModeState" true
			setUserProp theSpline "storedAdvancedModeState" false
			rapidSplineFFDSettings.loopMethod.enabled = true
			rapidSplineFFDSettings.dynVertRate.enabled = false
			theSimpleModeState = true
			theAdvancedModeState = false
		)
		if (getUserProp theSpline "storedSimpleModeState") == false then (
			setUserProp theSpline "storedSimpleModeState" false
			setUserProp theSpline "storedAdvancedModeState" true
			rapidSplineFFDSettings.loopMethod.enabled = false
			rapidSplineFFDSettings.dynVertRate.enabled = true
			theSimpleModeState = false
			theAdvancedModeState = true
		)
	),
	
	function updateRollout = ( --updates the rollout
		theSelection = $
		if classof theSelection == SplineShape or classof theSelection == line do (
			if matchPattern (theSelection.name) pattern:"rapidFFDSpline*" == true then (
				theSpline = theSelection
				
				if GUIUpdateFlag == true then (
					
				theDynVertRateState = getUserProp theSpline "storedDynVertRateState"
				if theDynVertRateState < 50 then theLoopMethodState = 1
				if theDynVertRateState > 50 then theLoopMethodState = 2
					
				getSimpAdvState()
					
				rapidSplineFFDSettings.theSegments.value = theSegmentsState
				rapidSplineFFDSettings.splineMethod.state = theSplineMethodState
				rapidSplineFFDSettings.loopMethod.state = theLoopMethodState
				rapidSplineFFDSettings.dynVertRate.value = theDynVertRateState
				rapidSplineFFDSettings.simpleMode.state = theSimpleModeState
				rapidSplineFFDSettings.advancedMode.state = theAdvancedModeState
				)
			)
		)
	),
	
	function updateMesh = ( -- udaptes the mesh
		if isSDActive == true do (
			if theObject.useSoftSelection == true do (
				if theSpline != undefined do (
					if isValidNode theSpline == true then (
						rtsffd.moveVertsSoft()
					)
				)
			)
			if theObject.useSoftSelection == false do (
				if theSpline != undefined do (
					if isValidNode theSpline == true then (
						rtsffd.moveVerts()
					)
				)
			)
		)
	),


	------------------------------------------------------ MAIN LOOP FUNCTIONS ------------------------------------------------------
	function getLoop theObject = ( -- returns an ordered Loop as an array
		selectedEdges = polyop.getEdgeSelection theObject
		selectedEdges
	),

	function getFirstVert theObject rev = ( -- returns the first vertex of the loop if rev = false, last vertex if rev = true, undefined if it's a closed loop
		
		endVerts = #()
		vertLoopArray = #()
		edgeLoop = polyop.getEdgeSelection theObject as array
		
		for i = 1 to edgeLoop.count do ( -- get the end vertices of the loop
			edgeVerts = polyop.getEdgeVerts theObject edgeLoop[i]
			for j = 1 to edgeVerts.count do (
				appendifunique vertLoopArray edgeVerts[j]
				if appendIfUnique endVerts edgeVerts[j] == false do (
					indexOfVert = findItem endVerts edgeVerts[j]
					deleteItem endVerts indexOfVert
				)
			)
		)

		if 	endVerts != undefined then (
			if rev == true do (
				return endVerts[1]
			)		
			if rev == false do (
				return endVerts[2]
			)
		)
		else return undefined
	),

	function getOrderedVertLoop theObject = ( -- generate an array containing the loop vertexes successively in order
		
		firstVert = getFirstVert theObject true
		if firstVert == undefined do ( -- if firstVert is undefined it sets the firs vert value to the firs element of the edge loop
			firstVert = ((polyop.getVertsUsingEdge theObject edgeLoop[1] as array)[1])
			isClosedLoop = true
		)
		
		firstEdge = (((polyop.getEdgesUsingVert theObject firstVert) as bitarray * edgeLoop as bitarray) as array)[1]
		lastVert = #{firstVert}
		lastEdge = #{firstEdge}
		orderedVertexLoop = #(firstVert)
		orderedEdgeLoop = #(firstEdge)
		
		for i = 1 to edgeLoop.count do (
			nextVert = (polyop.getVertsUsingEdge theObject lastEdge) - lastVert as bitarray
			lastVert = nextVert
			nextEdge = ((polyop.getEdgesUsingVert theObject lastVert) - lastEdge) * edgeLoop as bitarray
			lastEdge = nextEdge
			lastVert = lastVert as array
			append orderedVertexLoop lastVert[1] as array
		)	
		orderedVertexLoop
	),

	function getBaseVertLoopPosArray theVertArray = (
		
		theBaseVertArray = #()
		
		for i = 1 to theVertArray.count do (
			vertPos = polyop.getVert theObject theVertArray[i]
			append theBaseVertArray vertPos
		)
		theBaseVertArray
	),

	function getbaseSplineKnotPosArray theSpline = (
		
		theKnotPosArray = #()
		
		for i = 1 to numKnots theSpline 1 do (
			knotPos = getKnotPoint theSpline 1 i
			append theKnotPosArray knotPos
		)
		theKnotPosArray
	),

	------------------------------------------------------ LOOP LENGTH RATES TO KEEP ORIGINAL EDGE LEGHTS ------------------------------------------------------

	function getVertRateArray theObject vertLoop = (

		vertRateArray = #()
		nVertSectionLength = #(0)
		loopLength = 0
		loopVertRateArray = #()
		
		for i = 0 to ((vertLoop.count)-2) do (
			vert1 = polyop.getVert theObject vertLoop[i+1]
			vert2 = polyop.getVert theObject vertLoop[i+2]
			edgeLength = distance vert1 vert2
			loopLength = edgeLength + loopLength
			append nVertSectionLength loopLength
		)

		for i = 1 to vertLoop.count do (
			rate = nVertSectionLength[i] / loopLength
			append loopVertRateArray rate
		)
		loopVertRateArray
	),

	------------------------------------------------------ COORDINATE  FUNCTIONS ------------------------------------------------------

	function getPathCoordArray theSpline theCount forSpline: = ( -- generate the spline knot positions according to the amount of the theCount parameter
		
		coordArray = #()
		
		if (forSpline == true) do ( -- this is for generating the spline
			if isClosedLoop == false do (
				for i = 0 to theCount-1 do (
					vertRate = i/(theCount-1) as float
					if theSplineMethodState == 1 do thePosition = pathInterp theSpline 1 vertRate
					if theSplineMethodState == 2 do thePosition = lengthInterp theSpline 1 vertRate
					append coordArray thePosition
				)
			)
			if isClosedLoop == true do (
				for i = 0 to theCount do (
					vertRate = i/(theCount) as float
					if theSplineMethodState == 1 do thePosition = pathInterp theSpline 1 vertRate
					if theSplineMethodState == 2 do thePosition = lengthInterp theSpline 1 vertRate
					append coordArray thePosition
				)
			)
		)
			
		if (forSpline == unsupplied) do ( -- this is for moveVertsSoft
			if isClosedLoop == false do (
				for i = 0 to theCount-1 do (
					vertRate = i/(theCount-1) as float
					if theSplineMethodState == 1 do thePosition = pathInterp theSpline 1 (vertRateFixed[i+1] - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))
					if theSplineMethodState == 2 do thePosition = lengthInterp theSpline 1 (vertRateFixed[i+1] - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))
					append coordArray thePosition
				)
			)
			if isClosedLoop == true do (
				for i = 0 to theCount do (
					vertRate = i/(theCount) as float
					if theSplineMethodState == 1 do thePosition = pathInterp theSpline 1 (vertRateFixed[i+1] - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))
					if theSplineMethodState == 2 do thePosition = lengthInterp theSpline 1 (vertRate - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))

					append coordArray thePosition
				)
			)
		)
		coordArray
	),

	function getVertCoordArray theObject vertlist = ( -- generate an array of the selected loop vertexes position array
		
		coordArray = #()
		
		for i = 1 to vertlist.count do (
			thePosition = polyop.getVert theObject vertlist[i]
			append coordArray thePosition
		)
		coordArray
	),
	
	------------------------------------------------------ THE SPLINE/VERTEX OFFSET ------------------------------------------------------

	function getOffsetArray theObject = ( -- this one generates an offset array from the actual and destination position -- returns into an array
		
		vertCoords = getVertCoordArray theObject orderedVertLoop -- actual position
		pathCoords = getPathCoordArray theSpline vertCoords.count -- destination
		
		offsetArray = #() -- desination - actual position
		
		for i = 1 to vertCoords.count do (
			coord = pathCoords[i] - vertCoords[i]
			append offsetArray coord
		)
		offsetArray
	),

	function getBaseOffsetArray theObject = (

		vertCoords = getVertCoordArray theObject orderedVertLoop -- actual position
		baseVertCoords = baseVertLoopPosArray -- destination
		
		offsetArray = #() -- desination - actual position
		
		for i = 1 to vertCoords.count do (
			coord = baseVertCoords[i] - vertCoords[i]
			append offsetArray coord
		)
		offsetArray
	),

	------------------------------------------------------ SPLINE GENERATING FUNCTIONS ------------------------------------------------------

	function storeBaseKnots theSpline = ( -- stores the original knot positions 
		
		knotPosArray = #()
		
		for i = 1 to numKnots theSpline 1 do (
			knotPos = getKnotPoint theSpline 1 i
			append knotPosArray knotPos
		)
		knotPosArray
	),

	function removeKnots theSpline = ( -- clears all of the old non-uniform knots
		for i = 1 to (numKnots theSpline 1) do (
			deleteKnot theSpline 1 1
		)
	),

	function setNewKnots theSpline posArray = ( -- this function sets the new positions of the inner knots of the spline 

		if isClosedLoop == true do deleteItem posArray posArray.count
		
		for i = 1 to posArray.count do (
			addKnot theSpline 1 #smooth #curve posArray[i]
		)
		updateShape theSpline
	),

	function createShape vertLoop theName = ( -- this is what normally create spline from selection would do, but this uses the vertexes instead of the loop, IN ORDER.
		
		newSpline = theSpline = undo on(splineShape name:theName)
		addNewSpline newSpline 
		
		for i = 1 to vertLoop.count do (
			addKnot newSpline 1 #smooth #curve (polyop.getVert theObject (vertLoop[i]))
		)
		updateShape newSpline
		
		if getKnotPoint newSpline 1 1 == getKnotPoint newSpline 1 (numKnots newSpline 1) do (
			deleteKnot newSpline 1 (numKnots newSpline 1)
			close newSpline 1
		)
		theSpline
	),

	function getNormSpline theObject segs = ( -- this function generate a uniform spline from the selected loop
		createShape orderedVertLoop (uniqueName "rapidFFDSpline")
		
		select theSpline
		if isClosed theSpline 1 == true then (
			isClosedLoop = true
		)
		else if isClosed theSpline 1 == false then (
			isClosedLoop = false
		)
		baseSplineKnotPosArray = storeBaseKnots theSpline
		newPos = getPathCoordArray theSpline segs forSpline:true -- NUMBER OF SEGMENTS THE SPLINE CONTAINS
		removeKnots theSpline
		setNewKnots theSpline newPos
		subobjectlevel = 1
		updateShape theSpline
		splineFlag = true
		theSpline
	),

	------------------------------------------------------ WEIGHT FUNCTIONS FOR SOFT SELECTION ------------------------------------------------------

	function getAllWeights theObject = (
		
		weightArray = #()
		
		for i = 1 to polyop.getNumVerts theObject do (
			append weightArray (polyop.getVDataValue theObject 1 i)
		)
		weightArray
	),

	function genWeightMap theObject = (
		
		weightMap = #()
		
		mainSelWeights = getAllWeights theObject
		
		for i = 1 to orderedVertLoop.count do ( 
			
			weight = #()
			mainVertex = #()
			weightTable = #()
			subobjectlevel = 1
			polyop.setVertSelection theObject orderedVertLoop[i] -- kijelöli az elso mainVertexet
			
			append mainVertex orderedVertLoop[i]
			
			for j = 1 to polyop.getNumVerts theObject do ( 
				
				weight = polyop.getVDataValue theObject 1 j -- lekérdezi a mainVertexhez tartozó weight értéket
				
				if weight > 0 do ( -- megnézi nagyobb-e nullánál. Ha igen akkor
					
					if weight == mainSelWeights[j] do (-- összeveti az eredeti értékével és ha egyezik akkor azt a vertexet ami a weight-hez tartozik, a weightTable-be írja.
						append weightTable j
					)
				)
			)
			mainVertWeightArray = #(mainVertex[1], weightTable)
			append weightMap mainVertWeightArray
		)
		weightMap
	),
	
	------------------------------------------------------ THE MOVING FUNCTIONS ------------------------------------------------------

	function moveVerts = (
		
		for i = 0 to orderedVertLoop.count-1 do (
			vertRate = i/(orderedVertLoop.count-1) as float
			if theSplineMethodState == 1 do thePosition = pathInterp theSpline 1 (vertRateFixed[i+1] - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))
			if theSplineMethodState == 2 do thePosition = lengthInterp theSpline 1 (vertRateFixed[i+1] - ((vertRateFixed[i+1] - vertRate) * theDynVertRateState/100))
			polyop.setVert theObject #{orderedVertLoop[i+1]} thePosition
		)
		update theObject
	),

	function moveVertsSoft = (
		
		if theSpline != undefined then (
			offset = getOffsetArray theObject
			
			for i = 1 to orderedVertLoop.count do (
				polyop.moveVert theObject weightMap[i][2] offset[i] useSoftSel:true
			)
			update theObject
		)
		else (deleteAllChangeHandlers(); destroyDialog rapidSDActive; select theObject; subobjectlevel = 2; messageBox "Spline has been undoed or deleted!")
	),

	------------------------------------------------------ DATA SAVE FUNCTIONS ------------------------------------------------------

	function storeData theSpline = (
		setUserPropBuffer theSpline ""
		options.printAllElements = true -- this must be set to TRUE, so the listener can list out all elements of the array instead of 20 elements
			
		setUserProp theSpline "myObject" theObject.name
		setUserProp theSpline "storedWeightMap" weightMap
		setUserProp theSpline "storedOrderedVertLoop" orderedVertLoop
		setUserProp theSpline "storedMainSelWeights" mainSelWeights
		setUserProp theSpline "storedEdgeLoop" edgeLoop
		setUserProp theSpline "storedVertRateFixed" vertRateFixed
		setUserProp theSpline "storedBaseSplineKnotPosArray" baseSplineKnotPosArray
		setUserProp theSpline "storedVertLoopPosArray" baseVertLoopPosArray
		setUserProp theSpline "storedSegmentsState" theSegmentsState
		setUserProp theSpline "storedSplineMethodState" theSplineMethodState
		setUserProp theSpline "storedLoopMethodState" theLoopMethodState
		setUserProp theSpline "storedDynVertRateState" theDynVertRateState
		setUserProp theSpline "storedSimpleModeState" theSimpleModeState
		setUserProp theSpline "storedAdvancedModeState" theAdvancedModeState
		setUserProp theSpline "storedIsClosedLoop" isClosedLoop
	),

	function restoreData theSpline = (
		if (getUserProp theSpline "myObject" != "undefined") then theObject = execute ("$"+(getUserProp theSpline "myObject"))
		if (getUserProp theSpline "storedWeightMap" != "undefined") then weightMap = execute (getUserProp theSpline "storedWeightMap")
		if (getUserProp theSpline "storedOrderedVertLoop" != "undefined") then orderedVertLoop = execute (getUserProp theSpline "storedOrderedVertLoop")
		if (getUserProp theSpline "storedMainSelWeights" != "undefined") then mainSelWeights = execute (getUserProp theSpline "storedMainSelWeights")
		if (getUserProp theSpline "storedEdgeLoop" != "undefined") then edgeLoop = execute (getUserProp theSpline "storedEdgeLoop")
		if (getUserProp theSpline "storedVertRateFixed" != "undefined") then vertRateFixed = execute (getUserProp theSpline "storedVertRateFixed")
		if (getUserProp theSpline "storedBaseSplineKnotPosArray" != "undefined") then baseSplineKnotPosArray = execute (getUserProp theSpline "storedBaseSplineKnotPosArray")
		if (getUserProp theSpline "storedVertLoopPosArray" != "undefined") then baseVertLoopPosArray = execute (getUserProp theSpline "storedVertLoopPosArray")
		if (getUserProp theSpline "storedSegmentsState" != "undefined") then theSegmentsState = getUserProp theSpline "storedSegmentsState" as integer else theSegmentsState = 1
		if (getUserProp theSpline "storedSplineMethodState" != "undefined") then theSplineMethodState = getUserProp theSpline "storedSplineMethodState" as integer else theSplineMethodState = 1
		if (getUserProp theSpline "storedDynVertRateState" != "undefined") then theDynVertRateState = getUserProp theSpline "storedDynVertRateState" as integer else theDynVertRateState = 0
		if (getUserProp theSpline "storedLoopMethodState" != "undefined") then theLoopMethodState = getUserProp theSpline "storedLoopMethodState" as integer else theLoopMethodState = 1
		if (getUserProp theSpline "storedSimpleModeState" != "undefined") then theSimpleModeState = getUserProp theSpline "storedSimpleModeState" as booleanClass else theSimpleModeState = true
		if (getUserProp theSpline "storedAdvancedModeState" != "undefined") then theAdvancedModeState = getUserProp theSpline "storedAdvancedModeState" as booleanClass else theAdvancedModeState = false
		if (getUserProp theSpline "storedIsClosedLoop" != "undefined") then isClosedLoop = getUserProp theSpline "storedIsClosedLoop" as booleanClass else isClosedLoop = isClosed theSpline 1
	),

	function restoreSoftSelection theObject = (
		for i = 1 to mainSelWeights.count do (
			polyop.setVDataValue theObject 1 i mainSelWeights[i]
		)
	),

	------------------------------------------------------ BASIC SETTING QUERY ------------------------------------------------------

	function initSFFD = (
		
		GUIUpdateFlag = false
		makeDir (getDir #plugcfg + "\\" + "rapidTools" + "\\")
		iniFile = getDir #plugcfg + "\\" + "rapidTools" + "\\" + "rapidSplineFFD.ini"	
		
		if doesFileExist iniFile == false do (
			setINISetting iniFile "states" "segments" "4"
			setINISetting iniFile "states" "splineMethod" "1"
			setINISetting iniFile "states" "loopMethod" "1"
			setINISetting iniFile "states" "simpleMode" "true"
			setINISetting iniFile "states" "advancedMode" "false"
			setINISetting iniFile "states" "dynVertRate" "0"
		)
		
		------------------------------------ TESTING DEFAULT VALUES ------------------------------------
		
		if hasINISetting iniFile "states" "segments" == false do (
			setINISetting iniFile "states" "segments" "4"
		)
		
		if hasINISetting iniFile "states" "splineMethod" == false do (
			setINISetting iniFile "states" "splineMethod" "1"
		)
				
		if hasINISetting iniFile "states" "loopMethod" == false do (
			setINISetting iniFile "states" "loopMethod" "1"
		)
		
		if hasINISetting iniFile "states" "simpleMode" == false do (
			setINISetting iniFile "states" "simpleMode" "true"
		)
		
		if hasINISetting iniFile "states" "advancedMode" == false do (
			setINISetting iniFile "states" "advancedMode" "false"
		)
		
		if hasINISetting iniFile "states" "dynVertRate" == false do (
			setINISetting iniFile "states" "dynVertRate" "0"
		)
		
		------------------------------------ RESTORE DEFAULT VALUES ------------------------------------
		
		theSegmentsState = (getINISetting iniFile "states" "segments") as integer
		theSplineMethodState = (getINISetting iniFile "states" "splineMethod") as integer
		theloopMethodState = (getINISetting iniFile "states" "loopMethod") as integer
		theDynVertRateState = (getINISetting iniFile "states" "dynVertRate") as float
		theSimpleModeState = (getINISetting iniFile "states" "simpleMode") as booleanClass
		theAdvancedModeState = (getINISetting iniFile "states" "advancedMode") as booleanClass
	),

	function startDeform = (

		if classof theObject == Editable_Poly then (
			if subobjectLevel == 2 or subobjectLevel == 3 then (
				if ((polyop.getEdgeSelection theObject) as array).count != 0 then (
					if theObject.useSoftSelection == true then (
						edgeLoop = polyop.getEdgeSelection $ as array
						orderedVertLoop = getOrderedVertLoop theObject
						baseVertLoopPosArray = getBaseVertLoopPosArray orderedVertLoop -- saving the base vertex positions
						weightMap = genWeightMap theObject
						polyop.setVertSelection theObject orderedVertLoop
						theSpline = getNormSpline theObject theSegmentsState
						baseSplineKnotPosArray = getBaseSplineKnotPosArray theSpline
						vertRateFixed = getVertRateArray theObject orderedVertLoop -- vertRate creation
						
						if isClosedLoop == true do (
							orderedVertLoop = deleteItem orderedVertLoop orderedVertLoop.count
							weightMap = deleteItem weightMap weightMap.count
						)
						
						setCommandPanelTaskMode #modify
						select theObject
						theObject.useSoftSel = true
						theObject.lockSoftSel = true
						select theSpline
						print ("Vertices in main loop: " + ((orderedVertLoop.count) as string))
						storeData theSpline
						theSimpleModeState = true
						theAdvancedModeState = false
						softSelFlag = true
						GUIUpdateFlag = true
						isSDActive = true
					)
					
					else if theObject.useSoftSelection == false then (
						edgeLoop = polyop.getEdgeSelection $ as array
						orderedVertLoop = getOrderedVertLoop theObject
						baseVertLoopPosArray = getBaseVertLoopPosArray orderedVertLoop -- saving the base vertex positions
						theSpline = getNormSpline theObject theSegmentsState
						baseSplineKnotPosArray = getBaseSplineKnotPosArray theSpline
						vertRateFixed = getVertRateArray theObject orderedVertLoop -- vertRate creation
						storeData theSpline
						select theSpline
						print ("Vertexes count in loop: " + ((orderedVertLoop.count) as string))
						storeData theSpline
						theSimpleModeState = true
						theAdvancedModeState = false
						GUIUpdateFlag = true
						isSDActive = true
					)
				)
				else messageBox "Please Select an edgeloop in edge or border subobject mode!"
			)
			else messageBox "Please Select at least one edge"
		)
		else if (classof theObject == line) or (classof theObject == SplineShape) then (
			theSpline = theObject
			restoreData theSpline
			splineFlag = true
			
			if weightMap.count == 0 then (
				isSDActive = true
				GUIUpdateFlag = true
			)
			
			else if weightMap.count >= 1 then (
				setCommandPanelTaskMode #modify
				select theObject
				softSelFlag = true
				theObject.lockSoftSel = true
				restoreSoftSelection theObject
				theObject.useSoftSelection = true
				select theSpline
				subobjectlevel = 1
				isSDActive = true
				GUIUpdateFlag = true
			)
		)
		else messageBox "Please Select an Editable Poly or a Spline Object!"
	),

----------------------------------------------------------------------------------------------------------
	function rapidSplineFFD = (

		rtsFFD.theObject = $

		if classof rtsFFD.theObject == Editable_Poly then (
			if rtsFFD.sublevel == 2 or rtsFFD.sublevel == 3 then (
				if ((polyop.getEdgeSelection rtsFFD.theObject) as array).count != 0 then (
					if rtsFFD.theObject.useSoftSelection == true then (
						rtsFFD.initSFFD()
						rtsFFD.startDeform()
						
						createDialog rapidSDActive
						when geometry rtsFFD.theSpline changes id:#conformCallback do (
							if rtsFFD.theSpline != undefined do rtsFFD.moveVertsSoft()
						)
					)
					else if rtsFFD.theObject.useSoftSelection == false then (
						rtsFFD.initSFFD()
						rtsFFD.startDeform()
						
						createDialog rapidSDActive
						when geometry rtsFFD.theSpline changes id:#conformCallback do (
							if rtsFFD.theSpline != undefined do rtsFFD.moveVerts()
						)
					)
				)
			)
		)
		else if (classof rtsFFD.theObject == line) or (classof rtsFFD.theObject == SplineShape) then (
			if rtsFFD.weightMap.count == 0 then (
				rtsFFD.initSFFD()
				rtsFFD.startDeform()
			
				createDialog rapidSDActive
				when geometry rtsFFD.theSpline changes id:#conformCallback do (
					if rtsFFD.theSpline != undefined do rtsFFD.moveVerts()
				)
			)
			else if rtsFFD.weightMap.count >= 1 then (
				rtsFFD.initSFFD()
				rtsFFD.startDeform()
			
				createDialog rapidSDActive
				when geometry rtsFFD.theSpline changes id:#conformCallback do (
					if rtsFFD.theSpline != undefined do rtsFFD.moveVertsSoft()
				)
			)
		)
	),
----------------------------------------------------------------------------------------------------------	

	on create do (
		theObject = $
		sublevel = subobjectlevel
		initSFFD()
	)
)

if rapidSDActive == undefined then (
	rollout rapidSDActive "Rapid SDeformer Active" width:208 height:64 (
		
		checkButton activeBtn "Rapid SDeformer Active" pos:[8,8] width:192 height:48 checked:true
		
		on activeBtn changed state do (
			deleteAllChangeHandlers id:#conformCallback
			if isValidNode rtsFFD.theSpline != false do (
				undo on (delete rtsFFD.theSpline)
				select rtsFFD.theObject
				)
			if classOf rtsFFD.theObject == Editable_Poly do (
				rtsFFD.theObject.lockSoftSel = false
				subobjectlevel = 2
			)
			redrawViews()
			destroyDialog rapidSDActive
			rtsFFD.isSDActive = false
		)
		
		on activeBtn rightclick do (
			deleteAllChangeHandlers id:#conformCallback
			if isValidNode rtsFFD.theSpline != false do rtsFFD.storeData rtsFFD.theSpline
			select rtsFFD.theObject
			if classOf rtsFFD.theObject == Editable_Poly do (
				rtsFFD.theObject.lockSoftSel = false
				if rtsFFD.splineFlag == false then subobjectlevel = 2
				if rtsFFD.splineFlag == true then select rtsFFD.theSpline; subobjectlevel = 0
			)
			redrawViews()
			destroyDialog rapidSDActive
			rtsFFD.isSDActive = false
		)
	)
)

if rapidSplineFFDSettings == undefined then (
	rollout rapidSplineFFDSettings "RapidSplineFFD" width:184 height:436 (
			
		groupBox grp1 "Basic Settings" pos:[8,84] width:168 height:250
		groupBox grp2 "Loop Proportion" pos:[16,190] width:152 height:136
		groupBox grp3 "Spline Interpolation Method" pos:[16,128] width:152 height:48

		spinner theSegments "Knots:  " pos:[38,104] width:100 height:16 type:#integer range:[2,1000,rtsFFD.theSegmentsState]
		
		radioButtons splineMethod "" pos:[24,150] width:119 height:30 enabled:true labels:#("Segment", "Spline") default:rtsFFD.theSplineMethodState columns:2
		radioButtons loopMethod "" pos:[24,232] width:115 height:16 enabled:rtsFFD.theSimpleModeState labels:#("Fixed", "Even") default:rtsFFD.theLoopMethodState columns:2
		slider dynVertRate "" pos:[28,280] width:140 height:25 type:#float ticks:4 enabled:rtsFFD.theAdvancedModeState range:[0,100,rtsFFD.theDynVertRateState]
		
		checkbox simpleMode "Simple Mode" pos:[24,208] width:128 height:16 checked:rtsFFD.theSimpleModeState
		checkbox advancedMode "Advanced Mode" pos:[24,260] width:128 height:16 checked:rtsFFD.theAdvancedModeState
		
		button strtDeform "Start Spline FFD" pos:[8,340] width:168 height:24
		button rstSpline "Reset Spline" pos:[8,372] width:168 height:24
		button rstMesh "Reset Mesh" pos:[8,404] width:168 height:24
		
		bitmap rapidSplineFFDHeader "Bitmap" pos:[8,8] width:168 height:64 fileName:((getdir #userscripts) + "\\rapidTools\\rapidSplineFFD_header.png")
		
		on theSegments changed state do (
			setINISetting rtsFFD.iniFile "states" "segments" (state as string)
		)
		
		on splineMethod changed state do (
			setINISetting rtsFFD.iniFile "states" "splineMethod" (state as string)
			rtsFFD.theSplineMethodState = splineMethod.state
			rtsFFD.updateMesh()
		)
			
		on loopMethod changed state do (
			setINISetting rtsFFD.iniFile "states" "loopMethod" (state as string)
			rtsFFD.theLoopMethodState = loopMethod.state
			
			if loopMethod.state == 1 do (
				dynVertRate.value = 0
				rtsFFD.theDynVertRateState = dynVertRate.value
			)
			
			if loopMethod.state == 2 do (
				dynVertRate.value = 100
				rtsFFD.theDynVertRateState = dynVertRate.value
			)
			rtsFFD.updateMesh()
		)
		
		on dynVertRate changed state do (
			setINISetting rtsFFD.iniFile "states" "dynVertRate" (state as string)
			rtsFFD.theDynVertRateState = dynVertRate.value
			rtsFFD.updateMesh()
		)
		
		on simpleMode changed state do (
			setINISetting rtsFFD.iniFile "states" "simpleMode" "true"
			rtsFFD.theSimpleModeState = true
			rapidSplineFFDSettings.simpleMode.state = true
			setINISetting rtsFFD.iniFile "states" "advancedMode" "false"
			rtsFFD.theAdvancedModeState = false
			rapidSplineFFDSettings.advancedMode.state = false
			
			rapidSplineFFDSettings.dynVertRate.enabled = false
			rapidSplineFFDSettings.loopMethod.enabled = true
			if rapidSplineFFDSettings.dynVertRate.value < 50 do rapidSplineFFDSettings.loopMethod.state = 1
		)
		
		on advancedMode changed state do (
			setINISetting rtsFFD.iniFile "states" "simpleMode" "false"
			rtsFFD.theSimpleModeState = false
			rapidSplineFFDSettings.simpleMode.state = false
			setINISetting rtsFFD.iniFile "states" "advancedMode" "true"
			rtsFFD.theAdvancedModeState = true
			rapidSplineFFDSettings.advancedMode.state = true
			
			rapidSplineFFDSettings.dynVertRate.enabled = true
			rapidSplineFFDSettings.loopMethod.enabled = false
			if rapidSplineFFDSettings.dynVertRate.value > 50 do rapidSplineFFDSettings.loopMethod.state = 2
		)

		on strtDeform pressed do (
			rtsFFD.rapidSplineFFD()
		)
		
		on rstMesh pressed do ( --baseVertLoopPosArray baseSplineKnotPosArray
			if isValidNode rtsFFD.theObject == true and rtsFFD.baseVertLoopPosArray != undefined then (
				with redraw on
				if rtsFFD.softSelFlag == false then (
					for i = 1 to rtsFFD.orderedVertLoop.count do (
						polyop.setVert rtsFFD.theObject rtsFFD.orderedVertLoop[i] rtsFFD.baseVertLoopPosArray[i]
					)
				)
				
				if rtsFFD.softSelFlag == true then (
					baseOffsetArray = rtsFFD.getBaseOffsetArray rtsFFD.theObject
					
					for i = 1 to rtsFFD.orderedVertLoop.count do (
						polyop.moveVert rtsFFD.theObject rtsFFD.weightMap[i][2] baseOffsetArray[i] useSoftSel:true
					)
				)
				update rtsFFD.theObject
				redrawViews()
			)
		)
		
		on rstSpline pressed do (
			if isValidNode rtsFFD.theSpline == true and rtsFFD.baseSplineKnotPosArray != undefined then (
				with redraw on
				for i = 1 to rtsFFD.baseSplineKnotPosArray.count do (
					setKnotPoint rtsFFD.theSpline 1 i rtsFFD.baseSplineKnotPosArray[i]
				)
				updateShape rtsFFD.theSpline
				redrawViews()
			)
		)
		
		-- CALLBACKS FOR DYNAMIC USER fOPS
		on rapidSplineFFDSettings open do (
			rtsFFD.updateRollout()
			callbacks.addScript #selectionSetChanged "rtsFFD.updateRollout()" id:#rolloutUpdate
		)
			
		on rapidSplineFFDSettings close do (
			callbacks.removeScripts id:#rolloutUpdate
		)
	)
)