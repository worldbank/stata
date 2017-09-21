# World Bank GitHub

## Usage and contribution

This repository contains a broad variety of STATA commands (adofiles) which are useful in data management, statistical analysis, and the production of graphics. In many cases, these adofiles reduce the production of routine items from a tedious programming task to a single command line – such as data import and cleaning; production of summary statistics tables; and categorical bar charts with confidence intervals.

This repository is an effort to debug, polish, improve, and disseminate this set of commands and others that are developed during the course of work. As byproducts of various DEC projects, the adofiles in this repository can be found in various stages of development. Some are barely-developed commands without even a helpfile; some are fully developed with example datasets and use instructions; some have bugs or undocumented features. Few have appropriate levels of code commenting.

Please use the adofiles and/or any code they contain for WB or external projects and analysis as desired; they are shared under the [MIT License](https://opensource.org/licenses/MIT). Please contribute development of both existing code, new functionality, and documentation. For questions about any existing or intended functionality of any of the files, contact [Benjamin Daniels](mailto: bdaniels@worldbank.org).

Thank you and enjoy!

## Installing Commands

[`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) installs commands from the [World Bank GitHub Stata respository](https://github.com/worldbank/stata).

Begin by installing [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) into the /ado/personal folder. Type `sysdir` in the Stata console to locate this. [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) will then be able to access any command in the [src](https://github.com/worldbank/stata/tree/master/src) directory by writing `wb_git_install commandName`.

Commands still in development can be found in and submitted to the [dev](https://github.com/worldbank/stata/tree/master/dev) directory and will be made visible to [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) and posted on the [landing page](http://worldbank.github.io/stata/) after review. Please feel free to contribute to development of all commands!

# Visual Library

## Graphics

### betterBar

[`betterBar`](https://github.com/worldbank/stata/tree/master/src/betterBar) creates bar graphs for multiple variables with confidence intervals, setting `by()` and `over()` groups, adding labels and legends, and various styling commands.

![betterBar demo](https://raw.githubusercontent.com/worldbank/stata/master/src/betterBar/betterBar.png)

```
wb_git_install betterBar
sysuse auto
betterBar mpg trunk turn \\\
  , over(foreign) se \\\
  barlook(1 lw(thin) lc(white) fi(100))
```

## Data Management

### import_metadata

[`import_metadata`](https://github.com/worldbank/stata/tree/master/src/import_metadata) allows the user to create an Excel-based metadata file, then import one or more .xlsx or .dta files, including harmonizing variable naming and categorical coding and labeling. It can be used to expedite the cleaning of a single file or to combine (append) different surveys or survey rounds, taking the "hard work" out of the dofile.

![import_metadata demo](https://raw.githubusercontent.com/worldbank/stata/master/src/import_metadata/import_metadata.png)

```
wb_git_install import_metadata
[see documentation for extensive examples]
```

## Statistical Analysis

### sumStats

[`sumStats`](https://github.com/worldbank/stata/tree/master/src/sumStats) will produce requested statistics for any number and combination of variables and sample restrictions.

![sumStats demo](https://raw.githubusercontent.com/worldbank/stata/master/src/sumStats/sumStats.png)

```
sysuse auto.dta, clear
sumStats ///
  (sumstats (price mpg rep78 headroom trunk if foreign == 0) ///
  (price mpg rep78 headroom trunk if foreign == 1) ///
  using "table_1.xls" , replace stats(mean sd p5 p95 N)
 ```



