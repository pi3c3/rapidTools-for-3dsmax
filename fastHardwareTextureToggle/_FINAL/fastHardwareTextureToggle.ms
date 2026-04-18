if toggle == true then (
	toggle = false
)
else if toggle == false then (
	toggle = true
)

if toggle == false then (
	for i in scenematerials do (
		try (
	 		showTextureMap i toggle
			enableHardwareMaterial i toggle	
			showHWTextureMap i toggle
	
		)
		catch continue
	)
)

else if toggle == true then (
	for i in scenematerials do (
		try (
	 		showTextureMap i toggle
			showHWTextureMap i toggle
			enableHardwareMaterial i toggle
			
		)
		catch continue
	)
)