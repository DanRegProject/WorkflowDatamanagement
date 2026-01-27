/* Start del 4 */

/* tjek årstal på dod og vnds nederst */
%start_log(&logdir, 4-LavPopulationsForløbsregister);
%start_timer(masterdata); /* measure time for this macro */


%macro makepopreg(pop,dode,vandringer,in=master,out=master);
%if %upcase(&test)=TRUE %then %let in=WORK;
%if %upcase(&test)=TRUE %then %let out=WORK;
proc sort data=&in..&vandringer out=vandringer nodupkey;
	by pnr haend_dato indud_kode;
%runquit;
proc sort data=&in..&dode out=dode nodupkey;
	by pnr;
%runquit;
proc sort data=&in..&pop out=pop;
    by pnr;
%runquit;
data pop;
	merge pop dode;
	by pnr;
%runquit;
%macro ibef;
    proc sql noprint;
    select distinct memname into :ds_names separated by ' '
        from dictionary.tables
        where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and 
        (upcase(memtype)="DATA" or upcase(memtype)="VIEW");
	%let i=1;
	
	%do %while (%scan(&ds_names,&i) ne );
   		%if %sysfunc(exist(&in..&dsn)) or %sysfunc(exist(&in..&dsn,VIEW)) %then %do;
			proc sql;
			create table _pop as
				select a.*, b.koen as koen&y, b.foed_dag as foed_dag&y, &y as yr&y
			from pop a left join &in..&dsn b
			on a.pnr=b.pnr
			order by pnr;
			create table pop as select * from _pop;
		%end;
		%let i=%eval(&i+1);
	%end;
	run;
%mend;
%let globalstart= mdy(1,1,1900);
%let globalend  = mdy(1,1,2099);
%ibef;
data population; set pop;
retain sex birthdate rec_in rec_out;
format birthdate deathdate rec_in rec_out date10.;
deathdate=doddato;
array kon{*} koen: ;
array fdag{*} foed_dag: ;
array aar{*} yr: ;
do I = 1 to dim(kon);
	if i=1 then do;
		sex=.;
		birthdate=.;
		rec_in=&globalstart;
		rec_out=&globalend;
	end;
	if kon{i} ne . then do;
			kon{i}=kon{i}-1;/* recode to binary 0/1 */
			if (sex ne kon{i} or birthdate ne fdag{i}) then do;
				rec_out=mdy(12,31,aar{i}-1);
				if sex ne . and birthdate ne . then output;
				rec_in=mdy(1,1,aar{i});
				rec_out=&globalend;
			end;
			sex=kon{i};
			birthdate=fdag{i};
	end;
end;
output;
keep pnr sex birthdate deathdate rec_in rec_out;
run;
   /*
       data population;
        merge population pop;
        by pnr;
    run;
  */


/* make dataset to represent periods of residence */
data vandringer;
	set vandringer;
	by pnr;
	format udv_dato indv_dato date10.;
	retain udv_dato indv_dato last_kode Fra_land Til_land;

	if first.pnr then do;
		udv_dato  = &globalstart;
		indv_dato = &globalstart;
		last_kode = "";
		fra_land = .;
		til_land = .;
	end;
/*
	if (last_kode eq indud_kode) then do;
		if (indud_kode eq 'I') then udv_dato = indv_dato;
	    else indv_dato=udv_dato; output test;
end;
	*/
	if indud_kode='I' then do;
		indv_dato=haend_dato-1;
		fra_land=indUd_land;
	end;
	if indud_kode='U' and (last_kode ne indud_kode) /* brug første række hvis gentagelser */ then do;
		udv_dato=haend_dato;
		til_land=indUd_land;
	end;

	rec_in=&globalstart;
	rec_out=&globalend;

	if last.pnr or (indud_kode='U'  and (last_kode ne indud_kode) /* brug første række hvis gentagelser */)  then do;
		if last.pnr and indud_kode='I' then do;
			udv_dato=&globalend;
			til_land=.;
		end;
		if indv_dato<udv_dato then output vandringer;
	end;
	last_kode =  indud_kode;
	format rec_in rec_out  date10.;
	keep pnr udv_dato indv_dato fra_land til_land rec_in rec_out ;

%runquit;


proc sort data=vandringer out=&out..vandringer;
	by pnr udv_dato indv_dato;
run;
proc sort data=population out=&out..population;
	by pnr;
run;
%mend;

/* based on BES create population register */
%makepopreg(population_709645,dod2023,vnds2023);

%end_timer(masterdata, text=Measure time for master);
%end_log;

