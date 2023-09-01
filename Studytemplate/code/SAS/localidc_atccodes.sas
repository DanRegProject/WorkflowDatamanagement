/*

*/
/*
 Use this file for diagnose (LPR), operation (OPR), procedure (UBE), prescription (ATC), laboratory data (LAB) that are not available in the general codelists;
 Eventually consider these codes to be included in the general list;

 See macros/SAS/ICD_ATC_codes for how to write the code groups, or use the macro in icd_atcdefines.sas
 %macro ICD_ATCdefines(type, name, short_txt, code, icd8="");
 */
/* example
%ICD_ATCdefines(LPR, slemdiag, "det gør ondt, av av", D666, icd8=666);
*/

