** Many-way-tab

cap prog drop multicat
prog def multicat

syntax anything [if] [in], [gen(string asis)]

marksample touse

tempvar generate

gen `generate' = ""

qui foreach var of varlist `anything' {
	local label : var label `var'
	replace `generate' = `generate' + "`comma'`label'" if `var' == 1
	local comma ", "
	}
	
qui replace `generate' = regexr(`generate',"^,","")
qui replace `generate' = "" if `touse' == 0

ta `generate'

if "`gen'" != "" gen `gen' = `generate'

	
end
