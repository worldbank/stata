{smcl}
{* February 9th 2012}{...}
{hline}
Help for {hi:crossfold}
{hline}

{title:Description}

{p}{cmd:crossfold} performs {it:k}-fold cross-validation on a specified model in order to evaluate a model's ability to fit out-of-sample data.{p_end}

{p}This procedure splits the data randomly into {it:k} partitions, then for each partition it fits the specified model using the other {it:k}-1 groups and uses the resulting parameters to predict the dependent variable in the unused group.{p_end}

{p}Finally, {cmd:crossfold} reports a measure of goodness-of-fit from each attempt. The default evaluation metric is root mean squared error (RMSE).{p_end}

{title:Syntax}

{cmd:crossfold} {it:model} [{it:model_if}] [{it:model_in}] [{it:model_weight}], 
	[{opt eif()}] [{opt ein()}] [{opt ew:eight(varname)}] 
	[{opt stub(string)}] [{opt k(value)}] [{opt loud}]
	[{opt mae}] [{opt r2}]
	[{it:model_options}]

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt eif; ein}}Error evaluation {it:if} and {it:in} specifications place restrictions on the out-of-sample set that should be fit. Modelling {it:if} and {it:in} restrictions should be specified with the model.{p_end}
{synopt:{opt ew:eight}}Weighting for error evaluation purposes. Model weights, identical or not, should be specified after the model.{p_end}
{synopt:{opt stub()}}Specifies a stub name for naming estimation results and for the results matrix. The default is {it:est}.{p_end}
{synopt:{opt k()}}Specifies a number of folds to carry out. The default is 5, and {it:k} cannot exceed 300 or the number of observations.{p_end}
{synopt:{opt loud}}Displays each model as it is fit.{p_end}
{synopt:{opt mae}}Calculates mean absolute errors (MAE) instead of RMSE.{p_end}
{synopt:{opt r2}}Calculates psuedo-R-squared (the square of the correlation coefficient of the predicted and actual values of the dependent variable) instead of RMSE.{p_end}
{synopt:{it:model_options}}Modelling command options (such as {it:fe} for {cmd:xtreg}).{p_end}
{synoptline}

{title:Examples}

{cmd:. sysuse nlsw88}
(NLSW, 1988 extract)

{p}{cmd:. crossfold reg wage union}

             |      RMSE 
-------------+-----------
        est1 |  4.171849 
        est2 |  4.105884 
        est3 |  4.038483 
        est4 |  4.151482 
        est5 |  4.171727 

{p}{cmd:. crossfold reg wage union, mae}

             |       MAE 
-------------+-----------
        est1 |   2.99209 
        est2 |   3.13541 
        est3 |  3.158161 
        est4 |  3.035878 
        est5 |  3.006016 

{p}{cmd:.crossfold reg wage hours grade i.race i.industry i.occupation, r2}

             | Pseudo-R2 
-------------+-----------
        est1 |  .2036234 
        est2 |  .1804039 
        est3 |  .2213548 
        est4 |  .2159976 
        est5 |  .1556564 

{p}{cmd:. crossfold qreg wage union [weight=hours], eweight(hours) mae}{p_end}
(importance weights assumed)

             |       MAE 
-------------+-----------
        est1 |  3.078402 
        est2 |  2.864632 
        est3 |  2.846198 
        est4 |  2.989049 
        est5 |  2.990051 

{p}{cmd:. crossfold qreg wage union collgrad age grade [weight=hours], eweight(hours) k(3) mae}{p_end}
(importance weights assumed)

             |       MAE 
-------------+-----------
        est1 |  2.449628 
        est2 |  2.700219 
        est3 |  2.588182 

{title:Saved Results}

{p}{cmd:crossfold} saves the model errors in the matrix {opt r(stub)} (which is named {bf: r(est)} if no stub name is specified).{p_end}

{p}It also saves the model parameters under the names {it:stub}{bf:1} ... {it:stub}{bf:k}. They can be recalled using {cmd:estimates restore} {it:name}.{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:References}

{p}Schonlau, Matthias. "Boosted regression (boosting): An intoductory tutorial and a Stata plugin." The Stata Journal (2005). 5, Number 3, pp.330-354.

{p}FAQ: What are pseudo R-squareds? UCLA: Academic Technology Services, Statistical Consulting Group. http://www.ats.ucla.edu/stat/mult_pkg/faq/general/psuedo_rsquareds.htm (accessed February 14, 2012).

{p_end}