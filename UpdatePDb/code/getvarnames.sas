%macro getvar(tab);
proc sql noprint inobs=100;
create table work.tab as select * from IN01220.&tab ;
select distinct name into:varlist separated by ' '
from sashelp.vcolumn
where libname='WORK' and memname='TAB';
%put &tab;
%put &varlist;
%mend;
%getvar(LPR3_SB_DIAGNOSE);
%getvar(LPR3_SB_DIAGNOSE_TILLAEG);
%getvar( LPR3_SB_FORLOEBELEMENT);
%getvar(  LPR3_SB_FORLOEBMARKOER);
%getvar( LPR3_SB_KONTAKT);
%getvar( LPR3_SB_METASTASER);
%getvar(  LPR3_SB_OPHOLDSADRESSE);
%getvar(  LPR3_SB_PROCEDURER);
%getvar(   LPR3_SB_PROCEDURER_TILLAEG);
%getvar(   LPR3_SB_RESULTATER);
%getvar(LPR3_SB_SKSKODE);
 %getvar(  LPR3_SB_SOR_COMPLETE);
