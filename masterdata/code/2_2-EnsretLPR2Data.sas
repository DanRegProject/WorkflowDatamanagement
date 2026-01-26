/* Start del 2.2 */

%macro ensretlpr2(head, in=master,out=master);
%start_log(&logdir, 2_2-EnsretLPR2Data&head);
%start_timer(masterdata); /* measure time for this macro */
    * head: prefix på datasæt ;
    * in:   libname hvor der læses fra ;
    * out:  libname hvor data skal placeres ;
%local i dsn ds_names;
%if %upcase(&test)=TRUE %then %let in=WORK;
%if %upcase(&test)=TRUE %then %let out=WORK;
%let head=%upcase(&head);
    proc sql noprint;
        select distinct memname into :ds_names separated by ' '
            from dictionary.tables
            where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and 
            (upcase(memtype)="DATA" or upcase(memtype)="VIEW");

        %if %index(&head,ADM)>0  %then %do;
        /* ADM */;
        %let i=1;
        %do %while  (%scan(&ds_names,&i) ne );
            %let dsn=%scan(&ds_names,&i);
            %if %sysfunc(exist(&in..&dsn)) or %sysfunc(exist(&in..&dsn,VIEW)) %then %do;
                data _tempdata_;
                    set &in..&dsn;
                    _void_=0;
                    starttid=hms(%if %varexist(&in..&dsn,INDTIME) %then indtime;%else 11;,
                        %if %varexist(&in..&dsn,INDMINUT) %then indminut; %else 59;,0);
                    sluttid= hms(%if %varexist(&in..&dsn,UDTIME) %then udtime;%else 11;,
                        %if %varexist(&in..&dsn,UDMINUT) %then udminut; %else 59;,0);
                    format starttid sluttid time.;
                    drop _void_
                        %if %varexist(&in..&dsn,indtime) %then  indtime;
                    %if %varexist(&in..&dsn,indminut) %then  indminut;
                    %if %varexist(&in..&dsn,udtime) %then  udtime;
                    %if %varexist(&in..&dsn,udminut) %then  udminut;;
                run;
               proc sql noprint;
               %IF SYSFUNC(exist(&out..&dsn,VIEW)) %THEN drop view &out..&dsn;;
               quit;
                proc sort data=_tempdata_ out=&out..&dsn noduplicates;
                    by pnr kontakt_id;
                run;
                %cleanup(_tempdata_,lib=work);
                %end;
            %let i=%eval(&i+1);
            %end;
        %end;
    %if %index(&head,DIAG)>0  %then %do;
        /* DIAG */
    %let i=1;
    %do %while  (%scan(&ds_names,&i) ne );
        %let dsn=%scan(&ds_names,&i);
        %if %sysfunc(exist(&in..&dsn))  or %sysfunc(exist(&in..&dsn,VIEW)) %then %do; /* test om filen findes */
                data _tempdata1_ _tempdata_;
            set &in..&dsn;
            _void_=0;
            if diagtype="+" then do;
                diagkode_parent=diag;
                %if %varexist(&in..&dsn,tildiag) %then diag=tildiag; ;
                end;
            drop _void_
                %if %varexist(&in..&dsn,tildiag) %then  tildiag;
            ;
  	    if diagtype ne "+" or diagtype ne "H" then output _tempdata_;
            output _tempdata1_ ;
                run;
                proc sql;
                 %IF %sysfunc(exist(&in..&dsn,VIEW)) %THEN drop view &out..&dsn;;
                    create table &out..&dsn as
                        select a.*, b.diagtype as diagtype_parent
                        from _tempdata1_ a left join _tempdata_ b
                        on a.kontakt_id=b.kontakt_id and a.diagkode_parent=b.diag;
                quit;
                proc sort data=&out..&dsn noduplicates;
                    by kontakt_id;
                run;
                %cleanup(_tempdata_,lib=work);
                %cleanup(_tempdata1_,lib=work);
                %end;
            %let i=%eval(&i+1);
            %end;
        %end;
    %if %index(&head,OPR)>0 OR %index(&head,SKSUBE)>0 %then %do;
        /* SKSOPR og SKSUBE*/;
        %let i=1;
        %do %while  (%scan(&ds_names,&i) ne );
            %let dsn=%scan(&ds_names,&i);
            %if %sysfunc(exist(&in..&dsn)) or  %sysfunc(exist(&in..&dsn,VIEW)) %then %do; /* test om filen findes */
                data _tempdata_;
                set &in..&dsn;
                %if %varexist(&in..&dsn,oprart) %then %DO;
                    proctype=oprart;
                    if oprart="D" or oprart="V" then proctype="P";
                    if proctype="+" then do;
                        prockode_patent=proc;
                        %if %varexist(&in..&dsn,tilopr) %then proc=tilopr;;
                        proctype_parent="P";
                        end;
                    %END;
                shak_afs_pro=osgh||oafd;
                starttid_proc=hms(%if %varexist(&in..&dsn,OTIME) %then otime;%else 11;,
                    %if %varexist(&in..&dsn,OMINUT) %then ominut; %else 59;,0);

                drop %if %varexist(&in..&dsn,tilopr) %then tilopr;
                %if %varexist(&in..&dsn,oprart) %then oprart;
                osgh oafd %if %varexist(&in..&dsn,OTIME) %then otime;
                %if %varexist(&in..&dsn,OMINUT) %then ominut;;
                run;
                proc sql;
                %IF  %sysfunc(exist(&in..&dsn,VIEW)) %THEN drop view &out..&dsn;;
                quit;
                proc sort data=_tempdta_ out=&out..&dsn noduplicates;
                    by kontakt_id;
                run;
                %cleanup(_tempdata_);
                %end;
            %let i=%eval(&i+1);
            %end;
        %end;
%end_timer(masterdata, text=Measure time for master);
%end_log;
    %mend;
%ensretlpr2(lpr_adm   );
*%ensretlpr2(lpr_bes   );
%ensretlpr2(lpr_diag   );
%ensretlpr2(lpr_opr    );
%ensretlpr2(lpr_sksopr );
%ensretlpr2(lpr_sksube );
%ensretlpr2(priv_adm  );
%ensretlpr2(priv_diag  );
%ensretlpr2(priv_sksopr);
%ensretlpr2(priv_sksube);
%ensretlpr2(psyk_adm   );
%ensretlpr2(psyk_diag  );



