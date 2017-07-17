{smcl}
{* Jun 4th 2014}
{hline}
Help for {hi:metalabel}
{hline}

{title:Description}

{p}{cmd:metalabel} imports variable labels from a metadata spreadsheet with columns {it:varname} as well as {it:varlab} and/or {it:vallab}.

{title:Syntax}

{p}{cmd:metalabel} {help using}, [{opt varlab}] [{opt vallab}]

{title:Instructions}

{p}Specify {opt varlab} to apply variable labels from the column {it:varlab}. Specify {opt vallab} to apply value labels from the column and sheet {it:vallab}.

{p}If {opt vallab} is specified, the Excel metadata file should also have a {it:vallab} sheet with a {it:row} for every value of every value label to be applied. The column entries {bf:must} indicate:{p_end}

{p 2 5}{bf:1)} The name of the value label (corresponding to the value labels in the first sheet) in {it:name}.{p_end}
{p 2 5}{bf:2)} The value (unique within label; numeric) in {it:value}.{p_end}
{p 2 5}{bf:3)} The label for the value in {it:label}.{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}