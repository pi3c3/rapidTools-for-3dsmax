mcrArray = (getFiles ((getdir #usermacros) + "\\rapidTools*"))
mcrCategory = "rapidTools"
mainMenuBar = menuMan.getMainMenuBar()
theMenuItem = ""

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

	-- HERE THE SCRIPT CHECK IF THE MENU EXISTS OR NOT
	-- IF EXISTS IT CHANGES THE MENUEXISTS FLAG TO TRUE
	
	numMenus = mainMenuBar.numItems()
	menuExists = false

	for i = 1 to numMenus do (
		testMenu = mainMenuBar.getItem i
		if testMenu.getTitle() == mcrCategory then (
			menuExists = true
			theMenuItem = testMenu
		)
	)

	if menuExists == false then ( -- IF MENUEXISTS IS FALSE, IT CREATES THE MENU

		actionNames = getFileNameArray mcrArray
		actionNamesCount = actionNames.count

		createMenu "rapidTools"

		for i = 1 to actionNamesCount do (
			addAction mcrCategory actionNames[i]
		)

		menuMan.updateMenuBar()
	)
	else ( -- IF IT'S TRUE, THEN IT ASKS IF IT CAN BE DELETED BEFORE REPLACEING IT
		if queryBox "The Menu already exists! Do you want to replace it?" then (
			mainMenuBar.removeItem theMenuItem
			menuMan.updateMenuBar()
			
			actionNames = getFileNameArray mcrArray
			actionNamesCount = actionNames.count

			createMenu "rapidTools"

			for i = 1 to actionNamesCount do (
				addAction mcrCategory actionNames[i]
			)
			
			menuMan.updateMenuBar()
		)
	)