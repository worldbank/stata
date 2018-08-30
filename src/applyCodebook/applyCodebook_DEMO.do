* DEMO for applyCodebook

sysuse auto, clear

cd "/Users/bbdaniels/GitHub/stata/src/applyCodebook/"

qui do "applyCodebook.ado"

applyCodebook ///
  using "applyCodebook_DEMO.xlsx" 

applyCodebook ///
  using "applyCodebook_DEMO.xlsx" , drop

applyCodebook ///
  using "applyCodebook_DEMO.xlsx" , novarlab

*
