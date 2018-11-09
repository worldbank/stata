// outwriter: writes arbitrary matrix to Excel/LaTeX

cap prog drop outwriter
prog def outwriter

	// VERSION
	version 15.1

	syntax anything using/ ///
		, ///
		[format(integer 2)] ///
		[rownames(string asis)] ///
		[colnames(string asis)]


	// Regressions or matrix?
	if `: word count `anything'' >= 2 {

		cap mat drop results results_STARS
		cap regprep `anything' , below `options'

		mat results = r(results)
		mat results_STARS = r(results_STARS)

		qui forvalues row = 1/`=rowsof(results_STARS)' {
		  forvalues col = 1/`=colsof(results_STARS)' {
		    local check = results_STARS[`row',`col']
		    if "`check'" == "1" mat results_STARS[`row',`col'] = 3
		    if "`check'" == "3" mat results_STARS[`row',`col'] = 1
		  }
		}
	local anything = "results"
	}

	// Set up putexcel
	putexcel set `using' , replace

		local nCols = colsof(`anything') + 1
		local nRows = rowsof(`anything') + 1

	// Write row names
	if "`rownames'" == "" local rownames : rownames `anything', quoted
	forvalues i = 2/`nRows'{
		local theName : word `=`i'-1' of `rownames'
		putexcel A`i' = "`theName'" , nformat(bold)
	}

	// Write column names
	if "`colnames'" == "" local colnames : colnames `anything', quoted
	forvalues i = 2/`nCols'{
		local theName : word `=`i'-1' of `colnames'
		local theCol : word `i' of `c(ALPHA)'
		putexcel `theCol'1 = "`theName'" , nformat(bold)
	}

	// Write values
	forvalues i = 2/`nRows' {
	forvalues j = 2/`nCols' {

		// Get the placement
		local theCol : word `j' of `c(ALPHA)'
		local theRow = `i'

		// Get the values
		local nStars 	= `anything'_STARS[`=`i'-1',`=`j'-1']
			local nStars = min(3,`nStars')
		local theValue  = `anything'[`=`i'-1',`=`j'-1']

		// Set the formatting
		local theFormat = `format'*"0" + `nStars'*"\*" + `=3-`nStars''*"_*"

		putexcel `theCol'`theRow' = `theValue' , nformat(#.`theFormat')

		putexcel close
	}
	}

end

sysuse auto.dta, clear
reg price mpg
	est sto reg1
	est sto reg2

outwriter reg1 reg2 using "/users/bbdaniels/desktop/test.xlsx"


// Have a lovely day!
