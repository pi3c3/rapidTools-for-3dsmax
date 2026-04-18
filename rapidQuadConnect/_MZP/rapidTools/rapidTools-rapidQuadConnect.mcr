macroScript rapidQuadConnect
category:"rapidTools"
toolTip: "rapidQuadConnect"
buttonText: "rapidQuadConnect"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidQuadConnect.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)