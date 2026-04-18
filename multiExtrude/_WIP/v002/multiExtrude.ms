macroScript multiExtrude category:"rapidTools" tooltip:"multiExtrude" buttonText: "multiExtrude" (

	-- TO DO -- IF NO CHANGES OCCUR IN EDGE LIST THEN DETACH AS NEW OBJECT

	-- function cache
	-----------------------------------------------------------------------------------------------------
	cTP = convertToPoly
	cTSS = convertToSplineShape
	cO = classOf
	sCO = superclassOf
	aTT = polyop.attach
	aAW = addAndWeld
	sE = select
	uS = updateShape
	wSM = windows.sendmessage

	gCNHWND = windows.getChildrenHWND
	gCHWND = windows.getChildHWND

	gCO = modPanel.getCurrentObject()

	-- functions
	-----------------------------------------------------------------------------------------------------
	function stopGUI = (
		setCommandPanelTaskMode #modify
		try (
			WM_SETREDRAW=0xB
			commandHWND = gCHWND #max "Command Panel"
			wSM commandHWND[1]  WM_SETREDRAW 0 0
		)
		catch ()
	)

	function startGUI = (
		WM_SETREDRAW=0xB
		commandHWND = gCHWND #max "Command Panel"
		wSM commandHWND[1]  WM_SETREDRAW 1 0
	)

	function registerAutoAccept = (
		DialogMonitorOPS.unRegisterNotification id:#accept
		fn notification =
		(
			hwnd = DialogMonitorOPS.GetWindowHandle()
			DialogMonitorOPS.enabled = on
			UIAccessor.PressButtonByName hwnd "OK"
			DialogMonitorOPS.unRegisterNotification id:#accept
		)
		DialogMonitorOPS.RegisterNotification notification id:#accept

	)
	
	function unregisterAutoAccept = (
		DialogMonitorOPS.unRegisterNotification id:#accept
		DialogMonitorOPS.enabled = off
	)

	function getKnotList theObj = (
		nS = numSplines theObj
		sArr = #()
		sArr[nS] = 0
		for i = 1 to nS do (
			sArr[i] = #(i, (#{1..(numKnots $ i)} as array))
		)
		return sArr	
	)

	function getKnotSelectionList theObj = (
		nS = numSplines theObj
		sArr = #()
		sArr[nS] = 0
		for i = 1 to nS do (
			skPair = #(i, (getKnotSelection $ i))
			sArr[i] = skPair
		)
		return sArr
	)

	function getSegSelList theObj = (
		nS = numSplines theObj
		sArr = #()
		sArr[nS] = 0
		for i = 1 to nS do (
			skPair = #(i, (getSegSelection  $ i))
			sArr[i] = skPair
		)
		return sArr
	)

	function getSepSegSelList theobj = (
		ns = numsplines theobj
		sarr = #()
		
		for i = 1 to ns do (
			numsegs = numsegments theobj i
			segments = getsegselection $ i as bitarray
			
			first = undefined
			last = undefined
			allseglist = #()
			seglist = #()
			for j = 1 to numsegs+1 do (
				issel = segments[j]
				if issel then (
					append seglist j
				)
				else (
					if seglist.count != 0 then (	
						append allseglist seglist
						if seglist[1] == 1 then first = seglist
						if seglist[seglist.count] == numsegs then last = seglist
						seglist = #()
					)
				)
			)
			
			if first != undefined and last != undefined and isclosed theobj i then (
				join allseglist[allseglist.count] allseglist[1]
				deleteitem allseglist 1
			)

			for j in allseglist do (
				append sarr #(i, j)
			)
		)
		sarr
	)

	function numKnotsSelected theObj = (
		nS = numSplines theObj

		num = 0
		for i = 1 to nS do (
			num += (getKnotSelection $ i).count
		)
		return num
	)

	function getKnotsUsingSeg theObj skPairList = (
		skPairList = deepCopy skPairList
		skPairListCount = skPairList.count
		for i = 1 to skPairListCount do (
			knotList = #()
			splineKnotCount = skPairList[i][2].count

			closed = isClosed theObj skPairList[i][1]
			for j = 1 to splineKnotCount do (
				knotA = skPairList[i][2][j]
				knotB = knotA + 1
				if closed and knotB > numKnots theObj skPairList[i][1] then (
					knotB = knotB - 1
				)
				append knotList knotA
				append knotList knotB
			)
			knotList = makeUniqueArray knotList
			skPairList[i][2] = knotList
		)
		return skPairList
	)

	-- planned
	function getSegsUsingKnot theObj skPairList = (
		skPairListCount = skPairList.count
		for i = 1 to skPairListCount do (
			knotList = #{}
			splineKnotCount = skPairList[i][2].count
			for j = 1 to splineKnotCount do (
				knotA = skPairList[i][2][j]
				knotB = knotA + 1
				append knotList knotA
				append knotList knotB
			)
			skPairList[i][2] = knotList as array
		)
		return skPairList
	)

	function getSideKnots theObj skPairList = (



	)

	-- program flow
	-----------------------------------------------------------------------------------------------------
	sel = $selection as array

	if sel != undefined then (
		
		selCount = sel.count
		
		-- if more then one object is selected
		--------------------------------------
		if selCount > 1 then (
			-- Editable Patch is a crap, so we have no chance
			-- but converting it to an Editable Poly, so we can attach it
			for i in sel where cO i == Editable_Patch do cTP i
			for i in sel where cO i == Editable_Mesh do cTP i

			-- let's do check if it is and EPoly...
			-- If it isn't we have to walk through the list
			-- and check if there bis any...
			-- If there is, then it has to override the 
			-- first selection, so it become an EPoly
			mixed = False
			if cO sel[1] != Editable_Poly then (
				for i = 2 to selCount do (
					if cO sel[i] == Editable_Poly or cO sel[i] == PolyMeshObject then (
						mixed = True
						exit
					)
				)
			)
			-- if it is a mixed array, then let's convert everything into an Editable Poly object
			if mixed then (
				for i in sel where cO != Editable_Poly or cO i != PolyMeshObject do cTP i
			)
			-- In case of geometryClass
			if sCO sel[1] == GeometryClass then (
				for i in sel where cO i != Editable_Poly or cO i != PolyMeshObject do cTP i
				if cO sel[1] == Editable_Poly then (
					for i = 2 to selCount do (
						aTT sel[1] sel[i]
					)
				)
				else if cO sel[1] == PolyMeshObject then (
					if cO sel[1].modifiers[1] == Edit_Poly then (
						stopGUI()
						sE sel[1]
						for i = 2 to selCount do (
							sel[1].modifiers[1].attach sel[i]
						)
						startGUI()
					)
				)
			)
			-- In case of shape class
			else if sCO sel[1] == shape then (
				if sel[1].modifiers.count == 0 then (
					
					stopGUI()
					
					if cO sel[1] != line or cO sel[1] != splineShape then cTSS sel[1]
					if cO sel[1] == line or cO sel[1] == splineShape then (
						for i = 2 to selCount do (
							cTSS sel[i]
							uS sel[1]
							aAW sel[1] sel[i] 0
						)
					)
					startGUI()
				)
				else if sel[1].modifiers.count > 0 then (
					stopGUI()
					if cO sel[1] == splineShape then (
						cTSS sel[1]
						uS sel[1]
						for i = 2 to selCount do (
							cTSS sel[i]
							uS sel[1]
							aAW sel[1] sel[i] 0
						)
					)
					startGUI()
				)
			)
		)

		-- if only single object is selected
		--------------------------------------------------------
		else if selCount == 1 then (
			class = cO sel[1]
			sel = sel[1]

			-- if subobjectlevel is zero then simply activate the attach mode
			-----------------------------------------------------------------
			if subobjectlevel == 0 then ( -- EXPLODE -- BAAAAAAAAAAAAAAAAANG (NOT YET)
				if class == Editable_Poly or class == PolyMeshObject then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				)
				else if class == line or class == splineShape then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				) 
				else if class == Editable_Patch then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				) 
				else if class == Editable_Mesh then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				)
			)

			-- SUBOBJECT LEVEL 1
			----------------------------------------------------------------
			if subobjectlevel == 1 then (
				-- EDITABLE POLY
				if class == Editable_Poly  then (
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
				)
				-- EDITABLE MESH
				else if class == Editable_Mesh then (
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (

				)
			)

			-- SUBOBJECT LEVEL 2
			----------------------------------------------------------------
			else if subobjectlevel == 2 then (
				-- EDITABLE POLY				
				if class == Editable_Poly then (
					newName = uniquename (sel.name + "_shape")
					polyop.createShape sel (polyop.getEdgeSelection sel) smooth:False name:newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
					newName = uniquename (sel.name + "_shape")
					gCO.createShape newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					registerAutoAccept()
					meshOps.createShapeFromEdges sel
					unregisterAutoAccept()
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					-- segment extrusion
					segmentList = getSepSegSelList sel
					knotList = getKnotsUsingSeg sel segmentList

					si = 0
					lastSpline = 1
					max select none
					for i = 1 to knotList.count do (
						if knotList[i][2].count != 0 then (
							
							if lastSpline != knotList[i][1] then (
								lastSpline = knotList[i][1]
								si = 0
							)

							firstPos = getKnotPoint sel knotList[i][1] (knotList[i][2][1] + si)
							lastPos = getKnotPoint sel knotList[i][1] (knotList[i][2][knotList[i][2].count] + si)

							segA = (segmentList[i][2][1] + 1 + si)
							segB = (segmentList[i][2][segmentList[i][2].count] + 2 + si)
						
							addKnot sel knotList[i][1] #corner #curve firstPos segA
							addKnot sel knotList[i][1] #corner #curve lastPos segB

							if knotList[i][2][knotList[i][2].count] - knotList[i][2][1] == knotList[i][2].count - 1 then (

								if segB > (numSegments sel segmentList[i][1]) then segB = segB
								else segB = segB-1

								segSelList = #{segA..segB} as array
							)
							else (
								sort segmentList[i][2]
								iter = 0
								shift = False
								segSelList = #()
								for i in segmentList[i][2] do (
									if i - iter == 1 and shift == False then (
										append segSelList (i)
										iter += 1
									)
									else (
										append segSelList (i + 2 + si)
									)
								)
							)
							si += 2
							updateShape sel
							setSegSelection sel segmentList[i][1] segSelList keep:True
							)
						)
					)
				)
			)
			-- SUBOBJECT LEVEL 3
			----------------------------------------------------------------
			else if subobjectlevel == 3 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					newName = uniquename (sel.name + "_shape")
					polyop.createShape sel (polyop.getEdgeSelection sel) smooth:False name:newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
					newName = uniquename (sel.name + "_shape")
					gCO.createShape newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					newMesh = meshop.detachFaces sel (getFaceSelection sel) delete:true asMesh:true
					emesh = Editable_mesh() --create an empty Editable_mesh
					emesh.mesh = newMesh --assign the detached faces to the new mesh
					emesh.pos = sel.pos
					update emesh --update the mesh 
				)
				else if class == splineShape or class == line then (
					registerAutoAccept()
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Detach" do UIAccessor.PressButton i[1]
					unregisterAutoAccept()
				)
			)
			-- SUBOBJECT LEVEL 4
			----------------------------------------------------------------
			else if subobjectlevel == 4 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					edgeCount = polyop.getNumEdges sel
					polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:false --name:newName
					newEdgeCount = polyop.getNumEdges sel
					if newEdgeCount == edgeCount then polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:true
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
					edgeCount = gCO.getNumEdges()
					gCO.ButtonOp #DetachFace
					newEdgeCount = gCO.getNumEdges()
					if edgeCount == newEdgeCount then gCO.detachToObject (uniquename(sel.name))
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					openEdges = (meshop.getOpenEdges sel).numberset
					newMesh = meshop.detachFaces sel (getFaceSelection sel) delete:true asMesh:false
					newOpenEdges = (meshop.getOpenEdges sel).numberset
					if newOpenEdges == openEdges then (
						newMesh = meshop.detachFaces sel (getFaceSelection sel) delete:true asMesh:true
						emesh = Editable_mesh() --create an empty Editable_mesh
						emesh.mesh = newMesh --assign the detached faces to the new mesh
						emesh.pos = sel.pos
						update emesh --update the mesh 
					)
				)
			)
			-- SUBOBJECT LEVEL 5
			----------------------------------------------------------------
			else if subobjectlevel == 5 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					edgeCount = polyop.getNumEdges sel
					polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:false --name:newName
					newEdgeCount = polyop.getNumEdges sel
					if newEdgeCount == edgeCount then polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:true
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
					edgeCount = gCO.getNumEdges()
					gCO.ButtonOp #DetachFace
					newEdgeCount = gCO.getNumEdges()
					if edgeCount == newEdgeCount then gCO.detachToObject (uniquename(sel.name))
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					openEdges = (meshop.getOpenEdges sel).numberset
					newMesh = meshop.detachFaces sel (getFaceSelection sel) delete:true asMesh:false
					newOpenEdges = (meshop.getOpenEdges sel).numberset
					if newOpenEdges == openEdges then (
						newMesh = meshop.detachFaces sel (getFaceSelection sel) delete:true asMesh:true
						emesh = Editable_mesh() --create an empty Editable_mesh
						emesh.mesh = newMesh --assign the detached faces to the new mesh
						emesh.pos = sel.pos
						update emesh --update the mesh 
					)
				)
			)
		)
	)
)