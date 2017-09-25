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

	keep stat var logic value

	drop if logic == ""
	
* Do the calculatons...

	qui count
	qui forvalues i = 1/`r(N)' {
	
		local theLogic = logic[`i']
		local theVar = var[`i']
		local theStat = stat[`i']
			local theStat = "\`r(`theStat')'"
	
		tempfile a
			qui save `a', replace
		
		use `theData', clear
		qui su `theVar' if `theLogic' , d
		local theValue = `theStat'
		
		use `a', clear
		
		qui replace value = `theValue' in `i'
		
		}
		
		
	mkmat value , mat(theResults)
		
	putexcel D2 = matrix(theResults) `using', modify
	
	use `theData', clear
	
end
	
/* Demo

sysuse auto, clear
flowchart using "flowChart.xlsx"

* Have a lovely day!
