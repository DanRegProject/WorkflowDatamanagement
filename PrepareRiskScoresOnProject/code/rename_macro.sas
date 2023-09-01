%macro run_loop(inlib=,data=,outlib=,surfix=);
proc sql noprint;
select distinct(name) 
	into : varname1 - : varname999
	from __&data;
	quit;
run;

data &outlib..&data;
set &data;
%do i = 1 %to &sqlobs;
	%if "&&varname&i." eq "pnr" or "&&varname&i." eq "rec_in" or "&&varname&i." eq "rec_out" %then ;
	%else %do;
		rename &&varname&i.=&&varname&i.._&surfix;
	%end;
%end;
run;
%mend;

%macro renaming_variables(inlib=,data=,outlib=,surfix=);

data &data;
set &inlib..&data;
run;

proc contents noprint data=&inlib..&data out=__&data(keep=name);
run;

%run_loop(inlib=&inlib,data=&data,outlib=&outlib,surfix=&surfix);

proc datasets library=work noprint;
 delete __:;
run;

%mend;
