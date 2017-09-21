
** Imports JSON to data

cap prog drop json2dta
prog def json2dta

syntax 	anything				/// of the form: (newvarname1 newvarname2 = _varX _varY)
		[using/] 				/// API root
		[if] [in] , 			///
		[*] 					/// the list of arguments required by the json key : parses opt(varname) as opt=varval&
		[key(string asis)] 		/// API key if needed
		[markup(string asis)]	/// mark updated variables
		[DESCribe]				/// show possibilities in first record instead of looping
		[NOIsily]				//  show queries
		
		
* Setup

	qui {

	marksample touse

	tempvar id
		gen `id' = _n
		tostring `id' , replace
		
	tempfile old
		save `old', replace
		
	local letters = subinstr("`c(alpha)' `c(ALPHA)' , & = 1234567890"," ","",.)

* Parse out the variable list and create holder file

	local theOldVars = substr("`anything'",strpos("`anything'","(")+1,strpos("`anything'","=")-strpos("`anything'","(")-1)
	local theNewVars = substr("`anything'",strpos("`anything'","=")+1,strpos("`anything'",")")-strpos("`anything'","=")-1)
		local n_theOldVars : word count `theOldVars'
		local n_theNewVars : word count `theNewVars'
			while `n_theNewVars' < `n_theOldVars' {
				local theNewVars = "`theNewVars' `theNewVars'"
				local n_theNewVars : word count `theNewVars'
				}
	
	clear
		gen `id' = ""
	
	tempfile new
		save `new' , emptyok
		
	} // end qui
	
* Loop over obs

	qui use `old' if `touse', clear

	qui count
	local max = `r(N)'
	qui forvalues i = 1/`max' {
	
		di in red "Querying `i'/`max'..."
	
		use `old' if `touse', clear
	
		* Prepare arguments
	
		local theArgs ""
		
		foreach argument in `options' {
			local theNextArg = substr("`argument'",1,strpos("`argument'","(")-1)
			local theNextVar = substr("`argument'",strpos("`argument'","(")+1,strpos("`argument'",")")-strpos("`argument'","(")-1)
			local theNextVal = `theNextVar'[`i']
			
			local theArgs "`theArgs'`theNextArg'=`theNextVal'&"
			}
			
			local cleanArgs ""
			
			local length = length("`theArgs'")
				forvalues k = 1/`length' {
					local theNextChar = substr("`theArgs'",`k',1)
					if strpos("`letters'","`theNextChar'") local cleanArgs "`cleanArgs'`theNextChar'"
						else local cleanArgs "`cleanArgs'+"
					}
				
			forvalues x = 1/10 {
				local cleanArgs = subinstr("`cleanArgs'","++","+",.)
				}
				
			local cleanArgs = regexr("`cleanArgs'","[+][&]$","&")
				
		* Add key or remove trailing "&"
		
			if "`key'" != "" local cleanArgs = "`cleanArgs'key=`key'"
				else local cleanArgs = regexr("`cleanArgs'","\&$")

		* Get the JSON data

			if "`noisily'" != "" di in red `"`using'`cleanArgs'"'
			import delimited using `"`using'`cleanArgs'"', clear

			qui {
				replace v1 = subinstr(v1,",","",.)
				gen val = substr(v1,strpos(v1,":")+2,.) if regexm(v1,`"[a-zA-Z0-9\"]$"') 
					replace val = v1 if regexm(v1,`"\"$"') & val == ""
					replace val = subinstr(val,`"""',"",.)
				replace val = strtrim(val)
				replace v1 = strtrim(v1)
					replace v1 = subinstr(v1,val,"",.)
					replace v1 = subinstr(v1,`"""',"",.)
					replace v1 = regexr(v1,`" : $"',"")
				}
				
		* Clean it up
				
			qui gen varname = ""
			local thisPrefix = ""
			local thePrefix = ""
			local theLastPrefix = ""

			qui count
			qui forvalues k = 1/`r(N)' {
				local theText = v1[`k']
				if regexm(`"`theText'"',"\[$") | regexm(`"`theText'"',"\{$") {
					local thisPrefix = `"`theText'"'
						local thisPrefix = subinstr(`"`thisPrefix'"',`"""',"",.)
						local thisPrefix = subinstr(`"`thisPrefix'"',`":"',"",.)
						local thisPrefix = subinstr(`"`thisPrefix'"',`" "',"",.)
						local thisPrefix = subinstr(`"`thisPrefix'"',`"["',"",.)
						local thisPrefix = subinstr(`"`thisPrefix'"',`"{"',"",.)
						if "`thisPrefix'" != "" local thePrefix = `"`thePrefix'`thisPrefix'_"'
						if "`thisPrefix'" != "" local theLastPrefix = `"`thisPrefix'_"'

					}
				if regexm(`"`theText'"',"\]$") | regexm(`"`theText'"',"\}$") {
					local thePrefix = subinstr("`thePrefix'","`theLastPrefix'","",.)
					}
				if val != "" in `k' {
					local lowest = v1[`k']
					replace varname = "`thePrefix'`lowest'" in `k'
					}
				}
				
			qui replace varname = substr(varname,1,length(varname)-1) if regexm(varname,"_$")

			order varname val , first

			qui drop v1
			qui drop if varname == ""
			qui gen shortname = ""
			
			qui count
				forvalues j = 1/`r(N)' {
					local theOldname = varname[`j']
					local theNewname = ""
					local length = length("`theOldname'")
					local n = 0
					forvalues k = 1/`length' {
						local letter = substr("`theOldname'",`k',1)
						if "`letter'" == "_" local theNewname "`theNewname'`letter'"
						if "`letter'" == "_" local n = 0
						if "`letter'" != "_" local ++n
						if "`letter'" != "_" & `n' < 4 local theNewname "`theNewname'`letter'"
						}
					replace shortname = "`theNewname'" in `j'
					}
					
			order shortname , first

			sxpose, clear firstnames force
			
			foreach var of varlist * {
				local theLabel = `var'[1]
				local theValue = `var'[2]
				label var `var' "`theLabel' : `theValue'"
				}
				
			drop in 1
			
		* Describe option

		if "`describe'" != "" {
			de *
			-
			}
			
		* Grab the desired items

		if "`describe'" == "" {

			
			local nvars = 0
			foreach var of varlist * {
				local ++nvars
				if !regexm("`theOldVars'","`var'") drop `var'
				}
				
			local nvars : word count `theOldVars'
				
			forvalues j = 1/`nvars' {
				local theOld : word `j' of `theOldVars'
				local theNew : word `j' of `theNewVars'
				cap rename `theOld' `theNew'
				}
				
			gen `id' = `i'
			tostring *, replace
				
			append using `new'
				save `new' , replace
			
		}
		
	} // End loop over obs
	
		
	merge 1:1 `id' using `old'
	
	if "`markup'" != "" {
		cap gen `markup' = .
		replace `markup' = (_merge == 3)
		}
		
	drop _merge
	
end
