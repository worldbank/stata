set trace off
set tracedepth 2

cap prog drop stata2r_ranger
prog def stata2r_ranger

syntax anything , GENerate(string asis) [seed(integer 47)] ///
	[rpath(string asis)] [weight(string asis)] [num.trees(integer 1000)] ///
	[importance(string asis)] [write.forest(string asis)]// for windows
	
* Setup

	unab anything : `anything'
	local thedepvar : word 1 of `anything'
	local rhsvars = subinstr("`anything'","`thedepvar' ","",1)
	local rhsvars = subinstr("`rhsvars'"," "," + ",.)
	
	gen X_FAKEDV = `thedepvar'
	local thedepvar "X_FAKEDV ~ "
	gen X_FAKEID = _n

	preserve
		keep `anything' X_FAKEID X_FAKEDV

// Export dataset

	quietly: cap saveold "testout.dta" , replace v(12)
		if _rc!=0 saveold "testout.dta" , replace
	quietly: file close _all
	 
// Write R Code

	quietly: file open rcode using  test.R, write replace
	quietly: file write rcode ///
		`"setwd("`c(pwd)'")"' _newline ///
		`"set.seed(`seed')"' _newline ///
		`"if(!"ranger" %in% installed.packages()) install.packages("ranger",repos="http://cran.us.r-project.org")"' _newline ///
		`"library(foreign)"' _newline ///
		`"library(ranger)"' _newline ///	
		`"data<-data.frame(read.dta("testout.dta"))"' _newline ///
		`"rf.output <- ranger(`thedepvar' `rhsvars', data = data, case.weight = `weight', num.trees = `num.trees', write.forest = `write.forest', importance = `importance')"' _newline ///
		`"data[["`generate'"]] <- predict[rf.output]]"' _newline ///
		`"write.dta(data,"testin.dta")"'
	quietly: file close rcode
	 
// Run R

	if "`c(os)'" == "MacOSX" {
		qui shell /Library/Frameworks/R.framework/Resources/bin/R --vanilla <test.R
		}
	else {
		qui shell "`rpath'" CMD BATCH test.R
		}

// Read Revised Data Back to Stata

	qui use testin.dta, clear
	su `generate' 
	
	qui keep `generate' X_FAKEID
	
	tempfile newdata
		qui save `newdata' , replace
		
	restore
		
		qui merge 1:1 X_FAKEID using `newdata' , nogen update replace
		drop X_FAKEID X_FAKEDV





// Clean up
rm testout.dta
rm testin.dta
rm test.R

end

* Demo
sysuse auto, clear

*stata2r_rf mpg foreign price trunk, gen(predicted_price) seed(474747)

stata2r_ranger price mpg trunk, gen(predicted_price) seed(474747) rpath(C:\Program Files\R\R-2.15.1\bin\x64\R.exe)

*test weight option
 
 

* Have a lovely day!
