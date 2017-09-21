{smcl}
{* December 24th 2014}
{hline}
Help for {hi:treatgrade}
{hline}

{title:Description}

{p}{cmd:treatgrade} outputs an Excel file to {help using} containing relevant treatment information, including long-format medicine information, as well as update fields for manual review of medicine information. It also includes manual-entry field for medicine interactions, treatment quality grading, and medicine grading. Import coming soon.

{title:Syntax}

{p 2 4}{cmd:treatgrade} {help using} [{help if}] [{help in}], {opth id(varlist)} {opt med:stubs(medicine_info_stub_list)} {opth t:reatbins(varlist)}
{break} [{opt u:pdates(medicine_updates_stub_list)}]

{title:Instructions}

{p}The outputted spreadsheet will contain all the ID variables. It will also contain the {bf:variable labels} from {opt t:reatbins()} for each case where the binary variable is equal to 1. Finally, it will include the long-format medicine information from {opt med:stubs()}, the first of which should be a never-empty name. As stubs, the variables in the dataset should end in an index number for each wide-format medicine.

{p}In {opt u:pdates()}, specify the medicine stubs for which updating should be reflected as an option on the spreadsheet.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}