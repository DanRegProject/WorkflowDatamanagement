/* SVN header
$Date: 2021-07-05 13:03:37 +0200 (ma, 05 jul 2021) $
$Revision: 309 $
$Author: fskMarJen $
$ID: $
*/

rename birthdate birthdate
rename deathdate deathdate

gen studyend =$studyend
/*
/* example of making an exposure variable */
generate type = "warfarin"    if warfarinbaseline == 1
encode type, g(Ntype)

generate bittype = (Ntype > 3)
label define bittype 0 NOAC 1 Warfarin
label values bittype bittype
*/
/* create sex variable (numeric with label) */
destring sex, replace

cap drop censurdate
gen censurdate = min(pop_out,$studyend)
format censurdate %d

gen death=(deathdate<=censurdate)

/* create values for age groups (indicators) */
egen StudyAgeGrp =cut(age$index), at(0,40,50,60,65,70,75,80,85,90,130)
cap drop age80
cap drop age85
cap drop age75
cap drop age65

gen age80 = (age$index >= 80)
gen age85 = (age$index >= 85)
gen age75 = (age$index >= 75)
gen age65 = (age$index >= 65)


foreach i in $MediList{
  gen `i'base${drugBefore}to$drugAfter =($index-`i'laeksdbe$index <= $drugBefore | `i'fieksdaf$index-$index <= $drugAfter)
}

foreach v in pe dvt {
	gen `v'recurbeidate = (`v'fidatebeidate != `v'ladatebeidate)
}
/* create status and enddate variables for analysis */
if "$ENDPall" != ""{
foreach e in $ENDPall{
  loc vars
  loc combined
  if strpos("`e'","comb")>0{
    foreach v in $`e' {
      if strpos("`v'", "death") == 0 loc vars `vars' `v'dateaf$index
      if strpos("`v'", "death") > 0 loc combined combined
    }
    loc temp = substr("`e'", 5, .)
    genEndpoint `temp' `vars', deadDate(deathdate) deadCode(death) studyEndDate(censurdate) `combined'
  }
  /* create single endpoint */
  else if strpos("`e'","death")==0{
    genEndpoint `e' `e'dateaf$index, deadDate(deathdate) deadCode(death) studyEndDate(censurdate)
  }
  /* create combination endpoints */
  else if strpos("`e'","death")>0{
    genEndpoint `e', deadDate(deathdate) deadCode(death) studyEndDate(censurdate)
  }
}


/* remove "comb" from endpoints with death */
gl tENDPd
foreach e in $ENDPd{
  loc temp = substr("`e'", 5, .)
  if strpos("`e'", "comb") == 0 {
    gl tENDPd $tENDPd `e'
  }
  else {
    gl tENDPd $tENDPd `temp'
  }
}

/* remove "comb" from any other endpoint */
gl tENDP
foreach e in $ENDP{
  loc temp = substr("`e'", 5, .)
  if strpos("`e'", "comb") == 0 {
    gl tENDP $tENDP `e'
  }
  else {
    gl tENDP $tENDP `temp'
  }
}

gl ENDPd $tENDPd
gl ENDP  $tENDP
}##***** newvariables.do End 
