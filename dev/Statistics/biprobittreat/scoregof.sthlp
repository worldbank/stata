{smcl}
{* *! version 1.0.0  28oct2009}{...}
{cmd:help scoregof}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:scoregof} {hline 2}}Score test of normality for probit and bivariate probit
{p2colreset}{...}

{title:Syntax}

{p 4 12 2} {cmd:scoregof} [{cmd:,} {opt boot:strap}{cmd:(}{it:#}{cmd:)}]

{title:Description}

{p 4 4 2}
{cmd:scoregof} is a postestimation command for {helpb probit}, {helpb dprobit},
and {helpb biprobit}.  It computes a goodness-of-fit score test.

{title:Option}

{p 4 8 2}
{cmd:bootstrap(}{it:#}{cmd:)} computes the {it:p}-value by bootstrapping the
test using the specified number of bootstrap replications.  If this option
is not specified, {it:p}-values are computed using an asymptotic chi-squared
distribution.

{title:Remarks}

{p 4 4 2}
{cmd:scoregof} cannot be used if {helpb probit}, {helpb dprobit},
or {helpb biprobit} was called with any of the following options:
{cmd:partial}, {cmd:offset}, {cmd:constraints}.

{p 4 4 2}
After {helpb biprobit}, the test still works if one of the left-hand-side
variables appears on the right side of the other equation.

{p 4 4 2}
The test is performed on the estimation sample.

{title:Saved results}

{pstd}
{cmd:scoregof} saves the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(scorestat)}}test statistic{p_end}
{synopt:{cmd:r(p)}}{it:p}-value{p_end}

{title:References}

{p 4 8 2}
Chiburis, R. C. (2009). "Score tests of normality in bivariate probit models: Comment and implementation," Working paper, University of Texas at Austin.

{p 4 8 2}
Murphy, A. (2007). "Score tests of normality in bivariate probit models," {it:Economics Letters} 95(3): 374-379.

{title:Also see}

{psee}
Online:  {manhelp probit R}, {manhelp dprobit R}, {manhelp biprobit R},
{manhelp probit_postestimation R:probit postestimation},
{manhelp biprobit_postestimation R:biprobit postestimation}
{p_end}

Richard Chiburis 10/28/2009