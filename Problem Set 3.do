* Problem Set 3 Do File
* Tara Carr-Lemke
* October 11, 2018

version 15  //this ensures your grandkids will run this fine :)
set more off  //will run everything
cap log close //to suppress error
log using tara.txt, replace text //but before you start log, you need to close if it was opened
//and then can close
log close
sysdir //to see where stata saves

/**************/
/***navigate***/
/**************/

pwd //to see where we are
ls //to list what we have

cd C:\Users\tdc57\Desktop
/*************************/
/***import/export/clean***/
/******* merge 1 ********/
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

destring *, replace
destring *, replace ignore(",")

hist ilrctotal, percent //for key var of interest do a histogram or tab

//Eliminate categories of 8 and 31
replace ilrctotal=. if ilrctotal==8
replace ilrctotal=. if ilrctotal==31

//Correct addition error
replace ilrctotal = 3 in 811

//Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==0

hist ilrctotal, percent //to check and see if data looks cleaned

//Eliminate missing values
drop if ilrctotal==.

//Explain what the 7 valid categories are: 
//1) No 287(g) agreement with Immigration and Customs Enforcement (ICE) 
//2) No contract with ICE to detain immigrants in county detention facilities 
//3) Restriction or refusal to hold individuals after their release date on the basis of ICE detainers (“ICE holds”)
//4) Policy against notifying ICE of release dates and times or other information about inmate status (“ICE alerts”)
//5) Prohibition against ICE in jails or requirement of detainee consent before ICE is allowed to interrogate 
//6) Prohibition against asking about immigration status
//7) General prohibition on providing assistance and resources to ICE to enforce civil immigration laws
//ILRC assigns a "1" for each category above for which the county is implementing the policy. Aggregates total. Lists total in "ILRC Total" category.

tab ilrctotal, mi //I want to see the range of sanctuary levels. I call 1-2 "anti-sanctuary." 75% of counties have anti-sanctuary or anti-immigrant law enforcement policies in place.

keep ilrctotal state //I only want to analyze these variables

tab  state ilrctotal
collapse ilrctotal, by(state) //I want a state average of ILRC totals
l
save a1, replace
use a1, clear 

///Now look at Harvard YouGov data
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
sum
tab inputstate //To view participation by state.
//A question relate to immigration
//Question CC16_301d: most important problem is immigration
//Question reads: How important are each of these issues (a variety of issues were provided) to you? Very High/Somewhat High/Somewhat Low/Very Low/None. Immigration is one of the choices.
tab CC16_301d //76% of participants id issue as high or very high importance
rename CC16_301d imm_big_problem
rename inputstate state
keep imm_big_problem state
tab imm_big_problem, mi  //about 20% of total respondents identified immigration as their top issue
collapse imm_big_problem, by(state) //I want a state average
l

decode state, gen(state3)

drop state
ren state3 state
gen state2=""

replace state2="AL"		if state=="Alabama"
replace state2="AK"		if state=="Alaska"
replace state2="AZ"		if state=="Arizona"
replace state2="AR"		if state=="Arkansas"
replace state2="CA"		if state=="California"
replace state2="CO"		if state=="Colorado"
replace state2="CT"		if state=="Connecticut"
replace state2="DE"		if state=="Delaware"
replace state2="DC"		if state=="District of Columbia"
replace state2="FL"		if state=="Florida"
replace state2="GA"		if state=="Georgia"
replace state2="HI"		if state=="Hawaii"
replace state2="ID"		if state=="Idaho"
replace state2="IL"		if state=="Illinois"
replace state2="IN"		if state=="Indiana"
replace state2="IA"		if state=="Iowa"
replace state2="KS"		if state=="Kansas"
replace state2="KY"		if state=="Kentucky"
replace state2="LA"		if state=="Louisiana"
replace state2="ME"		if state=="Maine"
replace state2="MD"		if state=="Maryland"
replace state2="MA"		if state=="Massachusetts"
replace state2="MI"		if state=="Michigan"
replace state2="MN"		if state=="Minnesota"
replace state2="MS"		if state=="Mississippi"
replace state2="MO"		if state=="Missouri"
replace state2="MT"		if state=="Montana"
replace state2="NB"		if state=="Nebraska"
replace state2="NV"		if state=="Nevada"
replace state2="NH"		if state=="New Hampshire"
replace state2="NJ"		if state=="New Jersey"
replace state2="NM"		if state=="New Mexico"
replace state2="NY"		if state=="New York"
replace state2="NC"		if state=="North Carolina"
replace state2="ND"		if state=="North Dakota"
replace state2="OH"		if state=="Ohio"
replace state2="OK"		if state=="Oklahoma"
replace state2="OR"		if state=="Oregon"
replace state2="PA"		if state=="Pennsylvania"	
replace state2="PR"		if state=="Puerto Rico"
replace state2="RI"		if state=="Rhode Island"
replace state2="SC"		if state=="South Carolina"
replace state2="SD"		if state=="South Dakota"
replace state2="TN"		if state=="Tennessee"
replace state2="TX"		if state=="Texas"
replace state2="UT"		if state=="Utah"
replace state2="VT"		if state=="Vermont"
replace state2="VA"		if state=="Virginia"
replace state2="WA"		if state=="Washington"
replace state2="WV"		if state=="West Virginia"
replace state2="WI"		if state=="Wisconsin"
replace state2="WY"		if state=="Wyoming"

drop state
rename state2 state
save a2, replace
l

/*******************/
/***combine data***/
/*****merge 1******/
/******************/
use a1, clear //master 
list
merge 1:1 state using a2 //using 
//47 matched. 5 had master only data. 2 had using only data. PR and Guam are not surprising. 

//and now may wanna save this--the purpose of merge is to get the new data!
//later on may want to merge everything together if possible

/*************************/
/***import/export/clean***/
/******* merge 2 ********/
/************************/

///Harvard YouGov data
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
sum
tab inputstate //To view participation by state.
//Another question related to immigration.
//Question CC16_331_1-9: what do you think the U.S. government should do about immigration? Select all that apply.
tab CC16_331_7 //43% of participants say "illegal" immigrants should be id'ed and deported
rename CC16_331_7 prodeportation
rename inputstate state
keep prodeportation state
tab prodeportation, mi
collapse prodeportation, by(state) //I want a state average
l

decode state, gen(state3)

drop state
ren state3 state
gen state2=""

replace state2="AL"		if state=="Alabama"
replace state2="AK"		if state=="Alaska"
replace state2="AZ"		if state=="Arizona"
replace state2="AR"		if state=="Arkansas"
replace state2="CA"		if state=="California"
replace state2="CO"		if state=="Colorado"
replace state2="CT"		if state=="Connecticut"
replace state2="DE"		if state=="Delaware"
replace state2="DC"		if state=="District of Columbia"
replace state2="FL"		if state=="Florida"
replace state2="GA"		if state=="Georgia"
replace state2="HI"		if state=="Hawaii"
replace state2="ID"		if state=="Idaho"
replace state2="IL"		if state=="Illinois"
replace state2="IN"		if state=="Indiana"
replace state2="IA"		if state=="Iowa"
replace state2="KS"		if state=="Kansas"
replace state2="KY"		if state=="Kentucky"
replace state2="LA"		if state=="Louisiana"
replace state2="ME"		if state=="Maine"
replace state2="MD"		if state=="Maryland"
replace state2="MA"		if state=="Massachusetts"
replace state2="MI"		if state=="Michigan"
replace state2="MN"		if state=="Minnesota"
replace state2="MS"		if state=="Mississippi"
replace state2="MO"		if state=="Missouri"
replace state2="MT"		if state=="Montana"
replace state2="NB"		if state=="Nebraska"
replace state2="NV"		if state=="Nevada"
replace state2="NH"		if state=="New Hampshire"
replace state2="NJ"		if state=="New Jersey"
replace state2="NM"		if state=="New Mexico"
replace state2="NY"		if state=="New York"
replace state2="NC"		if state=="North Carolina"
replace state2="ND"		if state=="North Dakota"
replace state2="OH"		if state=="Ohio"
replace state2="OK"		if state=="Oklahoma"
replace state2="OR"		if state=="Oregon"
replace state2="PA"		if state=="Pennsylvania"	
replace state2="PR"		if state=="Puerto Rico"
replace state2="RI"		if state=="Rhode Island"
replace state2="SC"		if state=="South Carolina"
replace state2="SD"		if state=="South Dakota"
replace state2="TN"		if state=="Tennessee"
replace state2="TX"		if state=="Texas"
replace state2="UT"		if state=="Utah"
replace state2="VT"		if state=="Vermont"
replace state2="VA"		if state=="Virginia"
replace state2="WA"		if state=="Washington"
replace state2="WV"		if state=="West Virginia"
replace state2="WI"		if state=="Wisconsin"
replace state2="WY"		if state=="Wyoming"

drop state
rename state2 state
save a3, replace
l

/*******************/
/***combine data***/
/*****merge 2******/
/******************/

use a1, clear //master 
list
merge 1:1 state using a3 //using 
//47 matched. 5 had master only data. 2 had using only data. PR and Guam are not surprising. 


/*************************/
/***import/export/clean***/
/******* merge 3 ********/
/************************/
use https://github.com/taradcarrlemke/dm/raw/master/MI%20Correlates%20of%20State%20Policy.dta, clear
//From Correlates of State Policy from MI State
keep state undocumented_immigrants immig_laws_total immig_laws_accom immig_laws_restrict immig_laws_neut
drop undocumented_immigrants //this number ended up not being collected in most states, so unhelpful
tab immig_laws_total, mi //According to this data, only 5.6% of states passed immigration laws  
hist immig_laws_total //See that relativley few passed legislation related to immigration

sort state //many duplicates in this dataset
codebook state //to view this variable more closely 
//I next tried a series of dup codes to eliminate large number of repeats
duplicates report 
duplicates examples
duplicates list
duplicates drop

//would be easier just to say sth like:
drop if immig_laws_total==.
//and more importantly i think you miss something here (though i may be wrong!)--i guess these are over years, so
//you should have kept year variable and then only retain years that you need

drop in 1
drop in 4
drop in 5
drop in 7
drop in 8
drop in 10
drop in 12/13
drop in 14
drop in 16
drop in 18
drop in 20
drop in 23/24
drop in 28
drop in 32
drop in 33
drop in 35
drop in 41
drop in 43
drop in 45/46
drop in 46
drop in 49
drop in 53
drop in 54
drop in 56
drop in 58
drop in 61/62
drop in 62
drop in 64
drop in 65
drop in 67
drop in 69/70
drop in 75/76
duplicates tag, generate(dup)
list if dup==1 //I was still trying to find a way to automate the dup process. I thought this command would keep the first instance only.

drop in 2
drop in 4
drop in 6
drop in 8
drop in 10
drop in 17
drop in 18/19
drop in 18
drop in 20/21
drop in 24
drop in 30
drop in 31
drop in 33/34
drop in 33/34
drop in 37
drop in 40
drop in 43
drop in 45
drop in 46
drop in 49


//I next tried finding an automatic way to switch state names for state abbreviations.
//I used the following commands but kept receiving errors.
//destring *, replace
//destring *, replace ignore(",")
//encode state, gen(state3)
//I then used the following commands (one example follows below) but kept running into issues with strings.
//replace state3="AL" if state=="Alabama"
//I also tried the following commands to take a different tack, but did not have suucess.
//drop state
//ren state3 state
//gen state2=""
//replace state2="AL" if state=="Alabama" (as one example)
//So I decided to change abbreviations manually

replace state = "AL" in 1
replace state = "AK" in 2
replace state = "AZ" in 3
replace state = "AR" in 4
replace state = "CA" in 5
replace state = "CO" in 6
replace state = "CT" in 7
replace state = "DE" in 8
replace state = "DC" in 9
replace state = "FL" in 10
replace state = "GA" in 11
replace state = "HI" in 12
replace state = "ID" in 13
replace state = "IL" in 14
replace state = "IN" in 15
replace state = "IO" in 16
replace state = "KS" in 17
replace state = "KY" in 18
replace state = "LA" in 19
replace state = "ME" in 20
replace state = "MD" in 21
replace state = "MA" in 22
replace state = "MI" in 23
replace state = "MN" in 24
replace state = "MI" in 25
replace state = "MO" in 26
replace state = "MT" in 27
replace state = "NE" in 28
replace state = "NV" in 29
replace state = "NH" in 30
replace state = "NJ" in 31
replace state = "NM" in 32
replace state = "NY" in 33
replace state = "NC" in 34
replace state = "ND" in 35
replace state = "OH" in 36
replace state = "OK" in 37
replace state = "OR" in 38
replace state = "PA" in 39
replace state = "RI" in 40
replace state = "SC" in 41
replace state = "SD" in 42
replace state = "TN" in 43
replace state = "TX" in 44
replace state = "UT" in 45
replace state = "VT" in 46
replace state = "VA" in 47
replace state = "WA" in 48
replace state = "WV" in 49
replace state = "WI" in 50
replace state = "WY" in 51

save a4, replace
l

/*******************/
/***combine data***/
/*****merge 3******/
/******************/
use a1, clear //master 
list
merge 1:1 state using a4
//variable state was str11, now str23 to accommodate using
//variable state does not uniquely identify observations in the using
//yes that's the problem--so in a4 state is not unique, and you said it is: 1:1
use a4
sort state
l if state==state[_n-1] //and MI! if you fix that it merges fine
//btw great work, almost there, wish others did that much

/*************************/
/***import/export/clean***/
/******* merge 4 ********/
/************************/

/*******************/
/***combine data***/
/*****merge 4******/
/******************/


/*************************/
/***import/export/clean***/
/******* merge 5 ********/
/************************/

/*******************/
/***combine data***/
/*****merge 5******/
/******************/

