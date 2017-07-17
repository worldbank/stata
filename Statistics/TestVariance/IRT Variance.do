** IRT Distribution


global directory "/Users/bbdaniels/Dropbox/WorldBank/QuTub/Restricted/Patna Analysis"
		
	use "${directory}/constructed/Wave_0_1_combined.dta" , clear
		keep if case == 1 & visit == 1 & round == 1
		
	rename sp1_h_* q*

	set seed 474747 //For replicability.
	
	keep q* facilitycode
		drop qutub_id
		gen formal = regexm(facilitycode,"QF")
	
	
	local x = 0
	
	cap mat drop theResults
	tempfile theData
		save `theData' , replace
	
	local x = 0
	forvalues items = 2/20 {
		cap mat drop theResult
		forvalues iteration = 1/20 {
			
			local ++x
			
			ncr , n(21) r(`items')
			local theItems = subinstr("`r(chosen)'"," "," q",.)
			di "`theItems'"
			use `theData' , clear
			easyirt `theItems' ///
				using "/Users/bbdaniels/Desktop/IRT Variance/scores/it_`x'.dta" ///
				, id(facilitycode)
				
			merge 1:1 facilitycode using "/Users/bbdaniels/Desktop/IRT Variance/scores/it_`x'.dta"
			
			reg theta_mle formal
				mat theResult = nullmat(theResult) \ [_b[formal]]
				
				
				
			
			
			
			}
			
			mat colnames theResult = "irt`items'"
			
			mat theResults = nullmat(theResults),theResult
			
		}
		
		

	-
	
	cap prog drop ncr
	prog def ncr , rclass
	
		syntax , n(integer) r(integer)
		
		forvalues i = 1/`n' {
			local theList = "`theList' `i' "
			}
			
		forvalues i = 1/`r' {
			local rnumbers = ""
			foreach num of local theList { 
				local randomnumber = runiform()
				local rnumbers = "`rnumbers'`randomnumber' "
				}
			
			local selection : list sort rnumbers
			local posofselected = word("`selection'",wordcount("`selection'")) 
			local posinselectionlocal : list posof "`posofselected'" in rnumbers 
			local randomitem : word `posinselectionlocal' of `theList'
			
			local theFinalList = "`theFinalList' `randomitem'"
			local theList = subinstr("`theList'"," `randomitem' ","",.)
			}

		return local chosen = "`theFinalList'"
		
	end
	
	ncr , n(25) r(5)
	




* 




