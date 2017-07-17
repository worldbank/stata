* Call OpenIRT 
*
capture program drop openirt
program  openirt
  version 10.1
	preserve
	set more off
	* set eolchar unix
	local seed = round(uniform()*10000000)
	syntax, id(varname) item_prefix(name) save_item_parameters(string) save_trait_parameters(string) ///
		[samplesize(integer 2000) burnin(integer 1000) theta(varname) model(string) ///
		fixed_item_file(string)]

	isid `id'
	aorder `item_prefix'*
			
	* List selected items
	display as text "Selected items: " _continue
	foreach v of varlist `item_prefix'* {
		local itemid : subinstr local v "`item_prefix'" "", all
		local item_list `item_list' `itemid'
	}	
	display "`item_list'"
		
	* Write out response data
	display as text "Setting up response data..."
	tempfile response_file
	tempvar group
	
	if("`theta'" == "") {
		tempvar theta		
		qui gen `theta' = -9999				
	} 
	else {
		qui count if theta != .
		display as text "Number of fixed theta: `r(N)'"
	}
	
	* check item responses
	foreach v of varlist `item_prefix'* {
		qui sum `v'
		if(r(min)<0 | r(max) > 1) {
			display as error "`v': Response data must be coded 0/1."
			exit
		}
		if(r(mean)==0) {
			display as error "Warning: `v' is 100 percent 0, consider dropping item."
		}
		if(r(mean)==1) {
			display as error "Warning: `v' is 100 percent 1, consider dropping item."
		}
	}
	qui recode _all (.=-9999)
	qui gen `group' = 1
	tempfile openirt_tmp
	qui outsheet `id' `group' `theta' `item_prefix'* using `openirt_tmp', replace delim(" ") noquote nolabel nonames
	capture erase `response_file'
	filefilter `openirt_tmp' `response_file', from("\r\n") to("\n")
	capture erase `openirt_tmp'
	
	* Write out parameter data
	display as text "Setting up parameter data..."
	clear
	local num_items : list sizeof item_list
	qui set obs `num_items'
	qui gen id = .
	local i = 1
	foreach	id of local item_list {
		qui replace id = `id' in `i'
		local ++i
	}
	if("`model'" == "2PL") {
		gen type = 1
		display as text "Default model: Two parameter logistic (2PL)"
	}
	else {
		gen type = 2
		display as text "Default model: Three parameter logistic (3PL)"
	}
	gen numcat = 2
	gen a = -9999
	gen b = -9999
	gen c = -9999
	gen d1 = -9999
	gen d2 = -9999
	gen d3 = -9999
	gen d4 = -9999
	tempfile item_file
	sort id
	qui save `item_file', replace
	
	if("`fixed_item_file'" != "") {
		cap use `fixed_item_file', clear
		if(_rc != 0) {
			display as error "Could not open fixed item parameter file: `fixed_item_file'."
			exit
		}
		confirm variable id
		confirm variable type
		confirm variable a
		confirm variable b
		confirm variable c
		keep id type a b c
		sort id
		qui merge id using `item_file', update
		qui count if _m==1
		if(`r(N)' > 0) {
			display as error "Fixed item ids do not match response item ids."
			exit
		}
	}
	qui compress
	sort id
	isid id
	qui outsheet id type numcat a b c d1 d2 d3 d4 using `openirt_tmp', replace delim(" ") noquote nolabel nonames
	capture erase `item_file'
	filefilter `openirt_tmp' `item_file', from("\r\n") to("\n")
	capture erase `openirt_tmp'
	
	* Run estimation routine from shell
	qui findfile openirt.exe
	local execfile `r(fn)'
	local execfile : subinstr local execfile " " "\ ", all
	!chmod +x `execfile'
	
	qui findfile openirt.ini

	*local inifile : subinstr local inifile " " "\ ", all
	*display "`inifile'"
	tempfile inifile
	qui copy "`r(fn)'" `inifile', replace
	tempfile testout
	tempfile responseout
	capture erase `reponseout'
	capture erase `testout'
	local a `execfile' --config-file=`inifile' --test-file=`item_file' --response-file=`response_file' ///
    --test-outfile=`testout' --response-outfile=`responseout' ///
    --sample-size=`samplesize' --burnin=`burnin' --thin=1 --random-seed=`seed'
	* display "`a'"
	! `a'
	
	cap confirm file `responseout'
	if(_rc == 601) {
		display as error "OpenIRT could not estimate your model.  Please check the specified options and try again."
		exit
	}
	
	* Test parameters
	qui insheet using `testout', clear
	lab var id "Item ID"
	lab var type "Item Type"
	cap lab define itemtype 1"2PL" 2"3PL"
	lab val type itemtype
	lab var a_eap "Item discrimination (EAP)"
	lab var b_eap "Item difficulty (EAP)"
	lab var c_eap "Item difficulty (EAP)"
	forvalues i = 1/5 {
		lab var a_pv`i' "Item discrimination (Plausible value `i')"
		lab var b_pv`i' "Item difficulty (Plausible value `i')"
		lab var c_pv`i' "Item guessing (Plausible value `i')"		
	}
	qui compress
	qui recode _all (-9999=.)
	sort id
	display as text _newline "Saving item parameters..."
	save `save_item_parameters', replace

	qui insheet using `responseout', clear
	lab var id "Respondent ID"
	drop group
	lab var theta_eap "Theta (EAP)"
	forvalues i = 1/5 {
		lab var theta_pv`i' "Theta (Plausible value `i')"
	}
	lab var theta_mle "Theta (MLE)"
	lab var theta_mle_se "Theta standard error (MLE)"
	
	* some standard errors may be nan if likelihood very flat.  replace with missing
	qui destring _all, force replace
	qui recode _all (-9999=.)
	
	display as text _newline "Saving traits..."
	qui compress
	sort id
	save `save_trait_parameters', replace
	restore
	set more on
end

* net install /Users/tristanz/Data/OpenIRT/Stata/openirt, force
* sysuse naep_children, clear
* openirt, id(id) item_prefix(item) save_item_parameters(items) save_trait_parameters(traits)
