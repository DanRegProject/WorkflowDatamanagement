/* Start del 6 */
%start_log(&logdir, 6-LavAfdelingstyperegister);
%start_timer(masterdata);
%let startyr=1990;

/*%IF %EXIST(master.depclass) %THEN %DO;*/
  %cleanup(depclass,lib=master);
/*%END;*/

%gethosp(work.allhosp, fromyear=&startyr);

data work.allhosp;
	set work.allhosp;
		electflag=(priority="2" or substr(priority,1.4)="ATA3");
		overnight=(indate ne outdate);
		year=year(indate);
	keep hospital hospitalunit year electflag overnight;
run;
proc summary data=work.allhosp nway;
	class hospital hospitalunit year electflag overnight;
	output out=work.depcount;
run;
data work.depcount;
	set work.depcount;
	if year<&startyr then delete;
	tot=1;
run;
proc summary data=work.depcount;
	class hospital hospitalunit year;
	weight _freq_;
	var electflag overnight tot;
	types hospital*hospitalunit*year hospital*hospitalunit; /* den sidste giver year=. */
	output out=work.depclass sum=electN overnightN totcount mean=electprop overnightprop;
run;
data work.depclass;
	set work.depclass;
	deptype=.;
	if electprop<.5 and overnightprop<.5 then deptype=3; /* ED */
	if electprop>=.5 and overnightprop<.5 then deptype=2; /* outpatient */
	if overnightprop>=.5 then deptype=1; /* Inpatient */
	if year=. then year=0;
run;

proc format;
	value deptype
	1="Inpatient"
	2="Outpatient"
	3="ED";

proc sort data=work.depclass;
	by hospital hospitalunit year;
run;

data master.depclass;
	set work.depclass(rename=(deptype=deptype_) where=(year>0));
	by hospital hospitalunit year;
	deptypetxt_=put(deptype_,deptype.);
	retain startyear endyear deptype deptypetxt;
	if first.hospitalunit then do;
		startyear=year;
		deptype=deptype_;
		deptypetxt=deptypetxt_;
	end;
	endyear=year;
%	if last.hospitalunit then output;
	keep hospital hospitalunit startyear endyear deptype deptypetxt;
run;

data master.depclass;
	set master.depclass work.depclass(where=(year=0) in=a);
	if a then do;
		startyear=0;
		endyear=0;
		deptypetxt=put(deptype,deptype.);
	end;
	keep hospital hospitalunit startyear endyear deptype deptypetxt;
run;

%cleanup(allhosp depcount depclass);

%end_timer(masterdata, text=Measure time for master);
%end_log;
