%macro pnr2lbnr(ds,invar=pnr,outvar=_pnr_,dropinvar=TRUE);
    /* funktion til at indsætte løbenummer til erstatning af SDS's pseudonymiserede lange pnr */
    /* datasættet pnr2lbnrlist dannes i xxxx.sas */
    %local tmpds;
    %let tmpds=%Newdatasetname(tmp);
    proc sql;
        create table &tmpds as
            select b.lbnr as &outvar, a.*
            from &ds a left join master.pnr2lbnrlist b
            on a.&invar = b.pnr
            order by b.lbnr;
        %runquit;
        data &ds;
            set &tmpds;
            %if &dropvar=TRUE %then drop &invar;;
        %runquit;
    %mend;
