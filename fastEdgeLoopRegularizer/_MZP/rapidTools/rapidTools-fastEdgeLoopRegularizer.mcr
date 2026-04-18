macroScript fastEdgeLoopRegularizer
category:"rapidTools"
toolTip: "fastEdgeLoopRegularizer"
buttonText: "fastEdgeLoopRegularizer"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\fastEdgeLoopRegularizer.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)