-- escapeEnable = true
-- clearListener()

struct actionInspector (
	multiConnect_lastEdge = undefined,
	multiConnect_lastGeo = undefined, 
	multiConnect_lastDir = 1
)

function getOrderedRing sel gCO dir:1 = (
	edgeSel = polyop.getEdgeSelection sel
	if edgeSel.numberset == 2 then (
		firstEdge = (edgeSel as array)[1]
		secondEdge = (edgeSel as array)[2]
		polyop.setEdgeSelection sel firstEdge
		gCO.SelectEdgeRing()
		allEdges = polyop.getEdgeSelection sel 

		polyop.setEdgeSelection sel firstEdge
		edgeCount = allEdges.numberset

		sameRing = findItem allEdges secondEdge

		if sameRing != 0 then (
			i = 0
			ring = #(firstEdge)
			while lastEdge != secondEdge and i != 100 do (
				$.setRingShift actInsp.multiConnect_lastDir true false
				currEdge = (polyop.getEdgeSelection sel as array)[1]
				if lastEdge != currEdge then (
					append ring currEdge
					lastEdge = currEdge 
				)
				else (
					actInsp.multiConnect_lastDir = -1 * actInsp.multiConnect_lastDir
					ring = #(firstEdge)
					polyop.setEdgeSelection sel firstEdge
				)
				i+= 1
			)
			polyop.setEdgeSelection sel ring
			gCO.connectEdges()
			actInsp.multiConnect_lastEdge = polyop.getEdgeSelection sel
			actInsp.multiConnect_lastGeo = sel
		)
	)
	else if (actInsp.multiConnect_lastEdge - (polyop.getEdgeSelection sel)).numberset == 0 and actInsp.multiConnect_lastGeo == sel then (
		edges = polyop.getEdgeSelection sel
		vertices = polyop.getVertsUsingEdge sel edges
		baseEdges = for i in vertices where 

		gCO.Remove selLevel:#edge
		gCO.Remove selLevel:#vertex
-- 		actInsp.multiConnect_lastDir = -1 * actInsp.multiConnect_lastDir
-- 		getOrderedRing sel gCO dir:-1
-- 		actInsp.multiConnect_lastEdge = polyop.getEdgeSelection sel
-- 		actInsp.multiConnect_lastGeo = sel
	)
)

if actInsp == undefined then (
	global actInsp = actionInspector()
)

gCO = modPanel.getCurrentObject()
getOrderedRing $ gCO

print actInsp.multiConnect_lastEdge
print actInsp.multiConnect_lastGeo