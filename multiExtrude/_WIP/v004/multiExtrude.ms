macroScript multiExtrude category:"rapidTools" tooltip:"multiExtrude" buttonText: "multiExtrude" (

	clearListener()
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
			append sarr #(i, allseglist)
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
					lastKnot = knotArrList[knotArrList.count][knotArrList[knotArrList.count].count]
					lastSeg = i[2] [i[2].count] [i[2] [i[2].count].count]
					segCount = knotArrList[knotArrList.count].count
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
					knotSelection = getKnotSelectionList sel
					max select none
					knotSelList = #()
					for i in knotSelection do (
						knotCount = numKnots sel i[1]
						si = 0
						closed = isClosed sel i[1]
						if not closed then (
							for j in i[2] do (
								if j == 1 then (
									pos = getKnotPoint sel i[1] j
									addKnot sel i[1] #corner #curve pos 1
									updateShape sel
									append knotSelList #(i[1], #(j))
									si += 1
								)
								else if (j + si) == numKnots sel i[1] then (
									pos = getKnotPoint sel i[1] (j + si)
									addKnot sel i[1] #corner #curve pos (j + si + 1)
									updateShape sel
									append knotSelList #(i[1], #(j + si + 1))
								)
								else (
									pos = getKnotPoint sel i[1] (j + si)
									addNewSpline sel
									newSpline = numSplines sel
									addKnot sel newSpline #corner #curve pos
									addKnot sel newSpline #corner #curve pos
									updateShape sel
									append knotSelList #(newSpline, #(2))
								)
							)
						)
						else if closed then (
							for j in i[2] do (
								pos = getKnotPoint sel i[1] (j)
								addNewSpline sel
								newSpline = numSplines sel
								addKnot sel newSpline #corner #curve pos
								addKnot sel newSpline #corner #curve pos
								updateShape sel
								append knotSelList #(newSpline, #(2))
							)
						)
					)
					for i in knotSelList do setKnotSelection sel i[1] i[2] keep:True
				)
			)

			-- SUBOBJECT LEVEL 2
			----------------------------------------------------------------
			else if subobjectlevel == 2 then (
				-- EDITABLE POLY				
				if class == Editable_Poly then (

				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					-- segment extrusion
					segmentList = getSepSegSelList sel
					knotList = getKnotsUsingSeg sel segmentList
					max select none
					----------------------------
					-- MAIN ITERATOR FOR SPLINES
					----------------------------
					for i in knotList do (
						closed = isClosed sel i[1]
						knotCount = numKnots sel i[1]
 						-- if the spline is open, then the solution is quite simple
						if not closed then (
							si = 0
							for j in i[2] do (
								firstPos = getKnotPoint sel i[1] (j[1] + si)
								lastPos = getKnotPoint sel i[1] (j[j.count] + si)
								segA = (j[1] + si)
								segB = (j[j.count] + si + 1)
								addKnot sel i[1] #corner #curve firstPos segA
								addKnot sel i[1] #corner #curve lastPos segB
								updateShape sel
								segSelList = #{(segA+1)..(segB-1)} as array
								setSegSelection sel i[1] segSelList keep:True
								si += 2
							)
						)
						-- it it's closed, then it's a much more complex case
						else (
							-- this is the case when we have a selection that goes through the first knot
							if i[2][1][1] == 1 and i[2][i[2].count][i[2][i[2].count].count] == knotCount then (
								si = 0
								for j in i[2] do (
									-- this occurs in case when the segment is the first one
									if j[1] == 1 then (
		 								firstPos = getKnotPoint sel i[1] (j[1] + si)
		 								lastPos = getKnotPoint sel i[1] (j[j.count] + si)
		 								segA = (j[1] + si)
		 								segB = (j[j.count] + si + 1)
		 								addKnot sel i[1] #corner #curve lastPos segB
		 								updateShape sel
		 								segSelList = #{(segA)..(segB-2)} as array
		 								setSegSelection sel i[1] segSelList keep:True
		 								si += 1
	 								)
	 								-- this runs, when we reach the last segment
	 								else if j[j.count] == knotCount then (
		 								firstPos = getKnotPoint sel i[1] (j[1] + si)
		 								lastPos = getKnotPoint sel i[1] (j[j.count] + si)
		 								segA = (j[1] + si)
		 								segB = (j[j.count] + si + 1)
		 								addKnot sel i[1] #corner #curve firstPos segA
		 								updateShape sel
		 								segSelList = #{(segA+1)..(segB)} as array
		 								setSegSelection sel i[1] segSelList keep:True
	 								)
	 								-- in any other cases this runs...
	 								else (
		 								firstPos = getKnotPoint sel i[1] (j[1] + si)
		 								lastPos = getKnotPoint sel i[1] (j[j.count] + si)
		 								segA = (j[1] + si)
		 								segB = (j[j.count] + si + 1)
		 								addKnot sel i[1] #corner #curve firstPos segA
		 								addKnot sel i[1] #corner #curve lastPos segB
		 								updateShape sel
		 								segSelList = #{(segA+1)..(segB-1)} as array
		 								setSegSelection sel i[1] segSelList keep:True
		 								si += 2
	 								)
	 							)
	 						)
	 						-- this is the latest case, when the first knot,
	 						-- is the part of the latest segment
 							else (
 								si = 0
 								for j in i[2] do (
 									if j[j.count] != 1 then (
		 								firstPos = getKnotPoint sel i[1] (j[1] + si)
		 								lastPos = getKnotPoint sel i[1] (j[j.count] + si)
		 								segA = (j[1] + si)
		 								segB = (j[j.count] + si + 1)
		 								addKnot sel i[1] #corner #curve firstPos segA
		 								addKnot sel i[1] #corner #curve lastPos segB
		 								updateShape sel
		 								segSelList = #{(segA+1)..(segB-1)} as array
		 								setSegSelection sel i[1] segSelList keep:True
		 								si += 2
		 							)
		 							else (
		 								firstPos = getKnotPoint sel i[1] (j[1] + si)
		 								lastPos = getKnotPoint sel i[1] (j[j.count])
		 								segA = j[1] + si
		 								segB = (j[j.count] + 1)
		 								addKnot sel i[1] #corner #curve firstPos segA
 										segB = numSegments sel i[1] + 1
		 								addKnot sel i[1] #corner #curve lastPos segB
		 								updateShape sel
		 								segSelList = #{(segA+1)..(segB-1)} as array
		 								setSegSelection sel i[1] segSelList keep:True
		 							)
								)
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
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					facesSelected = getFaceSelection sel
					meshop.ExtrudeFaces sel facesSelected 0 0
				)
				else if class == splineShape or class == line then (
					registerAutoAccept()
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Outline" do UIAccessor.PressButton i[1]
					unregisterAutoAccept()
				)
			)
			-- SUBOBJECT LEVEL 4
			----------------------------------------------------------------
			else if subobjectlevel == 4 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					facesSelected = getFaceSelection sel
					polyop.ExtrudeFaces sel facesSelected 0
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
					gCO.ExtrudeFaceHeight = 0
					gCO.SetOperation #ExtrudeFace
					gCO.commit()
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
					facesSelected = getFaceSelection sel
					meshop.ExtrudeFaces sel facesSelected 0 0
				)
			)
			-- SUBOBJECT LEVEL 5
			----------------------------------------------------------------
			else if subobjectlevel == 5 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
				)
				-- EDIT POLY
				else if class == PolyMeshObject then (
				)
				-- EDITABLE MESH
				else if class == Editable_mesh then (
				)
			)
		)
	)
)