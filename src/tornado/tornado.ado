* Regression coefficient chart/table

cap prog drop tornado
prog def tornado

syntax anything =/exp /// syntax – tornado : reg d1 d2 d3 = treatment
	[if] [in] /// [pweight] ///
	, [*] ///
	 [or] /// odds-ratios
	 [d]  /// cohen's d
	 [controls(varlist)]

preserve
marksample touse, novarlist
keep if `touse'

	// Set up

		tempvar dv

	// Set up depvars
	tokenize `anything'
		local cmd = "`1'"
		mac shift

	// Loop over depvars
	cap mat drop results
	local x = 1
	while "`1'" != "" {
		di "`1'"

		// Get label
		local theLabel : var lab `1'
		local theLabels = `"`yLabels' `x' "`theLabel'""'

		// Standardize if d option
		if "`d'" == "d" {
			cap drop `dv'
			egen `dv' = std(`1')
			local 1 = "`dv'"
		}

		// Regression
		`cmd' `1' `exp' `controls' , `options' `or'
			mat a = r(table)'
			mat a = a[1,....]
			mat results = nullmat(results) ///
				\ a , `x'

	local ++x
	mac shift
	}

di `"`theLabels'"'

// Graph
	clear
	svmat results , n(col)
	pause on
	pause

	tw ///
		(scatter c10 b) ///
		(rcap c10 ll ul , h) ///
		, yscale(reverse)

end


sysuse auto, clear
tornado reg price mpg = trunk , d
