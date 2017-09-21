** PPS with special sauce

cap prog drop ppsplus
prog def ppsplus

syntax anything , Size(varname) Number(string asis) Weight(string asis) [seed(integer 474747)]

set seed `seed'
sort `size'
tempvar id
	gen `id' = _n

qui sum `size'
tempvar dsize
gen `dsize' = `r(max)' - `size'

set seed `seed'	
sort `size'
tempvar cumulative_size
	gen `cumulative_size' = sum(`size')
	tempvar i2
	gen `i2' = -`cumulative_size'

set seed `seed'
sort `dsize' `i2'

	tempvar nsample
		gen `nsample' = `number' + 1 - _n
		replace `nsample' = 0 if `nsample' < 0
		
	tempvar toobig
		gen `toobig' = ( (`size'/`cumulative_size') > (1/`nsample') )
		
		qui count if `toobig'
		local ppsremainder = `number' - `r(N)'
		local ppsstart = `r(N)' + 1
		
	tempvar ppssample
	set seed `seed'
	samplepps `ppssample' in `ppsstart'/l, size(`size') n(`ppsremainder')

* Clean up sampled set and remerge	
	
	preserve
		keep if `toobig' == 1 | `ppssample' == 1
		
		* Generate Weights
			qui sum `cumulative_size'
			local cu_max =  `r(max)'
				gen `weight' = `size'/`cu_max' if `toobig' == 1
				
			qui sum `cumulative_size' if `toobig' == 0
				replace `weight' = (`r(max)'/`cu_max')*(1/`ppsremainder') if `weight' == .
					label var `weight' "Weight"
					
		tempfile sampled
			save `sampled', replace
	
	restore
	
	merge 1:1 `id' using `sampled'
		recode _m (3 = 1 "Sampled")(1 = 0 "Not Sampled"), gen(`anything')
			label var `anything' "Sampled"
			
			drop _m
		
		
		
end
