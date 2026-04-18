mcrArray = (getFiles ((getdir #usermacros) + "\\rapidTools*"))
menuINI = iniDest = getdir #userscripts + "\\rapidTools\\defINI\\menu.ini"
mcrCategory = "rapidTools"
mainMenuBar = menuMan.getMainMenuBar()
theMenuItem = ""

	function readMenuINI what = (
		toolNames = getINISetting menuINI
		toolCategories = for i in toolNames collect getINISetting menuINI i "category"
		if what == "names" then (
			return toolNames
		)
			
		else if what == "categories" then (
			return toolCategories 
		)
	)

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
	
	-- create categorized menu function
	function createSubMenus rtMenu = (
		local rtMenu
		for i = 1 to mainMenuBar.numItems() do (
			menu = mainMenuBar.getItem(i)
			if menu.getTitle() == mcrCategory do (
				rtMenu = menu
			)
		)
		
		rtMenu = rtMenu.getSubMenu()
		rtMenu.numItems()
		
		itemNameArr = readMenuINI "names"
		categoryArr = readMenuINI "categories"
		categs = makeUniqueArray categoryArr
		
		categIndices = #()
		for i = 1 to categs.count do (
			menuExists = False
			for j = 1 to rtMenu.numItems() do (
				subMenu = rtMenu.getItem j
				subMenuName = subMenu.getTitle()
				if subMenuName == categs[i] then (
					menuExists = True
					append categIndices j
				)
			)
			if menuExists == False then (
				myMenu = menuMan.createMenu categs[i]
				theSubMenu = menuMan.createSubMenuItem categs[i] myMenu
				rtMenu.addItem theSubMenu (rtMenu.numItems()+1)
				append categIndices (rtMenu.numItems())
			)
		)

		for i = 1 to itemNameArr.count do (
			itemCategory = categoryArr[i]
			itemName = itemNameArr[i]
			index = (findItem categs itemCategory)
			menu = rtMenu.getItem categIndices[index]
			subMenu = menu.getSubMenu()
			myAction = menuMan.createActionItem itemNameArr[i] mcrCategory
 			subMenu.addItem myAction -1
		)
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

		if queryBox "Do you want a sub-menu based, or a single list menu?" then (
			createSubMenus mainMenuBar
		)
		else (
			for i = 1 to actionNamesCount do (
				addAction mcrCategory actionNames[i]
			)
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

			if queryBox "Do you want a sub-menu based, or a single list menu?" then (
				createSubMenus mainMenuBar
			)
			else (
				for i = 1 to actionNamesCount do (
					addAction mcrCategory actionNames[i]
				)
			)
			menuMan.updateMenuBar()
		)
	)
	
menuMan.findMenu "Object"