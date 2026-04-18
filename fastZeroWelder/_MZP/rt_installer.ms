------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--																				--
--	rapidTools installer																--
--	written by: Gábor Miklós (pi3c3)														--
--	version: 1.1																	--
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

global checkFlag = true

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
		
		checkFlag = true
		
		if fileArray != undefined do (
			fileArrayCount = fileArray.count
			for i = 1 to fileArrayCount do (
				if doesFileExist (destFolder + filenameFromPath fileArray[i]) == true then (deleteFile (destFolder + filenameFromPath fileArray[i]))
				copyFile fileArray[i] (destFolder + filenameFromPath fileArray[i])
				if doesFileExist (destFolder + filenameFromPath fileArray[i]) == false then (checkFlag = false)
			)
		)
		return checkFlag
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
		if checkFlag == true then (
			messageBox "Thank you for buying rapidTools! Happy rapid modeling! :)"
			messageBox "Please restart 3dsmax to take effect!"
			destroyDialog rtInstaller
		)
		else if checkFlag == false then (
			messageBox "Something went wrong, because the installation wasn't succesfull!\nTry install in administrator mode!"
		)
	)
)

createDialog rtInstaller