options mprint merror spool;

%let GlobalProject = FSEID0000XXXX;

%let globalprojectpath = F:\Projekter\&GlobalProject;

/* project specific names and paths */
%let ProjectName          = MasterCode;
%let projectdescription   = Generate individual risktables for each project;
%let ProjectOwnerInitials = FLS;
%let ProjectPath          = &globalprojectpath/&ProjectName;
%let ProjectDate          = today();

%let macropath     = &projectpath/macros;
%let localworkdir  = &projectpath/data;
%let localcodedir  = &projectpath/code;
%let localdir      = &projectpath/;

%let localpath     = &localworkdir;
%let datapath      = &globalprojectpath/MasterData/;

%let currentpath   = &datapath; /* change accordingly when testing or updating for real */
*%let currentpath   = &localpath; /* change accordingly when testing or updating for test */

%let logdir        = &currentpath/log;

%let lastyrbak = 2018;

%include "&macropath/sas/common.sas";

libname Risklib  "&currentpath/RiskTables";     /* place for temp files to base the risk score calculation on */
libname mcolib   "&currentpath/RiskTables";

%include "&localcodedir/Makerisk.sas";
%include "&localcodedir/Makemulticoscores.sas";
%include "&macropath/SAS/ICD_ATC_CODES/Riskscores.sas";
options fullstimer;

%let create_log     = TRUE; /* set to TRUE if you want the log in a textfile in &locallogdir */
%let create_timelog = FALSE;  /* set to TRUE if you want to monitor  execution time */
%let update = TRUE; /* change to true after 2021 - 02 - 12 MJE */

%makeRiskTables; /* bunch of cardiovascular risk scores */
%makemulticoTables(charlson);
%makemulticoTables(segal);
%makemulticoTables(HFRS);

%checklog(log=&logdir);
