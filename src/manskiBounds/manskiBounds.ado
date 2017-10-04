
* Manski simulations for treatment effect under adverse selection assumptions.

cap prog drop manskiBounds
prog def manskiBounds

syntax anything 			/// Specify full model
	  [if] [in] 			///
	, [*] 					/// Regression options
	  Treatment(varname)	/// Binary treatment indicator – MUST be first in regression
	  Outcome(varname) 		/// Binary outcome variable
	  [Seed(integer 4747)]  //  Seed to replicate

* Setup

	preserve
	marksample touse
	keep if `touse'
	
	cap mat drop theResults
	
	set seed `seed'
		sort * , stable
	
	tempvar randControl
		gen `randControl'   = runiform() if `treatment' == 0 & `outcome' == .
	tempvar randTreatment
		gen `randTreatment' = runiform() if `treatment' == 1 & `outcome' == .
	
	tempfile theData
		save `theData' , replace
	
* Run "true" regression

	`anything' , `options'
		local theBeta = _b[`treatment']
		
	
* Loop over values

	local p90 = 0
	local p95 = 0
	qui forvalues i = 99(-1)50 {
		
		use `theData' , clear
		
		* Set percentile cutoffs for treatment and control groups
		
			_pctile `randControl', p(`i')
				local cutControl = `r(r1)'
			
			_pctile `randTreatment', p(`i')
				local cutTreatment = `r(r1)'
	
		* Infill worst case data
			
			if `theBeta' < 0 { // Positive effect of treatment on outcome
				replace `outcome' = 0 if `outcome' == . & `treatment' == 0 & `randControl'   <  `cutControl'
				replace `outcome' = 1 if `outcome' == . & `treatment' == 0 & `randControl'   >= `cutControl'
				replace `outcome' = 0 if `outcome' == . & `treatment' == 1 & `randTreatment' >= `cutTreatment'
				replace `outcome' = 1 if `outcome' == . & `treatment' == 1 & `randTreatment' <  `cutTreatment'
				}
			else { // Negative effect of treatment on outcome
				replace `outcome' = 1 if `outcome' == . & `treatment' == 0 & `randControl'   <  `cutControl'
				replace `outcome' = 0 if `outcome' == . & `treatment' == 0 & `randControl'   >= `cutControl'
				replace `outcome' = 1 if `outcome' == . & `treatment' == 1 & `randTreatment' >= `cutTreatment'
				replace `outcome' = 0 if `outcome' == . & `treatment' == 1 & `randTreatment' <  `cutTreatment'
				}
				
		* Rerun regression with infilled data and record results
		
			`anything' , `options'	
		
			mat regdata = r(table)
				local b		= regdata[1,1]
				local l 	= regdata[5,1]
				local u 	= regdata[6,1]
				local p	 	= regdata[4,1]
				
		* Data points
					
			local pct = 100-`i'
			
				if `p90' == 0 & `p' < 0.1  local p90 = `pct'-0.5
				if `p95' == 0 & `p' < 0.05 local p95 = `pct'-0.5
			
			mat theResults = nullmat(theResults) \ [`pct',`b',`l',`u',`p']
			
		}
		
			mat colnames theResults = "i" "b" "l95" "u95" "p"
			
	restore
	
	clear
	svmat theResults, n(col)
	
	local sBeta = string(round(`theBeta',0.01))

	qui su l
		local theMin = `r(min)'
		if `theBeta' < `theMin' local theMin = `theBeta'
		if 0 < `theMin' local theMin = 0
	qui su u
		local theMax = `r(max)'
		if `theBeta' > `theMax' local theMax = `theBeta'
		if 0 > `theMax' local theMax = 0
		
	local graph_opts bgcolor(white) title("") note(, justification(left) color(black) span pos(7)) title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black) span pos(11)) graphregion(color(white)) ylab(,angle(0) nogrid) ytit("") xtit(,placement(left) justification(left)) yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))
	
	tw 	(rarea l95 u95 i , fc(gs14) lc(gs14)) ///
		(function 0 , range(i) lc(black) lp(dot)) ///
		(function `theBeta' , range(0 50) lc(black) lp(dash) ) ///
		(function `p90' , range(`theMin' `theMax') lc(black) lp(dash) hor) ///
		(function `p95' , range(`theMin' `theMax') lc(black) lp(dash) hor) ///
		(line b i ,lp(solid) lc(black)) ///
	,	`graph_opts' legend(off) xtit("Bounding Fraction{&rarr}") ///
		ylab(`theBeta' "{&beta}: `sBeta'" 0 "No Effect") xlab(0 25 50 `p90' `""p="".1""' `p95' `""p="".05""')
	
end

* Demo 

	clear
	set obs 1000
	matrix c = (1,-.5,0 \ -.5,1,.4 \ 0,.4,1)
	corr2data x y z, corr(c)
	
	replace x = 1 if x > 0
	replace x = 0 if x < 0
	replace y = 1 if y > 0
	replace y = 0 if y < 0
	replace x = . if z > .5
	
	manskiBounds reg x y z ///
		, t(y) o(x)
		
	cd "/users/bbdaniels/desktop/"
	graph export manskiBounds.png , replace


* Have a lovely day!
