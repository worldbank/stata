* Figure A4. Trust in Westerners Earthquake Effect Mortality Bounding

	* This figure requires post-processing to add labels.
		
	set seed 474747

	use "$directory/data/analysis.dta", clear
		keep if touse_trust == 1 & indiv_adult == 1
		isid censusid memid, sort
		
		cap mat drop results
		
		preserve
		
		gen tempfar  = runiform() if indiv_dead == 1 & hh_far_from_quake == 1
		gen tempnear = runiform() if indiv_dead == 1 & hh_far_from_quake == 0

	forvalues i = 99(-1)50 {
		
		qui {	
		
			_pctile tempfar, p(`i')
				local cutfar = `r(r1)'
				
			_pctile tempnear, p(`i')
				local cutnear = `r(r1)'
			
			replace indiv_trust_note_h = 0 if indiv_dead == 1 & hh_far_from_quake == 0 & tempnear < `cutnear'
			replace indiv_trust_note_h = 1 if indiv_dead == 1 & hh_far_from_quake == 0 & tempnear >= `cutnear'
			
			replace indiv_trust_note_h = 1 if indiv_dead == 1 & hh_far_from_quake == 1 & tempfar < `cutfar'
			replace indiv_trust_note_h = 0 if indiv_dead == 1 & hh_far_from_quake == 1 & tempfar >= `cutfar'
			
			areg indiv_trust_note_h hh_near_quake hh_wealth_2 hh_wealth_1 indiv_male hh_epidist hh_slope hh_fault_minimum i.hh_district , cl(village_code) a(indiv_age)
			mat regdata = r(table)
				local b		= regdata[1,1]
				local l95 	= regdata[5,1]
				local u95 	= regdata[6,1]
				local p	 	= regdata[4,1]
					
			areg indiv_trust_note_h hh_near_quake hh_wealth_2 hh_wealth_1 indiv_male hh_epidist hh_slope hh_fault_minimum i.hh_district , cl(village_code) a(indiv_age) level(90)
			mat regdata = r(table)
				local b		= regdata[1,1]
				local l90 	= regdata[5,1]
				local u90 	= regdata[6,1]
				local p	 	= regdata[4,1]
					
			local pct = 100-`i'
			
		}
		
		mat results = nullmat(results) \ [`pct',`b',`l90',`u90',`l95',`u95',`p']
			mat colnames results = "i" "b" "l90" "u90" "l95" "u95" "p"
		
		}
		
	restore
	
	clear
	svmat results, n(col)
	
	tw 	(rarea l95 u95 i , fc(gs14) lc(gs14)) ///
		(rarea l90 u90 i , fc(gs12) lc(gs14)) ///
		(function 0 , range(i) lc(black) lp(dot)) ///
		(function 14.5 , range(-.05 .2) lc(black) lp(dash) hor) ///
		(function 42.5 , range(-.05 .2) lc(black) lp(dash) hor) ///
		(line b i ,lp(solid) lc(black)) ///
	,	$graph_opts legend(off) ytit("Treatment Effect (Near Fault)") xtit("Bounding Fraction")
	
	
	graph export "$directory/figures/Figure A4.png", replace width(3000)
		graph save "$directory/temp/Figure A4.gph", replace 
		
* Have a lovely day!
