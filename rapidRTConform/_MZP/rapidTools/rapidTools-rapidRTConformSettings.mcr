macroScript rapidRTConformSettings
category:"rapidTools"
toolTip: "rapidRTConformSettings"
buttonText: "rapidRTConformSettings"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidRTConformSettings.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)