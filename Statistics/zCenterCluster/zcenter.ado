** Implements rapid clustering algorithm

cap prog drop zcenter
prog def zcenter
	syntax [if] [in], id(varname) x(varname) y(varname) MAXdistance(string asis) gen(string asis) [latlon] [seed(integer 47)] [center(string asis)] [append]
	
	tempvar n
		gen `n' = 1
		
* Setup for append

	* if "`append'" != "" rename `gen' `gen'_temp
	
* Set first center arbitrarily
	
	marksample touse
	preserve
	keep if `touse'
	

	cap gen `center' = 0
	keep `center' `x' `y' `id' `n'
	  
	tempfile a
		save `a'
		
	set seed `seed'
	
	tempvar temp
		gen `temp' = runiform()
		sort `temp'
	
	* Initialize cluster-center dataset	     
	
		drop `temp'
		
		if "`append'" == "" keep in 1
		if "`append'" != "" keep if `center' == 1 
			cap drop `center'
			tempfile centers
			save `centers'
			
* Test distance to nearest center; begin loop.

	tempvar distance
	local quit = 0
	local i = 1

	qui while `quit' == 0 {

		rename * *_c
				
		joinby `n' using `a'
		cap drop `center'
		
		if "`latlon'" == "latlon" {
			vincenty `y' `x' `y'_c `x'_c, hav(`distance') inkm
			}
		else {
			gen `distance' = sqrt( (`y' - `y'_c )*(`y' - `y'_c ) + (`x' - `x'_c )*(`x' - `x'_c ) )
			}
			
		sort `id' `distance'
		bys `id': keep if _n == 1
		qui sum `distance'
		
		if `r(max)' > `maxdistance' {
			
			sort `distance'
			
			keep in `r(N)'
			
			keep `x' `y' `id' `n'
			append using `centers'
			save `centers', replace
			
			}
		else {
			local quit = 1
			}
			
		}

		keep `x' `y' `id' `n' `id'_c `distance'
		

* For each observation, keep the pairing to the nearest center.
		
	sort `id' `distance'
	bys `id': keep if _n == 1
	
	egen `temp' = rank(`id'_c), field
		tostring `temp', replace
		encode `temp', gen(`gen')
		label drop `gen'
			label var `gen' "Cluster ID"
	
	if "`center'" != "" {
		gen `center' = (`distance' == 0)
			label var `center' "Center Indicator"
		}
		
	drop if `x' == . | `y' == .
	
	keep `id' `gen' `center'
	
	save `a', replace
	
	restore
	
	merge 1:1 `id' using `a', nogen update replace
	
	if "`append'" != "" {
		* sort  `gen'_temp `gen'
		* bys `gen': egen `gen'_final = mode(`gen'_temp)
		* gen `gen'_final = `gen'_temp
		}
	
end
