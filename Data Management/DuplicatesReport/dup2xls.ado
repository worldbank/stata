** Lists differences within a file across sets of repeated observations or double entries.

cap prog drop dup2xls
prog def dup2xls

syntax [anything] using, id(string asis) names(string asis) [String]

if "`anything'" != "" {
	use `anything', clear
	}

preserve

tempfile a

* Identify duplicate observations.

	tempname duptag

	qui duplicates tag `id', gen(`duptag')

	qui keep if `duptag' == 1
	
qui count

if `r(N)' == 0 {
	di in red "No duplicates detected."
	}
else qui {
	
* Identify groups with binary indicators.

	tempvar dupgroup

	egen `dupgroup' = group(`id')
	
	levelsof `dupgroup', local(groups)
	
* Loop over sets and record all variables that differ within sets.

	foreach group in `groups' {
		
		save `a', replace
		
		local diflist ""
		
		keep if `dupgroup' == `group'
		
		foreach var of varlist * {
		
			local theType : type `var'
			
			if !regexm("`theType'","str") {
			
				local n = _N
			
				qui sum `var' if `dupgroup' == `group'
				
				if `r(N)' != 0 {
				
					if (`r(max)' != `r(min)') | (`r(N)' != `n') {
						
							local diflist `diflist' `var'
						
						}
						
					}
					
				}
					
			else if "`string'" != "" {
			
					local diflist `diflist' `var'
				
				}
				
			}
			
			keep `id' `names' `diflist'
			tempfile group_`group'
			save `group_`group'', replace
			
			use `a', clear
			
		}
				
* Build results dataset.

	clear

	foreach group in `groups' {
		append using `group_`group''
		}

	sort `id'
	order *, seq
	order `id' `names'
	export excel * `using', first(var) replace
}
	
end




