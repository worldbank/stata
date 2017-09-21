{smcl}
{* September 24th 2014}
{hline}
Help for {hi:bettertab}
{hline}

{title:Description}

{p}{cmd:bettertab} writes a matrix from {help tabulate} using {help xml_tab}, containing the counts and/or percentage frequencies of the requested variable(s).

{title:Syntax}

{p}{cmd:bettertab} {help varlist} [{help using}] [{help if}] [{help in}], [{opt round()}] [{opt dec:imals()}] [{it:xml_tab_options}]

{title:Instructions}

{p}The table will behave as {help tabulate} with one or two variables.

{p}In {opt dec:imals}, specify the number of decimal places for each statistic, for example, {bf:decimals(}2 2 2 2 2 0 1 2{bf:)}. This only applies if an output file for {help xml_tab} is specified in {help using}, and supersedes the {bf:format()} option from {help xml_tab}.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}