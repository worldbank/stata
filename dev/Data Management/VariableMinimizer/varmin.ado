* Readme

cap prog drop varmin
prog def varmin

	syntax anything
	
* Setup
	
	unab theVarlist : *
	
preserve

clear

	tempfile a
		save `a' , replace emptyok
		
* Make a master file

qui {

	foreach file in `anything' {

		import delimited "`file'" , clear delim("§")
		
		append using `a'
		
		tempfile a
			save `a' , replace
		
		}
		
	local x = 1
	foreach item in `theVarlist' {
	
		local ++x
		
		gen v`x' = "`item'" if strpos(v1,"`item'")
		
		}
		
	collapse (firstnm) v* , fast
	
	gen n = 1
	
	reshape long v , i(n)
	
	keep v
	
	drop if v == ""
	
	drop in 1
	
	count 
	
		forvalues i = 1/`r(N)' {
		
			local theNextVar = v[`i']
		
			local theKeepList = "`theKeepList' `theNextVar'"
			
			}
			
restore

} // end qui

	keep `theKeepList'
	
end


* Have a lovely day!
