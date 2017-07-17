// scoregof
// Postestimation command for -probit- and -biprobit-
// Richard C. Chiburis 11/1/2009
// Based on Murphy, "Score tests of normality in bivariate probit models," Economics Letters 2007.
// I corrected some typos in Murphy's paper--check documentation at https://webspace.utexas.edu/~rcc485/
//
// Usage:
// For asymptotic p-value:   scoregof
// For bootstrapped p-value: scoregof, bootstrap(#)
//
// Cannot be used if -probit-, -dprobit-, or -biprobit- was called with any of these options:
// partial, offset, constraints
program scoregof, rclass
  version 10.1
  syntax [, BOOTstrap(integer 0)]

  if missing(e(cmd)) {
    error 301
  }
  if e(cmd) != "probit" & e(cmd) != "dprobit" & e(cmd) != "biprobit"  {
    di as err "scoregof can only be called after probit, dprobit, or biprobit"
    exit 321
  }

  if e(cmd) == "probit" | e(cmd) == "dprobit" {
    tempname b numparams
    matrix `b' = e(b)
    scalar `numparams' = colsof(`b') + 2

    // Get the LHS variable
    local y = e(depvar)

    // Get the RHS variables
    local regressors : colnames e(b)
    local noconstant = ",noconstant"
    while 1 {
      gettoken regressori regressors : regressors
      if "`regressori'" == "" {
        continue, break
      }
      else if "`regressori'" == "_cons" {
        local noconstant
      }
      else {
        local x `x' `regressori'
      }
    }

    preserve
    quietly keep if e(sample)  // use only observations in the estimation sample

    // ml model statement is invoked so that mlvecsum and mlmatsum will work below,
    // but we don't re-run the maximization here; we just initialize with the
    // estimated parameters computed by -probit- previously.
    tempname b2 extraequation
    ml model d2 scoregof_null (`y':`y'=`x'`noconstant') /`extraequation'
    matrix coleq `b' = `y'
    matrix `b2' = 0
    matrix colnames `b2' = `extraequation':_cons
    matrix `b' = (`b', `b2')
    ml init `b'

    tempvar xb
    predict `xb', xb

    ********** Likelihood **********
    tempvar s fi
    tempname lnf
    qui gen byte `s' = 2 * `y' - 1
    qui gen double `fi' = normal(`s'*`xb')
    scalar `lnf' = 0  // only needed because mlvecsum and mlmatsum require this as an input but don't really use it

    ********** Gradient **********
    tempvar g1i g2i g3i
    qui gen double `g1i' = `s' * normalden(`xb') / `fi'
    qui gen double `g2i' = (`xb'^2 - 1) * `g1i' / 6
    qui gen double `g3i' = -(`xb'^3 - 3*`xb') * `g1i' / 24

    tempname gj g
    forvalues j = 1/3 {
      local eqj = min(`j', 2)
      mlvecsum `lnf' `gj' = `g`j'i', eq(`eqj')
      matrix `g' = (nullmat(`g'), `gj')
    }

    ********** Information Matrix **********
    tempvar Hi
    tempname Hs Hj Hjk negH
    qui gen double `Hi' = .
    matrix `negH' = J(`numparams', `numparams', 0)
    forvalues yy = 0/1 {
      qui replace `s'   = 2 * `yy' - 1
      qui replace `fi'  = normal(`s'*`xb')
      qui replace `g1i' = `s' * normalden(`xb') / `fi'
      qui replace `g2i' = (`xb'^2 - 1) * `g1i' / 6
      qui replace `g3i' = -(`xb'^3 - 3*`xb') * `g1i' / 24

      forvalues j = 1/3 {
        local eqj = min(`j', 2)
        forvalues k = 1/3 {
          local eqk = min(`k', 2)
          qui replace `Hi' = `fi' * `g`j'i' * `g`k'i'
          mlmatsum `lnf' `Hjk' = `Hi', eq(`eqj',`eqk')
          matrix `Hj' = (nullmat(`Hj'), `Hjk')
        }
        matrix `Hs' = (nullmat(`Hs') \ `Hj')
        matrix drop `Hj'
      }
      matrix `negH' = `negH' + `Hs'
      matrix drop `Hs'
    }

    ********** Test Statistic **********
    tempname M scorestat p
    matrix `M' = `g' * invsym(`negH') * `g''
    scalar `scorestat' = `M'[1,1]

    restore

    ********** p-value **********
    if `bootstrap' > 0 {
      scoregof_bootstrap1 `bootstrap' `scorestat'
    }

    di
    di as txt "Score goodness-of-fit test for probit"
    di

    if `bootstrap' > 0 {
      scalar `p' = r(p)
      di as txt "Score test statistic =" as res %8.2f `scorestat'
      di as txt "Bootstrapped p-value =  " as res %8.4f `p'
    }
    else {
      scalar `p' = chi2tail(2, `scorestat')
      di as txt _col(14) "chi2(2) =" as res %8.2f `scorestat'
      di as txt _col(10) "Prob > chi2 =  " as res %8.4f `p'
    }
    return scalar scorestat = `scorestat'
    return scalar p = `p'

  }
  else {
    tempname b numparams
    matrix `b' = e(b)
    scalar `numparams' = colsof(`b') + 9

    // Get the LHS variables
    local depvar = e(depvar)
    gettoken y1 depvar : depvar
    gettoken y2 depvar : depvar

    // Get the RHS variables
    local eqs : coleq e(b)
    local regressors : colnames e(b)
    local noconstant1 = ",noconstant"
    local noconstant2 = ",noconstant"
    while 1 {
      gettoken eqi eqs : eqs
      gettoken regressori regressors : regressors
      if "`eqi'" == "`y1'" {
        if "`regressori'" == "_cons" {
          local noconstant1
        }
        else {
          local x1 `x1' `regressori'
        }
      }
      else if "`eqi'" == "`y2'" {
        if "`regressori'" == "_cons" {
          local noconstant2
        }
        else {
          local x2 `x2' `regressori'
        }
      }
      else continue, break
    }

    preserve
    quietly keep if e(sample)  // use only observations in the estimation sample

    // ml model statement is invoked so that mlvecsum and mlmatsum will work below,
    // but we don't re-run the maximization here; we just initialize with the
    // estimated parameters computed by -biprobit- previously.
    ml model d2 bipr_lf (`y1':`y1'=`x1'`noconstant1') (`y2':`y2'=`x2'`noconstant2') /athrho
    ml init `b'

    tempvar xb1 xb2
    tempname rho sq1mrho
    predict `xb1', xb1
    predict `xb2', xb2
    scalar `rho' = e(rho)
    scalar `sq1mrho' = sqrt(1 - `rho'^2)

    ********** Likelihood **********
    tempvar s1 s2 sxb1 sxb2 srho fi
    tempname lnf
    qui gen byte `s1' = 2 * `y1' - 1
    qui gen byte `s2' = 2 * `y2' - 1
    qui gen double `sxb1' = `s1'*`xb1'
    qui gen double `sxb2' = `s2'*`xb2'
    qui gen double `srho' = `s1'*`s2'*`rho'
    qui gen double `fi' = binormal(`sxb1', `sxb2', `srho')
    scalar `lnf' = 0  // only needed because mlvecsum and mlmatsum require this as an input but don't really use it

    ********** Gradient **********
    tempvar T1i T2i T3i g1i g2i g3i g4i g5i g6i g7i g8i g9i g10i g11i g12i
    qui gen double `T1i'  = normalden(`sxb1') * normal((`sxb2'-`srho'*`sxb1') / `sq1mrho')
    qui gen double `T2i'  = normalden(`sxb2') * normal((`sxb1'-`srho'*`sxb2') / `sq1mrho')
    qui gen double `T3i'  = normalden(`sxb1') * normalden((`sxb2'-`srho'*`sxb1') / `sq1mrho') / `sq1mrho'
    qui gen double `g1i'  = `s1' * `T1i' / `fi'
    qui gen double `g2i'  = `s2' * `T2i' / `fi'
    qui gen double `g3i'  = `s1' * `s2' * `T3i' / `fi'
    qui gen double `g4i'  = `s1' * ((`sxb1'^2 - 1) * `T1i' - `srho' * ((`srho'^2-2)*`sxb1' + `srho'*`sxb2')*`T3i' / `sq1mrho'^2) / 6 / `fi'
    qui gen double `g5i'  = `s2' * (-`sxb1' + `srho'*`sxb2') * `T3i' / `sq1mrho'^2 / 2 / `fi'
    qui gen double `g6i'  = `s1' * (-`sxb2' + `srho'*`sxb1') * `T3i' / `sq1mrho'^2 / 2 / `fi'
    qui gen double `g7i'  = `s2' * ((`sxb2'^2 - 1) * `T2i' - `srho' * ((`srho'^2-2)*`sxb2' + `srho'*`sxb1')*`T3i' / `sq1mrho'^2) / 6 / `fi'
    qui gen double `g8i'  = (-`sxb1'*(`sxb1'^2 - 3)*`T1i' - `srho' * ((`srho'^4 - 3*`srho'^2 + 3)*`sxb1'^2 + (`srho'^3-3*`srho')*`sxb1'*`sxb2' + `srho'^2*`sxb2'^2 - (3-2*`srho'^2)*(1-`srho'^2))*`T3i' / `sq1mrho'^4) / 24 / `fi'
    qui gen double `g9i'  = `s1' * `s2' * (`sxb1'^2 - 2*`srho'*`sxb1'*`sxb2' + `srho'^2*`sxb2'^2 - (1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 6 / `fi'
    qui gen double `g10i' = -(`srho'*`sxb1'^2 - (1+`srho'^2)*`sxb1'*`sxb2' + `srho'*`sxb2'^2 - `srho'*(1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 4 / `fi'
    qui gen double `g11i' = `s1' * `s2' * (`sxb2'^2 - 2*`srho'*`sxb2'*`sxb1' + `srho'^2*`sxb1'^2 - (1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 6 / `fi'
    qui gen double `g12i' = (-`sxb2'*(`sxb2'^2 - 3)*`T2i' - `srho' * ((`srho'^4 - 3*`srho'^2 + 3)*`sxb2'^2 + (`srho'^3-3*`srho')*`sxb2'*`sxb1' + `srho'^2*`sxb1'^2 - (3-2*`srho'^2)*(1-`srho'^2))*`T3i' / `sq1mrho'^4) / 24 / `fi'

    tempname gj g
    forvalues j = 1/12 {
      local eqj = min(`j', 3)
      mlvecsum `lnf' `gj' = `g`j'i', eq(`eqj')
      matrix `g' = (nullmat(`g'), `gj')
    }

    ********** Information Matrix **********
    tempvar Hi
    tempname Hs Hj Hjk negH
    qui gen double `Hi' = .
    matrix `negH' = J(`numparams', `numparams', 0)
    forvalues yy1 = 0/1 {
      forvalues yy2 = 0/1 {
        qui replace `y1' = `yy1'
        qui replace `y2' = `yy2'
        drop `xb1' `xb2'
        predict `xb1', xb1  // recompute xb1, xb2 here in case of endogeneity (one y appears in the other x)
        predict `xb2', xb2
        qui replace `s1' = 2 * `y1' - 1
        qui replace `s2' = 2 * `y2' - 1
        qui replace `sxb1' = `s1'*`xb1'
        qui replace `sxb2' = `s2'*`xb2'
        qui replace `srho' = `s1'*`s2'*`rho'
        qui replace `fi' = binormal(`sxb1', `sxb2', `srho')
        qui replace `T1i'  = normalden(`sxb1') * normal((`sxb2'-`srho'*`sxb1') / `sq1mrho')
        qui replace `T2i'  = normalden(`sxb2') * normal((`sxb1'-`srho'*`sxb2') / `sq1mrho')
        qui replace `T3i'  = normalden(`sxb1') * normalden((`sxb2'-`srho'*`sxb1') / `sq1mrho') / `sq1mrho'
        qui replace `g1i'  = `s1' * `T1i' / `fi'
        qui replace `g2i'  = `s2' * `T2i' / `fi'
        qui replace `g3i'  = `s1' * `s2' * `T3i' / `fi'
        qui replace `g4i'  = `s1' * ((`sxb1'^2 - 1) * `T1i' - `srho' * ((`srho'^2-2)*`sxb1' + `srho'*`sxb2')*`T3i' / `sq1mrho'^2) / 6 / `fi'
        qui replace `g5i'  = `s2' * (-`sxb1' + `srho'*`sxb2') * `T3i' / `sq1mrho'^2 / 2 / `fi'
        qui replace `g6i'  = `s1' * (-`sxb2' + `srho'*`sxb1') * `T3i' / `sq1mrho'^2 / 2 / `fi'
        qui replace `g7i'  = `s2' * ((`sxb2'^2 - 1) * `T2i' - `srho' * ((`srho'^2-2)*`sxb2' + `srho'*`sxb1')*`T3i' / `sq1mrho'^2) / 6 / `fi'
        qui replace `g8i'  = (-`sxb1'*(`sxb1'^2 - 3)*`T1i' - `srho' * ((`srho'^4 - 3*`srho'^2 + 3)*`sxb1'^2 + (`srho'^3-3*`srho')*`sxb1'*`sxb2' + `srho'^2*`sxb2'^2 - (3-2*`srho'^2)*(1-`srho'^2))*`T3i' / `sq1mrho'^4) / 24 / `fi'
        qui replace `g9i'  = `s1' * `s2' * (`sxb1'^2 - 2*`srho'*`sxb1'*`sxb2' + `srho'^2*`sxb2'^2 - (1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 6 / `fi'
        qui replace `g10i' = -(`srho'*`sxb1'^2 - (1+`srho'^2)*`sxb1'*`sxb2' + `srho'*`sxb2'^2 - `srho'*(1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 4 / `fi'
        qui replace `g11i' = `s1' * `s2' * (`sxb2'^2 - 2*`srho'*`sxb2'*`sxb1' + `srho'^2*`sxb1'^2 - (1-`srho'^2)) * `T3i' / `sq1mrho'^4 / 6 / `fi'
        qui replace `g12i' = (-`sxb2'*(`sxb2'^2 - 3)*`T2i' - `srho' * ((`srho'^4 - 3*`srho'^2 + 3)*`sxb2'^2 + (`srho'^3-3*`srho')*`sxb2'*`sxb1' + `srho'^2*`sxb1'^2 - (3-2*`srho'^2)*(1-`srho'^2))*`T3i' / `sq1mrho'^4) / 24 / `fi'
        forvalues j = 1/12 {
          local eqj = min(`j', 3)
          forvalues k = 1/12 {
            local eqk = min(`k', 3)
            qui replace `Hi' = `fi' * `g`j'i' * `g`k'i'
            mlmatsum `lnf' `Hjk' = `Hi', eq(`eqj',`eqk')
            matrix `Hj' = (nullmat(`Hj'), `Hjk')
          }
          matrix `Hs' = (nullmat(`Hs') \ `Hj')
          matrix drop `Hj'
        }
        matrix `negH' = `negH' + `Hs'
        matrix drop `Hs'
      }
    }

    ********** Test Statistic **********
    tempname M scorestat p
    matrix `M' = `g' * invsym(`negH') * `g''
    scalar `scorestat' = `M'[1,1]

    restore

    ********** p-value **********
    if `bootstrap' > 0 {
      scoregof_bootstrap2 `bootstrap' `scorestat'
    }

    di
    di as txt "Murphy's score test for biprobit"
    di

    if `bootstrap' > 0 {
      scalar `p' = r(p)
      di as txt "Score test statistic =" as res %8.2f `scorestat'
      di as txt "Bootstrapped p-value =  " as res %8.4f `p'
    }
    else {
      scalar `p' = chi2tail(9, `scorestat')
      di as txt _col(14) "chi2(9) =" as res %8.2f `scorestat'
      di as txt _col(10) "Prob > chi2 =  " as res %8.4f `p'
    }
    return scalar scorestat = `scorestat'
    return scalar p = `p'
  }
end

program scoregof_bootstrap1, rclass
  args reps scorestat

  quietly {
    local cmdline = e(cmdline)

    // Get the LHS variable
    local y = e(depvar)

    tempname holdname
    _estimates hold `holdname', copy restore 
    preserve

    tempvar p1
    predict `p1', pr

    tempname higher
    scalar `higher' = 0
    forvalues boot = 1/`reps' {
      replace `y' = (uniform() < `p1')
      `cmdline'
      scoregof
      if r(scorestat) > `scorestat' {
        scalar `higher' = `higher' + 1
      }
    }

    return scalar p = (`higher' + 0.5) / (`reps' + 1)
  }   
end

program scoregof_bootstrap2, rclass
  args reps scorestat

  quietly {
    local cmdline = e(cmdline)

    // Get the LHS variables
    local depvar = e(depvar)
    gettoken y1 depvar : depvar
    gettoken y2 depvar : depvar

    tempname holdname
    _estimates hold `holdname', copy restore 
    preserve

    tempvar p00 p01 p10 p11 u
    forvalues yy1 = 0/1 {
      forvalues yy2 = 0/1 {
        replace `y1' = `yy1'
        replace `y2' = `yy2'
        predict `p`yy1'`yy2'', p`yy1'`yy2'
      }
    }
    gen double `u' = .

    tempname higher
    scalar `higher' = 0
    forvalues boot = 1/`reps' {
      replace `u' = uniform()
      replace `y1' = (`u' >= `p00' + `p01')
      replace `y2' = ((`u' >= `p00' & `u' < `p00' + `p01') | `u' >= `p00' + `p01' + `p10')
      `cmdline'
      scoregof
      if r(scorestat) > `scorestat' {
        scalar `higher' = `higher' + 1
      }
    }

    return scalar p = (`higher' + 0.5) / (`reps' + 1)
  }   
end
