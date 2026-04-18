--macroScript RapidNGonSolverSettings Category:"rapidTools" toolTip:"RapidNGonSolverSettings" (

makeDir (getDir #plugcfg + "\\" + "rapidTools" + "\\")
global iniFile = getDir #plugcfg + "\\" + "rapidTools" + "\\" + "nGonSolver.ini"

	if doesFileExist iniFile == false do (
		setINISetting iniFile "states" "hexagon" "true"
		setINISetting iniFile "states" "octagon" "true"
		setINISetting iniFile "states" "concave" "false"
	)
		
	if hasINISetting iniFile "states" "hexagon" == false do (
		setINISetting iniFile "states" "hexagon" "true"
	)
		
	if hasINISetting iniFile "states" "octagon" == false do (
		setINISetting iniFile "states" "octagon" "true"
	)
	
	if hasINISetting iniFile "states" "concave" == false do (
		setINISetting iniFile "states" "concave" "false"
	)

	global hexagonState = getINISetting iniFile "states" "hexagon"
	global octagonState = getINISetting iniFile "states" "octagon"
	global concaveState = getINISetting iniFile "states" "concave"
	
fn checkState varState = (
	if varState == "true" do (
		return true
	)
	
	if varState == "false" do (
		return false
	)
)

hexagonState = checkState(hexagonState)
octagonState = checkState(octagonState)
concaveState = checkState(concaveState)

if nGonSolverSettings == undefined then (
	rollout nGonSolverSettings "nGonSolvers" width:224 height:206
	(
		groupBox grp1 "Solve" pos:[8,80] width:208 height:120
		checkbox hexagonChk "Hexagons" checked:hexagonState pos:[24,104] width:176 height:16
		checkbox octagonChk "Octagons" checked:octagonState pos:[24,136] width:176 height:16
		checkbox concaveChk "Concaves (experimental)" checked:concaveState pos:[24,168] width:176 height:16
		bitmap theHeader "Bitmap" pos:[8,8] width:208 height:64 fileName:((getdir #userscripts) + "\\rapidTools\\rapidNGonSolver_header.png")
		
		on hexagonChk changed hexagonState do (
			if hexagonState == true do (
			setINISetting iniFile "states" "hexagon" "true"
			)
			if hexagonState == false do (
			setINISetting iniFile "states" "hexagon" "false"
			)
		)

		on octagonChk changed octagonState do (
			if octagonState == true do (
			setINISetting iniFile "states" "octagon" "true"
			)
			if octagonState == false do (
			setINISetting iniFile "states" "octagon" "false"
			)
		)

		on concaveChk changed concaveState do (
			if concaveState == true do (
			setINISetting iniFile "states" "concave" "true"
			)
			if concaveState == false do (
			setINISetting iniFile "states" "concave" "false"
			)
		)
	)
)

if nGonSolverSettings.open != True then (
	createDialog nGonSolverSettings
)
else (
	destroyDialog nGonSolverSettings
	createDialog nGonSolverSettings
)

--)