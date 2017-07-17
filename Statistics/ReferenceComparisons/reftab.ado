** Reference-Category Multiple Comparison Tables

cap prog drop reftab
prog def reftab

syntax anything [using] [if] [in], BYvar(varname) REFcat(integer) [controls(string asis)] [CLuster(varname)] [DECimals(string asis)] [iv(varname)] [n] [SEm] [logit] [*]

marksample touse

preserve

keep if `touse'

qui levelsof `byvar' , local(levels)

cap mat drop _all

* Options

if "`logit'" != "" local or or
if "`logit'" == "" local reg reg
	else local reg logit

if "`sem'" == "sem" local semlabel "."

if "`cluster'" != "" local cluster " vce(cluster `cluster')"

* Create results
			
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
				
				mat theReference = nullmat(theReference) \ [theNextVarAll, theNextVar]
				
		* Do the regressions
		
			qui `reg' `var' ib`refcat'.`byvar' , `cluster' `or'
			
			mat theResults = r(table)

		* Get means, SEs, and regression coefficients by category

			local x = 0
			foreach level in `levels' {
				local ++x
				if `refcat' != `level' {
				
				* Regression coefs
				
				mat theReg_`level' = nullmat(theReg_`level') \ theResults[1,`x']
					local p = theResults[4,`x']
					local stars_`level' = 0
					if `p' < 0.1  local stars_`level' = 3
					if `p' < 0.05 local stars_`level' = 2
					if `p' < 0.01 local stars_`level' = 1
					mat theStars_`level' = nullmat(theStars_`level') \ [`stars_`level'']
					
					
				if "`sem'" == "sem" mat theReg_`level' = nullmat(theReg_`level') \ theResults[2,`x']
				if "`sem'" == "sem" mat theStars_`level' = theStars_`level' \ [0]
								
				* Means/SEs

				qui tabstat `var' if `byvar' == `level' , s(mean `sem') save
					mat theNextVar = r(StatTotal)
					
					mat theMeans_`level' = nullmat(theMeans_`level') \ theNextVar
					
					}
				} // End categories loop.
			
		* Controls
			
			if "`controls'" != "" {
				qui `reg' `var' ib`refcat'.`byvar' `controls' , `cluster' `or'
				mat theResults = r(table)
				
				local x = 0
				foreach level in `levels' {
					local ++x
					if `refcat' != `level' {
				
					mat theAdj_`level' = nullmat(theAdj_`level') \ theResults[1,`x']
						local p = theResults[4,`x']
						local stars_`level' = 0
						if `p' < 0.1  local stars_`level' = 3
						if `p' < 0.05 local stars_`level' = 2
						if `p' < 0.01 local stars_`level' = 1
												
						mat theAdjStars_`level' = nullmat(theAdjStars_`level') \ [`stars_`level'']
					if "`sem'" == "sem" mat theAdj_`level' = nullmat(theAdj_`level') \ theResults[2,`x']
					if "`sem'" == "sem" mat theAdjStars_`level' = theAdjStars_`level' \ [0]
						}
						
					} // End controls category loop
					
				} // End Controls if
				
		* Instrumental Variables
		
			if "`iv'" != "" {
			
				* Regression
				
					qui ivregress 2sls `var' (`iv' = ib`refcat'.`byvar') `cluster'

					mat theIV = nullmat(theIV) \ _b[`iv']
					local p = (2 * (1- normal(abs(_b[`iv']/_se[`iv']))))
					local stars_IV = 0
					if `p' < 0.1  local stars_IV = 3
					if `p' < 0.05 local stars_IV = 2
					if `p' < 0.01 local stars_IV = 1
					mat theStars_IV = nullmat(theStars_IV) \ [`stars_IV']
					
					mat colnames theIV = "IV"
					
					if "`sem'" == "sem" mat theIV = nullmat(theIV) \ _se[`iv']
					if "`sem'" == "sem" mat theStars_IV = theStars_IV \ [0]
					
					
				* With controls
				
				if "`controls'" != "" {
				
					qui ivregress 2sls `var' (`iv' = ib`refcat'.`byvar') `controls' `cluster'
										
					mat theIV_Adj = nullmat(theIV_Adj) \ _b[`iv']
					local p = (2 * (1- normal(abs(_b[`iv']/_se[`iv']))))
					local stars_IV_Adj = 0
					if `p' < 0.1  local stars_IV_Adj = 3
					if `p' < 0.05 local stars_IV_Adj = 2
					if `p' < 0.01 local stars_IV_Adj = 1
					mat theStars_IV_Adj = nullmat(theStars_IV_Adj) \ [`stars_IV']
					
					mat colnames theIV_Adj = "Adjusted"
					
					if "`sem'" == "sem" mat theIV_Adj = nullmat(theIV_Adj) \ _se[`iv']
					if "`sem'" == "sem" mat theStars_IV_Adj = theStars_IV_Adj \ [0]
					
					} // End Controls IV loop
			
			
			} // End IV loop
			
		} // End variable loop.
			
* Compile Results
	
	local nlevels = 1
	local spaces `""Means""'
	foreach level in `levels' {
		if `refcat' != `level' {
		if `nlevels' > 1 local spaces `" `spaces' "Means" "'
		local ++ nlevels
	
		local theLabel : label (`byvar') `level'
		if "`n'" == "n" {
			qui count if `byvar' == `level'
			mat n = nullmat(n) , `r(N)'
			}
		
		mat colnames theMeans_`level' = "`theLabel'"
		mat colnames theReg_`level' = "OLS"
		if "`controls'" != "" mat colnames theAdj_`level' = "Adjusted"
	
		mat results_means 	= nullmat(results_means) , theMeans_`level'
		
		mat results_regs 	= nullmat(results_regs) , theReg_`level' , nullmat(theAdj_`level')
		mat results_regs_S 	= nullmat(results_regs_S) , theStars_`level' , nullmat(theAdjStars_`level')
		
		if "`controls'" != "" local theNames `"`theNames' "`theLabel'" "`theLabel'" "'
		if "`controls'" == "" local theNames `"`theNames' "`theLabel'" "'
		}
		}
		
	local refname : label (`byvar') `refcat'
		
	mat colnames theReference = "Total" "`refname'"
	
	mat results_means_S = J(rowsof(results_means),colsof(results_means),0)
	mat theReference_S = J(rowsof(theReference),colsof(theReference),0)
	
	mat results 		= theReference , results_means , results_regs , nullmat(theIV), nullmat(theIV_Adj)
	mat results_STARS 	= theReference_S , results_means_S , results_regs_S , nullmat(theStars_IV), nullmat(theStars_IV_Adj)
	
	if "`n'" == "n" {
		mat n = allN, refN , n , J(1,colsof(results)-colsof(n)-2,.)
		mat n_S = J(1,colsof(n),0)
		mat results 		= results \ n
		mat results_STARS 	= results_STARS \ n_S
		local theLabels `" `theLabels' "N" "'
		}
		
	mat rownames results = `theLabels'
	
	matlist results
	
* Print to xml_tab

	local x = 0

	if `"`using'"' != `""' {
	
		foreach word in `decimals' {

				local format NCRR`word'
				if "`sem'" == "sem" local semformat NCRI`word'
								
				local theFormats `theFormats' `format' `semformat'
				local ++x

			}
			
	if "`iv'" != "" {
	
		local theIVlab : var label `iv'
		
		}
		
		local n1 = `nlevels' + 1
		
		xml_tab results `using' , `options' cblanks(`n1') format((SCLB0) (SCCB0 `theFormats' NCRR0)) ///
			showeq ceq("Means" "Means" `spaces' `theNames' "`theIVlab'" "`theIVlab'") rnames(`theLabels')
		
		}
		
	
end


