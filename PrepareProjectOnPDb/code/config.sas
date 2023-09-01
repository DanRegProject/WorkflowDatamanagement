/* This config file extracts data from the main tables in YYYY to a specific project XXXX           */

options compress=NO;
options mprint merror spool;
OPTIONS THREADS CPUCOUNT=3;

%let create_timelog = TRUE;
%let create_log     = TRUE;
%let firstrun       = FALSE;
%let PROJECT_NAME   = FSEID0000XXXX;
*%let Last_DataUpdate     = mdy(06,23,2016);  /* first version */
*%let Last_DataUpdate     = mdy(02,01,2017);  /* first update */
*%let Last_DataUpdate     = mdy(05,23,2017);  /* update */
*%let Last_DataUpdate     = mdy(06,19,2017);  /* Data from 23/5 with correct use of getMedi */
*%let Last_DataUpdate     = mdy(08,07,2017);  /* Update of data */
*%let Last_DataUpdate     = mdy(10,09,2017);  /* Update of data */
*%let Last_DataUpdate     = mdy(12,30,2017);  /* Update of data */
*%let Last_DataUpdate     = mdy(04,16,2018);  /* Update of data */
*%let Last_DataUpdate     = mdy(08,06,2018);  /* Update of data */
*%let Last_DataUpdate     = mdy(10,25,2018);  /* Update of data */
*%let Last_DataUpdate     = mdy(1,23,2019);   /* Update of data */
*%let Last_DataUpdate     = mdy(1,22,2020);   /* Update of data */
%let Last_DataUpdate     = mdy(06,21,2021);   /* Update of data and LPR3_SB*/

%let globalprojectpath = F:\Projekter\PDB0000YYYY\;
%let globalmacropath   = &globalprojectpath\MasterMacros\macros\SAS\macros\; /* point to local version of MasterMacros - keep same version for all SW updates */
%let projectpath       = &globalprojectpath\&PROJECT_NAME\;
%let datapath          = &globalprojectpath\MasterData\;
%let currentpath       = &projectpath\OutputData;
%let localpath         = &projectpath;
%let macropath	       = &projectpath\macros;

%include "&projectpath\macros\SAS\common.sas";

%let sqlmax=max; *Must be set after common.sas;
/* prjdata: Folder with tables for specific project */
/* raworg : Folder with all unchanged tables from view (added rec_in and rec_out)   */
libname prjdata    "&projectpath\updateData";            /* data for update is placed here */
libname outdata    "&projectpath\OutputData";            /* final output is placed here */
libname popdat     "&projectpath/population";            /* where the population is found and stored  */
libname raw        "&datapath\raw"  access=readonly;     /* Point to PDB data when re-using the general macros for getting  ATC and ICD  */

%let lastyr            = 2021;

%include "&globalprojectpath/MasterRawCode/code/data_variable_list.sas";   /* list all tables with order of variables */


%start_log(&currentpath/log, config);
%header(path=&projectpath\code, ajour=&Last_DataUpdate, dataset=&PROJECT_NAME, initials=NNN, reason=Data for project &PROJECT_NAME );
%start_timer(config); /* measure time for entire project */

/* create the population */
%let pop         = popdat.population;      /* the final list with pnr, reduced to only one copy of each pnr, if update this file will be added new candidates */
%let poplist     = prjdata.pop;            /* new list with recnum that goes with pnr, for fetching LPR data, is prefix */
%let population1 = B01;                     /* antitrombotiske lægemidler */
%include "&projectpath/code/population.sas";
%end_log;

/* This macro is used to find candidates: */
%put "&macropath/sas/macros/getMedi.sas";

%start_log(&currentpath/log, config, option=); /* restart config log, option= will append */
%getPnrandRecnum(&pop,&poplist,source=LPR LPRPSYK MINIPAS MINIPASPSYK LPR3SB,ajour=&Last_DataUpdate); /* this project only reduces the population in the LMS tables */
%end_log; /* config log is replaced with individual logs for each table */


%start_log(&currentpath/log, config, option=); /* restart config log, option= will append */

/* changes specific to project &PROJECT_NAME */
/* Changes from det general data variable list */
%let CPR3_table2  = cpr3_t_person,            , 0,0,      v_pnr_encrypted c_kon c_status d_foddato d_status_hen_start, ,;
%let CPR3_tableN  = 2;


%let LPR_table1  = lpr2_mdl_uaf_t_opr,    ,        2018,    &lastyr_lpr2,   	v_recnum c_opr c_komb c_oafd c_osgh, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table2  = lpr2_mdl_t_diag,       ,        2005,    &lastyr_lpr2,   	v_recnum c_diag c_diagtype c_tildiag, lpr2_mdl_t_adm, k_recnum;
%let LPR_table3  = lpr2_mdl_uaf_t_diag,   ,        2018,    &lastyr_lpr2,   	v_recnum c_diag c_diagtype c_tildiag, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table4  = lpr2_mdl_t_opr,        ,        2005,    &lastyr_lpr2,   	v_recnum c_opr c_komb c_oafd c_osgh, lpr2_mdl_t_adm, k_recnum;
%let LPR_table5  = lpr2_mdl_t_sksopr,     ,        2005,    &lastyr_lpr2,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto v_otime v_ominut, lpr2_mdl_t_adm, k_recnum;
%let LPR_table6  = lpr2_mdl_uaf_t_sksopr, ,        2018,    2018,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, 						lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table7  = lpr2_mdl_uaf_t_sksopr, ,        2019,    &lastyr_lpr2,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, 	lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table8  = lpr2_mdl_t_sksube,     ,        2005,    &lastyr_lpr2,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, lpr2_mdl_t_adm, k_recnum;
%let LPR_table9  = lpr2_mdl_uaf_t_sksube, ,        2018,    2018,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  , lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table10 = lpr2_mdl_uaf_t_sksube, ,        2019,   	&lastyr_lpr2,   	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table11 = lpr2_mdl_t_adm,        ,        2005,   	&lastyr_lpr2,   	k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm c_udm v_indtime v_indminut, lpr2_mdl_t_adm, k_recnum;
%let LPR_table12 = lpr2_mdl_uaf_t_adm,    ,        2018,    2018,   	k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm, lpr2_mdl_uaf_t_adm, k_recnum; /*c_indm c_udm v_indtime v_indminut er ikke i views før 2019*/
%let LPR_table13 = lpr2_mdl_uaf_t_adm,    ,        2019,    &lastyr_lpr2,	k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm c_udm v_indtime v_indminut, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table14 = lpr_t_diag,            ,        1977,    1994,      	v_recnum c_diag c_diagtype c_diagmod, lpr_t_adm, k_recnum;
%let LPR_table15 = lpr_t_diag,            ,        1995,    2004,     	v_recnum c_diag c_diagtype c_tildiag, lpr_t_adm, k_recnum;
%let LPR_table16 = lpr_t_opr,             ,        1977,    2004,      	v_recnum c_opr c_komb c_oafd c_osgh, lpr_t_adm, k_recnum;
%let LPR_table17 = lpr_t_sksopr,          ,        1996,    2004,      	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, lpr_t_adm, k_recnum;
%let LPR_table18 = lpr_t_sksube,          ,        1999,    2004,      	v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, lpr_t_adm, k_recnum;
%let LPR_table19 = lpr_t_adm,             ,        1977,    1986,      	k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime,  lpr_t_adm, k_recnum;
%let LPR_table20 = lpr_t_adm,             ,        1987,    1993,      	k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime c_udm,  lpr_t_adm, k_recnum;
%let LPR_table21 = lpr_t_adm,             ,        1994,    2004,      	k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime c_udm v_sengdage v_indminut ,  lpr_t_adm, k_recnum;
%let LPR_tableN    = 21; /* all LPR tables */
%let LPR_tableNewN = 21; /* the LPR tables that are still updated */

%let LPRPSYK_table1 = lpr_t_psyk_adm,             ,        0,    0,      k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh v_sengdage c_indm /*c_sex*/ c_udm  v_indminut v_indtime ,lpr_t_psyk_adm, k_recnum;
%let MINIPASPSYK_table1 = minipas_t_psyk_adm,    ,         2002,    &lastyr_lpr2,  k_recnum v_cpr_encrypted c_indm d_inddto d_uddto c_adiag c_pattype c_sgh c_afd v_sengdage /*c_sex*/ c_udm,minipas_t_psyk_adm, k_recnum;

/* reducing lms.epikur dataset */
%let LMS_table1 = LMS_epikur,             ,         1994,&lastyr,     cpr_encrypted eksd atc  vnr apk doso indo,,;

/* reduce LAB tables to the variables we need to use (remove samplingtime) */
%let LAB_table1  = LAB_lab_dm_forsker   , ,        2008,&lastyr,        patient_cpr_encrypted analysiscode laboratorium_idcode referenceinterval_lowerlimit referenceinterval_upperlimit resulttype samplingdate /* samplingtime */ unit value,,;
%let LAB_tableN  = 1;

/*Removed RESULTATER OPHOLDSADRESSE METASTASER FORLOEBMARKOER. Certian variables commented/removed */
%let LPR3SB_table1 = LPR3_SB_DIAGNOSE,           , 0, 0, KONTAKT_ID ART DIAGNOSE_ID FEJL KODE SENEREAFKRAEFTET SIDEANGIVELSE ,                 LPR3_SB_KONTAKT, KONTAKT_ID ;
%let LPR3SB_table2 = LPR3_SB_DIAGNOSE_TILLAEG,   , 0, 0, DIAGNOSE_ID TILLAEGSKODE,                                                             LPR3_SB_DIAGNOSE, DIAGNOSE_ID;
%let LPR3SB_table3 = LPR3_SB_FORLOEBELEMENT,     , 0, 0, FORLOEBELEMENT_ID /* AFSLUTNINGSMAADE ANSVARLIG_ENHED */ FEJL FEJL_TRNS FORLOEBLABEL HENVISENDEINSTANS HENVISNINGSAARSAG /*HENVISNINGSMAADE HENVISNINGSTIDSPUNKT HOVEDSPECIALE INST_TYPE */ PERSONNUMMER_ENCRYPTED REFERENCETYPE REFERENCE_ID SLUTTIDSPUNKT STARTTIDSPUNKT /*SUNDHEDSINSTITUTION*/ ,              LPR3_SB_KONTAKT, FORLOEBELEMENT_ID  ;
%let LPR3SB_table4 = LPR3_SB_KONTAKT,            , 0, 0, KONTAKT_ID AKTIONSDIAGNOSE ANSVARLIG_ENHED FEJL FEJL_FLB FEJL_TRNS FORLOEBELEMENT_ID HENVISENDEINSTANS /*HENVISNINGSMAADE HENVISNINGSTIDSPUNKT*/ HOVEDSPECIALE INST_TYPE KONTAKTAARSAG KONTAKTTYPE PERSONNUMMER_ENCRYPTED PRIORITET SLUTTIDSPUNKT STARTBEHANDLING STARTTIDSPUNKT SUNDHEDSINSTITUTION , LPR3_SB_KONTAKT, KONTAKT_ID  ;
%let LPR3SB_table5 = LPR3_SB_PROCEDURER,         , 0, 0, KONTAKT_ID FEJL /*FORLOEBELEMENT_ID HANDLINGSSPEC*/ INDIKATION KODE KONTRAST PROCEDURER_ID PROCEDURETYPE PRODUCERENDE_ENHED SIDEANGIVELSE SLUTTIDSPUNKT STARTTIDSPUNKT ,                                                                                                                               LPR3_SB_KONTAKT, KONTAKT_ID ;
%let LPR3SB_table6 = LPR3_SB_PROCEDURER_TILLAEG, , 0, 0, PROCEDURER_ID TILLAEGSKODE,                                                           LPR3_SB_PROCEDURER, PROCEDURER_ID ;
%let LPR3SB_tableN = 6;

%let LPR3SBtxt_table2 = LPR3_SB_SOR_COMPLETE,   , 0, 0, GAELDENDE_FRA_DATO HOVEDSPECIALE /*NIVEAU*/ OPHOERT_DATO PARENT_SORKODE REGION SHAK_KODE SIDST_AENDRET_DATO SORKODE SOR_TYPE SPECIALE2 SPECIALE3 SPECIALE4 SPECIALE5 SPECIALE6 SPECIALE7 SPECIALE8, ,;

/* Only for LPR tables: create a pop file with recnum based on the population for the project */

/* copying LPR, CPR3, LMS with the corresponding pnr/recnum */
*%getPnrandRecnum(source=LPR);
%copyProjectData(&poplist,prjdata,LPRPSYK,    	&LPRPSYK_tableN,		ajour=&Last_DataUpdate);
%copyProjectData(&poplist,prjdata,MINIPAS,    	&MINIPAS_tableN,		ajour=&Last_DataUpdate);
%copyProjectData(&poplist,prjdata,MINIPASPSYK,	&MINIPASPSYK_tableN,	ajour=&Last_DataUpdate);
%copyProjectData(&poplist,prjdata,LPR,        	&LPR_tableN,			ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,CPR3,       	&CPR3_tableN,			ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,LAB,        	&LAB_tableN,			ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,LABtxt,     	&LABtxt_tableN,		SimpleCopy=TRUE,	ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,LMS,        	&LMS_tableN,			ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,LMStxt,     	&LMStxt_tableN, 	SimpleCopy=TRUE,	ajour=&Last_DataUpdate);
%copyProjectData(&pop,    prjdata,FGR,        	&FGR_tableN, 		SimpleCopy=TRUE,	ajour=&Last_DataUpdate);

%copyProjectData(&poplist,    prjdata,LPR3SB,		&LPR3SB_tableN, 		ajour=&Last_DataUpdate);
%copyProjectData(&poplist,    prjdata,LPR3SBtxt,	&LPR3SBtxt_tableN, 	SimpleCopy=TRUE,	ajour=&Last_DataUpdate);

%end_log;
%start_log(&currentpath/log, config, option=); /* restart config log, option= will append */
/* Run %refresh only if re-establishing a versionised data repository */
*%refresh(&firstrun,prjdata,outdata);
%end_log;
/* if this is a first run then do not run this last part, instead copy the files from prjdata to outdata, excluding the pop* files */

%macro CTrun;
%if &firstrun=FALSE %then %do;
%CombineTables(outdata, CPR3,    	&CPR3_tableN, 		project=., orglib=outdata, totallyraw=prjdata);

%CombineTables(outdata, LPRPSYK,    &LPRPSYK_tableN, 	project=., orglib=outdata, totallyraw=prjdata);
%CombineTables(outdata, MINIPAS,    &MINIPAS_tableN, 	project=., orglib=outdata, totallyraw=prjdata  /*, newfromyear =&RawFromYear*/); /* subset of LPR tables */
%CombineTables(outdata, MINIPASPSYK,&MINIPASPSYK_tableN,project=., orglib=outdata, totallyraw=prjdata  /*, newfromyear = &RawFromYear*/); /* subset of LPR tables */
%CombineTables(outdata, LPR,        &LPR_tablenewN,  	project=., orglib=outdata, totallyraw=prjdata);

%CombineTables(outdata, LMS,        &LMS_tableNewN,  	project=., orglib=outdata, totallyraw=prjdata);
%CombineTables(outdata, LMStxt,     &LMStxt_tableN,  	project=., orglib=outdata, totallyraw=prjdata);
/* LAB prepared - has newer been used. Simply copied to RAW the first time - this line is run next time */
%CombineTables(outdata, LAB,        &LAB_tableN, 		project=., orglib=outdata, totallyraw=prjdata); /* can be reduced with samplingdate - same procedure as eksd for LMS */
%CombineTables(outdata, LABtxt,     &LABtxt_tableN, 	project=., orglib=outdata, totallyraw=prjdata); /* can be reduced with samplingdate - same procedure as eksd for LMS */

%CombineTables(outdata, FGR,        &FGR_tableN, 		project=., orglib=outdata, totallyraw=prjdata);   /* kodetabeller */

%CombineTables(outdata, LPR3SB,  	&LPR3SB_tableN, 	project=., orglib=outdata, totallyraw=prjdata);
%CombineTables(outdata, LPR3SBtxt,	&LPR3SBtxt_tableN, 	project=., orglib=outdata, totallyraw=prjdata);
%end;
%else %do;
proc copy in = prjdata out = outdata;
%runquit;
%end;
%mend;
%CTrun;
%start_log(&currentpath/log, config, option=); /* restart config log, option= will append */


/* cleanup prjdata LAST STEP BEFORE DATACHECK */
%macro cleanup_prjdata;
%if &syserr le 4 %then %do;
	proc datasets library = prjdata kill noprint;
	%runquit;
%end;
%mend;
%cleanup_prjdata;


/* move text files with information of dates for each table */
filename src "&datapath\rawupdatedates.txt" recfm=n;
filename dst "&&projectpath\OutputData\log\rawupdatedates.txt" recfm=n;

%let rc = %sysfunc(fcopy(src,dst));
%put %sysfunc(sysmsg());

 %end_timer(config, text=Measure time for entire config file);
 %end_log;

/* finalize by making error checking and create reports on tabels, columns and codes */
%checklog(log=&currentpath/log);

%datacheck(outdata,doclib=&projectpath\OutputData);
%codecheck(outdata,lms_epikur,atc,1,doclib=&projectpath\OutputData);
