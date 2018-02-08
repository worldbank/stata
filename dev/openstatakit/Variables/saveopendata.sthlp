{smcl}
{* Feb 8th 2018}
{hline}
Help for {hi:saveopendata}
{hline}

{title:Description}

{p 2 4 4}{cmd:saveopendata} reads the currently open dataset and either (A) creates a codebook for it in the specified location; or (B) reads a series of .dofiles that reference the data and keeps only the variables that those dofiles reference.

{title:Syntax}

{p 2 4 4}{cmd:saveopendata} {it:saving_location} {help using} {it:dofile_list} 

{title:Things to Remember}

{p 2 4 4}{cmd:saveopendata} can only use dofiles that reference the FULL NAME of each variable. Using shortcuts and abbreviations will cause the dataset to be incorrect. It will also keep variables whose names contain other variables that are referenced.

{title:Demo}

	cd /Users/bbdaniels/GitHub/stata/dev/openstatakit/

	sysuse auto , clear
	
	isid make , sort
	
	reg rep78 headroom

	saveopendata "saveopendata" 	using "saveopendata.ado"
	saveopendata "saveopendata" 	, compact

{title:Author}

Benjamin Daniels
DIME Analytics
World Bank Group

bdaniels@worldbank.org

{p_end}