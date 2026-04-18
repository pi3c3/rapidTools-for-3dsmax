macroScript rapidNGonSolver
category:"rapidTools"
toolTip: "rapidNGonSolver"
buttonText: "rapidNGonSolver"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidNGonSolver.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)