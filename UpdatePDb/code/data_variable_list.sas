/* A list of all tables including all variables. If possible, all variables will be combined to one, and used for comparison (compby=sortby).
   If the variablelist is too long for this option, a subset list of variables will be picked to be used for comparison (compby) and
   the entire list will be present in sortby, and used for sorting the dataset.
   IF the old variablelist differs from the new list,  the tables will be sorted and combined with variables in common (oldsort=).
   Depending on the changes in that case, it is possible to either merge in new variables and keep old history or discontinue the old
   table and start a new with the option mergenew=, TRUE will merge into the existing table and FALSE will stop the old table and begin a new */
/*
   name          name of the table(s)
   compby        list of compare variables, if different from sortby
   startyr       if table runs from e.g. 2004-2016 then startyear is 2004. Set to 0 if year is not present in tablename
   endyr         if table runs from e.g. 2004-2016 then endyr     is 2004. Set to 0 if year is not present in tablename
   sortby        a list of all the variables in the dataset, NOTE: if primtab and primkey are given then the first variable MUST be the variable to link the primkey with
   primtab       name of the table with a primary key (fx t_adm with k_recnum)
   primkey       name of the primary key used in primtab
   oldsort=      the previous list of variables in the dataset. Optional
   mergenew=     TRUE: merge old and new variables, FALSE: start a new table. Optional, requires oldsort.
*/
/* The file getvarnames.sas include a utility to retrieve variables names from tables           */
/* if compby = "" then compby = sortby - use if huge amount of variables, e.g. with LMS txt     */
/* 28/9 2017 - oldsort without c_indm                                                           */
/* LPR  */     /*  name,             compby,    startyr,    endyr,                   sortby,                                                         primtab,           primkey */
%let lastyr_lpr2 = 2019;
%let LPR_table1  = lpr2_mdl_uaf_t_opr,    ,        2005,    &lastyr_lpr2,   v_recnum c_opr c_komb c_oafd c_osgh,                                     lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table2  = lpr2_mdl_t_diag,       ,        2005,    &lastyr_lpr2,   v_recnum c_diag c_diagtype c_tildiag,                                    lpr2_mdl_t_adm,     k_recnum;
%let LPR_table3  = lpr2_mdl_uaf_t_diag,   ,        2005,    &lastyr_lpr2,   v_recnum c_diag c_diagtype c_tildiag,                                    lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table4  = lpr2_mdl_t_opr,        ,        2005,    &lastyr_lpr2,   v_recnum c_opr c_komb c_oafd c_osgh,                                     lpr2_mdl_t_adm,     k_recnum;
%let LPR_table5  = lpr2_mdl_t_sksopr,     ,        2005,    &lastyr_lpr2,   v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto v_otime v_ominut,  lpr2_mdl_t_adm,     k_recnum;
%let LPR_table6  = lpr2_mdl_uaf_t_sksopr, ,        2005,    2018,   		v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, 		     lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table7  = lpr2_mdl_uaf_t_sksopr, ,        2019,    &lastyr_lpr2,   v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table8  = lpr2_mdl_t_sksube,     ,        2005,    &lastyr_lpr2,   v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, lpr2_mdl_t_adm,     k_recnum;
%let LPR_table9  = lpr2_mdl_uaf_t_sksube, ,        2005,    2018,           v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  ,                 lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table10 = lpr2_mdl_uaf_t_sksube, ,        2019,    &lastyr_lpr2,   v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto  v_otime v_ominut, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table11 = lpr2_mdl_t_adm,        ,        2005,    &lastyr_lpr2,   k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm c_udm v_indtime v_indminut v_udtime, lpr2_mdl_t_adm,     k_recnum;
%let LPR_table12 = lpr2_mdl_uaf_t_adm,    ,        2005,    2018,           k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm,                            lpr2_mdl_uaf_t_adm, k_recnum; /*c_indm c_udm v_indtime v_indminut er ikke i views før 2019*/
%let LPR_table13 = lpr2_mdl_uaf_t_adm,    ,        2019,    &lastyr_lpr2,   k_recnum v_cpr_encrypted c_adiag c_afd c_pattype c_sgh d_inddto d_uddto v_sengdage c_indm c_udm v_indtime v_indminut v_udtime, lpr2_mdl_uaf_t_adm, k_recnum;
%let LPR_table14 = lpr_t_diag,            ,        1977,    1994,      v_recnum c_diag c_diagtype c_diagmod,                  lpr_t_adm, k_recnum;
%let LPR_table15 = lpr_t_diag,            ,        1995,    2004,      v_recnum c_diag c_diagtype c_tildiag,                  lpr_t_adm, k_recnum;
%let LPR_table16 = lpr_t_opr,             ,        1977,    2004,      v_recnum c_opr c_komb c_oafd c_osgh,                   lpr_t_adm, k_recnum;
%let LPR_table17 = lpr_t_sksopr,          ,        1996,    2004,      v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, lpr_t_adm, k_recnum;
%let LPR_table18 = lpr_t_sksube,          ,        1999,    2004,      v_recnum c_opr c_oafd c_oprart c_osgh c_tilopr d_odto, lpr_t_adm, k_recnum;
%let LPR_table19 = lpr_t_adm,             ,        1977,    1986,      k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime,         					 lpr_t_adm, k_recnum;
%let LPR_table20 = lpr_t_adm,             ,        1987,    1993,      k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime c_udm, 						 lpr_t_adm, k_recnum;
%let LPR_table21 = lpr_t_adm,             ,        1994,    2004,      k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm v_indtime c_udm v_sengdage v_indminut v_udtime, lpr_t_adm, k_recnum;
%let LPR_tableN    = 21; /* all LPR tables */
%let LPR_tableNewN = 13; /* the LPR tables that are still updated */

/* LPR-PSYK  */     /*  name,                  compby,  startyr, endyr,     sortby */
%let LPRPSYK_table1 = LPR2_MDL_T_PSYK_ADM,             ,        0,    0,      k_recnum v_cpr_encrypted d_inddto d_uddto c_adiag c_afd c_pattype c_sgh c_indm c_sex c_udm v_indminut v_indtime v_sengdage v_udtime,lpr_t_psyk_adm, k_recnum;
%let LPRPSYK_table2 = LPR2_MDL_T_PSYK_diag,            ,        0,    0,      v_recnum c_diag c_diagtype c_tildiag,                                                          lpr_t_psyk_adm, k_recnum;
%let LPRPSYK_tableN    = 2; /* all LPR-PSYK tables */

/* CPR3 */      /*  name,                       compby,          no year,, sortby */
%let CPR3_table5  = CPR3_INDVANDRER_EFTERKOMMER, , 0,0,      v_pnr_encrypted gen oprindelses_land oprindelses_land_cprmyndighed oprindelses_land_tekst, ,;
%let CPR3_table4  = cpr3_t_adresse_udland,      , 0,0,      v_pnr_encrypted d_udrejse_dato, ,;
%let CPR3_table3  = cpr3_t_adresse_udland_hist, , 0,0,      v_pnr_encrypted c_annkor d_indrejse_dato d_udrejse_dato, ,;
%let CPR3_table2  = cpr3_t_person,              , 0,0,      v_pnr_encrypted v_mor_pnr_encrypted v_far_pnr_encrypted c_kon c_status d_foddato d_status_hen_start, ,;
%let CPR3_table1  = CPR3_dansk_ophold_periode_unik,            , 0,0,      v_pnr_encrypted dk_adresse_start dk_adresse_slut, ,;
%let CPR3_tableN  = 5;

/* DAR  - Tables has not been used/tested */
%let DAR_table1  = DAR_t_dodsaarsag_1,          , 0,0, k_cpr_encrypted c_bopkom c_dod1 c_dod2 c_dod3 c_dod4 c_dodsmaade c_institut c_obduktio c_operatio d_dodsdto, ,;
%let DAR_table2  = DAR_t_dodsaarsag_2,          , 0,0, k_cpr_encrypted c_bopkom c_bopkomf07 c_dodsmaade c_dodssted c_dodtilgrundl_acme c_dod1a c_dod1b c_dod1c c_dod1d c_dod21 c_dod22 c_dod23 c_dod24 c_dod25 c_dod26 c_dod27 c_dod28 c_findested c_obduktion c_praecis_dodssted c_praecis_findested d_dodsdato, ,;
%let DAR_tableN  = 2;

/* FGR - Tables has not been used/tested */
%let FGR_table1  = FGR_t_admklasse,          , 0,0, v_betydning d_ajodto d_tildto k_adm k_fradto, ,;
%let FGR_table2  = FGR_t_sksklasse,          , 0,0, v_betydning d_ajodto d_tildto k_kodetype k_sks k_fradto, ,;
%let FGR_table3  = FGR_t_snoklasse,          , 0,0, v_betydning d_ajodto d_tildto k_fradto c_sex k_sno v_fraalder v_tilalder, ,;
%let FGR_table4  = FGR_t_spcklasse,          , 0,0,             d_ajodto d_tildto k_fradto k_spc v_specialenavn, ,;
%let FGR_table5  = FGR_t_talklasse,          , 0,0, v_betydning d_ajodto d_tildto k_tal k_fradto, ,;
%let FGR_table6  = FGR_t_tilklasse,          , 0,0, v_betydning d_ajodto d_tildto k_til k_fradto, ,;
%let FGR_table7  = FGR_t_ubhklasse,          , 0,0, v_betydning d_ajodto d_tildto k_ubh k_fradto c_tul, ,;
%let FGR_table8  = FGR_t_ulyklasse,          , 0,0, v_betydning d_ajodto d_tildto k_uly k_fradto, ,;
%let FGR_table9  = FGR_t_prcklasse,          , 0,0, v_betydning d_ajodto d_tildto k_fradto c_sex k_prc v_fraalder v_tilalder, ,;
%let FGR_table10 = FGR_t_sghklasse,          , 0,0, k_sgh c_instart d_ajodto d_tildto v_sghnavn c_sghtype k_fradto, ,;
%let FGR_table11 = FGR_t_sghregklasse,       , 0,0, k_sgh c_instart c_region c_sghtype c_sorid d_tildto k_fradto v_sghnavn, ,;
%let FGR_table12 = FGR_t_afdklasse,          , 0,0, k_sgh c_speciale1 c_speciale2 c_speciale3 c_speciale4 d_ajodto d_tildto k_afd k_fradto v_afdnavn, ,;
%let FGR_table13 = FGR_t_atcklasse,          , 0,0, k_atc v_betydning d_ajodto d_tildto k_fradto, ,;
%let FGR_table14 = FGR_t_cpr_adm_komklasse,  , 0,0, k_kom c_amt c_region d_ajodto d_tildto k_fradto v_amtsnavn v_kommunenavn v_regionsnavn, ,;
%let FGR_table15 = FGR_t_diaklasse,          , 0,0, k_dia c_grp23 c_grp99 c_sex d_ajodto d_tildto k_fradto v_betydning v_fraalder v_tilalder, ,;
%let FGR_table16 = FGR_t_komklasse,          , 0,0, k_kom c_amt c_region d_ajodto d_tildto k_fradto v_amtsnavn v_kommunenavn v_regionsnavn, ,;
%let FGR_table17 = FGR_t_kommunebro,         , 0,0, c_komny c_region k_komgl v_komnavngl v_komnavnny v_regnavn, ,;
%let FGR_table18 = FGR_t_oprklasse,          , 0,0, v_betydning d_ajodto d_tildto k_fradto c_sex k_opr v_fraalder v_tilalder, ,;
%let FGR_tableN = 18;

/* MFR */      /*  name,                        compby,  startyr, endyr,     sortby */
%let MFRlpr_table1  = mfr_t_lpr_mfr,               ,        0,             0,   v_mcpr_encrypted v_bcpr_encrypted c_ryger c_sgh v_apgar  v_datatyp v_ga_dage v_hoved v_langde v_placenta v_sabort v_vagt, ,;
%let MFRlpr_tableN  = 1;

%let MFR_table1  = mfr_mfr,                     ,        1997,    &lastyr_lpr2,   pk_mfr cpr_moder_encrypted cpr_barn_encrypted  apgarscore_efter5minutter bmi_moder flerfoldsgraviditet foedselsdato foedselsdiagnose_moder gestationsalder_dage hovedomfang kejsersnit_modersoenske koen_barn laengde_barn levende_eller_doedfoedt markoer_andre_foedselskomplikati markoer_b_misdannelse markoer_cardiomyopati markoer_graviditetskomplikatio markoer_hjemmefoedsel_beregnet markoer_igangsaettelse markoer_infektioner markoer_kejsersnit markoer_medicinske_sygdomme markoer_vestimulation placentavaegt pprom prom rygerstatus_moder sygehus tang_forloesning tidligerespontaneaborter vaegt_barn vaegt_moder vakuumekstraktion,mfr_mfr, pk_mfr;
%let MFR_table2  = mfr_cardiomyopati,           ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table3  = mfr_graviditetskomplikation, ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table4  = mfr_igangsaettelse,          ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table5  = mfr_infektioner,             ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table6  = mfr_kejsersnit,              ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table7  = mfr_medicinske_sygdomme,     ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table8  = mfr_misdannelser,            ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table9 = mfr_vestimulation,            ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_table10 = mfr_andre_foedselskomplikat, ,        1997,    &lastyr_lpr2,   fk_mfr kodetype skskode, mfr_mfr, pk_mfr;
%let MFR_tableN  = 10; /* MFR updated with new variables in september 2017 */

/* MINIPAS */     /*  name,             compby,   startyr, endyr,    sortby */
%let MINIPAS_table1 = minipas_t_adm,    ,         2002,    &lastyr_lpr2,  k_recnum v_cpr_encrypted c_indm d_inddto d_uddto c_adiag c_pattype c_sgh c_afd v_sengdage c_udm, minipas_t_adm, k_recnum;
%let MINIPAS_table2 = minipas_t_diag,   ,         2002,    &lastyr_lpr2,  v_recnum c_diag c_diagtype c_tildiag,                                                            minipas_t_adm, k_recnum;
%let MINIPAS_table3 = minipas_t_sksopr, ,         2002,    &lastyr_lpr2,  v_recnum c_opr c_oprart d_odto c_tilopr c_oafd c_osgh,                                           minipas_t_adm, k_recnum;
%let MINIPAS_table4 = minipas_t_sksube, ,         2002,    &lastyr_lpr2,  v_recnum c_opr c_oprart d_odto c_tilopr c_oafd c_osgh,                                           minipas_t_adm, k_recnum;
%let MINIPAS_tableN = 4;

/* MINIPAS-PSYK */     /*  name,             compby,   startyr, endyr,    sortby */
%let MINIPASPSYK_table1 = minipas_t_psyk_adm,    ,         2002,    &lastyr_lpr2,  k_recnum v_cpr_encrypted c_indm d_inddto d_uddto c_adiag c_pattype c_sgh c_afd v_sengdage c_sex c_udm, minipas_t_psyk_adm, k_recnum;
%let MINIPASPSYK_table2 = minipas_t_psyk_diag,   ,         2002,    &lastyr_lpr2,  v_recnum c_diag c_diagtype c_tildiag,                                                                  minipas_t_psyk_adm, k_recnum;
%let MINIPASPSYK_tableN = 2;

/* NDR */     /*  name,           compby, noyear,, sortby */
%let NDR_table1 = ndr_t_diabetes, ,       0,0,     v_cpr_encrypted c_inklaarsag d_blod5i1 d_blod2i5 d_fodt d_inkldto d_ins d_lpr d_oad, ,;
%let NDR_tableN = 1;

/* LMS */     /*  name,           compby, noyear,, sortby, oldsort */
/* 22/6 2016 %let LMS_table1 = LMS_epikur,               ,          0,0,     cpr_encrypted eksd atc packsize vnr apk doso indo ekst;*/
/* 28/9 2017 remove oldsort */
%let LMS_table1 = LMS_epikur, /* 10/1-2017 */,         1994,&lastyr,     cpr_encrypted eksd atc packsize vnr apk doso indo volapk voltypecode voltypetxt, ,;
%let LMS_table2 = LMS_ekokur,                ,         0,0,     cpr_encrypted eksd atc patt rgl1 rgl2 rgla rimb, ,;
%let LMS_tableN = 2;
%let LMS_tableNewN = 2; /* opdatering inc hele 2023, MJE: jeg tænker at der skal stå 2 her (rettet fra 1) efter tilføjelsen af ekokur tabellen   */

/* hjælpetabeller: LMS in main project */
%let LMStxt_table1 = LMS_doso_tekster,         ,          0,0,     doso dosering, ,;
%let LMStxt_table2 = LMS_indo_tekster,         ,          0,0,     indo indikation, ,;
%let LMStxt_table3 = LMS_laegemiddeloplysninger, ATC ABC ACTDATE AIP_NU ATC1 AUP_NU BG_PRIS DELANTAL DELPAK DELPAKNING DISTRI DOSDISP DOSFORM DRUGID DSPNR IMPORT LMSUBGR MARKDATE NCE_S PACKSIZE PACKTYPE PKSUBGR PPRES PPRES_D PRICEDAT REGOWNER REGSIT_D REGSIT_P REIMB_D REIMB_P SIZEUNIT SPECIALE STOPDATE STRNUM STRUNIT /*TAKD */TILPRIS TRAFFIC VNR VOLTYPECODE VOLUME WHOADMVEJ WITHDA_D WITHDA_P,     0,0,     ATC ABC ACTDATE AIP_NU ATC1 AUP_NU BG_PRIS DELANTAL DELPAK DELPAKNING DISTRI DOSDISP DOSFORM DRUGID DSPNR IMPORT LMSUBGR MARKDATE NCE_S PACKSIZE PACKTYPE PKSUBGR PPRES PPRES_D PRICEDAT REGOWNER REGSIT_D REGSIT_P REIMB_D REIMB_P SIZEUNIT SPECIALE STOPDATE STRNUM STRUNIT TAKD TILPRIS TRAFFIC VNR VOLTYPECODE VOLUME WHOADMVEJ WITHDA_D WITHDA_P DISTRI_NAME DOSF_LT IMP_NAME PACKTEXT PNAME REG_NAME REIMB_LT STRENG VOLTYPETXT WHOADMVEJTXT, ,;
%let LMStxt_tableN = 3;

/* SSR */      /*  name,          compby,  startyr, endyr,    sortby */
%let SSR_table1  = ssr_t_ssik,    ,        1990,    2020,  v_cpr_encrypted c_ydelsesnr c_ytype v_antydel v_honaar v_honuge v_kontakt, ,;
%let SSR_tableN  = 1;


/* LAB */      /*  name,                  compby,  startyr, endyr,    sortby */
%let LAB_table1  = LAB_lab_dm_forsker,         ,      2008,&lastyr,    patient_cpr_encrypted analysiscode laboratorium_idcode referenceinterval_lowerlimit referenceinterval_upperlimit resulttype samplingdate samplingtime unit value, ,;
%let LAB_tableN  = 1;

%let LABtxt_table1  = LAB_lab_dm_labidcodes, ,        0,0,               idcode laboratorium region speciale, ,;
%let LABtxt_table2  = Lab_lab_dm_optaelling, ,        0,0,               LABORATORIUM REGION SPECIALE /* husk nyt kvartal */kvartal_2022_4 kvartal_2022_3 kvartal_2022_2 kvartal_2022_1 kvartal_2021_4 kvartal_2021_3 kvartal_2021_2 kvartal_2021_1 kvartal_2020_4 kvartal_2020_3 kvartal_2020_2 kvartal_2020_1 KVARTAL_2019_4 KVARTAL_2019_3 KVARTAL_2019_2 KVARTAL_2019_1 KVARTAL_2018_4 KVARTAL_2018_3 KVARTAL_2018_2 KVARTAL_2018_1 KVARTAL_2017_4 KVARTAL_2017_3 KVARTAL_2017_2 KVARTAL_2017_1 KVARTAL_2016_4 KVARTAL_2016_3 KVARTAL_2016_2 KVARTAL_2016_1 KVARTAL_2015_4 KVARTAL_2015_3 KVARTAL_2015_2 KVARTAL_2015_1 KVARTAL_2014_4 KVARTAL_2014_3 KVARTAL_2014_2 KVARTAL_2014_1 KVARTAL_2013_4 KVARTAL_2013_3 KVARTAL_2013_2 KVARTAL_2013_1 KVARTAL_2012_4 KVARTAL_2012_3 KVARTAL_2012_2 KVARTAL_2012_1 KVARTAL_2011_4 KVARTAL_2011_3 KVARTAL_2011_2 KVARTAL_2011_1 KVARTAL_2010_4 KVARTAL_2010_3 KVARTAL_2010_2 KVARTAL_2010_1 KVARTAL_2009_4 KVARTAL_2009_3 KVARTAL_2009_2 KVARTAL_2009_1 KVARTAL_2008_4 KVARTAL_2008_3 KVARTAL_2008_2 KVARTAL_2008_1, ,;
%let LABtxt_tableN  = 2;




/* LPR-3 Midlertidig datamodel*/

%let LPR3SB_table1 = LPR3_SB_DIAGNOSE,           , 0, 0, KONTAKT_ID ART DIAGNOSE_ID FEJL KODE SENEREAFKRAEFTET SIDEANGIVELSE ,                 LPR3_SB_KONTAKT, KONTAKT_ID ;
%let LPR3SB_table2 = LPR3_SB_DIAGNOSE_TILLAEG,   , 0, 0, DIAGNOSE_ID TILLAEGSKODE,                                                             LPR3_SB_DIAGNOSE, DIAGNOSE_ID;
%let LPR3SB_table3 = LPR3_SB_FORLOEBELEMENT,     , 0, 0, afslutningsmaade ansvarlig_enhed fejl fejl_trns forloebelement_id forloeblabel henvisendeinstans henvisningsaarsag henvisningsmaade henvisningstidspunkt hovedspeciale inst_type personnummer_encrypted referencetype reference_id sluttidspunkt starttidspunkt sundhedsinstitution ,              LPR3_SB_KONTAKT, FORLOEBELEMENT_ID  ;
%let LPR3SB_table4 = LPR3_SB_FORLOEBMARKOER,     , 0, 0, FORLOEBELEMENT_ID FEJL_FLB FORLOEBMARKOER_ID KODE TIDSPUNKT ,                         LPR3_SB_KONTAKT, FORLOEBELEMENT_ID;
%let LPR3SB_table5 = LPR3_SB_KONTAKT,            , 0, 0, KONTAKT_ID AKTIONSDIAGNOSE ANSVARLIG_ENHED FEJL FEJL_FLB FEJL_TRNS FORLOEBELEMENT_ID HENVISENDEINSTANS HENVISNINGSMAADE HENVISNINGSTIDSPUNKT HOVEDSPECIALE INST_TYPE KONTAKTAARSAG KONTAKTTYPE PERSONNUMMER_ENCRYPTED PRIORITET SLUTTIDSPUNKT STARTBEHANDLING STARTTIDSPUNKT SUNDHEDSINSTITUTION , LPR3_SB_KONTAKT, KONTAKT_ID  ;
%let LPR3SB_table6 = LPR3_SB_METASTASER,         , 0, 0, DIAGNOSE_ID FEJL KODE,                                                                LPR3_SB_DIAGNOSE, DIAGNOSE_ID;
%let LPR3SB_table7 = LPR3_SB_OPHOLDSADRESSE,     , 0, 0, KONTAKT_ID ENHED FEJL_KONTAKT FRAVAER OPHOLDSADRESSE_ID SLUTTIDSPUNKT STARTTIDSPUNKT, LPR3_SB_KONTAKT, KONTAKT_ID  ;
%let LPR3SB_table8 = LPR3_SB_PROCEDURER,         , 0, 0, KONTAKT_ID FEJL FORLOEBELEMENT_ID HANDLINGSSPEC INDIKATION KODE KONTRAST PROCEDURER_ID PROCEDURETYPE PRODUCERENDE_ENHED SIDEANGIVELSE SLUTTIDSPUNKT STARTTIDSPUNKT ,                                                                                                                               LPR3_SB_KONTAKT, KONTAKT_ID ;
%let LPR3SB_table9 = LPR3_SB_PROCEDURER_TILLAEG, , 0, 0, PROCEDURER_ID TILLAEGSKODE,                                                           LPR3_SB_PROCEDURER, PROCEDURER_ID ;
%let LPR3SB_table10 = LPR3_SB_LOKALRECIDIVER,    , 0, 0, DIAGNOSE_ID KODE FEJL,                                                           LPR3_SB_DIAGNOSE, DIAGNOSE_ID ;
%let LPR3SB_tableN = 10;

%let LPR3SB_spe_table1= LPR3_SB_RESULTATER,         , 0, 0, FEJL RESULTAT RESULTATER_ID RESULTATTYPE RI_TYPE TIDSPUNKT TRIGGER_ID TRIGGER_TYPE , ,;
%let LPR3SB_spe_tableN = 1;

%let LPR3SBtxt_table1 = LPR3_SB_SKSKODE,        , 0, 0, DATOAENDRING GYLDIGFRADATO GYLDIGTILDATO KODE LANGTEXT TEXT, ,;
%let LPR3SBtxt_table2 = LPR3_SB_SOR_COMPLETE,   , 0, 0, GAELDENDE_FRA_DATO HOVEDSPECIALE NIVEAU OPHOERT_DATO PARENT_SORKODE REGION SHAK_KODE SIDST_AENDRET_DATO SORKODE SOR_TYPE SPECIALE2 SPECIALE3 SPECIALE4 SPECIALE5 SPECIALE6 SPECIALE7 SPECIALE8, ,;
%let LPR3SBtxt_tableN = 2;


/* SMR - sygehusets medicin rigister */
%let SMR_table1 = DS_SMR_INDBERETNINGMEDPRIS,      , 0, 0, k_adm_id_eNcrypteD k_rEgion_id v_cpr_encrypteD d_adm d_konTakt_start d_ord_start d_ord_slUt c_sor c_kontaktansvaR_afd_sor c_atc v_lAeGEmiddeLnavn c_Varenummer v_drugid c_ord_type c_adm_vej V_adm_DOSis v_ADM_DOsiS_Enhed v_styrke_num v_styrKe_enhed v_pakningSstoerrelSe_Num v_pakninGsstoErrelse_enhed v_laegemiddel_form amgrOs_adm_pris, ,;
%let SMR_table2 = DS_SMR_LAEGEMIDDEL        ,      , 0, 0, varenummer vaRenummer__drugid_ vare_Beskrivelse Styrke_BeskriveLse styrke_numerisk StYrke_enhed enhed_st_rrelse administrationsvej_kOde administrationsvej_besKriveLse pakningsst_rrelse pakningsst_rrelse_besKrivelse pakningsst_rrElse_gruPpe atc_kode atc_beskrivelse laegemiddElform laegemiddElform___undErgruppe laegemiddelForm___hovedgruppe atc_grupPenIveau_1 atc_GruppeniveAu_2 kategori_niveaU_2 Er_aFH_ngighedsskaBEnde seponerings_note seponerings_tekst_niVeau_1 seponerings_teKst_niveau_2 delpakning_beskrivelSe volume volume_enhed_kode volume_enhed_beskrivelsE, ,;
%let SMR_tableN = 2;

/* LPR_F færdig datamodel, SB kan stadig bruges i 2023 */
%let LPR_F_table1 = LPR_F_KONTAKTER            ,      , 0, 0,  aktionsdiagnose cpr_encrypted dato_behandling_start dato_henvisning dato_slut dato_start dw_ek_forloeb dw_ek_kontakt enhedstype_ans enhedstype_hen henvisningsaarsag henvisningsmaade henvisning_fritvalg hovedspeciale_ans hovedspeciale_hen kontaktaarsag kontakttype lprindberetningssystem prioritet region_ans region_hen sorenhed_ans sorenhed_hen tidspunkt_behandling_start tidspunkt_henvisning tidspunkt_slut tidspunkt_start , LPR_F_KONTAKTER, DW_EK_KONTAKT;
%let LPR_F_table2 = LPR_F_diagnoser            ,      , 0, 0,  dw_ek_kontAkT dIagnosekode diaGnOSeTYpe senEre_afkraeftet diagnosekode_parent dIagnosetype_parent lprindberetningssystem, 	LPR_F_KONTAKTER			, ;
%let LPR_F_table3 = LPR_F_procedurer_kirurgi   ,      , 0, 0,  dw_ek_fOrloeb dw_ek_kontakt procedurekode proceduretype procedurekode_parent proceduretYpe_PaRent sorenhed_pro enhedstype_Pro hovedspeciale_pRo rEgIon_pro dato_starT tidspunkt_start dato_sluT tidspuNkt_slut lprindberetningssystem procedureregistrering_id, LPR_F_KONTAKTER ,;
%let LPR_F_table4 = LPR_F_procedurer_andre     ,      , 0, 0,  dw_ek_forloeb dw_ek_KontakT PRocedurekode proceduretype procedUrEkode_parent proceduretype_parent sorenhed_Pro eNhedsType_pro hovEdspEcIAlE_pro regiOn_pro dato_start tidspunkt_start dato_slut tidspunkt_slut lPrindBeretningssystem procedureRegistrering_id, LPR_F_KONTAKTER,;
%let LPR_F_table5 = LPR_F_kontaktlokationer    ,      , 0, 0,  dw_ek_kontakt soRenhed enhedstype hovedspeciaLe lprindberetningssystem rEgIon fravaer dato_start tidspunkt_Start dato_sLuT tidspunkt_sLut,LPR_F_KONTAKTER ,;
%let LPR_F_table6 = LPR_F_resultater           ,      , 0, 0,  dw_ek_kontAKt dW_ek_forlOeb TRiGgErtYpe triggerkode indberetningstype IndberetningsstatUs resultatType rEsultaTVaerdI resultatnummer sorEnhed_ans enhedstype_Ans hovedspeciale_ans region_ans daTO_ReSuLtat tiDspunkt_resultat lprindberetningssystem, ,;
%let LPR_F_table7 = LPR_F_forloeb              ,      , 0, 0,  dw_ek_forloeb dW_ek_helbRedsforloeb cPr_encrypted SorenHed_ans enhedstype_aNs hovedSPeciale_aNS rEgIon_aNS dato_staRt tidspUnKt_start dato_slut Tidspunkt_slut soRenhed_heN enhedstype_hen hOvedspeciale_hen region_hen dato_henvisning tiDspunKt_henvisning henvisningsaarsag henvisningsmaade henvisning_fritvAlg afslutningsmaade forlOEBlabel lprindberetningssystem, ,;
%let LPR_F_table8 = LPR_F_forloebsmarkoerer    ,      , 0, 0,  dW_ek_forloeb dato_markoEr TidsPuNkT_MARkoEr mArkoer lprindberetningssystem, ,;
%let LPR_F_table9 = LPR_F_henvisning_tillaeg   ,      , 0, 0,  dw_ek_forloeb Dw_ek_konTAKt tillaegskode lprindberetningssystem, ,;
%let LPR_F_table10 = LPR_F_HELBREDSFORLOEB     ,      , 0, 0,  dw_ek_helbRedSforLoeb iNDireKte_FeJl_HelbredsforloeB dw_ek_fOrloeb dw_ek_foRloeb_forrige fejl_forloeb_forrige referencehieRarki referencemaade dato_stArt tidspunkt_staRT dato_slut tidSpunkt_slut helbredsforloeblabel lprindberetningssystem, ,;
%let LPR_F_table11 = LPR_F_morbarnforloeb      ,      , 0, 0,  dato_start_barn dw_ek_forloeb_barn dw_ek_forloeb_mor dw_ek_morbarnforloeb forloeblabel_barn forloeblabel_mor lprindberetningssystem, ,;
%let LPR_F_table12 = LPR_F_nyt_helbredsforloeb ,      , 0, 0,  dato_henvisning_nyt dw_ek_forloeb_forrige dw_ek_forloeb_nyt dw_ek_nyt_helbredsforloeb forloeblabel_forrige forloeblabel_nyt henvisningsaarsag_nyt lprindberetningssystem tidspunkt_henvisning_nyt, ,;
%let LPR_F_table13 = LPR_F_ORGANISATIONER      ,      , 0, 0,  kode kodetype reGion region_tekst soreNheD sorenhed_Tekst sorEnhEd_type instituTionsejer instiTutionsejer_tekst institutionsEjer_type sundhedsinstitution sundhedsinstitution_tEKsT oRG_enhed_niveau1 org_enheD_niveau1_teksT org_enhed_niveau2 org_enhed_niveau2_tekst org_enHed_niveau3 org_EnheD_niveau3_teksT org_enHed_niveau4 org_eNhed_NiveAU4_tekst oRg_enHed_nIveau5 org_enhed_niveau5_tekst org_enHed_niveau6 org_enHed_niveau6_tekst org_enHed_niveau7 oRg_enheD_NIVeau7_TeksT org_enhed_niveau8 org_enhed_nIveaU8_tekSt org_enhed_niveaU9 org_enhed_niveau9_tekst oRg_enheD_niveau10 org_enheD_nIveau10_tEksT org_enhED_NivEAu11 org_eNhEd_niveau11_tekst org_enheD_niveau12 org_enhed_niVeau12_tekst hovEdspeciale Speciale2 speciale3 specIAlE4 speciale5 speciale6 speciale7 speciale8 speciale_samlet datO_lukket shak_sgh shaK_sgh_tekst Shak_afd shak_afd_tekst sHak_afs shak_afs_teksT ydernummer_encrypted gyldig_fra gyldig_til, ,;
%let LPR_F_table14 = LPR_F_ORGANISATIONER               ,      , 0, 0,  koDeType kode kode_tekst NIveau1 niveau1_tekst niveau2 niveau2_tEkst niveau3 niveau3_tekSt nivEau4 niveau4_tekst niveau5 niveau5_teKSt niveau6 niveau6_tekst nivEaU7 nIveau7_tekst niveau8 niveau8_tekSt nIveAu9 Niveau9_TeKst koen min_alder max_aLder gyldig_fra gyldig_tIl, ,;
%let LPR_F_tableN = 14;

