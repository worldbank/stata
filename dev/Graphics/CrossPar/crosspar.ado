* Cross-partials

cap prog drop crosspar
prog def crosspar
syntax anything , [controls(string asis)] [scatter]

	local graph_opts title(, justification(left) color(black) span pos(11)) graphregion(color(white)) ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) legend(region(lc(none) fc(none)))
	tempvar resid iresid
	
	* Loop over variables
	
		local x = 0
		
		unab anything : `anything'
		foreach var in `anything' {
			local indepvars = subinstr(" `anything' "," `var' "," ",.)
			
			local y = 0
			foreach indepvar in `indepvars' {
				local oindepvars = subinstr(" `indepvars' "," `indepvar' "," ",.)
				
				local ++x
				local ++y
				
				* Regress and predict residuals
				
				di in red "`x': `var' – `oindepvars' – `indepvar'"
				
				qui reg `var' `oindepvars' `controls' 
					cap drop `resid'
					qui predict `resid' , resid
						qui su `var' if e(sample)
						qui replace `resid' = `resid' + `r(mean)' // Shift to overall mean
						
				qui reg `indepvar' `oindepvars' `controls' 
					cap drop `iresid'
					qui predict `iresid' , resid
						qui su `indepvar' if e(sample)
						qui replace `iresid' = `iresid' + `r(mean)' // Shift to overall mean
					
				* Graph scatter of residuals
					
					local ytit : var label `var'
					local xtit : var label `indepvar'
					local title ""
						if `y' == 1 local title "`ytit'"
					if "`scatter'" != "" local theScatter "(scatter `resid' `iresid' , m(.) msize(tiny) jitter(5) mc(gray))"
					if "`scatter'" == "" local theScatter "(lfit `resid' `iresid' , lc(gray) lp(dash) lw(medthick))"
					
					qui reg `resid' `indepvar' `oindepvars' `controls' 
					local b = round(_b[`indepvar'],0.01)
					mat a = r(table)
						local p = a[4,1]
						local p = round(`p',0.001)
					if "`scatter'" == "" local theLabel "{&beta} = `b' ; p = `p'"
					
					tw ///
						`theScatter' ///
						(lpoly `resid' `iresid' , lw(thick) lc(maroon)) ///
						, title({bf:`title'}) ytit(" ") xtit("{bf:`xtit' {&rarr}}" "`theLabel'") legend(off) `graph_opts'  nodraw
					
						qui graph save __`x'.gph, replace
						
						local theGraphs "`theGraphs' __`x'.gph"
					
				}
						
			}
		
	* Diagonal gaps in combine
	
		local n : word count `anything'
		local check = `x' + `n'
			
		forvalues i = 1/`check' {
			forvalues row = 1/`n' {	
				if (`i' == (`n')*(`row'-1)+`row') local theGaps "`theGaps' `i'"	
				}	
			}
			
	* Combine graph
		
		graph combine `theGraphs' , graphregion(color(gs14)) holes(`theGaps') r(`n') colfirst
		
	* Clean up
	
		qui forvalues i = 1/`x' {
			!rm __`i'.gph
			}
					
end

* Have a lovely day!
