function getSepSegSelList theobj = (
	ns = numsplines theobj
	sarr = #()
	
	for i = 1 to ns do (
		numsegs = numsegments theobj i
		segments = getsegselection $ i as bitarray
		
		first = undefined
		last = undefined
		allseglist = #()
		seglist = #()
		for j = 1 to numsegs+1 do (
			issel = segments[j]
			if issel then (
				append seglist j
			)
			else (
				if seglist.count != 0 then (	
					append allseglist seglist
					if seglist[1] == 1 then first = seglist
					if seglist[seglist.count] == numsegs then last = seglist
					seglist = #()
				)
			)
		)
		
		if first != undefined and last != undefined and isclosed theobj i then (
			join allseglist[allseglist.count] allseglist[1]
			deleteitem allseglist 1
		)

		for j in allseglist do (
			append sarr #(i, j)
		)
	)
	sarr
)

function getSepKnotSelList theobj = (
	ns = numsplines theobj
	sarr = #()
	
	for i = 1 to ns do (
		numsegs = numsegments theobj i
		segments = getsegselection $ i as bitarray
		
		first = undefined
		last = undefined
		allseglist = #()
		seglist = #()
		for j = 1 to numsegs+1 do (
			issel = segments[j]
			if issel then (
				append seglist j
			)
			else (
				if seglist.count != 0 then (	
					append allseglist seglist
					if seglist[1] == 1 then first = seglist
					if seglist[seglist.count] == numsegs then last = seglist
					seglist = #()
				)
			)
		)
		
		if first != undefined and last != undefined and isclosed theobj i then (
			join allseglist[allseglist.count] allseglist[1]
			deleteitem allseglist 1
		)

		for j in allseglist do (
			append sarr #(i, j)
		)
	)
	sarr
)


function getBorderKnots = (
	ns = numsplines theobj
	sarr = #()
	
	for i = 1 to ns do (
		numsegs = numsegments theobj i
		segments = getsegselection $ i as bitarray
		
		first = undefined
		last = undefined
		allseglist = #()
		seglist = #()
		for j = 1 to numsegs+1 do (
			issel = segments[j]
			if issel then (
				append seglist j
			)
			else (
				if seglist.count != 0 then (	
					append allseglist seglist
					if seglist[1] == 1 then first = seglist
					if seglist[seglist.count] == numsegs then last = seglist
					seglist = #()
				)
			)
		)
		
		if first != undefined and last != undefined and isclosed theobj i then (
			join allseglist[allseglist.count] allseglist[1]
			deleteitem allseglist 1
		)

		for j in allseglist do (
			append sarr #(i, j)
		)
	)
	sarr	
	
	
)

print getBorderKnots()