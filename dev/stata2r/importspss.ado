
*importspss.ado
*by GHR 6/29/2010
*this script uses R to translate SPSS to Stata
*it takes as arguments the SPSS file and Stata file
*adapted from http://mikegruz.tumblr.com/post/704966440/convert-spss-to-stata-without-stat-transfer 
 
*DEPENDENCY: R and library(foreign) 
*if R exists but is not in PATH, change the reference to "R" in line 27 to be the specific location
 
capture program drop importspss
program define importspss
    set more off
    local spssfile `1'
    if "`2'"=="" {
        local statafile "`spssfile'.dta"
    }
    else {
        local statafile `2' 
    }
    local sourcefile=round(runiform()*1000)
    capture file close rsource
    file open rsource using `sourcefile'.R, write text replace
    file write rsource "library(foreign)" _n
    file write rsource `"data <- read.spss("`spssfile'", to.data.frame=TRUE)"' _n
    file write rsource `"write.dta(data, file="`statafile'")"' _n
    file close rsource
    quietly: shell "/Applications/R.app" CMD BATCH `sourcefile'.R
    erase `sourcefile'.R
    use `statafile', clear
end
