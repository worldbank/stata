** Creates single indicators from multiple-visit data based on completion binary.

cap prog drop visitstat
prog def visitstat

syntax anything using/ , Attempts(integer)

qui foreach stub in `anything' {

	local theLabel : var label `stub'1
	local theLabel = subinstr("`theLabel'","1 ","",.)
	
	cap local theValLab : value label `stub'1
	
	local theName = regexr("`stub'","_$","")
	
	gen `theName' = ""
		label var `theName' "`theLabel'"
		
		forvalues i = 1/`attempts' {
		
			cap replace `theName' = `stub'`i' 			if `using'`i' == 1
			cap replace `theName' = string(`stub'`i') 	if `using'`i' == 1
			
			}
			
		cap destring `theName', replace
		cap label val `theName' `theValLab'
	
	}

end
	
	
	
