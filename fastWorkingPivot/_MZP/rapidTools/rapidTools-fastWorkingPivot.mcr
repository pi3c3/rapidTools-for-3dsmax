macroScript fastWorkingPivot
category:"rapidTools"
toolTip: "fastWorkingPivot"
buttonText: "fastWorkingPivot"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastWorkingPivot.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)