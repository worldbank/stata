
cap prog drop medlookup
prog def medlookup

syntax anything using [if] [in], i(string asis) [append] [import(string asis)] [correct(string asis)]

* Import option (assigns values to dataset)


if "`import'" != "" qui {

	preserve
	
		import excel `using', first clear
		reshape long generic_, i(brand) j(salt)
		keep if generic_ != ""
		rename generic_ generic
		
		tempfile generics
			save `generics', replace
			
		import excel `using', first clear sheet("Generic")
			replace treattype = "other" if treattype == ""
			merge 1:m generic using `generics', nogen keep(3)
			keep if treattype != ""
				
			keep treattype salt brand 
					
			reshape wide treattype , i(brand) j(salt)
			
			gen treattype = treattype1 + " " + treattype2 + " " + treattype3 
			
			rename brand `anything'
			
			keep `anything' treattype 
			
		save `generics', replace
			
	restore
	
	preserve
	
		marksample touse
			keep if `touse'
		
		reshape long `anything', i(`i') j(TEMPMEDVAR)
		
		keep if `anything' != ""
		
		keep `anything' `i' TEMPMEDVAR
		
		merge m:1 `anything' using `generics'
		
		keep if _m != 2
		drop _m
		
		if "`correct'" != "" {
			gen `import'_incorrect 	= 1
			gen `import'_correct 	= 0
			foreach drug in `correct' {
				replace `import'_correct 	= 1 if regexm(treattype,"`drug'")
				replace `import'_incorrect 	= 0 if regexm(treattype,"`drug'")
				}
				
			local keepcorrect `import'_correct `import'_incorrect
			}
		
		reshape wide `anything' treattype `keepcorrect' , i(`i') j(TEMPMEDVAR)
		
		if "`correct'" != "" {
			egen `import'_correct 	= rowtotal(`import'_correct?*)
			egen `import'_incorrect = rowtotal(`import'_incorrect?*)
			drop `import'_correct?* `import'_incorrect?*
			
			label var `import'_correct "Number of Correct Drugs"
			label var `import'_incorrect "Number of Unnecessary Drugs"
			}
		
		local x = 1
		foreach var of varlist treattype* {
			local thetreatments `"`thetreatments' `var' + " " + "'
			label var `var' "Treatment Type `x'"
			local ++x
			}
		
		gen `import' = `thetreatments' " "
			label var `import' "All Treatment Classes"
		
		rename treattype* (`import'*)
		keep `i' `import' `import'*
		
		save `generics', replace
		
	restore
	
		merge 1:1 `i' using `generics', nogen update
		
		if "`correct'" != "" { // Fill zeroes for no drugs.
			marksample touse
			replace `import'_correct = 0 if `import'_correct == . & `touse' == 1
			replace `import'_incorrect = 0 if `import'_incorrect == . & `touse' == 1
			}
	
} // End import option
else { // Non-import: creates medicine list file

	qui reshape long `anything' , i(`i') j(TEMPMEDVAR)

	qui replace `anything' = "UNIDENTIFIED" if regexm(`anything',"Unl")
	qui replace `anything' = "UNIDENTIFIED" if regexm(`anything',"Miss")

	qui levelsof `anything', local(theDrugs)

	local ndrugs : word count `theDrugs'

	preserve
	clear
	tempfile alldrugs
		save `alldrugs', emptyok

	local ndrug = 0
	qui foreach drugname in `theDrugs' {
	local ++ndrug
		
		di in red "(`ndrug'/`ndrugs') Searching for `drugname'..."
		
		local cleanname = subinstr("`drugname'","'","",.)
		
		forvalues x = 1/10 {
				local cleanname = regexr("`cleanname'","[\[\\]\\^\%\.\|\?\*\+\(\)]","")
				local cleanname = subinstr("`cleanname'"," ","%20",.)
				}

		import delimited using "https://www.1mg.com/search/all?name=`cleanname'", clear
		
		foreach var of varlist * {
			cap rename `var' v1
			}
		
		keep if strpos(v1,"Drugs Matching") > 0
		gen test = strpos(v1, `"<a href="/drugs/"') + 10
		gen test2 = "https://www.1mg.com/" + substr(v1,test,.)
		gen test3 = substr(test2,1,strpos(test2,`"""')-1)

		local theURL = test3[1]

		cap import delimited using "`theURL'", clear delim("keywords", asstring)

			if _rc == 0 {
			
				split v1, p(`""salt-name">"')
				rename v1* generic_*
				
				forvalues i=2/4 {
					cap gen generic_`i' = ""
					}
					
				keep generic_2 generic_3 generic_4
					rename (generic_2 generic_3 generic_4)(generic_1 generic_2 generic_3)
					foreach var of varlist generic_1 generic_2 generic_3 {
						replace `var' = substr(`var',1,strpos(`var',"(")-1)
						}
						
					gen `anything' = "`drugname'"
					keep in 1
					append using `alldrugs'
						save `alldrugs', replace
				}

		}
		
	clear
		set obs `ndrugs'
		gen `anything' = ""
		qui forvalues i = 1/`ndrugs' {
			local theNextDrug : word `i' of `theDrugs'
			replace `anything' = "`theNextDrug'" in `i'
			}
			
		tempfile all
			save `all', replace
		
	use `alldrugs', clear
		qui merge 1:1 `anything' using `all', nogen
		sort `anything'
		rename `anything' brand
		
		* Append option
		
		if "`append'" == "append" {
			tempfile a
				save `a', replace
				
			* Brands	
				import excel `using', first clear allstring
				tempfile appendDrugs
					save `appendDrugs', replace
			* Generics
				import excel `using', first clear sheet("Generic") allstring
				tempfile appendGenerics
					save `appendGenerics', replace
				
			use `a', clear
				merge 1:1 brand using `appendDrugs', nogen update replace
			} // End Append
		
		export excel brand generic* `using', replace sheet("Brand") first(var)
		
		gen tempid = _n
		qui reshape long generic_, i(tempid) j(drug)
			rename generic_ generic
			keep generic
			drop if generic == ""
			sort generic
			duplicates drop generic, force
			gen treattype = ""
			
			recast str50  generic
			
			merge m:1 generic using `appendGenerics', nogen update replace		
			
			export excel `using', sheetreplace sheet("Generic") first(var)
			
	} // End prep (non-import) option
	
end
