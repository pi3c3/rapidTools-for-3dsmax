macroScript rapidRTConform
category:"rapidTools"
toolTip: "rapidRTConform"
buttonText: "rapidRTConform"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidRTConform.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)