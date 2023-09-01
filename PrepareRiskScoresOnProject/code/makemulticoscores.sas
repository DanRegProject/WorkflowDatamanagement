/* SVN header
$Date: 2018-12-17 17:29:57 +0100 (ma, 17 dec 2018) $
$Revision: 25 $
$Author: fskFleSkj $
$ID: $
*/
%macro makemulticoTables(score);
  %start_log(&logdir, &score, option=new );
  %start_timer(&score);

  %MakemulticoTable(&score);

  %end_timer(&score, text=execution time getting all &score tables from scratch );
  %end_log;
%mend;

%macro MakemulticoTable(score);
%local U I;

  %if %symexist(LPR&score.N) %then %do;
    %do I = 1 %to &&LPR&score.N;
       %let name = &score.&I;

      %if &&LPR&score.&I ne %then %getDiag(work, &name, ICD8=TRUE
          %if %symexist(LPR&score.&I.C) %then , &&LPR&score.&I.C; );;
    %end;
  %end;

%ReduceLPRmulticoTables(&score);

/* noget tilsvarende for ATC koder her */

/* CPR og OTH kriterier inkluderes i den endelige beregningsrutine multicoscore.sas */
%mend;

%macro ReduceLPRmulticoTables(score);
%local U I sets name recn;

  %if %symexist(LPR&score.N) %then %do;
    %do I = 1 %to &&LPR&score.N;
       %let name = LPR&score.&I;
       %if &&LPR&score.&I ne %then %do; /* avoid components with no definition */

      /* sort and keep lines regardless of pattype and diagtype
	     (e.g. remove all dublicates with same in- and outdate but different pattype) */
	  proc sort data=work.LPR&score.&I.all nodupkey out=work.&score.&I._red;
	  where &projectdate between rec_in and rec_out;
	    by pnr indate outdate;
	  %runquit;

          %smoothhosp(work.&score.&I._red,work.&score.&I._red,ajour=&projectdate);
          data work.&score.&I._red;
              set work.&score.&I._red;
                /* set weight to the diagnosis corresponding weight */;
                weight = &&LPR&score.&I.W;;
                %let recn=;
                length outcome $20. label $50.;
                outcome="&name";
                label=&&LPRL&score.&I;

            %if &update=TRUE %then %let recn=1;;
            rec_in&recn=&projectdate;
            rec_out&recn=&globalend;
            format rec_in&recn rec_out&recn date.;
            rename hosp_in= indate hosp_out=outdate;
            %if &update=TRUE %then id = catx(" ",of outcome hosp_in hosp_out weight);;
            keep pnr outcome label hosp_in hosp_out weight rec_in&recn rec_out&recn %if &update=TRUE %then id;;
            %runquit;
	  proc sort data=work.&score.&I._red;
	    by pnr %if &update=TRUE %then id; outcome indate outdate;
	  %runquit;

          %if &update=TRUE %then %do;
            data work.base&score.&I._red;
                set mcolib.LPR&score;
                where outcome="&name";
                id=catx(" ", of outcome indate outdate weight);
                %runquit;
            proc sort data=work.base&score.&I._red;
                by pnr %if &update=TRUE %then id; outcome indate outdate;
                %runquit;
            data work.&score.&I._red;
                merge  work.&score.&I._red(in=a) work.base&score.&I._red(in=b);
                by pnr id;
                if b and not a and rec_out>&projectdate then rec_out=&projectdate-1;
                if a and not b then do; rec_out=rec_out1; rec_in=rec_in1; end;
                    drop rec_in1 rec_out1 id;
            run;
            proc sort data=work.&score.&I._red;
                by pnr outcome indate outdate rec_in rec_out;
                %runquit;
                %end;

/*
        data mcolib.&score.&I._red;
            set work.&score.&I._red;
                %runquit;
*/
            %let sets = &sets  work.&score.&I._red;
            %end;
  %end;
%end;

data Mcolib.LPR&score;
  set &sets;
	  by pnr outcome;
	  if pnr ne "";
  run;
/*
%if %symexist(LPR&score.00W) %then %do;
    proc sort data=Mcolib.&score out=&score.int nodupkey;
        by pnr rec_in rec_out;
        %runquit;
        data &score.int; set &score.int;
            by pnr;
            outcome="Intercept";
            weight=&&LPR&score.00W;
            indate=.;outdate=.;
            %runquit;
            data mcolib.&score; set mcolib.&score &score.int;
                %runquit;
                %end;
*/
proc sort data=Mcolib.LPR&score;
   by pnr outcome indate outdate rec_in rec_out weight;
  %runquit;

%mend;

