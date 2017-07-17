* Collapses while preserving labels

cap prog drop labelcollapse
prog def labelcollapse

syntax anything [if] [in] [fweight  aweight  pweight  iweight], [vallab(varlist)] [n] [*]

if "`n'" == "n" {
	tempname n 
	gen `n' = 1
	local ncollapse (sum) `n'
	label var `n' "N"
	}

if "`weight'" != "" {
	local theWeight [`weight' `exp']
	}

foreach item in `anything' {
	if strpos("`item'",")") == 0 {
		local theVarlist `theVarlist' `item'
		}
	}

if "`vallab'" != "" {
	foreach var of varlist `vallab' {
		qui levelsof `var', local(levels)
		
		local theLabelList ""
		foreach level in `levels' {
			local theValLab : label (`var') `level'
			local theLabelList `" `theLabelList' `level' "`theValLab'" "'
			}
		cap label drop `var'_l
		label def `var'_l `theLabelList'
		}
	}
	
foreach var of varlist `theVarlist' {
	local `var'L : var label `var'
	}
	
collapse `anything' `ncollapse' `if' `in' `theWeight', `options'

foreach var of varlist `theVarlist' {
	label var `var' "``var'L'"
	cap label val `var' `var'_l
	}
	
end
