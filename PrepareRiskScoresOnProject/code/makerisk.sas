/* SVN header
$Date:  $
$Revision: $
$Author: $
$ID: $
*/
%macro MakeRiskTables;
  %start_log(&logdir, risktables, option=new );
  %start_timer(allrisk);

  /* Find all hypertension tables. Store in lib */
  %Hypertension(risklib);
  /* this table has to be rerun when new data is available - and merged with old */

  /* the following tables will find the first diagnosis. New pnr will be appended */
  %diabetes(risklib);

  /* get stroke - combined of istroke, SE and TIA  */
  %stroke(risklib);

  /* get Heart failure, combined of HF2, HFATC and LVD */
  %heartfailure(risklib);

  /* vascular diseases, MI or PAD3 or APlaq */
  %vascular(risklib);

  /* age and sex */
  %riskpopulation(risklib);

  /* Renal (for HAS-BLED) */
  %renal(risklib);

  /* MRenal (for ATRIA) */
  %Mrenal(risklib);

  /* liver (for HAS-BLED) */
  %liver(risklib);

  /* bleeding */
  %bleeding(risklib);

  /* drugs */
  %drugs(risklib);

  /* alcohol */
  %alcohol(risklib);

  /* addition to do orbit and atriableed */
  %addfororbit(risklib);

  /* renin */
  %renin(risklib);

  %end_timer(allrisk, text=execution time getting all risk tables from scratch );
  %end_log;
%mend; /* makerisktables */

%macro makeDiagtableinwork(name, lib);
  %put "find all pnr with " &name;
*  %getDiag(work, &name, basepop=&name, ICD8=TRUE);
   %getDiag(work, &name,  ICD8=TRUE);

  /* keep only pnr and &name, " &name "=indate */
  data work.&name;
    set work.LPR&name.ALL;
	  where &projectdate between rec_in and rec_out;
    keep pnr &name;
    &name = indate;
    format  &name  date.;
	if pnr ne ""; /* remove pnr = 0 or . - 1994 has a lot of bad entries */
  %runquit;

  %put "sort data by pnr and &name";
  proc sort data=work.&name nodupkey;
   by pnr &name ;
  %runquit;
  %let recn=;
  data work.&name;
    set work.&name;
    by pnr &name;
    *if first.pnr; /* to get all dates of events */
	%if &update=TRUE %then %let recn=1;;
    rec_in&recn=&projectdate;
	rec_out&recn=mdy(12,31,2099);
	format rec_in&recn rec_out&recn date.;
  %runquit;

  %if &update=TRUE %then %do;
    data work.base&name;
    set &lib..&name;
  %runquit;
  data work.&name;
  merge  work.&name(in=a) work.base&name(in=b);
  by pnr &name;
  if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
  if a and not b then do; rec_out=rec_out1; rec_in=rec_in1; end;
  if a and b then do; rec_out = rec_out1; end;
  drop rec_in1 rec_out1;
  run;
%end;
data &lib..&name;
    set work.&name;
%runquit;
%mend;


%macro makeMeditableinwork(name, lib);
  /* Find all pnr with " &name ", store in work.&name */
  %getMedi(work, &name);

  /* keep only information needed: pnr eksd rec_in rec_out. Eksd is renamed to atc */
  data work.&name;
    set work.LMDB&name.ALL (drop=&name);
    where &projectdate between rec_in and rec_out;
	format &name 4.;
    label  &name = "&name";
	&name = 1;
	if pnr ne "";
	%let recn=;
	%if &update=TRUE %then %let recn=1;;
    rec_in&recn=&projectdate;
	rec_out&recn=mdy(12,31,2099);
	format rec_in&recn rec_out&recn date.;
    keep pnr eksd &name rec_in&recn rec_out&recn ;
  %runquit;

  proc sort data=work.&name nodupkey ;
    by pnr eksd rec_in&recn rec_out&recn ; /* keep only one ekspedition per day */
  %runquit;

  %if &update=TRUE %then %do;
    data work.base&name;
    set &lib..&name;
  %runquit;
  data work.&name;
  merge  work.&name(in=a) work.base&name(in=b);
  by pnr eksd;
  if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
  if a and not b then do; rec_out=rec_out1; rec_in=rec_in1; end;
  if a and b then do; rec_out = rec_out1; end;
  drop rec_in1 rec_out1;
  run;
%end;
data &lib..&name;
    set work.&name;
%runquit;
  /* sort " &name " by pnr and date, remove identical lines */
  /* keep entire history for drug-tables */
%mend;



/* create all tables:  */
/* Hypertension */
%include "&localcodedir/hypertension.sas";

/* Diabetes */
%macro diabetes(lib);
  %makeDiagtableinwork(diabLPR, &lib);
  %makeMeditableinwork(diabATC, &lib);
%mend;

%macro stroke(lib);
/* get stroke - combined of istroke, SE and TIA  */
  %makeDiagtableinwork(istroke, &lib);
  %makeDiagtableinwork(SE, &lib);
  %makeDiagtableinwork(TIA, &lib);
%mend;


/* heart failure */
%macro heartfailure(lib);
  %makeMeditableinwork(hfATC, &lib);
  %makeMeditableinwork(loop, &lib);
  %makeDiagtableinwork(hfstr, &lib);
  *%makeDiagtableinwork(LVD, &lib);
%mend;

/* vascular */
%macro vascular(lib);
  %makeDiagtableinwork(MIstr, &lib);
  %makeDiagtableinwork(padvasc, &lib);
  *%makeDiagtableinwork(Aplaq, &lib);
%mend;

/* Mrenal */
%macro Mrenal(lib);
  %makeDiagtableinwork(Mrenal, &lib);
%mend;


/* renal */
%macro renal(lib);
  %makeDiagtableinwork(renal, &lib);
%mend;


/* liver */
%macro liver(lib);
  %makeDiagtableinwork(liver, &lib);
%mend;


%macro bleeding(lib);
  *%makeDiagtableinwork(Ibleed, &lib);
  *%makeDiagtableinwork(Mbleed3, &lib);
  *%makeDiagtableinwork(Gbleed2, &lib);
  *%makeDiagtableinwork(TIbleed, &lib);

  %makeDiagtableinwork(GIbleed, &lib);
  %makeDiagtableinwork(icbleed, &lib);
  %makeDiagtableinwork(impbleed, &lib);
  %makeDiagtableinwork(genbleed, &lib);
  %makeDiagtableinwork(ocbleed, &lib);
%mend;

%macro drugs(lib);
  %makeMeditableinwork(aspirin, &lib);
  %makeMeditableinwork(clopi, &lib);
  %makeMeditableinwork(NSAID, &lib);
%mend;

%macro alcohol(lib);
  %makeDiagtableinwork(alco, &lib);
%mend;

%macro addfororbit(lib);
      %makeMeditableinwork(Thien, &lib);
      %makeDiagtableinwork(Anemia, &lib);
%mend;

/* renin */
%macro renin(lib);
      %makeMeditableinwork(renin, &lib);
%mend;
