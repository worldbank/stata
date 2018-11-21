{smcl}
{* Nov 21st 2018}
{hline}
Help for {hi:outwrite}
{hline}

{title:Description}

{p}{cmd: outwrite} reads multiple regressions saved with {help estimates store}, consolidates them into a single table, and exports the results to a .xlsx, .xls, .csv, or .tex file.{p_end}
{break}{break} {p}Alternatively, as a programming command, it will accept a single matrix and print that; it will also look for matrix_STARS and affix that number of stars to each cell.{p_end}

{title:Syntax}

{p 2 4 4}{cmd: outwrite} {it:estimates_1} {it:estimates_2} [...]{break}
{help using} {it:/path/to/output}.[xlsx|xls|csv|tex] , {break}
[{opt r:eplace} {opt s:tats()} {opth d:rop(varlist)}] {break}
[{opt t:stat}|{opt p:value}] [{opth f:ormat(format)}] {break}
[{bf:sheet}({it:sheetname} [,replace]) {opt m:odify}] {break}
[{opt row:names("list" "of" "names")} {opt col:names("list" "of" "names")}] {break}

{synoptline}
{synoptset 16 tabbed}{...}
{p 4}{bf:Options}{p_end}
{synopt:}{p_end}
{synopt:{opt r:eplace}}Allows {bf:outwrite} to overwrite the output file.{p_end}
{synopt:{opt s:tats()}}Adds statistics from {help ereturn:e()} at the bottom of the table, such as N, r2, or scalars added by {help estadd}.{p_end}
{synopt:{opth d:rop(varlist)}}Suppresses reporting of all variables in in {help varlist} from the output. This can be a factor variable list.{p_end}
{synopt:{opt t:stat}|{opt p:value}}Reports T-statistics or P-values in regression table, instead of the default standard errors.{p_end}
{synopt:{opth f:ormat(format)}}Format the table values. By default this is %9.2f.{p_end}
{synopt:{opt sheet()}}Place results in a target sheet if using .xlsx format.{p_end}
{synopt:{opt m:odify}}Allows {bf:outwrite} to modify the output file. Often required with {opt sheet()} to work as expected.{p_end}
{synopt:{opt row:names()}}Manually renames rows of output. By default, the rows are named to reflect the variables in the estimation command.{p_end}
{synopt:{opt col:names()}}Manually renames columns of output. By default, the columns are named to reflect the saved equation names.{p_end}
{synoptline}
{p 4 4 4}{it:Note: if used to export a matrix, {opt stats()}, {opt drop()}, and {opt t:stat}|{opt p:value} will not be accepted.}

{title:Example}

{p 2 4 4}sysuse auto.dta, clear
{break}reg price i.foreign##c.mpg
{break}est sto reg1
{break}reg price i.foreign##c.mpg##i.rep78
{break}est sto reg2
{break}estadd scalar h = 4
{break}reg price i.rep78
{break}est sto reg3
{break}estadd scalar h = 2.5

{break}  outwrite reg1 reg2 reg3 using "test.xlsx" ///
{break}   , stats(N r2 h)  replace col("TEST" "(2)") drop(i.rep78) format(%9.3f)

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Acknowledgments}

{p}While the concept of {cmd:outwrite} is original, we borrowed core functionality from {helpb xml_tab} by Zurab Sajaia and Michael Lokshin, and many ideas from such programs as {helpb estout} by Ben Jann, {helpb outreg} by John Luke Gallup, {helpb outreg2} by Roy Wada, {helpb modltbl} by John H. Tyler, {helpb mktab} by Nicholas Winter, {helpb outtex} by Antoine Terracol, and {helpb est2tex} by Marc Muendler.{p_end}
