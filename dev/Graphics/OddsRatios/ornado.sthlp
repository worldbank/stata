{smcl}
{* Apr 1st 2015}
{hline}
Help for {hi:chartable}
{hline}

{title:Description}

{p}{cmd:ornado} generates a tornado chart of primary odds-ratio (logistic) regression results for an independent variable list, combined with a table detailing those results. The regression command MUST support odds-ratio reporting and the or option must be specified in the main options for the results to be sensible.

{title:Syntax}

{p 2 4}{cmd:ornado} {it:depvars} [{help if}] [{help in}], {opt c:ommand(estimation_command)} {opt rhs(indepvar [controlvars])}
{break} [{opt or}] [{opt p:stars}] [{opt globalif}] [{opt regopts(regression_options)}] [{it:tw_options}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt c:ommand()}}Indicates the estimation command to be utilized. For example, c(xtlogit) and c(xi: logit) are valid inputs.{p_end}
{synopt:{opt rhs()}}Specify the right-hand-side variables, beginning with the dependent variable of interest (the results to be reported) and listing control variables afterwards if desired.{p_end}
{synopt:{opt or}}Specifies odds ratios, indicating a logistic regression is to be used. *Currently the only available option and required.*{p_end}
{synopt:{opt p:stars}}Adds stars indicating p-values to the point estimates in the table.{p_end}
{synopt:{opt globalif}}When applied, allows an if-condition to be set for each dependent variable separately. Before running the command with this option, create a global variable named with the appropriate dependent variable containing "&" followed by the logic expression needed for that variable. (Such as global {it:depvar} "& ifvar==1").{p_end}
{synopt:{opt regopts()}}Set any desired options for the regression command.{p_end}
{synopt:{it:tw_options}}Specify any options needed for the graph.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}