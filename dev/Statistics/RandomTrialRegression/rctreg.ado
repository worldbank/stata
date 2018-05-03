** Produces formatted RCT regression tables.

cap prog drop rctreg
prog def rctreg

syntax varlist using [if/] [in], controls(varlist) treatment(varlist) [sd] [title(string asis)] [round(real 0.01)] [lag] [iv(string asis)] [p] [se] [ci] *

* Options

	local row = 4
	local treatvar : word 1 of `treatment'
	local morevars = regexr("`treatment'","`treatvar'","")
	local treatment `treatvar'

	* IV

	if "`iv'" != "" & "`ci'" == "" {
		local ivhead " H2=("IV Unadjusted") I2=("IV Adjusted") H3=("Difference") I3=("Difference") "
		local ivstats " H\`row'=("\`pe_iv'") I\`row'=("\`pe_iv_ad'")  "
		}
	if "`iv'" != "" & "`ci'" != "" {
		local ivhead " J2=("IV Unadjusted") L2=("IV Adjusted") J3=("Difference")  K3=("95% CI")  L3=("Difference") M3=("95% CI") "
		local ivstats " J\`row'=("\`pe_iv'") K\`row'=("\`ci_iv'") L\`row'=("\`pe_iv_ad'") M\`row'=("\`ci_iv_ad'") "
		}
		
	* SD (for means)
					
	if "`sd'" == "sd" {
		local sdputexcel " putexcel C\`row'=("(\`control_sd')") E\`row'=("(\`treatment_sd')") `using', modify "
		local anotherrow " local ++row "
		}
		
	* P-stats
		
	if "`ci'" == "" {
		if "`p'" == "p" {
			local pputexcel " putexcel F\`row'=("p=\`itt_p'") G\`row'=("p=\`itt_ad_p'") `using', modify "
			local anotherrow " local ++row "
			}
		if "`p'" == "p" & "`iv'" != "" {
			local ptputexcel " putexcel H\`row'=("p=\`iv_p'") I\`row'=("p=\`iv_ad_p'") `using', modify "
			}
		}
	if "`ci'" != "" {
		if "`p'" == "p" {
			local pputexcel " putexcel F\`row'=("p=\`itt_p'") H\`row'=("p=\`itt_ad_p'") `using', modify "
			local anotherrow " local ++row "
			}
		if "`p'" == "p" & "`iv'" != "" {
			local ptputexcel " putexcel J\`row'=("p=\`iv_p'") L\`row'=("p=\`iv_ad_p'") `using', modify "
			}
		}
	
	* Standard Errors (for regressions)
		
	if "`ci'" == "" {
		if "`se'" == "se" {
			local pputexcel " putexcel F\`row'=("(\`itt_se')") G\`row'=("(\`itt_ad_se')") `using', modify "
			local anotherrow " local ++row "
			}
		if "`se'" == "se" & "`iv'" != "" {
			local ptputexcel " putexcel H\`row'=("(\`iv_se')") I\`row'=("(\`iv_ad_se')") `using', modify "
			}
		}
	if "`ci'" != "" {
		if "`se'" == "se" {
			local pputexcel " putexcel F\`row'=("(\`itt_se')") H\`row'=("(\`itt_ad_se')") `using', modify "
			local anotherrow " local ++row "
			}
		if "`se'" == "se" & "`iv'" != "" {
			local ptputexcel " putexcel J\`row'=("(\`iv_se')") L\`row'=("(\`iv_ad_se')") `using', modify "
			}
		}
		
	
	* If conditions (cannot use marksample)
		
	if "`if'" != "" local ifand & 
	if "`if'" != "" local ifif if
	
	foreach var in `morevars' `controls' {
		local ifcond `" `ifcond' & `var' < . "'
		}
		
	* Lag control
	
	if "`lag'" != "" {
		local morevars L.\`var' `morevars'
		}	

* Set up spreadsheet header

if "`ci'" == "" {
	putexcel 	A1=(`title') ///
				A2=("Statistic") B2=("Control Group") D2=("Intervention Group") F2=("ITT Unadjusted") G2=("ITT Adjusted") ///
				B3=("N") C3=("Mean") D3=("N") E3=("Mean") F3=("Difference") G3=("Difference") ///
				`ivhead' ///
				`using', replace
	}
if "`ci'" != "" {
	putexcel 	A1=(`title') ///
				A2=("Statistic") B2=("Control Group") D2=("Intervention Group") F2=("ITT Unadjusted") H2=("ITT Adjusted") ///
				B3=("N") C3=("Mean") D3=("N") E3=("Mean") F3=("Difference") G3=("95% CI") H3=("Difference") I3=("95% CI") ///
				`ivhead' ///
				`using', replace
	}

* Regressions

qui foreach var of varlist `varlist' {

	local theLabel : var label `var'
	
	sum `var' if `treatment'==0 `ifcond' `ifand' `if' `in'
		local control_mean = string(round((1/`round')*`r(mean)',1)*`round')
		local control_sd = string(round((1/`round')*`r(sd)',1)*`round')
		local control_n = `r(N)'
	sum `var' if `treatment'==1 `ifcond' `ifand' `if' `in'
		local treatment_mean = string(round((1/`round')*`r(mean)',1)*`round')
		local treatment_sd = string(round((1/`round')*`r(sd)',1)*`round')
		local treatment_n = `r(N)'
		
	reg `var' `treatment' `morevars' `ifif' `if' `in', `options'
	
		mat regdata = r(table)
	
		local point_estimate = string(round((1/`round')*_b[`treatment'],1)*`round')
		local lower_limit = string(round((1/`round')*regdata[5,1],1)*`round')
		local upper_limit = string(round((1/`round')*regdata[6,1],1)*`round')
		local p_stat = regdata[4,1]
			local itt_p = string(round((1/`round')*regdata[4,1],1)*`round')
			local itt_se = string(round((1/`round')*_se[`treatment'],1)*`round')
			local stars = 0
			local theStars ""
			if `p_stat' < 0.1  local stars = 1
			if `p_stat' < 0.05 local stars = 2
			if `p_stat' < 0.01 local stars = 3
			if `stars' > 0 {
				local x = 0
				while `x' < `stars' {
					local theStars "`theStars'*"
					local ++x
					}
				}
			
			local pe = "`point_estimate'`theStars'"
			local pe_ci = "[`lower_limit' to `upper_limit']"
			
	if "`iv'" != "" {		
	
		ivregress 2sls `var' (`iv' = `treatment') `morevars' `ifif' `if' `in', `options'
		
			mat regdata = r(table)
		
			local point_estimate = string(round((1/`round')*_b[`iv'],1)*`round')
			local lower_limit = string(round((1/`round')*regdata[5,1],1)*`round')
			local upper_limit = string(round((1/`round')*regdata[6,1],1)*`round')
			local p_stat = regdata[4,1]
				local iv_p = string(round((1/`round')*regdata[4,1],1)*`round')
				local iv_se = string(round((1/`round')*_se[`iv'],1)*`round')
				local stars = 0
				local theStars ""
				if `p_stat' < 0.1  local stars = 1
				if `p_stat' < 0.05 local stars = 2
				if `p_stat' < 0.01 local stars = 3
				if `stars' > 0 {
					local x = 0
					while `x' < `stars' {
						local theStars "`theStars'*"
						local ++x
						}
					}
					
				local pe_iv = "`point_estimate'`theStars'"
				local ci_iv = "[`lower_limit' to `upper_limit']"
		} // iv option
			
	reg `var' `treatment' `morevars' `controls' `ifif' `if' `in', `options'
	
		mat regdata = r(table)
	
		local point_estimate = string(round((1/`round')*_b[`treatment'],1)*`round')
		local lower_limit = string(round((1/`round')*regdata[5,1],1)*`round')
		local upper_limit = string(round((1/`round')*regdata[6,1],1)*`round')
		local p_stat = regdata[4,1]
			local itt_ad_p = string(round((1/`round')*regdata[4,1],1)*`round')
			local itt_ad_se = string(round((1/`round')*_se[`treatment'],1)*`round')
			local stars = 0
			local theStars ""
			if `p_stat' < 0.1  local stars = 1
			if `p_stat' < 0.05 local stars = 2
			if `p_stat' < 0.01 local stars = 3
			if `stars' > 0 {
				local x = 0
				while `x' < `stars' {
					local theStars "`theStars'*"
					local ++x
					}
				}
				
			local pe_ad = "`point_estimate'`theStars'"
			local ci_ad = "[`lower_limit' to `upper_limit']"
			
	if "`iv'" != "" {		
	
		ivregress 2sls `var' (`iv' = `treatment') `morevars' `controls' `ifif' `if' `in', `options'
		
			mat regdata = r(table)
		
			local point_estimate = string(round((1/`round')*_b[`iv'],1)*`round')
			local lower_limit = string(round((1/`round')*regdata[5,1],1)*`round')
			local upper_limit = string(round((1/`round')*regdata[6,1],1)*`round')
			local p_stat = regdata[4,1]
				local iv_ad_p = string(round((1/`round')*regdata[4,1],1)*`round')
				local iv_ad_se = string(round((1/`round')*_se[`iv'],1)*`round')
				local stars = 0
				local theStars ""
				if `p_stat' < 0.1  local stars = 1
				if `p_stat' < 0.05 local stars = 2
				if `p_stat' < 0.01 local stars = 3
				if `stars' > 0 {
					local x = 0
					while `x' < `stars' {
						local theStars "`theStars'*"
						local ++x
						}
					}
					
				local pe_iv_ad = "`point_estimate'`theStars'"
				local ci_iv_ad = "[`lower_limit' to `upper_limit']"
		} // iv option
			
	* Print main results
	
		if "`ci'" == "" {	
			putexcel A`row'=("`theLabel'") ///
					 B`row'=(`control_n') C`row'=(`control_mean') D`row'=(`treatment_n') E`row'=(`treatment_mean') ///
					 F`row'=("`pe'") G`row'=("`pe_ad'") `ivstats' `using', modify
				}
		if "`ci'" != "" {	
			putexcel A`row'=("`theLabel'") ///
					 B`row'=(`control_n') C`row'=(`control_mean') D`row'=(`treatment_n') E`row'=(`treatment_mean') ///
					 F`row'=("`pe'") G`row'=("`pe_ci'") H`row'=("`pe_ad'") I`row'=("`ci_ad'") `ivstats' `using', modify
				}
					
			local ++row
			
	* Print options results
			
				`sdputexcel'
				`pputexcel'
				`ptputexcel'
				`anotherrow'
	
	} // Variable loop
	
	di "`ci'"

	
end

