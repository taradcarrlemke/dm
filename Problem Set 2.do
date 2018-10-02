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

/********************/
/***import/export***/
/*******************/

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

tab ilrctotal, mi //I want to see the range of sanctuary levels. 75% of counties have anti-sanctuary or anti-immigrant law enforcement policies in place.
save a1, replace

///Now look at Harvard YouGov data
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20."
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download"
tab inputstate
save a2, replace

/*******************/
/***combine data***/
/******************/
use a1, clear //master 
merge 1:1 state using a1





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



