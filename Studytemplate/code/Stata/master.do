/*

*/
/* configure this project */
global Projectnumber         NNNN             /* replace */
global Studynumber           ZZZ              /* replace */
global ProjectOwnerInitials  QQQ              /* replace */
global Shorttitle            Template        /* replace */
global ProjectDescription    Template project /* replace */
/* the date when data is collected */
global ProjectDate           mdy(12,20,2022)  /* replace */
global GlobalProject     = FSEID0000$Projectnumber;
global GlobalPath           f:/Projekter/$GlobalProject

/* Project specific names and paths */
/* set Projectname to <project-foldername> */

global ProjectName          ${ProjectNumber}_${Studynumber}_${ProjectOwnerInitials}_${Shorttitle}
global ProjectDescription   SAK in VHD

global ProjectPath          $GlobalPath/$ProjectName

global LocalCodeDir         $ProjectPath/code/Stata
global LocalMacroDir        $ProjectPath/macros
global LocalFinalData       $ProjectPath/data/Stata
global LocalWorkData        $ProjectPath/tempdata/Stata
global LocalRWorkData       $ProjectPath/tempdata/R
global LocalOutDir          $ProjectPath/out
global LocalRdatadir        $ProjectPath/data/R
global LocalRcodedir        $ProjectPath/code/R


cd "$LocalCodeDir"
run profile

gl CENSORREPORT TRUE
*gl CENSORREPORT FALSE
gl repname $ProjectName
if "$CENSORREPORT" == "TRUE" gl repname ${ProjectName}Censored
if "$CENSORREPORT" == "FALSE" gl repname ${ProjectName}Uncensored

cap log  close statalog
log using $LocalOutDir/statalog_$repname.log, name(statalog) replace


/* load the data */
use "$LocalFinalData/studiept", clear
rename *, lower
/* create lists and new variables*/
do globals
do newvariables

if "$CENSORREPORT"=="FALSE" gl fewdata 0

	gl repname ${ProjectName}Censored

	dowe Header.org using "$LocalOutDir/$repname.org", replace
        dowe Intro.org using "$LocalOutDir/$repname.org", replace
	dowe Flowchart.org using "$LocalOutDir/$repname.org", append

	dowe table1.org using "$LocalOutDir/$repname.org", append
	*dowe PropenLogistic.org using "$LocalOutDir/$repname.org", append
	*dowe propenTjek.org using "$LocalOutDir/$repname.org", append

	*dowe Table1.org using "$LocalOutDir/$repname.org", append
	*dowe plotMSD.org using "$LocalOutDir/$repname.org", append
	*dowe Rates.org using "$LocalOutDir/$repname.org", append
	*dowe Risks.org using "$LocalOutDir/$repname.org", append
	*dowe Cox.org using "$LocalOutDir/$repname.org", append
	*dowe cstat.org using "$LocalOutDir/$repname.org", append
	*dowe Forestplot.org using "$LocalOutDir/$repname.org", append

	save $LocalWorkData/$repname.dta, replace
	dowex, file("$LocalOutDir/$repname.org")
	copyout , copypath("$LocalOutDir/$num") inpath("$LocalOutDir") replace
	copyout , copypath("$LocalOutDir/${num}/pdf") inpath("$LocalOutDir") movetype(pdf) replace
	copyout , copypath("$LocalOutDir/${num}/png") inpath("$LocalOutDir") movetype(png) replace

log close statalog
