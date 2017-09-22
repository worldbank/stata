{smcl}
{* Sep 22 2017}
{hline}
Help for {hi:timeLines}
{hline}

{title:Description}

{p}{cmd: timeLines} creates a graphical representation of time use for various panel units when each observation represents an activity with a start and end time.

{title:Syntax}

{p 2 4 4}{cmd: timeLines} [{help if}] [{help in}], {opth id(varlist)} {opth start(varname)} {opth end(varname)} {break} [{opth names(varname)}] [{opth labels(varname)}] [{opt labopts()}] [{opth class(varname)}] [{opt classcolors()}] {break} [{it:tw_options}] 

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt id()}}Variable defining the individuals.{p_end}
{p2coldent:* {opt start()}}Variable defining the start times for each activity.{p_end}
{p2coldent:* {opt end()}}Variable defining the end times for each activity.{p_end}
{synopt:{opt names()}}Indicates names to be used in graph display, if these are not defined by labels on the id() variables.{p_end}
{synopt:{opt label()}}Indicates labels to be used in graph display, corresponding to time periods.{p_end}
{synopt:{opt labopts()}}Any options required for display of labels.{p_end}
{synopt:{opt class()}}Groups observations into classes, colored by classcolors().{p_end}
{synopt:{opt classcolors()}}List of colors for observation classes.{p_end}
{synopt:{it:tw_options}}Specify any additional options needed for display of graph.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org

{p_end}