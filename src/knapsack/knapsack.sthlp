{smcl}
{* Sep 10th 2017}
{hline}
Help for {hi:knapsack}
{hline}

{title:Description}

{p}Implements a solution for the 0/1 Knapsack Problem as described in http://www.es.ele.tue.nl/education/5MC10/Solutions/knapsack.pdf. Given a total budget, and data containing each potential item's cost and value, {cmd:knapsack} returns the maximum possible total value that can be purchased using the budget.

{p}If {opt gen:erate()} is specified, {it:newvarname} is created, containing 1 if the item is in the optimal set and 0 if it is not.

{title:Syntax}

{p}{cmd:knapsack} {it:budget} , {opt p:rice(varname)} {opt v:alue(varname)} {opt gen:erate(newvarname)}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com
