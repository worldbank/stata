* Creates table of summary statistics

cap prog drop sumStats
prog def sumStats

syntax anything using, stats(string asis) [*]

cap mat drop stats_toprint

* Separate into variable lists

	local x = 0
	while strpos("`anything'",")") > 0 {
		local ++x
		local `x' = substr("`anything'",1,strpos("`anything'",")")-1) 	// Take out group of variables up to close-parenthesis
			local `x' = subinstr("``x''","(","",1) 			// Remove open-parenthesis.

		local anything    = substr("`anything'",strpos("`anything'",")")+1,.) 	// Replace remaining list with everything after close-parenthesis
		}

* Stats and labels

	forvalues i = 1/`x' {
		cap mat drop blankrow
		qui tabstat  ``i''  ///
			, s(`stats') save

			mat a = r(StatTotal)'
			mat blankrow = J(1,colsof(a),.)

		if regexm("``i''"," if ") {
			local ifcond = substr("``i''",strpos("``i''"," if "),.)
			local ifcond = substr(subinstr("`ifcond'"," if ","",.),1,30)
				mat rownames blankrow = "`ifcond'"
			}

		if regexm("``i''"," if ") local stats_toprint = substr("``i''",1,strpos("``i''"," if "))
			else local stats_toprint = "``i''"

		if regexm("``i''"," if ")  local allLabels = `" `allLabels' "`ifcond'""'
			else local allLabels = `" `allLabels' "unrestricted""'

		foreach var of varlist `stats_toprint' {
			local theLabel : var label `var'
			local theRownames = `"`theRownames' "`theLabel'""'
			local theLabel = substr("`theLabel'",1,30)
			local allLabels = `"`allLabels' "`theLabel'""'
			}

		mat stats_toprint = nullmat(stats_toprint) \ nullmat(blankrow) \ r(StatTotal)'

		}

* Output

	mat rownames stats_toprint = `allLabels'

	local statnames = subinstr("`stats'"," ",`"" ""',.)
	mat colnames stats_toprint = "`statnames'"

	xml_tab stats_toprint ///
		`using' ///
	,  	rnames(`theRownames') ///
		`options'

end
