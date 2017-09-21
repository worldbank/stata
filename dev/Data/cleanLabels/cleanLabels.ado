
* Clean out commas from labels

cap prog drop cleanLabels
prog def cleanLabels

syntax anything // input the cleaning variable list

unab theVars : `anything'

preserve
clear

tempfile theCommands
	save `theCommands' , replace emptyok
	
restore


qui foreach var in `theVars' {
	cap label save `var' using "test.xls" ,replace
		if _rc==0 {
			preserve
			import delimited using "test.xls" , clear delimit(", modify", asstring) 
			append using `theCommands'
				save `theCommands' , replace
			restore
		}
	}
	
preserve
	use `theCommands' , clear
		replace v1 = subinstr(v1,",","",.)
		
	qui count
		forvalues i = 1/`r(N)' {
			local theNextMod = v1[`i']
			local theMods `" `theMods' `"`theNextMod' , modify"' "'
			}
restore
			
	local nMods : word count `theMods'
		forvalues i = 1/`nMods' {
			local theNextMod : word `i' of `theMods'
			`theNextMod'
			}
			
end

* demo

use "$immediatedata/allstates.dta" , clear
cleanLabels school_dist*

* Have a lovely day!
