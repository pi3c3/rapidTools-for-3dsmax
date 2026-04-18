-- macroScript rapidRTConformSettings buttonText:"RapidRTConformSettings" category:"rapidTools" toolTip:"rapidRTConformSettings" (

makeDir (getDir #plugcfg + "\\" + "rapidTools" + "\\")
global iniFile = getDir #plugcfg + "\\" + "rapidTools" + "\\" + "rapidRTConform.ini"
global rapidConformHeader = ((getDir #userscripts) + "\\rapidTools\\rapidRTConform_header.png")

	if doesFileExist iniFile == false do (
		setINISetting iniFile "states" "target" "true"
		setINISetting iniFile "states" "object" "true"
		setINISetting iniFile "states" "flipped" "true"
		setINISetting iniFile "states" "interactive" "true"
	)
		
	if hasINISetting iniFile "states" "target" == false do (
		setINISetting iniFile "states" "target" "true"
	)
		
	if hasINISetting iniFile "states" "object" == false do (
		setINISetting iniFile "states" "object" "true"
	)
	
	if hasINISetting iniFile "states" "flipped" == false do (
		setINISetting iniFile "states" "flipped" "true"
	)
	
	if hasINISetting iniFile "states" "interactive" == false do (
		setINISetting iniFile "states" "interactive" "true"
	)

	global targetState = getINISetting iniFile "states" "target"
	global objectState = getINISetting iniFile "states" "object"
	global flippedState = getINISetting iniFile "states" "flipped"
	global interactiveState = getINISetting iniFile "states" "interactive"
	
fn checkState varState = (
	if varState == "true" do (
		return true
	)
	
	if varState == "false" do (
		return false
	)
)

targetState = checkState(targetState)
objectState = checkState(objectState)
flippedState = checkState(flippedState)
interactiveState = checkState(interactiveState)

if rapidConformSettings == undefined then (
		rollout rapidConformSettings "rapidConformSettings" width:224 height:272
		(
			groupBox doubleSidedGrp "DoubleSided" pos:[8,80] width:208 height:120
			checkbox targetChk "Target" checked:targetState pos:[24,104] width:176 height:16
			checkbox objectChk "Object" checked:objectState pos:[24,136] width:176 height:16
			checkbox flippedChk "Flipped" checked:flippedState pos:[24,168] width:176 height:16
			groupBox interactiveGrp "Interactive Mode" pos:[8,208] width:208 height:56
			checkbox interactiveChk "Use Interactive Mode" checked:interactiveState pos:[24,232] width:176 height:16
			bitmap theHeader "bitmap" pos:[8,8] width:208 height:64 fileName:rapidConformHeader

		on targetChk changed targetState do (
			if targetState == true do (
			setINISetting iniFile "states" "target" "true"
			)
			if targetState == false do (
			setINISetting iniFile "states" "target" "false"
			)
		)

		on objectChk changed objectState do (
			if objectState == true do (
			setINISetting iniFile "states" "object" "true"
			)
			if objectState == false do (
			setINISetting iniFile "states" "object" "false"
			)
		)

		on flippedChk changed flippedState do (
			if flippedState == true do (
			setINISetting iniFile "states" "flipped" "true"
			)
			if flippedState == false do (
			setINISetting iniFile "states" "flipped" "false"
			)
		)

		on interactiveChk changed interactiveState do (
			if interactiveState == true do (
			setINISetting iniFile "states" "interactive" "true"
			)
			if interactiveState == false do (
			setINISetting iniFile "states" "interactive" "false"
			)
		)
	)
)

if rapidConformSettings.open != True then (
	createDialog rapidConformSettings
)
else (
	destroyDialog rapidConformSettings
	createDialog rapidConformSettings
)

-- )