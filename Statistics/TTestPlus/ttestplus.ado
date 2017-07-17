cap prog drop ttestplus
program define ttestplus
version 11.0

syntax varlist [if] [in] [using/], 	/// Using writes to excel. Requires xml_tab.
	by(varlist) 					/// Specify grouping variable, or, alternatively, two binary indicators.
	[Pvalues] 						/// Write p-values instead of t-stats.
	[Difference]					/// Differences
	[cut(string)] 					/// Specify where to cut the by-var if it is not already in two categories.
	[Round(real 0.01)]				/// Specify rounding of outputs.
	[se]							/// Displays standard errors.
	[n]								/// Display N at end of table.
	[*]								/// Other options for writing output.
	
preserve
marksample touse, novarlist
keep if `touse'

* Standard errors

	if "`se'" == "se" {
		local serow = "\ b2 \`b3_2' , [.]"
		local serowname = `" "." "'
		local serowformat = "NCRI2"
		local sername = `" " " "'
		}
	
* Convert cut to numerical if appropriates

	if regexm("`cut'", "[0-9]+") {
		local cutpoint = `cut'
		}
		
* Quit if bad cut syntax

	if "`cut'"!="mean" & "`cut'"!="median" & !regexm("`cut'", "[0-9]+") & "`cut'"!="" {
		di in red "Specify cut(value), cut(mean), or cut(median) only"
		exit 198
		}
	
* Cut groupvar if specified

	if "`cut'"=="mean" | "`cut'"=="median" | regexm("`cut'", "[0-9]+") {
		
		qui sum `by', d
			if "`cut'"=="median" {
				local cutpoint = `r(p50)'
				}
			if "`cut'"=="mean" {
				local cutpoint = `r(mean)'
				}
			local cutmin = `r(min)' - 1
			local cutmax = `r(max)' + 1
			tempvar btemp
				egen `btemp' = cut(`by'), at(`cutmin',`cutpoint',`cutmax')
			local bytemp = "`by'"
			local by = "`btemp'"
		
		}
		
		
* Prep varlist

	tokenize `varlist'
	
	local n_vars : word count `varlist'
	
* Run t-tests and add to results matrix

	cap mat drop results

	forvalues i = 1/`n_vars' {
	
		local theLabel : var label ``i''

		qui ttest ``i'' , by(`by')
		
		if "`pvalues'"=="pvalues" { 
			local p = round(min( r(p_u), r(p_l), r(p) ),`round')
			local stat = "`p'"
			}
		else { 
			local stat = "r(t)"
			}
		
		mat b1 = round(r(mu_1),`round'),round(r(mu_2),`round')
		mat b2 = round(`r(sd_1)'/sqrt(`r(N_1)'),`round'),round(`r(sd_2)'/sqrt(`r(N_2)'),`round')
		
		if "`difference'" == "difference" {
			mat b3 = round(`r(mu_2)' - `r(mu_1)',`round')
			local b3 ", b3"
			local b3_2 ", [.]"
			local b3_l `" "Difference" "'
			}
		
		mat results= nullmat(results) \ b1 `b3' , round(`stat',`round') `serow'

		local rnames `" `rnames' "`theLabel'" `sername' "'
		local rownames `" `rownames' "``i''" `serowname' "'
		
		}
			
* Output

	if "`pvalues'"=="pvalues" { 
		mat colnames results = "Group 1" "Group 2" `b3_l' "p-Statistic"
		}
	else { 
		mat colnames results = "Group 1" "Group 2" `b3_l' "t-Statistic"
		}
	
	di " "
	if "`cut'"!="" {
		if regexm("`cut'", "[0-9]+") {
			local cut = "specified"
			}
		di "`bytemp' cut at `cutpoint' (`cut')"
		}
	else {
		qui levelsof `by', local(levels)
		foreach level in `levels' {
			local theLevel : label (`by') `level'
			local cnames `" `cnames' "`theLevel'" "'
			}
		if "`pvalues'"=="pvalues" { 
			mat colnames results = `cnames' `b3_l' "p-Statistic"
			}
		else { 
			mat colnames results = `cnames' `b3_l' "t-Statistic"
			}
		}
		
* N

	qui if "`n'" == "n" {
		sum `by'
			local min = `r(min)'
			local max = `r(max)'
	
		count if `by' == `min'
			local n1 = `r(N)'
		count if `by' == `max'
			local n2 = `r(N)'
			
		mat results = results \ `n1' , `n2' , [.] `b3_2'
		
		local n N
		}
		
* Display
		
	mat rownames results = `rownames' `n'

		
	matlist results
	
	mat results_STARS = J(rowsof(results),colsof(results),0)
	
if "`using'" != "" {
		
	xml_tab results using "`using'", format((SCLB0) (SCCB0 NCRR2 `serowformat')) rnames(`rnames' `n') stars(0) `options'
	
	}
	
end
