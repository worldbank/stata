{smcl}
{* Mar 6rd 2015}
{hline}
Help for {hi:medlookup}
{hline}

{title:Description}

{p}{cmd:medlookup} produces a spreadsheet listing the (proper-case) brand names of medicines in the dataset and their generic components as indicated by the 1mg.com database. It also creates a second sheet allowing the classification of those components.

{p}On import, it matches the classifications back to the brand names, and can tabulate the number of correct and incorrect drugs (those that match a user-provided list of classifications).

{title:Syntax}

{p 2 4}{cmd:medlookup} {it:med_name_stub} {help using} [{help if}] [{help in}], {opt i(unique_id_varlist)} {break} [{opt import(treat_class_varname)}] [{opt append}] [{opt correct(correct_class_list)}]

{title:Instructions}

{p}The first use of medlookup will create the brand index spreadsheet with the list of proper-case-formatted brand names from the {it:med_name_stub}* variables, and the generic index spreadsheet with the list of all generics that appeared. The second sheet should be filled manually with the treatment class of the generic component for matching back.

{p}Specifying {opt import()} will match back the treatment class descriptors to the original observations, creating a new variable named {it:treat_class_varname} with the full (messy) list of treatment types that appear in that observation.

{p}Specifying {opt append} will add new data to an existing sheet, keeping the existing data if there is a conflict.

{p}Specifying {opt correct()} with {opt import()} will also create two further variables, named {it:treat_class_varname}_correct and {it:treat_class_varname}_incorrect, containing the number of medicines from the observation (nonmissing instances of {it:med_name_stub}) that match the treatment classes from {it:correct_class_list} and those that do not, respectively.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}