macroScript fastPanelizer
category:"rapidTools"
toolTip: "fastPanelizer"
buttonText: "fastPanelizer"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastPanelizer.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)