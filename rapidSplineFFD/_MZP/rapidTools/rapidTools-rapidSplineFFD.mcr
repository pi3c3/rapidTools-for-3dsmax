macroScript rapidSplineFFD
category:"rapidTools"
toolTip: "rapidSplineFFD"
buttonText: "rapidSplineFFD"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidSplineFFD.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)