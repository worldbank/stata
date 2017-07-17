// BPHLTEST
// Postestimation command for BIPROBIT
//
// Implements a modified Hosmer-Lemeshow goodness-of-fit test for biprobit.
// It can handle if either outcome variable appears as an endogenous variable
// in the other equation.  Operates on the estimation sample.
//
// Options:
//   groups1()  The number of groups to use for equation 1; default is 3
//   groups2()  The number of subgroups to use for equation 2; default is 3
//
// Richard Chiburis ~ October 8, 2009
program bphltest, rclass
  version 10.1
  syntax [, GROUPS1(integer 3) GROUPS2(integer 3)]

  if missing(e(cmd)) {
    error 301
  }
  if e(cmd) != "biprobit" {
    di as err "bphltest can only be called after biprobit"
    exit 321
  }
  if `groups1' * `groups2' < 3 {
    di as err "groups1*groups2 must be at least 3"
    exit 198
  }

  local depvar = e(depvar)
  gettoken y1 depvar : depvar
  gettoken y2 depvar : depvar

  preserve
  quietly keep if e(sample)  // use only observations in the estimation sample

  tempname rhohat
  scalar `rhohat' = e(rho)
  tempvar xb1 xb1g xb2 xb2g p11 p10 p01 p00 p1 p2 g1 g2 y11 y10 y01 y00 pearsonstat
  predict `xb1', xb1
  gen double `xb1g' = `xb1'
  quietly cap replace `xb1' = `xb1' - `y2' * _b[`y1':`y2']  // handle when y2 appears in y1 equation
  quietly cap replace `xb1g' = `xb1' + _b[`y1':`y2']        // handle when y2 appears in y1 equation
  predict `xb2', xb2
  gen double `xb2g' = `xb2'
  quietly cap replace `xb2' = `xb2' - `y1' * _b[`y2':`y1']  // handle when y1 appears in y2 equation
  quietly cap replace `xb2g' = `xb2' + _b[`y2':`y1']        // handle when y1 appears in y2 equation
  gen double `p11' = binormal( `xb1g',  `xb2g',  `rhohat')
  gen double `p10' = binormal( `xb1' , -`xb2g', -`rhohat')
  gen double `p01' = binormal(-`xb1g',  `xb2' , -`rhohat')
  gen double `p00' = binormal(-`xb1' , -`xb2' ,  `rhohat')
  gen double `p1' = `p11' + `p10'
  gen double `p2' = `p11' + `p01'

  sort `p1'
  gen `g1' = floor((_n-1) * `groups1' / _N)
  sort `g1' `p2'
  gen `g2' = floor((_n-1) * `groups1' * `groups2' / _N)

  gen `y11' = (`y1' == 1 & `y2' == 1)
  gen `y10' = (`y1' == 1 & `y2' == 0)
  gen `y01' = (`y1' == 0 & `y2' == 1)
  gen `y00' = (`y1' == 0 & `y2' == 0)

  collapse (sum) `p11' `p10' `p01' `p00' `y11' `y10' `y01' `y00', by(`g1' `g2')
  gen `pearsonstat' = (`y11' - `p11')^2 / `p11' + (`y10' - `p10')^2 / `p10' + (`y01' - `p01')^2 / `p01' + (`y00' - `p00')^2 / `p00'

  quietly summarize `pearsonstat'

  tempname hlstat df p
  scalar `hlstat' = r(sum)
  di
  di as txt "Modified Hosmer-Lemeshow goodness-of-fit test for biprobit"
  di
  scalar `df' = 3*(`groups1'*`groups2' - 2)
  scalar `p' = chi2tail(`df', `hlstat')
  di as txt _col(12) "chi2(" %3.0f `df' ") =" as res %8.2f `hlstat'
  di as txt _col(10) "Prob > chi2 =  " as res %8.4f `p'
  return scalar hlstat = `hlstat'
  return scalar p = `p'

  restore
end
