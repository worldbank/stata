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

***** XIREG ******
* Stores regression for translation into expanded format

cap prog drop xiReg
prog def xiReg

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

***** xiGen *****

cap prog drop xiGen
prog def xiGen , rclass

syntax anything , [prefix(string asis)]

qui xi3 `anything'
local conVars = subinstr("`anything'","*"," ",.)
	foreach word in `conVars' {
		if regexm("`word'","i.") local conVars = subinstr("`conVars'","`word'","",.)
		}

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
	return local xilist "`theVarlist' `conVars'"

end

***** XIOUT *****

* Wrapper for xml_tab

cap prog drop xiOut
prog def xiOut

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

		global theCommands = subinstr(`"${theCommands}"',"*"," * ",.)
		global theCommands = subinstr(`"${theCommands}"',"i."," i. ",.)

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

		global theCommands = subinstr(`"${theCommands}"'," * ","*",.)
		global theCommands = subinstr(`"${theCommands}"'," i. ","i.",.)

	* xi3 the dummy names and replace the interaction terms with the dummy xi3 outputs

		foreach interaction in `theNewInteractions' {
			qui xiGen `interaction'
			global theCommands = subinstr(`"${theCommands}"',"`interaction'","`r(xilist)'",.)
			}

	* Run the regressions

		local theN : word count ${theCommands}
		forvalues i = 1/`theN' {
			local theRawReg : word `i' of `theRawCommands'
			local theReg : word `i' of ${theCommands}
			local theName : word `i' of ${theRegNames}

			di in red "`theName': `theRawReg'"
			local theReg : list uniq theReg
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

***** XI3 *******

*! version 1.1a, changed version control, always runs command using current stata version 3/23/09
*! version 1.1, omit missing from some coding schemes, 6/30/03
*! version 1.0 (April 7, 2003)
*! Modified codings to permit time series operators
*! Replace f with a
*! Replace d with e
*! Replace s with g
*! removed experimental message
*! problems
*!   does not handle @ for 3 vars
*!   freaks out of length of terms exceeds 32
* Michael Mitchell & Phil Ender
* Academic Technology Services
* UCLA
* mnm@@ucla.edu ender@@ucla.edu

capture program drop xi3
program define xi3
  version 7

  * abort if less than version 7
  if _caller() < 7 {
    display as error "Requires version 7"
    exit
  }

  * display as text "This is an experimental version of xi3"
  * display as text "Please view results with some caution"

  * get rid of prior macros from xi3
  macro drop xi3_*
  macro drop S_1

  * set to 1 if you want debugging info
  global xi3_debug "0"


  * terms in equation as macro variables
  global xi3_terms

  * global abbrevlen
  global ablen 2

  * deal with time series variables
  capture _ts timevar panvar, panel
  if _rc==0 {
    local sorder : sortedby
  }

  * determine format of xi3 call
  gettoken first second : 0, parse(":")
  if "`second'" != "" {
    if "`first'" != ":" {
      * xi, pre() :
      local 0 `first'
      syntax [, PREfix(string)]
      if length("`prefix'") > 4 {
        dis as err "invalid stub name, name too long ( >4 )"
        exit 198
      }
      gettoken colon 0: second, parse(" :")
    }
    else {
      * xi :
      local 0 `second'
      local prefix "_I"
    }
    local xeq "yes"
  }
  else {
    * xi items
    gettoken comma : 0, parse(" ,")
    if "`comma'" == "," {
      * xi, pre() i.var
      gettoken comma 0 : 0, parse(" ,")
      gettoken prefix rest: 0, parse(" ")
      local 0  ",`prefix'"
      syntax [, PREfix(string)]
      if length("`prefix'") > 4 {
        dis as err "invalid stub name, name too long ( >4 )"
        exit 198
      }
      local 0 "`rest'"
    }
    else {
      * xi i.var
      local prefix "_I"
    }
  }
  global X__pre "`prefix'"

  * drop variables called from last xi command
  local todrop : char _dta[__xi__Vars__To__Drop__]
  foreach itemtodrop of local todrop {
    capture drop `itemtodrop'
  }

  * clear out placeholder for vars we will create
  char _dta[__xi__Vars__To__Drop__]

  * terms we will create that are i. and are continuous
  global X__in
  global X__cont

  * track interaction terms we constructed
  global X__intterms



  * parse the command
  local orig `0'
  gettoken t 0 : 0, parse(`" :,"()[]="') quotes
  while `"`t'"' != "" {

    if index(upper(`"`t'"'),"S.") {
      display as text "Please note that version 1.0+ changed the s. prefix to g."
      display as text "  see help xi3 for more information"
    }
    if index(upper(`"`t'"'),"D.") {
      display as text "Please note that version 1.0+ changed the d. prefix to e."
      display as text "  see help xi3 for more information"
    }
    if index(upper(`"`t'"'),"F.") {
      display as text "Please note that version 1.0+ changed the f. prefix to a."
      display as text "  see help xi3 for more information"
    }


    * if it is an interaction, or has a prefix
    if index(`"`t'"',"*") | index(`"`t'"',"|") | index(`"`t'"',"@") | index(upper(`"`t'"'),"I.") | index(upper(`"`t'"'),"G.") | index(upper(`"`t'"'),"E.") | index(upper(`"`t'"'),"H.") | index(upper(`"`t'"'),"R.") | index(upper(`"`t'"'),"O.") | index(upper(`"`t'"'),"A.") | index(upper(`"`t'"'),"B.") | index(upper(`"`t'"'),"C.") | index(upper(`"`t'"'),"U.") {
      myparse `t'

      * modify "orig", substituting in new terms, which will be executed later
      if `"$S_1"' != "." {
        local orig : subinstr local orig `"`t'"' `"$S_1"'
      }
      else {
        local orig : subinstr local orig `"`t'"' ""
      }
      if  ("$xi3_debug"=="1") { display "orig is `orig'" }
    }
    gettoken t 0 : 0, parse(`" :,"()[]="') quotes
  }
  if "`sorder'" != "" { sort `sorder' }

  * clear global variables
  * global X__in
  * global X__cont
  * global X__pre

  * execute command if used xi:
  if "`xeq'"=="yes" {
    * 1.1a 3/23/09 : run using current stata version
    version `c(stata_version)' : `orig'
  }
end


capture program drop myparse
program define myparse
  version 7
  if ("$xi3_debug"=="1") { display "Calling myparse with `*'" }

  local vars
  local toks

  * This expression will be replaced with myS_1
  local myS_1

  * take input and parse it into a list of variable names and tokens
  * vars : list of variables, e.g. read i.female
  * toks : list of tokens connecting them, e.g. *
  tokenize `0', parse(*@)
  local i 1
  while "``i''"!="" {
    local word = "``i''"
    if ("`word'" == "*") | ("`word'" == "@") {
      local toks "`toks' `word'"
    }
    else {
      * unabbreviate var right here
      if (substr("`word'",2,1) == ".") {
        local part1 = substr("`word'",1,2)
        local part2 = substr("`word'",3,.)
        unab part2unab : `part2' , min(1) max(1)
        local word2 "`part1'`part2unab'"
      }
      else {
        unab word2 : `word' , min(1) max(1)
      }
      if ("$xi3_debug"=="1") { display "unabbreviated `word' is `word2'" }
      local vars "`vars' `word2'"
    }
    local i=`i'+1
  }
  local varcnt : word count `vars'
  local tokcnt : word count `toks'

  * check to see that tokens are OK
  local toknum = 0
  local hasat = 0
  foreach tokname of local toks {
    local toknum = `toknum' + 1
    if ("`tokname'" == "@") {
      if (`toknum' < `tokcnt') {
        display as error "Error in term `0', @ can only be last in list"
        exit 999
      }
      else {
        local hasat = 1
      }
    }
  }

  if ("$xi3_debug"=="1") { display "There are `varcnt' vars: `vars'" }
  if ("$xi3_debug"=="1") { display "There are `tokcnt' toks: `toks' and hasat is `hasat'" }

  local intprefix
  local varnum 0

  * work through coding each of the variables
  * make
  *   varX : variable name for variable X
  *   varabrX: abbreviated variable (for interaction) for variable X
  *   varcatX: 0/1, 1 if variable X is categorical
  foreach varname of local vars {
    if ("$xi3_debug"=="1") { display "my varname is `varname'" }
    local varnum = `varnum' + 1

    if ("$xi3_debug"=="1") { display as input "working on `varname'" }
    #delimit ;
    if index(upper(`"`varname'"'),"I.") |
       index(upper(`"`varname'"'),"G.") |
       index(upper(`"`varname'"'),"E.") |
       index(upper(`"`varname'"'),"H.") |
       index(upper(`"`varname'"'),"R.") |
       index(upper(`"`varname'"'),"O.") |
       index(upper(`"`varname'"'),"A.") |
       index(upper(`"`varname'"'),"B.") |
       index(upper(`"`varname'"'),"C.") |
       index(upper(`"`varname'"'),"U.") {  ;
      #delimit cr

      local var`varnum' = substr("`varname'",3,.)
      local varabr`varnum' = substr("`varname'",3,$ablen)
      local varcat`varnum' = 1

      if ("$xi3_debug"=="1") { display as input "coding `varname'" }

      * code the categorical variable
      xi_ei `varname'

      * if S_1 indicates variable already exists, then dont add it to S_1
      if (`"$S_1"' != ".") {
        * if you dont have an @, or if you do have an @ and it has more than 2, or it is 2 and it is not the first
        * display "check hasat is `hasat' and varcnt is `varcnt' and varname is `varname' and var1 is `var1'"
        if (`hasat'==0) | (`hasat'==1 & ((`varcnt'>2) | (`varcnt'==2 & substr("`varname'",3,.)!="`var1'")) ) {
          local myS_1 "`myS_1' $S_1"
        }
      }
    }
    else {
      local var`varnum' = "`varname'"
      local varabr`varnum' = substr("`varname'",1,$ablen)
      local varcat`varnum' = 0

      * if already have the variable, dont add it to S_1
      local alreadyhave = 0
      foreach xcont of global X__cont {
        if "`xcont'"=="`varname'" {
          local alreadyhave = 1
        }
      }

      if `alreadyhave' == 0 {
        if (`hasat'==0) | (`hasat'==1 & ((`varcnt'>2) | (`varcnt'==2 & "`varname'" != "`var1'")) ) {
          local myS_1 "`myS_1' `varname'"
        }
      }

      * add variable to X__cont (to see if it is already coded next time)
      global X__cont "$X__cont `varname'"

      * save this as well, for postgr3
      global xi3_`varname' `varname'

    }
    if ("$xi3_debug"=="1") { display "myS_1 is now `myS_1'" }
  }

  * show results if debugging
  foreach varnum of numlist 1/`varcnt' {
    if ("$xi3_debug"=="1") { display "var number `varnum' is named `var`varnum'' abbrev is `varabr`varnum'' categ is `varcat`varnum'' and contains ${xi3_`var`varnum''}" }
  }

  if (`hasat'==1) & (`varcat`varcnt''==0) {
    display as error "Error in term `0', if you use @, the last term must be categorical"
    exit 999
  }

  * make 2 way interactions with *
  if (`varcnt' >= 2) & (`hasat'==0) {
    * loop i 1 to number of terms in this interaction
    foreach i of numlist 1/`varcnt' {
      * loop j 1 to number of terms in this interaction
      foreach j of numlist 1/`varcnt' {
        * only do each term once, when i is less than j
        if (`i' < `j')  {
          * only process this interaction if it has not already been processed before
          if ("$xi3_debug"=="1") { display "!!!!!!!!seeing if `var`i'' by `var`j'' as ${xi3_`var`i''X`var`j''} already exists" }
          if ("${xi3_`var`i''X`var`j''}" != "") {
            * display "`var`i'' by `var`j'' already exists"
          }
          else {

            checklen "xi3_`var`i''X`var`j''"
            global xi3_`var`i''X`var`j''

            * check to see if the abbreviated form of the interaction has been used

            * get prefixes for term 1 and 2
            local prenum

            * increment "prenum" until unique
            capture unab dupint : $X__pre`prenum'`varabr`i''*X`varabr`j''*
            while "`dupint'" != "" {
              local prenum = `prenum' + 1
              local dupint
              capture unab dupint : $X__pre`prenum'`varabr`i''*X`varabr`j''*
            }

            * cycle through all of the terms for vari
            foreach macroi of global xi3_`var`i'' {
              local suffi
              local lbli "`var`i''"
              if `varcat`i'' {
                local posi = length("`macroi'") - index(reverse("`macroi'"),"_") + 2
                local suffi = substr("`macroi'",`posi',.)
                local lbli : variable label `macroi'
                if ("$xi3_debug"=="1") { display "macroi is `macroi' and posi is `posi' and suffi is `suffi'" }
              }
              * cycle through all of the terms of varj
              foreach macroj of global xi3_`var`j'' {
                local suffj
                local lblj "`var`j''"
                if `varcat`j'' {
                  local posj = length("`macroj'")-index(reverse("`macroj'"),"_")+ 2
                  local suffj = substr("`macroj'",`posj',.)
                  local lblj : variable label `macroj'
                }

                * this is the target variable
                local targvar $X__pre`prenum'`varabr`i''`suffi'X`varabr`j''`suffj'

                * add this term to the macro
                global xi3_`var`i''X`var`j'' ${xi3_`var`i''X`var`j''}  `targvar'
                * make the variable
                generate `targvar' = `macroi' * `macroj'
                * label the variable
                label var `targvar' "`lbli'*`lblj'"
                * add to list of variables
                local myS_1 "`myS_1' `targvar'"
                char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `targvar'
                if ("$xi3_debug"=="1") { display "char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `targvar'" }
              }
            }
          }
        }
      }
    }
  }

  * make 3 way interactions with *
  if (`varcnt' >= 3) & (`hasat'==0) {
    foreach i of numlist 1/`varcnt' {
      foreach j of numlist 1/`varcnt' {
        foreach k of numlist 1/`varcnt' {
          if (`i' < `j') & (`j' < `k') {
            checklen "xi3_`var`i''X`var`j''X`var`k''"
            global xi3_`var`i''X`var`j''X`var`k''

            local prenum
            capture unab dupint : $X__pre`prenum'`varabr`i''*X`varabr`j''*X`varabr`k''*
            while "`dupint'" != "" {
              local prenum = `prenum' + 1
              local dupint
              capture unab dupint : $X__pre`prenum'`varabr`i''*X`varabr`j''*X`varabr`k''*
            }

            foreach macroi of global xi3_`var`i'' {
              local suffi
              local lbli "`var`i''"
              if `varcat`i'' {
                local posi = length("`macroi'") - index(reverse("`macroi'"),"_") + 2
                local suffi = substr("`macroi'",`posi',.)
                local lbli : variable label `macroi'
              }
              foreach macroj of global xi3_`var`j'' {
               local suffj
                local lblj "`var`j''"
                if `varcat`j'' {
                  local posj = length("`macroj'")-index(reverse("`macroj'"),"_")+ 2
                  local suffj = substr("`macroj'",`posj',.)
                  local lblj : variable label `macroj'
                }

                foreach macrok of global xi3_`var`k'' {
                  local suffk
                  local lblk "`var`k''"
                  if `varcat`k'' {
                    local posk = length("`macrok'")-index(reverse("`macrok'"),"_")+ 2
                    local suffk = substr("`macrok'",`posk',.)
                    local lblk : variable label `macrok'
                  }

                  local targvar $X__pre`prenum'`varabr`i''`suffi'X`varabr`j''`suffj'X`varabr`k''`suffk'

                  global xi3_`var`i''X`var`j''X`var`k'' ${xi3_`var`i''X`var`j''X`var`k''} `targvar'
                  generate `targvar' = `macroi' * `macroj' * `macrok'
                  label var `targvar' "`lbli'*`lblj' * `lblk'"
                  local myS_1 "`myS_1' `targvar'"
                  char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `targvar'
                }
              }
            }
          }
        }
      }
    }
  }

  * make 2 way interactions with AT
  if (`varcnt' >= 2) & (`hasat'==1) {

    tempvar withing
    egen `withing' = group(`var2')
    quietly summarize `withing'
    local ng = r(max)

    * loop i 1 to number of terms in this interaction
    foreach i of numlist 1/`varcnt' {
      * loop j 1 to number of terms in this interaction
      foreach j of numlist 1/`varcnt' {
        * only do each term once, when i is less than j
        if (`i' < `j')  {
          * only process this interaction if it has not already been processed before
          if ("${xi3_`var`i''W`var`j''}" != "") {
            * display "`var`i'' W `var`j'' already exists"
          }
          else {
            * clear macro variable for holding contents of the interaction term
            checklen "xi3_`var`i''W`var`j''"
            global xi3_`var`i''W`var`j''

            * check to see if the abbreviated form of the interaction has been used

            * get prefixes for term 1 and 2
            local prenum

            * increment "prenum" until unique
            capture unab dupint : $X__pre`prenum'`varabr`i''*W`varabr`j''*
            while "`dupint'" != "" {
              local prenum = `prenum' + 1
              local dupint
              capture unab dupint : $X__pre`prenum'`varabr`i''*W`varabr`j''*
            }
            * cycle through all of the terms for vari
            foreach macroi of global xi3_`var`i'' {
              local suffi
              local lbli "`var`i''"
              if `varcat`i'' {
                local posi = length("`macroi'") - index(reverse("`macroi'"),"_") + 2
                local suffi = substr("`macroi'",`posi',.)
                local lbli : variable label `macroi'
                if ("$xi3_debug"=="1") { display "macroi is `macroi' and posi is `posi' and suffi is `suffi'" }
              }
              * cycle through all levels of var2
              foreach group of numlist 1/`ng' {
                * get the group for b
                tempvar on
                qui gen `on' = .
                qui replace `on'=cond(`withing'==`group',_n,`on'[_n-1])
                local withinv = `var2'[`on'[_N]]

                local suffj = `withinv'
                local lblj : variable label `var2'

                * this is the target variable
                local targvar $X__pre`prenum'`varabr`i''`suffi'W`varabr`j''`suffj'

                * add this term to the macro
                global xi3_`var`i''W`var`j'' ${xi3_`var`i''W`var`j''}  `targvar'

                * make the variable
                quietly generate double `targvar' = 0
                quietly replace `targvar' = `macroi' if `withing'==`group'

                * label the variable
                label var `targvar' "`lbli' @ `var2'==`withinv'"

                * add to list of variables
                local myS_1 "`myS_1' `targvar'"
                char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `targvar'
              }
            }
          }
        }
      }
    }
  }


  * make 3 way interactions with AT
  if (`varcnt' >= 3) & (`hasat'==1) {
    display as error "3 way interactions with @ dont work yet"
    exit 999
  }


  if ("$xi3_debug"=="1") { display "AT END, myS_1 is `myS_1'" }

  * at the end, make the substitution for S_1
  if "`myS_1'" == "" {
    global S_1 "."
  }
  else {
    global S_1 "`myS_1'"
  }
end

capture program drop xi_ei
program define xi_ei /* I.<name> */
  args orig

  if upper(substr(`"`orig'"',1,2)) == "I." { local contype "ind" }
  if upper(substr(`"`orig'"',1,2)) == "C." { local contype "cen" }
  if upper(substr(`"`orig'"',1,2)) == "G." { local contype "sim" }
  if upper(substr(`"`orig'"',1,2)) == "E." { local contype "dev" }
  if upper(substr(`"`orig'"',1,2)) == "H." { local contype "hel" }
  if upper(substr(`"`orig'"',1,2)) == "R." { local contype "rev" }
  if upper(substr(`"`orig'"',1,2)) == "O." { local contype "orth" }
  if upper(substr(`"`orig'"',1,2)) == "A." { local contype "fdif" }
  if upper(substr(`"`orig'"',1,2)) == "B." { local contype "bdif" }
  if upper(substr(`"`orig'"',1,2)) == "U." { local contype "user" }

  tempvar g on
  local vn = substr(`"`orig'"',3,.)
  unab vn: `vn', max(1)

  * if x.varname is already included, dont code it again ;
  if ("$xi3_debug"=="1") { display "seeing if we should code `vn' if it is in $X__in" }
  if subinword("$X__in","`vn'"," ",1) != "$X__in" {
    global S_1
    if ("$xi3_debug"=="1") { display "`vn' already coded since part of $X__in, wont code it again!" }
    exit
  }

  if ("$xi3_debug"=="1") { display "WE ARE CODING `vn'" }


  *11. initialize macro xi3_varname
  global xi3_`vn' " "

  qui egen `g' = group(`vn')
  qui summ `g'
  local ng = r(max)
  local lowcode 1
  local topcode `ng'
  local useuser 0
  cap confirm string var `vn'
  if _rc {
    local isnumb "yes"
    cap assert `vn'==int(`vn') & `vn'<1e9 & `vn'>=0 if `vn' < .
    *** If orthpoly never, always use 1,2,3,4 coding, so added (& "`contype'" != "orth")  below
    if _rc==0 & ("`contype'" != "orth") {
      qui summ `vn'
      local lowcode = r(min)
      local topcode = r(max)
      local useuser 1
    }
  }

  xi_mkun `vn'
  local svn "$S_1"

  /* user char vn[omit] containing <value> */
	local omis : char `vn'[omit]
	if "`omis'" != "" {
		tempvar umark
		if "`isnumb'"=="yes" {
			capture confirm number `omis'
			if _rc {
				di as err /*
			*/" characteristic `vn'[omit] (`omis') invalid;" /*
			*/ _n "variable `vn' is numeric"
				exit 198
			}
			gen byte `umark'= float(`vn')==float(`omis')
		}
		else	gen byte `umark'= `vn'=="`omis'"
		capture assert `umark'==0
		if _rc==0 {
			di as txt "(characteristic `vn'[omit]: `omis'" _n /*
			  */ "yet variable " abbrev("`vn'",22) /*
			  */ " never equals `omis'; characteristic ignored)"
			local umark
		}
	}

				/* code for dropping first category */
	local ximode : char _dta[omit]
	if "`umark'"=="" & "`ximode'"=="" {
		tempvar umark
		qui gen byte `umark'=(`g'==1)
	}

	local max 0
	local jmax 0
	qui gen long `on'=.

	*** 3. create "omitg" (omitted group) and "omit" (omitted value) based on
      *      char.  Used for all types of contrasts, except for i. (indicator)
	if "`omis'" == "" {
      	local omitg = 1
	}
	else {
		local omitg = `omis'
      }
	* if helmert, reverse, fdif or rdiff, then force group 1 to be omitted group
	if "`contype'" == "rev" | "`contype'" == "bdif" {
		* if reverse, or bdif, then force group 1 to be omitted group
		local omitg 1
	}
	if "`contype'" == "hel" | "`contype'" == "fdif" | "`contype'" == "orth" | "`contype'" == "user" {
		* if helmert fdif or user, then force last group to be omitted group
		local omitg `ng'
	}
	qui replace `on'=cond(`g'==`omitg',_n,`on'[_n-1])
	local omit = `vn'[`on'[_N]]
      * 3. end of change

	forvalues j = 1/`ng' {
				/* obtain value */
		qui replace `on'=cond(`g'==`j',_n,`on'[_n-1])
		local value = `vn'[`on'[_N]]

		if `useuser' { local k `value' }
		else	local k `j'

		*** 4. replace the following line with the following lines of code
		* qui gen byte `svn'`k' = `g'==`j' if `g'!=.

            * get "prival", value for prior group (for var label)
		if (`j' == 1) {
			local prival = -99999999.987654321
		}
		else {
			qui replace `on'=cond(`g'==(`j'-1),_n,`on'[_n-1])
			local prival = `vn'[`on'[_N]]
		}

            * get "nextval", value for next group (for var label)
		if (`j' == `ng') {
			local nextval = -99999999.987654321
		}
		else {
			qui replace `on'=cond(`g'==(`j'+1),_n,`on'[_n-1])
			local nextval = `vn'[`on'[_N]]
		}

            * make contrast variables, passing in the following variables
            mk_`contype' `svn'`k' `vn'   `value' `omit' `g'     `j'     `omitg' `ng' `prival' `nextval'
            * end of change

		local zz `zz' `svn'`k'

		*** 5. comment out making the labels (they are made in the mk_xxx program above)
		* label var `svn'`k' "`vn'==`value'"

		if "`umark'"=="" {
			qui count if `g'==`j'
			if r(N)>`max' {
				local max = r(N)
				local jmax `k'
				local dval "`value'"
			}
		}
		else {
			capture assert `umark' if `g'==`j'
			if _rc==0 {
				local jmax `k'
				local dval "`value'"
			}
		}
	}

	*** 6. override the omitted group, except for "indicator" contrasts
	if "`contype'" != "ind" {
		if `useuser' {
			local jmax `omit'
		}
		else {
			local jmax `omitg'
		}
		local dval `omit'
      }
      * 6. end of change

	local newo = substr("`orig'",1,2) + abbrev("`vn'",13)
	if `useuser' {
		di as txt "`newo'" _col(19) "`svn'`lowcode'-`topcode'" /*
			*/ _col(39) "(naturally coded; `svn'`jmax' omitted)"
	}
	else {
		local rlen = 41 - length("(`svn'`jmax' for ==`dval' omitted)")
		di as txt "`newo'" _col(19) "`svn'`lowcode'-`topcode'" /*
			*/ _col(39) "(`svn'`jmax' for " abbrev("`vn'",`rlen') /*
			*/ "==`dval' omitted)"
	}

	drop `svn'`jmax'
	foreach item of local zz {
		if "`item'" != "`svn'`jmax'" {
			char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `item'
			if ("$xi3_debug"=="1") { display "char _dta[__xi__Vars__To__Drop__] `_dta[__xi__Vars__To__Drop__]' `item'" }
		  *#11. save value of _I variables in xi3_varname
      global xi3_`vn' ${xi3_`vn'} `item'
		}
	}
	capture list `svn'* in 1
	if _rc {
		global S_1 "."
	}
	else	global S_1 "`svn'*"
	global X__in "$X__in `vn'"
end


capture program drop xi_mkun
program define xi_mkun /* meaning make_unique_name <suggested_name> <topcat> */
	args base

	local pre $X__pre
	local name = substr("`pre'`base'",1,11) + "_"

	xi_mkun2 `name'
end

capture program drop xi_mkun2
program define xi_mkun2 /* meaning make_unique_name <suggested_name> */
	args name

	local totry "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local l 0
	local len = length("`name'")
	capture list `name'* in 1		/* try name out */
	while _rc==0 {
		local l=`l'+1
		local name = substr("`name'",1,`len'-1)+substr("`totry'",`l',1)
		capture list `name'* in 1
	}
	global S_1 "`name'"
end



* mk_ind, mk_cen, mk_sim, mk_dev, mk_hel, mk_rev, mk_orth, mk_fdif, mk_bdif, mk_user
* I. indicator coding: compares each level to the omitted group
* C. centered indicator coding
* G. group simple coding: compares each level to a reference group
* E. effect coding, deviation coding: deviations from the grand mean
* H. Helmert coding: compares leversl of a variable with mean of subsequent levels
* R. Reverse Helmert coding, compares levels of a variables with mean of previous levels
* O. orthogonal polynomial contrasts
* A. adjacent forward differences: adjacent levels, each vs. next
* B. backward differences: adjacent levels, each vs. previous
* U. user defined coding scheme

* I. indicator coding: compares each level to the omitted group
capture program drop mk_ind
program define mk_ind
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  qui gen byte `newvar' = `curvarg'==`curvalg' if `curvarg' < .
  label var `newvar' "`curvar'=`curval'"
end

* C. centered indicator coding
capture program drop mk_cen
program define mk_cen
  args  newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  qui gen double `newvar' = `curvarg'==`curvalg' if `curvarg'< .
  qui sum `newvar'
  qui replace `newvar' = `newvar' - r(mean)
  label var `newvar' "`curvar'(`curval' vs. `omit')"
end

* G. group coding: compares each level to a reference group
capture program drop mk_sim
program define mk_sim
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  quietly gen double  `newvar'=(`curvarg'==`curvalg')  if `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace  `newvar'=`newvar'-1/`ncat'          if `curvarg'<. /* New, omit missing 6/30/03 */
  label var `newvar' "`curvar'(`curval' vs. `omit')"
end

* E. effect coding, deviation coding: deviations from the grand mean
capture program drop mk_dev
program define mk_dev
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  quietly gen double `newvar'=(`curvarg'==`curvalg')-(`curvarg'==`omitg') if `curvarg'<. /* New, omit missing 6/30/03 */
  label var `newvar' "`curvar'(`curval' vs. grand mean)"
end

* H. Helmert coding: compares leversl of a variable with mean of subsequent levels
* forward difference, each category versus next
capture program drop mk_hel
program define mk_hel
  * last group should be omitted
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  quietly gen double `newvar'=0 if `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace `newvar'=(`ncat'-`curvalg')/(`ncat'-`curvalg'+1) if (`curvarg'==`curvalg') & `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace `newvar'=             -1  /(`ncat'-`curvalg'+1) if (`curvarg'> `curvalg')  & `curvarg'<. /* New, omit missing 6/30/03 */
  if (`curvalg'+1 == `ncat') {
    label var `newvar' "`curvar'(`curval' vs. `nextval')"
  }
  else {
    label var `newvar' "`curvar'(`curval' vs. `nextval'+)"
  }

end

* R. Reverse Helmert coding, compares levels of a variables with mean of previous levels
* backward difference, each category versus previous
capture program drop mk_rev
program define mk_rev
  * first group should be omitted
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  quietly gen double `newvar'=0 if `curvarg'<. /* New, omit missing 6/30/03 */

  * local curvalg = `curvalg' + 1
  quietly replace `newvar'=(   -1 +`curvalg')/(       `curvalg'  ) if (`curvarg'==`curvalg') & `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace `newvar'=             -1  /(       `curvalg'  ) if (`curvarg'< `curvalg')  & `curvarg'<. /* New, omit missing 6/30/03 */
  if (`curvalg' == 2) {
    label var `newvar' "`curvar'(`curval' vs. `prival')"
  }
  else {
    label var `newvar' "`curvar'(`curval' vs. `prival'-)"
  }
end

* O. orthogonal polynomial contrasts
capture program drop mk_orth
program define mk_orth
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  if `curvalg'==1 {
    local newvar2 = substr("`newvar'",1,length("`newvar'")-1)
    orthpoly `curvar', gen(`newvar2'*) deg(`ncat')
  }
end

* A. Adjacent forward differences: adjacent levels, each vs. next
* forward difference, each category versus next
* `i'=1 to `ncat'-1
capture program drop mk_fdif
program define mk_fdif
  * first group should be omitted
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  * local curvalg = `curvalg' - 1
  quietly gen double `newvar'=-`curvalg'/`ncat'      if `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace `newvar'=(`ncat'-`curvalg')/`ncat' if (`curvarg'<=`curvalg') & `curvarg'<. /* New, omit missing 6/30/03 */
  label var `newvar' "`curvar'(`curval' vs. `nextval')"
end

* B. backward differences: adjacent levels, each vs. previous
* backward difference, each category versus previous
capture program drop mk_bdif
program define mk_bdif
  * first group shuld be omitted
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  local curvalg = `curvalg' - 1
  quietly gen double `newvar'=`curvalg'/`ncat' if `curvarg'<. /* New, omit missing 6/30/03 */
  quietly replace `newvar'=(`curvalg'-`ncat')/`ncat' if (`curvarg'<= `curvalg') & `curvarg'<. /* New, omit missing 6/30/03 */
  label var `newvar' "`curvar'(`curval' vs. `prival')"
end

* U. user defined coding scheme
capture program drop mk_user
program define mk_user
  args       newvar   curvar curval  omit   curvarg curvalg omitg   ncat prival nextval
  local user : char `curvar'[user]
  * matrix does not exist
  if "`user'"=="" {
    display as error "User defined matrix for `curvar' does not exist"
    display as text  "You can create this matrix like this..."
    display as input ". char `curvar'[user] ( matrix values )"
    display as text  "for example, if race has 3 levels, you could type..."
    display as input ". char `curvar'[user] ( -2 1 1 \ 0 1 -1 )"
    exit -1
  }

  tempvar user1
  matrix input `user1' = `user'

  * matrix does not have the right number of columns
  local i = colsof(`user1')
  if `i' != `ncat' {
    display as error "Matrix based on `curvar'[user] (see below) has `i' columns but should have `ncat' columns and `ncat'-1 rows"
    display as text "Matrix for `curvar'[user]"
    matrix list `user1'
    exit=-1
  }

  * matrix does not have the right number of rows
  local j=rowsof(`user1')
  if (`j' != `ncat'-1) {
    display as error "Matrix based on `curvar'[user] (see below) has `j' rows, but should have `ncat'-1 rows and `ncat' columns"
    display as text "Matrix for `curvar'[user]"
    matrix list `user1'
    exit=-1
  }

  tempvar user2
  matrix `user2'=`user1'*`user1''
  if det(`user2') == 0 {
    display as error "Matrix for `curvar'[user] has linear dependencies between rows"
    display as text "Matrix for `curvar'[user]"
    matrix list `user1'
    exit=-1
  }

  matrix `user2' = `user1''*inv(`user1'*`user1'')
  local conlab = ""
  quietly generate double `newvar' = .
  if (`curvalg' < `ncat') {
    forvalues i = 1/`ncat' {
      quietly replace `newvar' = `user2'[`i',`curvalg'] if `curvarg'==`i' & `curvarg'<. /* New, omit missing 6/30/03 */
      local conval = `user1'[`curvalg',`i']
      local conlab = "`conlab' `conval'"
    }
  }
  label var `newvar' "`curvar'(`conlab')"
end

capture program drop checklen
program define checklen
  * display "checking length of `*'"
  if (length("`*'") > 31) {
    display as error "Sorry, but the length of `*' exceeds 31 characters."
    display as error "Please shorten the names of your variables to make this work"
    exit 999
  }
end



***** DEMO ******

	cd "/users/bbdaniels/desktop/"

	sysuse auto, clear

	xiReg reg1 , clear 	command(ivregress 2sls) depvar(price) rhs( ( i.foreign*headroom = turn*mpg ) gear_ratio)
	xiReg reg2 , 		command(regress) depvar(price) rhs( i.foreign*headroom*displacement )

	xiOut ///
		using "demo.xls" ///
		, replace stats(mean)

	xiGen i.foreign*headroom

* Have a lovely day!
