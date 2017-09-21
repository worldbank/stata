** Converts variable lists to proper case.

cap prog drop strprop
prog def strprop

syntax varlist, Case(string asis) [Names] [Strip(string asis)]

qui foreach var of varlist `varlist' {

	local theType : type `var'
	if regexm("`theType'","str") {
	
	forvalues x = 1/10 {
	
		if `"`strip'"' != `""' {
			replace `var' = regexr(`var',"[\[\\]\\^\%\.\|\?\*\+\(\)]","")

			foreach character in `strip' {
				replace `var' = regexr(`var',"[`character']","")
				}
			}
	
		replace `var' = `case'(`var')
		}
				
		}
		
	if "`names'" == "names" {
		local theNewName = lower("`var'")
		rename `var' `theNewName'
		}
	}

end
