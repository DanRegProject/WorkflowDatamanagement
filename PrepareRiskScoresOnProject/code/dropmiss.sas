%macro dropmiss(indata,outdata,nodrop);

%local I;

proc contents data = &indata ( drop=&nodrop ) memtype = data noprint out = _cntnts_ (keep = name type ) ;
run;

%let N_Char = 0;
%let N_Num = 0;

data _null_;
	set _cntnts_ end = lastobs nobs = nobs;

	if nobs = 0 then stop;

	n_char + ( type = 2) ;
	n_num + ( type = 1) ;

	if lastobs
	then do;
		call symput( 'N_Char' , left (put (n_char, 5.)));
		call symput( 'N_Num' , left (put (n_num, 5.)));
	end;
run;

%if %eval (&N_Num + &N_Char) = 0
%then %do ;
	%put /----------------------------------------------\;
	%put | Error from dropmiss:                         |;
	%put | No variables in dataset                      |;
	%put | Execution termination forthwith              |;
	%put \----------------------------------------------/;

	%goto L9999 ;
%end;

%let NUM0 = 0;
%let CHAR0 = 0;

%if &N_Num > 0 %then %do;
	%do I = 1 %to &N_Num;
		%global NUM&I;
	%end;
%end;

%if &N_Char > 0 %then %do;
	%do I = 1 %to &N_Char;
		%global Char&I;
	%end;
%end;

proc sql noprint ;
%if &N_Char > 0 %then %str( select name into :CHAR1 - :CHAR&N_Char from _cntnts_ where type = 2 ; ) ;
%if &N_Num > 0 %then %str( select name into :NUM1 - :NUM&N_Num from _cntnts_ where type = 1 ; ) ;
quit;


%IF &N_Char > 1 %then %do;
	%let N_CHAR_1 = %eval(&N_Char - 1);
%end;

proc sql noprint;
	select %do I = 1 %to &N_Num; max(&&NUM&I) , %end ; %if &N_Char > 1 %then %do;
			%do I = 1 %to &N_CHAR_1; max(&&CHAR&I), %end ; %end; max(&&CHAR&N_Char) into
			%do I = 1 %to &N_Num; : NUMMAX&I , %end; %if &N_Char > 1 %then %do ;
			%do I = 1 %to &N_CHAR_1; :CHARMAX&I, %end; %end; : CHARMAX&N_Char
			from &indata;
quit;

%let DROP_NUM = ;
%let DROP_CHAR = ;

%if &N_Num > 0 %then %do;
data _null_;
	%do I = 1 %to &N_Num;
		%if &&NUMMAX&I = . %then %do;
			%let DROP_NUM = &DROP_NUM %qtrim( &&NUM&I );
		%end;
	%end;
run;

%end;

%if &N_Char > 0 %then %do;
data _null_;
	%do I = 1 %to &N_Char;
		%if "%qtrim(&&CHARMAX&I)" eq "" %then %do;
			%let DROP_CHAR = &DROP_CHAR %qtrim(&&CHAR&I) ; 
		%end;
	%end;
run;
%end;

data &outdata;
%if &DROP_CHAR ^= %then %str(drop &DROP_CHAR ; ) ;
%if &DROP_NUM ^= %then %str(drop &DROP_NUM ; ) ;

set &indata;
run;

%L9999: 

%mend DROPMISS;
