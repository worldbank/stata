* Regression coefficient chart/table

cap prog drop tornado
prog def tornado

syntax anything =/exp /// syntax – tornado: reg d1 d2 d3 = i1 i2 i3
	[if] [in] [using] [pweight] ///
	, [*] ///
	 [or] /// odds-ratios
	 [d]  /// cohen's d

preserve
marksample touse, novarlist
keep if `touse'

	di "`anything'"
	di "`exp'"



end


sysuse auto, clear
tornado: price mpg = trunk headroom
