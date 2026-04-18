fileIn (getdir #userscripts + "\\" + "rapidTools" + "\\" + "rapidSplineFFDlib.ms")
-- fileIn ("E:\\Scripts\\3dsmax\\rapidSplineFFD\\_WIP\\v013\\" + "rapidSplineFFDlib.ms")

if rtsFFD == undefined then (
	rtsFFD = rapidTools_SFFD()
)

rtsFFD.rapidSplineFFD()
