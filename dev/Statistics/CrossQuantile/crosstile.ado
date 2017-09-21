** Creates quantile tables of statistics

cap prog drop crosstile
prog def crosstile

syntax varlist(min=3 max=3 numeric) [if/] [in] [using], n(string asis) [round(real 0.01)] *

if "`if'" != "" {
	local ifand &
	}

tempvar rowvar
tempvar colvar

local theDepVar : word 1 of `varlist'
local theRowVar : word 2 of `varlist'
	local theRowLab : var lab `theRowVar'
local theColVar : word 3 of `varlist'
	local theColLab : var lab `theColVar'

local theRowN : word 1 of `n'
local theColN : word 2 of `n'

xtile `rowvar' = `theRowVar', n(`theRowN')
xtile `colvar' = `theColVar', n(`theColN')

cap mat drop results
mat results = J(`theRowN',`theColN',0)
mat results_STARS = J(`theRowN',`theColN',0)

local theRowNames `" "`theRowLab' Q1" "'
local theColNames `" "`theColLab' Q1" "'

forvalues i = 1/`theRowN' {
	forvalues j = 1/`theColN' {
		qui sum `theDepVar' if `rowvar' == `i' & `colvar' == `j' `ifand' `if'
			local theMean = string(round(`r(mean)',`round'))
		mat results[`i',`j'] = `theMean'
		if `i' == 1 & `j' > 1 local theColNames `"`theColNames' "Q`j'" "'
		}
		if `i' > 1 local theRowNames `"`theRowNames' "Q`i'" "'
	}
	
mat rownames results = `theRowNames'	
mat colnames results = `theColNames'	
matlist results

if `"`using'"' != `""' {
	xml_tab results `using' , `options' stars(0)
	}
	
end
