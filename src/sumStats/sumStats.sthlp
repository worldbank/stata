{smcl}
{* Nov 8th 2017}
{hline}
Help for {hi:sumstats}
{hline}

{title:Description}

{p}{cmd:sumstats} easily generates a table of summary statistics with various {help if}-restrictions
and prints them to a specified output file using {help putexcel}.

{title:Syntax}

{phang}{cmd:sumstats} ({it:varlist_1} [{help if}]) [({it:varlist_2} [{help if}]) ...]
{break}	{help using} {it:"/path/to/output.xlsx"} [{help weight}], stats({it:{help tabstat##statname:stats_list}}) [replace] {p_end}

{title:Instructions}

{p}{cmd:sumstats} will print to Excel the requested statistics for the specified variables in each list with the specified conditions for that list.
Specify with {help using} the desired file path for the {help putexcel} output. {bf:aweights} and {bf:fweights} are allowed; statistics are calculated with {help tabstat}.

{title:Example}

{inp} sysuse auto.dta , clear
{inp} sumstats  ///
{inp}  (price mpg if foreign == 0) ///
{inp}  (price displacement length if foreign == 1) ///
{inp}  using "test.xlsx" , replace stats(mean sd)
{inp}  ({stata sumstats (price mpg if foreign == 0)(price displacement length if foreign == 1) using "test.xlsx" , replace stats(mean sd):Run})

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com
