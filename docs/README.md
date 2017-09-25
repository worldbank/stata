# World Bank GitHub

## Usage and contribution

This repository contains a broad variety of STATA commands (adofiles) which are useful in data management, statistical analysis, and the production of graphics. In many cases, these adofiles reduce the production of routine items from a tedious programming task to a single command line – such as data import and cleaning; production of summary statistics tables; and categorical bar charts with confidence intervals.

This repository is an effort to debug, polish, improve, and disseminate this set of commands and others that are developed during the course of work. As byproducts of various DEC projects, the adofiles in this repository can be found in various stages of development. Some are barely-developed commands without even a helpfile; some are fully developed with example datasets and use instructions; some have bugs or undocumented features. Few have appropriate levels of code commenting.

Please use the adofiles and/or any code they contain for WB or external projects and analysis as desired; they are shared under the [MIT License](https://opensource.org/licenses/MIT). Please contribute development of both existing code, new functionality, and documentation. For questions about any existing or intended functionality of any of the files, contact [Benjamin Daniels](mailto: bdaniels@worldbank.org) at [DIME Analytics](http://www.worldbank.org/en/research/dime/brief/DIME-Analytics).

Thank you and enjoy!

## Installing Commands

### wb_git_install

[`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) installs commands from the [World Bank GitHub Stata respository](https://github.com/worldbank/stata).

Begin by installing [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) into the /ado/personal folder. Type `sysdir` in the Stata console to locate this. [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) will then be able to access any command in the [src](https://github.com/worldbank/stata/tree/master/src) directory by writing `wb_git_install commandName`.

Commands still in development can be found in and submitted to the [dev](https://github.com/worldbank/stata/tree/master/dev) directory and will be made visible to [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) and posted on the [landing page](http://worldbank.github.io/stata/) after review. Please feel free to contribute to development of all commands!

### xml_tab

Many of the commands listed here that write to Excel spreadsheets depend on [`xml_tab`](http://fmwww.bc.edu/repec/bocode/x/xml_tab.html), which is included in the [Poverty Research Toolkit](http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTPROGRAMS/EXTPOVRES/0,,contentMDK:20292195~menuPK:546578~pagePK:64168182~piPK:64168060~theSitePK:477894,00.html#xml_tab) and authored by [Zurab Sajaia](mailto: zsajaia@worldbank.org) and [Michael Lokshin](mlokshin@worldbank.org). [`xml_tab`](http://fmwww.bc.edu/repec/bocode/x/xml_tab.html) is available for installation in Stata by writing `net install dm0037.pkg`; `ssc install xml_tab, replace`; or `findit xml_tab`.

# Visual Library

## Graphics

### betterBar

[`betterBar`](https://github.com/worldbank/stata/tree/master/src/betterBar) creates bar graphs for multiple variables with confidence intervals, setting `by()` and `over()` groups, adding labels and legends, and various styling commands.

![betterBar demo](https://raw.githubusercontent.com/worldbank/stata/master/src/betterBar/betterBar.png)

```
wb_git_install betterBar
sysuse auto , clear
betterBar mpg trunk turn ///
  , over(foreign) se ///
  barlook(1 lw(thin) lc(white) fi(100))
```

### orChart

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

### dta2kml

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

### txt2qr

[`txt2qr`](https://github.com/worldbank/stata/tree/master/src/txt2qr) outputs arbitrary text into a QR code for use with scanning devices such as ODK plugins.

![txt2qr demo](https://raw.githubusercontent.com/worldbank/stata/master/src/txt2qr/txt2qr.png)

```
wb_git_install txt2qr
txt2qr ///
  worldbank.github.io/stata/ ///
  using txt2qr.png ///
  , save replace
```

### timeLines

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



## Data Management

### import_metadata

[`import_metadata`](https://github.com/worldbank/stata/tree/master/src/import_metadata) allows the user to create an Excel-based metadata file, then import one or more .xlsx or .dta files, including harmonizing variable naming and categorical coding and labeling. It can be used to expedite the cleaning of a single file or to combine (append) different surveys or survey rounds, taking the "hard work" out of the dofile.

![import_metadata demo](https://raw.githubusercontent.com/worldbank/stata/master/src/import_metadata/import_metadata.png)

```
wb_git_install import_metadata
[see documentation for extensive examples]
```

### cleanLabels

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

## Analysis

### sumStats

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

### knapsack

[`knapsack'](https://github.com/worldbank/stata/tree/master/src/knapsack) implements a [dynamic programming solution to the Knapsack Problem](http://www.es.ele.tue.nl/education/5MC10/Solutions/knapsack.pdf), which selects an optimal set from a list of options based on input variables indicating price and value, and a set budget.

![knapsack demo](https://raw.githubusercontent.com/worldbank/stata/master/src/knapsack/knapsack.png)


```
wb_git_install knapsack
sysuse auto, clear
keep mpg price
rename (mpg price)(cost value)
knapsack 500, p(cost) v(value) gen(chosen)
di "`r(max)'"
table chosen , c(sum cost sum value)'
```
