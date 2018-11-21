{smcl}
{* Nov 21st 2018}
{hline}
Help for {hi:tornado}
{hline}

{title:Description}

{p}{cmd: tornado} reports regression results as a modified "tornado" chart.
This chart shows the effect of a single treatment variable on a range of independent variables.
It can display raw coefficients, standardized effect sizes (Cohen's {it:d}), or odds ratios (from logistic regressions).{p_end}

{title:Syntax}

{p 2 4}{cmd: tornado} {bf:estimator} {it:depvars} = {it: treatment}
{break} [{help if}] [{help in}] , [{opth weight(weight)}] [{opth c:ontrols(varlist)}]
{break} [{opth graph:opts(twoway_options)}] [{it:est_options}] [{bf:or|d}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Syntax}
{synoptline}
{synopt:{opt estimator}}Indicates the estimation command to be utilized.{p_end}
{synopt:{it:depvars}}List the left-hand-side variables.{p_end}
{synopt:{it:treatment}}List the independent variable of interest.{p_end}
{break}
{synopt:{bf:or|d}}Request effect sizes as odds ratios or Cohen's {it:d}. (Choose only one.){p_end}
{break}
{synopt:{opt weight()}}Specify weights.{p_end}
{synopt:{opt c:ontrols()}}Specify controls.{p_end}
{synopt:{opt graph:opts()}}Set any desired options for the graph.{p_end}
{synopt:{it:est_options}}Specify any options needed for the estimator.{p_end}
{synoptline}

{title:Examples}

sysuse auto, clear
gen check = rep78 > 3
gen check2 = 1-foreign
label val check origin

tornado reg headroom foreign = rep78
tornado reg headroom foreign = rep78 , d
tornado logit check2 foreign = check , or

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org
