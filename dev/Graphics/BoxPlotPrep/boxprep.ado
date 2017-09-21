* Barprep

cap prog drop boxprep
prog def boxprep

syntax anything [if] [in] , global(string asis) color(string asis) [f(real -2)] [p(real 0.2)]

	qui sum `anything' `if' `in', d
	
	gen `global'f= `f'          
		gen `global'pmin=r(p5)
		gen `global'p25=r(p25)
		gen `global'p50=r(p50)
		gen `global'p75=r(p75)
		gen `global'pmax=r(p95)
		gen `global'pmean=r(mean)
		gen `global'iqrmax = (1.5 * `global'p75 - `global'p25) + `global'p75
		
		replace `global'pmax = `global'iqrmax if `global'iqrmax < `global'pmax
		
	global `global' "(rcap `global'pmin `global'p25 `global'f in 1, msize(3) hor bcolor(`color'))(rbar `global'p25 `global'p75 `global'f in 1, barwidth(`p') hor bcolor(none) lp(solid) lw(thin) lc(`color'))(rcap `global'p50 `global'p50 `global'f in 1, msize(3) hor bcolor(`color'))(rcap `global'p75 `global'pmax `global'f in 1, msize(3) hor bcolor(`color'))"

	di in red "Saved as: \$`global'"
	
end

boxprep po_quality, global(test2) color(red)




* Have a lovely day!
