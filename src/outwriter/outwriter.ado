// outwriter: writes regressions or arbitrary matrix to Excel/LaTeX

cap prog drop outwriter
prog def outwriter

	// VERSION
	version 15.1

	syntax anything using/ ///
		, ///
		[format(integer 2)] ///
		[rownames(string asis)] ///
		[colnames(string asis)]


	// Regressions setup
	if `: word count `anything'' >= 2 {

		cap mat drop results results_STARS
		cap regprep `anything' , below `options' stats(N r2)

		mat results = r(results)
		mat results_STARS = r(results_STARS)

		// Correct star values
		forvalues row = 1/`=rowsof(results_STARS)' {
		forvalues col = 1/`=colsof(results_STARS)' {
		    local check = results_STARS[`row',`col']
		    if "`check'" == "1" mat results_STARS[`row',`col'] = 3
		    if "`check'" == "3" mat results_STARS[`row',`col'] = 1
		}
		}

		// Correct row names
		local conscounter = 0
		local rownames ""
		local rownames_old : rownames results, quoted
		local rowcounter 1
		cap mat drop results_new
		cap mat drop results_new_STARS
		foreach name in `rownames_old' {

			// Constant
			if regexm("`name'","_cons_easytofind0")  & (`conscounter' == 0) {
				local rownames `"`rownames' "Constant" """'
				mat results_new = nullmat(results_new) \ results[`=`rowcounter'-1',....]
				mat results_new = nullmat(results_new) \ results[`rowcounter',....]
				mat results_new_STARS = nullmat(results_new_STARS) \ J(1,colsof(results_STARS),0)
				mat results_new_STARS = nullmat(results_new_STARS) \ J(1,colsof(results_STARS),0)
				local ++conscounter
			}

			// Variables
		 	if !regexm("`name'","_cons") & regexm("`name'","_easytofind0") & (`conscounter' == 0) {
				local theVar = subinstr("`name'","_easytofind0","",.)
				local theLab : var lab `theVar'
				local rownames `"`rownames' "`theLab'" """'
				mat results_new = nullmat(results_new) \ results[`rowcounter',....]
				mat results_new = nullmat(results_new) \ results[`=`rowcounter'+1',....]
				mat results_new_STARS = nullmat(results_new_STARS) \ results_STARS[`rowcounter',....]
				mat results_new_STARS = nullmat(results_new_STARS) \ results_STARS[`=`rowcounter'+1',....]
				local ++rowcounter
			}

			// Stats
			if !regexm("`name'","_cons") & regexm("`name'","_easytofind1") & (`conscounter' == 1) {
				local theLab = subinstr("`name'","_easytofind1","",.)
				local rownames `"`rownames' "`theLab'""'
				mat results_new = nullmat(results_new) \ results[`rowcounter'-1,....]
				mat results_new_STARS = nullmat(results_new_STARS) \ J(1,colsof(results_STARS),0)
			}

		local ++rowcounter
		}

	local colnames `anything'
	local anything = "results_new"
	}

	// Set up putexcel
	putexcel set `using' , replace

		local nCols = colsof(`anything') + 1
		local nRows = rowsof(`anything') + 1

	// Write row names
	if `"`rownames'"' == "" local rownames : rownames `anything', quoted
	forvalues i = 2/`nRows'{
		local theName : word `=`i'-1' of `rownames'
		putexcel A`i' = "`theName'" , nformat(bold)
	}

	// Write column names
	if `"`colnames'"' == "" local colnames : colnames `anything', quoted
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

		cap putexcel `theCol'`theRow' = `theValue' , nformat(#.`theFormat')

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
