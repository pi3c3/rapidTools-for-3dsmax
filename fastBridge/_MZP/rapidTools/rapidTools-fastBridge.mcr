macroScript fastBridge
category:"rapidTools"
toolTip: "fastBridge"
buttonText: "fastBridge"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastBridge.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)