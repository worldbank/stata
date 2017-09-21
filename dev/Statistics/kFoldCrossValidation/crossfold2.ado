program define crossfold2, rclass
version 11.0

syntax anything [iweight/] [if/] [in], [k(numlist min=1 max=1)] [EWeight(varname)] [eif(string)] [ein(string)] [stub(string)] [loud] [mae] [mdae] [mape] [mdape] [r2] * 

* Initalize temporary variables.

	tempname u e A results group yhat abspe
	marksample touse
	
* Options and syntax checks.

	if "`mae'" == "mae" & "`r2'" == "r2" {
		di in red "MAE cannot be combined with R2; choose only one evaluation metric."
		exit 198
		}

	if "`k'" == "" {
		local k = 5
		}
	if "`k'" == "1" {
		di in red "Number of folds must be greater than 1"
		exit 198
		}
	if `k' > _N {
		di in red "Number of folds cannot exceed number of observations"
		exit 198
		}
	if `k' > 300 {
		di in red "Number of folds cannot exceed 300"
		exit 198
		}
		
	if "`loud'" == "" {
		local qui = "qui"
		}
		
	if "`eweight'" != "" {
		local eweight = "[weight=`eweight']"
		}
		
	if "`weight'" != "" {
		local weight = "[weight=`exp']"
		}
		
	if "`eif'" != "" {
		local eif = "& `eif'"
		}
	
	if "`ein'" != "" {
		local ein = "in `ein'"
		}
		
	if "`stub'" == "" {
		local stub = "est"
		}
		
* Randomize dataset and initialize results matrix.

	gen `u'       = uniform()
	xtile `group' = `u', n(`k')
	mat `results' = J(`k',1,.)
	local rnames
		forvalues i=1/`k' {
			local rnames "`rnames' "`stub'`i'""
			}
	matrix rownames `results' = `rnames'
	
* Fit models and calculate errors.
	
	forvalues i=1/`k' {

		`qui' `anything' `weight'									if `group' != `i' & `touse'  , `options'
		local depvar = e(depvar)
		cap estimates store `stub'`i'
			
		qui predict `yhat' 											if `group' == `i' `eif' `ein'
		
		* Generate error term
		
			if "`mae'" == "mae" {
				qui gen `e' = abs(`yhat'-`depvar') 					if `group' == `i' `eif' `ein'
				local stat = "mean"
				local result ""
				local label  "MAE"
			}
			else if "`mdae'" == "mdae" {
				qui gen `e' = abs(`yhat'-`depvar') 					if `group' == `i' `eif' `ein'
				local stat = "median"
				local result ""
				local label  "MdAE"
				}
			else if "`mape'" == "mape" {
				qui gen `e' = 100*(`depvar' - `yhat')/`depvar' 					if `group' == `i' `eif' `ein'
				qui gen `abspe' = abs(`e')					 					if `group' == `i' `eif' `ein'
				local stat = "mean"
				local result ""
				local label  "MAPE"
				}
			else if "`mdape'" == "mdape" {
				qui gen `e' = 100*(`depvar' - `yhat')/`depvar' 					if `group' == `i' `eif' `ein'
				qui gen `abspe' = abs(`e')					 					if `group' == `i' `eif' `ein'
				local stat = "median"
				local result ""
				local label  "MdAPE"
				}
			else if "`r2'" == "r2" {
				local label  "Pseudo-R2"
				}
			else {
				qui gen `e' = (`yhat'-`depvar')*(`yhat'-`depvar') 	if `group' == `i' `eif' `ein'
				local stat = "mean"
				local result "sqrt"
				local label  "RMSE"
				}
		
		* Tabulate errors
		
			if "`mae'" == "mae" | "`mdae'" == "mdae" {
				qui tabstat `e' `eweight'							if `group' == `i' `eif' `ein', stats(`stat') save
				mat `A' 			  = r(StatTotal)
				local statout 		   	  = `A'[1,1]
				mat `results'[`i',1]  = `result'(`statout')
				}
			else if "`mape'" == "mape" | "`mdape'" == "mdape" {
				qui tabstat `abspe' `eweight'							if `group' == `i' `eif' `ein', stats(`stat') save
				mat `A' 			  = r(StatTotal)
				local statout 		   	  = `A'[1,1]
				mat `results'[`i',1]  = `result'(`statout')
				}
			else if "`r2'" == "r2" {
				* Generate psuedo r-squared.
				qui corr `yhat' `depvar'
				mat `results'[`i',1]  = r(rho)*r(rho)
				}
			else {				
				qui tabstat `e' `eweight'							if `group' == `i' `eif' `ein', stats(`stat') save
				mat `A' 			  = r(StatTotal)
				local statout 		   	  = `A'[1,1]
				mat `results'[`i',1]  = `result'(`statout')				
				}
		
			drop `yhat'
			cap drop `e'
			cap drop `abspe'
		}
	
* Return results.
	
	mat colnames `results' = "`label'"
	matlist `results'
	return matrix `stub'   = `results'
	
end
