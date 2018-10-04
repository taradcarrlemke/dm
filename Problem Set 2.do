* Problem Set 2 Do File
* Tara Carr-Lemke
* October 4, 2018

version 15
set more off
cap log close //to suppress error
sysdir

/**************/
/***navigate***/
/**************/

pwd //to see where we are
ls //to list what we have

cd C:\Users\tdc57\Desktop
/*************************/
/***import/export/clean***/
/************************/

// First look at ILRC data
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
d
lookfor county
ta county
lookfor state
ta state

sort county state
l county state if county==county[_n-1] & state==state[_n-1]
drop if county==county[_n-1] & state==state[_n-1] 

destring *, replace
destring *, replace ignore(",")

//Eliminate categories of 8 and 31
replace ilrctotal=. if ilrctotal==8
replace ilrctotal=. if ilrctotal==31

//Correct addition error
replace ilrctotal = 3 in 811

//Explain what the 7 valid categories are: 
//1) No 287(g) agreement with Immigration and Customs Enforcement (ICE) 
//2) No contract with ICE to detain immigrants in county detention facilities 
//3) Restriction or refusal to hold individuals after their release date on the basis of ICE detainers (“ICE holds”)
//4) Policy against notifying ICE of release dates and times or other information about inmate status (“ICE alerts”)
//5) Prohibition against ICE in jails or requirement of detainee consent before ICE is allowed to interrogate 
//6) Prohibition against asking about immigration status
//7) General prohibition on providing assistance and resources to ICE to enforce civil immigration laws
//ILRC assigns a "1" for each category above for which the county is implementing the policy. Aggregates total. Lists total in "ILRC Total" category.

//Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==0

//Eliminate missing values
drop if ilrctotal==.

//I want to see the range of sanctuary levels. I call 1-2 "anti-sanctuary." 75% of counties have anti-sanctuary or anti-immigrant law enforcement policies in place.
tab ilrctotal, mi 

keep ilrctotal state

save a1, replace
use a1, clear
tab ilrctotal state
collapse ilrctotal, by(state)
l
save a1, replace
//alternative code: bys state: egen avg_ilrctotal=mean (ilrctotal) //to find the average ILRC totals by state
//sort state avg_ilrctotal ilrctotal
//l state avg_ilrctotal ilrctotal, sepby(state)
//drop avg_ilrctotal


///Now look at Harvard YouGov data
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
sum
tab inputstate //To view participation by state.
//Two questions relate to immigration.
//First is CC16_301d: most important problem is immigration
//Question read: How important are each of these issues (a variety of issues were provided) to you? Very High/Somewhat High/Somewhat Low/Very Low/None. Immigration is one of the choices.
//Second is CC16_331_1-9: what do you think the U.S. government should do about immigration? Select all that apply.
tab CC16_301d //76% of participants id issue as high or very high importance
tab CC16_331_7 //43% of participants say "illegal" immigrants should be id'ed and deported
rename CC16_301d imm_big_problem
rename CC16_331_7 prodeportation
rename inputstate state
keep imm_big_problem prodeportation state
tab imm_big_problem  
tab prodeportation 
collapse imm_big_problem, by(state) 
save a2, replace
list
//in future could also look at collapse prodeportation, by(state)


/*******************/
/***combine data***/
/******************/
use a1, clear //master 
list
merge 1:1 state using a1



 




