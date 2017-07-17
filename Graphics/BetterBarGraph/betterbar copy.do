** Generates better bar graphs

cap prog drop betterbar
prog def betterbar

syntax anything 				/// Variable list should be parenthesis-grouped to produce grouping if desired.
	[using]						/// For output
	[if] [in] [pweight], 				///
	[stats(string asis)]		/// Stats to display in caption
	[Vertical]					/// Horizontal bar is the default.
	[se]						/// Plots standard error bars.
	[n]							/// Affixes sample sizes in legend.
	[dropzero]					/// Drops zeroes
	[BINomial]					/// Plots standard error bars using binomial distribution; only if se is on.
	[Over(varlist)]				/// Determines groups for comparison at the lowest level.
	[Descending(string asis)]	/// Sorts with largest bar first; enter the logic expression identifying the sort group (ie, one == for each var of varlist). Use (1) if only one group.
	[Ascending(string asis)]	/// Sorts with smallest bar first; enter the logic expression identifying the sort group (ie, one == for each var of varlist). Use (1) if only one group.
	[BARlab(string asis)]		/// Labels bars with means. Specify location: upper, lower, mean, zero.
	[barlook(string asis)]		/// Allows specification of bar look options - write barlook(1 [styles] 2 [styles] ...)
	[labsize(string asis)]		/// Set categorical exis labelling size
	[by(varlist)]				/// Separate variables
	[nobylabel]					/// REMOVE Labels from by-variable
	[nobycolor]					/// REMOVE Coloration from by-variable
	[novarlab]					/// REMOVE Variable names
	[stat(string asis)]			/// Sums specified variables instead. Cannot be combined with se.
	[addplot(string asis)]		/// Add plots
	[nobarplot]					/// Suppress bars
	[*]							/// Allows any normal options for tw to be entered.

preserve
marksample touse
qui keep if `touse'

* Calculate display statistics if specified

	if "`stats'" != "" {
		gen N = _N
			label var N "Number of Observations"
		foreach var of varlist `stats' {
			qui sum `var'
				local stat = string(round(`r(mean)',0.01))
			local label : var label `var'
			local addStats `"`addStats' "`label' = `stat'" "'
			}
			
		local addStats `"cap(`addStats', span pos(11))"'
		}

* Set up options

	* Collapse stata
		
		if "`stat'" == "" local stat "mean"

	* Label size
	
		if "`labsize'" == "" {
			local labsize "small"
			}

	* Vertical bars
	
		if "`vertical'" == "" {
			local horizontal horizontal
			local labelaxis y
			local valueaxis x
			local scatter x \`barlab'
			local axisfix x zero
			}
		else {
			local horizontal vertical
			local labelaxis x
			local valueaxis y
			local scatter \`barlab' x
			local axisfix zero x
			}

	* Standard error bars
	
		if "`binomial'" == "binomial" {
			local serrstat seb
			}
		else {
			local serrstat sem
			}

		if "`se'" == "se" {
			local seplot "(rcap upper lower x, `horizontal' lc(black) lw(vthin) msize(vsmall))" // Set up tw graph for standar errors
			}
			
	* Over & by groups
	
		label def placeholder 1 "Placeholder"
	
		if "`over'" == "" {
			gen _over = 1
			local over _over
				label val _over placeholder
			}
			
		if "`by'" == "" {
			gen _by = 1
			local by _by
				label val _by placeholder
			}
				
		foreach var of varlist `over' `by' { // Drop observations with ANY missing membership indicators
			qui cap drop if `var' == .
			qui cap drop if `var' == ""
			}
	
		* Bar labels
	
		if "`barlab'" != "" {
			local blabplot (scatter `scatter', mlabel(mean) msymbol(none) mlabc(black) mlabs(1.8) mlabp(3))
			}
			
	* Variable sort
	
		if "`ascending'" != ""{
			local sort ""
			local sortLogic `"`ascending'"'
			}
			
		if "`descending'" != ""{
			local sort "-"
			local sortLogic `"`descending'"'
			}
		
	* Separate into variable lists
		
		local x = 1
		while strpos("`anything'",")") > 0 {
			local vargroup_`x' = substr("`anything'",1,strpos("`anything'",")")-1) 	// Take out group of variables up to close-parenthesis
				local vargroup_`x' = subinstr("`vargroup_`x''","(","",1) 			// Remove open-parenthesis.
				unab vargroup_`x' : `vargroup_`x''									// Expand variable names if needed.
								
			local anything    = substr("`anything'",strpos("`anything'",")")+1,.) 	// Replace remaining list with everything after close-parenthesis
			local ++x
			}
			
		if `x' == 1 {
			local varlist `anything'
			}
		else {
			forvalues i = 1/`x' {
				local varlist `varlist' `vargroup_`i'' // Compile full variable list.
				}
			}
			
		local n_vargroups = `x'
	
* Collapse and reshape so that each bar has an observation. This means one observation will correspond to one variable for one over-group.

	local x = 1
	foreach var of varlist `varlist' {
		local varname_`x' `var'
		local varlab_`x' : var label `var'
		rename `var' var_`x'
		local ++x
		}
		
	tempfile all
		qui save `all', replace
		
	gen _no = 1
	
	if "`weight'" != "" local theWeight "[`weight' `exp']"

	collapse (`stat') var_* (sum) _no `theWeight', fast by(`over' `by')
		qui reshape long var_, j(varid) i(`over' `by')
		rename var_ mean
		
		qui count
		qui gen varname = ""
		qui gen varlabel = ""
		
		forvalues i = 1/`r(N)' {
			local var = varid[`i']
			qui replace varname = "`varname_`var''" in `i'
			qui replace varlabel = "`varlab_`var''" in `i'
			}
	
		tempfile means
			qui save `means', replace
			
	* Standard errors and CIs
			
		use `all', clear
		
		collapse (`serrstat') var_* , fast by(`over' `by')
	
			qui reshape long var_, j(varid) i(`over' `by')
			rename var_ sem
			
		qui merge 1:1 varid `over' `by' using `means', nogen
		
		qui gen upper = mean + 1.96*sem
		qui gen lower = mean - 1.96*sem
		
		if "`dropzero'" != "" drop if mean == .
		if "`dropzero'" != "" drop if mean == 0
			
* Sort over, by, and variable groups and set up for ordering


	qui egen overgroup = group(`over')
		foreach var of varlist `over' {
			decode `var', gen(_over_`var')
			local theOverVars = `"`theOverVars' `overplus' _over_`var'"'
			local overplus `"+ ", " +"'
			}
			
		qui gen over = `theOverVars'
		
	qui egen bygroup = group(`by')
		foreach var of varlist `by' {
			decode `var', gen(_by_`var')
			local theByVars = `"`theByVars' `byplus' _by_`var'"'
			local byplus `"+ ", " +"'
			}
			
		qui gen by = `theByVars'
		
		gen byvarlab = by + ": " + varlabel
		if "`varlab'" != "" replace byvarlab = by
		replace byvarlab = regexr(byvarlab,"Placeholder: ","")
		
	qui gen vargroup = 1
		
	if `n_vargroups' > 1 {
		forvalues i = 1/`n_vargroups' {
			foreach varname in `vargroup_`i'' {
				qui replace vargroup = `i' if regexm("`vargroup_`i''",varname)
				}
			}
		}
	
* Ascending/descending sort	
	
	if "`ascending'" != "" | "`descending'" != "" {
		local theSortMean "sortmean" 
		qui gen sortmean = `sort'mean if `sortLogic'
		bys vargroup varid: egen _tempmean = mean(sortmean)
			qui drop sortmean
			rename _tempmean sortmean
		}
		
		qui sort bygroup vargroup `theSortMean' varid overgroup  
		gen varorder = _n
		
* Ordering
	
	qui count
	
	qui gen x = 1
	local theLastVarGroup = vargroup[1]
	local theLastVarID = varid[1]
	local theLastGroup = bygroup[1]
	
	local x = 1
	
	forvalues i = 2/`r(N)' {
		
		gen meantest = (mean == .)
		local skipSlot = meantest[`i']
		qui drop meantest
	
		if !`skipSlot' local ++x
	
		local theVarGroup = vargroup[`i']
		local theVarID = varid[`i']
		local theGroup = bygroup[`i']
		
		if `theVarGroup' != `theLastVarGroup' {
			local ++x
			}
		if `theVarID' != `theLastVarID' {
			local ++x
			}
		if `theGroup' != `theLastGroup' {
			local ++x
			}

		qui replace x = `x' in `i'
		
		local theLastVarGroup = `theVarGroup'
		local theLastVarID = `theVarID'
		local theLastGroup = `theGroup'
		
		}
		
	qui sum x
		if "`vertical'" == "" qui replace x = `r(max)' - x
		replace x = x / `r(max)'
		local width = 1/`r(max)'
	
	if "`bycolor'" == "" egen group = group(bygroup overgroup)
		else 			  gen group = overgroup
	qui separate x, by(group)
		qui sum group
		local n_groups = `r(max)'
		
	forvalues i = 1/`n_groups' {
	
		if regexm(`"`barlook'"',`"`i' "') {
		
			local k = strpos("`barlook'","`i' ")+2 
			local j = `i' + 1
			local j = strpos("`barlook'","`j' ") - `k' +2
			if `j' <= 0 local j "."
			
	
			local theoptions = substr("`barlook'",`k',`j'-3)
						
			}
	
		local meanplots `meanplots' (bar mean x`i', `horizontal' `theoptions' barwidth(`width'))
		}

* Prepare graph labels (varlabels + by-groups)
	
	encode byvarlab, gen(chartlabels)
	
	qui sum chartlabels
		local numlabels = `r(max)'
	
	forvalues i = 1/`numlabels' {
		qui sum x if chartlabels == `i'
		local theXMean = `r(mean)' + (`width'/20)*sqrt(`numlabels')
		
		local theVarLabel : label (chartlabels) `i'
		
		if "`bylabel'" != "" {
			local theVarLabel = substr("`theVarLabel'",strpos("`theVarLabel'",": ")+1,.)
			}
		
		local theXLabels `" `theXLabels' `theXMean' "`theVarLabel'" "'
		}

		
* PRepare legend labels (over-groups)
		
	encode over, gen(legendlabels)
		
	qui sum group
	if `r(max)' > 1 {
		forvalues i = 1/`r(max)'{
			
			qui sum legendlabels if group == `i'
				local labval = `r(mean)'
			local theLegendLabel : label (legendlabels) `labval'
				
			tempfile a
			qui save `a', replace
				qui keep if varid == 1
				collapse (sum) _no , by(group) fast
				qui sum _no if group == `i'
				if "`n'" == "n" {
					local legendN "(N=`r(mean)')"
					}
			use `a', clear
			
			local theLegendOrder `"`theLegendOrder' `i' "`theLegendLabel' `legendN'" "'
			}
		}
	else {
		local theLegendOff off
		}
		
	if "`over'" == "_over" local theLegendOff off
		
	format mean %9.2f
	gen zero = 0 

* Print using datasheet if using is specified
	
	if `"`using'"' != `""' {
	
		if "`over'" != "_over" local overstats `over'
		if "`by'" != "_by" local by `by'
		
		gen val2 = string(round(mean,0.01))
		
		label var sem "Standard Error"
		label var varname "Varname"
		label var varlabel "Variable"
		label var val2 "Mean Value"
		cap label var upper "Upper Bound"
		cap label var lower "Lower Bound"
		
		export excel varname varlabel `by' `over' val2 sem upper lower `using', first(varl) replace
		}
	
* Graph

	if "`barplot'" != "" {
	tw `addplot' `seplot' `blabplot' (scatter `axisfix', ms(i)) , `labelaxis'lab(`theXLabels', angle(0) nogrid notick labs(`labsize')) yscale(noline) xscale(noline) ///
		`addStats' `valueaxis'lab(, angle(0) nogrid) `labelaxis'tit(" ") `valueaxis'tit(" ") legend(pos(6) `theLegendOff' order(`theLegendOrder') region(lc(white)) ) ///
		graphregion(color(white)) ///
		`options'
	}
	else {
	tw `meanplots' `addplot' `seplot' `blabplot' (scatter `axisfix', ms(i)) , `labelaxis'lab(`theXLabels', angle(0) nogrid notick labs(`labsize')) yscale(noline) xscale(noline) ///
		`addStats' `valueaxis'lab(, angle(0) nogrid) `labelaxis'tit(" ") `valueaxis'tit(" ") legend(pos(6) `theLegendOff' order(`theLegendOrder') region(lc(white)) ) ///
		graphregion(color(white)) ///
		`options'	
	}
	
* End

end
