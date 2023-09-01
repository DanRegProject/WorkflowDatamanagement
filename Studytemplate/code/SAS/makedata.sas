/*

*/
%start_log(&locallogdir, makedata);
%start_timer(makedata);

%header(path=&projectpath, ajour=&ProjectDate, dataset=&ProjectName, initials=&ProjectOwnerInitials, reason=Running makedata.sas making final studypt-table);

data studie;
  merge &basedata; /* single population or a combination - tables are sorted by pnr and idate */
  by pnr idate;
  where &ProjectDate between rec_in and rec_out;
  drop rec_in rec_out;
%runquit;

/* reduce to first pnr */
data studie;
  set studie;
  by pnr idate;
  idate=oprdate;
  if first.pnr;
%runquit;

%describeSASchoises("Merge the hospital periods for the base treatment to the dataset"); /* set newfile in order to create a new empty file */

%macro mergedata;
%smoothhosp(mydata.hospitalSmooth, mydata.hospall, ajour=&ProjectDate, nofDays=1);

%if "&diaglist" ne "" %then %mergeDiag(studie, mydata, mydata, idate, &diaglist, postfix=B, ajour=&ProjectDate);;

/* example with subset */
%if "&diaglist" ne "" %then %mergeDiag(studie, mydata, mydata, idate, &diaglist, postfix=B, ajour=&ProjectDate, subset=(pattype eq "1"));;


%describeSASchoises("example: Looking at history for &diaglist and followup for &diaglist1");;
%if "&diagALL" ne "" %then %mergeDiag(studie, mydata, mydata, idate, &diagALL, hosp=mydata.hospitalSmooth, ajour=&ProjectDate);; /* basic data about population including hospitalization */
%if "&mediALL" ne "" %then %mergeMedi(studie, mydata, mydata, idate, &mediALL,  ajour=&ProjectDate);;
%if "&oprALL.&ubeALL" ne "" %then %mergeOpr(studie,  mydata, mydata, idate, &oprALL &ubeALL, ajour=&ProjectDate);;

%if "&diagtilALL" ne "" %then %mergeDiag(studie, mydata, mydata, idate, &diagtilALL, tildiag = TRUE, hosp=mydata.hospitalSmooth, ajour=&ProjectDate);; /* basic data about population including hospitalization */
%if "&oprtilALL.&ubetilALL" ne "" %then %mergeOpr(studie,  mydata, mydata, idate, &optilALL &ubetilALL, tilopr = TRUE, ajour=&ProjectDate);;
%if "&mediLAB" ne "" %then %mergeLAB(studie, mydata, mydata, idate, &labALL,  ajour=&ProjectDate);;
%mergePop(mydata.popAll, studie, studie, idate, ajour=&ProjectDate);
%mend;
%mergedata;

/* backup studie */
data mydata.studie;
  set studie;
%runquit;

%macro riskscores;
/* get risk scores and merge them onto studie */
%describeSASchoises("Risk calculation looking 1 year back in time");
%riskmacros(mydata.studie, idate, mydata.risktable, mydata.indicators, 1*&YearInDays, &locallogdir, &Projectdate);

%if "&useCharlson" eq "TRUE" %then %multicoscore (charlson, mydata.studie, mydata, idate, PeriodStart=, ajour=today(),mergebase=FALSE);;
%if "&useSegal" eq "TRUE" %then %multicoscore (segal, mydata.studie, mydata, idate, PeriodStart=, ajour=today(),mergebase=FALSE);
%if "&useHFRS" eq "TRUE" %then %multicoscore (hfrs, mydata.studie, mydata, idate, PeriodStart=, ajour=today(),mergebase=FALSE);

%mend;
%riskscores;

data myfinal.studiept;
  set mydata.studie ;
  by pnr;

  format ageidate 3.; /* no decimalpoints in age */
  if birthdate ne . then ageidate = intck('year', birthdate, idate);;
%macro callbase;
  /* information about basepopulation: */
  %if "&diagALL" ne "" %then %baseDiag(idate, &diagALL,  keeppat=TRUE, keepDiag=TRUE, keepDate=TRUE, keepStatus=TRUE, keepAfter=TRUE);;
  /* information according to idate in basepopulation */
  %if "&oprALL.&ubeALL" ne "" %then %baseOPR(idate,  &oprALL &ubeALL,   keepDate=TRUE, keepBefore=TRUE,  keepAfter=FALSE);
  %if "&mediALL" ne "" %then %baseMedi(idate, &mediALL, keepDate=TRUE, StatusType=1, StatusCrit=365);

  %if "&diagtilALL" ne "" %then %baseDiag(idate, &diagtilALL,  keeppat=TRUE, keepDiag=TRUE, keepDate=TRUE, keepStatus=TRUE, keepAfter=TRUE);;
  %if "&oprtilALL.&ubetilALL" ne "" %then %baseOPR(idate,  &oprtilALL &ubetilALL,   keepDate=TRUE, keepBefore=TRUE,  keepAfter=FALSE);

%mend;
%callbase;

%RunQuit;

/* create a table for STATA */
proc export data=myfinal.studiept outfile="&localstatadir\studiept.dta" replace;
%runquit;


%end_timer(makedata, text=entire makedata file);
%end_log;


*%TjekMacro(mydata.seALL, diagnose, pattype diagtype, titletxt='SE diagnosis');
*%TjekMacro(mydata.hfatcall, hfatc, strnum, titletxt='HF medication');
*%TjekMacro(mydata.pciall, opr, pattype oprart, titletxt='PCI operations');




