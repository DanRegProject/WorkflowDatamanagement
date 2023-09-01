/*

*/

%macro Initial_data_collection;
%start_timer(queryinit);
%start_log(&locallogdir, InitialDataCollection);

%header(path=&projectpath, ajour=&ProjectDate, dataset=&ProjectName, initials=&ProjectOwnerInitials, reason=Running Querydata.sas collecting data);


/* store the actual dates for each table in a local txt file */
data _null_;
  infile "&globalprojectpath/InputData/log/RawUpdateDates.txt";
  file "&localcodedir/RawUpdateDates.txt";
  input;
  put _infile_;
run;

%describeSASchoises("Base population made with &baseLPR &baseATC &baseOPR &baseUBE", Newfile=TRUE); /* set newfile in order to create a new empty file */

/* example base population based on diagnosis, different ways to use input codes (see Masterdata.sas) */
%if "&baseLPR" ne "" %then %getDiag(mydata, &baseLPR, basepop=basepop1, UAF=&noOutdate, ICD8=&useICD8);; /* UAF = true adds unfinished diagnosis */

%if "&baseATC" ne "" %then %getMedi(mydata, &baseATC, basepop=basepop2);;
%if "&baseOPR" ne "" %then %getOPR(mydata, &baseOPR, basepop=basepop3);;
%if "&baseUBE" ne "" %then %getOPR(mydata, &baseUBE, basepop=basepop4,type=UBE);;
%if "&baseLAB" ne "" %then %getLAB(mydata, &baseLAB, basepop=basepop5);;

/* reducer til een liste med pnr */
%macro makepnrlist;
        data &basepnr;
            set &basedata;
            by pnr;
            if first.pnr;
            keep pnr;
            %runquit;
%mend;
%makepnrlist; /* create list of pnr */

%end_timer(queryinit, text=Initial data in Querydata file );
%end_log;
%mend; /* Initial_data_collection */

/* this is where the long lists of data with additional medications and diagnosis are fetched */
%macro Supplemental_data;
%start_timer(querysup);
%start_log(&locallogdir, SupplementalData);

%describeSASchoises(); /* new line... */
%describeSASchoises("Supplemental diagnosis: &diagALL");
%describeSASchoises("Supplemental medications: &mediALL");
%describeSASchoises("Supplemental operations: &oprALL");
%describeSASchoises("Supplemental laboratory data: &labALL");


%if "&diagALL" ne "" %then %getDiag(mydata, &diagALL, basedata=&basepnr, UAF=&noOutdate, ICD8=&useICD8, fromyear=&projectstartyear);;
%if "&mediALL" ne "" %then %getMedi(mydata, &mediALL, basedata=&basepnr);;
%if "&oprALL" ne "" %then %getOPR(mydata, &oprALL, basedata=&basepnr, UAF=&noOutdate);;
%if "&ubeALL" ne "" %then %getOPR(mydata, &ubeALL, basedata=&basepnr, type=UBE,UAF=&noOutdate);;
%if "&diagtilALL" ne "" %then %getDiag(mydata, &diagtilALL, basedata=&basepnr, diagtype="+", tildiag=TRUE, UAF=&noOutdate, ICD8=&useICD8, fromyear=&projectstartyear);;
%if "&oprtilALL" ne "" %then %getOPR(mydata, &oprtilALL, tildiag=TRUE, basedata=&basepnr, UAF=&noOutdate);;
%if "&ubetilALL" ne "" %then %getOPR(mydata, &ubetilALL, tildiag=TRUE, basedata=&basepnr, type=UBE, UAF=&noOutdate);;
%if "&labALL" ne "" %then %getLab(mydata, &labALL, basedata=&basepnr);;
%getHosp(mydata.hospALL,basedata=&basepnr);
%getPOP(mydata.PopAll, &basepnr); /* not in use on DS */

%end_timer(querysup, text=Supplemental data in Querydata file );
%end_log;
%mend; /* supplemental_data */


