** Creates binaries from wide-format categoricals

cap prog drop anycat
prog def anycat

syntax anything , [shortlabel]

cap label def catyes 0 "No" 1 "Yes"

foreach stub in `anything' {
	
		local thelabel: val label `stub'1 
		local thevarlab: var label `stub'1 
		local thevarlab = subinstr("`thevarlab'","1 ","",.)
		preserve
		uselabel `thelabel', clear
			qui count
			local theValues ""
			local theLabels ""
			forvalues i = 1/`r(N)' {
				local nextValue = value[`i']
				local nextLabel = label[`i']
				local theValues "`theValues' `nextValue'"
				local theLabels `"`theLabels' "`nextLabel'" "'
				}
				
		restore
			
		local nLabels : word count `theValues'
		
		forvalues i = 1/`nLabels' {
		
			local value : word `i' of `theValues'
			local label : word `i' of `theLabels'
			local label = ltrim(rtrim(itrim("`label'")))
		
			gen `stub'any_`value' = 0
				if "`shortlabel'" == "" label var `stub'any_`value' "`label'"
					else label var `stub'any_`value' "`label'"
				label val `stub'any_`value' catyes
			foreach var of varlist `stub'*  {	
				qui replace `stub'any_`value' = 1 if `var' == `value'
				}
				
			label def `stub'any_`value' 0 "No" 1 "`label'"
				label val `stub'any_`value' `stub'any_`value'
					
		}
	}
	
end
