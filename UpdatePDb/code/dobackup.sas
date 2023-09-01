proc printto log="f:/Projekter/PDB0000YYYY/MasterRawCode/log/dobackup.log" new;
run;
%let bdate=%sysfunc(today(),date.);
%put &bdate;
options dlcreatedir;

libname brawdata "V:\Projekter\PDB0000YYYY\BackupData\MasterData\raw"; /* Backup library*/
libname rawOrg     "F:\Projekter\PDB0000YYYY\MasterData/raw";          /* Master tables  */
/* create sub library with todays date */
libname obackraw "V:\Projekter\PDB0000YYYY\BackupData\MasterData\raw\&bdate";

/* get list of datasets in master and backup libraries*/
ods output members=rawfiles;
proc datasets library=raworg memtype=data;
run;
quit;
ods output members=brawfiles;
proc datasets library=brawdata memtype=data;
run;
quit;

proc sql;
/* identify datasets that has been altered since last backup */
create table changes as
select a.name from
brawfiles a, rawfiles b
where a.name=b.name and a.lastModified ne b.lastModified;
/* identify datasets that has been added since last backup */
create table new as
select b.name from
 rawfiles b
where b.name not in (select a.name from brawfiles a);
quit;

/* create macro variables with the relevant dataset names */
data _null_;
set new;
new=cats('var',put(_n_,3.));
call symput(new,name);
call symput('Nnew',_n_);
*put name new;
run;
data _null_;
set changes;
cha=cats('cha',put(_n_,3.));
call symput(cha,name);
call symput('Ncha',_n_);
*put name new;
run;

/* copy new datasets to backupfolder */
%macro backupnews;
proc datasets ;
%do i=1 %to &Nnew;
copy in=raworg out=brawdata;
select &&var&I;
run;
%end;
quit;
%mend;
%backupnews;

/* copy altered datasets from backupfolder to version folder */
%macro backupchanges1;
proc datasets ;
%do i=1 %to &Ncha;
copy in=brawdata out=obackraw;
select &&cha&I;
run;
%end;
quit;
%mend;
%backupchanges1;

/* copy altered datasets from masterfolder to backupfolder  */
%macro backupchanges2;
proc datasets ;
%do i=1 %to &Ncha;
copy in=raworg out=brawdata;
select &&cha&I;
run;
%end;
quit;
%mend;
%backupchanges2;

proc printto;
run;
