** Reshapes to long for with non-stub names

cap prog drop freeshape
prog def freeshape

syntax varlist , i(string asis) j(string asis)

qui { // To long form

	* Rename variables for reshape, recording name and label

		local x = 0 // Variable index

		foreach var of varlist `varlist' {
			local ++x
			rename `var' `j'`x'
			local `j'`x'_name "`var'"
			local `j'`x'_label : var label `j'`x'
			}

	* Reshape
			
		reshape long `j' , i(`i') j(`j'_index)
		
	* Names and labels
		
		label var `j'_index "Index #"
		rename `j' `j'_value
			label var `j'_value "Value"
		gen `j'_name = ""
			label var `j'_name "Name"
		gen `j'_label = ""
			label var `j'_label "Label"
		forvalues varindex = 1/`x' {
			replace `j'_name = "``j'`varindex'_name'" if `j'_index == `varindex'
			replace `j'_label = "``j'`varindex'_label'" if `j'_index == `varindex'
			}
			
	* Variable order
			
		order `i' `j'_index `j'_name `j'_label `j'_value, first
		
	}
	
end
