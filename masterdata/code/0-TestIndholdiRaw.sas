%macro scanlib(in=rawdata,withyear=TRUE);
		%if &withyear eq TRUE %then options orientation=landscape;;
title "Report in library : &in";
	proc sql noprint;
    create table tables as select distinct memname as table, nobs
            from dictionary.tables
            where libname=upcase("&in") and upcase(memtype)="DATA";

    proc sql noprint;
        create table variables as select distinct memname as table, name, type
            from dictionary.columns
            where libname=upcase("&in") 
            order by memname, name;

	data tables;
		length tablegrp $50;
	    set tables;
		%if &withyear eq TRUE %then %do;
			pos=index(table,"20");
			if pos=0 then pos=index(table,"19");
			len=length(table);
			if pos=0 then pos=len+1;
			tablegrp=substr(table,1,pos-1);
			if pos<len+1 then year=1*substr(table,pos,len-pos+1);
			drop pos len;
		%end;
		%else %do;
			tablegrp=table; 
			year=.;
		%end;
	run;
	data tablesm tabless;
		set tables; 
		by tablegrp;
		if first.tablegrp+last.tablegrp<2 then output tablesm; else output tabless;
	run;

	data variables;
		merge variables tables;
		by table;
	run;
title2 "Single table entities";
	proc print data=tabless;
	run;
title2 "Multible table entities";
	proc tabulate data=tablesm missing;
		class tablegrp year;
		var nobs;
		table tablegrp, year*nobs=''*min=''*f=10.0;
	run;
title2 "Variable overview for each table";
	proc tabulate data=variables missing;
		class tablegrp name year;
		table tablegrp, name, year*N;
	run;
	 options orientation=portrait;
%mend;
ods pdf file="&logdir/rawdatareport.pdf";
%scanlib(in=rawdata);
%scanlib(in=extdata,withyear=FALSE);
%scanlib(in=extdata2,withyear=FALSE);
ods pdf close;
