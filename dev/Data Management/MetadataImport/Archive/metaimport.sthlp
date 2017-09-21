{smcl}
{* May 14th 2014}
{hline}
Help for {hi:metaimport}
{hline}

{title:Description}

{p}{cmd:metaimport} imports data from one or more spreadsheets and datasets and appends and consolidates them based on a single metadata spreadsheet containing information about the variables.

{title:Syntax}

{p 2 4 4}{cmd:metaimport} {it:master_file_list} {help using} {it:metadata_file}, [{opt p:rep}] [{it:Metadata Template Options}] 
{break} [{it:Master/Data Options}] [{it:Using/Metadata Options}] [{it:Output Options}] [{it:Saving Options}]

{title:Options}

{synoptline}
{synoptset 16 tabbed}{...}
{p 4}{bf:Metadata Template Creation}{p_end}
{synopt:}{p_end}
{synopt:{opt p:rep}}Creates a metadata template spreadsheet at the specified {help using} location containing the correct variable names from the master files. {p_end}
{synopt:}{p_end}
{synopt:}{it:Prep Options}{p_end}
{synopt:{opt name:row(#)}}Indicate the row number of the master spreadsheets containing original variable names. If not specified, the column letters are used. Variable names will automatically be included from a .dta master.{p_end}
{synopt: {opt head:row(#)}}Indicate the row in the master spreadsheets which contains data labels. Variable labels will automatically be included from a .dta master.{p_end}
{synopt:{opt old:name(names)}}Indicate the column name(s) to contain the names to match to the master files. If not specified, a single {it:oldname1} column will be created.{p_end}
{synopt:{opt rec:ode(names)}}Indicate the column name(s) to contain the recodes. If not specified, a single {it:recode} column will be created.{p_end}
{synopt:{opt r:eplace}}Required to write or overwrite metadata template.{p_end}
{synopt:}{p_end}
{synoptline}
{p 4}{bf:Data Import}{p_end}
{synopt:}{p_end}
{p 4}{it:Master/Data Options: Aside from {bf:sheet()}, must be consistent for all master spreadsheets.}{p_end}
{synopt:}{p_end}
{synopt:{opt name:row(#)}}Indicate the row number of the master spreadsheet containing original variable names. If not specified, the column letter is used.{p_end}
{synopt:{opt head:row(#)}}Indicate the last header row before data begins. If not specified, all rows are treated as data.{p_end}
{synopt:{opt sheet()}}Optionally indicate the names of the sheet on which data is located (one for each spreadsheet; use "x" for .dta files).{p_end}
{synopt:{opt drop:col(letter)}}Indicate a column which, if empty, means that the row is not an observation. This avoids importing a large number of blank rows. If not specified, observations are dropped if column A is blank.{p_end}
{synopt:}{p_end}
{p 4}{it:Using/Metadata Options}{p_end}
{synopt:}{p_end}
{synopt:{opt old:name(names)}}Indicate the column name(s) containing the original variable names to match to the master files, in order.{p_end}
{synopt:{opt rec:ode(names)}}Indicate the column name(s) containing the recode codes (STATA syntax), in the same order as the master files.{p_end}
{synopt:}{p_end}
{p 4}{it:Output Options}{p_end}
{synopt:}{p_end}
{synopt:{opt i:ndex(varname)}}Indicate a new variable name to identify the source of each observation. It will be numbered 1 2 3... in the order of the masters and can be coded in the metadata.{p_end}
{synopt:{opt a:ppend}}Reads the {it:first} master file for the highest already existing data of the variable name indicated in {opt i:ndex()} and begins index numbering from the next value, without replacing values in first master.{p_end}
{synopt:{opt dem:erge()}}For the final-named variables specified, missing data is treated as merged cells and filled with the preceding values.{p_end}
{synopt:}{p_end}
{p 4}{it:Saving Options}{p_end}
{synopt:}{p_end}
{synopt:{opt s:ave()}}Specify the directory in which to store generated .dta files. Leaves complete file active if not specified.{p_end}
{synopt:{opt r:eplace}}Allow overwrite of output .dta files.{p_end}
{synopt:{opt pre:fix()}}Prefix for output .dta files, if desired.{p_end}
{synopt:{opt post:fix()}}Postfix for output .dta files, if desired.{p_end}
{synopt:}{p_end}
{synoptline}

{title:Instructions}

{p}{bf:metaimport} imports any mix of master Excel and .dta files, labels them according to a common metadata spreadsheet, and appends them before outputting a set of final .dta files. Master Excel data file(s) to be imported may have a name for every variable in every column, in the {bf:namerow()}, or use the column letter. There should be no other rows with entries once the data has begun, and the final row of the header (the last row before data begins, including names and labels) should be consistent across all master Excel files and indicated with the {bf:headrow()} option if needed.{p_end}

{p}The Excel metadata file must have a {it:row} for every variable in its first sheet. The columns should indicate:{p_end}
 
{p 2 5}{bf:1)} The "original" name of the variable, corresponding to {bf:oldname()}. These must match the names in the master files {it:after} they are converted to STATA names by {help strtoname}. To obtain this list in a template metadata file, use the {cmd:prep} option. These names may vary across masters; to consolidate naming conflicts, place the variables in the same row and specify a single new name in the column titled {it:varname}. In all cases, one {bf:oldname()} column must be specified for each master file, in order. Columns may be reused for multiple masters.{p_end}
{break}
{p 2 5}{bf:2)} The final name for the variable in {it:varname}.{p_end}
{break}
{p 2 5}{bf:3)} Any necessary variable labels for the variable in {it:varlab}.{p_end}
{break}
{p 2 5}{bf:4)} A {bf:recode()} for the variable to be applied {bf:before} value labels. As in the original names, there must be one such entry for each master file even if no recodes are to occur for that master. Names can be repeated.{p_end}
{break}
{p 2 5}{bf:5)} Any necessary value label for the variable in {it:vallab} (see below).{p_end}
{break}
{p 2 5}{bf:6)} The list of filenames in which that variable belongs in {it:file}.{p_end}
{break}		
{p}The Excel metadata file will also have a {it:vallab} sheet with a {it:row} for every value of every value label to be applied. The column entries {bf:must} indicate:{p_end}

{p 2 5}{bf:1)} The name of the value label (corresponding to the value labels in the first sheet) in {it:name}.{p_end}
{p 2 5}{bf:2)} The value (unique within label; numeric) in {it:value}.{p_end}
{p 2 5}{bf:3)} The label for the value in {it:label}.{p_end}

{p}The Excel metadata file will also have a {it:construct} sheet with a {it:row} for every command to be executed, before variable labelling. The column entries {bf:must} indicate:{p_end}

{p 2 5}{bf:1)} The command in {it:command}.{p_end}
{p 2 5}{bf:2)} The variable name when relevant in {it:varname}. For the commands {help generate} and {help egen}, the variables will be dropped from existing data and regenerated consistently for all data. This is primarily relevant when {opt a:ppend} is specified.{p_end}
{p 2 5}{bf:3)} The required arguments or expression in {it:expression}. Omit the = sign for {help generate}, {help egen}, and {help replace}.{p_end}


{title:Example}

{p 2 4 4}metaimport 	"$directory/data/raw/Data1.xlsx" ///
{break} 		"$directory/data/raw/Data2.xlsx" ///
{break}			"$directory/data/raw/Data3.xlsx" ///
{break}			"$directory/data/raw/Data4.xlsx" ///
{break}using	"$directory/data/metadata/1_4_metadata.xlsx" ///
{break},	namerow(1) headrow(2) s($directory/data/public/) index(case) replace ///
{break} 	oldname(oldname1 oldname2 oldname3 oldname4) recode(recode recode recode recode) 

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}