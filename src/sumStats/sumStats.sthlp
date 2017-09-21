{smcl}
{* Sep 21st 2017}
{hline}
Help for {hi:sumStats}
{hline}

{title:Description}

{p}{cmd:sumStats} easily generates a table of summary statistics with various {help if}-restrictions and prints them to a specified output file using {help xml_tab}.

{title:Syntax}

{p}{cmd:sumStats} ({it:varlist_1} {help if} {it:condition_1}) [({it:varlist_2} {help if} {it:condition_2}) ...] {help using} , stats({it:{help tabstat##statname:stats_list}}) [{it:{help xml_tab:xml_tab_options}}]

{title:Instructions}

{p}{cmd:sumStats} will produce the requested statistics for the specified variables in each list with the specified conditions for that list. Variable labels will automatically be truncated to 30 characters and attached. Specify with {help using} the desired file path for the {help xml_tab} output, and include as usual any options for this command.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}