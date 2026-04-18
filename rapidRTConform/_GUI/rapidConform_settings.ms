macroScript rapidRTConformSettings buttonText:"RapidRTConformSettings" category:"rapidTools" toolTip:"rapidRTConformSettings" (

makeDir (getDir #plugcfg + "\\" + "rapidTools" + "\\")
global iniFile = getDir #plugcfg + "\\" + "rapidTools" + "\\" + "rapidRTConform.ini"

	if doesFileExist iniFile == false do (
		setINISetting iniFile "states" "target" "true"
		setINISetting iniFile "states" "object" "true"
	)
		
	if hasINISetting iniFile "states" "target" == false do (
		setINISetting iniFile "states" "target" "true"
	)
		
	if hasINISetting iniFile "states" "object" == false do (
		setINISetting iniFile "states" "object" "true"
	)

	global targetState = getINISetting iniFile "states" "target"
	global objectState = getINISetting iniFile "states" "object"
	
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

rollout rapidConformSettings "rapidConformSettings" width:224 height:176
(
	groupBox doubleSidedGrp "DoubleSided" pos:[8,80] width:208 height:88
	checkbox targetChk "Target" checked:targetState pos:[24,104] width:176 height:16
	checkbox objectChk "Object" checked:objectState pos:[24,136] width:176 height:16
	bitmap theHeader "bitmap" pos:[8,8] width:208 height:64 fileName:"J:\Scripts\3dsmax\\rapidRTConform\_HEADER\\rapidConform_header.png"

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
)

createDialog rapidConformSettings

)