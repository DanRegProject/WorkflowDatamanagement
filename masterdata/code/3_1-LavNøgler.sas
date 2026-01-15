

/* Start del 3 */
%start_log(&logdir, 3_1-LavNøgler);
%start_timer(masterdata); /* measure time for this macro */

/* tilsvarende pnr så laves der nye heltalsidenter for RECNUM, FAMILIE_ID, DW_EK_FORLOEB og DW_EK_KONTAKT */
%macro makekey(head,ident,in=master,out=master);
    * head: prefix på datasæt ;
    * ident: variabel med ident;
    * in:   libname hvor der læses fra, option ;
    * out:  libname hvor der skrives til, option ;
%local i ok postfix dsn ds_names;
%if %upcase(&test)=TRUE %then %let in=WORK;
%if %upcase(&test)=TRUE %then %let out=WORK;
%let OK=FALSE;
%let head=%upcase(&head);
    proc sql noprint;
        select distinct memname into :ds_names separated by ' '
            from dictionary.tables
            where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and upcase(memtype)="DATA";
        %let i=1;
        %do %while  (%scan(&ds_names,&i) ne );
            %let dsn=%scan(&ds_names,&i);
            %if %sysfunc(exist(&in..&dsn)) %then %do;
                %if %varexist(&in..&dsn,&ident) %then %do; /* evt sortere efter personident */
                proc sql;
                    %if &i=1 %then create table _tempfile_ as;
                    %else insert into _tempfile_;
                    select distinct &ident from &in..&dsn;
                    %sqlquit;
                    %let OK=TRUE;
                    %end;
                %else %put ERROR: Variablen &ident findes ikke i datasættet &in..&dsn;
                %end;
            %else %put Error: Datasættet &in..&dsn findes ikke ;
            %let i=%eval(&i+1);
        %end;
%if &OK=TRUE %then %do;
	proc sort data=_tempfile_ nodupkey;
		by &ident;
        run;
        %let postfix=;
        %if %index(&head,&LPR3grp)>0 %then %let postfix=&LPR3grp;
        %if "&head"="LPR_ADM" %then %let postfix=lpr;
        %if "&head"="PRIV_ADM" %then %let postfix=priv;
        %if "&head"="PSYK_ADM" %then %let postfix=psyk;
        data &out..key&postfix.&ident;
            set _tempfile_;
            where &ident is not missing;
            ny&ident=_N_;
        run;
        %put NOTE: Nøgle for &ident er dannet i datasættet &out..key&postfix.&ident;
        %end;
    %mend;

%makekey(bef          ,familie_id);
%makekey(lpr_adm      ,kontakt_id);
%makekey(priv_adm     ,kontakt_id);
%makekey(psyk_adm     ,kontakt_id);
*%makekey(lpr_f_forloeb,FORLOEB_id);
%makekey(lpr_f_kontakter,KONTAKT_id);
%end_timer(masterdata, text=Measure time for master);
%end_log;

