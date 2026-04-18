-- (

-- TODO --

-- FRONT and BACK not working for some reason... Probably the camera orientation search algorithm is broken...

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 	 	-
-- 	SIMPLE GLOBAL VARIABLES, CONSTANTS 	-
-- 	 	-
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
	global X = #X
	global Y = #Y
	global Z = #Z

	-- base numbers (smallest floating point and greatest floating point)
	-- 1.18E-38 to 3.40E38
	global MAX_FLOAT = 3.40E38
	global MIN_FLOAT = -3.40E38


	global moveTop
	global moveBottom
	global moveLeft
	global moveRight
	global averageVertical
	global averageHorizontal
	global rotateCW
	global rotateCCW
	global sliceHorizontal
	global sliceVertical
	global sliceThroughEdge

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 	 	-
-- 	BASIC LIB FUNCTIONS TO SOLVE TASKS 	-
-- 	MATH AND/OR OBJECT BASED FUNCTIONS 	-
-- 	 	-
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

	function GetVectorsAngle v1 v2 = (
		theAngle = acos(dot (normalize v1) (normalize v2))
	)

	function getViewDirectionRay = (
		-- The affine TM transforms from world coords to view coords -- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The Z axis of this matrix is the view direction.
		local viewDir = -coordSysTM.row3
		-- get the view position from this matrix
		local viewPt = coordSysTM.row4
		ray viewPt viewDir
	)

	function getUpDirectionRay = (
		-- The affine TM transforms from world coords to view coords -- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The Y axis of this matrix is the top direction.
		local viewDir = coordSysTM.row2
		-- get the view position from this matrix
		local viewPt = coordSysTM.row4
		ray viewPt viewDir
	)

	function getSideDirectionRay = (
		-- The affine TM transforms from world coords to view coords -- so we need the inverse of this matrix
		local coordSysTM = Inverse(getViewTM())
		-- The X axis of this matrix is the side direction.
		local viewDir = coordSysTM.row1
		-- get the view position from this matrix
		local viewPt = coordSysTM.row4
		ray viewPt viewDir
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

	function getSegList theObj = (
		nS = numSplines theObj
		sArr = #()
		sArr[nS] = 0
		for i = 1 to nS do (
			sArr[i] = #(i, (#{1..(numSegments $ i)} as array))
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

	function getSegmentSelectionList theObj = (
		nS = numSplines theObj
		sArr = #()
		sArr[nS] = 0
		for i = 1 to nS do (
			skPair = #(i, (getSegSelection  $ i))
			sArr[i] = skPair
		)
		return sArr
	)

	function getKnotsUsingSeg theObj skPairList = (
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

	-- selection list for spline: #(<int> spline, <array> knot/segment)
	function getSelection = (
		if classof $ == Editable_Poly then (
			case subobjectlevel of (
				0: objVerts = #{1..(polyop.getNumVerts $)} as array
				1: objVerts = (polyop.getVertSelection $) as array
				2: objVerts = (polyop.getVertsUsingEdge $ (polyop.getEdgeSelection $)) as array
				3: objVerts = (polyop.getVertsUsingEdge $ (polyop.getEdgeSelection $)) as array
				4: objVerts = (polyop.getVertsUsingFace $ (polyop.getFaceSelection $)) as array
				5: objVerts = (polyop.getVertsUsingFace $ (polyop.getFaceSelection $)) as array
			)
			return objVerts 
		)
		else if classof $ == Editable_Mesh then (
			case subobjectlevel of (
				0: objVerts = #{1..(meshop.getNumVerts $)} as array
				1: objVerts = (getVertSelection  $) as array
				2: objVerts = (meshop.getVertsUsingEdge $ (getEdgeSelection $)) as array
				3: objVerts = (meshop.getVertsUsingEdge $ (getEdgeSelection $)) as array
				4: objVerts = (meshop.getVertsUsingFace $ (getFaceSelection $)) as array
				5: objVerts = (meshop.getVertsUsingFace $ (getFaceSelection $)) as array
			)
			return objVerts
		)
		else if classof $ == SplineShape or classof $ == line then (
			case subobjectlevel of (
				0: objVerts = getKnotList $
				1: objVerts = getKnotSelectionList  $
				2: objVerts = getKnotsUsingSeg $ (getSegmentSelectionList $)
				3: objVerts = getKnotsUsingSeg $ (getSegmentSelectionList $)
			)
			return objVerts
		)
		else if classof $ == ObjectSet then (
			return $
		)
		else return undefined
	)

	-- <point3 directionList> <point3 axis index list> #([1,1,1], [0,1,2])
	-- [1,1,1] -> pointing [Right, Up, Away] | [-1,-1,-1] -> [Left, Down, Towards]
	-- [0,1,2] -> X horizontal, Y vertical, Z depth
	function getVPrefPlane = (
		X_vector = [1.0,0.0,0.0]
		Y_vector = [0.0,1.0,0.0]
		Z_vector = [0.0,0.0,1.0]
		up = (getUpDirectionRay()).dir
		dir = (getViewDirectionRay()).dir
		
		-- angle on viewRay
		xAngle = GetVectorsAngle dir x_vector
		yAngle = GetVectorsAngle dir y_vector
		zAngle = GetVectorsAngle dir z_vector

		-- angle on XY upRay
		xUPangle = GetVectorsAngle up x_vector
		yUPangle = GetVectorsAngle up y_vector
		zUPangle = GetVectorsAngle up z_vector

-- 		print "----------------------------"
-- 		print (xAngle as string)
-- 		print (yAngle as string)
-- 		print (zAngle as string)
-- 		print (xUPangle as string)
-- 		print (yUPangle as string)
-- 		print (zUPangle as string)
-- 		print "----------------------------"

		-- when viewing from the top
		if zAngle <= 45 then (
			up[3] = up[3] = 0.0
			xUPangle = GetVectorsAngle up x_vector
			yUPangle = GetVectorsAngle up y_vector
			if xUPAngle >= 45 and xUPAngle <= 135 and yUPAngle <= 90 then (
				return #([-1,1,-1], [2,1,0])
			)
			else if xUPAngle >= 45 and xUPAngle <= 135 and yUPAngle >= 90 then (
				return #([1,-1,-1], [2,1,0])
			)
			else if yUPAngle >= 45 and yUPAngle <= 135 and xUPAngle <= 45 then (
				return #([1,1,-1], [1,2,0])
			)
			else if yUPAngle >= 45 and yUPAngle <= 135 and xUPAngle >= 135 then (
				return #([-1,-1,-1], [1,2,0])
			)
		)
		-- when viewing from the side
		else if zAngle >= 45 and zAngle <= 135 then (
			up[3] = up[3] = 0.0
			xUPangle = GetVectorsAngle up x_vector
			yUPangle = GetVectorsAngle up y_vector
			if zUPAngle <= 45 then (
				if xangle >= 45 and xangle <= 135 and yUPangle <= 45 and  yAngle <= 90 then (
					return #([1,-1,1], [2,0,1])
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle <= 45 and  yAngle >= 90 then (
					return #([-1,1,1], [2,0,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle >= 135 and xAngle <= 90 then (
					return #([-1,-1,1], [0,2,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle >= 135 and xAngle >= 90 then (
					return #([1,1,1], [0,2,1])	
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle >= 135 and yAngle >= 90 then (
					return #([-1,1,1], [2,0,1])
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle >= 135 and yAngle <= 90 then (
					return #([1,-1,1], [2,0,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle <= 45 and xAngle >= 90 then (
					return #([1,1,1], [0,2,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle <= 45 and xAngle <= 90 then (
					return #([-1,-1,1], [0,2,1])
				)
				else if (close_enough zUPAngle 0.0 10) and (close_enough xAngle 0.0 10) then (
					return #([1,-1,1], [0,2,1])
				)
				else if (close_enough zUPAngle 0.0 10) and (close_enough xAngle 180.0 10) then (
					return #([-1,1,1], [0,2,1])
				)
			)
			else if zUPAngle >= 135 then (
				if xangle >= 45 and xangle <= 135 and yUPangle <= 45 and yAngle >= 90 then (
					return #([1,1,-1], [2,0,1])
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle <= 45 and yAngle <= 90 then (
					return #([-1,-1,-1], [2,0,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle >= 135 and xangle >= 90 then (
					return #([1,-1,-1], [0,2,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle >= 135 and xangle <= 90 then (
					return #([-1,1,-1], [0,2,1])
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle >= 135 and yAngle >= 90 then (
					return #([1,1,-1], [2,0,1])
				)
				else if xangle >= 45 and xangle <= 135 and yUPangle >= 135 and yAngle <= 90 then (
					return #([-1,-1,-1], [2,0,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle <= 45 and xangle <= 90 then (
					return #([-1,1,-1], [0,2,1])
				)
				else if yangle >= 45 and yangle <= 135 and xUPangle <= 45 and xangle >= 90 then (
					return #([1,-1,-1], [0,2,1])
				)
			)
		)
		-- when viewing from the bottom
		else if zAngle >= 135 then (
			up[3] = up[3] = 0.0
			xUPangle = GetVectorsAngle up x_vector
			yUPangle = GetVectorsAngle up y_vector
			if xUPAngle >= 45 and xUPAngle <= 135 and yUPAngle <= 90 then (
				return #([1,1,1], [2,1,0])
			)
			else if xUPAngle >= 45 and xUPAngle <= 135 and yUPAngle >= 90 then (
				return #([-1,-1,1], [2,1,0])
			)
			else if yUPAngle >= 45 and yUPAngle <= 135 and xUPAngle <= 45 then (
				return #([1,-1,1], [1,2,0])
			)
			else if yUPAngle >= 45 and yUPAngle <= 135 and xUPAngle >= 135 then (
				return #([-1,1,1], [1,2,0])
			)
		)
	)

	-- point3 pos | posList <point3 list>
	function getAvgPos posList = (
		sumPos = 0
		for i in posList do sumPos = sumPos + i
		avgPos = sumPos / (posList.count)
	)

	-- getting the screen space vertical axis
	function getVerticalAxis directionList = (
		directionList = (getVPrefPlane())[2]
		if directionList[1] == 1 then axis = 1
		else if directionList[2] == 1 then axis = 2
		else if directionList[3] == 1 then axis = 3
		axis
	)

	-- getting the screen space horizontal axis
	function getHorizontalAxis directionList = (
		directionList = (getVPrefPlane())[2]
		if directionList[1] == 2 then axis = 1
		else if directionList[2] == 2 then axis = 2
		else if directionList[3] == 2 then axis = 3
		axis
	)

	-- getting the screen space depth axis
	function getDepthAxis directionList = (
		directionList = (getVPrefPlane())[2]
		if directionList[1] == 0 then axis = 1
		else if directionList[2] == 0 then axis = 2
		else if directionList[3] == 0 then axis = 3
		axis
	)

	-- get the axis direction based on the given direction list
	function getAxisDirection axis directionList = (
		if axis == 1 then dir = directionList[1]
		else if axis == 2 then dir = directionList[2]
		else if axis == 3 then dir = directionList[3]
		dir
	)

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 	 																											-
-- 	MOVE FUNCTIONS BY CLASS FUNCTIONS 																			-
-- 	 																											-
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

	function moveNodes axisDirection axis: offset: matrix: axDirFlipped: = (

		-- if calculating with axis
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				axisMax = 1.0
				axisMin = -1.0
			)
			else if axDirFlipped == True then (
				axisMax = -1.0
				axisMin = 1.0
		)

		-- finding the most bottom object
		if axisDirection == axisMax then (
			mostBottom = MAX_FLOAT
			for i in selection do (
				bbox = nodeGetBoundingBox i matrix
				thePos = bbox[1][axis]
				if thePos < mostBottom then (
					mostBottom = thePos
				)
			)
		)
		else if axisDirection == axisMin then (
			mostBottom = MIN_FLOAT
			for i in selection do (
				bbox = nodeGetBoundingBox i matrix
				thePos = bbox[2][axis]
				if thePos > mostBottom then (
					mostBottom = thePos
				)
			)
		)

			-- dropping
			for i in selection do (
				bbox = nodeGetBoundingBox i matrix
				if axisDirection == axisMin then (
					offset[axis] = bbox[2][axis]*(-1)
				)
				else if axisDirection == axisMax then (
					offset[axis] = bbox[1][axis]*(-1)
				)
				offset[axis] = offset[axis] + mostBottom
				move i offset
			)
		)

		-- if we average between threshold limit values
		else if axDirFlipped == unsupplied then (
			mostBottom = MAX_FLOAT
			for i in selection do (
				center = i.center
				thePos = center[axis]
				if thePos < mostBottom then (
					mostBottom = thePos
				)
			)
			mostTop = MIN_FLOAT
			for i in selection do (
				center = i.center
				thePos = center[axis]
				if thePos > mostTop then (
					mostTop = thePos
				)
			)

			averagePosition = (mostTop + mostBottom) / 2

			-- dropping
			for i in selection do (
				center = i.center
				if axisDirection == 1.0 then (
					offset[axis] = center[axis]*(-1)
				)
				else if axisDirection == -1.0 then (
					offset[axis] = center[axis]*(-1)
				)
				offset[axis] = offset[axis] + averagePosition
				move i offset
			)
		)
	)

	function movePolyVertices axisDirection: axis: axDirFlipped: = (
	
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				axisMax = 1.0
				axisMin = -1.0
			)
			else if axDirFlipped == True then (
				axisMax = -1.0
				axisMin = 1.0
			)

			verts = getSelection()

			if axisDirection == axisMax then (
				mostBottom = MAX_FLOAT
				for i in verts do (
					thePos = polyop.getVert $ i
					if thePos[axis] < mostBottom then (
						mostBottom = thePos[axis]
					)
				)
			)
			else if axisDirection == axisMin then (
				mostBottom = MIN_FLOAT
				for i in verts do (
					thePos = polyop.getVert $ i
					if thePos[axis] > mostBottom then (
						mostBottom = thePos[axis]
					)
				)
			)	

			-- dropping
			for i in verts do (
				vPos = polyop.getVert $ i
				vPos[axis] = mostBottom
				polyop.setVert $ i vPos
			)
		)

		else if axDirFlipped == unsupplied then (
			verts = getSelection()

			mostBottom = MAX_FLOAT
			for i in verts do (
				thePos = polyop.getVert $ i
				if thePos[axis] < mostBottom then (
					mostBottom = thePos[axis]
				)
			)	
			mostTop = MIN_FLOAT
			for i in verts do (
				thePos = polyop.getVert $ i
				if thePos[axis] > mostTop then (
					mostTop = thePos[axis]
				)
			)

			averagePosition = (mostTop + mostBottom) / 2

			-- dropping
			for i in verts do (
				vPos = polyop.getVert $ i
				vPos[axis] = averagePosition
				polyop.setVert $ i vPos
			)
		)
	)

	function moveMeshVertices axisDirection: axis: axDirFlipped: = (
	
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				axisMax = 1.0
				axisMin = -1.0
			)
			else if axDirFlipped == True then (
				axisMax = -1.0
				axisMin = 1.0
			)

			verts = getSelection()

			if axisDirection == axisMax then (
				mostBottom = MAX_FLOAT
				for i in verts do (
					thePos = meshop.getVert $ i
					if thePos[axis] < mostBottom then (
						mostBottom = thePos[axis]
					)
				)
			)
			else if axisDirection == axisMin then (
				mostBottom = MIN_FLOAT
				for i in verts do (
					thePos = meshop.getVert $ i
					if thePos[axis] > mostBottom then (
						mostBottom = thePos[axis]
					)
				)
			)	

			-- dropping
			for i in verts do (
				vPos = meshop.getVert $ i
				vPos[axis] = mostBottom
				meshop.setVert $ i vPos
			)
		)

		else if axDirFlipped == unsupplied then (
			verts = getSelection()

			mostBottom = MAX_FLOAT
			for i in verts do (
				thePos = meshop.getVert $ i
				if thePos[axis] < mostBottom then (
					mostBottom = thePos[axis]
				)
			)	
			mostTop = MIN_FLOAT
			for i in verts do (
				thePos = meshop.getVert $ i
				if thePos[axis] > mostTop then (
					mostTop = thePos[axis]
				)
			)

			averagePosition = (mostTop + mostBottom) / 2

			-- dropping
			for i in verts do (
				vPos = meshop.getVert $ i
				vPos[axis] = averagePosition
				meshop.setVert $ i vPos
			)
		)
	)

	function moveKnots axisDirection: axis: axDirFlipped: = (

		sE = showEndResult
		if sE == True or $.modifiers.count != 0 then (
			showEndResult = False
			print "Because of AWKWARDESK: Show end result is not supported! Sorry :("
			return "Because of AWKWARDESK: Show end result is not supported! Sorry :("
		)

		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				axisMax = 1.0
				axisMin = -1.0
			)
			else if axDirFlipped == True then (
				axisMax = -1.0
				axisMin = 1.0
			)

			verts = getSelection()

			if axisDirection == axisMax then (
				mostBottom = MAX_FLOAT
				for i in verts do (
					for j in i[2] do (
						thePos = getKnotPoint $ i[1] j
						if thePos[axis] < mostBottom then (
							mostBottom = thePos[axis]
						)
					)
				)
			)
			else if axisDirection == axisMin then (
				mostBottom = MIN_FLOAT
				for i in verts do (
					for j in i[2] do (
						thePos = getKnotPoint $ i[1] j
						if thePos[axis] > mostBottom then (
							mostBottom = thePos[axis]
						)
					)
				)
			)	
			-- dropping
			sublevel = subobjectlevel
			convertToSplineShape $
			for i in verts do (
				for j in i[2] do (
					vPos = getKnotPoint $ i[1] j
					vecIn = getInVec $ i[1] j
					vecOut = getOutVec $ i[1] j
					vPos[axis] = mostBottom
					vecIn[axis] = mostBottom
					vecOut[axis] = mostBottom
					setKnotPoint $ i[1] j vPos
					setInVec $ i[1] j vecIn
					setOutVec $ i[1] j vecOut
				)
			)
			subobjectlevel = sublevel
			updateShape $
		)

		else if axDirFlipped == unsupplied then (
			verts = getSelection()

			mostBottom = MAX_FLOAT
			for i in verts do (
				for j in i[2] do (
					thePos = getKnotPoint $ i[1] j
					if thePos[axis] < mostBottom then (
						mostBottom = thePos[axis]
					)
				)
			)	
			mostTop = MIN_FLOAT
			for i in verts do (
				for j in i[2] do (
					thePos = getKnotPoint $ i[1] j
					if thePos[axis] > mostTop then (
						mostTop = thePos[axis]
					)
				)
			)

			averagePosition = (mostTop + mostBottom) / 2

			-- dropping
			sublevel = subobjectlevel
			convertToSplineShape $
			for i in verts do (
				for j in i[2] do (
					vPos = getKnotPoint $ i[1] j
					vecIn = getInVec $ i[1] j
					vecOut = getOutVec $ i[1] j
					vPos[axis] = averagePosition
					vecIn[axis] = averagePosition
					vecOut[axis] = averagePosition
					setKnotPoint $ i[1] j vPos
					setInVec $ i[1] j vecIn
					setOutVec $ i[1] j vecOut
				)
			)
			subobjectlevel = sublevel
			updateShape $
		)
	)	

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 	 	-
-- 	ROTATE FUNCTIONS BY CLASS FUNCTIONS 	-
-- 	 	-
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

	function rotateNodes axisDirection: axis: axises: rotateAngle: axDirFlipped: rotMid: = (
		-- if calculating with axis
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				deg = 45
			)
			else if axDirFlipped == True then (
				deg = -45
			)
		)

		if rotMid == #center then (

			center = selection.center

			if axisDirection == 1.0 then (
				-- fill eulerAngle 
				axises[axis] = deg
				rotateAngle.x = axises[1]
				rotateAngle.y = axises[2]
				rotateAngle.z = axises[3]
				about center in coordsys grid rotate selection rotateAngle
			)
			else if axisDirection == -1.0 then (
				-- fill eulerAngle 
				axises[axis] = deg
				rotateAngle.x = axises[1]
				rotateAngle.y = axises[2]
				rotateAngle.z = axises[3]
				about center in coordsys grid rotate selection rotateAngle
			)
		)
		else if rotMid == #pivot then (
			if axisDirection == 1.0 then (
				-- fill eulerAngle 
				axises[axis] = deg
				rotateAngle.x = axises[1]
				rotateAngle.y = axises[2]
				rotateAngle.z = axises[3]
				about pivot in coordsys grid rotate selection rotateAngle
			)
			else if axisDirection == -1.0 then (
				-- fill eulerAngle 
				axises[axis] = deg
				rotateAngle.x = axises[1]
				rotateAngle.y = axises[2]
				rotateAngle.z = axises[3]
				about pivot in coordsys grid rotate selection rotateAngle
			)
		)
	)

	-- theObj <Editable Poly> | rotateAngle <eulerAngles> | center <point3>
	function rotatePolyVertices theObj rotateAngle: axisDirection: axis: axises: axDirFlipped: = (
		-- if calculating with axis
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				deg = 45
			)
			else if axDirFlipped == True then (
				deg = -45
			)
		)

		verts = getSelection()

		vertPosList = for i in verts collect polyop.getVert $ i
		avgPos = getAvgPos vertPosList

		if axisDirection == 1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)
		else if axisDirection == -1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)

		theTM = matrix3 1
		theTM.row4 = avgPos
		theRotTM = (rotateAngle as matrix3) * theTM  

		TMArray = #()
		TMArray[verts.count] = 0
		vertsCount = verts.count
		for i = 1 to vertsCount do (
			in coordsys theTM vert = (polyop.getVert theObj verts[i]) 
			vert *= theRotTM  
			TMArray[i] = vert
		)
		polyop.setVert theObj verts TMArray 
	)

	-- theObj <Editable Mesh> | rotateAngle <eulerAngles> | center <point3>
	function rotateMeshVertices theObj rotateAngle: axisDirection: axis: axises: axDirFlipped: = (
		-- if calculating with axis
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				deg = 45
			)
			else if axDirFlipped == True then (
				deg = -45
			)
		)

		verts = getSelection()

		vertPosList = for i in verts collect meshop.getVert $ i
		avgPos = getAvgPos vertPosList

		if axisDirection == 1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)
		else if axisDirection == -1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)

		theTM = matrix3 1
		theTM.row4 = avgPos
		theRotTM = (rotateAngle as matrix3) * theTM  

		TMArray = #()
		TMArray[verts.count] = 0
		vertsCount = verts.count
		for i = 1 to vertsCount do (
			in coordsys theTM vert = (meshop.getVert theObj verts[i]) 
			vert *= theRotTM  
			TMArray[i] = vert
		)
		meshop.setVert theObj verts TMArray 
	)

	-- theObj <Editable Spline> | rotateAngle <eulerAngles> | center <point3>
	function rotateKnots theObj rotateAngle: axisDirection: axis: axises: axDirFlipped: = (
	
		sE = showEndResult
		if sE == True or $.modifiers.count != 0 then (
			showEndResult = False
			print "Because of AWKWARDESK: Show end result is not supported! Sorry :("
			return "Because of AWKWARDESK: Show end result is not supported! Sorry :("
		)

		-- if calculating with axis
		if axDirFlipped != unsupplied then (
			if axDirFlipped == False then (
				deg = 45
			)
			else if axDirFlipped == True then (
				deg = -45
			)
		)

		verts = getSelection()

		knotPosList = #()
		for i in verts do (
			for j in i[2] do (
				knotPos = getKnotPoint $ i[1] j
				append knotPosList knotPos
			)
		)

		avgPos = getAvgPos knotPosList

		if axisDirection == 1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)
		else if axisDirection == -1.0 then (
			-- fill eulerAngle 
			axises[axis] = deg
			rotateAngle.x = axises[1]
			rotateAngle.y = axises[2]
			rotateAngle.z = axises[3]
		)

		theTM = matrix3 1
		theTM.row4 = avgPos
		theRotTM = (rotateAngle as matrix3) * theTM  

		sublevel = subobjectlevel
		convertToSplineShape theObj
		for i in verts do (
			for j in i[2] do (
				-- knot
				in coordsys theTM vert = (getKnotPoint theObj i[1] j)
				vert *= theRotTM
				setKnotPoint theObj i[1] j vert
				-- in vector
				in coordsys theTM vert = (getInVec theObj i[1] j)
				vert *= theRotTM
				setInVec theObj i[1] j vert
				-- out vector
				in coordsys theTM vert = (getOutVec theObj i[1] j)
				vert *= theRotTM
				setOutVec theObj i[1] j vert
			)
		)
		subobjectlevel = sublevel
		updateShape theObj
	)

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- 	 	-
-- 	MOVE/ROTATE ACTIONS 	-
-- 	 	-
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

	function moveTop = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()
	
		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getVerticalAxis(orientationList)
	
		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList
	
		-- base values
		m = matrix3 1
		offset = [0,0,0]
		----------------------------------------------------
	
		-- moving the objects
		if $ != undefined then (
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset matrix:m axDirFlipped:True
			)
			-- moving the subobjects
			else if superclassof $ == GeometryClass or superclassof $ == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $ == Editable_Poly then (
						movePolyVertices axisDirection:axisDirection axis:axis axDirFlipped:True
					)
					-- if the object is an editable mesh object,
					else if classof $ == Editable_Mesh then (
						moveMeshVertices axisDirection:axisDirection axis:axis axDirFlipped:True
					)
					-- if the object is a editable shape
					else if classof $ == SplineShape or classof $ == line then (
						moveKnots axisDirection:axisDirection axis:axis axDirFlipped:True
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function moveBottom = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getVerticalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		m = matrix3 1
		offset = [0,0,0]
		----------------------------------------------------

		-- moving the objects
		if $ != undefined then (
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset matrix:m axDirFlipped:False
			)
			-- moving the subobjects
			else if superclassof $ == GeometryClass or superclassof $ == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $ == Editable_Poly then (
						movePolyVertices axisDirection:axisDirection axis:axis axDirFlipped:False
					)
					-- if the object is an editable mesh object,
					else if classof $ == Editable_Mesh then (
						moveMeshVertices axisDirection:axisDirection axis:axis axDirFlipped:False
					)
					-- if the object is a editable shape
					else if classof $ == SplineShape or classof $ == line then (
						moveKnots axisDirection:axisDirection axis:axis axDirFlipped:False
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function moveLeft = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getHorizontalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		m = matrix3 1
		offset = [0,0,0]
		----------------------------------------------------

		if $ != undefined then (
			-- moving the objects
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset matrix:m axDirFlipped:False
			)
			-- moving the subobjects
			else if superclassof $ == GeometryClass or superclassof $ == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $ == Editable_Poly then (
						movePolyVertices axisDirection:axisDirection axis:axis axDirFlipped:False
					)
					-- if the object is an editable mesh object,
					else if classof $ == Editable_Mesh then (
						moveMeshVertices axisDirection:axisDirection axis:axis axDirFlipped:False
					)
					-- if the object is a editable shape
					else if classof $ == SplineShape or classof $ == line then (
						moveKnots axisDirection:axisDirection axis:axis axDirFlipped:False
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function moveRight = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getHorizontalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		m = matrix3 1
		offset = [0,0,0]
		----------------------------------------------------

		if $ != undefined then (
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset matrix:m axDirFlipped:True
			)
			-- moving the subobjects
			else if superclassof $ == GeometryClass or superclassof $ == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $ == Editable_Poly then (
						movePolyVertices axisDirection:axisDirection axis:axis axDirFlipped:True
					)
					-- if the object is an editable mesh object,
					else if classof $ == Editable_Mesh then (
						moveMeshVertices axisDirection:axisDirection axis:axis axDirFlipped:True
					)
					-- if the object is a editable shape
					else if classof $ == SplineShape or classof $ == line then (
						moveKnots axisDirection:axisDirection axis:axis axDirFlipped:True
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function averageVertical = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getHorizontalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		offset = [0,0,0]
		----------------------------------------------------
		if $ != undefined then (
			-- moving objects
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset
			)
			-- moving the subobjects
			else if superclassof $.baseObject == GeometryClass or superclassof $.baseObject == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $.baseObject == Editable_Poly then (
						movePolyVertices axis:axis
					)
					-- if the object is an editable mesh object,
					else if classof $.baseObject == Editable_Mesh then (
						moveMeshVertices axis:axis
					)
					-- if the object is a editable shape
					else if classof $.baseObject == SplineShape or classof $.baseObject == line then (
						moveKnots axisDirection:axisDirection axis:axis
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function averageHorizontal = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getVerticalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		offset = [0,0,0]
		----------------------------------------------------
		if $ != undefined then (
			if classof $ == ObjectSet then (
				moveNodes axisDirection axis:axis offset:offset
			)
			-- moving the subobjects
			else if superclassof $.baseObject == GeometryClass or superclassof $.baseObject == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					if classof $.baseObject == Editable_Poly then (
						movePolyVertices axis:axis
					)
					-- if the object is an editable mesh object,
					else if classof $.baseObject == Editable_Mesh then (
						moveMeshVertices axis:axis
					)
					-- if the object is a editable shape
					else if classof $.baseObject == SplineShape or classof $.baseObject == line then (
						moveKnots axisDirection:axisDirection axis:axis
					)
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function rotateCW = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getDepthAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		axises = [0,0,0]
		rotateAngle = (EulerAngles 0 0 0)
		----------------------------------------------------

		-- if the slection contains more then one object
		if $ != undefined then (
			if classof $ == ObjectSet then (
				rotateNodes axisDirection:axisDirection axis:axis axises:axises rotateAngle:rotateAngle axDirFlipped:True rotMid:#center
			)
			else if superclassof $ == GeometryClass or superclassof $ == shape then (
				if subobjectlevel != 0 and subobjectlevel != undefined then (
					-- moving the subobjects
					if classof $ == Editable_Poly then (
						rotatePolyVertices $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:True
					)
					-- if the object is an editable mesh object,
					else if classof $ == Editable_Mesh then (
						rotateMeshVertices $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:True
					)
					-- if the object is a editable shape
					else if classof $ == SplineShape or classof $ == line then (
						rotateKnots $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:True
					)
				)
				else (
					rotateNodes axisDirection:axisDirection axis:axis axises:axises rotateAngle:rotateAngle axDirFlipped:True rotMid:#pivot
				)
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function rotateCCW = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getDepthAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList

		-- base values
		axises = [0,0,0]
		rotateAngle = (EulerAngles 0 0 0)
		----------------------------------------------------

		-- if the slection contains more then one object
		if classof $ == ObjectSet then (
			rotateNodes axisDirection:axisDirection axis:axis axises:axises rotateAngle:rotateAngle axDirFlipped:False rotMid:#center
		)
		else if superclassof $ == GeometryClass or superclassof $ == shape then (
			if subobjectlevel != 0 and subobjectlevel != undefined then (
			-- moving the subobjects
				if classof $ == Editable_Poly then (
					rotatePolyVertices $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:False
				)
				-- if the object is an editable mesh object,
				else if classof $ == Editable_Mesh then (
					rotateMeshVertices $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:False
				)
				-- if the object is a editable shape
				else if classof $ == SplineShape or classof $ == line then (
					rotateKnots $ rotateAngle:rotateAngle axisDirection:axisDirection axis:axis axises:axises axDirFlipped:False
				)
			)
			else (
				rotateNodes axisDirection:axisDirection axis:axis axises:axises rotateAngle:rotateAngle axDirFlipped:False rotMid:#pivot
			)
			redrawViews()
		)
		else print "Wrong Selection!"
	)

	function sliceHorizontal = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getVerticalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList
		----------------------------------------------------
		
		if $ != undefined then (
			vertList = polyop.getVertSelection $
			for i in vertList do (
				pos = polyop.getVert $ i
				dir = [0,0,0]
				dir[axis] = 1.0
				planeRay = (ray pos dir)
				faces = polyop.getFaceSelection $
				if faces.numberset == 0 then (
					polyop.slice $ #{1..(polyop.getNumFaces $)} planeRay
				)
				else (
					polyop.slice $ faces planeRay
				)
			)
		)
		redrawViews()
	)

	function sliceVertical = (
		----------------------------------------------------
		-- 	getting the actual viewport referencde data 
		vpData = getVPrefPlane()

		-- 	getting the vertical orientation
		orientationList = vpData[2]
		axis = getHorizontalAxis(orientationList)

		-- getting the direction of the axis
		directionList = vpData[1]
		axisDirection = getAxisDirection axis directionList
		----------------------------------------------------
		
		if $ != undefined then (
			vertList = polyop.getVertSelection $
			for i in vertList do (
				pos = polyop.getVert $ i
				dir = [0,0,0]
				dir[axis] = 1.0
				planeRay = (ray pos dir)
				faces = polyop.getFaceSelection $
				if faces.numberset == 0 then (
					polyop.slice $ #{1..(polyop.getNumFaces $)} planeRay
				)
				else (
					polyop.slice $ faces planeRay
				)
			)
		)
		redrawViews()
	)


	function cp pos dir = (
		p = plane()
		p.pos = pos
		p.dir = dir
	)

	function sliceThroughEdge = (

		if $ != undefined then (
			if classOf $ == Editable_Poly then (
				edges = polyop.getEdgeSelection $
				for i in edges do (

					----------------------------------------------------
					-- transform matrix and inverted transform matrix of the view
					viewTM = getViewTM()
					iViewTM = inverse(getViewTM())

					-- getting the selected edges vertices
					----------------------------------------------------------
					verts = (polyop.getVertsUsingEdge $ i) as array
					
					-- getting the positions of them in local camera space
					----------------------------------------------------------
					vertA = ((polyop.getVert $ verts[1]) * iViewTM)
					vertB = ((polyop.getVert $ verts[2]) * iViewTM)

					-- projecting the coordinates to the screen
					----------------------------------------------------------
					vA = ((polyop.getVert $ verts[1]) * viewTM)
					vB = ((polyop.getVert $ verts[2]) * viewTM)
					avgZPos = (vA[3] + vB[3])/2
					vA[3] = avgZPos
					vB[3] = avgZPos

					-- slice plane position (average of the vertices)
					----------------------------------------------------------
					avgPos = ((vertA + vertB) / 2) * viewTM

					-- screen projected 2d vector check if back or front view
					----------------------------------------------------------
					vE = (vA-vB)[1]
					if vE <= 0 then (
						screenVector = (matrixFromNormal(normalize(vA-vB)) * iViewTM).row3
					)
					else (
						screenVector = (matrixFromNormal(normalize(vB-vA)) * iViewTM).row3
					)
					
					-- getting the camera up vector
					----------------------------------------------------------
					cameraUpVector = iViewTM.row2
					
					-- getting the angle between the two vectors
					----------------------------------------------------------
					angleOffset = getVectorsAngle screenVector cameraUpVector
					
					-- acquiring the rotation matrix
					rotationMatrix = RotateYPRMatrix 0 0 (angleOffset)
					-- now we have to rotate the iViewTM with the screenVector
					sliceMatrix = rotationMatrix * iViewTM
					-- setting up the position of the iViewTM which is the modified transformation matrix for align
					sliceMatrix.row4 = avgPos 

					in coordsys sliceMatrix (
						originRay = ray [0,0,0] [0,0,0]
						polyop.setSlicePlane $ originRay 50
						faces = polyop.getFaceSelection $
						if faces.numberset == 0 then (
							polyop.slice $ (#{1..(polyop.getNumFaces $)}) originRay
						)
						else if faces.numberset != 0 then (
							polyop.slice $ (polyop.getFaceSelection $) originRay
						)
					)
				)
			)
		)
		redrawViews()
	)

-- MAIN FUNCTIONS TO EXECUTE --
-------------------------------
-- moveTop()
-- moveBottom()
-- moveLeft()
-- moveRight()
-- averageVertical()
-- averageHorizontal()
-- rotateCW()
-- rotateCCW()
-- sliceHorizontal()
-- sliceVertical()
-- sliceThroughEdge()
-------------------------------

-- ) -- END OF LIB