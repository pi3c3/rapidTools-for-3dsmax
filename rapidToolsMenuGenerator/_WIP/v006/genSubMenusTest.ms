mainMenuBar = menuMan.getMainMenuBar()	
mcrCategory = "rapidTools"
menuINI = iniDest = getdir #userscripts + "\\rapidTools\\defINI\\menu.ini"

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
	createSubMenus mainMenuBar
	menuMan.updateMenuBar()