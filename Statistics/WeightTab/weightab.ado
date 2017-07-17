* Survey (weighted) table

cap prog drop weightab
prog def weightab

	syntax ///
		anything 					/// Variables list
		[using/] 					///	Output file for xlsx table
		[if] [in] 					/// As usual
		[pweight]					///	Weighting of observations
		, ///
		over(string asis) 			/// List of variables defining categorical groups. Values should be labeled.
		[stats(string asis)] 		/// Choose from [b se t pvalue ll ul df crit eform] for reporting
		[graph] 					/// Produce bar graph of results
			[se] 					/// Includes 95% CI
			[dropzero] 				/// Removes zeroes from graph
			[barlook(string asis)] 	/// Sets look-of-bar options
			[barlab]				/// Labels bars with percentages
			[*] 					/// All remaining twoway options
		
		
qui {

* Setup

	unab anything : `anything'

* Options

	if "`stats'" == "" local stats "b se"

* Initialize results datasets

	preserve

	clear
	tempfile results
		save `results', replace emptyok
		
	tempfile output
		save `output', replace emptyok
		
	restore
	
* Preserve
	
	preserve

* Set up survey data weights

	marksample touse
	keep if `touse' == 1

	svyset , clear
	svyset [`weight' `exp']
	
	tempfile data
		save `data', replace
	
* Loop over variables

	qui foreach var in `anything' {
		use `data', clear
		
		* Calculate weighted statistics
		
		local theLabel : var label `var'
		svy: mean `var' , over(`over')
			mat a = r(table)'
			
		* Compile
		
		clear
		svmat a , names(col)
			gen label = "`theLabel'"
			gen varname = "`var'"
			gen over = ""
				local x = 1
				local overlist `"`e(over_labels)'"'
				foreach group in `overlist' {
					replace over = "`group'" in `x'
					local ++x
					}
		
		append using `results'
			save `results', replace
		
		}
		
* Compile statistics

	egen overgroup = group(over)
	
	tempfile allstats
		save `allstats' , replace
	
		qui levelsof overgroup , local(levels)
		foreach level in `levels' {
			use `allstats', replace
			keep if overgroup == `level'
			local theLabel = over[1]
			local allLabels `"`allLabels' "`theLabel'" "'
			}
	
	qui foreach statistic in `stats' {
		use `allstats' , clear
		
		rename `statistic' stat_temp
		
		keep stat_temp varname label overgroup
		
		reshape wide stat_temp , i(varname) j(overgroup)
		gen stat = "`statistic'"
		
		append using `output'
			save `output', replace
			
		}
		
		local x = 1
		foreach level in `levels' {
			local theLabel : word `x' of `allLabels'
			label var stat_temp`level' "`theLabel'"
			local ++x
			}

		local x = 1
		gen order = .
		foreach var in `anything' {
			replace order = `x' if varname == "`var'"
			local ++x
			}
			
		sort order stat
		
		label var label "Variable"
		label var stat "Statistic"
		
		replace label = "" if stat != "b"
		
	* Write
			
		if "`using'" != "" export excel label stat stat_temp* using `"`using'"' , first(varl) replace
		
* Bar graph
if "`graph'" != "" {

	* Set up statistics  for graphing

		use `allstats' , clear
		
		if "`dropzero'" != "" drop if b == 0
		
		local x = 1
			gen order = .
			foreach var in `anything' {
				replace order = `x' if varname == "`var'"
				local ++x
				}
		
			gen sort1 = -order
			gen sort2 = -overgroup
		
		sort sort1 sort2
	
	* Set y-positions
	
		gen pos = 0
		local x = 0
		local i = 1
		qui count
		local lastVar = varname[1]
		qui forvalues i = 1/`r(N)' {
			local thisVar = varname[`i']
			if "`thisVar'" != "`lastVar'" local ++x
			local lastVar = varname[`i']
			replace pos = 0.05 * `x' in `i'
			local ++i
			local ++x
			}
			
	* Set y-labels
		
		qui levelsof label, local(allLabels)
		foreach var in `allLabels' {
			qui sum pos if label == "`var'"
			local theYlabels `"`theYlabels' `r(mean)' "`var'""'
			}
		
	* Set graphing commands and styling
	
		tempfile final
		save `final' , replace
				
		qui foreach level in `levels' {
		
			if regexm(`"`barlook'"',`"`level' "') {
				
				local k = strpos("`barlook'","`level' ")+2 
				local j = `level' + 1
				local j = strpos("`barlook'","`j' ") - `k' +2
				if `j' <= 0 local j "."
				
		
				local theoptions = substr("`barlook'",`k',`j'-3)
							
				}
				
			local plots `"`plots' (bar b pos if overgroup == `level', horizontal barwidth(0.05) `theoptions') "'
			if "`se'" != "" local plots `"`plots' (rcap ul ll pos if overgroup == `level', horizontal lc(black) lw(vthin) msize(vsmall)) "'
			
			use `final', clear
				keep if overgroup == `level'
				local theLabel = over[1]
				if "`se'" != "" local theOrder = 2*`level' -1
				if "`se'" == "" local theOrder = `level'
				local legendorder `"`legendorder' `theOrder' "`theLabel'""'
			
			}
			
	* Labels
	
		if "`barlab'" != "" {
			local blabplot (scatter pos b, mlabel(b_label) msymbol(none) mlabc(black) mlabs(1.8) mlabp(3))
			}
			
	* Graph
		
		use `final', clear
		
		gen b_label = string(round(b*100,1)) + "%"
				
		tw ///
			`plots' `blabplot' ///
		, 	ylab(`theYlabels', angle(0) notick) ytit("") xtit("") ///
			legend(order(`legendorder')) `options'
			
	} // end graph option
		
} // end qui
		
end
	
* Have a lovely day!!
