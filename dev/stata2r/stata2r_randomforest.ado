
cap prog drop stata2r_rf
prog def stata2r_rf

syntax anything , GENerate(string asis)


local thedepvar : word 1 of `anything'
local thedepvar = "`thedepvar' ~ "
local rhsvars = subinstr("`anything'","`thedepvar' ","",1)
local rhsvars = subinstr("`rhsvars'"," "," + ",.)

/*
 
// Export in CSV format
quietly: saveold "testout.dta" , replace v(12)
quietly: file close _all
 
// Write R Code
// dependencies: foreign
quietly: file open rcode using  test.R, write replace
quietly: file write rcode ///
    `"setwd("/Users/bbdaniels/GitHub/tests/stata2r/")"' _newline ///
    `"library(foreign)"' _newline ///
    `"data<-data.frame(read.dta("testout.dta"))"' _newline ///
    `"attach(data)"' _newline ///
    `"x2<-x*2"' _newline ///
    `"data2<-cbind(data,x2)"' _newline ///
    `"write.dta(data2,"testin.dta")"'
quietly: file close rcode
 
// Run R
quietly: shell "/Applications/R.app" CMD BATCH test.R
 
// Read Revised Data Back to Stata
quietly: use testin.dta, clear
summarize

// Clean up
rm testout.dta
rm test.R


*/

end

 * Demo
 
 sysuse auto, clear
 
 stata2r_rf price mpg make
 
 

* Have a lovely day!
