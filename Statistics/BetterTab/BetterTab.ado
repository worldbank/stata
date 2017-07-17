** 

cap prog drop bettertab
prog def bettertab

syntax varlist [using] [if] [in], [round(real 1)] [DECimals(string asis)] [*]

preserve
marksample touse, novarlist
keep if `touse'

tempname matname

* Oneway tab
		
	local n_items = wordcount("`varlist'")

	if `n_items' == 1 {

		qui ta `varlist', matcell(`matname')
			local n = `r(N)'

		mat `matname' = `matname' \ `n'

		qui levelsof `varlist', local(levels)

		local n_levels = wordcount(`"`levels'"') + 1
		
		tempname pcts
		forvalues i = 1/`n_levels' {
			local theNextPCT = round(100*`matname'[`i',1] / `n',`round')
			mat `pcts' = nullmat(`pcts') \ ( `theNextPCT' )
			}
			
		mat `matname' = `matname' , `pcts'
		
		local theLabel : value label `varlist'
		foreach level in `levels' {
			cap local theNextLevel : label `theLabel' `level'
				if _rc != 0 {
					local theNextLevel = substr("`level'",1,32)
					}
			local theLevels = `" `theLevels' "`theNextLevel'" "'
			}
			
			mat rownames `matname' = `theLevels' "Total"
			mat colnames `matname' = "Count" "Percent"
			
			matlist `matname'
			mat `matname'_STARS = J(rowsof(`matname'),colsof(`matname'),0)
			
		}

* Twoway tab
			
	if `n_items' == 2 {

		tempname totals

		qui ta `varlist', matcell(`matname')
			mata : st_matrix("`totals'", rowsum(st_matrix("`matname'")))
			mat `matname' = `matname' , `totals'
			mata : st_matrix("`totals'", colsum(st_matrix("`matname'")))
			mat `matname' = `matname' \ `totals'
					
		local theRowVar : word 1 of `varlist'
			qui levelsof `theRowVar', local(levels)
			local theLabel : value label `theRowVar'
			foreach level in `levels' {
			cap local theNextLevel : label `theLabel' `level'
				if _rc != 0 {
					local theNextLevel = substr("`level'",1,32)
					}
			local theLevels = `" `theLevels' "`theNextLevel'" "'
			}
			
			mat rownames `matname' = `theLevels' "Total"
			local theLevels ""
			
		local theColVar : word 2 of `varlist'
			qui levelsof `theColVar', local(levels)
			local theLabel : value label `theColVar'
			foreach level in `levels' {
			cap local theNextLevel : label `theLabel' `level'
				if _rc != 0 {
					local theNextLevel = substr("`level'",1,32)
					}
			local theLevels = `" `theLevels' "`theNextLevel'" "'
			}
			
			mat colnames `matname' = `theLevels' "Total"
			
			matlist `matname'
			mat `matname'_STARS = J(rowsof(`matname'),colsof(`matname'),0)
			
		}
		
* xml_tab (using)

	if `"`using'"' != `""' {
	
		foreach word in `decimals' {
			
				local format NCRR`word'
						
				local theFormats `theFormats' `format'
				local ++x

			}

		mat `matname'_STARS = J(rowsof(`matname'),colsof(`matname'),0)
		
		xml_tab `matname' `using' , `options' stars(0) format((SCLB0) (SCCB0 `theFormats' NCRR0))
		
		}
	
end
	
