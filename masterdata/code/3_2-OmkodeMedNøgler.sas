
/* Anden del 3 */
%start_log(&logdir, 3_2-OmkodeMedNøgler);
%start_timer(masterdata); /* measure time for this macro */

/* De dannede nøgler appliceres på alle de relevante tabeller hvor variablen indgår */
%macro applykey(head,ident,in=master,out=master);
    * head: prefix på datasæt ;
    * ident: variabel med ident;
    * in:   libname hvor der læses fra, option ;
    * out:  libname hvor der skrives til, option ;
%local i dsn;
%if %upcase(&test)=TRUE %then %let in=WORK;
%if %upcase(&test)=TRUE %then %let out=WORK;
%let head=%upcase(&head);
%let postfix=;
%if %index(&head,&LPR3grp)>0 %then %let postfix=&LPR3grp;
%if %index(&head,LPR_)>0 and %index(&head,LPR_F)=0 %then %let postfix=lpr;
%if %index(&head,PRIV)>0 %then %let postfix=priv;
%if %index(&head,PSYK)>0 %then %let postfix=psyk;

%if %sysfunc(exist(&in..key&postfix.&ident)) %then %do; /* test om filen findes */
        proc sql noprint;
    select distinct memname into :ds_names separated by ' '
        from dictionary.tables
        where libname=upcase("&in") and index(memname,upcase("&head"))>0 and upcase(memtype)="DATA";
    %let i=1;
    %do %while  (%scan(&ds_names,&i) ne );
        %let dsn=%scan(&ds_names,&i);
        %if %sysfunc(exist(&in..&dsn)) %then %do; /* test om filen findes */;
            %if %varexist(&in..&&dsn,&ident) %then %do; /* evt sortere efter personident */;
                    proc sort data=&in..&dsn out=_tempdata_;
                        by &ident;
                    run;
                    Data &out..&dsn(rename=(ny&ident=&ident));
                        _Nudenid_=0;
                        retain _Nudenid_;
                        merge _tempdata_(in=a) &in..key&postfix.&ident(in=b);
                        by &ident;
                        drop &ident _Nudenid_;
                        if a;
                        if a and not b then _Nudenid_+1;
                        call symput('Nudenid',_Nudenid_);
                    run;
                    %if &Nudenid>0 %then %put WARNING: &Nudenid rækker uden ident i &in..key&postfix.&ident!;

                    %end;
                %else %put ERROR: Identen &ident findes ikke i datasættet &in..&dsn;
                %end;
            %else %put ERROR: Datasættet &in..&dsn findes ikke ;
            %let i=%eval(&i+1);
            %end;
        %end;
    %else %put ERROR: Nøgle datasættet &in..key&postfix.&ident findes ikke ;
    %mend;
/* familie_id */
%applykey(bef          ,familie_id);
%applykey(faik         ,familie_id);
/* kontakt_id lpr2 */
%applykey(lpr_adm      ,kontakt_id);
%applykey(lpr_bes      ,kontakt_id);
%applykey(lpr_diag     ,kontakt_id);
*%applykey(lpr_opr     ,kontakt_id);
%applykey(lpr_sksopr   ,kontakt_id);
%applykey(lpr_sksube   ,kontakt_id);
%applykey(priv_adm     ,kontakt_id);
%applykey(priv_diag    ,kontakt_id);
%applykey(priv_sksopr  ,kontakt_id);
%applykey(priv_sksube  ,kontakt_id);
%applykey(psyk_adm     ,kontakt_id);
%applykey(psyk_diag    ,kontakt_id);
/* forloeb_id - lpr3 */
%applykey(lpr_f_forloeb,   forloeb_id);
%applykey(lpr_f_kontakter, forloeb_id);
%applykey(lpr_f_resultater,forloeb_id);
%applykey(lpr_f_procedurer_andre,forloeb_id);
%applykey(lpr_f_procedurer_kirurgi,forloeb_id);
/* kontakt_id lpr3 */
%applykey(lpr_f_diagnoser,kontakt_id);
%applykey(lpr_f_kontakter,kontakt_id);
%applykey(lpr_f_resultater,kontakt_id);
%applykey(lpr_f_procedurer_andre,kontakt_id);
%applykey(lpr_f_procedurer_kirurgi,kontakt_id);
%end_timer(masterdata, text=Measure time for master);
%end_log;
