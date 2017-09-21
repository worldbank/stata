** Creates regression tables where every cell is the coefficient from the first independent-var.

cap prog drop regcell
prog def regcell

syntax anything [using] [if] [in], [se] [regopts(string asis)] [*]

preserve
marksample touse
keep if `touse'

* Separate into LHS and RHS variable lists
		
	local x = 0
	while strpos("`anything'",")") > 0 {
		local ++x
		local `x' = substr("`anything'",1,strpos("`anything'",")")-1) 	// Take out group of variables up to close-parenthesis
			local `x' = subinstr("``x''","(","",1) 			// Remove open-parenthesis.
							
		local anything    = substr("`anything'",strpos("`anything'",")")+1,.) 	// Replace remaining list with everything after close-parenthesis
		}
	
	local dep_variables "`1'"
		mac shift
		
	local n_models = `x' - 1
	local n_indepvars : word count `dep_variables'
	
	if "`se'" != "" local seblank `"".""'
	
* Do the regressions and build the matrix

	cap mat drop all_results

	mat all_results = J(`n_indepvars',`n_models',0)
		if "`se'" != "" mat all_results = all_results \ all_results // Double height if SE option
	mat all_results_STARS = J(rowsof(all_results),colsof(all_results),0) // stars matrix for xml_tab

	local i = 0
	
	foreach var of varlist `dep_variables' {
	
		local ++i
		local i_se = `i' + 1
		local theDepLabel : var label `var'
			local allDepLabels = `"`allDepLabels' "`theDepLabel'" `seblank'"'
	
		forvalues j = 1/`n_models' {
		
			qui xi: reg `var' ``j'' , `regopts'
			mat regdata = r(table)
			
				local b 		= regdata[1,1]
				local sem 		= regdata[2,1]
				local p_stat 	= regdata[4,1]
					local stars = 0
					if `p_stat' < 0.1  local stars = 3
					if `p_stat' < 0.05 local stars = 2
					if `p_stat' < 0.01 local stars = 1
					
				mat all_results[`i',`j'] = `b'
					if "`se'" != "" mat all_results[`i_se',`j'] = `sem'
				mat all_results_STARS[`i',`j'] = `stars'
					
			}
			
		if "`se'" != "" local ++i // Another row if SEs were added
			
		}

* Output

	mat rownames all_results = `allDepLabels'
	
	matlist all_results
		
	if `"`using'"' != `""' {
		xml_tab all_results `using' , `options' 
		}
	
end




