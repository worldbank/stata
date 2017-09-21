* Test

clear
version 13
* Create test dataset with missing lat/lon observations

	set obs 1000
	gen x = rnormal() * 0.010
	gen y = rnormal() * 0.010
	
	set obs 1500 // missings
	gen id = _n //ids

* Set up initial groups based on x/y - make sure to save the centers into the dataset

	zcenter, id(id) x(x) y(y) maxdistance(1) gen(group) latlon center(center)
	
	ta group center , m
	
	levelsof group , local(groups)
	
	foreach group in `groups' {
		local theList "`theList' (scatter x y if group == `group')"
		}
		
	tw `theList' (scatter x y if center == 1 , mlc(black) mc(none)) ///
		, legend(off) $graph_opts // xlab(-0.1(0.02)0.1) ylab(-0.1(0.02)0.1)
-
* Add new data in previously missing obs and add them to the markets

	replace x = rnormal() * 0.040 if x == .
	replace y = rnormal() * 0.010 if y == .

	* run zcenter again, specifying the name of the existing center variable and the 'append' option
	zcenter, id(id) x(x) y(y) maxdistance(3) gen(group) latlon center(center) append 
	
	ta group center , m
	

	ta group , m
	
* Visualization (centers are highlighted with black circles)

	levelsof group , local(groups)
	
	foreach group in `groups' {
		local theList "`theList' (scatter x y if group == `group')"
		}
		
	tw `theList' (scatter x y if center == 1 , mlc(black) mc(none)) ///
		, legend(off) $graph_opts xlab(-0.1(0.02)0.1) ylab(-0.1(0.02)0.1)

* Have a lovely day!
