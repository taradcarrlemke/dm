* Problem Set 3 Do File
* Tara Carr-Lemke
* October 11, 2018

version 15  //
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

hist ilrctotal, percent //for key variable of interest do a histogram or tab

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

keep ilrctotal state //I only want to analyze these variables.

tab ilrctotal state
collapse ilrctotal, by(state) //I want a state average of ILRC totals.
l
save a1, replace
use a1, clear 

///Now look at Harvard YouGov data
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
sum
tab inputstate //To view participation by state.
//A question related to immigration
//Question CC16_301d: most important problem is immigration
//Question reads: How important is each of these issues (a variety of issues were provided) to you? Very High/Somewhat High/Somewhat Low/Very Low/None. Immigration is one of the choices.
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
save a3, replace

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
save a4, replace
l

/*******************/
/***combine data***/
/*****merge 2******/
/******************/

use a1, clear //master 
list
merge 1:1 state using a4 //using 
//47 matched. 5 had master only data. 2 had using only data. PR and Guam are not surprising. 
save a5, replace

/*************************/
/***import/export/clean***/
/******* merge 3 ********/
/************************/
use https://github.com/taradcarrlemke/dm/raw/master/MI%20Correlates%20of%20State%20Policy.dta, clear
//From Correlates of State Policy from MI State
keep year state undocumented_immigrants immig_laws_total immig_laws_accom immig_laws_restrict immig_laws_neut
drop undocumented_immigrants //this number ended up not being collected in most states, so unhelpful
tab immig_laws_total, mi //According to this data, only 5.6% of states passed immigration laws  
tab year //See the historical data on immigration laws from 1900-2017. For this paper, only interested in charting laws passed between 2007 and today. But this information is fascinating and I would like to review and match up to historical events and trends. 
keep if year==2017 //I played around with trying to get counts for states across multiple years. I tried collapsing but did not have success. Ultimately, I decided to stick to looking at one year only for the purposes of this PS.  But I would like to return to this issue in the coming weeks.
//For instance, I tried using collapse immig_laws_total, by(state)
//so the command should work fine but you may add a specific subcommand; remmeber that the default is (mean), so maybe
//  collapse (count) immig_laws_total, by(state)
//or
// collapse (sum) immig_laws_total, by(state)
edit
replace state = "AR" in 1
replace state = "CT" in 2
replace state = "VT" in 3
replace state = "NY" in 4
replace state = "AL" in 5
replace state = "MI" in 6
replace state = "NV" in 7
replace state = "DE" in 8

save a6, replace
l

/*******************/
/***combine data***/
/*****merge 3******/
/******************/

use a1, clear
l
merge 1:1 state using a6 //46 failed to match given the small number of states that passed immigration laws in 2017
save a7, replace
l

/*************************/
/***import/export/clean***/
/******* merge 4 ********/
/************************/
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download," 
//decided to look at GSS for attitudes towards immigrants 
keep region excldimm immjobs immameco
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
tab region //to get a clearer idea of regional distribution
//NE: Connecticut, Maine, Massachusetts, New Hampshire, Rhode Island, Vermont
//Mid Atlantic: New Jersey, New York, PA
//South Atlantic: Delaware, District of Columbia, Maryland, Virginia, West Virginia, NC, SC, GA, FL
//East South Central: AL, Kentucky, Mississippi, Tennessee
//East North Central: Illinois, Indiana, Michigan, Ohio, Wisconsin
//West South Central: Arkansas, Louisiana, Oklahoma, Texas
//West North Central: Iowa, Kansas, Missouri, Nebraska, SD, ND, MN
//Mountain: Colorado, Montana, Utah, Wyoming, New Mexico, Idaho, Nevada, Arizona
//Pacific: California, Hawaii, Alaska, Oregon, Washington
save a8, replace

use a1
l
//will attempt to divide states into regions 
gen region=""
gen region1=""
gen region2=""
gen region3=""
gen region4=""
gen region5=""
gen region6=""
gen region7=""
gen region8=""
gen region9=""
//I tried this command but I'm not having luck...replace region=1 if state==CT ME MA NH RI VT
//bc thats wrong syntax! try inlist :):
//https://www.stata.com/statalist/archive/2011-04/msg00634.html or:
//https://www.google.com/search?q=stata+inlist&ie=utf-8&oe=utf-8&client=firefox-b-1-ab
//so you categorize into regions and then collapse or do 1:m merge
//Once I can categorize states into their regions, I will merge with a1. But how do I get there?


//save a9, replace

/*******************/
/***combine data***/
/*****merge 4******/
/******************/
//use a1, clear
//l
//merge 1:1 state using a9 
//save a10, replace


/*************************/
/***import/export/clean***/
/******* merge 5 ********/
/************************/
//I wanted to look at numbers of Hispanic and Latino population. I ran a search on the ACS.
//I then tried to figure out how to get the data from the ACS page to Stata.
//ls
unzipfile ACS_17_1YR_B03003.zip
insheet using ACS_17_1YR_B03003_with_ann.csv, clear
rename v3 state //easier to read if I clean the variable name
codebook state //string variable 
replace state = "Al" in 3
replace state = "AK" in 4
replace state = "AR" in 5
replace state = "AK" in 6
replace state = "CA" in 7
replace state = "CO" in 8
replace state = "CT" in 9
replace state = "DE" in 10
replace state = "DC" in 11
replace state = "FL" in 12
replace state = "GA" in 13
replace state = "HI" in 14
replace state = "ID" in 15
replace state = "IL" in 16
replace state = "IN" in 17
replace state = "IO" in 18
replace state = "KS" in 19
replace state = "KY" in 20
replace state = "LA" in 21
replace state = "ME" in 22
replace state = "MA" in 23
replace state = "MD" in 23
replace state = "MA" in 24
replace state = "MI" in 25
replace state = "MN" in 26
replace state = "MS" in 27
replace state = "MS" in 28
replace state = "MT" in 29
replace state = "NE" in 30
replace state = "NV" in 31
replace state = "NH" in 32
replace state = "NJ" in 33
replace state = "NM" in 34
replace state = "NY" in 35
replace state = "NC" in 36
replace state = "ND" in 37
replace state = "OH" in 38
replace state = "OK" in 39
replace state = "OR" in 40
replace state = "PA" in 41
replace state = "RI" in 42
replace state = "SC" in 43
replace state = "SD" in 44
replace state = "TN" in 45
replace state = "TX" in 46
replace state = "UT" in 47
replace state = "VT" in 48
replace state = "VA" in 49
replace state = "WA" in 50
replace state = "WV" in 51
replace state = "WI" in 52
replace state = "WY" in 53
replace state = "PR" in 54

rename v8 perHispanic_Latino //easier to read if I clean the variable name
rename perHispanic_Latino Total_HisLat //I forgot that these were actual numbers and not percentages.
//I might want to go back and tranform into percentages rather than counts. This would be easier to interpret later. 
rename v4 Total_Population //easier to read if I clean the variable name
drop in 1/2
save a11, replace

/*******************/
/***combine data***/
/*****merge 5******/
/******************/
//use a1, clear
//l
//merge 1:1 state using a11 //I get the following error message: variable state was str11, now str20 to accommodate using data's values"
//no! that's not the error, but message :) it's not in red!
//save a12, replace

