* Problem Set 2 Do File //this should be in every dofile
* Tara Carr-Lemke
* October 4, 2018
//nice preamble

version 15  //this ensures your grandkids will run this fine :)
set more off  //will run everything
cap log close //to suppress error
log using tara.txt, replace text //but before you start log, you need to close if it was opened
//and then can close
log close
sysdir //to see where stata saves stuff

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
l county state if county==county[_n-1] & state==state[_n-1] //so the UA is jail!! not county!!!
drop if county==county[_n-1] & state==state[_n-1]  //so dropping probably doesnt make sense; if anything collapse

destring *, replace //this is good usually helps!
destring *, replace ignore(",")

//Eliminate categories of 8 and 31
hist ilrctotal, percent //for key var of interest do a histogram or tab
ta ilrctotal
replace ilrctotal=. if ilrctotal==8
replace ilrctotal=. if ilrctotal==31

//Correct addition error
//replace ilrctotal = 3 in 811 //would be safer on condition like
replace ilrctotal = 3 if jurisdiction=="Dyer Sheriffs Office" & jailorprisonname=="Dyer County - TN"

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
save a1_1, replace //can also save as sth more meaningful
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


replace state2="AK" if state=="Alaska"


save a2, replace
list
//in future could also look at collapse prodeportation, by(state)


/*******************/
/***combine data***/
/******************/
use a1_1, clear //master 
list
merge 1:1 state using a2



 




