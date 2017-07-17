* Example code using OpenIRT

* Install:
cap program drop openirt
net install http://www.people.fas.harvard.edu/~tzajonc/stata/openirt/openirt, force

clear
set mem 50m

* Save 12 NAEP items locally
sysuse naep_items, clear
save naep_items, replace
count

* Easier to mix and match with c=0 for 2PL
recode c (.=0)

** DEMO 1: Item characteristic curves

* 2PL ICC (row 3)
twoway (function 1/(1+exp(-1.7*a[3]*(x-b[3]))), range(-4 4)), ///
	xtitle("Theta") ytitle("P(X=1|Theta)") title("Item Characteristic Curve")

* overlay two ICCs
twoway (function 1/(1+exp(-1.7*a[3]*(x-b[3]))), range(-4 4)) ///
	(function 1/(1+exp(-1.7*a[4]*(x-b[4]))), range(-4 4)), ///
	xtitle("Theta") ytitle("P(X=1|Theta)") title("Item Characteristic Curve") ///
	legend(order(1 "Item 16" 2 "Item 17"))
	
* 2pl and 3PL curve
twoway (function 1/(1+exp(-1.7*a[3]*(x-b[3]))), range(-4 4)) ///
	(function c[1] + (1-c[1])/(1+exp(-1.7*a[1]*(x-b[1]))), range(-4 4)), ///
	xtitle("Theta") ytitle("P(X=1|Theta)") title("Item Characteristic Curve") ///
	legend(order(1 "Item 16" 2 "Item 12"))

** Demo 2: Item information curves

* 2PL IIC
local i = 3
local iic2pl "(1.7*a[`i'])^2*(1/(1+exp(-1.7*a[`i']*(x-b[`i']))))*(1-(1/(1+exp(-1.7*a[`i']*(x-b[`i'])))))"
twoway (function `iic2pl', range(-4 4)), ///
	xtitle("Theta") ytitle("I(Theta)") title("Item Information Curve")

* 3PL IIC
local i = 2
local p "(c[`i']+(1-c[`i'])/(1+exp(-1.7*a[`i']*(x-b[`i']))))"
local iic3pl "((1.7*a[`i'])^2*(1-`p')/`p')*((`p'-c[`i'])/(1-c[`i']))^2"
twoway (function `iic3pl', range(-4 4)), ///
	xtitle("Theta") ytitle("I(Theta)") title("Item Information Curve")

* Multiple graphs
forvalues i = 1/9 {
	local title = "Item " + string(id[`i'])
	local p "(c[`i']+(1-c[`i'])/(1+exp(-1.7*a[`i']*(x-b[`i']))))"
	local iic3pl "((1.7*a[`i'])^2*(1-`p')/`p')*((`p'-c[`i'])/(1-c[`i']))^2"
	twoway (function `iic3pl', range(-5 5)), ///
		xtitle("Theta") ytitle("I(Theta)") title("`title'")
	graph save tmp`i', replace
}
graph combine tmp1.gph tmp2.gph tmp3.gph tmp4.gph tmp5.gph tmp6.gph tmp7.gph tmp8.gph tmp9.gph, ycommon xcommon

* Test information
replace c = 0 if c==.
local tif "0"
forvalues i = 1/12 {
	local p "(c[`i']+(1-c[`i'])/(1+exp(-1.7*a[`i']*(x-b[`i']))))"
	local iic3pl "((1.7*a[`i'])^2*(1-`p')/`p')*((`p'-c[`i'])/(1-c[`i']))^2"
	local tif "`tif'+`iic3pl'"
}
local se "1/sqrt(`tif')"
twoway (function `tif', range(-4 4)) /// 
	(function `se', range(-4 4) yaxis(2)), ///
	xtitle("Theta") ytitle("I(Theta)") title("Test Information") ytitle("Standard Error", axis(2)) ///
	legend(order(1 "Test Information" 2 "Expected Standard Error"))

** Demo 3: Test characteristic curve
replace c = 0 if c==.
local tcc "0"
forvalues i = 1/12 {
	local p "(c[`i']+(1-c[`i'])/(1+exp(-1.7*a[`i']*(x-b[`i']))))"
	local tcc "`tcc'+`p'/12"
}
twoway (function `tcc', range(-4 4)), /// 
	xtitle("Theta") ytitle("Percent Correct") title("Test Characteristic Curve")

** DEMO 4: Estimating IRT models using OpenIRT

* load response data
sysuse naep_children, clear

* Preliminary exploration: percent correct score
egen percent_correct = rowmean(item*)
kdensity percent_correct, xtitle("Percent Correct") title(NAEP Percent Correct Score Distribution)

* Often useful to check that items are positive correlated 
* with percent correct score
corr percent_correct item*

* Read help...
help openirt

* Example 1: Estimate both item parameters and ability for single test
openirt, id(id) item_prefix(item) save_item_parameters("items.dta") save_trait_parameters("traits.dta")

* Merge in ability estimates
merge id using traits, sort

* Compare distributions using different estimates
	
* Multiple plausible values can be combined to form better
* kdensity estimate.  Using one plausible value works better though too.
kdensity(theta_pv1), bw(.4) gen(x1 d1)
kdensity(theta_pv2), bw(.4) gen(x2 d2) at(x1)
kdensity(theta_pv3), bw(.4) gen(x3 d3) at(x1)
kdensity(theta_pv4), bw(.4) gen(x4 d4) at(x1)
kdensity(theta_pv5), bw(.4) gen(x5 d5) at(x1)
egen d = rowmean(d*)
line(d x1)

twoway (kdensity theta, bw(.4)) (kdensity theta_eap, bw(.4)) ///
	(line d x1) (kdensity theta_mle, bw(.4)), ///
	xtitle("Theta") title("True Theta vs EAP, PV, MLE Estimates") ///
	legend(order(1 "True" 2 "EAP" 3 "PV" 4 "MLE"))

drop x* d*

* QQ plot distribution comparisons
qqplot(theta_eap theta), xtitle("Theta (True)") ytitle("Theta (EAP)") title("") saving(tmp1.gph, replace)
qqplot(theta_mle theta), xtitle("Theta (True)") ytitle("Theta (MLE)") title("") saving(tmp2.gph, replace)
qqplot(theta_pv1 theta), xtitle("Theta (True)") ytitle("Theta (PV1)") title("") saving(tmp3.gph, replace)
qqplot(theta_pv2 theta), xtitle("Theta (True)") ytitle("Theta (PV2)") title("") saving(tmp4.gph, replace)
graph combine tmp1.gph tmp2.gph tmp3.gph tmp4.gph

* Graph TRUE vs EAP
twoway (scatter theta_eap theta) (function y=x, range(-3 3)), ///
	xtitle("Theta (True)") ytitle("Theta (EAP)") title("") ///
  text(3 3 "y = x", place(e)) legend(off)

* Graph TRUE vs MLE
twoway (scatter theta_mle theta) (function y=x, range(-3 3)), ///
	xtitle("Theta (True)") ytitle("Theta (MLE)") title("") ///
  text(3 3 "y = x", place(e)) legend(off)

* Example 2: Link two test forms
sysuse naep_children, clear

* Simulate two test forms by setting some responses to missing
* Must leave some common items.
recode item1-item6 (0/1=.) if _n <= 250
recode item7-item13 (0/1=.) if _n >250

* Estimate
openirt, id(id) item_prefix(item) save_item_parameters("items.dta") save_trait_parameters("traits.dta")

* Merge in ability estimates
merge id using traits, sort

* Graph TRUE vs EAP
twoway (scatter theta_eap theta) (function y=x, range(-3 3)), ///
	xtitle("Theta (True)") ytitle("Theta (EAP)") title("") ///
  text(3 3 "y = x", place(e)) legend(off)

* Graph TRUE vs MLE
twoway (scatter theta_mle theta) (function y=x, range(-3 3)), ///
	xtitle("Theta (True)") ytitle("Theta (MLE)") title("") ///
  text(3 3 "y = x", place(e)) legend(off)

* Example 3: Link to TIMSS using test formed from TIMSS item bank.
sysuse timss_items, clear
save fixed_items, replace
sysuse timss_children, clear
openirt, id(id) save_item_parameters("items.dta") save_trait_parameters("traits.dta") ///
	fixed_item_file("fixed_items.dta") item_prefix(q)
* load results
use traits, clear
* place on TIMSS scale (mu=500 sd=100), see TIMSS 1999.
foreach x of varlist theta_eap theta_mle theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5 {
	replace `x' = `x'*100 + 500
}

kdensity(theta_pv1), bw(15) gen(x1 d1)
kdensity(theta_pv2), bw(15) gen(x2 d2) at(x1)
kdensity(theta_pv3), bw(15) gen(x3 d3) at(x1)
kdensity(theta_pv4), bw(15) gen(x4 d4) at(x1)
kdensity(theta_pv5), bw(15) gen(x5 d5) at(x1)
egen d = rowmean(d*)
line(d x1)

twoway (kdensity theta_eap, bw(20)) ///
	(line d x1) (kdensity theta_mle, bw(20)), ///
	xtitle("Theta") title("EAP, PV, MLE Estimates") ///
	legend(order(1 "EAP" 2 "PV" 3 "MLE"))

drop x* d*
