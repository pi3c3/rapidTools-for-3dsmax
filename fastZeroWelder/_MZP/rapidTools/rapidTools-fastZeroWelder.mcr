macroScript fastZeroWelder
category:"rapidTools"
toolTip: "fastZeroWelder"
buttonText: "fastZeroWelder"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastZeroWelder.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)