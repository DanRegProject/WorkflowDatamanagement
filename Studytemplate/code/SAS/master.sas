/*

*/
*options mprint merror symbolgen mlogic macrogen ;
/* global path is general */
%let Projectnumber     = NNNN;                /* replace */
%let Studynumber     = ZZZ;                   /* replace */
%let ProjectOwnerInitials = QQQ;              /* replace */
%let Shorttitle = Template;                   /* replace */
%let projectdescription   = Template project; /* replace */
%let ProjectDate          = mdy(12,20,2022);  /* replace */
%let GlobalProject     = FSEID0000&Projectnumber;
%let globalprojectpath = F:\Projekter\&GlobalProject;

/* project specific names and paths */
%let ProjectName          = t&Projectnumber._&Studynumber._&ProjectOwnerInitials._&Shorttitle; /* set to <project folder name> */

%let ProjectPath          = &globalprojectpath/&ProjectName;

%let ProjectStartYear     = 1977; /* look at data from &projectStartYear */

%let macropath     = &projectpath/macros;
%let localfinaldir = &projectpath/data/SAS;
%let localworkdir  = &projectpath/tempdata/SAS;
%let localstatadir = &projectpath/data/Stata;
%let localcodedir  = &projectpath/code/SAS;
%let locallogdir   = &projectpath/out;
%let localdir      = &projectpath/;

%let create_log     = TRUE; /* set to TRUE if you want the log in a textfile in &locallogdir */
%let create_timelog = TRUE;  /* set to TRUE if you want to monitor  execution time */

%let commondir=&macropath;
%include "&macropath/sas/common.sas";

libname mydata "&localworkdir";
libname myfinal "&localfinaldir";

options mprint merror;
%let sqlmax    = max;
%start_log(&locallogdir, master, option=new );
%start_timer(master);

/* create header with information from top of file */
%header(path=&projectpath, ajour=&ProjectDate, dataset=&ProjectName, initials=&ProjectOwnerInitials, reason=&projectdescription);
/* local code definitions should be entered in this file */
%include "&localcodedir/localIDC_ATCcodes.sas";

/* a copy of the master tables are in work for faster processing */
/* the copy is created in querydata.sas and only needed in this file */
/* otherwide leave LPRdata and LMDBdata empty */
%let LPRdata = work.LPR;
%let LMDBdata = work.Medi;

/* set to TRUE if you want unfinished diagnosis and operations */
%let noOutdate = FALSE;

/* set to TRUE if you want to include ICD-8*/
%let useICD8   = FALSE;

/* list the information needed for creating the base population */
/* examples of how to select the main population codes, use a single table or combine e.g. LPR and ATC  */
%let baseLPR     = ;    /* LPR example */
%let baseATC     = ;    /* ATC example */
%let baseOPR     = ;
%let baseUBE     = ;
%let baseLAB     = ;

/***************************** Additional data *****************************************************/
/* examples of the lists - replace with the information you need for your study */

%let diaglist  = ;
%let diaglist1 = ;
%let medlist   = ;
/* operations */
%let oprlist   = ;
/* investigations */
%let ubelist   = ;
%let lablist   = ;

%let diagtil =;
%let ubetil =;
%let oprtil =;

/* combine in one macro variable */
/* edit if more macrovariables are defined above */
%let diagALL = &baseLPR &diaglist &diaglist1 ;
%let mediALL = &baseATC &medlist;
%let oprALL  = &baseOPR &oprlist;
%let ubeALL  = &baseUBE &ubelist;
%let labALL  = &baseLAB &lablist;

%let diagtilALL = &diagtil;
%let ubetilALL  = &ubetil;
%let oprtilALL  = &oprtil;

%let useCharlson = FALSE; /* or TRUE */
%let useSegal = FALSE; /* or TRUE */
%let useHFRS = FALSE; /* or TRUE */

/* create a combined dataset from basedata called basepop  */
*%let combinedBase = TRUE; /* will merge base datasets - set to false if no combination */
%let combinedBase = FALSE;

%global basepopLPR basepopATC basepopOPR basepopUBE basepopLAB basedata basepnr;
%macro setupbasepop;
    %if "&baseLPR" ne "" %then %let basepopLPR = mydata.basepop1; %else %let basepopLPR=;;
    %if "&baseATC" ne "" %then %let basepopATC = mydata.basepop2; %else %let basepopATC=;;
    %if "&baseOPR" ne "" %then %let basepopOPR = mydata.basepop3; %else %let basepopOPR=;;
    %if "&baseUBE" ne "" %then %let basepopUBE = mydata.basepop4; %else %let basepopUBE=;;
    %if "&baseLAB" ne "" %then %let basepopLAB = mydata.basepop5; %else %let basepopLAB=;;
    %let basedata = &basepopLPR &basepopATC &basepopOPR &basepopUBE &basepopLAB;
    %let basepnr = mydata.basepopred;
%mend;
%setupbasepop;

%macro makedoc;
/* generate txt files for article */
/* prefix, output folder, list of medicin/diagnosis etc., output filename */
%if "&mediALL" ne ""             %then %create_datalist(ATC, &locallogdir, &mediALL, medilist);;
%if "&diagALL.&diagtilALL" ne "" %then %create_datalist(LPR, &locallogdir, &diagALL &diagtilALL, diaglist, ICD8=&useICD8);;
%if "&oprALL.&oprtilALL" ne ""   %then %create_datalist(OPR, &locallogdir, &oprALL &oprtilALL, oprlist);;
%if "&ubeALL.&ubetilALL" ne ""   %then %create_datalist(UBE, &locallogdir, &ubeALL &ubetilALL, ubelist);;
%if "&labALL" ne ""              %then %create_datalist(LAB, &locallogdir, &labALL , lablist);;

%if "&useCharlson" eq "TRUE"     %then %create_datalist(CHARLSON, &locallogdir, , charlson);;
%if "&useSegal" eq "TRUE"        %then %create_datalist(SEGAL, &locallogdir, , segal);;
%if "&useHFRS" eq "TRUE"         %then %create_datalist(HFRS, &locallogdir, , segal);;
    %mend;
%makedoc;

%end_timer(master, text=master file until query and makedata);
%end_log;


%include "&localcodedir/QueryData.sas";
/* divide datacollection into two steps, uncomment in order to use them */
/* base population - run 1 time */
%Initial_data_collection;
/* supplemental data for basepopulation - run 1 time (requires Initial_data_collection) */
%supplemental_data;

/* create the studypt table */
%include "&localcodedir/makedata.sas";

%checklog(log=&locallogdir);
