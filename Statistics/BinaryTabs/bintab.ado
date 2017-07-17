
* Binary proportions and population estimates

cap prog drop bintab
prog def bintab

	syntax ///
		anything 					/// Variables list
		[using] 					///	Output file for xlsx table
		[if] [in] 					/// As usual
		[pweight]					///	Weighting of observations
		, ///
		over(string asis) 			/// List of variables defining categorical groups. Values should be labeled.
		[svyset_opts(string asis)]	/// Options for svyset
		[continuous(string asis)]	// Continuous variables
		
		
qui {

* Setup

	unab anything : `anything'
	
	tempvar theType 
		egen `theType' = group(`over'), label
	
	preserve

	marksample touse
	keep if `touse' == 1
	
	tempvar weightvar
	if "`weight'" == "" gen `weightvar' = 1
	if "`weight'" == "" local weight "pweight = `weightvar'"
	
* Set up survey data weights

	svyset , clear
	svyset [`weight' `exp'] , `svyset_opts'
	
	tempfile data
		save `data', replace
		
* Get proportions

	clear
	tempfile proportions
		gen `theType' = .
		gen value = .
		save `proportions' , replace emptyok

	qui foreach var in `anything' {
		use `data', clear
				
		table `var' `theType' , row replace
		
		rename `var' value
		rename table1 var`var'
		
		
		merge 1:1 `theType' value using `proportions' , nogen
		save `proportions' , replace
		
		}
		
	foreach var in `anything' {
		replace var`var' = 0 if var`var' == .
		}
		
		drop if value == 0
		replace value = 0 if value == .
		label def yn 0 "All" 1 "Yes"
		label val value yn
		
		order `theType' value, first
		
		sort `theType' value 
		
		reshape long var, i(`theType' value) j(varname) string
		
		reshape wide var, i(`theType' varname) j(value)
			gen prop = string(var1) + "/" + string(var0)
			drop var0 var1
			
		rename `theType' temp
			decode temp, gen(`theType')
			drop temp
			
	save `proportions' , replace
	
* Get means and CIs

	clear
	tempfile results
		save `results', replace emptyok
		
		qui foreach var in `anything' {
		use `data', clear
		
		* Calculate weighted statistics
		
		local theLabel : var label `var'
		svy: mean `var' , over(`over')
			mat a = r(table)'
			
		* Compile
		
		clear
		svmat a , names(col)
			gen label = "`theLabel'"
			gen varname = "`var'"
			gen `theType' = ""
				local x = 1
				local overlist `"`e(over_labels)'"'
				foreach group in `overlist' {
					* local lab`x' = "`group'"
					replace `theType' = "`group'" in `x'
					* local theN = `x'
					local ++x
					}
		
		append using `results'
			save `results', replace
		
		}
		
		merge 1:1 `theType' varname using `proportions'
		
		gen mean = "0" + string(round(b,0.01))
			replace mean = mean + "0" if length(mean) < 4
			replace mean = "0" if mean == "000"
			
		gen lower = "0" + string(round(ll,0.01))
			replace lower = "00" if regexm(lower,"-")
			replace lower = lower + "0" if length(lower) < 4
			replace lower = "0" if lower == "000"
			replace lower = "-" if ll == .
			
		gen upper = "0" + string(round(ul,0.01))
			replace upper = "00" if regexm(upper,"-")
			replace upper = upper + "0" if length(upper) < 4
			replace upper = "0" if upper == "000"
			replace upper = "-" if ul == .
			
		gen ci = mean + " [" + lower + "Ð" + upper +"]"
			replace ci = mean + " [Ð]" if ll == .
			
		keep label `theType' prop ci
		
		tempfile binaries
			save `binaries' , replace
		
* Get continuous variable statistics

	if "`continuous'" != "" {

		clear
		tempfile results
			save `results', replace emptyok
			
			qui foreach var in `continuous' {
			use `data', clear
			
			* Calculate weighted statistics
			
			local theLabel : var label `var'
			svy: mean `var' , over(`over')
				mat a = r(table)'
				
			* Compile
			
			clear
			svmat a , names(col)
				gen label = "`theLabel'"
				gen varname = "`var'"
				gen `theType' = ""
					local x = 1
					local overlist `"`e(over_labels)'"'
					foreach group in `overlist' {
						* local lab`x' = "`group'"
						replace `theType' = "`group'" in `x'
						* local theN = `x'
						local ++x
						}
						
			
			append using `results'
				save `results', replace
			
			}
					
			gen prop = string(round(b,0.01))
				replace prop = "0" + prop if b > 0 & b < 1
				replace prop = prop + ".0" if strpos(prop,".") == 0
				replace prop = prop + "0" if (length(prop) - strpos(prop,".") < 2) & strpos(prop,".") != 0
				replace prop = "0.00" if prop == "00.00"
				
			gen lower = string(round(ll,0.01))
				replace lower = "0" + lower if ll > 0 & ll < 1
				replace lower = lower + ".0" if strpos(lower,".") == 0
				replace lower = lower + "0" if (length(lower) - strpos(lower,".") < 2) & strpos(lower,".") != 0
				replace lower = "0.00" if lower == "00.00"
				
			gen upper = string(round(ul,0.01))
				replace upper = "0" + upper if ul > 0 & ul < 1
				replace upper = upper + ".0" if strpos(upper,".") == 0
				replace upper = upper + "0" if (length(upper) - strpos(upper,".") < 2) & strpos(upper,".") != 0
				replace upper = "0.00" if upper == "00.00"
				
			gen ci = " [" + lower + "Ð" + upper +"]"
			replace ci = " [Ð]" if ll == .
			replace ci = subinstr(ci,"-.","-0.",.)
				
			keep label `theType' prop ci
			
			append using `binaries'	
			
	}
		
* Set up for export	
		
	encode `theType', gen(_j)
		drop `theType'
		
	levelsof _j, local (types)
		foreach type in `types' {
			local theLabel : label (_j) `type'
			local  lab`type' "`theLabel'"
			}
	
	reshape wide prop ci , i(label)
	
	rename ci* `theType'*ci
	rename prop* `theType'*prop
	
	local x = 1
	foreach group in `overlist' {
		local theVars = "`theVars' `theType'`x'"
		
		local ++x
		}
	
	reshape long `theVars', i(label) string
	
	replace _j = "A" if _j == "prop"
	replace _j = "B" if _j == "ci"
	
	sort label _j
	
	replace label = "" if  _j == "B"
	
	drop _j
	
	label var label "Variable"
			
	foreach i in `types' {
		label var `theType'`i' "`lab`i''"
		}
		
* Export

			
	export excel * `using' , first(varl) replace

}
		
end
	
* Have a lovely day!
