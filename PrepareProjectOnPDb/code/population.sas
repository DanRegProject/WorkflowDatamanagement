/* FSEID0000XXXX population */
/* end result is a table "population", stored in the popdat library */

/*%include "&globalmacropath/getmedi.sas";*/
/*%include "&globalmacropath/nonrep.sas";*/

/* population 1 */
%let ATCinmedi = &population1;
%put &lastyr;
%getMedi(work, inmedi, basepop=population1,fromyear=1994);

proc sort data=work.population1(keep=pnr rec_in rec_out);
	by pnr;
%runquit;
* The population table is updated with record on when the id is included in the source population;
%macro join;
	data &pop;
		set work.population1(in=a
				 where=(pnr ne "" and rec_in <=  &Last_DataUpdate and &Last_DataUpdate<rec_out))
		%if %sysfunc(exist(&pop)) %then &pop/*(in=b)*/
		;;
		by pnr;
		if a then ajour=&Last_DataUpdate;
		keep pnr ajour;     /* keep only pnr */
	%runquit;
	proc sort data=&pop;
		by pnr ajour;
	%runquit;
	data &pop;
		set &pop;
		by pnr;
		if first.pnr;
	%runquit;
%mend;
%join;

