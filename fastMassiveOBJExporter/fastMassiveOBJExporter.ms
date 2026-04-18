macroScript massiveOBJExporter Category:"pi3c3's Scripts" toolTip:"massiveOBJExporter" ( -- START OF SCRIPT

fn getSelectedOBJs = ( -- put selected objects into an array. If no selection return #() array. If one selection, returns a one element array. If more a more element array.
		
	selectionArray = #()
	theSelection = $

	if theSelection != undefined then (
		if classOf theSelection != ObjectSet then (
			append selectionArray theSelection
		)
		else (selectionArray = theSelection as array)
	)
	else (return selectionArray
	free selectionArray
	)
)
	
fn removeExtension fileString = ( -- leszedi a kiterjsztést
	fileString = fileString as string
	fileString = substring fileString 1 (fileString.count-4)
	return fileString
)

fn makeOBJFolder = (
	OBJfolder = makeDir (maxFilePath + "\\" + removeExtension (maxFileName) + "OBJ")
	return OBJFolder
)

fn getOBJFolder = (
	filePath = maxFilePath
	OBJFolder = filePath + removeExtension (maxFileName) + "OBJ"
	return OBJFolder
)

fn getBadObjects OBJs= (
	
	badObjects = #()
	
	for i = 1 to OBJs.count do (
		if 	superclassof OBJs[i] != geometryClass do (
			append badObjects selectedObjects[i]
		)
	)
	return badObjects
)

fn exportSelected theOBJs = (
	
	promptFlag = true
	
	if selection.count != 0 then (
		makeOBJFolder()
		theOBJFolder = getOBJFolder()
		
		for i = 1 to theOBJs.count do (
			select theOBJs [i]
			fileNum = i as string
			OBJName = theOBJs[i].name
			if promptFlag == true then (
				exportFile (theOBJFolder + "\\" + OBJName +".obj") selectedOnly:true using:Wavefront_Object
				promptFlag = false
			)
			else (exportFile (theOBJFolder + "\\" + OBJName +".obj") #noPrompt selectedOnly:true using:Wavefront_Object) --this saves ("copies") the objects as a file
		)
	)
else (messageBox "Select mesh please!")
)

selectedObjects = getSelectedOBJs()
badObjects = getBadObjects (selectedObjects)

if badObjects.count != 0 then (
		messageBox "There's a non editable poly object in the selection! Please use Selection Filter or Collapse the Modifier Stack"
	)
	else (exportSelected selectedObjects)
) -- END OF SCRIPT