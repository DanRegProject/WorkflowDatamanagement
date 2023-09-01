
options nomprint nosymbolgen nomlogic;
%macro datacheck(inlib,key=v_pnr_encrypted v_cpr_encrypted patient_cpr_encrypted v_recnum patient_cpr_encrypted cpr_encrypted);
    %let inlib=%upcase(&inlib);
proc sql noprint;
    select upcase(memname) into :ds_list separated by ' '
        from dictionary.tables where libname = "&inlib" order by upcase(memname);
%macro loops;
    %local n i this thisv m j first;
	%let first=1;
    %let n = %sysfunc(countw(&ds_list));
	%let m = %sysfunc(countw(&key));
    %do i = 1 %to &n;
		%let year=;
        %let this= %upcase(%sysfunc(scan(&ds_list,&i)));
		%if %index(&this,19)>0 or %index(&this,20)>0 %then %do;
			%let year = %substr(&this,%length(&this)-3);
			%let this = %substr(&this,1,%length(&this)-4);
		%end;
        proc sql noprint;
		select upcase(name) into :vlist separated by ' ' from dictionary.columns where upcase(libname) = "&inlib" and upcase(memname) = "&this.&year";
    	%if &first=1 %then create table tablevars as ;
				%else insert into tablevars;
				select "&this" as table length=30, "&year" as year, upcase(name) as varname, 0 as Nkey  from dictionary.columns 
					where upcase(libname) = "&inlib" and upcase(memname) = "&this.&year";
			%do j = 1 %to &m;
    			%let thisv= %upcase(%sysfunc(scan(&key,&j)));
				%if %sysfunc(indexw(&vlist,&thisv))>0 %then %do;	
       				
		       	update tablevars set Nkey= (select count(*) from (select distinct &thisv from &inlib..&this.&year)) 
					where upcase(table)="&this" and upcase(varname)="&thisv" %if &year ne %then and year="&year";;
 			%end;
        %end;
		%let first=0;
	%end;
    %mend;
%loops;
quit;
ods pdf file="../UdtraeksDokumentation.pdf";
title "Kontrol dokument for &inlib";
proc tabulate data=tablevars;
class table varname year;
var Nkey;
table table, varname, year*Nkey="N unique"*sum=""*f=8.0;
run;
ods pdf close;
%mend;

%datacheck(outdata);
