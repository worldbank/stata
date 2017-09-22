* Clean out odd characters from value labels

cap prog drop cleanLabels
prog def cleanLabels

syntax anything /// input the cleaning variable list
	, [Remove(string asis)] // list of characters to remove; default is remove(, :). DOES NOT ACCEPT ` " '

* Setup

qui {
	
	version 13 // required for long macro
		
	unab theVars : `anything'

	if "`remove'" == "" local remove ", :"

	preserve
	clear

	tempfile theLabels

	tempfile theCommands
		save `theCommands' , replace emptyok
		
	restore

* Fill temp dataset with faulty value labels

	foreach var in `theVars' {
		local theLabel : value label `var'
		cap label save `theLabel' using `theLabels' ,replace
			if _rc==0 {
				preserve
				import delimited using `theLabels' , clear delimit(", modify", asstring) 
				append using `theCommands'
					save `theCommands' , replace
					
				restore
			}
		}
	
* Load replacement commands into macro
	
	preserve
		use `theCommands' , clear
		
		foreach item in `remove' {
			replace v1 = subinstr(v1,"`item'","",.)
			replace v1 = subinstr(v1,"  "," ",.)
			}
			
		qui count
			forvalues i = 1/`r(N)' {
				local theNextMod = v1[`i']
				local theMods `" `theMods' `"`theNextMod' , modify"' "'
				}
	restore

* Execute replacement commands
			
	local nMods : word count `theMods'
		forvalues i = 1/`nMods' {
			local theNextMod : word `i' of `theMods'
			`theNextMod'
			}
			
* End
	
	} // end quietly
	
	end

/* Demo

sysuse auto, clear
label def origin 1 "Of, Foreign : Origin" 0 "D,omes:tic" , modify
labelbook origin 
cleanLabels foreign
labelbook origin

* Have a lovely day!
