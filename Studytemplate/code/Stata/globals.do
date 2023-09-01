/*

*/

set more off, permanently

/* remember to set the dates */
gl inclstart mdy(1,1, 2010)
gl inclend mdy(12,20,2022)
gl studyend mdy(12,20,2022)
/* follow-up years */
gl FUP 1 2.5 5 10

/* table 1 grouping, NB must be with labels */
gl BGRP
gl BTEST FALSE
gl BBALANCE FALSE

/* reference exposure group */
gl Ref 1
gl RefName Standard

/* variables for the propensity model */
/* important weights are empty */
gl weight

/* max  years for rate graphs (c-statistics) */
gl maxFUP 5

/* title for plots in rates (nonDeath endpoints) */
gl rateTitle A, B
gl rateLegend 1 `""New""' 2 `""Standard""'

/* marker/score for ROC curve (c-statistics) */
gl Scores cha2ds2vasc

/* ticks for forestplot */
gl ticklist
gl ticklist 0.5 0.75 1 1.5 2

/* how to sort the different variables in forestplot */
gl sortlist1 $ENDP $ENDPd
gl sortlist2 1 2.5 5 10
gl sortlist3 Adjusted Crude

gl NC invnormal(0.975)

gl fewdata 5

gl index idate

gl MediList
/* list all the diagnosis used further on */
gl DiagList
/* operations */
gl OprList

/* replace part of variable name with base356to0 */
/* a variable will be calculated in newvariables.do and named "drug"base365to0 */
gl drugBefore 365 /* how many days before $index date */
gl drugAfter  0   /* how many days after  $index date */
/***************************************** TABLE 1 ***************************************************/
/* Table 1 specification, remember to set BVAR BGRP */
/* baseline variable types, list <variable name> <type> in global variable BVAR
  0: Binary
  1: Categorical
  2: continous (mean/sd)
  3: continous (median/1st-3rd)
*/
/* 0: Binary */
CreateList   DiagTab1Bin,   num(0) list($DiagList) addtxt("be$index")
CreateList   OprTab1Bin,    num(0) list($OprList) addtxt("be$index")
CreateList   MediTab1Bin,    num(0) list($MediList) addtxt("baseline$index")

/* 1: Categorical */
CreateList   DiabTab1Cat,    num(1) list() addtxt("be$index")

/* 2: Continous (mean/sd) */
CreateList   DiabTab1mean,   num(2) list() addtxt("be$index")

/* 3: Continous (median/1st-3rd) */
CreateList   DiabTab1median, num(3) list() addtxt("be$index")

/* combine all lists in BVARd and BVARm - will end op in one combined table */
/* Diagnosis and Riskvariables */
gl BVARd sex 0 age$index 2 age$index 3 age65 0   $DiagTab1Bin $OprTab1Bin ///
                                                 $DiagTab1Cat ///
                   $DiagTab1mean  $DiagTab1median
/* medications */
gl BVARm $MediTab1Bin
