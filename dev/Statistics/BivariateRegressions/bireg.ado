* bireg


cap prog drop bireg
	prog def bireg
	
	syntax anything using , regopts(string asis) [controls(string asis)] [*]
	
qui {
	
	foreach mat in biresults biresults_STARS regresults regresults_STARS allresults allresults_STARS {
	
		cap mat drop `mat'
		
		}
	
	local depvar : word 1 of `anything'
	local anything = subinstr("`anything'","`depvar'","",1)
		unab anything : `anything'
	
	
	* Binaries 
	
		qui foreach var of varlist `anything' {
			reg `depvar' `var' `controls', `regopts'
			
			local b = _b[`var']
			local se = _se[`var']
			
			mat biresults = nullmat(biresults) \ [`b',`se']
			
			test `var'
				local stars = 0
				if r(p) < 0.1 local stars = 3
				if r(p) < 0.05 local stars = 2
				if r(p) < 0.01 local stars = 1
				
			mat biresults_STARS = nullmat(biresults_STARS) \ [`stars',9]
			
			local theLabel : var label `var'
			local theLabels = `"`theLabels' "`theLabel'""'
			
			}
			
		
		local theLabels = `"`theLabels' "Constant" "N""'
		mat biresults = nullmat(biresults) \ [.,.] \ [.,.] 
		mat biresults_STARS = nullmat(biresults_STARS) \ [9,9] \ [9,9]
		
		mat rownames biresults = `theLabels'
		matlist biresults
		
	* Regression Results

		reg `depvar' `anything' `controls', `regopts'
		
		count if e(sample)
		local n = `r(N)'
		
		qui foreach var of varlist `anything' {
			
			if _b[`var'] != 0 local b = _b[`var']
				if _b[`var'] == 0 local b = .
			if _se[`var'] != 0 local se = _se[`var']
				if _se[`var'] == 0 local se = .
			
			test `var'
				local stars = 0
				if r(p) < 0.1 local stars = 3
				if r(p) < 0.05 local stars = 2
				if r(p) < 0.01 local stars = 1
				
			mat regresults_STARS = nullmat(regresults_STARS) \ [`stars',9]
			
			mat regresults = nullmat(regresults) \ [`b',`se']
			}
			
		local b = _b[_cons]
			local se = _se[_cons]
			
			test _cons
				local stars = 0
				if r(p) < 0.1 local stars = 3
				if r(p) < 0.05 local stars = 2
				if r(p) < 0.01 local stars = 1
			
		mat regresults = nullmat(regresults) \ [`b',`se'] \ [`n',.]
		mat regresults_STARS = nullmat(regresults_STARS) \ [`stars',9] \ [0,9]
		
		mat allresults = biresults , regresults
		mat allresults_STARS = biresults_STARS , regresults_STARS

		
}
		
		xml_tab allresults `using' , cnames("Estimate" "SE" "Estimate" "SE") showeq ceq("Bivariate Correlations" "Bivariate Correlations" "Multivariate Regression" "Multivariate Regression") ///
			`options'
		
	end


* Have a lovely day!do "/Users/bbdaniels/Desktop/bireg.do"
