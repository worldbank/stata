{smcl}
{* january 11th 2012}{...}
{hline}
Help for {hi:ttestplus}
{hline}

{title:Description}

{p}{cmd:ttestplus} automates and tabulates t-tests on one or more dimensions across two populations indicated by a categorical variable. It can also cut a continuous variable at a specified value. Finally, it can write results to an Excel .xml or .xls file if xml_tab is installed.

{title:Syntax}

{p}{cmd:ttestplus} {help varlist} [{help if}] [{help in}] [{help using}], {opt by(groupvar)} [{opt cut(value | mean | median)}] [{opt p:values}] [{opt d:ifference}] [{opt r:ound()}] [{it:xml_tab_options}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt by(groupvar)}}Variable defining the groups{p_end}
{synopt:{opt cut()}}Cuts a continuous {it:groupvar} at the specified value, at its mean, or at its median.{p_end}
{synopt:{opt p:values}}Returns p-statistics instead of t-statistics.{p_end}
{synopt:{opt se}}Returns standard errors under means.{p_end}
{synopt:{opt n}}Returns N at end of table.{p_end}
{synopt:{opt d:ifference}}Returns differences between means.{p_end}
{synopt:{opt r:ound()}}Specify rounding unit (default: 0.01).{p_end}
{synopt:{it:xml_tab_options}}Specify any additional options needed for xml_tab if Excel output is desired.{p_end}
{synoptline}
{p 4 6 2}* {opt by(groupvar)} is required.{p_end}

{title:Saved Results}

{p}{cmd:ttestplus} saves its output in the matrix {cmd:results}.{p_end}
{p}Writing Excel-formatted output to a file specified by {cmd:using} requires that xml_tab be installed.{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}