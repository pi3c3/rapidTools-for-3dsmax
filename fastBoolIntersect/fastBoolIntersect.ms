sel = selection as array

objA = undefined
objAIndex = undefined
suspendEditing which:#modify
with redraw off (
	-- checking for the first geometry object, which is capable of doing the boolean operation
	for i = 1 to sel.count do (
			if superclassof sel[i] == GeometryClass then (
				objA = sel[i]
				objAIndex = i
				exit
		)
	)

	if objA != undefined then (
		ts = timestamp()
		-- doing the boolean operation one by one, so we will get a full booleaned mesh
		for i = objAIndex+1 to sel.count do (
			if superclassof sel[i] == GeometryClass then (
				objB = sel[i]
				objA * objB
				undo on delete objB
			)
		)
		select objA
		convertToPoly objA
		print ("Intersect has taken: " + ((timestamp() - ts) as float /1000) as string + " sec")
	)
	else (
		messageBox "Wrong selection!"
	)
	resumeEditing which:#modify
)