* Regression coefficient chart/table

cap prog drop tornado
prog def tornado

syntax anything =/exp /// syntax – tornado : reg d1 d2 d3 = treatment
	[if] [in] [using] /// [pweight] ///
	, [*] ///
	 [or] /// odds-ratios
	 [d]  /// cohen's d
	 [controls(varlist)]

preserve
marksample touse, novarlist
keep if `touse'

	di "`anything'"
	di "`exp'"



end


sysuse auto, clear
tornado reg price mpg = trunk
