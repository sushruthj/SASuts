/*******************************************************************************
|
| Program Name:    runpval.sas
| Program Purpose: To generate PVAL report for the dataset in whose code this macro is
|                  being used
| SAS Version:     v9.4
|
| Created By:      Sushruth J. S.  
| Date:            12-Oct-2018
| Prerequisits:    Should have PVAL utility pre-compiled in UNIX as a executible
|
 ********************************************************************************/


%macro ru_pval(redir=%nrstr(/home/Desktop/Example/directory), emailid=%nrstr(username@email.com));
	%let switch= %symexist(_clientapp);

	%if &switch eq 1 %then
		%do;

			%if &_clientapp eq SAS Studio %then
				%do;
					%put WARNING: This pval utility cannot be run on the SAS Studio edition.;
					%put WARNING: Please run this utility in Unix/RedHat UI.;
					%put WARNING: Ending execution of macro.;
				%end;
		%end;
	%else %if &sysscpl ne Linux and &switch eq 0 %then
		%do;
			%put WARNING: This pval utility uses pval Unix command, where PVAL is compiled as executable.;
			%put WARNING: Operating system is not supported.;
		%end;
	%else %if &switch eq 0 and &sysscpl eq Linux %then
		%do;
			x ls &redir/qc/ > 
				&redir/qc/temp.txt;

			data a;
				infile "&redir/qc/temp.txt";
				input folders :$100.;

				if lowcase(folders)="pval";
			run;

			proc sql noprint;
				select * from a;
			quit;

			%put &sqlobs;

			%if &sqlobs=0 %then
				%do;
					options dlcreatedir;
					libname pval "&redir/qc/pval";
					x ls &redir/qc/pval > 
						&redir/qc/temp.txt;
				%end;

			data c;
				infile "&redir/qc/temp.txt";
				input folders :$100.;

				if lowcase(folders)="temp";
			run;

			proc sql noprint;
				select * from c;
			quit;

			%put &sqlobs;

			%if &sqlobs=0 %then
				%do;
					libname tempdat "&redir/qc/pval/temp";
				%end;
			x echo $(grep 'rc_\|rd_\|tc_\|td_\|ru_'  -m1 %sysfunc(getoption(sysin)) 
				| sed 's/[%()]//g') > &redir/qc/temp.txt;

			data _null_;
				infile "&redir/qc/temp.txt";
				input dataset :$100.;
				call symput ("dataset", compress(scan(dataset, 2, "_")));
			run;

			%put &dataset;
			x cp &redir/adamdata/&dataset..sas7bdat 
				&redir/qc/pval/temp;

			data a;
				length a $200;
				file "&redir/qc/pval/temp/&dataset..parm";
				a="STUDY_ID=MID203162";
				output;
				put a;
				a="SOURCE=&redir/qc/pval/temp";
				output;
				put a;
				a="TYPE=ADaM";
				output;
				put a;
				a="CONFIG_FILE=ADaM_1.0_FDA.xml";
				output;
				put a;
				a="CONFIG_DEFINE=";
				output;
				put a;
				a="CONFIG_CDISC=2017-09-29";
				output;
				put a;
				a="CHECK_DATA_VAL=ADaM data only";
				output;
				put a;
				a="REPORT_NAME=&redir/qc/pval/&sysuserid..xls";
				output;
				put a;
				a="BACKGROUND_JOB=No";
				output;
				put a;
				a="BACKGROUND_JOB_EMAIL=Yes";
				output;
				put a;
				a="REPORT_OVERWRITE=Yes";
				output;
				put a;
				a="SAVE_XPT=No";
			run;

			x uname -n --> &redir/qc/temp.txt;

			data _null_;
				infile "&redir/qc/temp.txt";
				input host :$100.;
				call symput ("host", compress(host));
			run;

			%put &host;
			x pval &redir/qc/pval/temp/&dataset..parm;
			x rm &redir/qc/pval/temp/&dataset..parm;
			x rm &redir/qc/pval/temp/&dataset..sas7bdat;
			x rm &redir/qc/temp.txt;
			filename eml email "&sysuserid@gsk.com";

			data _null_;
				file eml to=("&emailid") 
					/*attach=("&redir/qc/pval/&sysuserid..xlsx")*/
					subject="PVAL Report for the dataset: &dataset";
				put "Please click on the following link to open the pval report";
				put "file:\\&host..corpnet2.com\&sysuserid\Desktop\Example\qc\pval\&sysuserid..xlsx";
                put "NOTE: Please make sure that the server &host is mapped on the Network Drive before clicking on the file";
			run;

		%end;
%mend;
