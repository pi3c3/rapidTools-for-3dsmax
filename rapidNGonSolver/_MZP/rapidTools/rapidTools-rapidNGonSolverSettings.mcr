macroScript rapidNGonSolverSettings
category:"rapidTools"
toolTip: "rapidNGonSolverSettings"
buttonText: "rapidNGonSolverSettings"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidNGonSolverSettings.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)