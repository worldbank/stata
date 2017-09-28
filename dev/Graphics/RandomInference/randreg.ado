** Generates random estimates of

cap prog drop randreg
prog def randreg

syntax anything [if] [in], 			/// Anything specifies the full regression model.
	Treatment(varname)				/// Specify binary treatment variable.
	[Iterations(integer 100)] 		/// Set number of iterations.
	[Seed(integer -1)]			 	/// Set seed for randomization.
	[Round(real 0.01)]				/// Set rounding for graph.
	[ci(integer 95)]				/// Set size of confidence interval.
	[TITle(string asis)]			/// Specify title for graph.
	[SUBTITle(string asis)]			/// Specify subtitle for graph.
	[graphoptions(string asis)]		/// Any other graph options.
	[*]								/// Any other estimation options.

// Setup

	preserve

	sum `treatment'
		local freq_treatment = `r(mean)' * 100

	marksample touse
	keep if `touse'

	if `seed' != -1 {
		set seed `seed'
		}

	`anything' , `options'

	local beta = _b[`treatment']

	mat results = `beta' , 1

	tempvar runiform

	forvalues i = 1/`iterations' {

		cap drop `treatment'
		cap drop `runiform'

		gen `runiform' = runiform()
			qui centile `runiform' , c(`freq_treatment')
			gen `treatment' = (`runiform' < `r(c_1)')

		qui `anything' , `options'

		local beta = _b[`treatment']

		mat results = results \ [`beta' , 0]

		}

	clear

	qui svmat results

	qui sum results1 if results2
		local estimate = round(`r(mean)',`round')
		cap gen estimate = `estimate'

		local lower = (100 - `ci') / 2
		local upper = 100 - `lower'

	qui centile  results1 if !results2, c(`lower' `upper')
		local lower = round(`r(c_1)',`round')
		local upper = round(`r(c_2)',`round')

	kdensity results1 if !results2, gen(x y) nograph
	sort x
	tw  (kdensity results1 if !results2 , lc(black) ) (scatter x estimate, ms(i)) , ///
		xline(`lower' `upper', lp(dash)) xline(`estimate') xlab( `estimate' "Observed: `estimate'" 0 "0" `lower' "`lower'" `upper' "`upper'") ///
		legend(off) ylab(none) graphregion(color(white) margin(large)) title("`title'", color(black) span) subtitle("`subtitle'", color(black) span) ///
		note("Dashed lines indicate `ci'% bounds of `iterations' randomized placebo treatment estimates.") `graphoptions'

end
