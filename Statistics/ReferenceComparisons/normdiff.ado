* Normalized difference table

	cap prog drop normdiff
	prog def normdiff
	
	syntax ///
		anything ///
		[using] [if] [in], ///
		BYvar(string asis) ///
		refcat(string asis) ///
		[*]
		
* Setup 

	marksample touse

	preserve

	keep if `touse'

	qui levelsof `byvar' , local(levels)

	cap mat drop _all
	
* Get variables information
	
foreach var of varlist `anything' {
	
	* Add name to list
	
		local theLabel : var label `var'
		local theLabels `" `theLabels' "`theLabel'" `semlabel'  "'

	* Get means, SEs for reference category
	
		qui tabstat `var' if `byvar' != . , s(mean `sem') save
			mat theNextVarAll = r(StatTotal)
			qui count if `byvar' != .
			mat allN = `r(N)'
			
		qui tabstat `var' if `byvar' == `refcat' , s(mean `sem') save
			mat theNextVar = r(StatTotal)
			qui count if `byvar' == `refcat'
			mat refN = `r(N)'
			
		qui sum `var' if `byvar' == `refcat'
			local theReferenceMean = `r(mean)'
			local theReferenceVariance = `r(Var)'
			
			mat theReference = nullmat(theReference) \ [theNextVarAll, theNextVar]
		

* Get means, SEs, and regression coefficients by category

	local x = 0
	foreach level in `levels' {
		local ++x
		
		cap mat drop theDifferences_`x'
		
		if `refcat' != `level' {
						
		* Means/SEs

		qui tabstat `var' if `byvar' == `level' , s(mean `sem') save
			mat theNextVar = r(StatTotal)
			
			mat theMeans_`level' = nullmat(theMeans_`level') \ theNextVar
			
		qui sum `var' if `byvar' == `level'
			local thisMean = `r(mean)'
			local thisVariance = `r(Var)'
			
			local theDifference = (`thisMean' - `theReferenceMean') / sqrt(`theReferenceVariance' + `thisVariance')

			mat theDifferences_`x' = nullmat(theDifferences_`x') , [`thisMean' , `theDifference']
			
			local refname : label (`byvar') `level'
			local theCategories = `"`theCategories' "`refname' Mean" "`refname' Difference" "'
			
			}
			
		cap mat theDifferences = nullmat(theDifferences) \ theDifferences_`x'
		
		} // End categories loop.
		
		local theFormats "`theFormats' NCRR2"

	} // End variables loop
	
	mat theResults = theReference , theDifferences
	matlist theResults
	
	
	if `"`using'"' != `""' {
	
		local refname : label (`byvar') `refcat'
		
		xml_tab theResults `using' , `options' format((SCLB0) (SCCB0 `theFormats' NCRR0)) ///
			showeq cnames("Mean" "`refname' Mean" `theCategories') rnames(`theLabels')
			
		}

end

* Have a lovely day!
