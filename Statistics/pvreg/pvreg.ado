* Version 1, 5.30.2013
* Aakash Mohpal
* Regression Coefficient and Standard Errors with Five Plausible Values

cap: program drop pvreg
cap: clear matrix

program define pvreg

syntax [varlist] [if] [in], [theta(string) cluster(string)]

	local npv: word count `theta'
	if `npv'<5|`npv'>5 {
		di as error "Number of PV scores specified is `npv' (exactly 5 required)"
		exit 198
		}

	tokenize `theta'
	local j=0
	forvalues i=1/5{
		local j=`j'+1
		qui: reg ``i'' `varlist', cl(`cluster') robust 
		mat b`j'=(e(b))'
		mat v`j'=(vecdiag(e(V)))'
		local n`j'=e(N)
		}	
	mata: pv()
	
	mat rownames est=`varlist' _cons
	mat colnames est=Coef RobustSE
	di ""
	di ""
	di ""
	di ""
	di "Corrected Coefficients and Standard Errors"
	di "(also stored in matrix 'est')"
	di ""
	di "Number of observations: `n5'"
	di "Fixed effects: `fe'"
	matlist est

end

version 9
cap mata: mata drop pv()
mata:

void pv()
	
	{
		b1 = st_matrix("b1")
		b2 = st_matrix("b2")
		b3 = st_matrix("b3")
		b4 = st_matrix("b4")
		b5 = st_matrix("b5")
		v1 = st_matrix("v1")
		v2 = st_matrix("v2")
		v3 = st_matrix("v3")
		v4 = st_matrix("v4")
		v5 = st_matrix("v5")
		
		b=(b1+b2+b3+b4+b5):/5
		v=(v1+v2+v3+v4+v5):/5
		imp=(((b-b1):^2)+((b-b2):^2)+((b-b3):^2)+((b-b4):^2)+((b-b5):^2)):/4
		se=(v+(imp:*1.2)):^0.5
		
		est=b,se
		
		st_matrix("est",est)
	}

end

// Example Syntax:  
// pvreg public mbbs, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
// pvreg public mbbs, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
// pvreg public mbbs, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)
// pvreg public mbbs ssp1-ssp15 vill1-vill160, theta(theta_pv1 theta_pv2 theta_pv3 theta_pv4 theta_pv5) cluster(villid)

