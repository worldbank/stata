* ATC lookup

cap prog drop atc_lookup
prog def atc_lookup

syntax anything

qui {

preserve

	keep `anything'

	duplicates drop
	keep if `anything' != ""

	qui levelsof `anything' , local(theCodes)
	
	clear
	
		tempfile theResults
		save `theResults' , replace emptyok
		
	local theN : word count `theCodes'
	
	local x = 1
	foreach code in `theCodes' {

		import delimited using "http://www.whocc.no/atc_ddd_index/?code=`code'&showdescription=yes" , clear

		keep v1
		keep if regexm(v1,"code=`code'") & !regexm(v1,"Hide text")

		gen `anything' = "`code'"

		local checklength = length("`code'")

		replace v1 = substr(v1,(strpos(v1,`"`code'">"')+`checklength'+2),strpos(v1,"</a>")-(strpos(v1,`"`code'">"')+`checklength'+2))
		
		compress, nocoalesce

		rename v1 generic_name
		
		local theGeneric = generic_name[1]
		
		noi di in red "`code' = `theGeneric' (`x'/`theN')"
		
		append using `theResults'
			save `theResults' , replace
			
		local ++x
		
		}

drop if regexm(generic_name,"<")
		
sort `anything' generic_name
duplicates drop `anything', force

save `theResults' , replace
		
restore

} // end qui

merge m:1 `anything' using `theResults' , nogen

label var generic_name "Generic Name"

replace generic_name = proper(generic_name)
replace generic_name = subinstr(generic_name,"And","and",.)

end

* Have a lovely day!
