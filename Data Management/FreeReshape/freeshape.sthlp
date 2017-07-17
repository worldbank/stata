{smcl}
{* March 13th 2014}
{hline}
Help for {hi:freeshape}
{hline}

{title:Description}

{p}{cmd:freeshape} reshapes any variable list to long-format. Unlike reshape, it does not require that the variables be named with numbered stubs. It generates a sequenced ID from the {opt j()} option, and creates variables recording the original variable names, labels, and values, named {it:j_index, j_name, j_label,} and {it:j_value}, respectively.

{title:Syntax}

{p}{cmd:freeshape} {it:varlist}, {opt i(id_varlist)} {opt j(newvar_stub)}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}