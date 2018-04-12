** Labels Variables from Metadata

cap prog drop applyCodebook
prog def applyCodebook

syntax using, [varlab] [vallab] [rename] [recode]

preserve

import excel `using', first clear

* Prepare variable labels if specified.

	if "`varlab'" != "" {

		qui count
		forvalues i = 1/`r(N)' {
			local theVarname = varname[`i']
			local `theVarname'_lab = varlab[`i']
			}

		}

* Prepare renames if specified.

	if "`rename'" != "" {

		qui count
		forvalues i = 1/`r(N)' {
			local theVarname = varname[`i']
			local `theVarname'_ren = rename[`i']
			}

		}

* Prepare recodes if specified.

	if "`recode'" != "" {

		qui count
		forvalues i = 1/`r(N)' {
			local theVarname = varname[`i']
			local `theVarname'_rec = recode[`i']
			}

		}

* Prepare value labels if specified

if "`vallab'" != "" {

	* Prepare list of value labels needed.

		drop if `vallab' == ""

		cap duplicates drop `vallab', force

		count
			if `r(N)' == 1 {
				local theValueLabels = `vallab'[1]
				}
			else {
				forvalues i = 1/`r(N)' {
					local theNextValLab  = `vallab'[`i']
					local theValueLabels `theValueLabels' `theNextValLab'
					}
				}

	* Prepare list of values for each value label.

		import excel `using', first clear sheet(vallab)
			tempfile valuelabels
				save `valuelabels', replace

		foreach theValueLabel in `theValueLabels' {
			use `valuelabels', clear
			keep if name == "`theValueLabel'"
			local theLabelList "`theValueLabel'"
				count
				local n_vallabs = `r(N)'
				forvalues i = 1/`n_vallabs' {
					local theNextValue = value[`i']
					local theNextLabel = label[`i']
					local theLabelList_`theValueLabel' `" `theLabelList_`theValueLabel'' `theNextValue' "`theNextLabel'" "'
					}
			}

	* Prepare parallel lists of variables to be value-labeled and their corresponding value labels.

		import excel `using', first clear

			keep if `vallab' != ""
			local theValueLabelNames ""

			count
				if `r(N)' == 1 {
					local theVarNames	 = varname[1]
					local theValueLabelNames = `vallab'[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextVarname  = varname[`i']
						local theNextValLab   = `vallab'[`i']
						local theVarNames `theVarNames' `theNextVarname'
						local theValueLabelNames `theValueLabelNames' `theNextValLab'
						}
					}

	} // End vallab option.

* Apply to master.

restore

	foreach var of varlist * {
		if "``var'_lab'" != "" label var `var' "``var'_lab'"
		if "``var'_rec'" != "" recode    `var' ``var'_rec'
		}

	if "`vallab'" != "" {

		foreach theValueLabel in `theValueLabels' {
			label def `theValueLabel' `theLabelList_`theValueLabel'', replace
			}

			destring `theVarNames', replace

			local n_labels : word count `theValueLabelNames'
			if `n_labels' == 1 {
				label val `theVarNames' `theValueLabelNames'
				}
			else {
				forvalues i = 1/`n_labels' {
					local theNextVarname : word `i' of `theVarNames'
					local theNextValLab  : word `i' of `theValueLabelNames'
					label val `theNextVarname' `theNextValLab'
					}
				}

	foreach var of varlist * {
		if "``var'_ren'" != "" rename    `var' ``var'_ren'
		}

		} // End vallab option

di in red "Codebook applied!"

end
