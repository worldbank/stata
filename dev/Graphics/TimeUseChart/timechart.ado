
cap prog drop timechart
prog def timechart

syntax [if] [in], id(varlist) start(varname) end(varname) [names(varname)] [labels(varname)] [class(varname)] [classcolors(string asis)] [*]

marksample touse
preserve

* Set up unique IDs

	keep if `touse'
	
	tempvar tempid
	egen `tempid' = group(`id')
		
		qui sum `tempid'
		replace `tempid' = `r(max)' - `tempid' + 1
		cap `sort' `tempid'
	
* Set up names
		
	if "`names'" == "" {
		tempvar tempname
		gen `tempname' = `tempid'
		local names = "\`tempname'"
		}
	
		qui sum `tempid'
		local ymax = `r(max)'
		
	tempfile a
		save `a'
		collapse (first) `names', by(`tempid')
		
		sort `tempid'
		
		forvalues i = 1/`ymax' {
			local theLabel = `names'[`i']
			if "`theLabel'" != "`theLastLabel'" local theLabels `theLabels' `i' "`theLabel'"
			local theLastLabel = `names'[`i']
			}
		
	use `a', clear

* Set up labels
	
	if "`labels'" != "" {
		local labplot (scatter `tempid' `start', msym(none) mlab(`labels') mlabangle(0) mlabpos(3) mlabcolor(black))
		}
		
* Number observations

	tempvar n
	bys `id': gen `n' = _n

* Count largest group

	qui sum `n'
	local nmax = `r(max)'
	
* Set up classes
	
	if "`class'" == "" {
		tempvar falseclass
		gen `falseclass' = 1
			lab def false 1 "False"
			label val `falseclass' false
			local legend "legend(off)"
		local class \`falseclass'
		}
	
	save `a', replace
	local thelabel: val label `class' 
	uselabel `thelabel', clear
			qui count
			local nclass = `r(N)'
			local theValues ""
			forvalues i = 1/`nclass' {
				local nextValue = value[`i']
				local nextLabel = label[`i']
				if `nclass' > 1 local legend `"`legend' `i' "`nextLabel'""'
				local theValues = "`theValues' `nextValue'"
				}
				
			if `nclass' > 1 local legend `"legend(order(`legend'))"'
				
		use `a', clear

* Build list of plots

	forvalues i = 1/`nmax' {
		local classIndex = 0
		foreach j in `theValues' {
			local ++classIndex
			local theColor : word `classIndex' of `classcolors'
			if "`theColor'" == "" local theColor black
			local plots `plots' (rcap `start' `end' `tempid' if `n' == `i' & `class' == `j', hor lc(`theColor'))
			}
		}
	
* Graph
	
	local ytop = `ymax' + 1
	
	* di `" tw `plots' `labplot' , `legend' ytit(" ") ylab( 0 " " `theLabels' `ytop' " ", angle(0) noticks) graphregion(color(white)) title(, color(black) span) subtitle(, color(black) span) `options'  "'
	
	tw `plots' `labplot' , `legend' ytit(" ") xtit(" ")  ylab( `theLabels' , angle(0) noticks) yscale(reverse) ///
		graphregion(color(white)) title(, color(black) span) subtitle(, color(black) span) `options' ylab(,grid)

end
