{smcl}
{* Jun 4th 2014}
{hline}
Help for {hi:tabstatout}
{hline}

{title:Description}

{p}{cmd:tabstatout} produces a table of summary statistics and can also export to a spreadsheet if {help xml_tab} is installed.

{title:Syntax}

{p 2 4}{cmd:tabstatout} {it:statlist} [{help using}] [{help if}] [{help in}] [{help weight}] , {opth by(varname)}
{break} [{opt n}] [{opt sd}] [{opt t:otal}] [{opt trans:pose}] [{opt dec:imals()}] [{it:xml_tab_options}] 

{title:Instructions}

{p}In {it:statlist}, specify the statistics you would like to calculate, using the syntax from {help collapse}. Specify {bf:n} to attach a count row to the end of the table. Specify {opt t:otal} to attach a summary column to the end of the table. Specify {opt trans:pose} to transpose the table. Specify {bf:sd} to add standard deviations (of the means) under every statistic.

{p}In {opt dec:imals}, specify the number of decimal places for each statistic, for example, {bf:decimals(}2 2 2 2 2 0 1 2{bf:)} Add x to a number, for example, {bf:decimals(}2x 2 2 2 2 0 1x 2{bf:)} to suppress standard errors. This only applies if an output file for {help xml_tab} is specified in {help using}, and supersedes the {bf:format()} option from {help xml_tab}.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}