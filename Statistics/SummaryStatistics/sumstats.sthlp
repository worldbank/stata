{smcl}
{* May 27th 2015}
{hline}
Help for {hi:sumstats}
{hline}

{title:Description}

{p}{cmd:sumstats} easily generates a table of summary statistics with various {help if}-restrictions and prints them to a specified output file using {help xml_tab}.

{title:Syntax}

{p}{cmd:sumstats} {it:output_varlist} {help using} [{help if}] [{help in}], [{it:xml_tab_options}]

{title:Instructions}

{p}The output variable list will be of the form ({it:varlist_1} {help if} {it:condition_1}) ({it:varlist_2} {help if} {it:condition_2}).... It will produce the mean, standard deviation, and number of observations for the specified variables with the specified conditions. Variable labels will automatically be truncated to 30 characters and attached. Specify with {help using} the desired file path for the {help xml_tab} output, and include as usual any options for this command.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}