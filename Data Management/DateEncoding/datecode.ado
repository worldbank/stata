** Labels for time

cap prog drop datecode
prog def datecode

syntax anything , [format(string asis)]

foreach var of varlist `anything' {
	qui su `var' 
		local theMin = `r(min)'
		local theMax = `r(max)'
	if "`format'" == "" local format : format `var'
	
	local theLabels ""
	forvalues level = `theMin'/`theMax' {
		local theNext = string(`level',"`format'")
		local theLabels `"`theLabels' `level' "`theNext'""'
		}
		
	gen `var'_lab = `var'
		label def `var'_lab `theLabels'
		label val `var'_lab `var'_lab
		
	}
	
end
	
