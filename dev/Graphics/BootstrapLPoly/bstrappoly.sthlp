{smcl}
{* Jun 4st 2015}
{hline}
Help for {hi:bstrappoly}
{hline}

{title:Description}

{p}{cmd:bstrappoly} generates a bootstrapped 95% confidence interval for {help tw lpoly} for the variables specified in {opt b:ootstrap()}. Other two-way plots, an underlying histogram, and all relevant formatting options can be added.

{title:Syntax}

{p 2 4}{cmd:chartable} [{it:other_plots}] [{help if}] [{help in}] , {opt b:ootstrap(yvar xvar)} [{opt s:eed(integer)}] [{opt r:eps(integer)}]  {break}[{opt bopt:ions(bootstrap_options)}] [{opt lpolyopt:ions(tw_line_options)}] [{opt ciopt:ions(tw_rarea_options)}]
{break}[{opt hist:ogram(varname)}] [{opt hopt:ions(histogram_options)}] [{help twoway_options}]

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}