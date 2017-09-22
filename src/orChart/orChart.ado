* Regression coefficient chart/table

cap prog drop orChart
prog def orChart

syntax varlist [if] [in] [using] [pweight], Command(string asis) rhs(string asis) [regopts(string asis)] [globalif] [*] case0(string asis) case1(string asis)

preserve
marksample touse, novarlist
keep if `touse'

qui { // odds-ratio / logistic regressions: bounded by [1/100 , 100]

	if "`weight'" != "" local theWeight "[`weight' `exp']"

	local theVar : word 1 of `rhs'

	cap mat drop theResults

	foreach var of varlist `varlist' {
	
	tempfile allData
	save `allData', replace
		if "`globalif'" != "" keep if 1 $`var'

			local theLabel : var label `var'
			local theLabels =  `"`theLabels' "`theLabel'" "'

			`command' `var' `rhs' `theWeight', or `regopts'
			
			mat mattemp = r(table)
			mat nextResults = mattemp[1...,1]
			
				count if `var' == 1
					local y = `r(N)'
				count
					local n = `r(N)'
				sum `var'
					local x = `r(mean)'
					
				count if `var' == 1 & `theVar' == 0
					local y0 = `r(N)'
				count if `theVar' == 0
					local n0 = `r(N)'
				sum `var' if `theVar' == 0
					local x0 = `r(mean)'
					
				count if `var' == 1 & `theVar' == 1
					local y1 = `r(N)'
				count if `theVar' == 1
					local n1 = `r(N)'
				sum `var' if `theVar' == 1
					local x1 = `r(mean)'
					
				mat nextResults = nextResults \ [ `y' , `n' , `x' , `y0' , `n0' , `x0' , `y1' , `n1' , `x1' ]' 

			mat theResults = nullmat(theResults) , nextResults	
	use `allData', clear		
		}
		
		mat theResults = theResults 
		mat theResult = theResults'
			
		clear
		svmat double theResult, n(matcol)
			
		gen b2 = string(round(theResultb,.01))

				replace b2 = b2 + "*" if theResultpvalue < 0.1
				replace b2 = b2 + "*" if theResultpvalue < 0.05
				replace b2 = b2 + "*" if theResultpvalue < 0.01

			replace b2 = "0" + b2 if theResultb < 1 & theResultb > 0

		
		gen ll2 = string(round(theResultll,.01)) 
			replace ll2 = "0" + ll2 if theResultll < 1
			replace ll2 = "[ " +  ll2 + " ," 
		
		gen ul2 = string(round(theResultul,.01)) 
			replace ul2 = "0" + ul2 if theResultul < 1
			replace ul2 = ul2 + " ]"

		gen m2 = string(round(theResultpvalue,.0001))
			replace m2 = "0" + m2 if theResultpvalue < 1
			replace m2 = "<0.0001" if m2 == "00"
			rename ///
				(theResultr10 theResultr11 theResultr12 theResultr13 theResultr14 theResultr15 theResultr16 theResultr17 theResultr18) ///
				(y N x y0 N0 x0 y1 N1 x1)
			
		gen n = _n
		
		qui count
		
			local n1 = `r(N)' + 1
			local n2 = `r(N)' + 2
		set obs `n2'
			replace n = `n1' in `n1'
			replace n = 0 in `n2'
			replace b2 = "Odds Ratio" in `n1'
			replace ll2 = "[95% Confidence]" in `n1'
			replace ul2 = " " in `n1'
			replace m2 = "P-value" in `n1'
			
		gen less 	= .01
		gen b 		= 200
		gen ll 		= 2000
		gen ul 		= 10000
		gen m		= 80000
		gen more 	= 800000
		
		replace n = `n2' - n - 1 if (n != 0 & n != `n1')
		
		gen label = ""
			forvalues i = 1/`r(N)' {
				local pos = `n2' - `i' - 1
				local next : word `i' of `theLabels'
				replace label = "`next'" if n == `pos'
				local labels `"`labels' `pos' "`next'""'
				}
		
		tw 	(rcap theResultll theResultul n, horizontal lc(black)) ///
			(scatter n theResultb , ms(o) mc(black)) ///
			(scatter n b, mlabel(b2) ms(none)  mlabc(black)) ///
			(scatter n ll, mlabel(ll2) ms(none)  mlabc(black)) ///
			(scatter n ul, mlabel(ul2) ms(none) mlabc(black)) ///
			(scatter n m, mlabel(m2) ms(none) mlabc(black)) ///
			(scatter n more,  ms(none)) ///
			(scatter n less,  ms(none)) ///
			, 	xscale(log) xlab(none) ylab(`labels', angle(0) nogrid notick) ///
				xlab(0.01 "0.01" 0.1 `""0.1" "{&larr} Favors `case0'""' 1 "1.0" 10 `""10" "Favors `case1' {&rarr}""' 100 "100", notick) ///
				xline(0.01, lc(black)) xline(1, lc(gray) lp(dash)) xline(10, lc(gray) lp(dot)) xline(0.1, lc(gray) lp(dot)) xline(100, lc(black)) ///
				yscale(noline) xscale(noline) ytit("") legend(off) graphregion(color(white)) bgcolor(white) caption(`"`pnote'"', pos(7) span size(small)) `options'
		
		* xlab(0.01 "1:100" 0.1 "1:10" 1 "1:1" 10 "10:1" 100 "100:1", notick)
		
		if `"`using'"' != `""' {
			keep theResult* label y N x y0 N0 x0 y1 N1 x1
			rename theResult* *
			
			label var y0 "`case0'"
			label var N0 "N"
			label var x0 "Proportion"
			label var y1 "`case1'"
			label var N1 "N"
			label var x1 "Proportion"
			label var b  "Odds Ratio"
			label var pvalue "P-Value"
			label var ll "95% Lower Bound"
			label var ul "95% Upper Bound"
			
			export excel label y0 N0 x0 y1 N1 x1 b ll ul pvalue `using' , replace first(varl)
			}
			
	} // end qui

end
