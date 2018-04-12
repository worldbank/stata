* DEMO for applyCodebook

sysuse auto, clear

cd "/Users/bbdaniels/GitHub/stata/src/applyCodebook/"

qui do "applyCodebook.ado"

applyCodebook ///
  using "applyCodebook_DEMO.xlsx" ///
  , rename varlab recode vallab




*
