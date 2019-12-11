* PROJECT:          using SAS program to validate CRAN package "QRISK3"                                                    
* Copyright holder:          Copyright 2017 ClinRisk Ltd. 
* License: 	GPL-3 and details in  <https://qrisk.org/three/src.php> 
* Original QRISK3 algorithm:  <https://qrisk.org/three/src.php>
* PROGRAM NAME:       QRISK3_valid.sas                                                                   
* CREATED BY:      Yan Li                                                                                                                       
*                                                                                                       
* PROGRAM PURPOSE:   using SAS program to validate CRAN package "QRISK3"                                                    
* SAS VERSION:        9.3                                                                               
* OPERATING SYSTEM:   WINDOWS 10                                                                              
* FILES CREATED:                                                                                        
*                                                                                                       
********************************************************************************************************;
* MODIFICATION HISTORY                                                                                  ;
*                                                                                                       ;
*    VERSION NUMBER:  1                                                                                 ;
*    ---------------------------------------------------------------------------------------------      ;
*    CREATED BY:      Yan Li                                                                          ;
*                                                                                                       ;
*    VERSION NUMBER:  1 ;
*    Validation: we use SAS program to verify the R program. 
       we change only 1 variable each time to see whether the program is correct.
*    ---------------------------------------------------------------------------------------------      ;
*    MODIFIED BY:     <programmer's name>                                                               ;
*    DESCRIPTION:     <Provide detailed information on what changes have                                ;
*                     been made and reason>                                                             ;
*                                                                                                       ;
*    VERSION NUMBER:  3                                                                                 ;
*    ---------------------------------------------------------------------------------------------      ;
*    MODIFIED BY:     <programmer's name>                                                               ;
*    DESCRIPTION:     <Provide detailed information on what changes have                                ;
*                     been made and reason>                                                             ;
*                                                                                                       ;
********************************************************************************************************;

**** Clear the library , output and log;
dm 'output; clear;';
dm 'log; clear;';

proc datasets nolist memtype=data library=work kill;
run;
quit;

**Get the current working directory;
%let rc = %sysfunc(filename(fr,.));
%let curdir = %sysfunc(pathname(&fr));
%let rc = %sysfunc(filename(fr));

%put &curdir;

**Get the folder where the program is;
%let pathname = %sysget(SAS_EXECFILEPATH);
%put &pathname;
%let n_remove = %length(%scan(&pathname, -1, \));
%let pathname = %substr(&pathname, 1, %length(&pathname) - &n_remove-1);
%put &pathname;
**Get mother path;
%let n_remove1 = %length(%scan(&pathname, -1, \));
%let motherPath = %substr(&pathname, 1, %length(&pathname) - &n_remove1-1);
%put &motherPath;

**Read the test dataset;
**Define the path;
**Note I have made this SAS program to acquire where the file was stored;
**So do not need to change the path;

**QRISK3_2017_test;
%let QRISK3_2017_test_path = "&motherPath\RawData\QRISK3_2017_test.csv";
%let QRISK3_2019_test_path = "&motherPath\RawData\QRISK3_2019_test.csv";
%put &QRISK3_2017_test_path;
%put &QRISK3_2019_test_path;

**QRISK3_2017_test;
proc import datafile=&QRISK3_2017_test_path
        out=QRISK3_2017_test
        dbms=csv
        replace;
     getnames=yes;
run;

**QRISK3_2019_test;
proc import datafile=&QRISK3_2019_test_path
        out=QRISK3_2019_test
        dbms=csv
        replace;
     getnames=yes;
run;

**Note: if you use this macro for validation you can skip below comments;
**Otherwise if you intend to use this macro to calculate QRISK3 score;
**Please read below;

**Potential skip part starts---------------------------------------------------------------------------------------------------------------------------;
**Note: This SAS macro is different from R function;
**In the below macro, I used the variables from original QRISK3 algorithm and;
**did not map the variables to the macro (like CRAN package) as this is a validation process;
**This means if you plan to use this SAS version of QRISK3 to do calculation;
**Then you need to make your dataset has the same variable name as this test dataset;
**I provided a sample code here (if you have done specify the variable name in R package);

**The step to use this SAS macro to calculate a QRISK3 score rather than validation process;
**Step1: map and check your variable names to QRISK3 predictors according to the CRAN package "QRISK3";
**Step2: rename your variable and add dummy variables as below;
**Sample code (please double check);

/*data SAS_data;*/
/*  length QRISK_C_algorithm_score 8;*/
/*  set your_data_name;*/
/*  /*I am sorry this macro is a bit of hard-coding*/*/
/*  /*as it aims for validation rather than development*/*/
/*  /*QRISK_C_algorithm_score (you will not have for your data) was dummied to make the validation macro work*/*/
/*  /*or you could modify the macro*/*/
/*  /*Remember to remove column QRISK_C_algorithm_score and df when you done as they have no meaning,*/*/
/*  /*if it is not for validation*/*/
/*  QRISK_C_algorithm_score=0;*/
/*  /*The variable name on the left of the below equations mean the meaning of your variable in your own dataset*/*/
/*  /*Say if you have a variable called "blood" means "blood pressurement" in your data*/*/
/*  /*Then you need to modify below to make it as "blood = b_treatedhyp"*/*/
/*  rename*/
/*gender=gender age=age*/
/*atrial_fibrillation=b_AF atypical_antipsy=b_atypicalantipsy*/
/*regular_steroid_tablets=b_corticosteroids erectile_disfunction=b_impotence2*/
/*migraine=b_migraine rheumatoid_arthritis=b_ra */
/*chronic_kidney_disease=b_renal severe_mental_illness=b_semi*/
/*systemic_lupus_erythematosis=b_sle*/
/*blood_pressure_treatment=b_treatedhyp diabetes1=b_type1*/
/*diabetes2=b_type2 weight=weight height=height*/
/*ethiniciy=ethrisk heart_attack_relative=fh_cvd */
/*cholesterol_HDL_ratio=rati systolic_blood_pressure=sbp*/
/*std_systolic_blood_pressure=sbps5 smoke=smoke_cat townsend=town*/
/*  ;*/
/*run;*/

**Note run the macro below before you call the macro;
**Call this macro;
/*%QRISK3_valid(data=SAS_data, patid=ID, out=SAS_data_rst);*/

**The macro returns a dataset with columns QRISK3_SAS_score, patid, ;
**QRISK_C_algorithm_score and df (they are dummy variables if not meant for validation and remember to remove);
**Potential skip part end---------------------------------------------------------------------------------------------------------------------------;


%Macro QRISK3_valid(data, patid, out);
**retain order of the test data;
data rawData;
  set &data;
  order=_N_;
run;

**Female;
data test_q1;
    length score1 QRISK_C_algorithm_score df score dage age_1 age_2 dbmi bmi_1 bmi_2 a 8;
    set rawData (where=(gender=1)); /*Sorry but this is hard-code but enough for validation*/
Array survivor (15)  _temporary_
		(0
		0
		0
		0
		0
		0
		0
		0
		0
		0.988876402378082
		0
		0
		0
		0
		0)
	;
Array Iethrisk (9) _temporary_ (
		0,
		0.2804031433299542500000000,
		0.5629899414207539800000000,
		0.2959000085111651600000000,
		0.0727853798779825450000000,
		-0.1707213550885731700000000,
		-0.3937104331487497100000000,
		-0.3263249528353027200000000,
		-0.1712705688324178400000000
	);
Array Ismoke (5) _temporary_ (
		0,
		0.1338683378654626200000000,
		0.5620085801243853700000000,
		0.6674959337750254700000000,
		0.8494817764483084700000000
	);
    bmi= weight / ((height/100)**2);
    dage = age;
	dage=dage/10;
	age_1 = dage**(-2);
	age_2 = dage;
	dbmi = bmi;
	dbmi=dbmi/10;
	bmi_1 = dbmi**(-2);
	bmi_2 = (dbmi**(-2))*log(dbmi);

	/* Centring the continuous variables */

	age_1 = age_1 - 0.053274843841791;
	age_2 = age_2 - 4.332503318786621;
	bmi_1 = bmi_1 - 0.154946178197861;
	bmi_2 = bmi_2 - 0.144462317228317;
	rati = rati - 3.476326465606690;
	sbp = sbp - 123.130012512207030;
	sbps5 = sbps5 - 9.002537727355957;
	town = town - 0.392308831214905;

	/* Start of Sum */
	a=0;

	/* The conditional sums */

	a =a + Iethrisk[ethrisk];
	a =a + Ismoke[smoke_cat];

	/* Sum from continuous values */

	a =a+ age_1 * -8.1388109247726188000000000;
	a =a+ age_2 * 0.7973337668969909800000000;
	a =a+ bmi_1 * 0.2923609227546005200000000;
	a =a+ bmi_2 * -4.1513300213837665000000000;
	a =a+ rati * 0.1533803582080255400000000;
	a =a+ sbp * 0.0131314884071034240000000;
	a =a+ sbps5 * 0.0078894541014586095000000;
	a =a+ town * 0.0772237905885901080000000;

	/* Sum from boolean values */

	a =a+ b_AF * 1.5923354969269663000000000;
	a =a+ b_atypicalantipsy * 0.2523764207011555700000000;
	a =a+ b_corticosteroids * 0.5952072530460185100000000;
	a =a+ b_migraine * 0.3012672608703450000000000;
	a =a+ b_ra * 0.2136480343518194200000000;
	a =a+ b_renal * 0.6519456949384583300000000;
	a =a+ b_semi * 0.1255530805882017800000000;
	a =a+ b_sle * 0.7588093865426769300000000;
	a =a+ b_treatedhyp * 0.5093159368342300400000000;
	a =a+ b_type1 * 1.7267977510537347000000000;
	a =a+ b_type2 * 1.0688773244615468000000000;
	a =a+ fh_cvd * 0.4544531902089621300000000;

	/* Sum from interaction terms */
	/*Note that SAS index starts from 1 but C starts from 0*/
    if smoke_cat=2 then 	a =a+ age_1 * -4.7057161785851891000000000;
    if smoke_cat=3 then 	a =a+ age_1 * -2.7430383403573337000000000;
    if smoke_cat=4 then 	a =a+ age_1 * -0.8660808882939218200000000;
    if smoke_cat=5 then 	a =a+ age_1 * 0.9024156236971064800000000;
/*	a =a+ age_1 * (smoke_cat==1) * -4.7057161785851891000000000;*/
/*	a =a+ age_1 * (smoke_cat==2) * -2.7430383403573337000000000;*/
/*	a =a+ age_1 * (smoke_cat==3) * -0.8660808882939218200000000;*/
/*	a =a+ age_1 * (smoke_cat==4) * 0.9024156236971064800000000;*/

	a =a+ age_1 * b_AF * 19.9380348895465610000000000;
	a =a+ age_1 * b_corticosteroids * -0.9840804523593628100000000;
	a =a+ age_1 * b_migraine * 1.7634979587872999000000000;
	a =a+ age_1 * b_renal * -3.5874047731694114000000000;
	a =a+ age_1 * b_sle * 19.6903037386382920000000000;
	a =a+ age_1* b_treatedhyp * 11.8728097339218120000000000;
	a =a+ age_1 * b_type1 * -1.2444332714320747000000000;
	a =a+ age_1 * b_type2 * 6.8652342000009599000000000;
	a =a+ age_1 * bmi_1 * 23.8026234121417420000000000;
	a =a+ age_1 * bmi_2 * -71.1849476920870070000000000;
	a =a+ age_1 * fh_cvd * 0.9946780794043512700000000;
	a =a+ age_1 * sbp * 0.0341318423386154850000000;
	a =a+ age_1 * town * -1.0301180802035639000000000;

	/*Note that SAS index starts from 1 but C starts from 0*/
    if smoke_cat=2 then 	a =a+ age_2 * -0.0755892446431930260000000;
    if smoke_cat=3 then 	a =a+ age_2 * -0.1195119287486707400000000;
    if smoke_cat=4 then 	a =a+ age_2 * -0.1036630639757192300000000;
    if smoke_cat=5 then 	a =a+ age_2 * -0.1399185359171838900000000;
/*	a =a+ age_2 * (smoke_cat==1) * -0.0755892446431930260000000;*/
/*	a =a+ age_2 * (smoke_cat==2) * -0.1195119287486707400000000;*/
/*	a =a+ age_2 * (smoke_cat==3) * -0.1036630639757192300000000;*/
/*	a =a+ age_2 * (smoke_cat==4) * -0.1399185359171838900000000;*/

	a =a+ age_2 * b_AF * -0.0761826510111625050000000;
	a =a+ age_2 * b_corticosteroids * -0.1200536494674247200000000;
	a =a+ age_2 * b_migraine * -0.0655869178986998590000000;
	a =a+ age_2 * b_renal * -0.2268887308644250700000000;
	a =a+ age_2 * b_sle * 0.0773479496790162730000000;
	a =a+ age_2* b_treatedhyp * 0.0009685782358817443600000;
	a =a+ age_2 * b_type1 * -0.2872406462448894900000000;
	a =a+ age_2 * b_type2 * -0.0971122525906954890000000;
	a =a+ age_2 * bmi_1 * 0.5236995893366442900000000;
	a =a+ age_2 * bmi_2 * 0.0457441901223237590000000;
	a =a+ age_2 * fh_cvd * -0.0768850516984230380000000;
	a =a+ age_2 * sbp * -0.0015082501423272358000000;
	a =a+ age_2 * town * -0.0315934146749623290000000;

	/* Calculate the score itself */
	score = 100.0 * (1 - (survivor[surv]) ** (exp(a)) );
	score1 = round(score,0.1);
	df = score1 - QRISK_C_algorithm_score;
run;


**Male;
data test_q2;
    length score1 QRISK_C_algorithm_score df score dage age_1 age_2 dbmi bmi_1 bmi_2 a 8;
    set rawData (where=(gender=0));
Array survivor (15)  _temporary_
		(0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0.977268040180206,
		0,
		0,
		0,
		0,
		0)
	;
Array Iethrisk (9) _temporary_ (
		0,
		0.2771924876030827900000000,
		0.4744636071493126800000000,
		0.5296172991968937100000000,
		0.0351001591862990170000000,
		-0.3580789966932791900000000,
		-0.4005648523216514000000000,
		-0.4152279288983017300000000,
		-0.2632134813474996700000000
	);
Array Ismoke (5) _temporary_ (
		0,
		0.1912822286338898300000000,
		0.5524158819264555200000000,
		0.6383505302750607200000000,
		0.7898381988185801900000000
	);
	/* Applying the fractional polynomial transforms */
	/* (which includes scaling)                      */
    bmi= weight / ((height/100)**2);
	dage = age;
	dage=dage/10;
	age_1 = dage**(-1);
	age_2 = dage**(3);
    dbmi = bmi;
	dbmi=dbmi/10;
	bmi_2 = dbmi**(-2)*log(dbmi);
	bmi_1 = dbmi**(-2);

	/* Centring the continuous variables */

	age_1 = age_1 - 0.234766781330109;
	age_2 = age_2 - 77.284080505371094;
	bmi_1 = bmi_1 - 0.149176135659218;
	bmi_2 = bmi_2 - 0.141913309693336;
	rati = rati - 4.300998687744141;
	sbp = sbp - 128.571578979492190;
	sbps5 = sbps5 - 8.756621360778809;
	town = town - 0.526304900646210;

	/* Start of Sum */
	a=0;

	/* The conditional sums */

	a =a+ Iethrisk[ethrisk];
	a =a+ Ismoke[smoke_cat];

	/* Sum from continuous values */

	a =a+ age_1 * -17.8397816660055750000000000;
	a =a+ age_2 * 0.0022964880605765492000000;
	a =a+ bmi_1 * 2.4562776660536358000000000;
	a =a+ bmi_2 * -8.3011122314711354000000000;
	a =a+ rati * 0.1734019685632711100000000;
	a =a+ sbp * 0.0129101265425533050000000;
	a =a+ sbps5 * 0.0102519142912904560000000;
	a =a+ town * 0.0332682012772872950000000;

	/* Sum from boolean values */

	a =a+ b_AF * 0.8820923692805465700000000;
	a =a+ b_atypicalantipsy * 0.1304687985517351300000000;
	a =a+ b_corticosteroids * 0.4548539975044554300000000;
	a =a+ b_impotence2 * 0.2225185908670538300000000;
	a =a+ b_migraine * 0.2558417807415991300000000;
	a =a+ b_ra * 0.2097065801395656700000000;
	a =a+ b_renal * 0.7185326128827438400000000;
	a =a+ b_semi * 0.1213303988204716400000000;
	a =a+ b_sle * 0.4401572174457522000000000;
	a =a+ b_treatedhyp * 0.5165987108269547400000000;
	a =a+ b_type1 * 1.2343425521675175000000000;
	a =a+ b_type2 * 0.8594207143093222100000000;
	a =a+ fh_cvd * 0.5405546900939015600000000;

	/* Sum from interaction terms */
	/*Note that SAS index starts from 1 but C starts from 0*/
    if smoke_cat=2 then 	a =a+ age_1 * -0.2101113393351634600000000;
    if smoke_cat=3 then 	a =a+ age_1 * 0.75268676447503191000000000;
    if smoke_cat=4 then 	a =a+ age_1 * 0.99315887556405791000000000;
    if smoke_cat=5 then 	a =a+ age_1 * 2.1331163414389076000000000;
/*	a =a+ age_1 * (smoke_cat==1) * -0.2101113393351634600000000;*/
/*	a =a+ age_1 * (smoke_cat==2) * 0.7526867644750319100000000;*/
/*	a =a+ age_1 * (smoke_cat==3) * 0.9931588755640579100000000;*/
/*	a =a+ age_1 * (smoke_cat==4) * 2.1331163414389076000000000;*/

    a =a+ age_1 * b_AF * 3.4896675530623207000000000;
	a =a+ age_1 * b_corticosteroids * 1.1708133653489108000000000;
	a =a+ age_1 * b_impotence2 * -1.5064009857454310000000000;
	a =a+ age_1 * b_migraine * 2.3491159871402441000000000;
	a =a+ age_1 * b_renal * -0.5065671632722369400000000;
	a =a+ age_1* b_treatedhyp * 6.5114581098532671000000000;
	a =a+ age_1 * b_type1 * 5.3379864878006531000000000;
	a =a+ age_1 * b_type2 * 3.6461817406221311000000000;
	a =a+ age_1 * bmi_1 * 31.0049529560338860000000000;
	a =a+ age_1 * bmi_2 * -111.2915718439164300000000000;
	a =a+ age_1 * fh_cvd * 2.7808628508531887000000000;
	a =a+ age_1 * sbp * 0.0188585244698658530000000;
    a =a+ age_1 * town * -0.1007554870063731000000000;

	/*Note that SAS index starts from 1 but C starts from 0*/
    if smoke_cat=2 then 	a =a+ age_2 * -0.0004985487027532612100000;
    if smoke_cat=3 then 	a =a+ age_2 * -0.0007987563331738541400000;
    if smoke_cat=4 then 	a =a+ age_2 * -0.0008370618426625129600000;
    if smoke_cat=5 then 	a =a+ age_2 * -0.0007840031915563728900000;
/*	a =a+ age_2 * (smoke_cat==1) * -0.0004985487027532612100000;*/
/*	a =a+ age_2 * (smoke_cat==2) * -0.0007987563331738541400000;*/
/*	a =a+ age_2 * (smoke_cat==3) * -0.0008370618426625129600000;*/
/*	a =a+ age_2 * (smoke_cat==4) * -0.0007840031915563728900000;*/

	a =a+ age_2 * b_AF * -0.0003499560834063604900000;
	a =a+ age_2 * b_corticosteroids * -0.0002496045095297166000000;
	a =a+ age_2 * b_impotence2 * -0.0011058218441227373000000;
	a =a+ age_2 * b_migraine * 0.0001989644604147863100000;
	a =a+ age_2 * b_renal * -0.0018325930166498813000000;
	a =a+ age_2* b_treatedhyp * 0.0006383805310416501300000;
	a =a+ age_2 * b_type1 * 0.0006409780808752897000000;
	a =a+ age_2 * b_type2 * -0.0002469569558886831500000;
	a =a+ age_2 * bmi_1 * 0.0050380102356322029000000;
	a =a+ age_2 * bmi_2 * -0.0130744830025243190000000;
	a =a+ age_2 * fh_cvd * -0.0002479180990739603700000;
	a =a+ age_2 * sbp * -0.0000127187419158845700000;
	a =a+ age_2 * town * -0.0000932996423232728880000;

	/* Calculate the score itself */
	score = 100.0 * (1 - (survivor[surv])**exp(a) );
	score1 = round(score,0.1);
	df = score1 - QRISK_C_algorithm_score;
run;

data outtmp;
  set test_q1 test_q2;
  rename score1=SAS_QRISK3_score;
  keep &patid QRISK_C_algorithm_score score1 df order;
run;

proc sort data=outtmp out=&out (drop=order);
  by order;
run;

**print results for validation;
proc print data=&out;
run;
%Mend QRISK3_valid;

**2017 test;
%QRISK3_valid(data=QRISK3_2017_test, patid=ID, out=QRISK3_2017_rst);

**2019 test;
%QRISK3_valid(data=QRISK3_2019_test, patid=ID, out=QRISK3_2019_rst);

**See the max value of difference between SAS and C_algorithm score;
proc sql noprint;
   select max(df) into: df_max_2017 from QRISK3_2017_rst;
   select max(df) into: df_max_2019 from QRISK3_2019_rst;
quit

/*Both should be 0*/
%put the maximum difference between QRISK3 SAS macro and QRISK3 original C algorithem in 2017 test data is;
%put &df_max_2017;
%put the maximum difference between QRISK3 SAS macro and QRISK3 original C algorithem in 2019 test data is;
%put &df_max_2019;
