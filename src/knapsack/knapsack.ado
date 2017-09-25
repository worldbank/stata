// Returns the 0/1 knapsack problem solution values given a price and value variable and a price budget.

version 12.0

cap prog drop knapsack
prog def knapsack , rclass

syntax ///
  anything(name=budget id="budget constraint") ///
  [if] [in], ///
  Price(varname) Value(varname) ///
  [GENerate(string asis)]

* Setup in Stata

marksample touse

  if("`generate'" != "") {
    gen `generate' = .
  }

  local cols = `budget' + 1
    set matsize 10000

  qui count if `touse'
    local obs = `r(N)'
    local rows = `obs' + 1

  local theLabel : var label `value'

* Mata setup

mata: mata clear
m {

    st_view(v=0,.,"`value'","`touse'")
		v = 0 \ v
  	st_view(w=0,.,"`price'","`touse'")
		w = 0 \ w

* Loop over budget * items space to find solutions


  theSolutions = J(`rows',`cols',0)

  for(i=2;i<=`rows';i++) {
    for (j=1;j<=`budget';j++) {
      if(w[i] > j) {
        theSolutions[i,j+1] = theSolutions[i-1,j+1]
      }
      else {
	      opts = theSolutions[i-1, j+1], theSolutions[i-1, j-w[i]+1] + v[i]
        theSolutions[i, j+1] = max(opts)
      }
    }
  }

* Get list of chosen items

  isChosen = J(`rows',1,0)
  theColumn = `cols'
  for(i=`rows';i>1;i--) {
    if(theSolutions[i,theColumn]>theSolutions[i-1,theColumn]) {
      isChosen[i]=1
      theColumn = theColumn - w[i]
      }
  }

* Pass back to Stata

  isChosen = isChosen[|2\.|]

  if("`generate'" != "") {
    st_store(.,"`generate'",isChosen)
  }

  theSolution = theSolutions[`rows',`cols']
  st_matrix("theSolution",theSolution)

* End Mata

  } // End Mata

* Print the solution in Stata and save to r()

  local theSolution = el(theSolution,1,1)
  return scalar max = `theSolution'
  di in red "Maximum Total `theLabel' = `theSolution'"

* Finish up

  cap mat drop theSolution

end

/*********** Demo *********

sysuse auto, clear
keep mpg price
rename (mpg price)(cost value)

set trace off
set tracedepth 2

knapsack 500, p(cost) v(value) gen(chosen)

di "`r(max)'"
table chosen , c(sum cost sum value)



* Have a lovely day!
