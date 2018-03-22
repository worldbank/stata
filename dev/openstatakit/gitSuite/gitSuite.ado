* gitSuite

* gitReady

	cap prog drop gitReady
	prog def gitReady
	
	syntax anything
	
		! git --version
		global git "`anything'"
	
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
		! git add -A
		! git commit -m "Updated from Stata at $S_DATE $S_TIME: `anything'"
		! git push
		
	end

* Have a lovely day!
