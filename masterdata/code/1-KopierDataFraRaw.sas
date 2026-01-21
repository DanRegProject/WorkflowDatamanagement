/* Herfra er det datamanagement */
/* Start del 1 */
%start_log(&logdir, 1-KopierDataFraRaw);
%start_timer(masterdata); /* measure time for this macro */

/* Dan ny integer nøgle til erstatning af pnr */
proc sort data=&studiepop out=work._sortedpop_ nodupkey;
    by pnr;
run;
data master.keyPNR; set work._sortedpop_;
    nypnr=_N_;
run;

/* copy data from rawdata to workdata and if relevant generate indexes         */
/* hvis pnr indgår i datasættet så erstattes den med den nye heltals ident     */
%macro mycopy(head,in=rawdata,out=master,keep=,pnrvar=pnr);
    * head: prefix på datasæt ;
    * in:   libname hvor der læses fra ;
    * out:  libname hvor data skal placeres ;
    * keep: restriktion til disse variable, option ;
    * pnrvar: variabel med personident, default pnr, option ;
%LOCAL num_vars i v l lenstr ds_names used;
%LET ds_names=;
%LET head=%UPCASE(&head);
%IF %UPCASE(&test)=TRUE %THEN %LET out=WORK;

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
    %LET i=1;
    %DO %while  (%scan(&ds_names,&i) ne );
        %LET ds=%scan(&ds_names,&i);
        %IF %sysfunc(exist(&in..&ds)) %THEN %DO;
            data _tempdata_;
                &lenstr.;
                set &in..&ds(
                    %IF %UPCASE(&test)=TRUE %THEN obs=10000;)
                ;
            run;
            %IF %varexist(&in..&ds,&pnrvar) %THEN %DO;
                proc sort data=_tempdata_ out=_tempdata_(
                    %IF &pnrvar ne pnr %THEN rename=(&pnrvar=pnr);
                    %IF &keep ne %THEN keep=&pnrvar &keep;) noduplicates;
                    by &pnrvar;
                run;
                %END;

                        /* omdøb alle variable som har et foranstillet type indikator fx C_, D_  */
                        /* fjern variabeltype indikatorer som DS bruger på især LPR2 variable */
            proc sql noprint;
                select nvar into :num_vars
                    from dictionary.tables
                    where libname="WORK" and upper(memname)="_TEMPDATA_";
                select distinct(name) into :var1-:var%trim(%left(&num_vars))
                    from dictionary.columns
                    where libname="WORK" and upper(memname)="_TEMPDATA_";
                %sqlquit;
            %LET used=;
            proc datasets library=work nolist;
                modify _tempdata_;
                %DO v=1 %to &num_vars;
                    %LET l=%length(&&var&v);
                    %IF "%substr(&&var&v,1,2)"="C_" OR
                        "%substr(&&var&v,1,2)"="D_" OR
                        "%substr(&&var&v,1,2)"="V_"
                        %THEN %DO;
                            %IF %INDEX(&used,%substr(&&var&v,3,%eval(&l-2)))=0 %THEN %DO;
                                rename &&var&v = %substr(&&var&v,3,%eval(&l-2));
                                %LET used = &used %substr(&&var&v,3,%eval(&l-2));
                            %END;
                        %END;
                    %END;
                ;
            quit; run;
                        /* Erstat pnr med heltalsløbenummer fra keyPNR */
            %LET Nudenid = 0;
            Data &out..&ds;
                %IF %varexist(_tempdata_,pnr) %THEN %DO; /* erstat personident hvis relevant */
                if _N_ =1 then _Nudenid_=0;
                    retain _Nudenid_;
                    merge _tempdata_(in=b) master.keyPNR(in=a);
                    by pnr;
                    drop pnr;
                    rename nypnr=pnr;
                    if b;
                    if b and not a and first.pnr then _Nudenid_+1;
                    call symput('Nudenid',_Nudenid_);
                    drop _Nudenid_;
                    %END;
                %else
                    set _tempdata_;;
            run;
            %IF &Nudenid>0 %THEN %put WARNING: &Nudenid rækker uden ident i master.keyPNR!;
            %END;
            %else %put ERROR: The file &in..&ds does not exist;
            %LET i=%eval(&i+1);
        %END;
    %mend;

options compress=YES;
%mycopy(population_,in=popdata);
*%mycopy(akm);
%mycopy(bef);
%mycopy(dod2023);
%mycopy(dodsaasg);
%mycopy(faik);
%mycopy(lmdb,keep=eksd vnr apk indo doso atc volume strnum packsize patt korr rimb);
%mycopy(lpr_adm);
*%mycopy(lpr_bes);
%mycopy(lpr_diag);
%mycopy(lpr_opr);
%mycopy(lpr_sksopr);
%mycopy(lpr_sksube);
%mycopy(priv_adm);
%mycopy(priv_diag);
%mycopy(priv_sksopr);
%mycopy(priv_sksube);
%mycopy(psyk_adm); /*psyk_adm fejlleveret som årstabeller 2002-2018*/
%mycopy(psyk_diag);
%mycopy(lpr_f_diagnoser);
%mycopy(lpr_f_kontakter);
*%mycopy(lpr_f_forloeb);
*%mycopy(lpr_f_helbredsforloeb);
*%mycopy(lpr_f_forloebsmarkoerer);
%mycopy(lpr_f_resultater);
%mycopy(lpr_f_procedurer_andre);
%mycopy(lpr_f_procedurer_kirurgi);
%mycopy(lpr_f_organisationer);
%mycopy(uddf;
%mycopy(vnds);
*%mycopy(sssy);
*%mycopy(sysi);

*%mycopy(dimcancergruppering_icd10,in=rawext);
*%mycopy(dimpatologiskdiagnose,in=rawext);
*%mycopy(fctpatologiskprocedure,in=rawext);
*%mycopy(fctrekvisition,in=rawext,pnrvar=cprnummer);

*%mycopy(,in=rawext,pnrvar=cprnummer);

%mycopy(indberetningmedpris,in=extdata2,pnrvar=v_cpr,keep=d_adm d_kontakt_start d_ord_slut d_ord_start c_varenummer c_indikation_kode v_adm_dosis c_atc v_styrke_num v_styrke_enhed);
%mycopy(lab_dm_forsker,in=extdata2,pnrvar=patient_cpr);
%mycopy(lab_dm_labidcodes,in=extdata2);
%mycopy(lab_dm_optaelling,in=extdata2);
%mycopy(mfr,in=extdata2,pnrvar=cpr_moder);
%mycopy(nyfoedte,in=extdata2,pnrvar=cprnummer_mor);
*%mycopy(tumor_aarlig,in=rawext,pnrvar=cprnummer);

%END_timer(masterdata, text=Measure time for master);
%END_log;





