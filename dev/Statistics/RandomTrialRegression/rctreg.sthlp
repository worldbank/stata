{smcl}
{* Dec 30th 2014}
{hline}
Help for {hi:rctreg}
{hline}

{title:Description}

{p}{cmd:rctreg} performs regressions for random trials on the variables listed in {help varlist}, listing treatment and control means and intent-to-treat regression estimates for a binary treatment variable (including basic controls). There is the option of also producing contamination-adjusted IV estimates. Additional controlled models are also estimated for both. This is written to the Excel spreadsheet specified in {help using}.

{title:Syntax}

{p 2 4}{cmd:rctreg} {help varlist} {help using} [{help if}] [{help in}], {opth treatment(varlist)} {opth controls(varlist)}
{break}  [{opt lag]} [{opt iv()}] [{opt round()}] [{opt title()}] [{opt sd}] [{opt ci}] [{opt p}|{opt se}] [{it:regression_options}] 

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt treatment()}}Indicate a binary treatment variable (0 = control), followed by any control variables to be included in all models. Calculated and labeled as intention-to-treat (ITT) model.{p_end}
{synopt:{opt controls()}}Indicate additional control variables to be added to "adjusted" ITT regressions (and IV, if specified).{p_end}
{synopt:{opt lag}}Adds the first lag of the independent variable to the list of controls for all regressions. Data must be set as time-series.{p_end}
{synopt:{opt iv()}}If desired, specify a variable to be instrumented by the treatment indicator for treatment-effect-on-the-treated or contamination-adjusted analysis.{p_end}
{synopt:{opt round()}}Specify the unit for rounding (default is 0.01).{p_end}
{synopt:{opt title()}}Specify a title for the table.{p_end}
{synopt:{opt sd}}Place standard deviations below treatment and control means.{p_end}
{synopt:{opt ci}}Place 95% confidence intervals after regression estimates [in brackets].{p_end}
{synopt:{opt p}}Place p-values below regression estimates.{p_end}
{synopt:{opt se}}Place standard errors below regression estimates (in parentheses).{p_end}
{synoptline}

{title:Notes}

{p}Treatment and control means, as well as sample sizes, are calculated using observations that are included in the adjusted ITT analysis - that is, the observations for which all variables specified in {opt controls()} are nonmissing. This means that N may vary in the unadjusted analysis or the IV analysis if the {opt iv()} variables are missing.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}