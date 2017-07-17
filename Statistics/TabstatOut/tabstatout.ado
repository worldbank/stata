** Collapses summary statistics and outsheet

cap prog drop tabstatout
prog def tabstatout

syntax anything [using] [if] [in] [fweight  aweight  pweight  iweight] , by(string asis) [TRANSpose] [DECimals(string asis)] [n] [sd] [se] [Total] [*]

preserve
marksample touse
keep if `touse'

* Check matodd

	tempvar theByVar
	egen `theByVar' = group(`by') , label
	local by `theByVar'

	* qui ssc install matodd

* Transpose option

if "`transpose'" != "" {
	local theBy "row"
	local theVar "col"
	local noTranspose "cap -"
	local snip "[1... , 2...]"
	}
else {
	local theBy "col"
	local theVar "row"
	local snip "[2... , 1...]"
	}

* N option

if "`n'" == "n" {
	tempvar n
	gen `n' = 1
	local ncollapse (sum) `n'
	label var `n' "N"
	}
	
* Total option

	if "`total'" == "total" {
		tempfile all
			save `all', replace
		tempname new
		append using `all' , gen(`new')
		}

* Get categories of by-var

	qui levelsof `by' , local(levels)
	
	local theLabelList ""
		foreach level in `levels' {
			local theValLab : label (`by') `level'
			local theLabelList `" `theLabelList' "`theValLab'" "'
			local max = `level' + 1
			}
			
	if "`total'" == "total" {
		local theLabelList `" `theLabelList' "Total" "'
		replace `by' = `max' if `new' == 1 & `by' != .
		}
			
* Collapse and relabel

	if "`weight'" != "" {
	local theWeight [`weight' `exp']
	}

	foreach item in `anything' `ncollapse' {
		if strpos("`item'",")") == 0 {
			local theVarlist `theVarlist' `item'
			}
		}
		
	foreach var of varlist `theVarlist' {
		local `var'L : var label `var'
		}
		
* Standard Errors option

	if "`sd'" == "sd" {
	tempfile all
		save `all', replace
		local sdLabel `"" ""'
		local sdFormat NCRI2
		
		collapse (sd) `theVarlist' `theWeight', by(`by') fast
		
		cap drop `n'
		
		foreach var of varlist * {
			if "`var'" != "`by'" {
				label var `var' "-"
				rename `var' `var'_sd
				local order `order' `var' `var'_sd
				}
			}
		
		tempfile SDs
			save `SDs', replace
			
		use `all', clear
		
	}
	if "`se'" == "se" {
	tempfile all
		save `all', replace
		local sdLabel `"" ""'
		local sdFormat NCRI2
		
		collapse (sem) `theVarlist' `theWeight', by(`by') fast
		
		cap drop `n'
		
		foreach var of varlist * {
			if "`var'" != "`by'" {
				label var `var' "-"
				rename `var' `var'_sd
				local order `order' `var' `var'_sd
				}
			}
		
		tempfile SDs
			save `SDs', replace
			
		use `all', clear
		
	}
	
		
* Collapse
		
	collapse `anything' `ncollapse' `theWeight', by(`by') fast
		keep if `by' != .

	foreach var of varlist `theVarlist' {
		label var `var' "``var'L'"
		}
		
* Create matrix from data

	if "`sd'" == "sd" {
		qui merge 1:1 `by' using `SDs', nogen
		order `by' `order'
		}
	if "`se'" == "se" {
		qui merge 1:1 `by' using `SDs', nogen
		order `by' `order'
		}
	

	tempname a b
	
	foreach var of varlist * {
		qui sum `var'
		if `r(N)' == 0 drop `var'
		}

	mkmat * , mat(`a')
	mat `b' = `a' 
	`noTranspose' mat `b' = `a''
	
	mat `theBy'names `b' = `theLabelList'
	
	drop `by'
	
	foreach var of varlist * {
		if "`var'" != "`by'" {
			local theNextLabel : var label `var'
				local theNextLabel = subinstr("`theNextLabel'",":","",.)
			local theRowNames `" `theRowNames' "`theNextLabel'" "'
			}
		}
		
	mat `b' = `b'`snip'
		
	mat `theVar'names `b' = `theRowNames'
	
	matlist `b'	
	
* Write

	local x = 0
	local numdels = 0

	if `"`using'"' != `""' {
	
		foreach word in `decimals' {
			
			if regexm("`word'","x") {
				local form1 = regexr("`word'","x","")
				local format NCRR`form1'
				local delrow = 2*(`x'+1) - `numdels'
				matdelrc `b', row(`delrow')
					local ++ numdels
				}
			else {
				local format NCRR`word' `sdFormat'
				}
								
				local theFormats `theFormats' `format'
				local ++x

			}

		mat `b'_STARS = J(rowsof(`b'),colsof(`b'),0)
		
		xml_tab `b' `using' , `options' stars(0) format((SCLB0) (SCCB0 `theFormats' NCRR0))
		
		}
		
end
