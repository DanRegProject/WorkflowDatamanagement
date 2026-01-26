
/* Anden del 3 */

/* De dannede nøgler appliceres på alle de relevante tabeller hvor variablen indgår */
%macro applykey(head,ident,keyfile,in=master,out=master,var=);
%start_log(&logdir, 3_2-OmkodeMedNøgler&head.&ident.&var);
%start_timer(masterdata); /* measure time for this macro */
    * head: prefix på datasæt ;
    * ident: variabel med ident;    
    * keyfile: nøglefilen med ident;
    * in:   libname hvor der læses fra, option ;
    * out:  libname hvor der skrives til, option ;
    * var: variablen i datasættet der skal omnøgles, angives hvis den hedder andet end identen;
%local i dsn ds_names;
%if %upcase(&test)=TRUE %then %let in=WORK;
%if %upcase(&test)=TRUE %then %let out=WORK;
%let head=%upcase(&head);
%let postfix=;
%IF &var= %THEN %LET var=&ident;
%if %sysfunc(exist(&in..&keyfile)) %then %do; /* test om filen findes */
        proc sql noprint;
    select distinct memname into :ds_names separated by ' '
        from dictionary.tables
        where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and 
        (upcase(memtype)="DATA" or upcase(memtype)="VIEW");
    %let i=1;
    %do %while  (%scan(&ds_names,&i) ne );
        %let dsn=%scan(&ds_names,&i);
        %if %sysfunc(exist(&in..&dsn)) or %sysfunc(exist(&in..&dsn,VIEW)) %then %do; /* test om filen findes */;
            %if %varexist(&in..&&dsn,&var) %then %do; /* evt sortere efter personident */;
                    /*
                    proc sort data=&in..&dsn out=_tempdata_;
                        by &var;
                    run;
                    */
                    proc sql;
                       create table _added_ as 
                          select distinct &var as &ident from &in..&dsn(keep=&var)
                          where &var not in (
                             select &ident from &in..&keyfile);
                           select count(*) into :nadded from _added_;
                           %IF &nadded>0 %THEN %DO;
                              %PUT WARNING: &nadded keys in &in..&dsn were not found in &in..&keyfile;
                              data &in..&keyfile;
                                 set &in..&keyfile _added_(in=a);
                                 if a then ny&ident = -1*_N_;
                              run;
                              proc sort data=&in..&keyfile;
                                 by &ident;
                              run;
                           %END;
                    /*
                    Data &out..&dsn(rename=(ny&ident=&ident));
                        merge _tempdata_(in=a) &in..&keyfile(in=b rename=(&ident=&var));
                        by &var;
                        drop &var;
                        if a;
                    run;
                    */
                    %end;
                %else %put ERROR: Identen &var findes ikke i datasættet &in..&dsn;
                %end;
            %else %put ERROR: Datasættet &in..&dsn findes ikke ;
            %let i=%eval(&i+1);
            %end;
        %end;
    %else %put ERROR: Nøgle datasættet &in..&keyfile findes ikke ;
%end_timer(masterdata, text=Measure time for master);
%end_log;
    %mend;
/* familie_id */
%let keyvar=familie_id;
%let keyfile=keyfamilie_id;
*%applykey(bef          ,&keyvar,&keyfile);* grundlag for ident;
%applykey(faik         ,&keyvar,&keyfile);
/* kontakt_id lpr2 */
%let keyvar=kontakt_id;
%let keyfile=keylprkontakt_id;
*%applykey(lpr_adm      ,&keyvar,&keyfile);* grundlag for ident;
%applykey(lpr_bes      ,&keyvar,&keyfile);
%applykey(lpr_diag     ,&keyvar,&keyfile);
*%applykey(lpr_opr     ,&keyvar,&keyfile);
%applykey(lpr_sksopr   ,&keyvar,&keyfile);
%applykey(lpr_sksube   ,&keyvar,&keyfile);
%let keyfile=keyprivkontakt_id;
*%applykey(priv_adm     ,&keyvar,&keyfile);* grundlag for ident;
%applykey(priv_diag    ,&keyvar,&keyfile);
%applykey(priv_sksopr  ,&keyvar,&keyfile);
%applykey(priv_sksube  ,&keyvar,&keyfile);
%let keyfile=keypsykkontakt_id;
*%applykey(psyk_adm     ,&keyvar,&keyfile);* grundlag for ident;
%applykey(psyk_diag    ,&keyvar,&keyfile);
/* forloeb_id - lpr3 */
%let keyvar=forloeb_id;
%let keyfile=keylpr_fforloeb_id;
*%applykey(lpr_f_forloeb,   &keyvar,&keyfile);* grundlag for ident;
%applykey(lpr_f_kontakter, &keyvar,&keyfile);
%applykey(lpr_f_resultater,&keyvar,&keyfile);
%applykey(lpr_f_procedurer_andre,&keyvar,&keyfile);
%applykey(lpr_f_procedurer_kirurgi,&keyvar,&keyfile);
/* kontakt_id lpr3 */
%let keyvar=kontakt_id;
%let keyfile=keylpr_fkontakt_id;
%applykey(lpr_f_diagnoser,&keyvar,&keyfile);
*%applykey(lpr_f_kontakter,&keyvar,&keyfile);* grundlag for ident;
%applykey(lpr_f_resultater,&keyvar,&keyfile);
%applykey(lpr_f_procedurer_andre,&keyvar,&keyfile);
%applykey(lpr_f_procedurer_kirurgi,&keyvar,&keyfile);







