-- macroScript multiConnect category:"rapidTools" tooltip:"multiConnect" buttonText: "multiConnect" (

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
			-- before 3dsmax 2018 the Command panel name was: "Command Panel"
			-- from 3dsmax 2018 it has been renamed due to the change of the
			-- Qt5 system... From that version it's called: "CommandPanelWindow"
			commandHWND = gCHWND #max "Command Panel"
			if commandHWND == undefined then (
				commandHWND = gCHWND #max "CommandPanelWindow"
			)
			
			wSM commandHWND[1]  WM_SETREDRAW 0 0
		)
		catch ()
	)

	function startGUI = (
		WM_SETREDRAW=0xB
		-- before 3dsmax 2018 the Command panel name was: "Command Panel"
		-- from 3dsmax 2018 it has been renamed due to the change of the
		-- Qt5 system... From that version it's called: "CommandPanelWindow"
		commandHWND = gCHWND #max "Command Panel"
		if commandHWND == undefined then (
			commandHWND = gCHWND #max "CommandPanelWindow"
		)
		wSM commandHWND[1]  WM_SETREDRAW 1 0
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

	function numKnotsSelected theObj = (
		nS = numSplines theObj

		num = 0
		for i = 1 to nS do (
			num += (getKnotSelection $ i).count
		)
		return num
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

	function getViewDirection = (
		-- The affine TM transforms from world coords to view coords -- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The Z axis of this matrix is the view direction.
		local viewDir = coordSysTM.row3
		-- get the view position from this matrix
		viewDir
	)

	-- collecting the segments separatedly by spline and by non-connected segment groups
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
			append sarr #(i, allseglist)
		)
		sarr
	)

	-- collects all the vertices based on vertex selection
	function getKnotsUsingSeg theObj skPairList = (
		skPairList = deepCopy skPairList
		skPairListCount = skPairList.count

		skArr = #()
		for i in skPairList do (
			knotArrList = #()
			for j in i[2] do (
				knotList = #()
				for k in j do (
					appendIfUnique knotList (k)
					if k+1 <= (numKnots theObj i[1]) then (
						appendIfUnique knotList (k + 1)
					)
				)
				append knotArrList knotList
			)
			if isClosed theObj i[1] then (
				if knotArrList.count != 0 then (
					firstKnot = knotArrList[1][1]
					lastSeg = i[2] [i[2].count] [i[2] [i[2].count].count]
					knotCount = numKnots theObj i[1]

					if firstKnot != 1 and lastSeg == knotCount then (
						append knotArrList[knotArrList.count] 1
					)
				)
			)
			if knotArrList.count != 0 then (
				append skArr #(i[1], knotArrList)
			)
		)
		skArr
	)

	-- collects all the selected segments border segments in selection list
	function getBorderKnots theObj skPairList = (
		skPairList = deepCopy skPairList
		skPairListCount = skPairList.count

		skArr = #()
		for i in skPairList do (
			knotArrList = #()
			for j in i[2] do (
				knotList = #()
				for k in j do (
					appendIfUnique knotList (k)
					if k+1 <= (numKnots theObj i[1]) then (
						appendIfUnique knotList (k + 1)
					)
				)
				append knotArrList knotList
			)
			if isClosed theObj i[1] then (
				if knotArrList.count != 0 then (
					firstKnot = knotArrList[1][1]
					lastSeg = i[2] [i[2].count] [i[2] [i[2].count].count]
					knotCount = numKnots theObj i[1]

					if firstKnot == 1 and lastSeg == knotCount then (
						knotArrList[knotArrList.count] = knotArrList[knotArrList.count] + knotArrList[1]
						deleteItem knotArrList 1
					)
					else if firstKnot != 1 and lastSeg == knotCount then (
						append knotArrList[knotArrList.count] 1
					)
				)
			)
			for j = 1 to knotArrList.count do (
				knotArrList[j] = #(knotArrList[j][1], knotArrList[j][knotArrList[j].count])
			)
			if knotArrList.count != 0 then (
				append skArr #(i[1], knotArrList)
			)
		)
		skArr
	)

	-- program flow
	-----------------------------------------------------------------------------------------------------
	sel = $selection as array

	if sel != undefined then (
		
		selCount = sel.count
		
		-- if only single object is selected
		--------------------------------------------------------
		if selCount == 1 then (
			class = cO gCO
			sel = sel[1]

			-- if subobjectlevel is zero then simply activate the attach mode
			-----------------------------------------------------------------
			if subobjectlevel == 0 then (
				-- EDITABLE POLY				
				if class == Editable_Poly or class == Edit_Poly then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				)
				-- SPLINE SHAPE
				else if class == line or class == splineShape then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Attach" do UIAccessor.PressButton i[1]
				) 
			)

			-- SUBOBJECT LEVEL 1
			----------------------------------------------------------------
			if subobjectlevel == 1 then (
				-- EDITABLE POLY
				if class == Editable_Poly  then (
					dir = getViewDirection()
					verts = (polyop.getVertSelection sel) as array
					if verts.count == 2 then (
						vertA = verts[1]
						vertB = verts[2]
						polyop.cutVert sel vertA (polyop.getVert sel vertB) dir
					)
					else if verts.count > 2 then (
						gCO.buttonOp #ConnectVertices
					)
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					dir = getViewDirection()
					verts = (gCO.getSelection #Vertex) as array
					if verts.count == 2 then (
						refCoordSys = GetRefCoordSys()
						SetRefCoordSys #local
						vertA = verts[1]
						vertB = verts[2]
						gCO.StartCut #vertex (vertA) (gCO.getVertex vertB) dir node:sel
						gCO.commit()
						SetRefCoordSys refCoordSys
					)
					else if verts.count > 2 then (
						gCO.buttonOp #ConnectVertices
					)
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					splineCount = numSplines sel
					knotCount = 0
					knotList = #()
					for i = 1 to splineCount do (
						knots = getKnotSelection sel i
						knotCount += knots.count
						if knots.count != 0 then (
							append knotList #(i, knots)
						)
					)
					knotA = undefined
					knotB = undefined
					if knotCount >= 2 then (
						knotA = getKnotPoint sel knotList[1][1] knotList[1][2][1]
						for i in knotList do (
							for j in i[2] do (
								testKnot = getKnotPoint sel i[1] j
								if testKnot != knotA then (
									knotB = testKnot
									exit
								)
							)
							if knotA != undefined and knotB != undefined then exit
						)
					)
					if knotA != undefined and knotB != undefined then (
						theHold.cancel()
						theHold.begin()
						convertToSplineShape sel
						tempSpline = splineShape()
						newSplineID = numSplines tempSpline + 1
						addNewSpline tempSpline
						addKnot tempSpline newSplineID #corner #curve knotA
						addKnot tempSpline newSplineID #corner #curve knotB
						addAndWeld sel tempSpline 0.001
						updateShape sel
						subobjectlevel = 1
						theHold.accept("multiConnect")
					)
				)
			)

			-- SUBOBJECT LEVEL 2
			----------------------------------------------------------------
			else if subobjectlevel == 2 then (
				-- EDITABLE POLY				
				if class == Editable_Poly then (
					openEdges = polyop.getOpenEdges sel
					selEdges = polyop.getEdgeSelection sel
					edges = selEdges - openEdges
					if selEdges.numberSet > 1 then (
						if edges.numberSet == 0 then (
							refEdgeList = #{1..(polyop.getNumEdges sel)}
							gCO.bridgeSegments = 1
							gCO.Bridge selLevel:#Edge
							newEdgeList = #{1..(polyop.getNumEdges sel)}
							targetEdgeList = newEdgeList - refEdgeList
							borderList = #{}
							for i in targetEdgeList do borderList = borderList + (polyop.getBorderFromEdge sel i)
							bridgeEdges = borderList - targetEdgeList
							polyop.setEdgeSelection sel bridgeEdges
						)
						else (
							gCO.connectEdges()
						)
					)
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					selEdges = gCO.getSelection #edge
					edges = #{1..(gCO.getNumEdges())}
					gCO.ConvertSelection #edge #border
					openEdges = gCO.getSelection #edge
					gCO.setSelection #edge selEdges
					edges = selEdges - openEdges
					if selEdges.numberSet > 1 then (
						if edges.numberset == 0 then (
							refEdgeList = #{1..(gCO.getNumEdges())}
							gCO.bridgeSegments = 1
							gCO.buttonOp #BridgeEdge
							newEdgeList = #{1..(gCO.getNumEdges())}
							targetEdgeList = newEdgeList - refEdgeList
							gCO.setSelection #edge targetEdgeList
							gCO.ConvertSelection #edge #border
							borderList = gCO.getSelection #edge
							bridgeEdges = borderList - targetEdgeList
							gCO.setSelection #edge &bridgeEdges
						)
						else (
							gCO.ButtonOp #ConnectEdges
						)
					)
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					sepSegList = getSepSegSelList sel
					knotList = getBorderKnots sel sepSegList

					-- collecting two selection pairs which we gonna connect
					knotGroupA = undefined
					knotGroupB = undefined
					if knotList[1][2].count == 1 then (
						knotGroupA = #(knotList[1][1], knotList[1][2][1])
						knotGroupB = #(knotList[2][1], knotList[2][2][1])
					)
					else (
						knotGroupA = #(knotList[1][1], knotList[1][2][1])
						knotGroupB = #(knotList[1][1], knotList[1][2][2])
					)

					if knotGroupA != undefined and knotGroupB != undefined then (
						-- let's get the pairs based on their distances
						a1 = getKnotPoint sel knotGroupA[1] knotGroupA[2][1]
						b1 = getKnotPoint sel knotGroupB[1] knotGroupB[2][1]
						a2 = getKnotPoint sel knotGroupA[1] knotGroupA[2][2]
						b2 = getKnotPoint sel knotGroupB[1] knotGroupB[2][2]

						if distance a1 b1 > distance a1 b2 then knotGroupA[2] = #(knotGroupA[2][2], knotGroupA[2][1])

						if knotGroupA != undefined and knotGroupB != undefined then (
							theHold.cancel()
							theHold.begin()
							convertToSplineShape sel
							for i = 1 to 2 do (
								tempSpline = splineShape()
								newSplineID = numSplines tempSpline + 1
								addNewSpline tempSpline
								addKnot tempSpline newSplineID #corner #curve (getKnotPoint sel knotGroupA[1] knotGroupA[2][i])
								addKnot tempSpline newSplineID #corner #curve (getKnotPoint sel knotGroupB[1] knotGroupB[2][i])
								addAndWeld sel tempSpline 0.001
								updateShape sel
							splineOps.delete sel
							subobjectlevel = 2
							theHold.accept("multiConnect")
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
					gCO.bridgeSegments = 0
					gCO.Bridge selLevel:#Edge
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					gCO.bridgeSegments = 1
					gCO.buttonOp #BridgeEdge
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Cross Section" do UIAccessor.PressButton i[1]
				)
			)
			-- SUBOBJECT LEVEL 4
			----------------------------------------------------------------
			else if subobjectlevel == 4 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					gCO.bridgeSegments = 0
					gCO.Bridge selLevel:#Face
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					gCO.bridgeSegments = 0
					gCO.buttonOp #BridgePolygon
				)
			)
			-- SUBOBJECT LEVEL 5
			----------------------------------------------------------------
			else if subobjectlevel == 5 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "QuickSlice" do UIAccessor.PressButton i[1]
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "QuickSlice" do UIAccessor.PressButton i[1]
				)
			)
		)
	)
-- )