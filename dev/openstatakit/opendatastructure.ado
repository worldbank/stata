* Folder setup

cap prog drop opendatastructure
prog def opendatastructure
syntax anything

	cap mkdir "`anything'/Data/"
		cap mkdir "`anything'/Data/Raw/"
		cap mkdir "`anything'/Data/Clean/"
		cap mkdir "`anything'/Data/Metadata/"
	cap mkdir "`anything'/Dofiles/"
	cap mkdir "`anything'/Adofiles/"
	cap mkdir "`anything'/Constructed/"

	
	file open master using "`anything'/_Master_.do", write replace
		file close master
	file open clean using "`anything'/Dofiles/makedata_clean.do", write replace
		file close clean
	file open constructed using "`anything'/Dofiles/makedata_constructed.do", write replace
		file close constructed
	
end


* Have a lovely day!
