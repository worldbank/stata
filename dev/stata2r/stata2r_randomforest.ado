set trace off
set tracedepth 2

cap prog drop stata2r_rf
prog def stata2r_rf

syntax anything , GENerate(string asis)

local thedepvar : word 1 of `anything'
local thedepvar = "`thedepvar' ~ "
local rhsvars = subinstr("`anything'","`thedepvar' ","",1)
local rhsvars = subinstr("`rhsvars'"," "," + ",.)

// Export in CSV format
quietly: cap saveold "testout.dta" , replace v(12)
quietly: cap saveold "testout.dta" 
quietly: file close _all
 
// Write R Code
// dependencies: foreign
quietly: file open rcode using  test.R, write replace
quietly: file write rcode ///
    `"setwd("`c(pwd)'")"' _newline ///
    `"#install.packages("randomForest")"' _newline ///
    `"library(foreign)"' _newline ///
	`"library(randomForest)"' _newline ///	
    `"data<-data.frame(read.dta("testout.dta"))"' _newline ///
    `"rf.output <- randomForest(`thedepvar' `rhsvars', data = data)"' _newline ///
    `"data[["`generate'"]] <- rf.output[["predicted"]]"' _newline ///
    `"write.dta(data,"testin.dta")"'
quietly: file close rcode
 
// Run R
 * shell "/Applications/R.app" CMD BATCH test.R
qui shell /Library/Frameworks/R.framework/Resources/bin/R --vanilla <test.R

// Read Revised Data Back to Stata
 use testin.dta, clear
summarize

// Clean up
rm testout.dta
rm testin.dta
rm test.R

end

* Demo

sysuse auto, clear

stata2r_rf price mpg trunk, gen(predicted_price)
 
 

* Have a lovely day!

