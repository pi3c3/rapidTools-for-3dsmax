-- macroScript pubObject Category:"rapidTools" toolTip:"makiBoolean" (
function meshFilt obj = (superClassOf obj == GeometryClass) -- pickObject needs this function
theObj = $
theTarget = pickObject count:1 filter:meshFilt 
theObj - theTarget
delete theTarget
select theObj
convertToPoly theObj
subobjectlevel = 1
-- )