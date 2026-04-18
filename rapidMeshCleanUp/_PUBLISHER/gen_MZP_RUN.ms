valid_type = #(".png", ".tif", ".gif", ".jpg", ".mse", ".run", ".mcr")
del_type = #(".mse", ".run", ".mcr")
out_name = getFileNamePath (getThisScriptFilename()) + "mzp.run"
file_path = getFileNamePath (getThisScriptFilename())
inst_files = pathConfig.removePathLeaf file_path
folder_name = pathConfig.stripPathToLeaf (pathConfig.removePathLeaf file_path)
files_array = getFiles (inst_files + "\\*")
file_names = for i = 1 to files_array.count collect (filenameFromPath files_array[i])
out_mzp_array = #()
valid_files_array = #()
valid_files_count = 0

function encryptMSFiles files = (
	
	filesCount = files.count
	
	for i = 1 to filesCount do (
		if getFileNameType files[i] == ".ms" then
			encryptScript files[i] version:1
	)
)

encryptMSFiles files_array
files_array = getFiles (inst_files + "\\*")

function validateFiles files validType = (
	
	filesCount = files.count
	validTypeCount = validType.count
	
	validFilesArray = #()
	
	for i = 1 to filesCount do (
		for j = 1 to validTypeCount do (
			if getFileNameType files[i] == validType[j] then (
				append validFilesArray files[i]
			)
		)
	)
	return validFilesArray
)

--------------------------------------------------------------------- CREATING MCR FILES ---------------------------------------------------------------------

function genMCRFiles msArray = (
	
	msArrayCount = msArray.count
	msFiles = #()
	
	for i = 1 to msArrayCount do (
		if getFileNameType msArray[i] == ".ms" then (
			append msFiles (getFilenameFile msArray[i])
		)
	)
	
	msFilesCount = msFiles.count
	
	for j = 1 to msFilesCount do (
		mcrFile = createfile (inst_files + "\\" + "rapidTools-" + (getFileNameFile msFiles[j]) + ".mcr")
		
		format "macroScript " to:mcrFile
		format msFiles[j] to:mcrFile
		format "\n" to:mcrFile
		format "category:\"rapidTools\"" to:mcrFile
		format "\n" to:mcrFile
		format "toolTip: " to:mcrFile
		format "\"" to:mcrFile
		format msFiles[j] to:mcrFile
		format "\"" to:mcrFile
		format "\n" to:mcrFile
		format "buttonText: " to:mcrFile
		format "\"" to:mcrFile
		format msFiles[j] to:mcrFile
		format "\"" to:mcrFile
		format "\n" to:mcrFile
		format "silentErrors: true" to:mcrFile
		format "\n" to:mcrFile
		format "\n" to:mcrFile

		format "(" to:mcrFile
		format "\n" to:mcrFile
			format "	mseFile = (getdir #userscripts) + \"\\\\rapidTools\\\\" to:mcrFile
			format msFiles[j] to:mcrFile
			format ".mse\"" to:mcrFile
			format "\n" to:mcrFile
			format "	if (doesFileExist mseFile) then" to:mcrFile
			format "\n" to:mcrFile
				format	"		fileIn mseFile" to:mcrFile
				format "\n" to:mcrFile
			format	"	else" to:mcrFile
			format "\n" to:mcrFile
				format	"		messageBox \"Unable to locate the script.\" title:\"ERROR!!!\"" to:mcrFile
				format "\n" to:mcrFile
		format ")" to:mcrFile
		
		close mcrFile
	)
)

genMCRFiles files_array

--------------------------------------------------------------------- CREATING MCR FILES ---------------------------------------------------------------------

global tempMZPDir
global tempRTDir
global delArray

makeDir (tempMZPDir = (inst_files + "\\" + "_MZP"))
makeDir (tempRTDir = (tempMZPDir + "\\" + "rapidTools"))
out_file = createfile (tempMZPDir + "\\" + "mzp.run")

files_array = getFiles (inst_files + "\\*") -- ALL FILES
valid_files_array = validateFiles files_array valid_type -- VALID FILES WITH PATH
valid_files_count = valid_files_array.count -- VALID FILES COUNT
valid_files = for i = 1 to valid_files_count collect (filenameFromPath valid_files_array[i]) -- VALID FILE NAMES
delete_files_array = validateFiles valid_files_array del_type
delete_files_array_count = delete_files_array.count
	
format "name " to:out_file
format "\"" to:out_file
format folder_name to:out_file
format "\"" to:out_file
format "\n" to:out_file
format "version 1.00" to:out_file
format "\n\n" to:out_file

format "treeMove " to:out_file
format "\"" to:out_file
format "rapidTools" to:out_file
format "\"" to:out_file
format " to " to:out_file
format "\"" to:out_file
format "$temp" to:out_file
format "\"" to:out_file
format "\n\n" to:out_file

format "run " to:out_file
format "\"" to:out_file
format "rt_installer.ms" to:out_file
format "\"" to:out_file
format "\n" to:out_file
format "drop " to:out_file
format "\"" to:out_file
format "rt_installer.ms" to:out_file
format "\"" to:out_file
format "\n\n" to:out_file
format "clear temp"to:out_file

close out_file
edit out_name

function copyFiles = (
	
	tempMZPDir = (inst_files + "\\" + "_MZP")
	tempRTDir = (tempMZPDir + "\\" + "rapidTools")
	
	copyFile (inst_files + "\\" + "_PUBLISHER" +"\\"+ "header.png") (tempRTDir + "\\" + "header.png")
	copyFile (inst_files + "\\" + "_PUBLISHER" +"\\"+ "rt_installer.ms") (tempMZPDir + "\\" + "rt_installer.ms")
	--copyFile (inst_files + "\\" + "_PUBLISHER" +"\\"+ "gen_mzp.ms") (tempMZPDir + "\\" + "gen_mzp.ms")
	
	for i = 1 to valid_files_count do (
		copyFile valid_files_array[i] (tempRTDir + "\\" + valid_files[i])
	)
	
	for j = 1 to delete_files_array_count do (
		deleteFile delete_files_array[j]
	)
	
	--maz (tempRTDir + "\\rt_install.mzp") valid_files
)

copyFiles()
