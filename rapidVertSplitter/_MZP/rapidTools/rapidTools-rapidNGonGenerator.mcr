macroScript rapidNGonGenerator
category:"rapidTools"
toolTip: "rapidNGonGenerator"
buttonText: "rapidNGonGenerator"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidNGonGenerator.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)