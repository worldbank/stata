{smcl}
{* May 14th 2014}
{hline}
Help for {hi:timeoverlap}
{hline}

{title:Description}

{p}{cmd:timeoverap} indicates whether an observation in the master dataset overlaps with an event in the using dataset. It can also import characteristics from the using dataset when an overlap occurs. The command can also save the data in a new location or overwrite the master dataset automatically.

{title:Syntax}

{p 2 4 4}{cmd:timeoverlap} [{it:master}] {help using},{break}  {opt s:tartvars()} {opt e:ndvars()} {opth g:en(newvarname)} {break} [{opth c:opy(varlist)}]

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:{it:master}}Indicates a master dataset to load if specified; otherwise the master is the current dataset.{p_end}
{p2coldent:* {opt using}}Indicates the dataset containing the intervals which may overlap those in the master dataset.{p_end}
{p2coldent:* {opt s:tartvars()}}Variable defining the start times for each period. List the master variable first, then the using variable. Both MUST be in the same {help datetime##s2:Stata internal format}.{p_end}
{p2coldent:* {opt e:ndvars()}}Variable defining the end times for each period. List the master variable first, then the using variable. Both MUST be in the same {help datetime##s2:Stata internal format}.{p_end}
{p2coldent:* {opt g:en()}}Specify a new variable name. This will be a binary variable indicating whether the master observation overlaps some using observation.{p_end}
{synopt:{opt c:opy()}}If an overlap occurs, this variable list will be copied into the master dataset with the values from the overlapped period. This will work if each master observation overlaps AT MOST one using observation.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}