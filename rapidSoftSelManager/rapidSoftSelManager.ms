options.printAllElements = true -- this must be set to TRUE, so the listener can list out all elements of the array instead of 20 elements

	global theSSObj = selection[1]
	global softSelFloater
	global StoreSoftSelGUI
	global OpSoftSelGUI
	global softSelSettings
	global itemName = "SoftSelection"
	
	global softSelNameArray = #()
	global softSelWeightArray = #()
	
	global lastSelection = #{}
		
	global indexA
	global indexB
	
	----------------------------------------------- GET AND SET SOFT SELECTION TABLET ------------------------------------------------

	function getSoftSelection theSSObj = (
		local vertCount = polyop.getNumVerts theSSObj
		local weightArray = for i in #{1..vertCount} collect polyop.getVDataValue theSSObj 1 i
		return weightArray
	)

	function setSoftSelection weightArray = (
		if selection.count == 1 then (
			if selection[1] == theSSObj then (
				theSSObj.lockSoftSel = off
				theSSObj.lockSoftSel = on
				weightArrayCount = weightArray.count
				if weightArrayCount > polyop.getNumVerts theSSObj then weightArrayCount = polyop.getNumVerts theSSObj

				for i = 1 to weightArrayCount do (
					polyop.setVDataValue theSSObj 1 i weightArray[i]
				)
			)
		)
	)

	----------------------------------------------- GET AND SET SOFT SELECTION TABLET ------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------- STRING AND ID FUNCTIONS ----------------------------------------------------------
	
	function numToChar num = (

		local chars = #("A","B","C","D","E","F","G","H","I","J")
		local numArray = #(0,1,2,3,4,5,6,7,8,9)
		local numCount = (num as string).count
		local numString = num as string
		
		local letters = #()
		letters[numCount] = 0

		letters = for i = 1 to numCount collect chars[findItem numArray ((numString[i]) as integer)]
		
		local theString = ""
		for i = 1 to numCount do theString = theString + letters[i]
			
		return theString
	)

	function charToNum letters = (
		
		local chars = #("A","B","C","D","E","F","G","H","I","J")
		local numArray = #(0,1,2,3,4,5,6,7,8,9)
		local lettersCount = letters.count
		
		local nums = #()
		nums[lettersCount] = 0
		
		nums = for i = 1 to lettersCount collect numArray[(findItem chars letters[i])]
		
		local theString = ""
		for i = 1 to lettersCount do theString = theString + ((nums[i]) as string)
		
		local theInteger = theString as integer
		
		return theInteger
	)

	function IDFromName names pattern = (
		local namesCount = names.count
		local IDs = #()
		IDs[namesCount] = 0
		IDs = for i = 1 to namesCount collect substituteString names[i] (pattern + " ") ""
		return IDs
	)
	
	function getIDs chars = (
		local charsCount = chars.count
		local IDs = #()
		IDs[charsCount] = 0
		IDs = for i = 1 to charsCount collect charToNum chars[i]
		return IDs
	)
	
	function weightsFromName nameArray = (
		
		nameArrayCount = nameArray.count
		weightArray = #()
		weightArray[nameArrayCount] = 0
		
		for i = 1 to nameArrayCount do (
			index = findItem softSelNameArray nameArray[i]
			weightArray[i] = softSelWeightArray[index]
		)
		
		return weightArray
	)
	
	--------------------------------------------------------------------------- STRING AND ID FUNCTIONS ---------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------- DATA STORE AND DATA OPERATION FUNCTIONS ----------------------------------------------------------
	
	function storeProp key data = (
		if getUserProp theSSObj key == undefined then (
			setUserProp theSSObj key data
		)
		
		else if getUserProp theSSObj key != undefined then (
			softSelItems = execute (getUserProp theSSObj key)
			append softSelItems data
			setUserProp theSSObj key ""
			setUserProp theSSObj key (data as string)
		)
	)
	
	function setSSData = (
		
		local nameArray = getUserProp theSSObj "softSelNamesArray"
		local weightArray = getUserProp theSSObj "softSelWeightsArray"
		
		if nameArray != undefined then ( -- calculating the last char ID
			nameArray = execute nameArray
			weightArray = execute weightArray
			
			if nameArray.count != 0 then (
				IDs = IDFromName nameArray itemName
				lastID = amax (getIDs IDs)
				nextID = lastID + 1
			)
			else (
				nextID = 0
			)
		)
		else (
			nameArray = #()
			weightArray = #()
			nextID = 0
		)
		
		charID = numToChar nextID -- converting char ID to numeral ID, so we can count with it
		
		local theName = itemName + " " + charID
		local theWeightMap = getSoftSelection theSSObj
		
		append nameArray theName
		append weightArray theWeightMap
		
		storeProp "softSelNamesArray" nameArray
		storeProp "softSelWeightsArray" weightArray
		
		storeSoftSelGUI.ssList.items = nameArray -- updateGUI
		
		softSelNameArray = nameArray
		softSelWeightArray = weightArray
	)
	
	function delSSData = (
		local nameArray = getUserProp theSSObj "softSelNamesArray"
		local weightArray = getUserProp theSSObj "softSelWeightsArray"
		
		if nameArray != undefined then ( -- calculating the last char ID
			nameArray = execute nameArray
			weightArray = execute weightArray
		
			selItems = (storeSoftSelGUI.ssList.selection) as array
			selItemsCount = selItems.count
			
			for i = 1 to selItemsCount do (
				index = findItem nameArray (storeSoftSelGUI.ssList.items[selItems[i]])
				deleteItem nameArray index
				deleteItem weightArray index
			)
				
			storeProp "softSelNamesArray" nameArray
			storeProp "softSelWeightsArray" weightArray
			
			storeSoftSelGUI.ssList.items = nameArray -- updateGUI
			
			softSelNameArray = nameArray
			softSelWeightArray = weightArray
			
			itm = storeSoftSelGUI.ssList.selection
			
			if itm.numberset == 0 then ( -- if there is no itm selected, deselects all soft sel
				setSoftSelection #()
			)
			else ( -- if there is, than it selects the soft selection that is selected
				setSoftSelection softSelWeightArray[(itm as array)[1]]
			)
			
			if nameArray.count == 0 then (
				theSSObj.lockSoftSel = off
			)
		)
	)
	
	---------------------------------------------------------- DATA STORE AND DATA OPERATION FUNCTIONS ----------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------- UPDATE FUNCTIONS --------------------------------------------------------------------------------
	
	function updateSoftSelGUI = (
		theSSObj = selection[1]
		
		if theSSObj != undefined and classOf theSSObj == Editable_Poly then (
			if getUserProp theSSObj "softSelNamesArray" != undefined then (
				softSelNameArray = execute (getUserProp theSSObj "softSelNamesArray")
				softSelWeightArray = execute (getUserProp theSSObj "softSelWeightsArray")
				StoreSoftSelGUI.ssList.items = softSelNameArray
			)
		)
		else (
			StoreSoftSelGUI.ssList.items = #()
		)
	)
	
	function checkSoftSel = (
		if theSSObj.useSoftSel == off then (
			theSSObj.useSoftSel = on
			theSSObj.falloff = 0
		)
	)
	
	--------------------------------------------------------------------------------- UPDATE FUNCTIONS --------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------- DATA OPERATIONS ---------------------------------------------------------------------------------

	function addSoftSelection A B = (
		arrayCount = A.count
		local newArray = #()
		newArray[arrayCount] = 0
		
		for i = 1 to arrayCount do (
			result = A[i] + B[i]
			if result < 0 and softSelSettings.negChk.checked == true then result = 0
			newArray[i] = result
		)
		
		return newArray		
	)

	function subSoftSelection A B = (
		arrayCount = A.count
		local newArray = #()
		newArray[arrayCount] = 0
		
		for i = 1 to arrayCount do (
			result = A[i] - B[i]
			if result < 0 and softSelSettings.negChk.checked == true then result = 0
			newArray[i] = result
		)
		
		return newArray		
	)

	function multSoftSelection A B = (
		arrayCount = A.count
		local newArray = #()
		newArray[arrayCount] = 0
		
		for i = 1 to arrayCount do (
			result = A[i] * B[i]
			if result < 0 and softSelSettings.negChk.checked == true then result = 0
			newArray[i] = result
		)
		
		return newArray		
	)

	function divSoftSelection A B = (
		arrayCount = A.count
		local newArray = #()
		newArray[arrayCount] = 0
		
		for i = 1 to arrayCount do (
			result = A[i] / B[i]
			if result < 0 and softSelSettings.negChk.checked == true then result = 0
			newArray[i] = result
		)
		
		return newArray		
	)
	
	function maximizeData dataArray = (
		
		dataArrayCount = dataArray.count
		refArray = dataArray[1]
		refArrayCount = refArray.count
		
		for i = 2 to dataArrayCount do (
			for j = 1 to refArrayCount do (
				if refArray[j] < dataArray[i][j] then refArray[j] = dataArray[i][j]
			)
		)
		
		return refArray
	)

	---------------------------------------------------------------------------------- DATA OPERATIONS ---------------------------------------------------------------------------------
	
	rollout StoreSoftSelGUI "Store Soft Selection" width:176 height:744 (
		
		bitmap headerSS "Bitmap" pos:[8,8] width:160 height:66 fileName:((getdir #userscripts) + "\\rapidTools\\rapidSoftSelManager_header.png")
		
		multilistBox ssList "Stored Soft Selection" pos:[8,82] width:160 height:11 items:softSelNameArray
		
		button storeSS "Store" pos:[8,260] width:160 height:32
		button delSS "Delete" pos:[8,300] width:160 height:32
		
		on storeSS pressed do (
			if theSSObj != undefined then (
				if classOf theSSObj == Editable_Poly then (
					checkSoftSel()
					setSSData()
				)
				else messageBox "Please select an Editable Poly object!"
			)
			else messageBox "No object is selected!"
		)
		
		on delSS pressed do (
			if theSSObj != undefined then (
				delSSData()
			)
			else messageBox "Please select an Editable Poly object!"
		)
		
		on ssList selectionEnd do (
			itm = StoreSoftSelGUI.ssList.selection
			
			if lastSelection.numberset < itm.numberset then (
				lastSelection = itm - lastSelection

			)
			else if lastSelection.numberset > itm.numberset then (
				lastSelection  = lastSelection - itm

			)
			else if lastSelection.numberset == itm.numberset then (
				lastSelection  = itm
			)
			
			--- SET SOFT SEL HERE ---
			
			if theSSObj.useSoftSel == off then ( -- check if soft selection is on
				theSSObj.useSoftSel = on
			)
			
			if itm.numberset == 0 then ( -- if there is no itm selected, deselects all soft sel
				setSoftSelection #()
			)
			else ( -- if there is, than it selects the soft selection that is selected
				if softSelSettings.intChk.checked == true then (
					setSoftSelection softSelWeightArray[(itm as array)[1]]
				)
			)
		)
		
		on StoreSoftSelGUI open do (
			updateSoftSelGUI()
			callbacks.addScript #selectionSetChanged "updateSoftSelGUI()" id:#softSelSelectionHandler
		)
		
		on StoreSoftSelGUI close do (
			callbacks.removeScripts id:#softSelSelectionHandler
		)
	)
		
	rollout OpSoftSelGUI "Soft Selection Manager" width:176 height:744 (
		
		multilistBox opA "Operand A" pos:[8,368-320] width:160 height:2
		multilistBox opB "Operand B" pos:[8,424-320] width:160 height:2
		
		button addA "Add A" pos:[8,328-320] width:72 height:32
		button addB "Add B" pos:[96,328-320] width:72 height:32
		
		button addSS "Add (A + B)" pos:[16,496-320] width:144 height:32
		button subSS "Substract (A - B)" pos:[16,536-320] width:144 height:32
		button multSS "Multiply (A * B)" pos:[16,576-320] width:144 height:32
		button divSS "Divide (A / B)" pos:[16,616-320] width:144 height:32
		
		groupBox opGRP "Operations" pos:[8,480-320] width:160 height:176
		
		
		on addA pressed do (
			nameArr = storeSoftSelGUI.ssList.items
			selItems = (storeSoftSelGUI.ssList.selection) as array
			selItemsCount = selItems.count
			selNames = #()
			
			for i = 1 to selItemsCount do (
				selNames[i] = nameArr[selItems[i]]
			)
			
			opA.items = selNames
		)
		
		on addB pressed do (
			nameArr = storeSoftSelGUI.ssList.items
			selItems = (storeSoftSelGUI.ssList.selection) as array
			selItemsCount = selItems.count
			selNames = #()
			
			for i = 1 to selItemsCount do (
				selNames[i] = nameArr[selItems[i]]
			)
			
			opB.items = selNames
		)
		
		on addSS pressed do (
			if OpSoftSelGUI.opA.items.count > 0 and OpSoftSelGUI.opB.items.count > 0 then (
				operandA = OpSoftSelGUI.opA.items
				operandA = weightsFromName operandA
				
				operandB = OpSoftSelGUI.opB.items
				operandB = weightsFromName operandB
				
				operandA = maximizeData operandA
				operandB = maximizeData operandB
				
				resultAdd = addSoftSelection operandA operandB
				setSoftSelection resultAdd
			)
		)
		
		on subSS pressed do (
			if OpSoftSelGUI.opA.items.count > 0 and OpSoftSelGUI.opB.items.count > 0 then (
				operandA = OpSoftSelGUI.opA.items
				operandA = weightsFromName operandA
				
				operandB = OpSoftSelGUI.opB.items
				operandB = weightsFromName operandB
				
				operandA = maximizeData operandA
				operandB = maximizeData operandB
				
				resultSub = subSoftSelection operandA operandB
				setSoftSelection resultSub
			)
		)
		
		on multSS pressed do (
			if OpSoftSelGUI.opA.items.count > 0 and OpSoftSelGUI.opB.items.count > 0 then (
				operandA = OpSoftSelGUI.opA.items
				operandA = weightsFromName operandA
				
				operandB = OpSoftSelGUI.opB.items
				operandB = weightsFromName operandB
				
				operandA = maximizeData operandA
				operandB = maximizeData operandB
				
				resultMult = multSoftSelection operandA operandB
				setSoftSelection resultMult
			)
		)
		
		on divSS pressed do (
			if OpSoftSelGUI.opA.items.count > 0 and OpSoftSelGUI.opB.items.count > 0 then (
				operandA = OpSoftSelGUI.opA.items
				operandA = weightsFromName operandA
				
				operandB = OpSoftSelGUI.opB.items
				operandB = weightsFromName operandB
				
				operandA = maximizeData operandA
				operandB = maximizeData operandB
				
				resultDiv = divSoftSelection operandA operandB
				setSoftSelection resultDiv
			)
		)
	)
	
	rollout SoftSelSettings "Settings" width:176 height:744 (
		
		checkbox negChk "Prevent Negative Values" pos:[16,688-664] width:144 height:16
		checkbox intChk "Interactive Mode" pos:[16,712-664] width:144 height:16
		
		groupBox SettingsGRP "Settings" pos:[8,664-664] width:160 height:72
	)
		
	--------------------- GUI EVENT HANDLING ---------------------
	if softSelFloater == undefined then (
		softSelFloater = newRolloutFloater "Soft Sel Manager" 186 835
		addRollout storeSoftSelGUI softSelFloater
		addRollout OpSoftSelGUI softSelFloater
		addRollout softSelSettings softSelFloater
	)
	else (
		if softSelFloater.open == False then (
			softSelFloater = newRolloutFloater "Soft Sel Manager" 186 835
			addRollout storeSoftSelGUI softSelFloater
			addRollout OpSoftSelGUI softSelFloater
			addRollout softSelSettings softSelFloater
		)
	)