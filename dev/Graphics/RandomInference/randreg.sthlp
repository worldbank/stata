{smcl}
{* May 14th 2014}
{hline}
Help for {hi:randreg}
{hline}

{title:Description}

{p}{cmd:randreg} provides a visual illustration of the marginal effect of a randomized treatment on a specified outcome variables using any specified estimation method.

{title:Syntax}

{p 2 4 4}{cmd:randreg} {it:est_model} [{help if}] [{help in}], {opth t:reatment(varname)} {break} [{opt i:terations()}] [{opt s:eed()}] [{opt r:ound()}] [{opt ci()}] {break}  [{opt graphoptions(tw_options)}] [{it:est_options}]	

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{it:est_model}}Specify the full estimation command and model to be fit for analysis.{p_end}
{p2coldent:* {opt t:reatment()}}Indicates the binary treatment variable. Control should be 0, and treatment should be 1.{p_end}
{synopt:{opt i:terations()}}Specify the number of iterations to attempt with randomly generated treatment and control status whose frequencies match the actual frequencies. The default is 100.{p_end}
{synopt:{opt s:eed()}}Set randomization seed manually if desired.{p_end}
{synopt:{opt r:ound()}}Specify rounding units for results. The default is 0.01.{p_end}
{synopt:{opt ci()}}Set width of interval to illustrate. The default is 95(%).{p_end}
{synopt:{opt graphoptions()}}Set any desired options for the graph.{p_end}
{synopt:{it:est_options}}Specify any options needed for the estimation model.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}