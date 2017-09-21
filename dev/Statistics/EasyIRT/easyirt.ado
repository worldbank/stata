* Generalizes IRT to broader naming structures and sets up merge files.

cap prog drop easyirt
prog def easyirt

syntax varlist using/ [if] [in], id(varlist) [theta(string asis)] [Replace] [*]	

preserve

qui {
	* Setup
	
		marksample touse, novarlist
		keep if `touse'

		keep `id' `varlist'

		local theScores `using'
		local theParams = subinstr("`using'",".dta","_items.dta",.)
		local theLabels = subinstr("`using'",".dta","_labels.xlsx",.)
	
	* Rename variables for IRT
			
		labelcollapse (firstnm) `varlist' , by(`id')
		
		local x = 1
		
		foreach var of varlist `varlist' {
		
			local `var'_num  = `x'
			local `x'_name "`var'"
			local `x'_lab : var label `var'
				local ++x
				
			rename `var' _q``var'_num'
			
			sum _q``var'_num'
			if `r(N)' == 0 drop _q``var'_num'
			}

	* ID variables tempfile
	
		gen _IRT_ID = _n
		
		tempfile all
			save `all', replace
		
		keep `id' _IRT_ID
		
		tempfile theIDvars
			save `theIDvars', replace
			
		use `all', clear
		
	* Do IRT
	
		keep _IRT_ID _q*
		
		openirt , `options' id(_IRT_ID) item_prefix(_q) ///
			save_trait_parameters(`""`theScores'""') ///
			save_item_parameters(`""`theParams'""') 
			
	* Correct ID varname in score dataset

		use "`theScores'", clear
			cap rename id _IRT_ID
			merge 1:1 _IRT_ID using `theIDvars', nogen
			drop _IRT_ID
			
			if "`theta'" != "" {
				local thetavar = lower(strtoname("`theta'"))
				rename theta* `thetavar'*
				
				foreach var of varlist `thetavar'* {
					local oldLabel : var label `var'
						local newLabel = regexr("`oldLabel'","Theta","`theta'")
						label var `var' "`newLabel'"
					}
				}
			
			order `id', first
		save "`theScores'", replace
		
	* Attach original variable names and labels to parameter dataset
			
		use "`theParams'", clear
			gen label = ""
			gen varname = ""
			count
			forvalues i = 1/`r(N)' {
				local x = id[`i']
				replace varname = "``x'_name'" if id == `x'
				replace label = "``x'_lab'" if id == `x'
				}
		save "`theParams'", replace
		
}		
end
