* gitSuite

* gitReady

	cap prog drop gitReady
	prog def gitReady

	syntax anything

		! git --version
		global git `anything'

	end

* gitSet

	cap prog drop gitSet
	prog def gitSet

	syntax [anything]

		cd "${git}"
		! git pull

	end

* gitGo

	cap prog drop gitGo
	prog def gitGo

	syntax [anything]

		cd "${git}"

		* Change all xls outputs to magic csvs

			cap confirm file "${git}/csv.lua"
			if _rc != 0 ///
				cap copy "https://gist.githubusercontent.com/bbdaniels/089fa74cb312eac2694fbe683b9a9dc8/raw/d3416242d10ec3551e17253fa924cdf6bdf1677b/csv.lua" ///
				"${git}/csv.lua" , replace // <-- installs rendering luacode to overleaf : must set rendering to LuaTeX

			local xlsFiles : dir `"${git}/"' files "*.xls"
			local xlsFiles = subinstr(`" `xlsFiles' "', `"""' , "" , .)
			foreach xlsFile in `xlsFiles' {
				xls2csv `xlsFile'
				}

		* Push to remote

			! git add -A
			! git commit -m "Updated from Stata at $S_DATE $S_TIME: `anything'"
			! git push

	end

* CSV converter

	cap prog drop xls2csv
	prog def xls2csv

	syntax anything

	cd "${git}"

	! /Applications/LibreOffice.app/Contents/MacOS/soffice ///
		--headless -convert-to xlsx:"Calc MS Excel 2007 XML" ///
			`anything'

		preserve

	sleep 5000
	import excel using "`anything'x" , clear

	qui foreach var of varlist * {
		replace `var' = "0.00" if regexm(`var',"e-")
		replace `var' = substr(`var',1,strpos(`var',".")+2) if strpos(`var',".")
		replace `var' = "0" + `var' if strpos(`var',".") == 1
		replace `var' = subinstr(`var',"-.","-0.",1) if strpos(`var',"-.") == 1
		}

	local theCSV = subinstr("`anything'","xls","csv",.)

	outsheet using "`theCSV'" , c replace noq non
	!rm `anything'
	!rm `anything'x

	end

* Have a lovely day!
