{smcl}
{* Sep 22nd 2017}
{hline}
Help for {hi:orChart}
{hline}

{title:Description}

{p}{cmd: orChart} generates a chart of primary logistic regression results expressed as odds ratios for a list of dependent variables, combined with a table detailing those results.

{title:Syntax}

{p 2 4}{cmd: orChart} {it:depvars} [{help if}] [{help in}], {opt c:ommand(estimation_command)} {opt rhs(indepvar [controlvars])}
{break} [{opt globalif}] [{opt regopts(regression_options)}] [{it:tw_options}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt c:ommand()}}Indicates the estimation command to be utilized.{p_end}
{p2coldent:* {opt rhs()}}Specify the right-hand-side variables, beginning with the input of interest and listing control variables if desired.{p_end}
{synopt:{opt globalif}}When applied, allows an if-condition to be set for each dependent variable separately. Before running the command with this option, create a global macro containing “&” followed by the logic expression needed for that variable. (Such as {it: global depvar “& ifvar==1”}).{p_end}
{synopt:{opt regopts()}}Set any desired options for the regression command.{p_end}
{synopt:{it:tw_options}}Specify any options needed for the graph.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org

{p_end}