/* Herfra er det datamanagement */
/* Start del 2.1 */
%MACRO insertline(file,line);
	%let line = %UPCASE((&line);
	%let tempfile = %SYSFUNC(pathname(work))/mydef_tmp.sas;
	data _null_;
		infile "&file" lrecl=32767;
		length line $32767;
		retain inserted 0;
		input;
		line=upcase(_infile_);
		/* check if new line is change of an existing RENAME statement */
		if scan(line,1)="RENAME" and scan(line,1)=scan("&line",1) and scan(line,4)=scan("&line",2)
		then do;
			line = tranwrd("&line ;",scan("&line",2),scan(line,2));
			inserted=1;
		end;
		/* new lines are inserted just before RUN; */
		if strip(line)='RUN;' and not inserted then do;
			put " &line ;";
			inserted =1;
		end;
		put line;
	run;
	data _null_;
		infile "&tempfile" lrecl=32767;
		file "&file";
		input;
		put _infile_;
	run;
%MEND;

%macro ensretvar(head,old,new,in=master,mode=data);
%start_log(&logdir, 2_1-EnsretVariable&head);
%start_timer(masterdata); /* measure time for this macro */
    * head: prefix på datasæt ;
    * old: liste af variabelnavne der skal omdøbes;
    * new: liste af nye variabelnavne;
    * in:   libname hvor der læses fra, option ;
%local i j var dsn ds_names;
%if %upcase(&test)=TRUE %then %let in=WORK;
%LET head=%UPCASE(&head);
%if %sysfunc(countw(&old)) ne %sysfunc(countw(&new)) %then %put ERROR: Antal variabelnavne er ikke ens;
%else %do;
        proc sql noprint;
            select distinct memname into :ds_names separated by ' '
                from dictionary.tables
                where libname=upcase("&in") and prxmatch("/^&head.([^A-Za-z]|$)/", memname) > 0 and upcase(memtype)=upcase("&mode");
            %let i=1;
            %do %while  (%scan(&ds_names,&i) ne );
                %let dsn=%scan(&ds_names,&i);

				%IF %UPCASE(&mode)=VIEW %THEN %LET defpath=%sysfunc(pathname(&in))/&dsn._def.sas;
				%do j=1 %to %sysfunc(countw(&old));
                        %let var=%scan(&old,&j);
                /*        %if %varexist(&in..&dsn,&var) %then %do;*/ /* evt sortere efter personident */
						%IF %UPCASE(&mode)=DATA %THEN %DO;
	                        proc datasets nolist lib=&in;
	                            modify &dsn;
	                            rename &var = %scan(&new,&j);
	                        run;
	                        quit;
                        %end;
						%IF %UPCASE(&mode)=DATA %THEN %DO;
							%insertline(&defpath,rename &var = scan(&new,&j));
	                    %END;
                  /*  %else %put WARNING: Variablen %scan(&old,&j) findes ikke i datasættet &in..&dsn;
                    %end;*/
                %end;
				%if %UPCASE(&mode)=VIEW %THEN %DO; 
					%include "&defpath"; 
				%END;
	            %let i=%eval(&i+1);
            %end;
        %end;
	%end_timer(masterdata, text=Measure time for master);
	%end_log;
%mend;
%let mode=view;
%ensretvar(lpr_adm,   RECNUM  inddto  uddto spec sghamt sgh afd sex kontaars indm hsgh hafd hendto henm opdatdto,
		      kontakt_id start slut hovedspeciale_ans region_ans shak_sgh_ans shak_afd_ans koen kontaktaarsag prioritet shak_sgh_hen shak_afd_hen dato_henvisning henvisningsmaade dato_indberetning_start,mode=&mode);
*%ensretvar(lpr_bes,  recnum  , kontakt_id,mode=&mode);
%ensretvar(lpr_diag,  recnum  version, kontakt_id version_diag,mode=&mode);
%ensretvar(lpr_opr,   recnum  , kontakt_id,mode=&mode);
%ensretvar(lpr_sksopr,recnum version opr odto ,kontakt_id  version_proc proc start_proc ,mode=&mode);
%ensretvar(lpr_sksube,recnum version opr odto,kontakt_id  version_proc proc start_proc,mode=&mode);
%ensretvar(priv_adm,  recnum inddto uddto, kontakt_id start slut,mode=&mode);
%ensretvar(priv_diag, recnum version, kontakt_id version_diag,mode=&mode);
%ensretvar(priv_sksopr,recnum version opr odto,kontakt_id version_proc  proc start_proc,mode=&mode);
%ensretvar(priv_sksube,recnum version opr odto,kontakt_id version_proc proc start_proc,mode=&mode);
%ensretvar(psyk_adm,   recnum  inddto  uddto, kontakt_id start slut,mode=&mode);
%ensretvar(psyk_diag,  recnum  version , kontakt_id version_diag,mode=&mode);
%ensretvar(lpr_f_diagnoser,dw_ek_kontakt diagnosekode diagnosetype diagnosekode_parent diagnosetype_parent,
          kontakt_id diag diagtype diagkode_parent diagtype_parent,mode=&mode);
%ensretvar(lpr_f_kontakter,dw_ek_kontakt dato_start dato_slut tidspunkt_start tidspunkt_slut aktionsdiagnose dw_ek_forloeb,
                           kontakt_id start slut starttid sluttid adiag forloeb_id,mode=&mode);
*%ensretvar(lpr_f_forloeb,  dw_ek_forloeb dw_ek_helbredsforloeb ,forloeb_id helbredsforloeb_id,mode=&mode);
*%ensretvar(lpr_f_helbredsforloeb,dw_ek_forloeb dw_ek_helbredsforloeb ,forloeb_id helbredsforloeb_id,mode=&mode);
*%ensretvar(lpr_f_forloebsmarkoerer,dw_ek_forloeb ,forloeb_id,mode=&mode);
%ensretvar(lpr_f_resultater,dw_ek_kontakt dw_ek_forloeb  ,kontakt_id forloeb_id,mode=&mode);
%ensretvar(lpr_f_procedurer_andre,
    dw_ek_kontakt procedurekode dato_start dato_slut tidspunkt_start tidspunkt_slut proceduretype procedurekode_parent proceduretype_parent dw_ek_forloeb,
    kontakt_id  proc start_proc slut_proc startid_proc sluttid_proc proctype prockode_parent proctype_parent forloeb_id,mode=&mode);
%ensretvar(lpr_f_procedurer_andre,dato_henvisning tidspunkt_henvisning,dato_henvisning_proc tidspunkt_henvisning_proc,mode=&mode);
%ensretvar(lpr_f_procedurer_kirurgi,dw_ek_kontakt procedurekode dato_start proceduretype procedurekode_parent proceduretype_parent dw_ek_forloeb, kontakt_id  proc start_proc proctype prockode_parent proctype_parent forloeb_id,mode=&mode);
%ensretvar(lpr_f_procedurer_kirurgi,dato_henvisning tidspunkt_henvisning,dato_henvisning_proc tidspunkt_henvisning_proc,mode=&mode);







