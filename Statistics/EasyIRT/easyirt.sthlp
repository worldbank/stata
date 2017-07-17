{smcl}
{* January 5th 2014}
{hline}
Help for {hi:easyirt}
{hline}

{title:Description}

{p}{cmd:easyirt} performs IRT estimates using {help openirt} for the designated variable list, affixing original ID variables as well as variable names and labels to the generated datasets.

{title:Syntax}

{p}{cmd:easyirt} {help varlist} {help using} [{help if}] [{help in}], {opth id(varlist)} [{opt theta(theta_label)}] [{opt r:eplace}] [{it:openirt_options}]

{title:Instructions}

{p}The command first collapses the {help varlist} specified at the {bf:id} level, using the first nonmissing value from each {bf:id}-group. This allows multiple questionnaires to be stored in long format so long as the variable names do not overlap.

{p}Specify with {help using} the desired file path for the ability parameter estimates (ending in .dta). It will also create the item parameters dataset suffixed _items.dta. Specify in {opt theta()} the label for the estimated ability parameter variables. This will also become the stub for the variables (processed by {help strtoname()}) - so for example specifying {opt theta(Checklist IRT)} will lead to labels beginning with "Checklist IRT" and variable names of the form {it: checklist_irt_*}.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}