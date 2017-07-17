{smcl}
{* Sep 16th 2014}
{hline}
Help for {hi:dayofweek}
{hline}

{title:Description}

{p}{cmd:dayofweek} generates and labels a day-of-week variable given a
datetime variable.

{title:Syntax}

{p}{cmd:dayofweek} {it:datetime_variable}, {opth gen:erate(newvar)} [{opth label(string)}]

{title:Instructions}

{p}{cmd:dayofweek} will create a new variable as specified in {opt gen:erate()} containing the labeled values 0 (Sunday) - 6 (Saturday). The datetime variable must be in Stata internal datetime format as specified in {help dow()}. The {opt label()} option allows a variable label to be applied.

{title:Author}

Benjamin Daniels bbdaniels@gmail.com

