/* Herfra er det datamanagement */
/* Start del 2.1 */
%start_log(&logdir, 2_1-EnsretVariable);
%start_timer(masterdata); /* measure time for this macro */
%macro ensretvar(head,old,new,in=master);
    * head: prefix på datasæt ;
    * old: liste af variabelnavne der skal omdøbes;
    * new: liste af nye variabelnavne;
    * in:   libname hvor der læses fra, option ;
%local i j var dsn;
%if %upcase(&test)=TRUE %then %let in=WORK;

%if %sysfunc(countw(&old)) ne %sysfunc(countw(&new)) %then %put ERROR: Antal variabelnavne er ikke ens;
%else %do;
        proc sql noprint;
            select distinct memname into :ds_names separated by ' '
                from dictionary.tables
                where libname=upcase("&in") and index(memname,upcase("&head"))>0 and upcase(memtype)="DATA";
            %let i=1;
            %do %while  (%scan(&ds_names,&i) ne );
                %let dsn=%scan(&ds_names,&i);
                %if %sysfunc(exist(&in..&dsn)) %then %do;
                    %do j=1 %to %sysfunc(countw(&old));
                        %let var=%scan(&old,&j);
                        %if %varexist(&in..&dsn,&var) %then %do; /* evt sortere efter personident */
                        proc datasets nolist lib=&in;
                            modify &head.&i;
                            rename &var = %scan(&new,&j);
                        run;
                        quit;
                        %end;
                    %else %put WARNING: Variablen %scan(&old,&j) findes ikke i datasættet &in..&dsn;
                    %end;
                %end;
            %else %put ERROR: Datasættet &in..&dsn findes ikke ;
            %let i=%eval(&i+1);
            %end;
        %end;
    %mend;

%ensretvar(lpr_adm,   RECNUM  inddto  uddto spec sghamt sgh afd sex kontaars indm hsgh hafd hendto henm opdatdto,
		      kontakt_id start slut hovedspeciale_ans region_ans shak_sgh_ans shak_afd_ans koen kontaktaarsag prioritet shak_sgh_hen shak_afd_hen dato_henvisning henvisningsmaade dato_indberetning_start);
*%ensretvar(lpr_bes,  recnum  , kontakt_id);
%ensretvar(lpr_diag,  recnum  version, kontakt_id version_diag);
%ensretvar(lpr_opr,   recnum  , kontakt_id);
%ensretvar(lpr_sksopr,recnum version opr odto ,kontakt_id  version_proc proc start_proc );
%ensretvar(lpr_sksube,recnum version opr odto,kontakt_id  version_proc proc start_proc);
%ensretvar(priv_adm,  recnum inddto uddto, kontakt_id start slut);
%ensretvar(priv_diag, recnum version, kontakt_id version_diag);
%ensretvar(priv_sksopr,recnum version opr odto,kontakt_id version_proc  proc start_proc);
%ensretvar(priv_sksube,recnum version opr odto,kontakt_id version_proc proc start_proc);
%ensretvar(psyk_adm,   recnum  inddto  uddto, kontakt_id start slut);
%ensretvar(psyk_diag,  recnum  version , kontakt_id version_diag);
%ensretvar(lpr_f_diagnoser,dw_ek_kontakt diagnosekode diagnosetype diagnosekode_parent diagnosetype_parent,
          kontakt_id diag diagkode_parent diagtype_parent);
%ensretvar(lpr_f_kontakter,dw_ek_kontakt dato_start dato_slut tidspunkt_start tidspunkt_slut aktionsdiagnose dw_ek_forloeb,
                           ontakt_id start slut starttid sluttid adiag forloeb_id);
*%ensretvar(lpr_f_forloeb,  dw_ek_forloeb dw_ek_helbredsforloeb ,forloeb_id helbredsforloeb_id);
*%ensretvar(lpr_f_helbredsforloeb,dw_ek_forloeb dw_ek_helbredsforloeb ,forloeb_id helbredsforloeb_id);
*%ensretvar(lpr_f_forloebsmarkoerer,dw_ek_forloeb ,forloeb_id);
%ensretvar(lpr_f_resultater,dw_ek_kontakt dw_ek_forloeb  ,kontakt_id forloeb_id);
%ensretvar(lpr_f_procedurer_andre,
    dw_ek_kontakt procedurekode dato_start dato_slut tidspunkt_start tidspunkt_slut proceduretype procedurekode_parent proceduretype_parent dw_ek_forloeb,
    kontakt_id  proc start_proc slut_proc startid_proc sluttid_proc proctype prockode_parent proctype_parent forloeb_id);
%ensretvar(lpr_f_procedurer_andre,dato_henvisning tidspunkt_henvisning,dato_henvisning_proc tidspunkt_henvisning_proc);
%ensretvar(lpr_f_procedurer_kirurgi,dw_ek_kontakt procedurekode dato_start proceduretype procedurekode_parent proceduretype_parent dw_ek_forloeb, kontakt_id  proc start_proc proctype prockode_parent proctype_parent forloeb_id);
%ensretvar(lpr_f_procedurer_kirurgi,dato_henvisning tidspunkt_henvisning,dato_henvisning_proc tidspunkt_henvisning_proc);

%end_timer(masterdata, text=Measure time for master);
%end_log;



