** Imports Excel data using Excel metadata file

cap prog drop import_metadata
prog def import_metadata

syntax anything 				/// Specify the list of Excel or dta files to import - they will be appended onto each other.
	using, 						/// Specify the Excel metadata file (for read or write).
								///
								/// (PREP)
	[Prep]						/// Create metadata template using master data. Requires namerow and replace, may use headrow.
								///
								///	(MASTERS/DATA SPREADSHEETS : MUST BE CONSISTENT ACROSS EXCEL FILES)
	[NAMErow(string asis)]		/// Specify the row in which "original" variable names are stored.
	[HEADrow(string asis)]  	/// Specify the last row before data begins ; OR, for [prep], the row containing variable labels
	[DROPcol(string asis)]		/// Indicate a column which, if empty, means that this is not an observation (Excel column names, ie A B C D). Default is A.
								///
								/// (USING/METADATA)
	[OLDname(string asis)] 		/// Indicate the column name(s) containing the names to match to the master files, in order
	[RECode(string asis)]		/// Indicate the column name(s) containing the recode codes (STATA syntax), in the same order as the master files
	[sheet(string asis)]		/// Sheet for spreadsheets
								///
								///
								/// (OUTPUT)
	[Replace]					///	Allow overwrite of output metadata template or dta files. Like a safety switch.
	[DEMerge(string asis)]		/// List final variable names to down-fill (will never be missing)
	[Save(string asis)] 		/// Specify the directory in which to store generated .dta files.
	[Append]					/// If Index() is specified, indexing will start from the highest value in  pre-imported data, plus one; already-constructed data (1 file) should be listed first in file list.
	[Index(string asis)]		/// Indicate a variable name to identify the source of each observation. They will be numbered 1 2 3... in the order of the masters and can be coded in the metadata.
	[PREfix(string asis)]		/// Prefix for output .dta files, if desired.
	[POSTfix(string asis)]		/// Postfix for output .dta files, if desired.
								/// Final "generate" sheet specifies the variables to be constructed and their formulae. Will OVERWRITE these variables in existing data.						
								/// Final variable names always from column "varname".
								/// Final variable labels always from column "varlab".
								/// Final value labels always from column/sheet "vallab".

								
* Set up master file and defaults for Excel masters

	clear
	tempfile master
		save `master', emptyok
		
	if "`dropcol'" == "" {
		local dropcol A
		}
	
	if `"`sheet'"' != `""' {
		local nsheets : word count `sheet'
		forvalues i = 1/`nsheets' {
			local sheet`i' : word `i' of `sheet'
			local sheet`i' = `"sheet("`sheet`i''")"'
			}
		}
		
* Quietly

qui {

***************		
* Prep Option *
***************

if "`prep'" != "" {

* Prep for all files.

	local n_files : word count `anything'
	
	local theNextRow = 2
	local theNextCol = 5
	
	putexcel A1=("Variable Label") `using', `replace' sheet("Codebook", replace)
	putexcel B1=("Value Label") `using', modify sheet("Codebook")
	putexcel C1=("Recode") `using', modify sheet("Codebook")
	putexcel D1=("Variable Name") `using', modify sheet("Codebook")
			
	forvalues file_n = 1/`n_files' {
	
	* Oldname for file.
	
		local theNextColumn : word `theNextCol' of `c(ALPHA)'
	
		putexcel `theNextColumn'1=("oldname_`file_n'") `using', modify sheet("Codebook")
	
	* Load the file
	
		local theNextFile : word `file_n' of `anything'
			
		if !regexm("`theNextFile'","dta$") {
			import excel "`theNextFile'", clear `sheet`file_n'' // Import file if Excel.
			}
		else {
			use "`theNextFile'", clear // Load file if dta.
			}
			
	* Write var
		
		foreach var of varlist * {
		
			if !regexm("`theNextFile'","dta$") {
				if "`namerow'" != "" local theName = `var'[`namerow']
				if "`namerow'" == "" local theName = "`var'"
				local theName = strtoname("`theName'")
				cap local theLabel = `var'[`headrow']
					if _rc != 0 local theLabel = `var'[`namerow']
				}
			if regexm("`theNextFile'","dta$") {
				local theName "`var'"
				local theLabel : var label `var'
				}
			if "`theName'" != "" & "`theName'" != "_" {
				putexcel `theNextColumn'`theNextRow'=("`theName'") `using', modify sheet("Codebook")
				cap putexcel A`theNextRow'=("`theLabel'") `using', modify sheet("Codebook")
				local ++theNextRow
				}
			
			} // End looping over variables.
			
			local ++theNextCol
			
		} // End looping over files.
		
	* Write recode and note columns.
	
			if "`recode'" != "" foreach column in `recode' {
				local theNextColumn : word `theNextCol' of `c(ALPHA)'
				putexcel `theNextColumn'1=("`column'") `using', modify sheet("Codebook")
					local ++theNextCol
					}
				
			local theNextColumn : word `theNextCol' of `c(ALPHA)'
			putexcel `theNextColumn'1=("notes") `using', modify sheet("Codebook")
			
	* Write labelling sheet and construction sheet
			
		putexcel 		A1=("Value Label") 	B1=("Value") 	C1=("Label") 		`using', sheet("Value Labels", replace) modify
			putexcel 	A2=("yesno") 	B2=("0") 		C2=("No") 			`using', sheet("Value Labels") modify
			putexcel 	A3=("yesno") 	B3=("1") 		C3=("Yes")			`using', sheet("Value Labels") modify
			putexcel 	A4=("yesnodk") 	B4=("0") 		C4=("No") 			`using', sheet("Value Labels") modify
			putexcel 	A5=("yesnodk") 	B5=("1") 		C5=("Yes") 			`using', sheet("Value Labels") modify
			putexcel 	A6=("yesnodk") 	B6=(".a") 		C6=("Don't Know") 	`using', sheet("Value Labels") modify
			
		putexcel A1=("command") B1=("varname") C1=("arguments") D1=("notes") `using', sheet("construct", replace) modify
		
		clear
		di in red "Prep completed."
					
	} // End prep option.
	
else { // Begin merge (prep-else)

***********************************
* Import and clean metadata file. *
***********************************
		
import excel `using', first clear all
	
* Get final dta-file list and strip out duplicates

if "`save'" != "" {
	
	preserve

	keep if file != ""
	
	tempvar placeholder
		gen `placeholder' = 0
		
	collapse `placeholder', by(file) fast
	
	count
	
	forvalues i = 1/`r(N)' {
		local theNextFile = file[`i']
		local filenames `raw_filenames' `theNextFile'
		}
		
	restore
	
	}
	
* Get destring list from recodes

	gen _any_recode = 0
	
	if "`recode'" != "" {
		foreach var of varlist `recode' {
			replace _any_recode = 1 if `var' != ""
			}
		}
		
* Save Metadata

	tempfile metadata
		save `metadata', replace
		
*******************************************
* Import, clean, and append master files. *
*******************************************
	
* Loop over each input file to create fully appended master
	
local n_files : word count `anything'

forvalues file_n = 1/`n_files' { // Begin import-clean-append loop over master files.

* Load from raw data.
	
	local theNextFile : word `file_n' of `anything'
	
	if !regexm("`theNextFile'","dta$") { // Begin import-and-clean loop for Excel files.
			
		import excel using "`theNextFile'", clear allstring `sheet`file_n'' // Everything as strings for appending purposes. Destring done later.
					
		* Rename variables to master-indicated original names
		
			if "`namerow'" != "" {
				local dropvar = `dropcol'[`namerow']
				local dropvar = strtoname("`dropvar'")
			
				foreach var of varlist * {
					local theName = `var'[`namerow']
					local theName = strtoname("`theName'")
					if "`theName'" == "" | "`theName'" == "_" {
						drop `var'
						}
					else rename `var' `theName'
					}
				}
			else local dropvar `dropcol'
					
		* Drop rows without data
			
			if "`headrow'" != "" {
				drop in 1/`headrow'
				}

				drop if `dropvar' == "" // Drop anything with a missing value in the indicated column (A if not otherwise indicated)
				
		} // End load-and-clean for Excel files.
	else {
		use "`theNextFile'", clear // dta files need not be named, labeled, and trimmed.
		
			foreach var of varlist * { // Types and formats must be set so that numbers convert reversibly to strings at this stage.
				local theFormat : format `var'
				if !regexm("`theFormat'","s") recast double `var'
				if !regexm("`theFormat'","s") & !regexm("`theFormat'","t") format `var' %20.9f 
				}
				
			tostring *, replace force u // Everything as strings for appending purposes. Destring done later.
		}
		
		* Generate index variable if specified.

			if "`index'" != "" {
				if "`append'" == "" gen `index' = `file_n'
				if "`append'" != "" & `file_n' == 1 {
					qui sum `index'
					local maxGen = `r(max)' // Read in highest current value from pre-constructed data (the first master file) if [append] is specified.
					}
				if "`append'" != "" & `file_n' != 1 gen `index' = `maxGen' + `file_n' - 1 // Start from highest current value from constructed data +1 if [append] is specified.
				}
	
		* Save as raw data
		
			tempfile raw
				save `raw', replace
			
* Read in recodes if specified
	
	if "`recode'" != "" {
	
	* Prepare parallel lists of variables to recode and their recode patterns.
		
		use `metadata', clear
		
		local theRecodeVar  : word `file_n' of `recode'
		local theOldnameVar : word `file_n' of `oldname'
		
			keep if _any_recode == 1 & `theOldnameVar' != ""

			count
			
			if `r(N)' == 1 {
				local allRecodes = `theOldnameVar'[1]
				}
			else if `r(N)' > 1 {
				forvalues i = 1/`r(N)' {
					local theNextRecode = `theOldnameVar'[`i']
					local allRecodes `allRecodes' `theNextRecode'
					}
				}
		
		keep if `theRecodeVar' != ""
		local theOldNames ""
		local theRecodes  ""
		
		count 
			if `r(N)' == 1 {
				local theOldNames = `theOldnameVar'[1]
				local theRecodes  = `theRecodeVar'[1]
				local theRecodes  = `" "`theRecodes'" "'
				}
			if `r(N)' > 1 {
				forvalues i = 1/`r(N)' {
					local theNextOld = `theOldnameVar'[`i']
					local theNextRecode = `theRecodeVar'[`i']
					local theOldNames `theOldNames' `theNextOld'
					local theRecodes `" `theRecodes' "`theNextRecode'" "'
					}
				}
				
	* Apply recodes to variables.
				
		use `raw', clear
		
		foreach var in `allRecodes' {
			cap destring `var', replace
			}
		
		local n_recodes : word count `theRecodes'
		local i = 1
		while `i' <= `n_recodes' {
			local theOldName : word `i' of `theOldNames'
			local theRecode : word `i' of `theRecodes'
			cap destring `theOldName', i("`c(ALPHA)' `c(alpha)'") force replace
			recode `theOldName' `theRecode'
			local ++i
			}
			
		save `raw', replace
				
	} // End recode option.
			
* Read in renames
						
	* Prepare parallel lists of oldnames and newnames.
						
		use `metadata', clear
		
		local theNewnameVar VariableName
		local theOldnameVar : word `file_n' of `oldname'
		
		keep `theNewnameVar' `theOldnameVar'
		
		keep if `theNewnameVar' != "" & `theOldnameVar' != ""
		
		local theOldNames ""
		local theNewNames ""
		
		qui count
			if `r(N)' == 1 {
				local theOldNames = `theOldnameVar'[1]
					local theOldNames = substr("`theOldNames'",1,30)
				local theNewNames = `theNewnameVar'[1]
				}
			if `r(N)' > 1 {
				forvalues i=1/`r(N)' {
					local theNextOld = `theOldnameVar'[`i']
					local theNextNew = `theNewnameVar'[`i']
					local theOldNames `theOldNames' `theNextOld'
					local theNewNames `theNewNames' `theNextNew'
					
					}
				}

				
	* Apply new names.
				
		use `raw', clear
						
		local n_newnames : word count `theNewNames'
		local newNames "`theNewNames'"
			local i = 1
			
			foreach var of varlist * { // Avoid naming conflicts
				local theOldName = substr("`var'",1,30)
				rename `var' x_`theOldName'
				}
				
			while `i' <= `n_newnames' {
				local theOldName : word `i' of `theOldNames'
					local theOldName = substr("`theOldName'",1,30)
				local theNewName : word `i' of `theNewNames'
				cap rename x_`theOldName' `theNewName'
					if _rc != 0 local newNames = regexr(" `newNames' "," `theNewName'","")
				local ++i
				}
			
			keep `newNames'
						
* Append to master

	tostring *, replace u // To avoid loss of data during appends.
	append using `master'
		save `master', replace

			
} // End import-clean-append loop over master files.

*******************************************
* Now working with fully appended master. *
*******************************************

* De-merge (infill) merged cells from excel

	if "`demerge'" != "" {
		foreach var of varlist `demerge' {
			qui count
			local theLastVal = ""
			forvalues i = 1/`r(N)' {
				local theNextVal = `var'[`i']
				if "`theNextVal'" == "" replace `var' = "`theLastVal'" in `i'
				local theLastVal = `var'[`i'] 
				}
			}
		}	
			
* Destring. 

	destring *, replace 
	save `master', replace

* Generate new variables

	cap import excel `using', first clear sheet(construct) allstring
	if _rc == 0 {
	
		count
		if `r(N)' > 0 {
		
			gen equals = " = " if ( regexm(command,"gen") | command == "replace" )

			gen theCommand = command + " " + varname + equals + " " + arguments
			replace varname = "" if ( !regexm(command,"gen") )
			
			count
			if `r(N)' == 1 {
					local theGenerators = theCommand[1]
					local theGenerators = `" `"`theGenerators'"' "'
					local theVariables	= varname[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextGenerator 	= theCommand[`i']
						local theNextVarname 	= varname[`i']
						local theGenerators 	= `" `theGenerators' `"`theNextGenerator'"' "'
						local theVarnames	 	= `" `theVarnames' "`theNextVarname'" "'
						}
					}
					
			use `master' , clear
			
			foreach varname in `theVarnames' {
				cap drop `varname' // Remove from pre-existing data if any and re-generate from raw fields for consistency.
				}
				
			foreach command in `theGenerators' {
				`command'
				}
				
			save `master', replace
		
		} // If any commands.
	} // If no error
	
* Apply variable labels
	
	* Prepare parallel lists of variables to be labeled and their labels.

		use `metadata', clear
			drop if VariableName == ""
			save `metadata', replace
			
		keep if VariableLabel != ""
	
		count
			forvalues i = 1/`r(N)' {
				local theNextVar   = VariableName[`i']
				local theNextLabel = VariableLabel[`i']
				local theVars `theVars' `theNextVar'
				local theLabs `" `theLabs' "`theNextLabel'" "'
				}
				
	* Apply labels.
				
		use `master', clear
		
		local n_labels : word count `theLabs'
		forvalues i = 1/`n_labels' {
			local theNextVar   : word `i' of `theVars'
			local theNextLabel : word `i' of `theLabs'
			cap label var `theNextVar' "`theNextLabel'"
			}
			
		save `master', replace
							
* Apply value labels
			
	* Prepare list of value labels needed.
			
		use `metadata', clear 
		
			drop if ValueLabel == ""
			cap duplicates drop ValueLabel, force
			
			count
				if `r(N)' == 1 {
					local theValueLabels = ValueLabel[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextValLab  = ValueLabel[`i']
						local theValueLabels `theValueLabels' `theNextValLab'
						}
					}
			
	* Prepare list of values for each value label.
			
			import excel `using', first clear sheet("Value Labels")
				tempfile valuelabels
					save `valuelabels', replace
						
			foreach theValueLabel in `theValueLabels' {
				use `valuelabels', clear
				keep if ValueLabel == "`theValueLabel'"
				local theLabelList "`theValueLabel'"
					count
					local n_vallabs = `r(N)'
					forvalues i = 1/`n_vallabs' {
						local theNextValue = Value[`i']
						local theNextLabel = Label[`i']
						local theLabelList_`theValueLabel' `" `theLabelList_`theValueLabel'' `theNextValue' "`theNextLabel'" "'
						}
				}
				
	* Prepare parallel lists of variables to be value-labeled and their corresponding value labels.
				
		use `metadata', clear
				
			keep if ValueLabel != ""
			local theValueLabelNames ""
			
			count
				if `r(N)' == 1 {
					local theVarNames	 = VariableName[1]
					local theValueLabelNames = ValueLabel[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextVarname  = VariableName[`i']
						local theNextValLab   = ValueLabel[`i']
						local theVarNames `theVarNames' `theNextVarname'
						local theValueLabelNames `theValueLabelNames' `theNextValLab'
						}
					}
					
	* Label the values in the master dataset.
						
		use `master', clear
		
			foreach theValueLabel in `theValueLabels' {
				label def `theValueLabel' `theLabelList_`theValueLabel'' , modify
				}
						
			local n_labels : word count `theValueLabelNames'
			if `n_labels' == 1 {
				cap label val `theVarNames' `theValueLabelNames'
				}
			else {
				forvalues i = 1/`n_labels' {
					local theNextVarname : word `i' of `theVarNames'
					local theNextValLab  : word `i' of `theValueLabelNames'
					cap destring `theNextVarname', replace
					cap label val `theNextVarname' `theNextValLab'
					}
				}
				
			save `master', replace
				
* Save the datasets

	if "`save'" != "" {
		foreach fileName in `filenames' {
		
			use `metadata', clear
			
			local theVarnames ""
			
			keep if regexm(file,"`fileName'")
			count
				if `r(N)' == 1 {
					local theVarnames = varname[1]
					}
				else {
					forvalues i = 1/`r(N)' {
						local theNextVar = varname[`i']
						local theVarnames `theVarnames' `theNextVar'
						} 
					}
					
			use `master', clear
			
			local keepvars ""
			foreach var in `theVarnames' {
				cap su `var'
				if _rc == 0 local keepvars "`keepvars' `var'"
				}
			keep `keepvars'
			
			destring * , replace
			order *, seq
			compress
			
			save "`save'/`prefix'`fileName'`postfix'.dta", `replace'
			di in red "`save'/`prefix'`fileName'`postfix'.dta saved."
			
			} // End looping over final filenames.
		} // End if-statement for directory being specified.

* End.
		
	} // End merge (prep-else).
} // End quietly.

end

	
