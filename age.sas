/*******************************************************************************
|
| Program Name:    age.sas
| Program Purpose: To calculate age based on reference date and birthdate inputs.
|                  merges datasets.
| SAS Version:     v9.4
|
| Created By:      Sushruth J. S.  
| Date:            27-Oct-2018
| Prerequisits:    
|
 ********************************************************************************/




/*---------------------------------------------------------------------
Usage:
data _null_;
   dob = "25Dec60"d;
   end = "25Dec05"d;
   age1 = %age(dob);                   * age in years from today() ;
   age2 = %age(dob,end);               * age in years from 25Dec05 ;
   age3 = %age(dob,end,units=month);   * age in months from 25Dec05 ;
   age4 = %age(dob,units=day);         * age in days from today() ;
   put (dob end) (=date7. +1) (age1-age4) (=);
run;
-----------------------------------------------------------------------*/




%macro age
/*---------------------------------------------------------------------
Determines a person's age in <units> (default = years)
based on a reference date.
---------------------------------------------------------------------*/
(BEGDATE       /* Beginning date (REQ).                              */
               /* Usually a person's DOB.                            */
,ENDDATE       /* End date (Opt).                                    */
               /* If not specified, TODAY() is used.                 */
,UNITS=YEAR    /* Units (REQ).                                       */
               /* Default is year.  Valid values are                 */
               /* Y YEAR M MONTH D DAY.                              */
);

%local macro parmerr enddate;
%let macro = &sysmacroname;

%* set default end date if it was not specified ;
%if (%superq(enddate) = %str( )) %then %let enddate = %sysfunc(today());

%* check input parameters ;
%parmv(BEGDATE,      _req=1,_words=0)
%parmv(ENDDATE,      _req=1,_words=0)
%parmv(UNITS,        _req=1,_words=0,_case=U,_val=Y YEAR M MONTH D DAY)

%if (&parmerr) %then %goto quit;

%if (%upcase(%substr(&units,1,1)) = Y) %then %do;
   floor((intck('month',&begdate,&enddate) - (day(&enddate)<day(&begdate)))/12)
%end;
%else
%if (%upcase(%substr(&units,1,1)) = M) %then %do;
   floor((intck('month',&begdate,&enddate) - (day(&enddate)<day(&begdate))))
%end;
%else
%if (%upcase(%substr(&units,1,1)) = D) %then %do;
   &enddate - &begdate
%end;

%quit:
%* if (&parmerr) %then %abort;

%mend;
