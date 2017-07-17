{smcl}
{* September 24th 2014}
{hline}
Help for {hi:visitstat}
{hline}

{title:Description}

{p}{cmd:visitstat} creates a single variable containing the correct value of a completed interaction from multiple wide-format interaction attempts and a completion binary.

{title:Syntax}

{p}{cmd:visitstat} {it:stub_list} {bf:using} {it:completion_stub}, {opt a:ttempts(integer)}

{title:Instructions}

{p}In {it:stub_list}, list the stubs which contain the relevant information. They should end in the attempt number. A new variable will be created with the stub name, stripped also of any trailing underscore. It will be labelled the same as the first stub with any 1 in the variable label removed.

{p}After {bf:using}, list the stub name which contains the indicator for the completed interaction. This should be 0 for incomplete, 1 for complete, and 0 or missing for not attempted. There should only be one complete interaction per observation. In {opt a:ttempts}, enter the maximum number of attempts.

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}