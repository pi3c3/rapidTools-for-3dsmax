a = polyop.getEdgeSelection $

b = polyop.getVertsUsingEdge $ a

v1 = polyop.getVert $ (b as array)[1]
v2 = polyop.getVert $ (b as array)[2]

direction = v1 - v2
	
theNormal = matrixFromNormal (normalize direction)
WorkingPivot.setTM theNormal
toolMode.coordsys #working_pivot