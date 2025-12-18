/* master.sas                                                                         */
/* Klargør Rawdata til workdata                                                       */
/* SASdatafilerne i rawdata kopieres over i workdata til masterdata/data/sas/master   */
/* Der laves nye identvariable, jf anbefaling fra OPEN, hvorved strings erstattes af  */
/* integers. Desuden dannes indexfiler til nøgledatasættene (lpr og lmdb)             */
/* OPEN foreslår at man samler data der leveret opdelt i årsdatasæt. Dette kan være   */
/* hensigtsmæssigt for at gøre det nemt at tilgå data, men for meget store datasæt    */
/* kan det give meget lange svartider. De årsopdelte data er derfor i vid udstrækning */
/* fastholdt.                                                                         */
/* Der er enkelte tilfælde hvor der fjernes variable fra rawdata.                     */
/* Det samlede program vil kunne anvendes umiddelbart i andre projekter med minimal   */
/* tilretning.                                                                        */
/* Sidst i filen dannes grunddata til beregning af riskscores, fx charlson og         */
/* cha2ds2vasc. Dette kræver adgang til makroerne %getDiag og %makemulticotables!     */
/* Data til disse placeres i MCOlib. Hvis de skal dannes sættes MCOflag = TRUE        */
/* Flemming Skjøth, 27-08-2025                                                        */

options mprint merror spool dlcreatedir;
%global logdir create_log create_timelog;
/* Angiv projektnummer, tjek! */
%let Globalproject = 7xxxxx;
/* Kontroller sti, tjek!      */
%let Globalprojectpath    = e:/projektdb/OPEN/workdata/&globalproject;
%let GlobalprojectpathRaw = e:/projektdb/OPEN/rawdata/&globalproject;

/* Angiv hvor data skal placeres */
%let projectname            = masterdata; /* library in folder &globalprojectpath */
%let projectpath            = &globalprojectpath/&projectname;
/* Sikre at der er en folder til logfiler */
%let logdir                 = &projectpath/log;
libname log  "&logdir";  libname log clear; /* trick til at lave en folder */
/* Placering af makroer til at trække data til riskscores (MCOflag = TRUE) */
%let macropath              = &projectpath/../mastercode/SAS;
%include "&macropath/common.sas"; *<-- heri ændres LPR3grp ved opdatering af LPR3 datamodel;

/* Placering af data leveret fra DS, tjek!       */
libname  rawdata  "&globalprojectpathraw/grunddata"  ;
/* Placering af data leveret fra eksterne, tjek! */
libname extdata "&globalprojectpathraw/eksterne data" ;
libname extdata2 "&globalprojectpathraw/eksterne data/SDS_202412" ;
/* Placering af folder med studiepopulation, tjek! */
libname popdata "&globalprojectpathraw/population" ;

/* Placering af tilrettede data */
libname master "&projectpath/data/SAS/Master";
/* Placering af data til riskscores              */
libname mcolib "&projectpath/data/SAS/MCOLIB"; /* overwrite readonly in common.sas */

/* lave riskscoredata ?*/
%let MCOflag        = FALSE;
/* danne logfiler ? (god ide) */
%let create_log     = TRUE;
%let create_timelog = TRUE;
%let TEST           = FALSE; /* Ved testgennemløb sæt TRUE, ellers FALSE */
                            /* testgennemløb indlæser max 10000 rækker  */
							/* og placerer data i WORK                  */
							/* Dette dækker trin 1-4                    */
                            /* create_log kan evt sættes til FALSE      */

/* Angiv datasættet med studiepopulationen               */
/* bruges i 1-kopierDataFraRaw.sas til at lave pnr nøgle */
%let studiepop = rawdata.studiepopulation;
%let studiepop = popdata.population_709645;

/* I de inkluderede filer er makroer som ikke bør skulle ændres    */
/* med i makrokaldene nederst skal datasæt- og evt variabelnavne,  */
/* og årstal kontrolleres.                                         */
/* Nogle af programmerne indlæser komplette datasæt og er derfor   */
/* meget tidskrævende.                                             */

/* Lav en rapport over de leverede tabeller som kan tjekkes op mod indstillingen */
%END_LOG;
%include "&projectpath/code/0-TestIndholdiRaw.sas";

/* Kopier fra Raw, pnr omkodes til fortløbende heltal, variable omdøbes så
    foranstillede C_ V_ D_ fjernes, length justeres så trunkering af værdier undgåes */
%include "&projectpath/code/1-KopierDataFraRaw.sas";

/* variable omdøbnes for at få konsistens over LPR2 og LPR3 */
%include "&projectpath/code/2_1-EnsretVariable.sas";

/* kontakt tidsstempler i LPR2 oprettes og struktur for tillægskoder
    som i LPR3 dannes */
%include "&projectpath/code/2_2-EnsretLPR2Data.sas";

/* Der laves heltalsnøgler for supplerende identer */
%include "&projectpath/code/3_1-LavNøgler.sas";

/* datasæt omnøgles */
%include "&projectpath/code/3_2-OmkodeMedNøgler.sas";

/* lav et populationsregister ud fra BEF, DOD og VNDS */
%include "&projectpath/code/4-LavPopulationsForløbsRegister.sas";

/* Lav multicomorbiditetstabeller */
%include "&projectpath/code/5-LavMulticomorbiditetsRegister.sas";

/* Lav afdelingstype register, konsistent version af pattype på
    tværs af LPR2 og LPR3 */
%include "&projectpath/code/6-LavAfdelingstypeRegister.sas";

%checklog(log=&logdir);

