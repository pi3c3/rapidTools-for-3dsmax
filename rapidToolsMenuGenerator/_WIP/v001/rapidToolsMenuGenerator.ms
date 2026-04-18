mcrArray = (getFiles ((getdir #usermacros) + "\\rapidTools*"))
mcrCategory = "rapidTools"
	
function createMenu menuName = (
	mainMenuBar = menuMan.getMainMenuBar()
	menu = menuMan.createMenu menuName
	newMenu = menuMan.createSubMenuItem menuName menu
	newSubMenu = mainMenuBar.addItem newMenu -1
)

function addAction actionCateg theAction = (
	mainMenuBar = menuMan.getMainMenuBar()
	myAction = menuMan.createActionItem theAction actionCateg -- this is the action you want to add to the menu bar
	index = mainMenuBar.numItems()
	theMenu = mainMenuBar.getItem(index)
	theSubMenu = theMenu.getSubMenu()
	theSubMenu.addItem myAction -1
)

function getFileNameArray filePathArray = (
	filePathArrayCount = filePathArray.count
	fileNameArray = for i = 1 to filePathArrayCount collect substituteString (getFileNameFile (fileNameFromPath filePathArray[i])) "rapidTools-" ""
	return fileNameArray
)

if menuMan.findMenu "rapidTools" == undefined then (

actionNames = getFileNameArray mcrArray
actionNamesCount = actionNames.count

createMenu "rapidTools"

for i = 1 to actionNamesCount do (
	addAction mcrCategory actionNames[i]
)

menuMan.updateMenuBar()
--)

getdir #ui