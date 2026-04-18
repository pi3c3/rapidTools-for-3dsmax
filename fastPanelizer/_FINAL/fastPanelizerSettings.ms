--macroScript RapidNGonSolverSettings Category:"rapidTools" toolTip:"RapidNGonSolverSettings" (

global updateFastPanelizerUI
global theObj = $

if fastPanelizerSettings == undefined then (
	rollout fastPanelizerSettings "fastPanelizer" width:224 height:174
	(
		groupBox grp1 "Solve" pos:[8,80] width:208 height:88
		spinner width "Width:	" pos:[38,104] width:112 height:16 range:[0.0,1000.0,0.0]
		spinner height "Height:	" pos:[35,136] width:115 height:16 range:[-1000.0,1000.0,-3.0]
		bitmap theHeader "Bitmap" pos:[8,8] width:208 height:64 fileName:((getdir #userscripts) + "\\rapidTools\\fastPanelizer_header.png")

		on width changed val do (
			if $ != undefined then (
				setUserProp $ "fastPanelizerWidth" (val as string)
			)
		)

		on height changed val do (
			if $ != undefined then (
				setUserProp $ "fastPanelizerHeight" (val as string)
			)
		)
		
		on fastPanelizer open do (
			if $ != undefined then (
				updateFastPanelizerUI()
			)
			callbacks.addScript #selectionSetChanged "updateFastPanelizerUI()" id:#fastPanelizerUIUpdate
		)
			
		on rapidSplineFFD close do (
			callbacks.removeScripts id:#fastPanelizerUIUpdate
		)
	)
)

function updateFastPanelizerUI = (
	theObj = $
	if classof theObj == objectSet then (
		theObj = theObj[1]
	)
	if theObj != undefined and theObj != OK then (
		if getUserProp theObj "fastPanelizerWidth" != undefined then (
			panelWidth = getUserProp theObj "fastPanelizerWidth"
			fastPanelizer.width.value = panelWidth
		)
		else (
			fastPanelizer.width.value = fastPanelizer.width.value
			setUserProp theObj "fastPanelizerWidth" fastPanelizer.width.value as string
		)

		if getUserProp theObj "fastPanelizerHeight" != undefined then (
			panelHeight = getUserProp theObj "fastPanelizerHeight"
			fastPanelizer.height.value = panelHeight
		)
		else (
			fastPanelizer.height.value = fastPanelizer.height.value
			setUserProp theObj "fastPanelizerHeight" fastPanelizer.height.value as string
		)
	)
)

if fastPanelizerSettings.open != True then (
	createDialog fastPanelizerSettings
)
else (
	destroyDialog fastPanelizerSettings
	createDialog fastPanelizerSettings
)

--)