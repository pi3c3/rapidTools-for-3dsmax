-- macroScript multiAttach category:"rapidTools" tooltip:"multiAttach" buttonText: "multiAttach" (

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
				-- EDITABLE PATCH
				else if class == Editable_Patch then (
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
				else if class == Edit_Poly then (
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
				else if class == Edit_Poly then (
					newName = uniquename (sel.name + "_shape")
					gCO.createShape newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- SPLINE SHAPE
				else if class == splineShape or class == line then (
					registerAutoAccept()
					allHWND = gCNHWND #max
					for i in allHWND where UIAccessor.GetWindowText i[1] == "Detach" do UIAccessor.PressButton i[1]
					unregisterAutoAccept()
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
				else if class == Edit_Poly then (
					newName = uniquename (sel.name + "_shape")
					gCO.createShape newName
					subobjectlevel = 0
					select (execute("$" + newName))
				)
				-- SPLINE SHAPE
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
					refNumEdges = #{1..(polyop.getNumEdges sel)}
					polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:false
					newNumEdges = #{1..(polyop.getNumEdges sel)}
					if refNumEdges.numberset == newNumEdges.numberset then (
						newName = uniquename sel.name
						polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:true name:newName
					)
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					refNumEdges = #{1..(gCO.getNumEdges())}
					gCO.ConvertSelectionToBorder #Face #Border
					gCO.buttonOp #SplitEdges
					gCO.commit()
					newNumEdges = #{1..(gCO.getNumEdges())}
					if refNumEdges.numberset == newNumEdges.numberset then (
						newName = uniquename sel.name
						gCO.DetachToObject newName
					)
				)
			)
			-- SUBOBJECT LEVEL 5
			----------------------------------------------------------------
			else if subobjectlevel == 5 then (
				-- EDITABLE POLY
				if class == Editable_Poly then (
					polyop.detachFaces sel (polyop.getFaceSelection sel) delete:true asNode:true --name:newName
				)
				-- EDIT POLY
				else if class == Edit_Poly then (
					gCO.detachToObject (uniquename(sel.name))
				)
			)
		)
	)
-- )