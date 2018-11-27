*! version 1.0 09212011 – Benjamin Daniels – bbdaniels@gmail.com

cap prog drop forest
prog def forest

syntax anything =/exp /// syntax – forest reg d1 d2 d3 = treatment
	[if] [in]  ///
	, [*] /// regression options
	 [or] /// odds-ratios
	 [d]  /// cohen's d
	 [Controls(varlist fv ts)] ///
	 [GRAPHopts(string asis)] ///
	 [WEIGHTs(string asis)] ///


preserve
marksample touse, novarlist
keep if `touse'
qui {
	// Set up

		if "`weights'" != "" {
			local weight "[`weights']"
		}

		tempvar dv

		if "`d'" == "d" local std "Standardized "

		if "`or'" == "or" {
			local l0 : label (`exp') 0
			local l1 : label (`exp') 1
		}
		else {
		    local tlab : var label `exp'
		}

	// Set up depvars
	tokenize `anything'
		local cmd = "`1'"
		mac shift

	// Loop over depvars
	cap mat drop results
	local x = 1
	qui while "`1'" != "" {
		di "`1'"

		// Get label
		local theLabel : var lab `1'
		local theLabels = `"`theLabels' `x' "`theLabel'""'

		// Standardize if d option
		if "`d'" == "d" {
			cap drop `dv'
			egen `dv' = std(`1')
			local 1 = "`dv'"
		}

		// Regression
		`cmd' `1' `exp' `controls' `weight', `options' `or'
			mat a = r(table)'
			mat a = a[1,....]
			mat results = nullmat(results) ///
				\ a , `x'

	local ++x
	mac shift
	}

// Graph
clear
svmat results , n(col)

	// Setup
	if "`or'" == "or" {
		local log `"xline(1,lc(black) lw(thin)) xscale(log) xlab(.01 "1/100" .1 `""1/10" "{&larr} Favors `l0'""' 1 "1" 10 `""10" "Favors `l1'{&rarr}""' 100 "100")"'
		gen x1=100
		gen x2=1/100
	}
	else {
		local log `"xtit({&larr} `std'Effect of `tlab' {&rarr}) xline(0,lc(black) lw(thin))"'
		gen x1=0
		gen x2=0
	}

		gen y1 = 0
		gen y2 = `x'

	// Graph
	tw ///
		(scatter y1 x1 , m(none)) ///
		(scatter y2 x2 , m(none)) ///
		(rcap  ll ul c10 , horizontal lc(black)) ///
		(scatter c10 b , mc(black)) ///
		, `graphopts' `log' yscale(reverse) ylab(`theLabels',angle(0) notick nogrid) ytit(" ") legend(off)

}
end
