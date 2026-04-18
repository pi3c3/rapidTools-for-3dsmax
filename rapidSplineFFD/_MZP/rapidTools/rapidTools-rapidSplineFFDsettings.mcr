macroScript rapidSplineFFDsettings
category:"rapidTools"
toolTip: "rapidSplineFFDsettings"
buttonText: "rapidSplineFFDsettings"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidSplineFFDsettings.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)