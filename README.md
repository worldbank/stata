# World Bank GitHub Stata repository

## Description

This repository contains a broad variety of Stata commands (adofiles) which are useful in data management, statistical analysis, and the production of graphics. In many cases, these adofiles reduce the production of routine items from a tedious programming task to a single command line – such as data import and cleaning; production of summary statistics tables; and categorical bar charts with confidence intervals.

This repository is an effort to debug, polish, improve, and disseminate this set of commands and others that are developed during the course of work. As byproducts of various DEC projects, the adofiles in this repository can be found in various stages of development. Some are barely-developed commands without even a helpfile; some are fully developed with example datasets and use instructions; some have bugs or undocumented features. Few have appropriate levels of code commenting.

Please use the adofiles and/or any code they contain for WB or external projects and analysis as desired; they are shared under the MIT License (https://opensource.org/licenses/MIT). Please contribute development of both existing code, new functionality, and documentation. For questions about any existing or intended functionality of any of the files, contact Benjamin Daniels (bbdaniels@gmail.com).

Thank you and enjoy!

## How to use

[`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) installs commands from the [World Bank GitHub Stata directory](https://github.com/worldbank/stata).

Begin by installing the adofile from this location into the /ado/personal folder. It will then be able to access any command in the [src](https://github.com/worldbank/stata/tree/master/src) directory.

Commands still in substantial development can be found in the development branch and will be made visible to [`wb_git_install`](https://github.com/worldbank/stata/tree/master/wb_git_install) and posted on the [landing page](http://worldbank.github.io/stata/) after review. Please feel free to contribute to development of all commands!
