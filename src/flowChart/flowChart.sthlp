{smcl}
{* Sep 25th 2017}
{hline}
Help for {hi:flowChart}
{hline}

{title:Description}

{p}Given an Excel spreadsheet with columns A, B, C, and D titled “logic”, “var”, “stat” and “value”, respectively, {cmd:flowChart} replaces the “value” column with the requested statistic for the observations in the dataset that fit the condition expressed in “logic”. This allows for the creation of dynamically updating custom tables and flowcharts.

{title:Syntax}

{p}{cmd:flowChart} {help using} {it:xlsx_path} [{help if}] [{help in}]

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org
