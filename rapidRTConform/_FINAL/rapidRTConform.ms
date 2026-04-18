-- macroScript rapidRTConform buttonText:"RapidRTConform" category:"rapidTools" toolTip:"rapidRTConform" (

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------ BASIC VARIABLES ------------------------------------------------------------------------------------
	-- base objects
	global theObj
	global theTarget
	global TMDummy
	-- vertex selection
	global vertCount
	global vertSelArray
	global vertSelArrayA
	-- vertex refrence objects
	global vertPosArray
	global vertNormalArray
	-- trimesh objects
	global theObjTrimesh
	global theTargetTrimesh
	-- base values
	global basePos
	global baseRot
	global baseScale
	-- states of double sided methodology
	global targetState
	global objectState
	-- GUI declaration
	global RapidConformActive

------------------------------------------------------------------------------------ BASIC VARIABLES ------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------- PRE-CACHE METHODS ---------------------------------------------------------------------------------

	global gn = getNormal
	global mGV = meshop.getVert
	global iR = intersectRay
	global sV = polyop.setVert
	global gVS = polyop.getVertSelection

--------------------------------------------------------------------------------- PRE-CACHE METHODS ---------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------ BASIC FUNCTIONS ------------------------------------------------------------------------------------

	function getVertNormalArray theObj = (

		vertNormalArray = #()
		vertNormalArray[vertCount] = 0
		
		for i = 1 to vertCount do vertNormalArray[i] = normalize(gn theObjTrimesh vertSelArrayA[i])
		
		vertNormalArray
	)

	function getVertPosArray theObj = (
		
		vertPosArray = #()
		vertPosArray[vertCount] = 0
		
		for i = 1 to vertCount do vertPosArray[i] = mGV theObjTrimesh vertSelArrayA[i]
			
		 vertPosArray
	)
	
	function getIntersectRay theObj theTarget = (
		
		vertNormalArray = getVertNormalArray theObj
		vertPosArray = getVertPosArray theObj
		
		intersectRayArray = #()
		intersectRayArray[vertCount] = 0
		
		for i = 1 to vertCount do (
			intersectRayData = iR theTargetTrimesh (ray vertPosArray[i] vertNormalArray[i])
			if intersectRayData == undefined then intersectRayData = ray(vertPosArray[i])[0,0,0]
			intersectRayArray[i] = intersectRayData
		)
		
		 intersectRayArray
	)
	
	function gatherConformData theObj theTarget = ( -- generating and gathering the data that is necessary for the conformation
		
		vertSelArray = gVS theObj -- vertex selection dependent data structures
		vertSelArrayA = vertSelArray as array
		vertCount = vertSelArrayA.count
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		undo on (theObjTrimesh = (snapshot theObj name: (uniquename "tempObjMesh")))
		meshop.flipNormals theObjTrimesh #{1..(meshop.getNumFaces theObjTrimesh)}
		
		undo on (theTargetTrimesh = (snapshot theTarget name: (uniquename "tempTargetMesh")))
		
		if targetState == true then (
			theTargetTrimeshDS = (snapshot theTarget name: (uniquename "tempTargetMeshDS"))	
			meshop.flipNormals theTargetTrimeshDS #{1..(meshop.getNumFaces theTargetTrimeshDS)}
			attach theTargetTrimesh theTargetTrimeshDS -- this makes the conformation capable on both sides of the target mesh	
		)
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		hide theObjTrimesh
		hide theTargetTrimesh
		
		vertTargetRayArray = getIntersectRay theObjTrimesh theTargetTrimesh
		vertTargetRayArrayCount = vertTargetRayArray.count
		
		vertTargetPosArray = #()
		vertTargetPosArray[vertCount] = 0
		
		for i = 1 to vertTargetRayArrayCount do vertTargetPosArray[i] = vertTargetRayArray[i].pos
	)
	
	function gatherConformDataInt theObj theTarget = ( -- generating and gathering the data that is necessary for the conformation
		
		vertSelArray = gVS theObj -- vertex selection dependent data structures
		vertSelArrayA = vertSelArray as array
		vertCount = vertSelArrayA.count
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		undo on (theObjTrimesh = (snapshot theObj name: (uniquename "tempObjMesh")))
		meshop.flipNormals theObjTrimesh #{1..(meshop.getNumFaces theObjTrimesh)}
		
		undo on (theTargetTrimesh = (snapshot theTarget name: (uniquename "tempTargetMesh")))
		
		if targetState == true then (
			theTargetTrimeshDS = (snapshot theTarget name: (uniquename "tempTargetMeshDS"))	
			meshop.flipNormals theTargetTrimeshDS #{1..(meshop.getNumFaces theTargetTrimeshDS)}
			attach theTargetTrimesh theTargetTrimeshDS -- this makes the conformation capable on both sides of the target mesh	
		)
		
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			
		theObj.pos = [0,0,0]
		theObjTrimesh.pos = [0,0,0]
		
		undo on (theObj.parent = TMDummy = (Point pos:[0,0,0] isSelected:on name: (uniquename "TMDummy")))
		TMDummy.size = 25
		TMDummy.drawOnTop = true
		TMDummy.box = true
		theObjTrimesh.parent = TMDummy
			
		hide theObjTrimesh
		hide theTargetTrimesh
			
		freeze theObjTrimesh
		freeze theTargetTrimesh
			
		theObjTrimesh.xray = true
		theTargetTrimesh.xray = true
		
		vertTargetRayArray = getIntersectRay theObjTrimesh theTargetTrimesh
		vertTargetRayArrayCount = vertTargetRayArray.count
		
		vertTargetPosArray = #()
		vertTargetPosArray[vertCount] = 0
		
		for i = 1 to vertTargetRayArrayCount do vertTargetPosArray[i] = vertTargetRayArray[i].pos
			
		TMDummy.pos = basePos
	)
	
	function conformInteractive = (
-- 		ts = timestamp()
		newNormals = getVertNormalArray tempObjMesh
		newPos = getVertPosArray tempObjMesh
		
		intersectRayArray = #()
		intersectRayArray[vertCount] = 0
			
		for i = 1 to vertCount do (
			intersectRayData = iR theTargetTrimesh (ray newPos[i] newNormals[i])
			if intersectRayData == undefined then intersectRayData = ray(newPos[i])[0,0,0]
			intersectRayArray[i] = intersectRayData
		)
		
		vertTargetPosArray = #()
		vertTargetPosArray[vertCount] = 0
		intersectRayArrayCount = intersectRayArray.count
		
		for i = 1 to intersectRayArrayCount do vertTargetPosArray[i] = intersectRayArray[i].pos
		
		sV theObj vertSelArray vertTargetPosArray
		
-- 		print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
	
	function conformInteractiveFlipped = (
-- 		ts = timestamp()
		newNormals = getVertNormalArray tempObjMesh
		newPos = getVertPosArray tempObjMesh
		
		intersectRayArray = #()
		intersectRayArray[vertCount] = 0
			
		for i = 1 to vertCount do (
			intersectRayData = iR theTargetTrimesh (ray newPos[i] -newNormals[i])
			if intersectRayData == undefined then intersectRayData = ray(newPos[i])[0,0,0]
			intersectRayArray[i] = intersectRayData
		)
		
		vertTargetPosArray = #()
		vertTargetPosArray[vertCount] = 0
		intersectRayArrayCount = intersectRayArray.count
		
		for i = 1 to intersectRayArrayCount do vertTargetPosArray[i] = intersectRayArray[i].pos
		
		sV theObj vertSelArray vertTargetPosArray
		
-- 		print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
	
	function conformInteractiveDS = (
-- 		ts = timestamp()
		newNormals = getVertNormalArray tempObjMesh
		newPos = getVertPosArray tempObjMesh
		
		intersectRayArray = #()
		intersectRayArray[vertCount] = 0
			
		for i = 1 to vertCount do (
			intersectRayData = iR theTargetTrimesh (ray newPos[i] newNormals[i])
			intersectRayDataINV = iR theTargetTrimesh (ray newPos[i] -newNormals[i])
			
			if intersectRayData == undefined and intersectRayDataINV == undefined then ( 
				intersectRayArray[i] = ray(newPos[i])[0,0,0]
			)
			
			if intersectRayData != undefined and intersectRayDataINV == undefined then ( 
				intersectRayArray[i] = intersectRayData
			)
			
			if intersectRayData == undefined and intersectRayDataINV != undefined then (
				intersectRayArray[i] = intersectRayDataINV
			)
			
			if intersectRayData != undefined and intersectRayDataInv != undefined then (
				if distance intersectRayData.pos newPos[i] > distance intersectRayDataINV.pos newPos[i] then intersectRayArray[i] = intersectRayDataINV
				if distance intersectRayData.pos newPos[i] < distance intersectRayDataINV.pos newPos[i] then intersectRayArray[i] = intersectRayData
				if distance intersectRayData.pos newPos[i] == distance intersectRayDataINV.pos newPos[i] then intersectRayArray[i] = intersectRayData
			)
		)
		
		vertTargetPosArray = #()
		vertTargetPosArray[vertCount] = 0
		intersectRayArrayCount = intersectRayArray.count
		
		for i = 1 to intersectRayArrayCount do vertTargetPosArray[i] = intersectRayArray[i].pos
		
		sV theObj vertSelArray vertTargetPosArray
		
-- 		print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
	)
	
	function startConform = (
		
	makeDir (getDir #plugcfg + "\\" + "rapidTools" + "\\")
	global iniFile = getDir #plugcfg + "\\" + "rapidTools" + "\\" + "rapidRTConform.ini"
			
		if doesFileExist iniFile == false do (
			setINISetting iniFile "states" "target" "false"
			setINISetting iniFile "states" "object" "false"
			setINISetting iniFile "states" "flipped" "false"
			setINISetting iniFile "states" "interactive" "true"
		)
		
		if hasINISetting iniFile "states" "target" == false do (
			setINISetting iniFile "states" "target" "false"
		)
			
		if hasINISetting iniFile "states" "object" == false do (
			setINISetting iniFile "states" "object" "false"
		)
		
		if hasINISetting iniFile "states" "flipped" == false do (
			setINISetting iniFile "states" "flipped" "false"
		)
		
		if hasINISetting iniFile "states" "interactive" == false do (
			setINISetting iniFile "states" "interactive" "true"
		)

		global targetState = execute (getINISetting iniFile "states" "target")
		global objectState = execute (getINISetting iniFile "states" "object")
		global flippedState = execute (getINISetting iniFile "states" "flipped")		
		global interactiveState = execute (getINISetting iniFile "states" "interactive")
		
		if interactiveState == True then (
			gatherConformDataInt theObj theTarget
		)
		else if interactiveState == False then (
			gatherConformData theObj theTarget
		)
		
		subobjectlevel = 0
		
		if objectState == false then (
			ts = timestamp()
			if flippedState == false then (
				conformInteractive()
			)
			else if flippedState == true then (
				conformInteractiveFlipped()
			)
			print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
			if interactiveState == true do (
				createDialog RapidConformActive
				if flippedState == false then (
					when geometry TMDummy changes id:#conformCallback do (
						if theObj != undefined do conformInteractive()
					)
				)
				else if flippedState == true do (
					when geometry TMDummy changes id:#conformCallback do (
						if theObj != undefined do conformInteractiveFlipped()
					)
				)
			)
			if interactiveState == false do (
				undo on (delete theTargetTrimesh)
				undo on (delete theObjTrimesh)
				select theObj
			)
		)
		
		if objectState == true then (
			ts = timestamp()
			conformInteractiveDS()
			print ("Time need for conformation: " + ((((timestamp() - ts) as float)/1000) as string) + " sec")
			if interactiveState == true do (
				createDialog RapidConformActive
				when geometry TMDummy changes id:#conformCallback do (
					if theObj != undefined do conformInteractiveDS()
				)
			)
			if interactiveState == false do (
				undo on (delete theTargetTrimesh)
				undo on (delete theObjTrimesh)
				select theObj
			)
		)
	)
	
------------------------------------------------------------------------------------ BASIC FUNCTIONS ------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------- DATA SAVE FUNCTIONS --------------------------------------------------------------------------------

-- 	function storeData theSpline = (
-- 		setUserPropBuffer theObj ""
-- 		options.printAllElements = true -- this must be set to TRUE, so the listener can list out all elements of the array instead of 20 elements
-- 		setUserProp theObj "basePos" basePos
-- 	)

-- 	function restoreData theSpline = (
-- 		if (getUserProp theSpline "myObject" != "undefined") then theObject = execute ("$"+(getUserProp theSpline "myObject"))
-- 	)

-------------------------------------------------------------------------------- DATA SAVE FUNCTIONS --------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------- PROGRAM FLOW CONTROL ------------------------------------------------------------------------------
	
	rollout RapidConformActive "Rapid Conform Active" width:208 height:64 (
	checkButton activeBtn "Rapid Conform Active" pos:[8,8] width:192 height:48 checked:true
	
	on activeBtn changed state do (
		deleteAllChangeHandlers id:#conformCallback
		destroyDialog RapidConformActive
		undo on (delete TMDummy)
		undo on (delete theTargetTrimesh)
		undo on (delete theObjTrimesh)
		select theObj
		)
	)
	
	--on activeBtn changed 
	function meshFilt obj = (superClassOf obj == GeometryClass) -- pickObject needs this function
	
	theObj = $
	
	if subobjectlevel != 0 or subobjectlevel != undefined and classof theObj == Editable_Poly then (
		sblevel = subobjectlevel
		theTarget = pickObject count:1 filter:meshFilt 

		if theTarget != undefined then (
			basePos = theObj.position
			baseRot = theObj.rotation
			baseScale = theObj.scale
		
			targetPos = theTarget.position
			targetRot = theTarget.rotation
			targetScale = theTarget.scale
		
			case sblevel of (
				5: theObj.convertSelection #element #vertex
				4: theObj.convertSelection #face #vertex
				3: theObj.convertSelection #border #vertex
				2: theObj.convertSelection #border #vertex
			)
			startConform()
		)
		else messageBox "Please select vertexes, edges or faces!"
	)
	else messageBox "Please select an Editable Poly object that you want to conform!"
-- )