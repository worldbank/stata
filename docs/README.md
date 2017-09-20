# Introduction

This repository contains a broad variety of STATA commands (adofiles) which are useful in data management, statistical analysis, and the production of graphics. In many cases, these adofiles reduce the production of routine items from a tedious programming task to a single command line – such as data import and cleaning; production of summary statistics tables; and categorical bar charts with confidence intervals.

This repository is an effort to debug, polish, improve, and disseminate this set of commands and others that are developed during the course of work. As byproducts of various DEC projects, the adofiles in this repository can be found in various stages of development. Some are barely-developed commands without even a helpfile; some are fully developed with example datasets and use instructions; some have bugs or undocumented features. Few have appropriate levels of code commenting.

Please use the adofiles and/or any code they contain for WB or external projects and analysis as desired; they are shared under the [MIT License](https://opensource.org/licenses/MIT). Please contribute development of both existing code, new functionality, and documentation. For questions about any existing or intended functionality of any of the files, contact [Benjamin Daniels](mailto: bdaniels@worldbank.org).

Thank you and enjoy!

# Installing Commands

Commands can be accessed directly through the [GitHub respository](https://github.com/worldbank/stata/) or by downloading and installing `wb_git_install` [directly](https://github.com/worldbank/stata/tree/master/wb_git_install) which will add the files to Stata on command.

# Visual Library

## betterBar

![betterBar demo](https://www.mathsisfun.com/data/images/bar-graph-fruit.svg)

```
wb_git_install betterBar
sysuse auto
betterBar mpg trunk turn \\\
  , over(foreign) se \\\
  barlook(1 lw(thin) lc(white) fi(100))
```
