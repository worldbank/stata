{smcl}
{* Sep 26th 2017}
{hline}
Help for {hi:xiPlus}
{hline}

{title:Description}

{p}{cmd:xiPlus} is a package of commands that accumulates and then runs regressions, including multiple interaction terms, ourputting a single properly labeled results table in {help using} via {help xml_tab}.

{title:Syntax}

{p}{bf:First Regression: } {cmd:xiReg} {it:regression_name} [{help if}] , clear command({it:regression_command}) depvar({it:dependent_variable}) rhs({it:RHS_variables}){p_end}
{p}{bf:More Regressions: }[{cmd:xiReg} {it:regression_name} [{help if}] , {bind:     } command({it:regression_command}) depvar({it:dependent_variable}) rhs({it:RHS_variables})] {p_end}
{break}
{p}{bf:Write to Excel: }{bind:  } {cmd:xiOut} {help using} , [stats({it:dependent_variable_statistics})] [{help xml_tab} options]

{title:Instructions}

{p}xiReg is first used with the option {opt clear} to set the first regression model.{p_end}
{p}xiReg can then accumulate additional regressions as the command is repeated excluding the clear option.{p_end}
{p}All regressions must be run on the same data.{p_end}
{p}xiOut prints the properly formatted regression table to the .xls file specified in {help using}.{p_end}
{p}The {opt stats()} option in xiOut adds the requested statistics from the dependent variables to the table.{p_end}

{title:xiGen}

{cmd:xiGen} will expand a set of interaction variables into data.

{title:Demo}

{p}sysuse auto, clear{p_end}
{break}
{p}xiReg reg1 , clear /// {p_end}
{p 2}command(ivregress 2sls) depvar(price) rhs( ( i.foreign*headroom = turn mpg turn*mpg ) gear_ratio){p_end}
{p}xiReg reg2 , ///	{p_end}
{p 2}command(regress) depvar(price) rhs(gear_ratio i.foreign*headroom i.foreign*trunk*displacement ){p_end}
{break}
{p}xiOut using "demo.xls" , replace stats(mean){p_end}
{break}
{p}xiGen i.foreign*headroom{p_end}

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org

{p_end}
