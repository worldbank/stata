// Creates table of summary statistics

cap prog drop sumstats
prog def sumstats

version 15.1

syntax anything using/ [aw fw], stats(string asis) [replace]

cap mat drop stats_toprint
qui {
// Separate into variable lists

	local x = 0
	while strpos("`anything'",")") > 0 {
		local ++x
		local `x' = substr("`anything'",1,strpos("`anything'",")")-1) 	// Take out group of variables up to close-parenthesis
			local `x' = subinstr("``x''","(","",1) 			// Remove open-parenthesis.

		local anything    = substr("`anything'",strpos("`anything'",")")+1,.) 	// Replace remaining list with everything after close-parenthesis
	}

// Initialize output Excel file

	putexcel set `using' , `replace'

	// Stats headers
	local col = 1
	foreach stat in `stats' {
		local ++col
		local theCol : word `col' of `c(ALPHA)'
		putexcel `theCol'1 = "`stat'" , bold
	}

// Loop over groups

	local theRow = 1
	forvalues i = 1/`x' {
		local ++theRow

		// Catch if-condition if any, else print full sample
		if regexm("``i''"," if ") {
			local ifcond = substr("``i''",strpos("``i''"," if ")+4,.)
			local justvars = substr("``i''",1,strpos("``i''"," if "))
			local ifcond = `"Subsample: `ifcond'"'
		}
		else local ifcond "Full Sample"
		putexcel A`theRow' = "`ifcond'", bold

		// Get statistics
		local ++theRow
		qui tabstat  ``i''  ///
			[`weight'`exp'] ///
			, s(`stats') save
			mat a = r(StatTotal)'
			putexcel B`theRow' = matrix(a) , nformat(number_d2)

		// Get variable labels
		local varRow = `theRow'
		foreach var in `justvars' {
			local theLabel : var label `var'
			putexcel A`varRow' = "`theLabel'"
			local ++varRow
		}
	local theRow = `theRow' + `=rowsof(a)'
	}

// Finalize

	putexcel close
} // end qui
di in red "Summary statistics output to `using'"
end
