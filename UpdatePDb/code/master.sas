options compress=YES;
options mprint merror spool;
%put start of master.sas %sysfunc(today(),date.) %sysfunc(time(),time.); /* just to keep track in the log */

%include "D:\Program Files\SASHome\SASFoundation\9.4\nls\en\Autoexec_Forskermaskine.sas";

/* keep other options available for test purpose */
*options mprint merror symbolgen mlogic  ; /* option macrogen remove, can cause memory related errors (problem note 1821) */
*options mprint merror mlogic  ;
/* reset options; */
*options nosymbolgen nomlogic;
%let globalend = mdy(12,31,2099);

%let globalprojectpath = F:\Projekter\PDB0000YYYY;
%let projectpath       = &globalprojectpath;
%let localpath         = &globalprojectpath/MasterRawCode;
%let datapath          = &globalprojectpath/MasterData;
%let macropath         = &globalprojectpath/MasterMacros/macros/;

%let Defaultproject = PDB0000YYYY;

/* REMEMBER to run dobackup.sas before initiating extraction process */

/* REMEMBER: change from local to datapath, set dates and lastyr. Choose log. */
*%let currentpath     = &localpath;         /* USE THIS when testing  */
%let currentpath     = &datapath;          /* USE THIS when updating for real */

%let create_timelog  = TRUE;               /* measure execution time */
%let create_log      = TRUE;               /* change to TRUE when updating real data, will save the log in &currentpath/log */

/* Be aware, tables are updated every month at the following days:
   CPR3     1.+20.
   DAR      25.
   LMS  ikke fast dato - tjek opdateringstabellen!!!!!!!!!
   LPR      18.+19.
   MFR      22.
   MINIPAS  19.
   SSR      23.
   safest time to update from 2.-17. or 26.-31. depending on last LMS update  */

/* REMEMBER: set the time when updating data */
%let last_dataupdate = mdy(5,10,2021);   /* All projects update, get the changes from 2016 and onwards */
%let last_dataupdate = mdy(12,31,2022);

%let lastyr          = 2022;
%let RawFromYear     = 2016; /* update the files from 2016 and onwards, leave the rest untouched */
%let LMSRawFromYear  = 2019; /* update the files from 2018 and onwards, leave the rest untouched, it is anticipated that LMS is not altered (must be evaluated) */
%let LABRawFromYear  = 2008; /* update the files from start and onwards,  unsure about LAB as new labs may be added with historical data */
*%let newyear         = 2021; /* first update after new year - tables has to be updated "manually" - no version available for merge */
%let UpdateFromYear  = &RawFromYear;

%let GetDataWithODBC = FALSE;    /* Now RAW data are placed in backup folder before merge */ /* old: master.sas only handles brand new RAW data - but CombineWithOld macro will be reused with local data */

/* REMEMBER update the MasterMacros/macros/SAS/macros folder (SVN update) */
%include "&macropath/SAS/common.sas";

*%let sqlmax=1000; /* use when testing (sqlmax=max defined in common)*/ /*max is in common*/
*%let combmax = 1000; /* when testing the code, reduce table size */ /*max is in CombineWithOld*/

/* rawdata: Master tables in MasterData/raw - stored in MasterCode/raw when testing */
/* rawtop:  Master tables general info in MasterData - stored in MasterData  */
/* remember only 7 letters in libname... */
libname rawdata    "&currentpath/raw";
libname rbackup    "&currentpath/Totallyraw";
libname rawtop     "&currentpath";
libname rawOrg     "&datapath/raw";     /* Master tables - already in use - be careful */

%let rawtoppath       = &currentpath;  /* change to raw/rawnew etc. when data is ready */
%let raworgpath       = &datapath/raw;

/* file: MasterMacros\macros\SAS\macros/getTablesOverview.sas */
%GetAvailableTables(rawtop); /* overblik tabelnavne */
%GetUpdateList(rawtop);      /* overblik opdateringsdato */

/* REMEMBER: do not run make_updatetxt before you are ready to retrive data */
/* Txtfile with latest available update-dates for the RAW tables. */
/* Txtfile with short description of where the RAW tables are used */
/* will also create a table with names and dates, to be used for generating macrovariables with dates for each area */
/* file: MasterMacros\macros\SAS\macros/makeupdatetxt.sas */
%make_updatetxt(rawtop,&currentpath,&last_dataupdate);

/* howto.txt part 4 until here */
%start_timer(startRawtime);

%include "F:\Projekter\PDB0000YYYY\MasterRawCode/code/data_variable_list.sas";          /* list of available tables with variables */


/* 19/9-2017 change: Only update the latest files
   This macro will update the files from 2016 (RawFromYear), or selected tables with no year limit.
   The rest of the files in TotallyRaw are untouched. Tables are stored in TotallyRaw */
/* file: MasterMacros\macros\SAS\macros/GetRawTables */
  %GetNewRawTables(rbackup, LMS,         &LMS_tableN,    newfromyear = &LMSRawFromYear,crit=eksd);
  %GetNewRawTables(rbackup, LPR,         &LPR_tableNewN, newfromyear = &RawFromYear); /* subset of LPR tables */
  %GetNewRawTables(rbackup, LPRPSYK,     &LPRPSYK_tableN);
  %GetNewRawTables(rbackup, MINIPAS,     &MINIPAS_tableN  /*, newfromyear =&RawFromYear*/); /* subset of LPR tables */
  %GetNewRawTables(rbackup, MINIPASPSYK, &MINIPASPSYK_tableN  /*, newfromyear = &RawFromYear*/); /* subset of LPR tables */
  %GetNewRawTables(rbackup, CPR3,        &CPR3_tableN);
  *MFR is not avaible for LPR3 (2020- ) as of 17-05-2021;
  %GetNewRawTables(rbackup, MFR,         &MFR_tableN,    newfromyear = &RawFromYear);
  %GetNewRawTables(rbackup, MFRlpr,      &MFRlpr_tableN, newfromyear = &RawFromYear);
  %GetNewRawTables(rbackup, LMStxt,      &LMStxt_tableN); /* lms tekster flyttet til hovedprojekt */
  %GetNewRawTables(rbackup, FGR,         &FGR_tableN);   /* kodetabeller */
  *SSR is not avaible for LPR3 (2021 ) as of 17-05-2021;
  %GetNewRawTables(rbackup, SSR,         &SSR_tableN,    newfromyear = &RawFromYear);
  %GetNewRawTables(rbackup, LAB,         &LAB_tableN,    newfromyear = &LABRawFromYear, crit=samplingdate);
  %GetNewRawTables(rbackup, LABtxt,      &LABtxt_tableN);

  %GetNewRawTables(rbackup, LPR3SB,     &LPR3SB_tableN);
  %GetNewRawTables(rbackup, LPR3SBtxt,  &LPR3SBtxt_tableN);

  /* update from late 2023 new register SMR if LPR_F*/
  %GetNewRawTables(rbackup, SMR,     &SMR_tableN);
  %GetNewRawTables(rbackup, LPR_F,     &LPR_F_tableN);

%end_timer(startRAWtime, text=time getting all tables from scratch);

*%checklog(log=&currentpath/log);

/* COMBINE the new and the old tables */
%start_timer(startMergetime);
/* Combine the new masterfiles with the old. Only for the last period of time (from 2016) */

/* file : MasterMacros\macros\SAS\macros/combinewithold.sas */
%CombineTables(rawdata, LPR,              &LPR_tablenewN,  NewFromYear=&RawFromYear);
%CombineTables(rawdata, LPRPSYK,          &LPRPSYK_tableN);
%CombineTables(rawdata, MINIPAS,          &MINIPAS_tableN  /*, newfromyear =&RawFromYear*/); /* subset of LPR tables */
%CombineTables(rawdata, MINIPASPSYK,      &MINIPASPSYK_tableN  /*, newfromyear = &RawFromYear*/); /* subset of LPR tables */
%CombineTables(rawdata, CPR3,             &CPR3_tableN);
%CombineTables(rawdata, LMS,              &LMS_tableN,    NewFromYear=&LMSRawFromYear);
%CombineTables(rawdata, LMStxt,           &LMStxt_tableN);
/* LAB prepared - has newer been used. Simply copied to RAW the first time - this line is run next time */
%CombineTables(rawdata, LAB,              &LAB_tableN,    NewFromYear=&LABRawFromYear); /* can be reduced with samplingdate - same procedure as eksd for LMS */
%CombineTables(rawdata, LABtxt,           &LABtxt_tableN);
/* update only latest years  */
%CombineTables(rawdata, SSR,              &SSR_tableN,    NewFromYear=&RawFromYear);
%CombineTables(rawdata, MFR,              &MFR_tableN,    NewFromYear=&RawFromYear);
%CombineTables(rawdata, MFRlpr,           &MFRlpr_tableN, NewFromYear=&RawFromYear);
%CombineTables(rawdata, FGR,              &FGR_tableN);   /* kodetabeller */

%CombineTables(rawdata, LPR3SB,           &LPR3SB_tableN);
%CombineTables(rawdata, LPR3SBtxt,        &LPR3SBtxt_tableN);

%CombineTables(rawdata, SMR,              &SMR_tableN);
%CombineTables(rawdata, LPR_F,            &LPR_F_tableN);


/* split lpr_f_procedure in kontakter and forloeb */

data rawdata.lpr_f_procedurer_kirurgi_kontakt
	rawdata.lpr_f_procedurer_kirurgi_forloeb;
	set rawdata.lpr_f_procedurer_kirurgi;
	if DW_EK_KONTAKT ne . then output rawdata.lpr_f_procedurer_kirurgi_kontakt;
	if DW_EK_FORLOEB ne . then output rawdata.lpr_f_procedurer_kirurgi_forloeb;
run;

data rawdata.lpr_f_procedurer_andre_kontakt
	rawdata.lpr_f_procedurer_andre_forloeb;
	set rawdata.lpr_f_procedurer_andre;
	if DW_EK_KONTAKT ne . then output rawdata.lpr_f_procedurer_andre_kontakt;
	if DW_EK_FORLOEB ne . then output rawdata.lpr_f_procedurer_andre_forloeb;
run;

/* write time measurement in the log */
%end_timer(startMergetime, text='time merging all new tables with old');

/* checklog is the really easy way to find errors.... USE IT */
/* file: MasterMacros\macros\SAS\macros/checklog.sas */
%checklog(log=&currentpath/log);

