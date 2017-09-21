** Encode and replace

cap prog drop rencode
prog def rencode

syntax varlist

local x = 1

foreach var of varlist `varlist' {
	encode `var', gen(_temp`x')
	drop `var'
	rename _temp `var'
	local ++x
	}
	
end
