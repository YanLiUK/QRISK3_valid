//This C program used C version of QRISK3 to verify the R package "QRISK3"
//It directly calls the original QRISK3 C algorithm
//Original QRISK3 C algorithm can be found from <https://qrisk.org/three/src.php>
//Copyright of QRISK3 C algorithm: Copyright 2017 ClinRisk Ltd.
//Author of this validation program: Yan Li

#include<stdio.h>
#include<math.h>
//include QRISK3 function
#include "QRISK3.h"

int main()
{  //Initialise results
    double exmale = 0;
    //Since C code are low level language so it does not dataframe structure
    //Below code calculates one hypothetical patients' risk score
    //By manually change the value according to QRISK3_2017_test.csv and QRISK3_2019_test.csv
    //To obtain QRISK_C_algorithm_score
    //Sorry this is a lot of labour unless you wish to re-invent data structure in C
    //For testing purpose, I suggest to randomly pick patients from about two csv files
    //and see whether I recorded them correctly

    //male example
    //The below corresponding to the first male patient (line 27) in QRISK3_2019_test.csv
    //do note that ethrisk is the same as ethrisk in csv file
    //but value of smoke_cat should be smoke_cat - 1 from csv file
    //The reason is the csv files were created for R which has index starts from 1
    //C has index starts from 0 and the vector of ethrisk and smoke_cat are a bit different
    //between C code and R code
    //see head file QRISK3.h to find out
    int age = 64, b_AF = 0, b_atypicalantipsy = 0, b_corticosteroids = 0, b_impotence2 = 0, b_migraine = 0, b_ra = 0,
        b_renal = 0, b_semi = 0, b_sle = 0, b_treatedhyp = 0, b_type1 = 0, b_type2 = 0;
    double weight = 80, height = 178;
    double bmi = weight / ((height / 100) * (height / 100));
    int ethrisk = 2, fh_cvd = 0; //note for ethrisk the C code should start from 0 but this original C program
                                 // has two 0 (stand for white and unknown) so the ethrisk is the same as R code
                                 //i.e. if R has ethrisk=2, so this C code should also have ethrisk=2
    double rati = 4, sbp = 180, sbps5 = 20;
    int smoke_cat = 0, surv = 10; //C starts from 0, so smoke_cat is 1 in R but should be 0 in here.
    double town = 0.0;

    // original QRISK3 does not have gender, we could use the same patients characterisit but different gender to compare
    // calculate QRISK3 score female
    exmale = cvd_male_raw(age, b_AF, b_atypicalantipsy, b_corticosteroids, b_impotence2, b_migraine, b_ra,
                          b_renal, b_semi, b_sle, b_treatedhyp, b_type1, b_type2, bmi, ethrisk, fh_cvd,
                          rati, sbp, sbps5, smoke_cat, surv, town);
    printf("male risk is %lf \n", exmale);
    system("pause");
    return 0;
}