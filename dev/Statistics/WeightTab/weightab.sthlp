{smcl}
{* Sep 8th 2015}
{hline}
Help for {hi:weightab}
{hline}

{title:Description}

{p}{cmd:weightab} produces xlsx sheets and/or bar graphs with weighted cross-group comparisons.

{title:Syntax}

{p 2 4}{cmd:weightab} {help varlist} [{help if}] [{help in}] [{help using}] [{help weight}], {opth over(varlist)} [{it:options}] 

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Primary Options}
{synoptline}
{p2coldent:* {it:varlist}}The list of variables to produce summary statistics for. Calculations are based on {help svy}: {help mean} using supplied weights.{p_end}
{p2coldent:* {opt weight}}Specify weight variable. Only pweights are currently supported.{p_end}
{p2coldent:* {opth o:ver(varlist)}}Produces grouping of observations. Values should be labeled.{p_end}
{break}
{synopthdr:XLSX Options}
{synoptline}
{p2coldent:+ {opt using}}Export the final statistics to the specified spreadsheet.{p_end}
{synopt:{opt stats()}}Choose from {help mean}'s [{it:b se t pvalue ll ul df crit}] statistics for reporting. The default is stats(b se).{p_end}
{break}
{synopthdr:Graph Options}
{synoptline}
{p2coldent:+ {opt graph}}Requests bar graph of results.{p_end}
{synopt:{opt se}}Requests 95% CIs around point estimates.{p_end}
{synopt:{opt dropzero}}Excludes bars with b=0.{p_end}
{synopt:{opt barlook()}}Specify bar styling options, up to one for each lowest-level category, as: {bf:barlook(}1 {help barlook_options} 2 {help barlook_options} ...{bf:)}.{p_end}
{synopt:{help twoway_options}}Specify as usual.{p_end}

{synoptline}
{p 4 6 2}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com


