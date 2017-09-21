** Table-out


cap prog drop tableout
prog def tableout

syntax anything [using] [if] [in], row(string asis) COLumn(string asis) [*]

preserve

cap mat drop theResults

marksample touse
	keep if `touse'

	table `row' `column' , c(`anything') replace

	qui levelsof `row' , local(rowlevels)
		local nRowLevels : word count `rowlevels'
	qui levelsof `column' , local(collevels)
		local nColLevels : word count `collevels'

	mat theResults = J(`nRowLevels',`nColLevels',.)
	
	local i = 0
	foreach rowlevel in `rowlevels' {
		local ++ i
		local j = 0
		foreach collevel in `collevels' {
			local ++j
			qui su table1 if `row' == `rowlevel' & `column' == `collevel'
			local theStat = r(mean)
			mat theResults[`i',`j'] = `theStat'
			}
		}

	foreach i in `rowlevels' {
		local theRowName : label (`row') `i'
		local theRowName = substr("`theRowName'",1,30)
		local theRowNames `"`theRowNames' "`theRowName'""'
		}
		
	foreach j in `collevels' {
		local theColName : label (`column') `j'
		local theColName = substr("`theColName'",1,30)
		local theColNames `"`theColNames' "`theColName'""'
		}
	
	mat rownames theResults = `theRowNames'
	mat colnames theResults = `theColNames'

	xml_tab theResults `using' , `options'

end

* Have a lovely day!

