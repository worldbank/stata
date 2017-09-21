** Tabulates lagged data

cap prog drop lagtab
prog def lagtab

syntax varlist [using] [if] [in] , [LABel(string asis)] [Lags(integer 1)] [id(varlist)] [Time(varlist)] [*]

preserve
marksample touse, novarlist
keep if `touse'

* tsset if needed

if "`id'" != "" & "`time'" != "" {
	tempvar idvar timevar
	egen `idvar' = group(`id')
	egen `timevar' = group(`time')
	qui duplicates drop `idvar' `timevar', force
	tsset `idvar' `timevar'
	}

* Do the tabs

forvalues i = 1/`lags' {

	foreach var of varlist `varlist' {
	
	
		* Label option
		
			local visit = `i'+1
	
			if "`label'" != "" {
				label var `var' "`label' 1"
				local varlabel "`label' `visit'"
				}
			else {
				local varlabel "T+`i'"
				}
	
		gen F`i'_`var' = F`i'.`var'
			local thelabel : val lab `var'
			label val F`i'_`var' `thelabel'
			label var F`i'_`var' "`varlabel'"
		ta F`i'_`var' `var', `options'
		}
		
	}
	
end
