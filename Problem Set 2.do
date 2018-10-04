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
bys state: egen avg_ilrctotal=mean (ilrctotal) //to find the average ILRC totals by state
collapse avg_ilrctotal, by(state)
//is line 69 legit?????

//gen avg_stateilrctotal=.
//egen avg_ilrctotal, by(state)=mean (ilrctotal)
//egen avg_ilrctotal=mean (ilrctotal)
//sum avg_ilrctotal 

//gen avg_stateilrctotal=.
//bys state: egen avg_ilrctotal, by(state)=mean (ilrctotal)
//bys state: egen avg_ilrctotal=mean (ilrctotal)
//sum avg_ilrctotal 


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
sample 100, count
keep imm_big_problem prodeportation state
tab imm_big_problem  
tab prodeportation 

save a2, replace
list
collapse prodeportation, by(state)
tab state

/*******************/
/***combine data***/
/******************/
use a1, clear //master 
list
merge 1:1 ilrctotal using a2

use a2, clear
merge 1:1 state using a2

//below is adam's code
//use a1, clear //master 
//ta state //it is not unique!
//so you need to collapse it in one dataset! and then do m:1; 
//so one dataset would have state level data, and the other one person level; the one for state level, needs to unique
//collapse inc educ, by(region)(mean is default)
// collapse (count) id, by(marital
//list
//merge 1:1 state using a2

//use a2, clear
//merge 1:1 state using a2


////don't worry about code below

gen id= _n
keep id region
save gss1dta., replace
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear 
gen id= _n
keep id inc 

save "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", replace
d
sum
insheet  using "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear 

 // OR Now look at GSS data
//QUESTION??? use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear 



