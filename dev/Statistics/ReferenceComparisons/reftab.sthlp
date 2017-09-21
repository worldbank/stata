{smcl}
{* December 24th 2014}
{hline}
Help for {hi:reftab}
{hline}

{title:Description}

{p}{cmd:reftab} displays and can also write a matrix of summary statistics and regression results using {help xml_tab}, containing the means of the requested variable(s) and estimated marginal effects of membership in various categories of a by-variable.

{title:Syntax}

{p 2 4}{cmd:reftab} {help varlist} [{help using}] [{help if}] [{help in}], {opth by:var(varname)} {opt ref:cat(base_value)} [{opth iv(varname)}]
{break} [{opth controls(varlist)}] [{opt logit}] [{opt cl:uster(clustvar)}] [{opt dec:imals()}] [{opt n}] [{opt se:m}] [{it:xml_tab_options}]

{title:Instructions}

{p}The first panel of the table will contain means of the specified variables by categories of {opt by:var()}, with standard errors if {opt se:m} is specified. Each successive panel will report the regression coefficients for each category of {bf:byvar} from a regression on the full set of group membership indicators with the {opt ref:cat()} value excluded. If {opt controls()} are specified, each panel will also contain the estimates from the fixed-effects regression controlled for the specified variables.

{p}If {bf:logit} is specified, the differences will be calculated as odds ratios. If {bf:iv} is specified, the final panel will contain the second-stage estimate of the effect of the variable specified, instrumented on the full set of category indicators. It will include an adjusted estimate as well if {opt controls()} are specified.

{p}In {opt dec:imals}, specify the number of decimal places to be reported for each variable, for example, {bf:decimals(}2 0 1 2{bf:)} if there are four variables and 2, 0, 1, and 2 places are desired. This also affects the standard error formatting. This only applies if an output file for {help xml_tab} is specified in {help using}, and supersedes the {bf:format()} option from {help xml_tab}. Specifying {bf:n} adds sample sizes to the means panel (which may differ from the sample sizes used in regression if control variables are missing).

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}