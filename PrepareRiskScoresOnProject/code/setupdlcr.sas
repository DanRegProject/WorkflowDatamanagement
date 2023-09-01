%macro setupDLCR;

%start_log(&logdir, DLCRdata, option=new );
%start_timer(DLCRdata);


%include "F:/Projekter/FSEID0000NNNN/MasterCode/code/dropmiss.sas";

/*Variabler til basisdatasaet*/
%let DLCRbaselist = pnr sex /*birthdate*/ STARTTID_RES SlUTTId_RES DIAGNOSE_DATO HOEJDE
	VaeGT DLCO PAKKEAAR FEV1 ECOGPERFORMANCE OPDATERET_PATOBANKDIAGNOSE
	TKLASSIFIKATION_RES NKlASSIFIKATION_RES MKLASSIfIKATION_RES
	C_TKLASSIFIKATIoN C_NKLASSIFIkATION C_MKLAssIFIkATIoN C_STADIE
	C_UNDERSTADIE STATuS_DATo STAtuS DXREGION_TEXT nAVnaFDELING
	birthyear birthmonth status /*description*/ /*statusdate deathdate
	vitalstatus inper_out_date inper_in_date*/;

/*Variabler til kirurgidatasaet*/
%let DLCRkirlist = pnr sex /*birthdate*/ EsTFEV1 ECOGPERFORMANCE OPDAtEReT_PATOBaNKdIAGNOsE
	TkLASSIfIkATIoN_RES NKlAssiFIKATIoN_RES MklaSSIfIKATIon_RES
	C_TKLASSIFIKatION c_nkLASsIfikATION C_mKLAsSIfIKATION C_STaDIE
	C_UNdERSTADIE PTNM_kENDt P_TKLaSSIFIKAtiOn P_NKLASSIFIKATIoN
	P_MKLASSiFikATION p_StAdIE P_UNDErStADIE StATUS_dATO STATUS
	XLCNEOADJuVERENDEBEHQUAD_RES kIRrisK_reS XLCrISKKOL_REs
	XLCRiSKmBCORdIS_RES XLCRISKaNDRe_RES ALKOHOLQUAD
	XLCOPERAtIONSDATO_RES XLCKIrOpTYPE XLCTORAKOToMIADg MuSCLESPARINGQUAD
	XLCKLAS XLCLOK XLCbiLObekTOMILOK XLCPNeUCoMPLLOK_REs XLcTHORAXVaeGSRESEKT
	iNDSaTPaTCH XLCOPBRoNKIEURES XLcTuMORFJERNeTMAKRo FUNGSEGMENTER
	FJERNSEGMENtER XlcTUMORfJERNETMIKRO PATOLOGI_RES XLCPOSTOPERaTIVT
	XLCPOSTKOMPL01 XLCPoSTkOMPL02 XlCARYTMITyPE XLCPOSTKOMpL03
	XLCPOSTKOMPL04 xLCPOSTkOMPL05 XLCPOSTKOMPL06 XLCPOStKOMPL07
	XLCPOSTKOMPL08 XLCPOSTkOMPl09 XlCpoSTKOMPl10 XLCRESPIRATORBEhaNdL
	XLCpOstKOMPL11 XLCPOstKoMPL12 XLcPoSTkOMPL13 XLCPosTKomPL14 xLCPOsTKOMPL15
	XLCPOSTKOMpL16 XLCINTENSIVAFDELInG XLCINTENSIVAFddAGE xLCOvERfLYTTETANAFDQUAD
	XLCVIdEREFORlOeB XLCKIRURGIHENVDAtO_RES XLcKiRuRGIINDLdATO_RES
	XLCUDSKRiVELSeDaTo_RES status /*description statusdate deathdate vitalstatus*/;

/*variabler til onkologidatasaet*/
%let DLCRonkolist = pnr sex birthdate STArTTID_rES SLUTTID_reS DIAGnOsE_DAtO ECOGPERFoRMaNCE
	OPDATERET_PATOBANKDIAGNOSE TKLaSSIfIKATIOn_ReS NKLASSIfiKATION_RES
	MKlASSIFiKatiOn_reS C_tKLASsifiKAtION c_NKLAsSIFIkATION C_MKlASSIFiKaTiON
	C_STADIE C_UNDErSTADIE STATUS_DATO StATUS BEHANDLING_START_rES ONKVENTETID
	ONKVENTEAARSAG beHaNDLING_kEmO BEHAnDLING_STR BEHANDLING_STR_FRAC
	BEHANDLING_STR_GY BehANDlInG_ANDEN BEHANDLING_TYPE_Res status /*description
	statusdate deathdate vitalstatus*/;

%let DLCR1data = in0NNNN.DS_EXT_DLCR_2019_06_19_V2;
%let DLCR2data = in0NNNN.DS_EXT_DLCR_20190619V20191210;



/*get all variables into macro variable : varlist*/
proc sql noprint;
	select name into: varlist separated by ' ' from dictionary.columns
	where upcase(libname) = 'IN0NNNN'
	and upcase(memname) = 'DS_EXT_DLCR_2019_06_19_V2'
	and xtype ne 'date'
	;
quit;
run;

proc sql noprint;
	select name into: varlistsks separated by ' ' from dictionary.columns
	where upcase(libname) = 'IN0NNNN'
	and upcase(memname) = 'DS_EXT_DLCR_2019_06_19_V20191210'
	and xtype ne 'date'
	;
quit;
run;

/* split data by variables formular */
data dlcrbase_all
	 dlcrkir_all
	 dlcronko_all;
set in0NNNN.DS_EXT_DLCR_2019_06_19_V2;
if formular = 'Udredning' then output dlcrbase_all;
if formular = 'Onkologi' then output dlcronko_all;
if formular = 'Kirurgi' then output dlcrkir_all;
run;

data dlcrsks_all;
set in0NNNN.DS_EXT_DLCR_2019_06_19_V20191210;
run;

/* change NA values to missing in all variables in macro varlist */
%macro remove_NA_cols(data,varlist);
%let nvar = %sysfunc(countw(&varlist));
data &data;
set &data;
	%do i= 1 %to &nvar;
		%let var = %scan(&varlist,&i);
		%put &var;
		if &var eq 'NA' then &var = '';
	%end;
run;

%mend;
%remove_NA_cols(dlcrbase_all,&varlist);
%remove_NA_cols(dlcrkir_all,&varlist);
%remove_NA_cols(dlcronko_all,&varlist);

%remove_NA_cols(dlcrsks_all,&varlistsks);

/* remove variables from all missing in base/kir/onko data */

%dropmiss(dlcrbase_all,dlcrbase);
%dropmiss(dlcronko_all,dlcronko);
%dropmiss(dlcrkir_all,dlcrkir);

%dropmiss(dlcrsks_all,dlcrsks);

/* rename all variables to add a surfix (base,kir,onko) */

%include "F:\Projekter\FSEID0000NNNN\MasterCode\code\rename_macro.sas";
%renaming_variables(inlib=work,data=dlcrbase,outlib=dlcrdata,surfix=base);
%renaming_variables(inlib=work,data=dlcrkir,outlib=dlcrdata,surfix=kir);
%renaming_variables(inlib=work,data=dlcronko,outlib=dlcrdata,surfix=onko);

data dlcrdata.dlcrsks;
set dlcrsks;
run;

%end_timer(DLCRdata, text=execution time dividing DLCR data into base, kir and onko);
%end_log;

%mend;

*%setupdlcr;
