** Tab-gen with proper labelling

cap prog drop tabgen
prog def tabgen

syntax varlist

	cap label def yesnobin 0 "No" 1 "Yes"

	foreach var of varlist `varlist' {
		
		qui levelsof `var' , local(levels)
		
		foreach level in `levels' {
			gen `var'_`level' = (`var' == `level')
			local theLabel : label (`var') `level'
						
			label var `var'_`level' "`theLabel'"
			
			label val `var'_`level' yesnobin
			
			local theList = "`theList' `var'_`level'"
			}
				
		}
		
	codebook `theList' , compact
		
end
