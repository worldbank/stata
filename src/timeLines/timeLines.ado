
cap prog drop timeLines
prog def timeLines

syntax [if] [in], id(varlist) start(varname) end(varname) ///
	[names(varname)] [labels(varname)] [class(varname)] ///
	[classcolors(string asis)] [labopts(string asis)] [*]

marksample touse
preserve

* Set up unique IDs

	keep if `touse'
	
	tempvar tempid
	egen `tempid' = group(`id') , label
	/*	
		qui sum `tempid'
		replace `tempid' = `r(max)' - `tempid' + 1
		cap `sort' `tempid'
	*/
* Set up names
		
	if "`names'" == "" {
		tempvar tempname
		decode `tempid' , gen(`tempname')
		local names = "\`tempname'"
		}
	
		qui sum `tempid'
		local ymax = `r(max)'
		local ymin = `r(min)'
		
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
		local labplot (scatter `tempid' `start', msym(none) mlab(`labels') mlabangle(0) mlabpos(1) mlabcolor(black) `labopts')
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
				
			if `nclass' > 1 local legend `"legend(region(lc(none) fc(none)) order(`legend'))"'
				
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
	
	qui su `start'
	gen xbot = `r(min)'
	gen ytop = `ymin' - 0.5
		
	tw `plots' `labplot' (scatter ytop xbot in 1 , m(none)), `legend' ytit(" ") xtit(" ")  ylab( `theLabels' , angle(0) noticks) yscale(reverse) ///
		graphregion(color(white)) title(, color(black) span) subtitle(, color(black) span) `options' ylab(,grid) bgcolor(white)

end

/** DEMO

webuse census , clear
keep in 40/50
replace pop18p = pop18p / 1000
replace pop = pop / 1000
format pop18p %tdMon_CCYY
drop if state == "Virginia"
xtile category = popurban , n(2)
	label def category 1 "Early Adopters" 2 "Late Adopters"
	label val category category
timeLines , ///
  id(region) start(pop18p) end(pop) ///
  labels(state) labopts(mlabangle(30)) ///
  xsize(7) class(category) classcolors(maroon navy)
  
  graph export "/users/bbdaniels/desktop/timeLines.png" , replace
  
* Have a lovely day!
