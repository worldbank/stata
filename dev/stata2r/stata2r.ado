
// Set Working Directory

cd "/Users/bbdaniels/desktop/"

clear
set more off
log close _all
 
// Create Data
set obs 100
matrix c = (1,-.5,0 \ -.5,1,.4 \ 0,.4,1)
corr2data x y z, corr(c)
 
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
 * shell "/Applications/R.app" CMD BATCH test.R
 
 shell /Library/Frameworks/R.framework/Resources/bin/R --vanilla <test.R
 
// Read Revised Data Back to Stata
quietly: use testin.dta, clear
summarize
 
// Clean up
rm testout.dta
rm test.R

* Have a lovely day!
