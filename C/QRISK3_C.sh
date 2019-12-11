#This sh files contain instructrions how to direct call C function to validate R package "QRISK3"
#The original QRISK3 C algorithm copyrights to ClinRisk Ltd. 
#This file was created by Yan Li

#Step1: open command prompt if in windows
#give the path where you store the folder QRISK3_valid\C
#and copy paste and run below command using command prompt
cd "ChangeToYourPath\QRISK3_valid\C"

#Step2: Before compile read comments of files including Use_QRISK3_C_female.c, 
#QRISK3.h and Use_QRISK3_C_male.c

#compile
#copy paste and run below command (line without #) using command prompt
#This would give you an .exe called "One_C_female.exe" or "One_C_male.exe" in windows
#Double click .exe to get the calculated risk score from command prompt
#Sorry but each compile would only return one patients' risk score
#Unless you wish to re-invent data structure in C (low-level language)
#female
gcc -o One_C_female Use_QRISK3_C_female.c
#male
gcc -o One_C_male Use_QRISK3_C_male.c

#Suggest validation process
#Change patients' value of risk factor according to QRISK3_2019_test.csv or QRISK3_2017_test.csv
#in Use_QRISK3_C_female.c or Use_QRISK3_C_male.c and compile
#See whether it returns the same score recorded in the column of "QRISK_C_algorithm_score" from QRISK3_2019_test.csv or QRISK3_2017_test.csv


