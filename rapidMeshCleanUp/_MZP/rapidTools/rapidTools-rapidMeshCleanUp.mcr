macroScript rapidMeshCleanUp
category:"rapidTools"
toolTip: "rapidMeshCleanUp"
buttonText: "rapidMeshCleanUp"
silentErrors: true

(
	mseFile = (getdir #userscripts) + "\\rapidTools\\rapidMeshCleanUp.mse"
	if (doesFileExist mseFile) then
		fileIn mseFile
	else
		messageBox "Unable to locate the script." title:"ERROR!!!"
)