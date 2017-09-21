{smcl}
{* Jun 4th 2014}
{hline}
Help for {hi:labelcollapse}
{hline}

{title:Description}

{p}{cmd:labelcollapse} preserves variable labeling while performing {help collapse}.

{title:Syntax}

{p}{cmd:labelcollapse} {it:clist} [{help if}] [{help in}] [{help weight}] , [{opth vallab(varlist)}] [{it:collapse_options}] 

{title:Instructions}

{p}Instead of running {help collapse}, use {cmd:labelcollapse} to preserve variable labels. Specify {opt vallab()} to preserve value labels for the specified {help varlist}. The rest of the syntax is identical.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}