** Updates flowchart spreadsheet

cap prog drop flowchart
prog def flowchart

syntax using [if] [in]
marksample touse
preserve
keep if `touse'

version 13

tempfile theData
	save `theData', replace
	
cap mat drop theResults

* Load the flowchart spreadsheet
		
	import excel `using', first clear

	keep note logic value

	drop if logic == ""
	
* Do the calculatons...

	qui count
	qui forvalues i = 1/`r(N)' {
	
		local theLogic = logic[`i']
	
		tempfile a
			qui save `a', replace
		
		use `theData', clear
		qui count if `theLogic'
		local theValue = `r(N)'
		
		use `a', clear
		
		qui replace value = `theValue' in `i'
		
		}
		
		
	mkmat value , mat(theResults)
		
	putexcel C2 = matrix(theResults) `using', modify
	
	use `theData', clear
	
end
	
/* Demo

sysuse auto, clear
flowchart using ///
	"/Users/bbdaniels/Desktop/flowChart.xlsx"

* Have a lovely day!
