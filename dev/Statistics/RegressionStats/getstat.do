* Mean

cap prog drop getstat

prog def getstat

syntax anything

	qui sum `e(depvar)' if e(sample)
		local mean = `r(`anything')'
	estadd scalar mean = `mean'

end



* Have a lovely day!
