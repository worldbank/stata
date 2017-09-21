
* Intervals program

cap prog drop intervals
		prog def  intervals
		syntax anything [if] [in] [pweight], [Binary]
			marksample touse
			
	preserve
		qui keep if `touse'
		
	version 13
			
	if "`weight'" != "" qui svyset , clear
	if "`weight'" != "" qui svyset [`weight' `exp']
	
	if "`weight'" != "" foreach var of varlist `anything' {
		
		local theLabel : var label `var'

		if "`binary'" != "" {
			qui count if `var' == 1
				local yes = string(`r(N)')
			qui count if `var' != .
				local all = string(`r(N)')
			qui svy: mean `var'
				mat a = r(table)
				
				local mu = a[1,1]
				local ll = a[5,1]
				local ul = a[6,1]
			
				local mu = string(round(`mu'*100,1))
				local ll = string(round(`ll'*100,1))
				local ul = string(round(`ul'*100,1))			
				di in red "`theLabel': `yes' of `all' (`mu'%; 95% CI: `ll'–`ul')"
			} // end binary option
		else {
			qui svy: mean `var'
				mat a = r(table)
				
				local mu = a[1,1]
				local ll = a[5,1]
				local ul = a[6,1]
				
				local mu = substr(string(round(`mu'*100,1)/100),1,strpos(string(round(`mu'*100,1)/100),".")+2)
				local ul = substr(string(round(`ul'*100,1)/100),1,strpos(string(round(`ul'*100,1)/100),".")+2)
				local ll = substr(string(round(`ll'*100,1)/100),1,strpos(string(round(`ll'*100,1)/100),".")+2)
				
				di in red "`theLabel': `mu' (95% CI: `ll'–`ul')"
			} // end continuous
			
		} // end weighted var-loop
			
	if "`weight'" == "" foreach var of varlist `anything' {
		
		local theLabel : var label `var'

		if "`binary'" != "" {
			qui count if `var' == 1
				local yes = string(`r(N)')
			qui count if `var' != .
				local all = string(`r(N)')
			qui ci `var', b wilson	
				local mu = string(round(`r(mean)'*100,1))
				local ll = string(round(`r(lb)'*100,1))
				local ul = string(round(`r(ub)'*100,1))			
				di in red "`theLabel': `yes' of `all' (`mu'%; 95% CI: `ll'–`ul')"
			} // end binary option
		else {
			qui ci `var'
				local mu = substr(string(round(`r(mean)'*100,1)/100),1,strpos(string(round(`r(mean)'*100,1)/100),".")+2)
				local ul = substr(string(round(`r(ub)'*100,1)/100),1,strpos(string(round(`r(ub)'*100,1)/100),".")+2)
				local ll = substr(string(round(`r(lb)'*100,1)/100),1,strpos(string(round(`r(lb)'*100,1)/100),".")+2)
				
				di in red "`theLabel': `mu' (95% CI: `ll'–`ul')"
			} // end continuous
			
		} // end unweighted var-loop
			
	end
	
* Have a lovely day!
