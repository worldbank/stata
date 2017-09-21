* Medicine generic characteristics linking file

cap prog drop medgenerics
prog def medgenerics

* Syntax

	syntax anything /// Stub for wide-format drugs identifiers in data
		using /// Generics characteristics file; first column must be titled "Generic Name"
		, link(string asis) /// Each row should match the drugs identifiers from stubs in "A" and then list generics across; no headers
		[prep] [append] [replace] /// Prep exports raw data for cleaning; append indicates the files already exist; replace allows overwrite

* Import option (non-prep)

	if "`prep'" == "" qui {
		
	* Load generics info file

		preserve
			
		import excel `using', first clear
			
		drop if GenericName == ""
			
		foreach var of varlist * { 
			if strpos("`c(ALPHA)'","`var'") drop `var'
			}
			
		foreach letter in `c(ALPHA)' {
			cap rename `letter'? ?
			foreach var of varlist * { 
				if strpos("`c(ALPHA)'","`var'") drop `var'
				}
			}
			
		foreach var of varlist * { // get list of variables
			if "`var'" != "GenericName" {
				local theName : var label `var'
				local theName = lower(strtoname("`theName'"))
				rename `var' `anything'any_`theName'
				local theVars "`theVars' `anything'any_`theName'"
				}
			}
		
		tempfile generics
			save `generics', replace
			
		restore
		
	* Load and merge link file

		preserve
			
		import excel `link', clear
		duplicates drop
		
		rename A `anything' // for merge
		
		local x = 1
		foreach var of varlist * { // get list of variables
			if "`var'" != "`anything'" {
				rename `var' GenericName_`x'
				local ++x
				}
			}
			
		reshape long GenericName_ , i(`anything') 
		
		rename GenericName_ GenericName
		
			drop if GenericName == ""
		
		merge m:1 GenericName using `generics' , keep(1 3)
			
			foreach var of varlist `theVars' {
				local `var'_label : var label `var'
				}
			
			collapse (max) `theVars' , by(`anything')
			
			foreach var of varlist `theVars' {
				label var `var' "``var'_label'"
				}
			
		save `generics', replace
		
		restore
		
	* Setup raw data

		* IDs for final merge

			tempvar n
				gen `n' = _n
			
		* Reshape to long in medicines
		
			preserve
				
			tempvar med
				
			reshape long `anything', i(`n') j(`med')
		
		* Merge generic characteristics onto medicines
			
			keep `anything' `n' `med'

			merge m:1 `anything' using `generics' , nogen keep(1 3)
			
			sort `n' `med'
				
			foreach var of varlist `anything'?* {
				replace `var' = 0 if `var' == .
				}
				
			foreach var of varlist `theVars' {
				local `var'_label : var label `var'
				}
			
			collapse (max) `theVars' , by(`n')
			
			foreach var of varlist `theVars' {
				label var `var' "``var'_label'"
				}
			
			tempfile data
				save `data' , replace
			
			restore

	* Merge final data
		
		merge 1:1 `n' using `data', nogen
			
	* End non-prep

		}
		
* Prep option

	if "`prep'" != ""  qui {
	
	* Append option
	
		if "`append'" == "" {
		
			putexcel A1=("Generic Name") B1=("Antibiotic") A2=("Aceclofenac") B2=("0") A3=("Paracetamol") B3=("0") `using' , `replace'
			
			putexcel A1=("ACECLOFENAC & PARACETAMOL") B1=("Aceclofenac") C1=("Paracetamol") using `link' , `replace'
			
			}
		
	* Import using and linking spreadsheets
		
		preserve
		
		import excel `using' , first clear
		
		duplicates drop
		
		tempfile coding
			save `coding' , replace
			
		import excel `link' , clear
		
		duplicates drop
		
		tempfile linking
			save `linking', replace
			
		restore
	
	* Export linking file
	
		preserve
	
		* Reshape to long in medicines, merge, and export
		
			tempvar n
				gen `n' = _n
				
			tempvar med
				
			reshape long `anything', i(`n') j(`med')
			
			keep `anything'
			
			duplicates drop
			
			rename `anything' A
			
				merge 1:1 A using `linking' , nogen update replace
				
				sort A

				export excel using `link' , `replace'
			
		* Reshape to long in generics, merge, and export
		
			drop A
			local x = 1
			foreach var of varlist * {
				rename `var' GenericName`x'
				local ++x
				}
				
			tempvar n
			gen `n' = _n
				
			tempvar med
								
			reshape long GenericName, i(`n') j(`med')
			
			keep GenericName
				keep if GenericName != ""
				duplicates drop
				
			merge 1:1 GenericName using `coding' , nogen
			
				label var GenericName "Generic Name"
				
				sort GenericName
				
				foreach var of varlist * {
					if length("`var'") < 3 drop `var' 
					}
			
				export excel `using' , `replace' first(varl)
			
			restore

* End Prep option
	
	}
		
end


	
* Have a lovely day!
