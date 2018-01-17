** Generates random estimates of

cap prog drop randReg
prog def randReg , rclass

syntax anything [if] [in], 			/// Anything specifies the full regression model.
	Treatment(varname)						/// Specify binary treatment variable.
	[reps(integer 100)] 					/// Set number of reps.
	[strata(varname)]							/// Allow strata
	[Seed(integer -1)]			 			/// Set seed for randomization.
	[Round(real 0.01)]						/// Set rounding for graph.
[graph]													/// Turn on graph
	[ci(integer 95)]							/// Set size of confidence interval.
	[TITle(string asis)]					/// Specify title for graph.
	[SUBTITle(string asis)]				/// Specify subtitle for graph.
	[graphoptions(string asis)]		/// Any other graph options.
	[*]														/// Any other *estimation* options.


// Setup

	preserve

	set matsize `=`reps'+10'

	marksample touse
	qui keep if `touse'

	if `seed' != -1 {
		set seed `seed'
		}

	if "`strata'" == "" {
		tempvar fakestrata
		gen `fakestrata' = 1
		local strata " \`fakestrata' "
		}

	qui levelsof `strata' , local(thestrata)

// Get "true" regression estimate for plot

	qui `anything' , `options'
		local beta = _b[`treatment']
		local p = (2 * ttail(e(df_r), abs(_b[`treatment']/_se[`treatment'])))
		mat results =  `beta' , . , 0 // Initialize results matrix with "true" beta , no false beta, and indicator off
		local beta_disp = round(`beta',`round')
		local p1_disp = round(`p',`round')
	di "Regression from data:  B = `beta_disp'"
	di "Regression from data:  p = `p1_disp'"

// reps loop

	tempvar runiform
	tempvar placebos

	qui forvalues i = 1/`reps' {

		// Setup placebo treatment

			cap drop `placebos'
				gen `placebos' = 0

		// Set strata treatment proportions equal to true strata treatment proportions

			foreach level in `thestrata' {

				sum `treatment' if `strata' == `level'
				local freq_treatment = `r(mean)' * 100

				gen `runiform' = runiform()
					qui centile `runiform' , c(`freq_treatment')
					replace `placebos' = (`runiform' < `r(c_1)') if `strata' == `level'
					drop `runiform'

				}

		// Run false regression, including true treatment indicator (in main regression) fake treatment indicator (added) and strata indicators (added)

			qui `anything' `placebos' i.`strata' , `options'

			local beta_true = _b[`treatment']
			local beta_fake = _b[`placebos']

		mat results = results \ [`beta_true' , `beta_fake' , 1] // Append results matrix with "true" beta , false beta, and indicator on

		}

// Load and assess results

		clear
		mat colnames results = "true" "fake" "sim_touse"
		qui svmat results , names(col)

	// Recover true estimate

		qui sum true if sim_touse == 0
			local estimate = round(`r(mean)',`round')
			cap gen estimate = `estimate'


	// Print and store results

		qui	gen ttemp = abs(true)
		qui	gen ftemp = abs(fake)

		qui count if (ttemp <= ftemp) & sim_touse == 1
		local p2 = `r(N)'/`reps'
		local p2_disp = round(`p2',`round')

		di "Regression simulation: p = `p2_disp'"

		return scalar b = `beta'
		return scalar p_reg = `p'
		return scalar p_sim = `p2'

	// Graphical representation

	if "`graph'" == "graph" {

		// Get bounds of placebo estimates

			local lower = (100 - `ci')
			local upper = 100 - `lower'

			qui centile  fake if sim_touse == 1 , c(`lower' `upper')
				local lower = round(`r(c_1)',`round')
				local upper = round(`r(c_2)',`round')

			if `beta' > 0 {
				local place "upper"
				local label `"`upper' "`upper'""'
				* keep if fake >= 0
				}
			else {
				local place "lower"
				local label `"`lower' "`lower'""'
				* keep if fake <= 0
				}

		// Draw graph

			kdensity fake if sim_touse == 1 , gen(x y) nograph
			sort x
			tw  (kdensity fake if sim_touse == 1 , lc(black) ) , /// (scatter x estimate, ms(i)) , ///
				xline(``place'', lp(dash)) xline(`estimate') xlab( `estimate' `""{&beta}=""`estimate'""' 0 "0" `label' ) ///
				legend(off) ylab(none) bgcolor(white) graphregion(color(white) margin(large)) title("`title'", color(black) span) subtitle("`subtitle'", color(black) span) ///
				note("p = `p2'. Dashed line indicates one-sided `ci'% bound of `reps' placebo treatment estimates. ") `graphoptions' xtit(" ") ytit(" ")

		}

end

/*** DEMO

clear
set obs 1000
gen treat_rand = runiform()
gen treatment = treat_rand > 0.5
gen error = rnormal()
gen outcome = .3*treatment + 3*error
randReg reg outcome treatment , seed(4747) t(treatment) graph reps(100)
	graph export "randReg.png" , replace width(1000)
	return list

* Have a lovely day!
