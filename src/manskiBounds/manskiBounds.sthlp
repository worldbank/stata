{smcl}
{* October 4th 2017}
{hline}
Help for {hi:manskiBounds}
{hline}

{title:Description}

{p}{cmd:manskiBounds} implements Manski bounding simulations as in Andrabi and Das (2017). For a binary treatment variable and a binary outcome variable, the first simulation is "extreme" bounds: all missing observations are assigned the outcome that would produce the least significant effect of treatment on outcome. This is then relaxed by varying the "bounding fraction" until outcome simulation is random in both treatment and control groups with missing outcomes (50%), which induces measurement error in the original estimate proportional to the number of missing outcome values. The displayed graph shows this relaxation process, as well as the bounding fractions at which p<0.01 and p<0.05 are attained, and the estimated effect from the original model on non-missing data.

{title:Syntax}

{p}{cmd:manskiBounds} {it:regression_model} [{help if}] [{help in}], {it:regression_options} {opth t:reatment(varname)} {opth o:utcome(varname)} {opt s:eed(integer)}{p_end}
{break}
{p}{cmd:treatment} and {cmd:outcome} must be binary; {cmd:treatment} must be the first variable in the regression; and the regression command must produce an "ordinary" results table (as in {help regress}).{p_end}

{title:Author}

Benjamin Daniels
bdaniels@worldbank.org

{title:Demo}

	clear
	set obs 1000
	matrix c = (1,-.5,0 \ -.5,1,.4 \ 0,.4,1)
	corr2data x y z, corr(c)
	
	replace x = 1 if x > 0
	replace x = 0 if x < 0
	replace y = 1 if y > 0
	replace y = 0 if y < 0
	replace x = . if z > .5
	
	manskiBounds reg x y z ///
		, t(y) o(x)
		
	graph export manskiBounds.png , replace

{title:References}

In Aid We Trust: Hearts and Minds and the Pakistan Earthquake of 2005
Tahir Andrabi and Jishnu Das
The Review of Economics and Statistics 2017 99:3, 371-386 
http://www.mitpressjournals.org/doi/abs/10.1162/REST_a_00638

{p_end}