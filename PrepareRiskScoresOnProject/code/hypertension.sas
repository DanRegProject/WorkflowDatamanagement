/* SVN header
$Date:  $
$Revision: $
$Author: $
$ID: $
*/
/* Find all hypertension tables. */
%macro MakeHypTable;
  %local U;
  %do U = 1 %to &RISKhypN; /* loop the list of tables found in ATCriskscores.sas */
    %let name = %scan(&RiskHyp,&U); /* the names are corresponding to defines in ATCkoder.sas */

	%getMedi(work, &name);
  %end;
%mend;


/* remove not needed information. Only pnr, eksd and type of hypertension is needed. Keep rec_in and rec_out. */
%macro ReduceHypTables(lib);
  %local U;

  %do U = 1 %to &RiskhypN; /* nof tables */
    %let name = %scan(&RiskHyp,&U); /* the names are corresponding to defines in ATCkoder.sas */

  /* sort, in order to reduce to only one pnr for each rec_in&rec_out period */
	proc sort data=work.LMDB&name.ALL nodupkey;
	  where &projectdate between rec_in and rec_out;
	  by pnr eksd &name ;
   %runquit;

   data work.&name._red(rename=(atc=&name)) ;
	 set work.LMDB&name.ALL(rename=(&name=inatc));
	 by pnr eksd inatc;
	 length atc $36.;
	 retain atc;
	 if first.eksd then atc="";
	 atc=catx(" ",of atc inatc);
	 /* keep information about medication - do not replace with 1 - used for combination drug calculation */
	 label atc = "&name";
	 if pnr ne "";
	 rec_in1=&projectdate;
	 rec_out1=mdy(12,31,2099);
	 format rec_in1 rec_out1 date.;
	 if last.eksd then output;
	 keep pnr eksd atc rec_in1 rec_out1;
   %runquit;
%end;

/* combine in one final table */
data work.hypall;
  merge
  %do U = 1 %to &RiskhypN; /* nof tables */
    %let name = %scan(&RiskHyp,&U); /* the names are corresponding to defines in ATCkoder.sas */
    work.&name._red %end;
	;
  by pnr eksd;
%if &update=TRUE %then %do;
  id=catx("_", of
  %local U;
  %do U = 1 %to &RISKhypN; /* loop the list of tables found in ATCriskscores.sas */
    %let name = %scan(&RiskHyp,&U); /* the names are corresponding to defines in ATCkoder.sas */
    &name
	%end;
    );
%end;
%if &update=FALSE %then	rename rec_in1=rec_in rec_out1=rec_out;;
%runquit;
%if &update=TRUE %then %do;
  data work.basehypall;
  set &lib..hypall;
  id=catx("_", of
  %local U;
  %do U = 1 %to &RISKhypN; /* loop the list of tables found in ATCriskscores.sas */
    %let name = %scan(&RiskHyp,&U); /* the names are corresponding to defines in ATCkoder.sas */
    &name
	%end;
    );
  %runquit;
  data work.hypall;
  merge  work.hypall(in=a) work.basehypall(in=b);
  by pnr eksd id;
  if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
  if a and not b then do; rec_out=rec_out1; rec_in=rec_in1; end;
  if a and b then do; rec_out = rec_out1; end;
  drop rec_in1 rec_out1 id;
  run;
%end;
data &lib..hypall;
set work.hypall;
  %runquit;
%mend;

%macro Hypertension(lib);
  %MakeHypTable;
  %reduceHyptables(&lib);
   /* make sure pnr and dates are sorted */
   proc sort data=&lib..hypall;
     by pnr eksd;
	%runquit;
	%makeDiagtableinwork(hyplpr,risklib);
%mend;

