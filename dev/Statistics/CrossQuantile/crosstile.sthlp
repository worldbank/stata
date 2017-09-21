{smcl}
{* October 24th 2014}
{hline}
Help for {hi:crosstile}
{hline}

{title:Description}

{p}{cmd:crosstile} creates a matrix of means for the dependent variable, categorized by quantile for two independent variables. If {help using} is specified it will write the matrix to a spreadsheet using {help xml_tab}. Specify the number of quantiles in {opt n()}, first for the column variable and then for the row variable. Results are stored in the matrix {it:results}.

{title:Syntax}

{p}{cmd:crosstile} {it:depvar colvar rowvar} [{help using}], {opt n()} [{it:xml_tab_options}]


{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}