{smcl}
{* May 14th 2014}
{hline}
Help for {hi:timechart}
{hline}

{title:Description}

{p}{cmd:timechart} creates a graphical representation of time use when each observation of a dataset is  a distinct activity period and an ID variable is available to group the observations.

{title:Syntax}

{p 2 4 4}{cmd:timechart} [{help if}] [{help in}], {opth id(varlist)} {opth start(varname)} {opth end(varname)} {break} [{opth names(varname)}] [{opth labels(varname)}] [{it:tw_options}] 

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt id()}}Variable defining the individuals.{p_end}
{p2coldent:* {opt start()}}Variable defining the start times for each activity.{p_end}
{p2coldent:* {opt end()}}Variable defining the end times for each activity.{p_end}
{synopt:{opt names()}}Indicates names to be used in graph display, corresponding to ID variable.{p_end}
{synopt:{opt label()}}Indicates labels to be used in graph display, corresponding to time periods.{p_end}
{synopt:{it:tw_options}}Specify any additional options needed for display of graph.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}