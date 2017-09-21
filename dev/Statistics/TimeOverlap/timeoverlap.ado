** Compares two datasets to idenfity overlapping time intervals from a list.
** Generates binary overlap, optional length of overlap, and can copy variables into master from using.
** Can overwrite master or save in new location.
** This will work if each master observation overlaps AT MOST one using observation.

cap prog drop timeoverlap
prog def timeoverlap

syntax [anything] using, 		/// Specify the master dataset and the using dataset. If nothing is specified the master is the current datset.
	Startvars(string asis)		/// Specify the start-time-vars in the master, then the using dataset. They MUST be in the same SIF time format. The display format is irrelevant.
	Endvars(string asis)		/// Specify the end-time-vars in the master, then the using dataset. They MUST be in the same SIF time format. The display format is irrelevant.
	Gen(string asis)			/// Specify an overlap indicator variable name to be created.
	[Length(string asis)]		/// Specify a variable name to store the overlap duration if desired. : NOT YET IMPLEMENTED
	[Copy(string asis)]			/// Specify a variable list to copy in from the using dataset on overlap matches.
	
	
* Set up options macros

	local masterstart : word 1 of `startvars'
	local masterend   : word 1 of `endvars'
	local usingstart  : word 2 of `startvars'
	local usingend    : word 2 of `endvars'

* Open master datset if specified

	if "`anything'" != "" {
		use "`anything'", clear
		}

* Preserve master data and create missing variables to copy in.

	if "`copy'" != "" {
		foreach copyvar in `copy' {
			gen `copyvar' = ""
			}
		}
		
	gen `gen' = 0
		
	qui count
		local n_master = `r(N)'
	
	tempfile masterdata
		save `masterdata', replace

* Load using dataset

	use `using', clear

* Loop over using dataset

	qui count
	local n_using = `r(N)'
	
	tempfile usingdata
		save `usingdata', replace
		
	if "`copy'" != "" {
		tostring `copy', replace
		}

	forvalues using = 1/`n_using' {
		
		use "`usingdata'", clear
		
		local theUsingStart = `usingstart'[1]
		local theUsingEnd   = `usingend'[1]
		
		if "`copy'" != "" {
			foreach copyvar of varlist `copy' {
				local `copyvar' = `copyvar'[1]
				}
			}
			
		drop in 1
		save `usingdata', replace

	* Return to master and compare start/end times with stored interval
	
		use `masterdata', clear
		
		replace `gen' = 1 if !( (`masterstart' > `theUsingEnd') | (`masterend' < `theUsingStart') )
		
		if "`copy'" != "" {
			foreach copyvar of varlist `copy' {
				replace `copyvar' = "``copyvar''" if !( (`masterstart' > `theUsingEnd') | (`masterend' < `theUsingStart') )
				}
			}
			
		save `masterdata', replace
		
	}
	
	if "`copy'" != "" {
		cap destring `copy', replace
		}
		
end


	
