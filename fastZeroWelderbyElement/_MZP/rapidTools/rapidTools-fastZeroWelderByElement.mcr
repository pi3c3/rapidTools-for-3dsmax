macroScript fastZeroWelderByElement
category:"rapidTools"
toolTip: "fastZeroWelderByElement"
buttonText: "fastZeroWelderByElement"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastZeroWelderByElement.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)