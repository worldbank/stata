{smcl}
{* Apr 1th 2015}
{hline}
Help for {hi:betterbar}
{hline}

{title:Description}

{p}{cmd:betterbar} produces bar graphs with grouping of variables, standard error bars, and cross-group comparisons.

{title:Syntax}

{p 2 4}{cmd:betterbar} {help varlist} [{help if}] [{help in}] [{help using}], [{it:options}] [{help twoway_options}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Primary Options}
{synoptline}
{p2coldent:* {it:varlist}}The list of variables can be entered as usual or in parenthetical groups to produce ordering. {break}For example: {it:(animal_vars) (vegetable_vars) (mineral_vars)}.{p_end}
{break}
{synopt:{opt using}}Export the collapsed dataset to the specified spreadsheet.{p_end}
{break}
{synopt:{opth by(varlist)}}Produces top-level grouping of bars by specified variables.{p_end}
{synopt:{opth o:ver(varlist)}}Produces bottom-level grouping of bars.{p_end}
{break}
{synopthdr:Graph Options}
{synoptline}
{synopt:{opt nobylabel}}Suppresses labelling from by-group.{p_end}
{synopt:{opt nobycolor}}Suppresses coloring by by-group.{p_end}
{synopt:{opt novarlab}}Suppresses labeling by variable.{p_end}
{synopt:{opt nobarplot}}Suppresses bar chart.{p_end}
{break}
{synopt:{opt stat()}}Produces any {help collapse} statistic instead of means. Not recommended to combine with {opt se}.{p_end}
{synopt:{opt v:ertical}}Produces vertical bars. The default is horizontal.{p_end}
{synopt:{opt labsize()}}Specify label size for variable axis.{p_end}
{synopt:{opt barlook()}}Specify bar styling options, up to one for each lowest-level category, as: {bf:barlook(}1 {help barlook_options} 2 {help barlook_options} ...{bf:)}.{p_end}
{break}
{synopthdr:Added Statistics}
{synoptline}
{synopt:{opt addplot()}}Specify a list of twoway plots to add to the chart. The categorical axis is variable {it:x}, ranging from 0 to 1, and the numerical axis is variable {it:mean}. Over-groups and by-groups are named and numbered as in the original data with the original variable names. Variables can be specified as "if varname == {it:varname}".{p_end}
{break}
{synopt:{opth stats(varlist)}}Displays the sample size and the means of the specified variables. Adjustments can be made by specifying {bf:caption()} in {help twoway_options}.{p_end}
{synopt:{opt n}}Adds group sizes to legend.{p_end}
{break}
{synopt:{opt se}}Includes standard error bars around the calculated statistics adjusted to the 95% confidence interval, calculated as 1.96*SE(mean).{p_end}
{synopt:{opt bin:omial}}Uses binomial distribution standard errors. The default is normal.{p_end}
{break}
{synopt:{opt bar:lab()}}Labels the bars with the mean values. Specify {it:upper, lower, mean, or zero} to control the placement of the label -  at the upper or lower bound of the confidence interval, at the mean (the end of the bar) or at the zero point.{p_end}
{break}
{synopthdr:Sorting}
{synoptline}
{synopt:{opt d:escending()}}Sorts bars with the highest value first. {p_end}
{synopt:{opt a:scending()}}Sorts bars with the lowest value first.{p_end}
{synopt:}Inside the parentheses should be a logic expression indicating the group to sort by. For example: {opt descending(treament==1 & male==1)}. If no {opt over}- or {opt by}-groups are specified, use {opt descending(1)}.{p_end}

{synoptline}
{p 4 6 2}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}
