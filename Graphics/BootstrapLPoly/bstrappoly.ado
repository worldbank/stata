* Bootstrap confidence intervals for lpoly

cap prog drop bstrappoly
prog def bstrappoly

syntax [anything] [if] [in] , Bootstrap(string asis) [BOPTions(string asis)] [CIOPTions(string asis)] [LPOLYOPTions(string asis)] ///
	[HISTogram(string asis)] [HOPTions(string asis)] [Seed(integer 474747)] [Reps(integer 500)] [*]

set seed `seed'
preserve

marksample touse
	keep if `touse'
	
tempname id
	gen `id' = _n

	cap drop yhat*
	
	tempfile all
		save `all', replace

tempname xgrid

* Histogram

	if "`histogram'" != "" local histogram "(histogram `histogram' , yaxis(2) `hoptions')"

* Setup

	lpoly `bootstrap' , nograph `boptions' generate(`xgrid' yhat_obs)

	keep if `xgrid' <.
	keep `xgrid' yhat_obs `id'
	sort `xgrid'

	tempfile tofill
		save `tofill'
		
		gen id = _n
		keep id `xgrid' `id'
		sort id
		
		tempfile grid
		save `grid'

* Bootstrapping	
	
	qui forvalues i = 1/`reps' {
		use `all', clear
		bsample 
			gen id = _n
			sort id
			merge 1:1 id using `grid', nogen
			
		lpoly `bootstrap' , nograph `boptions' generate(yhat_`i') width(`reps') at(`xgrid') nograph
			keep if `xgrid' < .
			keep `xgrid' yhat_`i' `id'
			sort `xgrid'
			merge 1:1 `xgrid' using `tofill', nogen

			sort `xgrid'
			save `tofill', replace
						
		}
		
	use `tofill'
		qui merge 1:1 `id' using `all'
		
		egen lb = rowpctile(yhat*), p(2.5)
		egen ub = rowpctile(yhat*), p(97.5)
		twoway ///
			`histogram' /// histogram if specified
			(rarea lb ub `xgrid' , sort `cioptions') /// bootstrap CI
			`anything' /// whatever else
			(line yhat_obs `xgrid' , sort `lpolyoptions') /// ordinary lpoly
			, `options'
			
end

