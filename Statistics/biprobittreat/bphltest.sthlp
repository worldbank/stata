{smcl}
{* *! version 1.0.0  23oct2009}{...}
{cmd:help bphltest}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:bphltest} {hline 2}}Hosmer-Lemeshow goodness-of-fit test for bivariate probit model
{p2colreset}{...}

{title:Syntax}

{p 4 12 2} {cmd:bphltest} [{cmd:,} {opt groups1}{cmd:(}{it:#}{cmd:)} {opt groups2}{cmd:(}{it:#}{cmd:)}]

{title:Description}

{p 4 4 2}
{cmd:bphltest} is a postestimation command for {helpb biprobit}.
It computes the Hosmer-Lemeshow goodness-of-fit test adapted to the bivariate probit model.

{title:Options}

{p 4 8 2}
{cmd:groups1(}{it:#}{cmd:)} specifies the number of groups to use for equation 1; default is 3.

{p 4 8 2}
{cmd:groups2(}{it:#}{cmd:)} specifies the number of subgroups to use for equation 2; default is 3.

{title:Remarks}

{p 4 4 2}
{cmd:bphltest} cannot be used if {helpb biprobit} was called with any of
the following options: {cmd:partial}, {cmd:offset}, {cmd:constraints}.

{p 4 4 2}
The test still works if one of the left-hand-side variables appears on the
right side of the other equation.

{p 4 4 2}
The test is performed on the estimation sample.

{title:Saved results}

{pstd}
{cmd:bphltest} saves the following in {cmd:r()}:

{synoptset 25 tabbed}{...}
{p2col 5 25 29 2: Scalars}{p_end}
{synopt:{cmd:r(hlstat)}}test statistic{p_end}
{synopt:{cmd:r(p)}}{it:p}-value{p_end}

{title:Also see}

{psee}
Online:  {manhelp biprobit R}, {manhelp biprobit_postestimation R:biprobit postestimation}, {helpb logistic_postestimation##estatgof:estat gof}
{p_end}

Richard Chiburis 10/23/2009