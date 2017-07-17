{smcl}
{* Dec 30th 2014}
{hline}
Help for {hi:ppsplus}
{hline}

{title:Description}

{p}{cmd:ppsplus} performs probability-proportional-to-size sampling, even when some observations are too large for sampling under the traditional PPS sampling framework. It also generates appropriate weights for the sample as a result.

{title:Syntax}

{p}{cmd:ppsplus} {it:sample_newvar}, {opth s:ize(varname)} {opt n:umber(sample_size)} {opt w:eight(newvar)} [{opt seed()}]

{title:Instructions}

{p}Specify the variable indicating the size, the variable indicating the number of observations to be sampled, and the variables that will hold the sampling dummy and the weights. All weights will sum to 1. They are calculated as ({it:size}/{it:total_size}) for observations that would be sampled with probability equal to or greater than 1 in ordinary PPS, which are sampled with probability 1. Weights are calculated as (1/{it:remaining_N})*({it:remaining_size}/{it:total_size}) for observations which would be sampled with probability less than 1, which are sampled by PPS after including all oversized observations in the sample. That is, all remaining observations are weighted equally, as in typical PPS sampling.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}