/*******************************************************************************
|
| Program Name:    mergetool.sas
| Program Purpose: To merge datasets as listed. This tool automatically sorts and
|                  merges datasets.
| SAS Version:     v9.4
|
| Created By:      Sushruth J. S.  
| Date:            27-Oct-2018
| Prerequisits:    
|
 ********************************************************************************/


%macro mergetool (datasets=lib1.abc lib2.xyz lib3.cde,              /*****List of dataset names to be merged****/
                  byvars=var1 var2 var3 var4,                       /*****By Variables given for Merge and sort****/
		  mergeddatasetname=outdat,                         /*****Output dataset name*****/
		  indata=abc and xyz or cde);                       /*****For the In-operator used while doing match merging****/
		  
		  
		  
		%if %length(%sysfunc(compress(&datasets))) eq 0 %then
		%do;
			%put ERROR: Dataset names are needed for the macro to execute;
			%put ERROR: Terminating the macro without any further processing.;
			%abort;
		%end;

	%if %length(%sysfunc(compress(&byvars))) eq 0 %then
		%do;
			%put ERROR: By Variables must be stated in the macro variable byvars.;
			%put ERROR: Terminating the macro without any further processing.;
			%abort;
		%end;
	%put NOTE: Execution of Merge started.;

	/****Counting the number of input datasets to the macro****/
%let ndats=%sysfunc(countw(&datasets, " "));
	%put NOTE: You have given an input of &ndats datasets.;

	%do i=1 %to &ndats;
		%let dat&i = %sysfunc(scan(&datasets, &i, " "));
		%put &&dat&i;

		/*****Stripping the library name from the original input****/
		
		
		%if %sysfunc(find(&&dat&i, .)) gt 0 %then
			%do;
				%let sortdat&i = %sysfunc(scan(&&dat&i, 2, .));
				%put NOTE: A work dataset &&sortdat&i is being created to avoid sorting in the original library.;
				%let inop = %str((in=&&sortdat&i));
				%let merdat&i = &&sortdat&i &inop.;

				data &&sortdat&i;
					set &&dat&i;
				run;

			%end;
		%else
			%do;
				%let sortdat&i = &&dat&i;
				%let inop = %str((in=&&sortdat&i));
				%let merdat&i = &&sortdat&i &inop.;
				%put NOTE: Dataset &&sortdat&i will be sorted without a temporary dataset creation as it exists in work area.;
				%put NOTE: You may need to re-sort this dataset after the execution of macro is done.;
			%end;
		%put &&sortdat&i;

		/*****Generating output dataset names for proc sort*****/
		
		
		%if %symexist(datlist) eq 1 %then
			%do;

				data ___vars;
					set ___vars;
					_&i="&&merdat&i";
				run;

				%if &i=&ndats %then
					%do;

						data _null_;
							set ___vars;
							call symputx ("datlist", catx(" ", of _1 - _&ndats));
						run;

					%end;
			%end;
		%else
			%do;

				data ___vars;
					_&i="&&merdat&i";
					call symputx ("datlist", _&i);
				run;

			%end;
		%put &datlist;

		/******Sorting of data by the given byvars*****/
		proc sort data=&&dat&i out=&&sortdat&i;
			by &byvars;
		run;

	%end;

	/*******Merging of Dataset starts here****/
	data &mergeddatasetname;
		merge &datlist;
		by &byvars;

		%if %length(&indata) gt 0 %then
			%do;

				if &indata;
			%end;
	run;
	
	
%mend;

