* Create day-of-week variable

cap prog drop dayofweek
prog def dayofweek

syntax anything, GENerate(string asis) [label(string asis)]

	gen `generate' = dow(`anything')
	
	cap label def weekdays 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" 5 "Friday" 6 "Saturday"
		label val `generate' weekdays

	if "`label'" != "" {
		label var `generate' "`label'"
		}
		
end
