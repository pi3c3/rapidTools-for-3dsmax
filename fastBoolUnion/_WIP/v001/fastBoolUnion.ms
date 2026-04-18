-- theHold.Begin() 
fn shapeFilt o = (superClassOf o == GeometryClass)
ts = timestamp()
objB = pickObject 1 filter:shapeFilt
if objB != undefined then (
	objA = selection as array
	convertToMesh objA
	for i = 2 to objA.count do attach objA[1] objA[i]
	objA = $
	objB+objA
	undo on delete objA
	select objB
	convertToPoly objB
	print ("Union has taken: " + ((timestamp() - ts) as float /1000) as string + " sec")
)
else print "Operation Cancelled!"
-- theHold.Accept()
-- theHold.End()