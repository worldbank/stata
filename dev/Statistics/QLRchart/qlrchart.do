* Quandt Likelihood Ratio Graph

cap prog drop qlrchart
prog def qlrchart
	
	syntax anything ///
		[if] [in] , ///
		range(string asis) /// typical numlist 
		[regopts(string asis)] /// regression options
		[*] // graph tw options
		
* If/in setup

	cap mat drop theResults

	preserve
	
		marksample touse
	
		keep if `touse'
		
* Detect breakpoint var

	local breakvar : word 3 of `anything'
		
* Test all points in numlist
		
	tempvar breakpoint
	
	qui foreach value of numlist `range' {
		
		cap drop `breakpoint'
			gen `breakpoint' = `breakvar' > `value'
			
			sum `breakpoint'
			
			xi i.`breakpoint'*`breakvar'
			
			local theInteraction : word 2 of `_dta[__xi__Vars__To__Drop__]'
			
			qui `anything' `_dta[__xi__Vars__To__Drop__]' , `regopts'
			
			test `_dta[__xi__Vars__To__Drop__]'
			
			mat theResults = nullmat(theResults) \ [`value',`r(F)']
		
		}
		
	matlist theResults
		
	end


* Testing

	use "$directory/constructed/analysis_aidtrust.dta", clear

	qlrchart ///
		areg ///
		indiv_trust_note_h ///
		hh_faultdist ///
		indiv_edu_primary hh_wealth_2 hh_wealth_1 indiv_male hh_epidist hh_slope  ///
		if touse_trust == 1  ///
	, regopts(a(indiv_age)) range(20(2)40)

* Have a lovely day!
