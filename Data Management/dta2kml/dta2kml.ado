*** Writes .dta to KML

capture program drop dta2kml
program define dta2kml
version 9.0

syntax using [if] [in], LATitude(varname numeric) LONgitude(varname numeric) [ALTitude(varname numeric)] ///
	[Folders(varname)] [Names(varname)] [Icons(varname string)] [Descriptions(varname)] [Replace] ///
	[lines(string asis)] // Should be given as grouping variable and index variable.
	
marksample touse

preserve
tempfile subsave

qui {

drop if `touse' == 0

*********************
* Write file header *
*********************

	cap file close kmlfile
	file open kmlfile `using', write `replace'
	
	#delimit ;

	file write kmlfile 
		`"<?xml version="1.0" encoding="UTF-8"?>"' _n 
		`"<kml xmlns="http://www.opengis.net/kml/2.2">"' _n
		`"<Document>"' _n _n ;
		
	#delimit cr
	
************
** POINTS **
************

if "`lines'" == "" {

	* Prep option macros
		
		if "`altitude'" == "" {

			tempvar altvar
			gen `altvar' = 0
			local altitude \`altvar'
			
			}
			
		if "`names'" != "" {
		
			local nameopen  "<name>"
			local nameclose "</name>"
			local namen `"_n"'
			
			}
			
		if "`descriptions'" != "" {
		
			local descopen  "<description>"
			local descclose "</description>"
			local descn "_n"
			
			}
			
		if "`icons'" == "" {
		
			tempvar noiconvar
			gen `noiconvar' = "http://maps.google.com/mapfiles/kml/paddle/red-circle.png"
			local icons \`noiconvar'
			
			}
			

	* Sort by folder

		tempname foldername

		if "`folders'" != "" {
			
			ta `folders', generate(`foldername')
			sort `folders'
		
			}
		
		else {
			
			gen `foldername' = 1
			local folders `foldername'
			label var `foldername' "`foldername'==Placemarks"
			
			}
		
	* Write icon styles

		tempvar iconvar
		tempvar stylevar
		tempname iconname

		encode `icons', generate(`iconvar')
		ta `iconvar', generate(`iconname')
		gen `stylevar' = .
			
		foreach icon of varlist `iconname'* {
		
			local varlength  = length("`iconvar'==") + 1
			local varlabel   : variable label `icon'  
			local style = substr("`varlabel'",`varlength',.)
			local namelength = length("`iconname'") + 1
			local stynum = substr("`icon'",`namelength',.)
				replace `stylevar' = `stynum' if `icon'==1

			#delimit ;
				
			file write kmlfile
				`"<Style id="`stynum'">"' _n
				_tab "<IconStyle>" _n
				_tab _tab "<scale>1</scale>" _n
				_tab _tab "<Icon>" _n
				_tab _tab _tab "<href>`style'</href>" _n
				_tab _tab "</Icon>" _n
				_tab "</IconStyle>" _n
				"</Style>" _n _n ;
			
			#delimit cr
		
			} // End style loop
		
	* Write observations in folders
		
		foreach folder of varlist `foldername'* {
		
			save `subsave', replace
			keep if `folder' == 1
			gen n = _n
			
			* Write folder header
			
				local varlength  = length("`folders'==") + 1
				local varlabel   : variable label `folder'  
				local foldertitle = substr("`varlabel'",`varlength',.)
				
				#delimit ;
				
				file write kmlfile `"<Folder id="`foldertitle'">"' _n
					"<name>`foldertitle'</name>" _n
					"<visibility>1</visibility>" _n
					"<open>0</open>" _n _n ;
					
				#delimit cr
			
			* Write observations
			
				count
				forvalues i = 1/`r(N)' {
				
				if "`names'" != "" {
					local name = `names'[`i']
					replace `names' in `i' = subinstr("`name'","&","and",.)
					local name = `names'[`i']
					}
				if "`descriptions'" != "" {
					local desc = `descriptions'[`i']
					replace `descriptions' in `i' = subinstr("`desc'","&","and",.)
					local desc = `descriptions'[`i']
					}
					local style  = `stylevar'[`i']
					local coord2 = `latitude'[`i']
					local coord1 = `longitude'[`i']
					local coord3 = `altitude'[`i']
				
					#delimit ;
				
					file write kmlfile
						"<Placemark>" _n
						"`nameopen'`name'`nameclose'" `namen'
						"`descopen'`desc'`descclose'" `descn'
						"<styleUrl>#`style'</styleUrl>" _n
						"<Point>" _n
						_tab "<coordinates>`coord1',`coord2',`coord3'</coordinates>" _n
						_tab "<altitudeMode>relativeToGround</altitudeMode>" _n _tab "<extrude>1</extrude>" _n
						"</Point>" _n
						"</Placemark>" _n _n ;
					
					#delimit cr

					} // End observation loop
			
			* Write folder footer
			
				file write kmlfile "</Folder>" _n _n
			
			use `subsave', clear
			
			} // End folder loop
		
	} // End - if `lines' == ""
			
***********
** LINES **
***********

if "`lines'" != "" {

	local LineGroupVar : word 1 of `lines'
	local LineIndexVar : word 2 of `lines'
		
	isid `LineGroupVar' `LineIndexVar' , sort
	
	tempvar groupVar
		gen str50 `groupVar' = ""
		cap replace `groupVar' = string(`LineGroupVar')
		cap replace `groupVar' = `LineGroupVar'
		
	levelsof `groupVar' , local(groups)
		foreach group in `groups' {
			count if `groupVar' == "`group'"	
			
			file write kmlfile "<Placemark>" _n "<LineString>" _n "<coordinates>" _n
		
		forvalues i = 1/`r(N)' {
		
			sum `longitude' if `groupVar' == "`group'" & `LineIndexVar' == `i'
				local coord1 = `r(mean)'
			sum `latitude' if `groupVar' == "`group'" & `LineIndexVar' == `i'
				local coord2 = `r(mean)'
			
			file write kmlfile _tab "`coord1',`coord2',0." _n
			
		   }
		   
		   file write kmlfile _n "</coordinates>" _n"</LineString>"  _n "</Placemark>" _n _n	
		   
		}
	
	} // End - if `lines' != ""

*********************			
* Write file footer *
*********************

	file write kmlfile "</Document>" _n
	file write kmlfile "</kml>" _n
	file close kmlfile

} // End quietly
	
restore
	
end
