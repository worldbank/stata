# How to use this command

## Description

`wb_git_install` installs commands from the [World Bank GitHub Stata repository](https://github.com/worldbank/stata).

Begin by installing the adofile from this location into Stata's /ado/personal folder. `wb_git_install` will then be able to access any command in this repository's [src](https://github.com/worldbank/stata/tree/master/src) directory.
```
net install "https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"
```

Commands still in development can be found in and submitted to the [dev](https://github.com/worldbank/stata/tree/master/dev) directory and will be made visible to `wb_git_install` and posted on the [landing page](http://worldbank.github.io/stata/) after review. Please feel free to contribute to development of all commands!

## Syntax

`wb_git_install` _commandName_

Thank you and enjoy!
