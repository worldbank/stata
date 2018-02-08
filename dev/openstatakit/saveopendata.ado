* Program to trim public release dataset to only include variables used in analysis

cap prog drop saveopendata
prog def saveopendata

* Syntax – anything sets location to save data and codebook ; using lists all dofiles that use the current dataset

	syntax anything [using/] , [compact]
	
* Get all variables in current dataset
	
	local anything = subinstr(`"`anything'"',`"""',"",.)
	unab theVarlist : *

* Quietly

qui {
	
* If [using] is requested:
* Initialize datafile of variable names

if `"`using'"' != "" {
	
		preserve
		clear

		tempfile a
			save `a' , replace emptyok
		
	* Stack up all the lines of code from all the dofiles in a dataset

		foreach file in `using' {
		
			* Load the file and append to dofile-dataset

				import delimited "`file'" , clear delim("ß")
				
				append using `a'
				tempfile a
					save `a' , replace
					
		} // End dofile loop
				
	* Loop through every variable in the current dataset and put its name wherever it occurs
		
		local x = 1
		foreach item in `theVarlist' {
		
			local ++x
			gen v`x' = "`item'" if strpos(v1,"`item'") 
			
			} // End variable loop
			
	* Collapse to one column to get every variable mentioned in any dofile
		
		collapse (firstnm) v* , fast
			gen n = 1
			reshape long v , i(n) // Reshape to column of varnames
			keep v
			drop if v == ""
			drop in 1
			
	* Loop over variable names to build list of variables to keep
	
		count 
		forvalues i = 1/`r(N)' {
		
			local theNextVar = v[`i']
			local theKeepList = "`theKeepList' `theNextVar'"
			
			} // End variable loop

* Restore and keep variables

	restore
	keep `theKeepList' // Keep only variables mentioned in the dofiles
	compress
	save "`anything'.dta" , replace
	
	} // end if using

* Write codebook – compactly if specified

	cap log close
	cap set trace off
	log using "`anything'.txt", text replace
	noisily codebook , `compact'
	log close

* End

} // end qui

noi di in red " "
noi di in red "Check the dataset carefully to make sure:"
noi di in red "(A) There is no personally-identifying information remaining"
noi di in red "(B) Your analysis reproduces exactly from this copy"
noi di in red " "
noi di in red "Thank you for creating a neatly shareable dataset or codebook with saveopendata!"
	
end

/* Demo

	cd /Users/bbdaniels/GitHub/stata/dev/openstatakit/

	sysuse auto , clear
	
	isid make , sort
	
	reg rep78 headroom

	saveopendata "saveopendata" 	using "saveopendata.ado"
	saveopendata "saveopendatacompact" 	, compact
	
* Have a lovely day!
