** Stores, expands, and outputs interaction terms

**** REQUIREMENTS ****

* Depends on xi3 and xml_tab


***** GETSTAT ****
* Stores and lists summary statistics from regression DEPVAR in ${xiStats}

cap prog drop getstat
prog def getstat

syntax anything , /// List of statistics
	[clear] // Clears stats list. Used automatically in -xisto- and can be used as long as the maximal list of statistics is ordered last.

	if "`clear'" == "clear" global xiStats "" // resets list of added statistics

	foreach stat in `anything' { // builds list of summary statistics from regression DEPVAR

		qui sum `e(depvar)' if e(sample)
			local theStat = "r(`stat')"
			local fullstat = `theStat'
		estadd scalar `stat' = `fullstat'
		
		global xiStats "${xiStats} stat_`stat'"
		
		}
		
end

***** XISTO ******
* Stores regression for translation into expanded format

cap prog drop xisto
prog def xisto

syntax anything /// Name of regression
	[if] ///
	, ///
	command(string asis) /// Command (regress, ivregress 2sls, etc)
	depvar(string asis) /// Dependent variable name
	rhs(string asis) /// Full RHS 
	[*] /// regopts
	[clear] // restarts regression accumulation
	
	if "`clear'" != "" global theVarlist ""
	if "`clear'" != "" global theCommands ""
	if "`clear'" != "" global theRegNames ""
	
	* Save the regression
	
		global theVarlist = `"${theVarlist} `rhs'"'
		global theCommands = `"${theCommands}  "`command' `depvar' `rhs' `if', `options'""'
		global theRegNames = `"${theRegNames} `anything'"'

end

***** XIGEN *****

cap prog drop xigen
prog def xigen , rclass

syntax anything , [prefix(string asis)]

qui xi3 `anything'

foreach var of varlist `_dta[__xi__Vars__To__Drop__]' {
	
	local theLogic : var label `var'
	
	local theLogic = subinstr("`theLogic'","&","",.)
	local theLogic = subinstr("`theLogic'","*"," ",.)
	
	local n_logic : word count `theLogic'
	
		local theNewLabel ""
		local and ""
		
		forvalues i = 1/`n_logic' {
		
			local theNextLogic : word `i' of `theLogic'
		
			if (strpos("`theNextLogic'","==") > 0) | (strpos("`theNextLogic'","=") > 0) { // Check for categorical
		
				local theNextLogic = subinstr("`theNextLogic'","=="," ",.)
				local theNextLogic = subinstr("`theNextLogic'","="," ",.)
				local theNextLogic = subinstr("`theNextLogic'","*"," ",.)
				local theNextLogic = subinstr("`theNextLogic'","("," ",.)
				local theNextLogic = subinstr("`theNextLogic'",")"," ",.)
				local theVar : word 1 of `theNextLogic'
				local theVal : word 2 of `theNextLogic'
				
				local theLab : label (`theVar') `theVal'
				
				local theNewLabel `theNewLabel' `and' `theLab'
					local and "&"
				
				}
			
			else { // for continuous
			
					local and "*"
					
					local theNextLogic = subinstr("`theNextLogic'","=="," ",.)
					local theNextLogic = subinstr("`theNextLogic'","="," ",.)
					local theNextLogic = subinstr("`theNextLogic'","*"," ",.)
					local theNextLogic = subinstr("`theNextLogic'","("," ",.)
					local theNextLogic = subinstr("`theNextLogic'",")"," ",.)
					local theVar : word 1 of `theNextLogic'
					local theVal : word 2 of `theNextLogic'
					
					local theLab : var label `theVar'
					
					local theNewLabel `theNewLabel' `and' `theLab'
						
					}
			}
		
			local theNewLabel = itrim(trim("`theNewLabel'"))
			local theNewLabel = regexr("`theNewLabel'","^\*","")
			local theNewLabel = regexr("`theNewLabel'","^&","")
			local theNewLabel = itrim(trim("`theNewLabel'"))
		label var `var' "`prefix' `theNewLabel'"
		
			local theNewName = subinstr("`var'","_I","",1)

			cap clonevar `theNewName' = `var'
				drop `var'
				
			local theVarlist "`theVarlist' `theNewName'"
			
	}
	
	codebook `theVarlist', compact
	return local xilist "`theVarlist'"
	
end

***** XITAB *****

* Wrapper for xml_tab

cap prog drop xitab
prog def xitab

syntax using, /// Location to output all saved regressions
	[stats(string asis)] /// Calls getstat
	[*] // xml_tab options
	
	preserve
	
	local theRawCommands = `"${theCommands}"'
	global theVarlist : list uniq global(theVarlist)
	
	* Build the list of interaction terms
	
		local theInteractions ""
		foreach item in ${theVarlist} {
			if (strpos("`item'","*") > 0 | strpos("`item'","i.") > 0) local theInteractions "`theInteractions' `item'"
			}
		
	* Extract the variables and clonevar them into 2-character dummy names for non-redundancy in xi3 (aa_-zz_)
	
		local theIvars = subinstr(subinstr("`theInteractions'","*"," ",.),"i.","",.)
		local theIvars : list uniq theIvars
		local theNewInteractions = "`theInteractions'"
			
			local x = 0
			local y = 1
			foreach var in `theIvars' {
				local ++x
				local theLetter2 : word `x' of `c(alpha)'
				local theLetter : word `y' of `c(alpha)'
				if `x' == 26 {
					local x = 0
					local ++y
					}
				
				clonevar `theLetter'`theLetter2'_ = `var'
				global theCommands = subinstr(`"${theCommands}"',"`var'","`theLetter'`theLetter2'_",.)
				local theNewInteractions = subinstr("`theNewInteractions'","`var'","`theLetter'`theLetter2'_",.)
				}
				
	* xi3 the dummy names and replace the interaction terms with the dummy xi3 outputs
		
		foreach interaction in `theNewInteractions' {
			qui xigen `interaction'
			global theCommands = subinstr(`"${theCommands}"',"`interaction'","`r(xilist)'",.)
			}
			
	* Run the regressions
		
		local theN : word count ${theCommands}
		forvalues i = 1/`theN' {
			local theRawReg : word `i' of `theRawCommands'
			local theReg : word `i' of ${theCommands}
			local theName : word `i' of ${theRegNames}
			
			di in red "`theName': `theRawReg'"
			`theReg'
			qui eststo `theName'
			
			if "`stats'" != "" {
				qui getstat `stats' , clear
				}
				
			}
	
	* Output
	
	xml_tab ${theRegNames} ///
		`using' ///
		,  `options' ///
		below c("Constant") stats(`stats' r2 N) lines(COL_NAMES 3 LAST_ROW 3 _cons 2) format((SCLB0) (SCCB0 NCRR2 NCRI2)) drop(o.*)
	
	restore
	
	* Clear the global macros
	
		global theVarlist ""
		global theCommands ""
		global theRegNames ""
	
end

***** DEMO ******
/*
	sysuse auto, clear
	
	xisto reg1 , clear 	command(ivregress 2sls) depvar(price) rhs( ( i.foreign*headroom = turn mpg turn*mpg ) gear_ratio) 
	xisto reg2 , 		command(regress) depvar(price) rhs(gear_ratio i.foreign*headroom i.foreign*trunk*displacement ) 
	
	xitab ///
		using "/users/bbdaniels/desktop/demo.xls" ///
		, replace stats(mean)


* Have a lovely day
