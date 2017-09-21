{smcl}
{* *! version 1.0.0  30oct2009}{...}
{cmd:help biprobittreat}
{hline}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{hi:biprobittreat} {hline 2}}Treatment effects for bivariate probit model
{p2colreset}{...}

{title:Syntax}

{p 4 4 2}
{cmd:biprobittreat} uses the same syntax as {helpb biprobit}.

{title:Description}

{p 4 4 2}
{cmd:biprobittreat} computes the average treatment effect and average treatment effect
on the treated in the bivariate probit model.

{title:Remarks}

{p 4 4 2}
The first equation specified is assumed to be the outcome equation, and the second
equation is assumed to be the treatment equation.  The treatment variable should
appear on the right-hand side of the outcome equation.

{title:Example}

{p 4 4 2}
The recommended method for obtaining confidence intervals is via bootstrapping:

{phang2}{cmd:. bootstrap _b ate=r(ate) att=r(att), reps(199): biprobittreat (Y = T X) (T = Z X)}{p_end}
{phang2}{cmd:. estat bootstrap, percentile}{p_end}

{title:Saved results}

{pstd}
{cmd:biprobittreat} saves the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(ate)}}Average treatment effect{p_end}
{synopt:{cmd:r(att)}}Average treatment effect on the treated{p_end}

{title:Also see}

{psee}
Online:  {manhelp biprobit R}, {manhelp treatreg R}, {manhelp bootstrap R}
{p_end}

Richard Chiburis 10/30/2009