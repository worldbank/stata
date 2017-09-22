{smcl}
{* Sep 22nd 2017}
{hline}
Help for {hi:cleanLabels}
{hline}

{title:Description}

{p}{cmd:cleanLabels} removes characters from value labels. By default it removes “,” and “:” since these are known to cause issues with export commands. Optionally a different list can be specified, but " ` and ' cannot be removed at this time.

{title:Syntax}

{p}{cmd:cleanLabels} {help varlist} , [{opt r:emove(charlist)}]

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org

Wenqing Zhu
wzhu2@worldbank.org
