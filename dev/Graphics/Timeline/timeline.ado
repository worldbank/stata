* Timeline graphing

cap prog drop timeline
	prog def  timeline

	syntax using, [*]
	
	/* Required Excel fields are start_date (MDY, required), end_date (MDY, may be left blank), event title, and height (may be blank). */
	/* twoway_options are accepted as usual. */
	
	* Load

		import excel `using', clear first
	
	* Datetime setup

		replace end_date=start_date if end_date==""

		gen start=date(start_date,"MDY")
		gen end=date(end_date,"MDY")

		format start %tddd_Mon_YY
		format end %tddd_Mon_YY
	
	* Height calculations
		
		replace height = 1-height // Any heights entered put 1 at top and 0 at bottom
		
		qui count if height == .
			local check = 1/`r(N)'
			
		sort height start
		
		replace height = -1+(0.75*`check'*_n) if height == .
		
	* Placeholders
	
		gen zero=0
		gen max=-1.5*height
		gen datemax = end + 70
	
	* Set up duration lines
	
		qui count
			forvalues i = 1/`r(N)' {
				local checkstart = start in `i'
				local checkend = end in `i'
				local checkheight = height in `i'
				
				if `checkstart' != `checkend' {
					local lines "`lines' (function y=`checkheight' , range(`checkstart' `checkend') lc(black) lp(dash))"
					}
			}
	
	* Graph
	
		tw ///
			(dropline height start, ///
				mlab(event) mlabgap(0) mlabpos(1) mlabsize(vsmall) mlabang(0) m(none) mlabc(black) lc(black) mfc(white)) ///
			`lines' ///
			(scatter height datemax, m(none)) (scatter zero start, m(none)) ///
			, legend(off) ylab(none) xtit("") ytit("") `options'

end

	- // Example

	timeline using "/Users/bbdaniels/Dropbox/worldbank/adofiles/Graphics/Timeline/timeline.xlsx" , $graph_opts fysize(35)
		graph save "/Users/bbdaniels/Dropbox/worldbank/adofiles/Graphics/Timeline/a.gph" , replace
		
		graph combine ///
			"/Users/bbdaniels/Dropbox/worldbank/adofiles/Graphics/Timeline/b.gph" ///
			"/Users/bbdaniels/Dropbox/worldbank/adofiles/Graphics/Timeline/a.gph" ///
			, c(1) $graph_opts1 xcom graphregion(color(white)) ///
			imargin(0 0 0 0)
			
		graph export "/Users/bbdaniels/Dropbox/worldbank/adofiles/Graphics/Timeline/com.png" , width(2000) replace

* Have a lovely day!
