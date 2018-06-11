# World Bank GitHub

## Other World Bank Repositories

* [Impact Evaluations Toolkit](https://worldbank.github.io/ietoolkit/)
* [Stata Visual Library](https://worldbank.github.io/Stata-IE-Visual-Library/)
* [Distributional Impact Analysis Toolkit](https://worldbank.github.io/DIA-toolkit/)

## Usage and contribution

This repository is an effort to debug, polish, improve, and disseminate useful reusable Stata code that is developed during the course of work. This repository is for such useful snippets – formalized as [adofiles](https://www.stata.com/manuals13/u17.pdf) – which automate routine data management, statistical analysis, and graphing tasks such as data import and cleaning, production of summary statistics tables, and categorical bar charts with confidence intervals.

Commands still in development can be found in and submitted to the [dev branch](https://github.com/worldbank/stata/tree/dev); please fork that branch and submit a pull request at any time. Current versions of released commands are in [src](https://github.com/worldbank/stata/tree/master/src) after review by the team. Commands in [src](https://github.com/worldbank/stata/tree/master/src) are surfaced on this [landing page](http://worldbank.github.io/stata/) and made visible to [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) after review.

Please use the adofiles and/or any code they contain as desired; they are shared under the [MIT License](https://opensource.org/licenses/MIT). Please contribute development of existing code, new functionality, and documentation. For questions about any existing or intended functionality of any of the files, contact [Benjamin Daniels](mailto:bdaniels@worldbank.org) at [DIME Analytics](http://www.worldbank.org/en/research/dime/brief/DIME-Analytics).

## Installing Commands

### wb_git_install

[`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) copies code from this [World Bank GitHub Stata respository](https://github.com/worldbank/stata) into Stata.  `wb_git_install` can access any command in this repository's [src](https://github.com/worldbank/stata/tree/master/src) directory by name alone. Begin by installing [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install):
```
net install "https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"
```

Some corporate security policies, including the World Bank's, will not allow this functionality on company-managed machines. If the above command returns a security error, you will need to access the [src](https://github.com/worldbank/stata/tree/master/src) directory directly and install the commands manually into `c(sysdir_plus)` or `c(sysdir_personal)`. Type `sysdir` in Stata to see the location of these folders; [or access the Stata documentation for more details.](https://www.stata.com/manuals13/u17.pdf)

### xml_tab

Many of the commands listed here that write to Excel spreadsheets depend on [`xml_tab`](http://fmwww.bc.edu/repec/bocode/x/xml_tab.html), which is included in the [Poverty Research Toolkit](http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTPROGRAMS/EXTPOVRES/0,,contentMDK:20292195~menuPK:546578~pagePK:64168182~piPK:64168060~theSitePK:477894,00.html#xml_tab) and authored by [Zurab Sajaia](mailto:zsajaia@worldbank.org) and [Michael Lokshin](mailto:mlokshin@worldbank.org). [`xml_tab`](http://fmwww.bc.edu/repec/bocode/x/xml_tab.html) is available for installation in Stata by writing `net install dm0037.pkg`; `wb_git_install xml_tab, replace`; or `findit xml_tab`.


# Codebooks for Data Management

## importCodebook

[`importCodebook`](https://github.com/worldbank/stata/tree/master/src/importCodebook) allows the user to create an Excel-based metadata file, then import one or more .xlsx or .dta files, including harmonizing variable naming and categorical coding and labeling. It can be used to expedite the cleaning of a single file or to combine (append) different surveys or survey rounds, taking the "hard work" out of the dofile.

![importCodebook demo](https://raw.githubusercontent.com/worldbank/stata/master/src/importCodebook/importCodebook.png)

```
wb_git_install importCodebook
[see documentation for extensive examples]
```

## applyCodebook

[`applyCodebook`](https://github.com/worldbank/stata/tree/master/src/applyCodebook) allows the user to create an Excel codebook file, which will apply renames, recodes, variable labels, and value labels to the open dataset. It can be used to expedite the cleaning of a single file , taking the "hard work" out of the dofile.

![applyCodebook demo](https://raw.githubusercontent.com/worldbank/stata/master/src/applyCodebook/applyCodebook.png)

```
wb_git_install applyCodebook
sysuse auto, clear

applyCodebook ///
  using "applyCodebook_DEMO.xlsx" ///
  , rename varlab recode vallab
```

## exportCodebook

[`exportCodebook`](https://github.com/worldbank/stata/tree/master/src/exportCodebook) reads the currently open dataset and either (A) creates a codebook for it in the specified location; or (B) reads a series of .dofiles
    that reference the data and keeps only the variables that those dofiles reference.


![exportCodebook demo](https://raw.githubusercontent.com/worldbank/stata/master/src/exportCodebook/exportCodebook.png)

```
wb_git_install exportCodebook
sysuse auto , clear
exportCodebook "exportCodebook_compact" 	, compact
```

# Commands for Data Analysis

## betterBar

[`betterBar`](https://github.com/worldbank/stata/tree/master/src/betterBar) creates bar graphs for multiple variables with confidence intervals, setting `by()` and `over()` groups, adding labels and legends, and various styling commands.

![betterBar demo](https://raw.githubusercontent.com/worldbank/stata/master/src/betterBar/betterBar.png)

```
wb_git_install betterBar
sysuse auto , clear
betterBar mpg trunk turn ///
  , over(foreign) se ///
  barlook(1 lw(thin) lc(white) fi(100))
```

## weightTab

[`weightTab`](https://github.com/worldbank/stata/tree/master/src/weightTab) creates tables of (weighted) statistics and, optionally, bar graphs for multiple variables with any output statistic from the `mean` command.

![weightTab demo](https://raw.githubusercontent.com/worldbank/stata/master/src/weightTab/weightTab.png)

```
wb_git_install weightTab
sysuse auto , clear
weightTab  price-trunk [pweight = weight] ///
	using "weightTab.xls" ///
	, over(foreign) stats(b se ul ll) graph
```

## randReg

[`randReg`](https://github.com/worldbank/stata/tree/master/src/randReg) provides simulation results and visual illustration of randomization-based p-values, based on [Randomization inference vs. bootstrapping for p-values.](https://jasonkerwin.com/nonparibus/2017/09/25/randomization-inference-vs-bootstrapping-p-values/)

![randReg demo](https://raw.githubusercontent.com/worldbank/stata/master/src/randReg/randReg.png)

```
clear
set obs 1000
gen treat_rand = runiform()
gen treatment = treat_rand > 0.5
gen error = rnormal()
gen outcome = .3*treatment + 3*error
randReg reg outcome treatment , seed(4747) t(treatment) graph reps(100)
  graph export "randReg.png" , replace width(1000)
  return list
```

## orChart

[`orChart`](https://github.com/worldbank/stata/tree/master/src/orChart) generates a chart of primary logistic regression results for a single binary independent variable, expressed as odds ratios, for a list of dependent variables, combined with a table detailing those results.

![orChart demo](https://raw.githubusercontent.com/worldbank/stata/master/src/orChart/orChart.png)

```
wb_git_install orChart
webuse census , clear
tab region , gen(region_)
gen endsinA = substr(state,-1,1) == "a"
orChart ///
  region_1 region_2 region_3 region_4 ///
  , command(logit) rhs(endsinA pop) ///
  case0(Others) case1(States Ending in A) xsize(8)
```

## sumStats

[`sumStats`](https://github.com/worldbank/stata/tree/master/src/sumStats) will produce requested statistics for any number and combination of variables and sample restrictions.

![sumStats demo](https://raw.githubusercontent.com/worldbank/stata/master/src/sumStats/sumStats.png)

```
wb_git_install sumStats
sysuse auto , clear
sumStats ///
  (price mpg rep78 headroom trunk if foreign == 0) ///
  (price mpg rep78 headroom trunk if foreign == 1) ///
  using "table_1.xls" ///
  , replace stats(mean sd p5 p95 N)
 ```

## knapsack

[`knapsack`](https://github.com/worldbank/stata/tree/master/src/knapsack) implements a [dynamic programming solution to the Knapsack Problem](http://www.es.ele.tue.nl/education/5MC10/Solutions/knapsack.pdf), which selects an optimal set from a list of options based on input variables indicating price and value, and a set budget.

![knapsack demo](https://raw.githubusercontent.com/worldbank/stata/master/src/knapsack/knapsack.png)

```
wb_git_install knapsack
sysuse auto, clear
keep mpg price
rename (mpg price)(cost value)
knapsack 500, p(cost) v(value) gen(chosen)
di "`r(max)'"
table chosen , c(sum cost sum value)
```

## dta2kml

[`dta2kml`](https://github.com/worldbank/stata/tree/master/src/dta2kml) outputs decimal lat/lon coordinates into a KML file for visual exploration.

![dta2kml demo](https://raw.githubusercontent.com/worldbank/stata/master/src/dta2kml/dta2kml.jpg)

```
wb_git_install dta2kml
clear
set obs 100
gen lat = rnormal() +38
gen lon = rnormal() -77
dta2kml using demo.kml , lat(lat) lon(lon) replace
```

## txt2qr

[`txt2qr`](https://github.com/worldbank/stata/tree/master/src/txt2qr) outputs arbitrary text into a QR code for use with scanning devices such as ODK plugins.

![txt2qr demo](https://raw.githubusercontent.com/worldbank/stata/master/src/txt2qr/txt2qr.png)

```
wb_git_install txt2qr
txt2qr ///
  worldbank.github.io/stata/ ///
  using txt2qr.png ///
  , save replace
```

## flowChart

[`flowChart`](https://github.com/worldbank/stata/tree/master/src/flowChart) allows for the creation of dynamically updating custom tables and flowcharts via an Excel spreadsheet with a simple interface.

![flowChart demo](https://raw.githubusercontent.com/worldbank/stata/master/src/flowChart/flowChart.png)

```
wb_git_install flowChart
sysuse auto, clear
flowchart using "flowChart.xlsx"
```

## manskiBounds

[`manskiBounds`](https://github.com/worldbank/stata/tree/master/src/manskiBounds)  implements Manski bounding simulations as in Andrabi and Das (2017). For a binary treatment variable and a binary outcome variable, the first simulation is "extreme" bounds: all missing observations are assigned the outcome that would produce the least significant effect of treatment on outcome. This is then relaxed by varying the "bounding fraction" until outcome simulation is random in both treatment and control groups with missing outcomes (50%), which induces measurement error in the original estimate proportional to the number of missing outcome values. The displayed graph shows this relaxation process, as well as the bounding fractions at which p<0.01 and p<0.05 are attained, and the estimated effect from the original model on non-missing data.

![manskiBounds demo](https://raw.githubusercontent.com/worldbank/stata/master/src/manskiBounds/manskiBounds.png)

```
wb_git_install manskiBounds
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
```

## timeLines

[`timeLines`](https://github.com/worldbank/stata/tree/master/src/timeLines) creates a graphical representation of time use for various panel units when each observation represents an activity with a start and end time.

![timeLines demo](https://raw.githubusercontent.com/worldbank/stata/master/src/timeLines/timeLines.png)

```
wb_git_install timeLines
webuse census , clear
keep in 40/50
replace pop18p = pop18p / 1000
replace pop = pop / 1000
format pop18p %tdMon_CCYY
drop if state == "Virginia"
xtile category = popurban , n(2)
  label def category 1 "Early Adopters" 2 "Late Adopters"
  label val category category
timeLines , ///
  id(region) start(pop18p) end(pop) ///
  labels(state) labopts(mlabangle(30)) ///
  xsize(7) class(category) classcolors(maroon navy)
```

# Commands for Data Cleaning

## cleanLabels

[`cleanLabels`](https://github.com/worldbank/stata/tree/master/src/cleanLabels) removes characters from value labels. By default it removes “,” and “:” since these are known to cause issues with export commands.

![cleanLabels demo](https://raw.githubusercontent.com/worldbank/stata/master/src/cleanLabels/cleanlabels.png)

```
wb_git_install cleanLabels
sysuse auto , clear
label def origin 1 "Of, Foreign : Origin" 0 "D,omes:tic" , modify
labelbook origin
cleanLabels foreign
labelbook origin
```
