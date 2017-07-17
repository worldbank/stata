

cap prog drop data_notes
prog def data_notes

syntax varlist

foreach var of varlist `varlist' {
	preserve
	qui import delimited using "https://www.qutubproject.org/s/statafile.txt" , clear delim(":")
	qui keep if trim(v1) == "`var'"
	qui local theText = v2 in 1
	di  "Notes for `var':"
	di  "`theText'"
	di  " "
	restore
	}
	
end

clear

set obs 100
gen var1 = _n
gen var2 = _N

data_notes *






