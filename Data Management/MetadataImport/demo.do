* Demo for import_metadata

	global directory "/Users/bbdaniels/Dropbox/WorldBank/Adofiles/Data/MetadataImport/"
	
	qui do "$directory/import_metadata.ado"
	
* Prep demo
* This is the raw prefilled template used to create "$directory/auto_metadata.xlsx".

	import_metadata ///
		"$directory/auto.xlsx" ///
	using "$directory/prep_demo.xlsx" ///
		, prep replace namerow(1) headrow(2)

* Import Demo 
* Reproduces auto.dta from the delabeled data found in "$directory/auto.xlsx" and the metadata stored in "$directory/auto_metadata.xlsx".

	import_metadata ///
		"$directory/auto.xlsx" ///
	using "$directory/auto_metadata.xlsx" ///
		, namerow(1) headrow(2) oldname(oldname_1)

* Have a lovely day!
