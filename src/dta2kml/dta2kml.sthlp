{smcl}
{* December 5th 2013}{...}
{hline}
Help for {hi:dta2kml}
{hline}

{title:Description}

{p}{cmd:dta2kml} outputs a KML file from selected datapoints in a Stata dataset.{p_end}

{title:Syntax}

{cmd:dta2kml} {help using} {it:filename} {ifin}, [{opt replace}]
	{opth lat:itude(varname)} {opth lon:gitude(varname)} [{opth alt:itude(varname)}]
	[{opt lines(group_var index_var)}] [{it:point_options}]
	

{synoptset}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt Line Options}}{p_end}{break}
{synopt:{opt lines()}}Specify the grouping variable (unique for each line) and the index variable, ranging from 1 to {it:n} consecutively for each element. If {opt lines()} is specified only this type of data can be used.{p_end}{break}
{synopt:{opt Point Options}}{p_end}{break}
{synopt:{opt f:olders()}}Indicates a variable containing folder names.{p_end}
{synopt:{opt n:ames()}}Indicates a variable containing placemark names.{p_end}
{synopt:{opt i:cons()}}Indicates a variable containing the full URLs of the desired icons from the libraries located at {it:http://kml4earth.appspot.com/icons.html}. If this option is not specified, all placemarks display the default icon.{p_end}
{synopt:{opt d:escriptions()}}Indicates a variable containing descriptions to attach to the placemarks.{p_end}
{synoptline}


{title:Notes}

{p}Latitude and longitude must be specified in numeric decimal format, not degrees-minutes-seconds format or string format. Altitude must be specified numerically in meters.{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{p_end}