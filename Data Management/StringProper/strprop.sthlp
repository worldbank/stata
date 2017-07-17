{smcl}
{* May 14th 2014}
{hline}
Help for {hi:strprop}
{hline}

{title:Description}

{p}{cmd:strprop} replaces a set of string variables with proper-case text.

{title:Syntax}

{p}{cmd:strprop} {it:varlist}, {opt c:ase(proper | lower | upper)} [{opt n:ames}] [{opt s:trip()}]

{title:Instructions}

{p}Specify the varlist to be case-formatted. {cmd:strprop} will automatically skip non-string variables, so specifying {bf:*} or other wildcards is acceptable. Specify {opt n:ames} to {help rename} all variables to lowercase. Specify {opt s:trip()} to remove the characters [ ] \ ^ % . | ? * + ( ) from the variable in addition to any other characters specified.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}