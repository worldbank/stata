** Updates flowchart spreadsheet
* I have made a fix!
cap prog drop flowchart
prog def flowchart

syntax using [if] [in]
marksample touse
preserve
keep if `touse'

tempfile theData
	save `theData', replace
	
cap mat drop theResults

* Load the flowchart spreadsheet
		
	import excel `using', first clear

	keep note logic value

	drop if logic == ""
	
* Do the calculatons...

	qui count
	forvalues i = 1/`r(N)' {
	
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
