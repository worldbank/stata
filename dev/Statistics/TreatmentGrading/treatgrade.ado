** Outputs (and will eventually import) treatment grading files

cap prog drop treatgrade
prog def treatgrade

syntax using [if] [in], id(string asis) MEDstubs(string asis) [Updates(string asis)] Treatbins(varlist)

marksample touse, novarlist

* Export
qui {
	preserve
	keep if `touse'

	tempfile all
	save `all', replace

	* Treatments

		keep `id' `treatbins'
		local x = 1
		foreach var of varlist `treatbins' {
			local theLabel : var label `var'
			gen _treat_`x' = "`theLabel'" if `var' == 1
			local ++x
			}
		reshape long _treat_ , i(`id') j(treat)
			keep if _treat_ != ""
			keep `id' _treat_
			
		tempfile treatments
			save `treatments', replace
			
	* Medicines

		use `all', clear
		
		local theName : word 1 of `medstubs'
		
		* Get description labels
		foreach stub in `medstubs' {
			local label_`stub' : var label `stub'1
			local label_`stub' = regexr("`label_`stub''","1 ","")
			}
		
		reshape long `medstubs', i(`id') j(_med)
			keep `id' _med `medstubs'
			
			drop if `theName' == ""
			
		tempfile medicines
			save `medicines', replace
			
	* Append w/Blanks
	
		use `all', clear
		
		keep `id'
	
		append using `treatments', gen(source)
		append using `medicines', gen(source2)
		sort `id' source source2 _med
		
	* Formatting
	
		foreach var in varlist `id' {
	
		cap replace `var' = "" if source == 0
		cap replace `var' = . if source == 0
		
		local ifblank `" `ifblank' `ifand' `var' == ".z" "'
		local ifand "&"
		
		}
		
		replace _treat_ = `theName' if `theName' != ""
			label var _treat_ "Treatment Description"
			
		foreach stub in `medstubs' {
			if "`stub'" != "`theName'" {
				label var `stub' "`label_`stub''"
				cap replace `stub' = .z if `theName' == ""
				tostring `stub', replace
				cap replace `stub' = ".z" if `theName' == ""
				}
			}
			
		gen fill = ".z"
			label var fill "Fill -->"
		
		if "`updates'" != "" {
			foreach update in `updates' {
				gen `update'_update = " "
				replace `update'_update = ".z" if `theName' == ""
				label var `update'_update "Update `label_`update''"
				}
			}
			
		drop source source2 `theName'
		
		foreach var in _med _treat_ `id' {
			tostring `var', replace
			replace `var' = ".z" if `var' == "" | `var' == "."
			}
		label var _med "Med #"
		
	* Grading fields
	
		tempvar temp1 temp2 temp3
	
		gen `temp1' = _n
		tsset `temp1'
	
		gen `temp2' = (`ifblank')
			gen quality = l.`temp2'
			recode quality (1 = . )(*=.z)
			label var quality "Overall Treatment Quality"
			
			gen interactions = l.`temp2'
			recode interactions (1 = .)(*=.z)
			label var interactions "Any Harmful Interactions"
			
		gen med_quality = ".z" if _med == ".z"
			label var med_quality "Medicine Quality"
			
			tostring quality interactions, replace
				replace quality = "" if quality == "."
				replace interactions = "" if interactions == "."
			
		drop `temp1' `temp2'
		
	* Write	
}
		export excel `using', first(varl) replace sheet("Treatments")

end

