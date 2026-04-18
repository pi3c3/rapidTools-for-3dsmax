macroscript moveFarLeft category:"rapidTools" tooltip:"Move Far Left" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global moveLeft
	moveLeft()
)

macroscript moveFarRight category:"rapidTools" tooltip:"Move Far Right" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global moveRight
	moveRight()
)

macroscript moveFarTop category:"rapidTools" tooltip:"Move Far Top" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global moveTop
	moveTop()
)

macroscript moveFarBottom category:"rapidTools" tooltip:"Move Far Bottom" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global moveBottom
	moveBottom()
)

macroscript averageHorizontal category:"rapidTools" tooltip:"Move Average Horizontal" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global averageHorizontal
	averageHorizontal()
)

macroscript averageVertical category:"rapidTools" tooltip:"Move Average Vertical" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global averageVertical
	averageVertical()
)

macroscript rotateClockWise category:"rapidTools" tooltip:"Rotate Clock Wise" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global rotateCW
	rotateCW()
)

macroscript rotateCounterClockWise category:"rapidTools" tooltip:"Rotate Counter Clock Wise" (
	scriptPath = getdir #userscripts + "\\rapidTools\\fastMoveFarthestLib.ms"
	filein scriptPath
	global rotateCCW
	rotateCCW()
)
