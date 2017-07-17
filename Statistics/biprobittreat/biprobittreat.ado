#delim;
/* BIPROBITTREAT
 * Treatment effects in bivariate probit model
 *
 * Call with same syntax as -biprobit-.  The first equation is assumed to be
 * the outcome equation, and the second equation is assumed to be the 
 * treatment equation.
 *
 * Saved results:
 *   r(ate): average treatment effect
 *   r(att): average treatment effect on the treated
 *
 * Bootstrapping the confidence intervals is highly recommended.
 * To obtain bootstrapped confidence intervals, use the following commands:
 *   bootstrap _b ate=r(ate) att=r(att), reps(199): biprobittreat <biprobit arguments>
 *   estat bootstrap, percentile
 *   
 * Richard Chiburis ~ October 30, 2009
 */
program define biprobittreat, rclass;
syntax anything [, *];

biprobit `anything', `options';
tempvar tmpT xb1g xb1 xb2 tev;
tempname rhohat;
scalar `rhohat' = e(rho);

local depvar = e(depvar);
gettoken Y depvar : depvar;
gettoken T depvar : depvar;

predict `xb2', xb2;
preserve;
qui gen `tmpT' = `T';
qui replace `T' = 0;
predict `xb1', xb1;
qui replace `T' = 1;
predict `xb1g', xb1;
qui replace `T' = `tmpT';

qui gen double `tev' = (binormal(`xb1g', `xb2', `rhohat') - binormal(`xb1', `xb2', `rhohat')) / normal(`xb2') if `T' == 1;
summ `tev', meanonly;
return scalar att = r(mean);
qui replace `tev' = normal(`xb1g') - normal(`xb1');
summ `tev', meanonly;
return scalar ate = r(mean);

end;