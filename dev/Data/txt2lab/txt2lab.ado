* Text to labelled field

cap prog drop txt2lab
prog def txt2lab

syntax anything using/ , [update]

* Update option

if "`update'" == "" local missonly "& `anything' == ."


* Get the categories

	local thelabel: val label `anything'
	preserve
	uselabel `thelabel', clear
		qui count
		local theValues ""
		local theLabels ""
		forvalues i = 1/`r(N)' {
			local nextValue = value[`i']
			local nextLabel = label[`i']
			local theValues "`theValues' `nextValue'"
			local theLabels `"`theLabels' "`nextLabel'" "'
			}
			
		restore
		
* Fill the numeric variable
		
	local nLabels : word count `theValues'
		
		forvalues i = 1/`nLabels' {
		
			local value : word `i' of `theValues'
			local label : word `i' of `theLabels'
			
			replace `anything' = `i' if `using' == "`label'" `missonly'
			
		}
		
end

