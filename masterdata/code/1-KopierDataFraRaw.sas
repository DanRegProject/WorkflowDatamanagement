/* Herfra er det datamanagement */
/* Start del 1 */

/* copy data from rawdata to workdata and if relevant generate indexes         */
/* hvis pnr indgår i datasættet så erstattes den med den nye heltals ident     */
%macro mycopy(head,in=rawdata,out=master,keep=,pnrvar=pnr,mode=data);
%start_log(&logdir, 1-KopierDataFraRaw_&head);
%start_timer(masterdata); /* measure time for this macro */
    * head: prefix på datasæt ;
    * in:   libname hvor der læses fra ;
    * out:  libname hvor data skal placeres ;
    * keep: restriktion til disse variable, option ;
    * pnrvar: variabel med personident, default pnr, option ;
%LOCAL num_vars i v l lenstr ds_names used ndel;
%LET ds_names=;
%LET head=%UPCASE(&head);
%IF %UPCASE(&test)=TRUE %THEN %LET out=WORK;
%LET in=%UPCASE(&in);
%LET out=%UPCASE(&out);

    proc sql noprint;
        select distinct memname into :ds_names separated by ' '
            from dictionary.tables
            where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and upcase(memtype)="DATA";

%IF &ds_names eq %THEN %PUT ERROR: The header/file &head does not identify any datasets;

    proc sql noprint;
        create table char_vars as select upcase(name) as name, max(length) as maxlength, min(length) as minlength
            from dictionary.columns
            where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and upcase(type)="CHAR"
            group by upcase(name)
            having minlength<maxlength
            order by name;

    data _null_;
        set char_vars end=eof;
        by name;
        length len_stmt $300;
        retain len_stmt 'length';
        if first.name;
        len_stmt = catx(' ',len_stmt, strip(name), '$', strip(maxlength)) ;
        if eof then call symput('lenstr',trim(len_stmt));
    run;
    %cleanup(char_vars,lib=work);
    %LET i=1;
    %DO %while  (%scan(&ds_names,&i) ne );
        %LET ds=%scan(&ds_names,&i);
        %IF %sysfunc(exist(&in..&ds)) %THEN %DO;

            proc sql noprint;
                select nvar into :num_vars
                    from dictionary.tables
                    where libname="&in" and upper(memname)="&ds";
                select distinct(name) into :var1-:var%trim(%left(&num_vars))
                    from dictionary.columns
                    where libname="&in" and upper(memname)="&ds";
                %sqlquit;
        %IF %varexist(&in..&ds,&pnrvar) %THEN %DO;
            proc sql;
            select count(*) into :ndel from &in..&ds where missing(strip(&pnrvar));
                %IF &ndel>0 %THEN %DO;
                    %PUT WARNING: Number of rows in &in..&ds with missing &pnrvar: &ndel..;
                %END;
            quit;
        %END;
        proc sql;
            %IF %sysfunc(exist(&out..&ds)) %THEN drop table &out..&ds;;
            %IF %sysfunc(exist(&out..&ds,VIEW)) %THEN drop view &out..&ds;;    
        quit;

        %let defpath = %sysfunc(pathname(&out))/&ds._def.sas;
        data _null_;
        file "&defpath";
        put "  data &out..&d";
        %IF %UPCASE(&mode)=VIEW %THEN put "/ view=&out..&ds";;
        put ";";
        put "&lenstr.;";
        put "set &in..&ds(";
                    %IF %UPCASE(&test)=TRUE %THEN put " obs=10000";;
                    %IF &pnrvar ne pnr %THEN put "rename=(&pnrvar=pnr)";;
                    %IF &keep ne %THEN put "keep=&pnrvar &keep";;
        put ")";
        put ";";
        %IF %varexist(&in..&ds,&pnrvar) %THEN %DO;
            put "if missing(strip(pnr)) then delete;";
        %END;
                    /* omdøb alle variable som har et foranstillet type indikator fx C_, D_  */
                    /* fjern variabeltype indikatorer som DS bruger på især LPR2 variable */
        %LET used=;
        %DO v=1 %to &num_vars;
            %LET l=%length(&&var&v);
            %IF "%substr(&&var&v,1,2)"="C_" OR
                "%substr(&&var&v,1,2)"="D_" OR
                "%substr(&&var&v,1,2)"="V_"
                %THEN %DO;
                    %IF %SYSFUNC(INDEXW(&used,%substr(&&var&v,3,%eval(&l-2))))=0 %THEN %DO;
                        put "rename &&var&v = %substr(&&var&v,3,%eval(&l-2));";
                        %LET used = &used %substr(&&var&v,3,%eval(&l-2));
                    %END;
                %END;
            %END;
            put "run;";
            run;
            %include "&defpath";
            %END;
            %LET i=%eval(&i+1);
        %END;
        
%END_timer(masterdata, text=Measure time for master);
%END_log;
    %mend;

%let mode=view;
options compress=YES;
%mycopy(population_,in=popdata,mode=&mode);
*%mycopy(akm,mode=&mode);
%mycopy(bef,mode=&mode);
%mycopy(dod2023,mode=&mode);
%mycopy(dodsaasg,mode=&mode);
%mycopy(faik,mode=&mode);
%mycopy(lmdb,keep=eksd vnr apk indo doso atc volume strnum packsize patt korr rimb,mode=&mode);
%mycopy(lpr_adm,mode=&mode);
*%mycopy(lpr_bes,mode=&mode);
%mycopy(lpr_diag,mode=&mode);
%mycopy(lpr_opr,mode=&mode);
%mycopy(lpr_sksopr,mode=&mode);
%mycopy(lpr_sksube,mode=&mode);
%mycopy(priv_adm,mode=&mode);
%mycopy(priv_diag,mode=&mode);
%mycopy(priv_sksopr,mode=&mode);
%mycopy(priv_sksube,mode=&mode);
%mycopy(psyk_adm,mode=&mode); 
%mycopy(psyk_diag,mode=&mode);
%mycopy(lpr_f_diagnoser,mode=&mode);
%mycopy(lpr_f_kontakter,mode=&mode);
*%mycopy(lpr_f_forloeb,mode=&mode);
*%mycopy(lpr_f_helbredsforloeb,mode=&mode);
*%mycopy(lpr_f_forloebsmarkoerer,mode=&mode);
%mycopy(lpr_f_resultater,mode=&mode);
%mycopy(lpr_f_procedurer_andre,mode=&mode);
%mycopy(lpr_f_procedurer_kirurgi,mode=&mode);
%mycopy(lpr_f_organisationer,mode=&mode);
%mycopy(uddf,mode=&mode);
%mycopy(vnds,mode=&mode);
*%mycopy(sssy,mode=&mode);
*%mycopy(sysi,mode=&mode);

*%mycopy(dimcancergruppering_icd10,in=rawext,mode=&mode);
*%mycopy(dimpatologiskdiagnose,in=rawext,mode=&mode);
*%mycopy(fctpatologiskprocedure,in=rawext,mode=&mode);
*%mycopy(fctrekvisition,in=rawext,pnrvar=cprnummer,mode=&mode);

*%mycopy(,in=rawext,pnrvar=cprnummer,mode=&mode);

%mycopy(indberetningmedpris,in=extdata2,pnrvar=v_cpr,keep=d_adm d_kontakt_start d_ord_slut d_ord_start c_varenummer c_indikation_kode v_adm_dosis c_atc v_styrke_num v_styrke_enhed,mode=&mode);
%mycopy(lab_dm_forsker,in=extdata2,pnrvar=patient_cpr,mode=&mode);
%mycopy(lab_dm_labidcodes,in=extdata2,mode=&mode);
%mycopy(lab_dm_optaelling,in=extdata2,mode=&mode);
%mycopy(mfr,in=extdata2,pnrvar=cpr_moder,mode=&mode);
%mycopy(nyfoedte,in=extdata2,pnrvar=cprnummer_mor,mode=&mode);
*%mycopy(tumor_aarlig,in=rawext,pnrvar=cprnummer,mode=&mode);









