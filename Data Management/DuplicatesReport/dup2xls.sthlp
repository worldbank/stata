{smcl}
{* May 14th 2014}
{hline}
Help for {hi:dup2xls}
{hline}

{title:Description}

{p}{cmd:dup2xls} outputs an Excel file of discrepancies between duplicate observations.

{title:Syntax}

{p}{cmd:dup2xls} [{it:master_data}] {help using} {it:output_file}, {opth id(varlist)} {opth names(varname)} [{opt s:tring}]	

{synoptset 16 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{p2coldent:* {opt id()}}Indicates the variable list that provides a unique ID within which comparisons should be made. (For example, {it:household member}.){p_end}
{p2coldent:* {opt names()}}Indicates the names of the entries within the unique ID across which comparisons should be made. (For example {it:doubleentry}.){p_end}
{synopt:{opt s:tring}}Indicates that all string variables should be outputted for manual inspection.{p_end}
{synoptline}
{p 4 6 2}{it:(A * indicates required options.)}{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}