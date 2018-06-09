*! version 3.42 17Mar2008 M. Lokshin, Z. Sajaia

# delimit ;

program define xml_tab;
version 8;

syntax [anything] [using/] [, STYle(string) EXcelpath(passthru) CAlcpath(passthru)
							  save(string) updateopts NOIsily xml_tab_nopreserve fixed *];

if ~missing(`"`using'"', `"`save'"') Error 198 `"either using or save() option can be specified"';

local options `"`options' save("`using'`save'")"';

capture confirm matrix `anything'; // do we have a list of matrices?
local rc = _rc;

updateopts `style', ver(3.26) `updateopts' `excelpath' `calcpath' isest(`rc');

local 0 ", `options'";
syntax , [replace append newappend WIde LOng sd TStat Pvalue Right Below noBRackets sd2 NOADJust ADJust *];
local options : subinstr local 0 "," "";

if ~missing("`replace'`append'`newappend'") {;
	opts_excl1 styles `"`styles'"' replace;
	opts_excl1 styles `"`styles'"' append;
	opts_excl1 styles `"`styles'"' newappend;
};
if ~missing("`long'`wide'") {;
	opts_excl1 styles `"`styles'"' long;
	opts_excl1 styles `"`styles'"' wide;
};
if ~missing("`below'`right'`sd2'") {;
	opts_excl1 styles `"`styles'"' below;
	opts_excl1 styles `"`styles'"' right;
	opts_excl1 styles `"`styles'"' sd2;
};
if ~missing("`sd'`tstat'`pvalue'") {;
	opts_excl1 styles `"`styles'"' sd;
	opts_excl1 styles `"`styles'"' tstat;
	opts_excl1 styles `"`styles'"' pvalue;
};
if ~missing("`adjust'`noadjust'") {;
	opts_excl1 styles `"`styles'"' adjust;
	opts_excl1 styles `"`styles'"' noadjust;
};

local 0 ", `styles' `options'";
foreach opt in Format Lines FONt LOng WIde STARs NOLabel SHOWeq save SHeet STATs
			   sd TStat Pvalue Right Below NOBRackets sd2 EQuations RBlanks TBlanks CBlanks
			   Title NOADJust ADJust RNames CEq CNames NOTEs SAVEMat Constant CWidth SAVEPath MV {;
	_parse combop 0 : 0, option(`opt') rightmost;
};
//_parse combop 0 : 0, option(CWidth);

quietly `noisily' {;
	display as text "note: options were expended to";
	display as result `"    `0'"';
};
display _n;

tempname M;
    if `rc'==0 {;
		gettoken first rest : anything;
		// syntax for the matrix list
		syntax [, Format(passthru) Lines(string asis) FONt(string asis)
				  LOng WIde STARs(passthru) SHOWeq SAVEPath(name)
				  save(string) SHeet(string) replace append newappend
				  drop(passthru) keep(passthru) EQuations(passthru)
				  RBlanks(string asis) TBlanks(numlist max=1 >0 integer) CBlanks(string) CWidth(string)
				  Title(string) RNames(passthru) CEq(passthru) CNames(passthru) NOTEs(string asis) mv(passthru)
				];

		matrix `M' = `first';
		foreach mat of local rest {;
			Mat_Capp `M' : `M' `mat', miss(.z) cons ts;
		};
		keepdrop `M', `keep' `drop';

		capture confirm matrix `first'_STARS;
		if ~_rc {;
			if rowsof(`first')!=rowsof(`first'_STARS) |
			   colsof(`first')!=colsof(`first'_STARS) {;
				Error 503 `"matrices `first' and `first'_STARS must have same dimensions"';
			};
			matrix  `M'_STARS = `first'_STARS;
			if missing("`long'") {;
				Widemat `M'_STARS;
				matrix  `M'_STARS = r(result);
			};
		};
		getstarchars , `stars';

		if missing("`long'") {;
			Widemat `M';
			matrix `M' = r(result);
		};
    };
	else {;
		syntax  [, Format(passthru) Lines(string asis) FONt(string asis)
				STYle(string) LOng WIde STARs(passthru)
				NOLabel SHOWeq SAVEPath(name)
				save(string) SHeet(string) replace append newappend SAVEMat(string)
				STATS(passthru) sd TStat Pvalue Right Below noBRackets sd2 NOADJust ADJust
				drop(passthru) keep(passthru) EQuations(passthru)
				RBlanks(string asis) TBlanks(numlist max=1 >0 integer)
				CBlanks(string) CWidth(string) mv(passthru)
				Title(string) CEq(passthru) CNames(passthru) NOTEs(string asis) Constant(string) *
		];

		_get_eformopts , eformopts(`options') allowed(__all__);
		local eform	`"`s(str)'"';

		opts_Exclusive "`sd' `tstat' `pvalue'";
		opts_Exclusive "`right' `below'";
		opts_Exclusive "`long' `wide'";
		opts_Exclusive "`adjust' `noadjust'";

		if missing("`right'") local sd2 "sd2";		                // will need to change later

		if ~missing("`tstat'") {;
	    	local cap "t";
		};
		else {;
			if ~missing("`pvalue'") {;
				local cap "p-value";
			};
			else {;
		        local cap "se";  // used to be sd
			};
		};
		Mkemat `anything', `stats' `stars' `long' `sd2' cap(`cap') `keep' `drop'
						   `equations' `noadjust' eform(`eform');
		matrix `M'       = r(coef);
	 	matrix `M'_STARS = r(n_stars);
	}; // else

if ~missing("`savemat'") {;
	local rpl `replace'; // save the -replace- option

	if missing("`long'") matrix roweq `M'=:;
	else {;
		local req : roweq `M';
		local req : subinstr local req "_easytofind3" "", all;
		matrix roweq `M' = `req';
	};
	local rn : rownames `M';
	local rn : subinstr local rn "_easytofind0" "", all;
	matrix rownames `M' = `rn';

	local 0 `savemat';
	syntax name , [replace exit];
	if missing("`replace'") {;
		matrix `namelist'= nullmat(`namelist') \ `M';
		matrix `namelist'_STARS = nullmat(`namelist'_STARS) \  `M'_STARS;
	};
	else {;
		matrix `namelist'= `M';
		matrix `namelist'_STARS = `M'_STARS;
	};
	`exit';
	local replace `rpl'; // restore the option
};

tempfile tmpstyles;

opts_Exclusive "`append' `replace' `newappend'";

// get sheet options
local 0 `sheet';
syntax [anything(name=sheet)] [, COLor(integer -1) NOGridlines];

// check if sheet name is valid
gettoken a b : sheet, parse(":\/?*[]");

if ~missing("`b'") | length("`sheet'")>31 Error 198 `"not a valid Excel sheet name"';

if missing("`sheet'") local sheet "Sheet1";

_getfilename "`save'";
if `"`r(filename)'"'==`"`save'"' {;
	local save "`c(pwd)'/`save'";
};
else {;
	if index(`"`r(filename)'"', ".")==0 {;
		local save `"`save'.xml"';
	};
};
local filename = cond(strpos("`save'", "\") + strpos("`save'", "/") > 0, "`save'", "`c(pwd)'/`save'");

if ~missing("`newappend'`append'") {;
	capture confirm file "`save'";
	if _rc {;
		local replace "replace";
	};
	else {;
		local append "append";
	};
};
if missing("`append'`replace'") {;
	capture confirm file "`save'";
	if ~_rc {;
		Error 602 `"file `save' already exists"';
	};
	else {;
		local replace "replace";
	};
};

if missing("`xml_tab_nopreserve'") preserve;
drop _all;
quietly {;
   	savetodataset `M' `M'_STARS, `format' `sd2' `rnames' `cnames' `ceq' etitle(`"`etitle'"') `mv' `fixed';

	capture confirm matrix `M'_STARS;
	if ~_rc {;
		local starnote "note: ";
		forvalues s = 1/`: list sizeof stars' {;
   	   		local starnote "`starnote', `: word `s' of `starchars'' p&lt;`: word `s' of `stars''";
		};
		local starnote : subinstr local starnote "," "";
		local notes `""`starnote'", `notes'"';
 	};
	sort id;
	if ~missing(`"`rblanks'"') {;
		generate nreq = 0 in 1;
		 replace nreq = nreq[_n-1] + (mod(id,10)==6) if _n>1;
		local add = 0;
		while (~missing(`"`rblanks'"')) {;
			_parse comma 1 rblanks : rblanks;
			gettoken num 1 : 1, qed(qt);
			gettoken txt 1 : 1;
			local 1 = substr(trim("`1'"), 1, 5);
			local num = trim("`num'");
			if "`num'"=="LAST_ROW" local num = _N-3;
			capture confirm integer number `num';
			local isname = _rc;

			if ~(`isname' | `qt') {;
				local s "`s' `num'";
				numlist "`s'", sort;
				local s `r(numlist)';
				local add : list posof "`num'" in s;
				if `add'>0 local add=`add'-1;

				local cond "_n==`=`num'+`add'+3'+nreq";
			};
			else {;
				local cond = cond(missing("`sd2'"), `"d_0=="`num'""', `"d_0=="`num'_easytofind1""');
			};
		 	summarize id if `cond', meanonly;

			local rm = r(min);
			if ~missing(`rm') {;
 			  	replace id = id+0.01 if abs(id-`rm')<0.001;
				local N = _N+1;
				set obs `N';
				replace id = `rm' + 5 in `N';
				local txt `txt';
				replace d_0 = trim(`"`txt'"') in `N';
				foreach var of varlist f_* {;
					replace `var' = cond(missing("`1'"),`var'[int(r(min)/10)+3], "0_`1'") in `N';
				};
				if `isname' local s "`s' `=`rm'/10'";
			};
 			local rblanks : subinstr local rblanks "," "";
			sort id;
		};
	}; // rblanks
	local ncindex =1; // column for the notes

	if ~missing("`cblanks'") {;
		unab vlist : d_*;
		local cbrc : word count `vlist';
		local --cbrc; // d_0 was included

		foreach cb of local cblanks {;
			capture confirm integer number `cb';
			if _rc {;
				if substr("equations", 1, length("`cb'")) == lower("`cb'") {;
					tempvar n;
					generate `n' = _n;
					summarize `n' if id==-10, meanonly;
					local mn = r(min);
	 				forvalues i= 2/`cbrc' {;
						if ~missing(d_`=`i'-1'[`mn']) & d_`=`i'-1'[`mn']!=".x_" & d_`i'[`mn']==".x_" {;
							tempname nn;
							generate d_eq_`nn' = "";
							generate f_eq_`nn' = ""; //f_`1';
							capture move d_eq_`nn' d_`i';
							local hasbceq 1;
						};
					};
				};
				else Error 198 `"invalid cblanks()"';
			};
			else {;
				if `cb'<0 {;
					local cb = -1;
					local ++ncindex;
				};
				capture confirm variable d_`cb';
				if ~_rc | `cb'==-1 {;
					tempname nn;
					generate d_`nn' = "";
					generate f_`nn' = ""; //f_`1';
					local next = `cb' + 1;
					capture move d_`nn' d_`next';
				}; //if
			};
		}; // cb
	}; // cblanks

	if ~missing("`lines'") {;
		local lines : subinstr local lines "," "", all;
		while ~missing(`"`lines'"') {;
			gettoken txt lines : lines;
			gettoken 1   lines : lines;
			confirm integer number `1';
			local txt = trim("`txt'");
			if "`txt'"=="LAST_ROW" local txt = _N-3;
			capture confirm integer number `txt';

			if ~_rc {;
				if `txt'==-3 {;
					local title_line "";
					break, continue;
				};
				local cond "_n==`=`txt'+3'";
			};
			else {;
				local cond = cond(missing("`sd2'"), `"d_0=="`txt'""', `"d_0=="`txt'_easytofind1""');
			};

	  		foreach var of varlist f_* {;
				replace `var'=substr(`var',1,7)+cond(`cond' ,trim("`1'"), "") if substr(`var',8,2)=="" & `var'!="";
			}; // foreach
		}; // while
	}; // lines

	if ~missing("`sd2'") {;
		summarize id if strpos(d_0, "easytofind3"), meanonly;
		local stm = r(mean);
		drop if strmatch(d_0, "*_easytofind0") & id > `stm';
		replace d_0 = substr(d_0, 1, length(d_0)-1) + "0" if id > `stm';
		if missing("`brackets'") {;
			foreach var of varlist f_* {;
				replace `var' = "9_"+substr(`var',3,7) if strmatch(d_0, "*_easytofind1");
			}; // end foreach
		}; // if
	}; // if

	replace l_0 = "" if strmatch(d_0, "*_easytofind1");
	replace d_0 = "" if strmatch(d_0, "*_easytofind1");
	replace l_0 = "" if id<1;
	replace d_0 = "" if id<1;

	replace d_0 = subinstr(d_0, "_easytofind0" ,"", .);

  	drop if strmatch(d_0, "easytofind*");

	if missing("`nolabel'") {;
		replace d_0 = l_0 if (l_0 != "");
	};
	if ~missing(`"`constant'"') {;
		replace d_0 = `"`constant'"' if d_0=="_cons";
	};
	if missing(`"`etitle'"') {; //~`rc' {; // it's a matrix list
 		drop if round(id)==-20;
	};
	if missing("`showeq0'`showeq'") {;
  		drop if round(id)==-10;
	};
 }; //quietly

unab vlist : d_*;
local rc : word count `vlist';
local --rc; // d_0 was included

tempfile tmpfile;
tempname ofile outfile;

local lsheet "`sheet'";

if ~missing("`replace'") {;
		local fno "01";
	 	_styles " " `"`fno' `font'"' `"`starchars'"';
		// encoding='UTF-8' standalone='yes'
        local xmlheader  "<?xml version='1.0'?>
                          <?mso-application progid='Excel.Sheet'?>
                          <Workbook xmlns='urn:schemas-microsoft-com:office:spreadsheet'
                                    xmlns:o='urn:schemas-microsoft-com:office:office'
                                    xmlns:x='urn:schemas-microsoft-com:office:excel'
                                    xmlns:ss='urn:schemas-microsoft-com:office:spreadsheet'
                                    xmlns:html='http://www.w3.org/TR/REC-html40'>";
        file open  `outfile' using "`tmpfile'", write;
        file write `outfile' `"`xmlheader'"' _n;
		gettoken font size : font;
		local font "`font' `size'";
		local font : list retokenize font;
        file write `outfile' `"<FontList>`fno' `font'</FontList>"' _n;
        file write `outfile' `"`styles'"' _n;
  	    file write `outfile' "<DocumentProperties xmlns='urn:schemas-microsoft-com:office:office'>";
		file write `outfile' "<Description>created using xml_tab</Description></DocumentProperties>";
		file write `outfile' `"<Sheetnames>?`lsheet'?</Sheetnames>"' _n;
}; //if
else {; // append
    file open `ofile'   using "`save'", read;
    file open `outfile' using "`tmpfile'", write;
    file read  `ofile'  line;                     // header
    file write `outfile' `"`line'"' _n;
    file read  `ofile'  line;                     // font list
	findfont `"`line'"' `"`fno' `font'"';
    file write `outfile' `"`line'"' _n;
    file read  `ofile'  line;                     // styles
	_styles `"`line'"' `"`fno' `font'"' `"`starchars'"';
    file write `outfile' `"`styles'"' _n;
	file read  `ofile'  line;                     // Description, sheetnames
        if strpos(`"`line'"',"xml_tab")==0 {;
            display as error "cannot append, existing file was created or changed by some other program";
            exit 603;
        };
    local sheetID=0;
	local sheet  "`lsheet'";
	local dfdfdf : subinstr local line "?`lsheet'?" "", all count(local c);
    while `c'>0 {;
        local ++sheetID;
        local lsheet "`sheet' (`sheetID')";
		local dfdfdf : subinstr local line "?`lsheet'?" "", all count(local c);
    }; //while
	local line : subinstr local line "</Sheetnames>" "`lsheet'?</Sheetnames>";
    file write `outfile' `"`line'"' _n;

    while r(eof)==0 {;
        file read  `ofile'  line;
        if `"`line'"'!="</Workbook>" file write `outfile' `"`line'"' _n;
    }; //for
}; //else

file write `outfile' `"<Worksheet ss:Name='`lsheet''>"';
if `color'>=0 | ~missing("`gridlines'") {;
	file write `outfile' "<WorksheetOptions xmlns='urn:schemas-microsoft-com:office:excel'>";
	if `color'>=0 file write `outfile' "<TabColorIndex>`color'</TabColorIndex>";
	if ~missing("`gridlines'") file write `outfile' "<DoNotDisplayGridlines/>";
	file write `outfile' "</WorksheetOptions>";
};
file write `outfile' "<Table x:FullColumns='1' x:FullRows='1'>";

local customwidths = 0;
local customrc = `rc';

if ~missing("`cwidth'") {;
	while ~missing("`cwidth'") {;
		_parse comma curr cwidth : cwidth;
	   	local cwidth : subinstr local cwidth "," "";
		gettoken ind wdt : curr;
		capture confirm integer number `ind';
		if _rc {;
			if substr("equations", 1, length("`ind'")) == lower("`ind'") & ~missing("`hasbceq'", "`wdt'"){;
				local i 1;
	 			foreach var of varlist d_* {;
					if strpos("`var'", "d_eq_") {;
						local cids "`cids' `i'";
						local cwdts "`cwdts' `wdt'";
						//file write `outfile' "<Column ss:Index='`i'' ss:AutoFitWidth='0' ss:Width='`=trim("`wdt'")''/>";
					};
					local ++i;
				};
			};
		};
		else {;
			if `: list ind in inds' | `ind'>256 | `ind'<0 continue;

			if missing("`wdt'") local wdt = 0;
			capture numlist `wdt', range(>=0 <=1000);
			if _rc continue;
			local cids "`cids' `=`ind'+1'";
			local cwdts "`cwdts' `wdt'";
			// file write `outfile' "<Column ss:Index='`=`ind'+1'' ss:AutoFitWidth='0' ss:Width='`=trim("`wdt'")''/>";
			local inds "`inds' `ind'";
			local customwidths = `customwidths' + `wdt';
			local --customrc;
		};
	};
	_qsort_index `cids' \ `cwdts';
	local cwdts `r(slist2)';
	local i 1;
	foreach cid in `r(slist1)' {;
		loca wdt : word `i++' of `cwdts';
		file write `outfile' "<Column ss:Index='`cid'' ss:AutoFitWidth='0' ss:Width='`=trim("`wdt'")''/>";
	};
};

	if ~missing("`tblanks'") local addindex =1+`tblanks';
	else 					 local addindex =1;

	if ~missing("`title'") {;
			local hh= (int(length("`title'") /((`customrc'+1)*8.43+`customwidths'/7.5))+1)*(12.75 + max((`size'-10)*1.5,0));
			local title : subinstr local title "<" "&lt;", all;
			local title : subinstr local title ">" "&gt;", all;
			local ltitle "<Row ss:Index='`addindex++'' ss:Height="`hh'"><Cell ss:StyleID='s`fno'_Title'  ss:MergeAcross='`rc''>
	                      <Data ss:Type='String'>`title'</Data></Cell></Row>";
	        file write `outfile' `"`ltitle'"';
	};

forvalues i = 1/`=_N' {;
	local mrg   = 0;
	foreach var of local vlist {;
   		local datum = `var'[`i'];
		local datum : subinstr local datum "<" "&lt;", all;
		local datum : subinstr local datum ">" "&gt;", all;
		if (`"`datum'"'==".x_") {;
			local ++ mrg;
		   	continue;
		};
		local fvar  = "f" + substr("`var'",2,.);
		local f     = `fvar'[`i'];
		if ~missing("`f'") local f "`fno'_`f'";
		local dtype = cond(upper(substr("`f'", 6, 1))=="N" & ~missing(real(`"`datum'"')), "Number", "String");
		if (`mrg'>0) {;
			local  mrgstr "ss:MergeAcross='`mrg''";
		};
		else {;
			local mrgstr;
		};
		local xmlrow "`xmlrow' <Cell ss:StyleID='s`f'' `mrgstr'><Data ss:Type='`dtype''>`datum'</Data></Cell>";
		local mrg = 0;
	}; // var
	local xmlrow "<Row ss:Index='`addindex++''>`xmlrow'</Row>";
	file write  `outfile' `"`xmlrow'"' _n;
	local  xmlrow "";
}; // i

if ~missing(`"`notes'"') {;
	local notes : subinstr local notes "<" "&lt;", all;
	local notes : subinstr local notes ">" "&gt;", all;
  	local --addindex;
	while (~missing(`"`notes'"')) {;
		_parse comma 1 notes : notes;
		if ~missing(`"`1'"') {;
			gettoken num txt : 1;
			capture confirm integer number `num';
			if _rc {;
				local txt "`num'`txt'";
				local num=0;
			};
	  		local ++num;
 			local addindex = `addindex'+`num';

			file write  `outfile' `"<Row ss:Index='`addindex''><Cell ss:StyleID='s`fno'_Note' ss:Index='`ncindex''><Data ss:Type='String'>`txt'</Data></Cell></Row>"';
		};
		local notes : subinstr local notes "," "";
	};
};

file write  `outfile' "</Table></Worksheet>" _n;
file write  `outfile' "</Workbook>";
file close _all;

capture copy "`tmpfile'" "`save'", replace;
if _rc {;
	    display as error "file cannot be saved at this location";
	    exit 603;
};
display as text "note: results saved to `filename'";

	if "`c(os)'"=="Windows" &  missing("`c(mode)'"){;
		if ~missing(`"`excelpath'"') {;
			display `"{ stata `"winexec "`excelpath'" "`filename'" "': click here}"' _c;
			display as text " to open with Excel";
			if ~missing("`savepath'") global `savepath' "`excelpath'";
		};
		if ~missing(`"`calcpath'"') {;
			display `"{ stata `"winexec "`calcpath'" "`filename'" "': click here}"' _c;
			display as text " to open with Calc";
		};
	};
if missing("`xml_tab_nopreserve'") restore;
end;
/*******************************************************************************/
/*******************************************************************************/

program define Keep, rclass;   //adopted from est_table.ado
	args b spec;

	tempname RES bt tmp;
		foreach sp of local spec {;
		matrix `bt' = `b';
		local row =  rownumb(`bt', "`sp'");
		if `row' == . {;
		 	display as error "coefficient `sp' does not occur in any of the models";
		 	exit 198;
		};
		while `row' != . {;
			if index("`sp'",":") > 0 {;    // complete equation spec.
				matrix `tmp' = `bt'["`sp'",1...];
			};
			else {;
				matrix `tmp' = `bt'[`row',1...];
			};
			 matrix `RES' = nullmat(`RES') \ `tmp';
			if `row'+rowsof(`tmp')>`=rowsof(`bt')' continue, break;
			matrix `bt' = `bt'[`=`row'+rowsof(`tmp')'...,1...];
			local row =  rownumb(`bt', "`sp'");
		};
	};
	capture confirm matrix `RES';
	if _rc {;
		display as error "all variables dropped, nothing to output";
		exit 999;
	};
	return matrix result `RES';
end; // Keep

program define Drop, rclass;   //borrowed from est_table.ado
	args b spec;
	tempname bt;
	matrix `bt' = `b';

	foreach sp of local spec {;
		local isp = rownumb(`bt', "`sp'");
		if `isp' == . {;
			display as error "coefficient `sp' does not occur in any of the models";
			exit 198;
		};
		while `isp' != . {;
			local nb = rowsof(`bt');
			if `isp' == 1 {;
				if (`nb' == 1) {;
					display as error "all variables dropped, nothing to output";
					exit 999;
				};
				matrix `bt' = `bt'[2...,1...];
			};
			else if `isp' == `nb' {;
				matrix `bt' = `bt'[1..`=`nb'-1',1...];
			};
			else {;
				local im1 = `isp'-1;
				local ip1 = `isp'+1;
				matrix `bt' = `bt'[1..`im1',1...] \ `bt'[`ip1'...,1...];
			};
			local isp = rownumb(`bt', "`sp'");
		};
	};
	return matrix result `bt';
end; // Drop


program define keepdrop;
	syntax anything(name=bbc) [, keep(string) drop(string)];

	if ~missing("`keep'") {;
		if (index("`keep'", "*") + index("`keep'", "?") > 0) expandspec keep `bbc' `"`keep'"';

		Keep `bbc' `"`keep'"';
		matrix `bbc' = r(result);
		local reqs : roweq `bbc';
		local reqs : list uniq reqs;
		tempname tmp;

		foreach req of local reqs {;
			Keep `bbc' `"`req':"';
			matrix `tmp' = nullmat(`tmp') \ r(result);
		};
		matrix `bbc' =`tmp';
	};

	if ~missing("`drop'") {;
		if (index("`drop'", "*") + index("`drop'", "?") > 0) expandspec drop `bbc' `"`drop'"';

		Drop `bbc' `"`drop'"';
		matrix `bbc' = r(result);
	};
end; // program keepdrop

program define GetStats;       //borrowed from est_table.ado
	args stats bs;
	local r2_a  "r2_a";
	local r2_p  "r2_p";
	tempname rank st V;
	local escalars : e(scalars);
	local is 1;
	foreach stat of local stats {;
		local sr "`stat'";
		if inlist("`stat'", "aic", "bic", "rank") {;
			if missing("`hasrank'") {;
				capture matrix `V' = syminv(e(V));
				local rc = _rc;
				if `rc' == 0 {;
					scalar `rank' = colsof(`V') - diag0cnt(`V');
				};
				else {;
					if `rc' == 111 {;
						scalar `rank' = 0;
					};
				    else {;
						matrix `V' = syminv(e(V));
					};
				};
				local hasrank 1;
			};
			if "`stat'" == "aic" {;
				scalar `st' = -2*e(ll) + 2*`rank';
			};
			else {;
				if "`stat'" == "bic" {;
					scalar `st' = -2*e(ll) + log(e(N)) * `rank';
				};
			  	else {;
					if "`stat'" == "rank" {;
						scalar `st' = `rank';
					};
				};
			};
		};
		else {;
			if "`stat'" == "r2_a" {;
				if `:list posof "r2_a" in escalars' > 0 {;
					scalar `st' = e(r2_a);
					global R2_ : list global(R2_) | r2_a;
				};
				else {;
					if `:list posof "r2_p" in escalars' > 0 {;
					 	scalar `st' = e(r2_p);
						global R2_ : list global(R2_) | r2_p;
					};
					else {;
						scalar `st' = .91e308;  // .z
					};
				};
			};
			else {;
				if `:list posof "`stat'" in escalars' > 0 {;
					scalar `st' = e(`stat');
				};
			 	else {;
					scalar `st' = .91e308;
				};
			};
		};
		matrix `bs'[`is++',1] = `st';
		matrix rownames `bs' =`stats';
	};
end; // GetStats

program define Mkemat, rclass;
	syntax [anything] [, STATS(string) STARs(passthru) LOng sd2 cap(string) keep(passthru) drop(passthru)
						EQuations(string) NOADJust eform(string)];

	if missing("`anything'") {;
		local anything ".";
	};
	gettoken name rest : anything, bind;
	local nnames = 0;
	while ~missing("`name'") {;
		if strpos("`name'", "(") {;
			local ++nnames;      // just one estimator with nonstandard matrices
		};
		else {;
			quietly estimates dir `name';
			local name "`r(names)'";
			local nnames = `nnames'+`: word count `name'';
		};
		local names "`names' `name'";
		gettoken name rest : rest, bind;
	};

	tempname bbc bc bbs bs;

	if ~missing("`stats'") {;
		local stats : subinstr local stats "," "", all;
		confirm names `stats';

		if (`:list posof "r2_p" in stats' > 0 |
			`:list posof "r2_a" in stats' > 0) {;
			local r2_a  "r2_a";
			local r2_p  "r2_p";
			local stats : list stats | r2_a;
			local stats : list stats - r2_p;
		};
	   	local stats : list uniq stats;
		local nstat : list sizeof stats;
		matrix `bs' = J(`nstat', 1, .z);
		global R2_ ;
	};

	tempname hcurrent esample;
	_estimates hold `hcurrent', restore nullok estsystem;

	local ni 0;
	if missing("`sd2'") {;
		local x ".x_";
	};

	gettoken first rest : names, bind;
	while ~missing("`first'") {;
		local ++ni;
		gettoken name opts : first, parse("(") bind;
		nobreak {;
			if ("`name'" != ".") {;
				quietly estimates dir `name';
			 	est_unhold `name' `esample';
			};
			else {;
				_est unhold `hcurrent';
			};
			if missing("`opts'") {;                             // extract options
			   local eb "b";
			   local eV "V";
			   local noadj;
			   local leform;
			};
			else {;
				gettoken 0 : opts, match(par);
				syntax [anything] [, *];
				_get_eformopts , eformopts(`options') allowed(__all__) soptions;

				local leform	`"`s(str)'"';
				local udiparm	`"`s(options)'"';     // not used yet
				gettoken eb eV : anything;
				if missing("`eb'") {;
				   local eb "b";
				   local eV "V";
				   local noadj;
				};
				else local noadj `noadjust';
			};
			capture confirm matrix e(`eb') e(`eV');
			if _rc {;
				display as error "`name' estimation result does not have e(`eb') and/or e(`=trim("`eV'")')";
				if ("`name'" != ".") est_hold `name' `esample';
				else 		   		_est hold `hcurrent', restore nullok estsystem;
				exit 111;
			};

			tempname B V VV SC tB tV tSTat PVal;
	   		matrix `B'  = e(`eb');
	   		matrix `V'  = e(`eV');

			local coleqs : coleq `B';
			if `"`: list uniq coleqs'"' == "_" & ~missing("`e(depvar)'") matrix coleq `B' = `e(depvar)';

			if ~missing("`noadj'") {;
				capture confirm matrix e(b) e(V);
				if _rc {;
					display as error "`name' estimation result does not have e(b) and/or e(V)";
					display as error "cannot report unadjasted t-statistics";
					if ("`name'" != ".") est_hold `name' `esample';
					else 		   		_est hold `hcurrent', restore nullok estsystem;
					exit 111;
				};
				matrix `tB'=e(b);
				matrix `tV'=e(V);
			};
	   		if ~missing("`stats'") {;
				GetStats "`stats'" `bs';
				matrix          `bbs' = J(rowsof(`bs'), 1,.9042e308),`bs', `bs', J(rowsof(`bs'), 1, .9042e308);  // .x
				matrix rownames `bbs' = `: rownames `bs'';
				matrix roweq    `bbs' = easytofind3;

				if (missing("`long'") & `: word count $R2_'>1) {;
					global R2_ "r2_a/r2_p";
				};
			};
			local eqname = cond("`name'" != ".", "`name'", `"`e(title)'"');
									 local ttle`ni' "`e(_estimates_title)'";
			if missing("`ttle`ni''") local ttle`ni' "`e(estimates_title)'";            // Stata 10.0
			if missing("`ttle`ni''") local ttle`ni' "`eqname'";
		  	if "`name'" != "." est_hold `name' `esample';
			else  	    	  _est hold `hcurrent', restore nullok estsystem;
		};  // nobreak

	   	formateqnames `B' `V' "`name'|`ni'";
	   	if ~missing("`noadj'") formateqnames `tB' `tV' "`name'|`ni'";

		if issymmetric(`V') {;
			forvalues v = 1/`=colsof(`B')' {;
				if (`V'[`v',`v'] > 0) {;
					matrix `VV' = nullmat(`VV'), sqrt(`V'[`v',`v']);
				};
  				else {;
					if (`B'[1,`v'] == 0) {;
						matrix `B'[1,`v'] = .8998e308;  // = .d;
					};
					matrix `VV' = nullmat(`VV'), .91e308; // .z;
				};
			};
		};
		else matrix `VV' =`V';

		if ~missing(`"`eform'"') local leform `"`eform'"';
		if ~missing(`"`leform'"') {;
			local coef : subinstr local leform "." "", all;
			capture Drop `bc' "_cons";
			if ~_rc matrix `bc' = r(result);
		};
		else local coef "coef";

		forvalues i = 1/`=colsof(`B')' {;
			if ~missing("`noadj'") {;
				local t = `tB'[1, `i']/sqrt(`tV'[`i', `i']);
			};
			else {;
				local t = `B'[1, `i']/`VV'[1, `i'];
			};
			
			qui est restore `name';
			
			local p = 2*cond(e(df_r)==.  ,1-norm(abs(`t')), ttail(e(df_r),abs(`t')));
			
			matrix `tSTat' = nullmat(`tSTat'), `t';
			matrix `PVal'  = nullmat(`PVal'), (`p' \ .91e308);

			if ~missing(`"`leform'"') {;
				matrix `B'[1, `i']  = exp(`B'[1, `i']);
				matrix `VV'[1, `i'] = `B'[1, `i']*`VV'[1, `i'];
			};
		};

		if      "`cap'" == "se" matrix `bc' = (`B' \ `VV'            \ `PVal')';
		else if "`cap'" == "t"  matrix `bc' = (`B' \ `tSTat'         \ `PVal')';
		else 					matrix `bc' = (`B' \ `PVal'[1,....]  \ `PVal')';

 	 	matrix coleq    `bc' = `name'|`ni';
		matrix colnames `bc' = "`coef'" `cap' pval mis;

		if ~missing("`equations'") & ~missing("`long'") {;
			AdjustRowEq `bc' `ni' `nnames' "`equations'";
		};
 		matrix `bc' = `bc' \ nullmat(`bbs');
		if (`ni' > 1) {;
			Mat_Capp `bbc' : `bbc' `bc', miss(.91e308) cons ts;
		};
		else {;
	    	matrix `bbc' = `bc';
		};
		local etitle "`etitle' `x' "`ttle`ni''"";
  		gettoken first rest : rest, match(par) bind;
	}; // while

	// move scalars to the end
	tempname tmpsc tmpst;
	capture matrix `tmpsc' = `bbc'["easytofind2:",....]; // model scalars
	if ~_rc {;
		Drop `bbc' "easytofind2:";
		matrix `bbc' = r(result);
	};
	capture matrix `tmpst' = `bbc'["easytofind3:",....];
	if ~_rc {;
		Drop `bbc' "easytofind3:";
		matrix `bbc' = r(result);
	};

	keepdrop `bbc', `keep' `drop';

	matrix `bbc' = `bbc' \ nullmat(`tmpsc');
	matrix `bbc' = `bbc' \ nullmat(`tmpst');

   	if missing("`long'") {;
		local etitle;
		local ceq  : coleq `bbc';
		local cequ : list uniq ceq;
		local req  : roweq `bbc';
		local requ : list uniq req;
		local rsc "easytofind2"; // model scalars
		local rst "easytofind3"; // statistics
		local requ : list requ - rsc;
		local requ : list requ - rst;
		tempname wbc wbbc wbbbc J tsc tst tmp ttst ttsc;
		local nii = 0;
		foreach col of local cequ {;
			capture matrix drop `wbbc';
			matrix `tmp' = `bbc'[....,"`col':"];
			local ni = 0;
			foreach row of local requ {;
				matrix `wbc' = `tmp'["`row':",....];
				matrix roweq `wbc' =:;
				matrix `J' =J(`=rowsof(`wbc')', `=colsof(`wbc')', .91e308);
				if mreldif(`wbc', `J')>0 {;
					matrix coleq `wbc'=`row';
					if `++ni' > 1 {;
						Mat_Capp `wbbc' : `wbbc' `wbc', miss(.91e308) cons ts;
						local etitle "`etitle' `x' .x_";
					};
					else {;
						matrix  `wbbc' = `wbc';
					};
				};
			};
			capture matrix `tsc' = `tmp'["`rsc':",....];
			if ~_rc & `ni'>1 {;
				matrix `tsc' = `tsc', J(rowsof(`tsc'), (`ni'-1)*4, .91e308);
			};
			capture matrix `tst' = `tmp'["`rst':",....];
			if ~_rc & `ni'>1 {;
				local rownames : rowfullnames `tst';
				matrix `tst' = J(rowsof(`tst'), (`ni'-1)*4, .9042e308), `tst';
				matrix  rowname `tst' =`rownames';
			};
			if `ni'>1 {;
				local showeq=1;
			};
  			if `ni' {;
				if `++nii' > 1 {;
					capture Mat_Capp `wbbbc' : `wbbbc' `wbbc', miss(.91e308) cons ts;
					capture matrix `ttsc' = `ttsc', `tsc';
					capture matrix `ttst' = `ttst', `tst';
				};
				else {;
							matrix `wbbbc' = `wbbc';
					capture matrix `ttsc'  = `tsc';
					capture matrix `ttst'  = `tst';
				};
				local etitle "`etitle' `x' "`ttle`nii''"";
			};
		};
		matrix `bbc' =`wbbbc' \ nullmat(`ttsc');
		matrix `bbc' =`bbc'   \ nullmat(`ttst');
	};
   	if ~missing("`sd2'") {;
		tempname tmpA;
		forvalues i = 1/`= rowsof(`bbc')' {;
			tempname tmpB tmpC;
			forvalues j = 1/`= colsof(`bbc') / 2' {;
				local c1 = `j' * 2 - 1;
				local c2 = `j' * 2;
				matrix `tmpC' = `bbc'[`i',`c1'..`c2']';
				local cnames : colfullnames `tmpC';
				matrix colnames `tmpC' = `: word 1 of `: roweq `tmpC''';
				matrix roweq    `tmpC' = :;
				matrix `tmpB' = nullmat(`tmpB'), `tmpC';
			}; // j
			matrix rownames `tmpB' = `cnames'_easytofind0 `cnames'_easytofind1;
			matrix  `tmpA' = nullmat(`tmpA') \ `tmpB';
		}; // i
	 	matrix coleq    `tmpA' =`: colnames `tmpB'';
	 	matrix colnames `tmpA' =coef/`cap';
		matrix  `bbc' = `tmpA';
	};
	if `: word count $R2_'>1 {;
		global R2_ "r2_a/r2_p";
	};
	local rnames : rownames `bbc';
	local rnames : subinstr local rnames "r2_a" "$R2_";
	matrix rownames `bbc' = `rnames';

	// get variable labels if available
	local rnames;
	tempname tmp;
	forvalues i = 1/`= rowsof(`bbc')' {;
		matrix `tmp' =`bbc'[`i',....];
		local rn : rownames `tmp';
		local rn : subinstr local rn "_easytofind0" "";
		local rn : subinstr local rn "_easytofind1" "";
		capture local lbl : variable label `rn';
		if ("`lbl'"!="" & _rc==0) {;
			local rn "`lbl'";
		};
		local rnames "`rnames' "`rn'"";
	};

	tempname n_stars D;

	getstarchars , `stars';

	local rr  = rowsof(`bbc');
	local rc  = colsof(`bbc') / 2; // extra cols of tstats;

	matrix `n_stars' = J(`rr', `rc', 0);
	matrix `D'       = J(`rr', `rc', .);

	if missing("`sd2'") {;
		local base  = 2;
		local sdc   = 1;
		local sdr   = 0;
	};
	else {;
		local base  = 1;
		local sdc   = 0;
		local sdr   = 1;
	};
	local cnames_old : colfullnames `bbc';
	local cnames;
	forvalues j = 1/`rc' {;
		local jC = int((`j'-0.1)/(1+`sdc'))*(1+`sdc')+`j';
		local cnames `"`cnames' `: word `jC' of `cnames_old''"';
 		forvalues i = 1/`rr'{;
			matrix `D'[`i',`j']=`bbc'[`i',`jC'];
			if mod(`j',`sdc'+1)==`sdc' & mod(`i', `sdr'+1)==`sdr' {;
				local p = min(`bbc'[`i',`jC'+`base'], .);

				forvalues s =1/`: list sizeof stars' {;
					if `p'<=`: word `s' of `stars'' {;
						matrix `n_stars'[`i', `j'] = `s';
						continue, break;
					};
				};
			};
		};
	};

	matrix rownames `D' = `: rownames `bbc'';
	matrix roweq    `D' = `: roweq `bbc'';
	matrix colnames `D' = `cnames';

	return matrix coef    = `D';
	return matrix n_stars = `n_stars';

	c_local rnames `"rnames(`rnames')"';
	c_local etitle `"`etitle'"';
	c_local showeq0 `showeq';
	c_local stars `"`stars'"';
	c_local starchars `"`starchars'"';
end; // Mkemat

program define formateqnames;
	args B V;

	local eq  : coleq `B';
  	local eq : subinstr local eq "." "dot", all;    // mlogit problem
	matrix coleq `B' =`eq';

	local eq     : subinstr local eq "_" "", all word;
	if missing(trim("`eq'")) {;
		matrix coleq `B' = `: word 1 of `e(depvar)'';
	};
	else {;
		local cnames : colfullnames `B';
		local ueq    : list uniq eq;
		foreach eqname of local ueq {;
			local eq : subinstr local eq "`eqname'" "`eqname'", all count(local c);
			if (`c' == 1) {;
				local cnames : subinstr local cnames "`eqname':_cons" "easytofind2:`eqname'", all;
			};
		};
		matrix colnames `B' = `cnames';
		matrix colnames `V' = `cnames';
		//matrix rownames `V' = `cnames';
	};
end; // program formateqnames

program define AdjustRowEq;    // borrowed from est_table.ado
	args b ni nmodel eqspec;

	local eqspec : subinstr local eqspec ":" " ", all;
	local eqspec : subinstr local eqspec "#" "" , all;

	local beqn : roweq `b';
	local beq  : list uniq beqn;

	local iterm 0;
	gettoken term eqspec : eqspec , parse(",");
	while ~missing("`term'") {;
		local ++iterm;

		gettoken eqname oprest: term, parse("=");
		gettoken op rest : oprest, parse("=");
		if trim(`"`op'"') == "=" {;
			confirm name `eqname';
			if ~missing(`"`:list beq & eqname'"') {;
				display as error "option equations() invalid";
				display as error "specified equation name already occurs in model `ni'";
				exit 198;
			};
			local term `rest';
		};
		else {;
			local eqname #`iterm';
		};

		local nword : list sizeof term;
		if ~inlist(`nword', 1, `nmodel') {;
			display as error "option equations() invalid";
			display as error "a term should consist of either 1 or `nmodel' equation numbers";
			exit 198;
		};
		if `nword' > 1 {;
			local term  : word `ni' of `term';
		};

		if trim("`term'") != "." {;
			capture confirm integer number `term';
			if _rc {;
				display as error "option equations() invalid";
				display as error "`term' was found, while an integer equation number was expected";
				exit 198;
			};
			if ~inrange(`term',1,`:list sizeof beq') {;
				display as error "option equations() invalid";
				display as error "equation number `term' for model `ni' out of range";
				exit 198;
			};
			if `:list posof "`eqname'" in beq' != 0 {;
				display as error "impossible to name equation `eqname'";
				display as error "you should provide (another) equation name";
				exit 198;
			};
			local beqn : subinstr local beqn "`:word `term'  of `beq''" "`eqname'" , word all;
		};

		if missing("`eqspec'") {;
			continue, break;
		};
		gettoken term eqspec: eqspec , parse(",");
		assert "`term'" == ",";
		gettoken term eqspec: eqspec , parse(",");
	};
	matrix roweq `b' = `beqn';
end;

program define savetodataset;
	syntax anything [, format(string asis) sd2 RNames(string asis)
					   CEq(string asis) CNames(string asis) etitle(string) fixed mv(passthru)];

	local cfrmt = cond(missing("`fixed'"), "%24.0g", "%24.8f");

	tokenize `anything';
	local D       `1';
	local rr  = rowsof(`D');
	local rc  = colsof(`D');
	capture confirm matrix `2';
	if _rc {;
		tempname D_STARS;
		matrix `D_STARS' = J(`rr', `rc', 0);
	};
	else local D_STARS `2';

	local obs = `rr'+3;

	set obs `obs';
	tempname tmp;

	readformats `rc' `"`format'"';

	generate int id = (_n - 3)*10;
	generate str d_0 = "";
	generate str l_0 = "";
	if ~missing("`sd2'") local eas "_easytofind1";
	replace d_0 = "EST_NAMES`eas'"  in 1;
	replace d_0 = "SCOL_NAMES`eas'" in 2;
	replace d_0 = "COL_NAMES`eas'"  in 3;
	local rownames : rownames `D';
	local roweqs   : roweq    `D';
	forvalues i = 1/`rr' {;
		matrix `tmp' = `D'[`i',....];
		local roweq1 : roweq `tmp';
		local aa     : word `i' of `rnames';
		if "`roweq1'" == "easytofind2" {;
			replace d_0 = "/`: rownames `tmp''" in `=`i'+3';
			replace l_0 = `"/`aa'"' in `=`i'+3';
		};
		else {;
			replace d_0 = "`: rownames `tmp''" in `=`i'+3';
			replace l_0 = `"`aa'"' in `=`i'+3';
		};
		if "`roweq1'"!="`roweq'" & "`roweq1'"!="_" {;
			set obs `++obs';
			local roweq `roweq1';
			replace d_0 = "`roweq'"  in `obs';
			replace id  = `i'*10 - 4 in `obs';
 		};
	};
   	forvalues j = 1/`rc' {;
		matrix `tmp' = `D'[....,`j'];
		generate str d_`j' = "`: word `j' of `etitle''" in 1;
		local coleq : word `j' of `ceq';
		if missing(`"`coleq'"') local coleq : coleq `tmp';
		 replace     d_`j' = `"`coleq'"' in 2;
		 if `j'>1 replace     d_`=`j'-1' = cond((d_`j' == d_`=`j'-1') & (d_`=`j'-1'[1]==".x_" | d_`=`j'-1'[1]==""), ".x_", `"`coleq1'"') in 2;
	    local coleq1 `"`coleq'"';
		local cn : word `j' of `cnames';
		if missing("`cn'") local cn : colnames `tmp';
		 replace d_`j' = "`cn'" in 3;
		forvalues i = 1/`rr'{;
  			replace d_`j' = string(`D'[`i',`j'],"`cfrmt'") in `=`i'+3';
			local nstars = cond(`D_STARS'[`i', `j']<10, `D_STARS'[`i', `j'], 0);
			replace f_`j' = "`nstars'_" + upper(substr(trim(f_`j'),3,5)) in `=`i'+3';
		}; // forvalues i

		summarize id if strpos(d_0, "easytofind3"), meanonly;
		local stm = r(mean);

		replace f_`j' = "0_N2200" if inlist(l_0,"N","df_r", "df_m") & id > `stm';
    	replace f_`j' = "0_N2203" if inlist(l_0,"r2","r2_a", "r2_p", "r2_a/r2_p") & id > `stm';
    	replace f_`j' = "0_N2202" if l_0=="ll" & id > `stm';
		replace f_`j' = "0_N2200" if f_`j'=="" & id > `stm';

		replace d_`j' ="(dropped)"  if(d_`j'==".d_");
		replace d_`j' =""           if(d_`j'==".z_");
	}; // forvalues j

	replace l_0 = "Number of observations" if l_0=="N"         & id > `stm';
	replace l_0 = "Log-Likelihood"     	   if l_0=="ll"        & id > `stm';
	replace l_0 = "R2"        		 	   if l_0=="r2"        & id > `stm';
	replace l_0 = "Adjusted R2"            if l_0=="r2_a"      & id > `stm';
	replace l_0 = "Pseudo R2"          	   if l_0=="r2_p"      & id > `stm';
	replace l_0 = "Adjusted/Pseudo R2" 	   if l_0=="r2_a/r2_p" & id > `stm';

	replace l_0 = d_0       if l_0=="";
	replace f_0 = "0_S2110" if f_0=="";

	MVEncode, `mv';
end;

program define readformats;
args ni format;
	local format : subinstr local format "," "", all;

	gettoken first rest : format, bind;
	if missing("`rest'") {;
		local rest "`format'";
	};
	else {;
		local format "`rest'";
	};
	local first : subinstr local first "(" "", all;
	local first : subinstr local first ")" "", all;

	tokenize "`first'";
	generate str f_0 = "0_`=substr("`1'", 1, 5)'";
	if ~missing("`2'") {;
		local j=2;
		local i=4;
		while `i'<=_N {;
			if missing("``j''") local j=2;
			else {;
				replace f_0="0_`=substr("``j''", 1, 5)'" in `i';
				local ++j;
				local ++i;
			};
		};
	};

	local i=1;
	while `i'<=`ni' {;
		gettoken first rest : rest, match(p) bind;
		local first : subinstr local first "(" "", all;
		local first : subinstr local first ")" "", all;
		tokenize "`first'";
		generate str f_`i' = "0_`=substr("`1'", 1, 5)'";
		if ~missing("`2'") {;
			local j=2;
			local k=4;
			while `k'<=_N {;
				if missing("``j''") local j=2;
				else {;
					replace f_`i'="0_`=substr("``j''", 1, 5)'" in `k';
					local ++j;
					local ++k;
				};
			};
		};
		local ++i;
		if missing("`rest'") {;
			local rest "`format'";
		};
	};
end;

program define _styles;
	args styles font starchars;

	gettoken fno font  : font;
	gettoken font size : font;
	local font = proper("`font'");
	if ~missing("`size'") {;
		capture confirm number `size';
		if _rc {;
			display as error "'`size'' found where font size expected";
			exit 7;
		};
		local size "ss:Size='`=trim("`size'")''";
	};

	local flist;
	foreach var of varlist f_* {;
		forvalues i=1/`=_N' {;
	        local f=`var'[`i'];
	        local flist "`flist' `f'";
		};
	};
	local flist : list uniq flist;

	local styles : subinstr local styles "<Styles><Style ss:ID='s' />" "";
	local styles : subinstr local styles "</Styles>" "";

	local styles : subinstr local styles "'s`fno'_Title'" "'s`fno'_Title'", all count(local cc);

	if `cc'==0 {;
		local styles "`styles'<Style ss:ID='s`fno'_Title'>";
		local styles "`styles'<Alignment ss:Vertical='Center' ss:Horizontal='Center' ss:WrapText='1'/>";
	    local styles "`styles'<Font ss:Bold='1' ss:FontName='`font'' `size' />";
	    local styles "`styles'</Style>";
	    local styles "`styles'<Style ss:ID='s`fno'_Note'>";
	    local styles "`styles'<Alignment ss:Vertical='Center' ss:Horizontal='Left' />";
	    local styles "`styles'<Font ss:FontName='`font'' `size' />";
	    local styles "`styles'</Style>";
	}; //if

	local 0 = 0;
	local 1 = 1;
	local 2 = 2;
	local 3 = 3;
	local 4 = 4;
	foreach f in `flist' {;
		local styles : subinstr local styles "'s`fno'_`f''" "'s`fno'_`f''", all count(local cc);
	    if `cc' continue;

		local lwrap = cond(upper(substr(`"`f'"', 3, 1))=="N", "", "ss:WrapText='1'");

	    local vert=upper(substr(`"`f'"', 4, 1));
		local T = 1;
		local C = 2;
		local B = 3;
	        if "``vert''"=="1" local V "ss:Vertical='Top'";
	        else if "``vert''"=="2" local V "ss:Vertical='Center'";
	             else if "``vert''"=="3" local V "ss:Vertical='Bottom'";
	                  else local V "";
	    local hori=upper(substr(`"`f'"', 5, 1));
		local L = 1;
		local R = 3;
	        if "``hori''"=="1" local H "ss:Horizontal='Left'";
	        else if "``hori''"=="2" local H "ss:Horizontal='Center'";
	             else if "``hori''"=="3" local H "ss:Horizontal='Right'";
	                    else local H "";
	    local face=upper(substr(`"`f'"', 6, 1));
		local R = 0;
		local B = 1;
		local I = 2;
		local O = 3;
		local U = 4;
	        if "``face''"=="1" 		local B "ss:Bold='1'";
	        else if "``face''"=="2" local B "ss:Italic='1'";
	        else if "``face''"=="3" local B "ss:Bold='1' ss:Italic='1'";
	        else if "``face''"=="4" local B "ss:Underline='Single'";
	        else 					local B "";

	    local digt=substr(`"`f'"', 7, 1);
		if      ("`digt'" == "8") local digt ="0.00000000";
		else if ("`digt'" == "9") local digt ="0.000000000";
		else		  		  	  local digt =string(0,"%9.`digt'f");

	    local bline=substr(`"`f'"', 8, 2);
	    if "`bline'"=="1" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Continuous' />";
		};
	    else if "`bline'"=="2" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Continuous' ss:Weight='1' />";
		};
	    else if "`bline'"=="3" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Continuous' ss:Weight='2' /> ";
		};
	    else if "`bline'"=="4" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Continuous' ss:Weight='3' /> ";
		};
	    else if "`bline'"=="5" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Dot' ss:Weight='1' /> ";
		};
	    else if "`bline'"=="6" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='DashDotDot' ss:Weight='1' /> ";
		};
	    else if "`bline'"=="7" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='DashDotDot' ss:Weight='2' /> ";
		};
	    else if "`bline'"=="8" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='DashDot' ss:Weight='1' /> ";
		};
		else if "`bline'"=="9" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='DashDot' ss:Weight='2' /> ";
		};
	    else if "`bline'"=="10" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Dash' ss:Weight='1' /> ";
		};
	    else if "`bline'"=="11" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Dash' ss:Weight='2' /> ";
		};
	    else if "`bline'"=="12" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='SlantDashDot' ss:Weight='2' /> ";
		};
	    else if "`bline'"=="13" {;
			local BR "<Border ss:Position='Bottom' ss:LineStyle='Double' ss:Weight='3' /> ";
		};
		else local BR;

		local nstars=substr(`"`f'"', 1, 1);
		local theblanks = "";
		local nblanks = `nstars' - 1;
		if `nstars' == 0 local nblanks = 3 ;
			forvalues i = 1/`nblanks' {;
				local theblanks "`theblanks'_*";
				};
		if (`nstars' == 9) local fmt "(#,##`digt')_*_*;(-#,##`digt')";
		else {;
			if `nstars'>0 {;
				local char : word `nstars' of `starchars';
			};
			else local char;
		    local fmt "#,##`digt'&quot;`char'&quot;`theblanks';&quot;-&quot;#,##`digt'&quot;`char'&quot;`theblanks'";
		};
	    local styles "`styles'<Style ss:ID='s`fno'_`f''>";
	    local styles "`styles'<Alignment `V' `H' `lwrap'/>";
	    local styles "`styles'<Font `B' ss:FontName='`font'' `size' />";
	    local styles "`styles'<Borders>`BR'</Borders>";
	    local styles `"`styles'<NumberFormat ss:Format='`fmt'' /></Style>"';
	};
	c_local styles "<Styles><Style ss:ID='s' />`styles'</Styles>";
end;

program define updateopts;
	syntax [anything(name=stname)], [VER(string) updateopts EXcelpath(string) CAlcpath(string)] isest(integer);

	local stname =cond(missing("`stname'"), cond(`isest', "DEFAULT", "M"), upper("`stname'"));

	tempname file_w file_r;
	tempfile tmpf;

 	// check if we have the options file
	quietly findfile xml_tab.ado;
	local fname "`r(fn)'";
	local fname : subinstr local fname "xml_tab.ado" "xml_tab_options.txt";

	capture confirm file "`fname'";
	local writenew = _rc | ~missing("`updateopts'");
	if `writenew'==0 {;
		file open `file_w' using "`tmpf'", write;
		local writenew = 1; // if version not found

		file open `file_r' using "`fname'", read;
		local eof=0;
		while `eof'==0 {;
			file read  `file_r' line;
			local eof=r(eof);
			local save 1;
			if strpos(`"`line'"', "VERSION") {;
				if trim(`"`line'"')!="VERSION=`ver'" {;
					continue, break;
				};
				else local writenew = 0;
			};
			if missing("`c(mode)'`c(console)'") {;               // do we need a clickable link?
				if strpos(`"`line'"', "EXCELPATH") {;
					local tt `: subinstr local line "EXCELPATH=" ""';
					capture confirm file "`tt'";
					_getfilename "`tt'";
					if (_rc==0 & upper("`r(filename)'")=="EXCEL.EXE") | missing("`tt'") {;
						local excelpath "`tt'";
						local excelfound 1;
					};
					else local save 0;
				};
				if strpos(`"`line'"', "CALCPATH") {;
					local tt `: subinstr local line "CALCPATH=" ""';
					capture confirm file "`tt'";
					_getfilename "`tt'";
					if (_rc==0 & upper("`r(filename)'")=="SCALC.EXE") | missing("`tt'") {;
						local calcpath "`tt'";

						local calcfound 1;
					};
					else local save 0;
				};
			};
			else {;
				local excelfound 1;
				local  calcfound 1;
			};
			if strpos("`line'", "`stname'=") {;
				local style `: subinstr local line "`stname'=" ""';
			};
			if ~missing("`line'")  & `save' file write `file_w' "`line'" _n;

		};
		if `writenew' {;
			file close `file_w';
			erase `tmpf';
		};
	};
	if `writenew'>0 {; //there is no options file
		local DEFAULT "format(S2100 (S2210 N2303)) cw(0 140) right wide stars(0.01 0.05 0.1)";
		local S1      "format(S2100 (S2210 N2303) (S2210 N2123)) cw(0 140) right wide stars(0.01 0.05 0.1) lines(COL_NAMES 1 _cons 1 LAST_ROW 13) stats(N r2)";
		local M       "format(N2103) cw(0 140)";
		file open  `file_w' using "`tmpf'", write;
   		file write `file_w' "  VERSION=`ver'" _n;
   		file write `file_w' "  DEFAULT=`DEFAULT'" _n;
		file write `file_w' "       S1=`S1'" _n;
		file write `file_w' "        M=`M'" _n;
		local style "``stname''";
	    local upd = 1;
	};
	if missing("`excelfound'") {;
		capture confirm file "`excelpath'";
		if _rc {;
			local excelpath;
			capture local dirs : dir "C:/Program Files/Microsoft Office" dirs "office*";
			foreach d of local dirs {;
				capture confirm file "C:/Program Files/Microsoft Office/`d'/excel.exe";
				if ~_rc {;
					local excelpath "C:/Program Files/Microsoft Office/`d'/excel.exe";
					continue, break;
				};
			}; // d
		};
		file write `file_w' "EXCELPATH=`excelpath'" _n;
		local upd = 1;
	};

	if missing("`calcfound'") {;
    	capture confirm file "`calcpath'";
    	if (_rc>0) {;
    	    local calcpath ;
    	    capture local dirs : dir "C:/Program Files" dirs "openoffice*";
			foreach d of local dirs {;
    	    	capture confirm file "C:/Program Files/`d'/program/scalc.exe";
				if ~_rc {;
    	            local calcpath "C:/Program Files/`d'/program/scalc.exe";
					continue, break;
				};
			}; // d
		};
		file write `file_w' " CALCPATH=`calcpath'" _n;
		local upd = 1;
	};
	file close _all;
	if ~missing("`upd'") {;
		 capture copy `tmpf' `"`fname'"', replace;
		if _rc {;
			if ~missing(`"`updateopts'`excelpath'`calcpath'"') {;
				display as error "could not save options";
				display as error "file cannot be saved at this location";
				exit 603;
			};
			else exit;
		};
	};
	// write defaults
	local 0 ", `style'";
	syntax , [FONt(passthru) LOng WIde STARs(passthru)
			  save(passthru) SHeet(passthru) sd TStat PValue Right Below sd2 *];
	if missing("`font'") 			  local font "font(Arial 10)";
	if missing("`long'`wide'") 		  local wide "wide";
	if missing("`save'") 			  local save "save(stata_out.xml)";
	if missing("`sheet'") 			  local sheet "sheet(sheet1)";
	if missing("`right'`below'`sd2'") local right "right";
	if missing("`sd'`tstat'`pvalue'") local sd "sd";
	if missing("`stars'") 			  local stars "stars(*** 0.01 ** 0.05 * 0.1)";

	if `isest' {;
		local style "`save' `sheet' `long' `wide' `sd' `tstat' `pvalue' `stars' `right' `below' `sd2' `font' `options'";
	};
	else {;
		local style "`save' `sheet' `font' `stars' `options'";
	};
	local style : list retokenize style;

	c_local excelpath `"`excelpath'"';
	c_local calcpath  `"`calcpath'"';
	c_local styles `"`style'"';
end; // program updateopts

program define opts_Exclusive; // Rewriting for the Stata 8.0
args opts;
	local n : word count `opts';
	if `n' < 2 {;
		exit;
	};
	display in smcl as error "{p}";
	display in smcl as error "only one of";
	if `n' == 2 {;
		display in smcl as error `"`: word 1 of `opts'' "'
			`"or `: word 2 of `opts''"';
	};
	else {;
		forvalues i=1/`=`n'-1' {;
			display in smcl as error `"`:word `i' of `opts'',"';
		};
		display in smcl as error `"or `:word `n' of `opts''"';
	};
	display in smcl as error "is allowed{p_end}";
	exit 198;
end; // program opts_Exclusive

program define expandspec;
	args result b spec;

	foreach sp of local  spec {;
		local full = cond(index("`sp'", ":") > 0, "full","");
		local rnames : row`full'names `b';
		if index("`sp'", "*") + index("`sp'", "?")> 0 {;
			foreach name of local rnames {;
				if strmatch("`name'", "`sp'") local spn "`spn' `name'";
			};
		};
		else local spn "`spn' `sp'";
	};
	local spn : list uniq spn;
	c_local `result' "`spn'";
end; // program expandspec

program define opts_excl1;
	args nest st opt;
		local 0 ", `st'";
		syntax , [replace append WIde LOng sd TStat Pvalue Right Below sd2 *];
		local `opt';
		local st "`replace' `append' `wide' `long' `sd' `tstat' `pvalue' `right' `below' `sd2' `options'";
		local st : list retokenize st;
	c_local `nest' `st';
end; // program opts_excl1

program define findfont;
	args line font;
	local xmlstr `"`line'"';
	//xmlstr will be of a form : <FontList>01 "Arial" 10?02 "Times New Roman" 10?03 "Arial" 12?...</FontList>
	local xmlstr : subinstr local xmlstr "<FontList>" "";
	local xmlstr : subinstr local xmlstr "</FontList>" "";

	while ~missing("`xmlstr'") {;
		gettoken item xmlstr : xmlstr, parse("?");
		gettoken no xfont : item;

		gettoken font size : font;
		local font "`font' `size'";
		local font : list retokenize font;

		if (upper(trim(`"`xfont'"')) == upper(trim(`"`font'"'))) {;
			local found 1;
			continue, break;
		};
		local xmlstr : subinstr local xmlstr "?" "";
	};
	if missing("`found'") {;
		local ++no;
		if (`no'< 10) local no "0`no'";
		local line : subinstr local line "</FontList>" "";
		local line `"`line'?`no' `font'</FontList>"';
	};
	c_local fno `no';
	c_local line `"`line'"';
end; // program findfont

program define getstarchars;
	syntax [, STARs(string asis)];

	local stars : subinstr local stars "," "", all;
	local n : word count `stars';
	if `n'<=3 {; 					// Simple syntax
		local strchrs "*** ** *";
	};
	else {;
		local strchrs `""`: word 1 of `stars''" "`: word 3 of `stars''""';
		local strs    `"`: word 2 of `stars'' `: word 4 of `stars''"';
		if ~missing(`"`: word 6 of `stars''"') {;
			local strchrs `"`strchrs' "`: word 5 of `stars''""';
			local strs    `"`strs' `: word 6 of `stars''"';
		};
		local stars `strs';
	};

   	capture numlist "`stars'", range(>=0 <=1);
	if _rc {;
		display as error "stars(): `stars' - invalid numlist";
		exit _rc;
	};
	_qsort_index `stars';
	c_local stars "`r(slist1)'";

	foreach i in `r(order)' {;
		local starchars `"`starchars' "`: word `i' of `strchrs''""';
	};
	c_local starchars `"`starchars'"';
end; // program gettstarchars

program define Mat_Capp;
	if _caller() >= 9.0 {;
		mat_capp `0';
	};
	else {;
		syntax anything [, miss(str) cons ts];

		local b12   : word 1 of `anything';
		local colon : word 2 of `anything';
		local b1    : word 3 of `anything';
		local b2    : word 4 of `anything';

	    tempname TMP;
		forvalues j = 1/2 {;
			forvalues i = 1/`=colsof(`b`j'')' {;
				matrix `TMP' = `b`j''[....,`i'];
				local cnames `"`cnames' "`: colnames `TMP''""';
				local ceqs `"`ceqs' "`: coleq `TMP''""';
			};
			matrix colnames `b`j'' =:a;
		};
		mat_capp `0';
		matrix colnames `b12'=`cnames';
		matrix coleq    `b12'=`ceqs';
	};
end; // program Mat_Capp

program define Widemat, rclass;
	args bbc;

	local ceq  : coleq `bbc', quoted;
	local cequ : list uniq ceq;
	local req  : roweq `bbc', quoted;
	local requ : list uniq req;

	if `"`requ'"' == `""_""' {;
		return matrix result = `bbc';
		exit;
	};

	tempname wbc wbbc wbbbc J tmp;

	local nii = 0;

	foreach col of local cequ {;
		capture matrix drop `wbbc';
		matrix `tmp' = `bbc'[....,"`col':"];
		local ni = 0;
		foreach row of local requ {;
			matrix `wbc' = `tmp'["`row':",....];
			matrix roweq `wbc' =:;
			matrix `J' =J(`=rowsof(`wbc')', `=colsof(`wbc')', .z);
			if mreldif(`wbc', `J')>0 {;
				matrix coleq `wbc'="`row'";
				forvalues xi = 1/`=colsof(`wbc')-1' {;
					local etitle "`etitle' .x";
				}; // end forvalues

				if `++ni' > 1 {;
					mat_capp `wbbc' : `wbbc' `wbc', miss(.z) cons ts;
					local etitle "`etitle' .x";
				};
				else {;
					matrix  `wbbc' = `wbc';
				};
			};
		};
		local etitle `"`etitle' "`col'""';
  		if `ni' {;
			if `++nii' > 1 {;
				capture mat_capp `wbbbc' : `wbbbc' `wbbc', miss(.z) cons ts;
			};
			else {;
				matrix `wbbbc' = `wbbc';
			};
		};
	};
	return matrix result = `wbbbc';
	if `: word count `cequ''>1  c_local etitle `"`etitle'"';
	c_local showeq0 "showeq";
end; // program Widemat

program define MVEncode;
	syntax, [mv(string asis)];

	local spec `"`mv'"';
	local n 0;
	if `"`spec'"' == `""""' {;
		local iselse 1;
	};
	else {;
		gettoken tok spec : spec, parse(" =\");
		if missing(`"`spec'"') & ~missing(`"`tok'"') {;
			local else_rule `"`tok'"';
			local iselse 1;
		};
		else {;
			while `"`tok'"' != "" & `"`tok'"' != "else" {;
				local ++n;
				capture assert `"`tok'"' == "." | ( (length(`"`tok'"')==2 & inrange(`"`tok'"',".a",".z")) );
				if _rc Error 198 `"`tok' is not a missing value code"';

				local lhs`n' `"`tok'"';

				gettoken tok spec : spec, parse(" =\");
				if `"`tok'"' != "=" Error 198 "= expected";

				gettoken tok spec : spec, parse(" =\");
				local rhs`n' `"`tok'"';

				gettoken tok spec : spec, parse(" =\");
				if !inlist(`"`tok'"', "", "\") Error 198 `"`tok' found, where \ expected"';

				gettoken tok spec : spec, parse(" =\");
			};

			if `"`tok'"' == "else" {;
				gettoken tok spec : spec, parse(" =\");
				if `"`tok'"' != "=" Error 198 "= expected";

				gettoken tok spec : spec, parse(" =\");
				local else_rule `"`tok'"';
				local iselse 1;
			};
		};
	};

	foreach var of varlist d_* {;
		forvalues rule = 1/`n' {;
			replace `var' = `"`rhs`rule''"' if `var'==`"`lhs`rule''"';
		};
       	if "`iselse'" != "" replace `var' = `"`else_rule'"' if `var' == "." | (length(`var')==2 & inrange(`var',".a",".z"));
    };

end;

program define Error;
	args nr txt;

	display as error `"`txt'"';
	exit `nr';
end;
