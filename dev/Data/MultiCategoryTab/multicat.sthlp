{smcl}
{* March 13th 2015}
{hline}
Help for {hi:multicat}
{hline}

{title:Description}

{p}{cmd:multicat} compiles indicator variables into a single string variable indicating which of the indicators are equal to 1 for each observation. The variable label of the indicator variables are reflected in the new variable. When no variable is equal to 1 the new variable will be equal to "" (string missing).

{title:Syntax}

{p}{cmd:multicat} {it:indicator_varlist}, {opt gen:erate(newvar)}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}