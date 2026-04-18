------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--																				--
--	rapidTools installer																--
--	written by: Gábor Miklós (pi3c3)														--
--	version: 1.0																	--
--																				--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
header = getdir #temp + "\\rapidTools\header.png"
temp = getdir #temp + "\\rapidTools" --
imageExt = #("png", "jpg", "gif", "tif")
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--msFiles = #()
mseFiles = #()
mcrFiles = #()
imageFiles = #()
allFileArray = #(imageFiles, msFiles, mseFiles, mcrFiles)
----------------------------------------------------------------------------------------------------------------------------------------------------------------
--msDest = getdir 
mseDest = getdir #userscripts + "\\rapidTools\\"
mcrDest = getdir #usermacros + "\\"
imagesDest = getdir #userscripts + "\\rapidTools\\"

function install = (

	makedir mseDest
	makedir mcrDest
	makedir imagesDest
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	function getFilesByExtension thePath theExt = (
		
		if classof theExt == string then (
			theFiles = getFiles (thePath + "\*." + theExt)
			return theFiles
		)
		
		else if classof theExt == array then (
			theExtArraycount = theExt.count
			theFiles = #()
			
			for i = 1 to theExtArrayCount do (
				theFile = getFiles (thePath + "\*." + theExt[i])
				theFiles = theFiles + theFile
			)
		return theFiles
		)
	)
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	--msFiles = getFilesByExtension temp "ms"
	mseFiles = getFilesByExtension temp "mse"
	mcrFiles = getFilesByExtension temp "mcr"
	imageFiles = getFilesByExtension temp imageExt

	function copyFiles fileArray destFolder = (
		if fileArray != undefined do (
			fileArrayCount = fileArray.count
			for i = 1 to fileArrayCount do (
				copyFile fileArray[i] (destFolder + filenameFromPath fileArray[i])
			)
		)
	)
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
	copyFiles mseFiles mseDest
	copyFiles mcrFiles mcrDest
	copyFiles imageFiles imagesDest
	----------------------------------------------------------------------------------------------------------------------------------------------------------------
)

rollout rtInstaller "rapidTools Installer" width:488 height:168 (
	
	bitmap header "installerHeader" filename:(getdir #temp + "\\rapidTools\header.png") pos:[8,8] width:472 height:112 
	button instBtn "Install rapidTools" pos:[8,128] width:472 height:32

	on instBtn pressed do(
		install()
	)
)

createDialog rtInstaller