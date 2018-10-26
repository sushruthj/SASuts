data x y z;
set sashelp.class;
if 1=1 then output x;
if sex = "F" then output y;
if age gt 13 then output z;
run;


%macro procmerge (datasets=abc, byvars=x, mergeddatasetname=outdat);
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

				data &&sortdat&i;
					set &&dat&i;
				run;

			%end;
		%else
			%do;
				%let sortdat&i = &&dat&i;
				%put NOTE: Dataset &&sortdat&i will be sorted without a temporary dataset creation as it exists in work area.;
				%put NOTE: You may need to re-sort this dataset after the execution of macro is done.;
			%end;

		/*****Generating output dataset names for proc sort*****/
		
		%if %symexist(datlist) eq 1 %then
			%do;
				%let inop = %str((in=&&sortdat&i));
				*%let datlist= %sysfunc(catx(%nrstr( ), &datlist, &&sortdat&i, &inop ));
                
                %let datlist = &datlist &&sortdat&i &inop;
				%put &datlist;
				%put &inop;
			%end;
		%else
			%do;
			    %let inop = %str((in=&&sortdat&i));
				*%let datlist= %sysfunc(catx(%nrstr( ), &&sortdat&i, &inop. ));
                %let datlist=&&sortdat&i &inop.;
				%put &inop;
			%end;

		/******Sorting of data by the given byvars*****/
	/*	proc sort data=&&dat&i out=&&sortdat&i;
			by &byvars;
		run;*/

	%end;
	
	/*******Merging of Dataset starts here****/
	
	/*data &mergeddatasetname;
	   merge &datlist;
	   by &byvars;
	run;*/
	
	
%mend;

*options mprint symbolgen;
%procmerge(datasets=work.x y z, byvars=name, mergeddatasetname=outdat);
