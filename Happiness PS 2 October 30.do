* Problem Set 2 Do File
* Tara Carr-Lemke
* Happiness Class
* November 1, 2018

version 15
set more off  //will run everything
cap log close //to suppress error
sysdir //to see where stata saves

/**************/
/***navigate***/
/**************/

pwd //to see where we are
ls //to list what we have
cd C:\Users\tdc57\Desktop

/********************/
/***import/export***/
/******clean*******/
/*****visualize*****/
/*******************/
// DATA SET 1
//Look at and clean ILRC data
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
d
lookfor county
ta county
lookfor state
ta state //note that DE is only state missing 
ta ilrctotal
//Explain what the 7 valid categories are: 
//1) No 287(g) agreement with Immigration and Customs Enforcement (ICE) 
//2) No contract with ICE to detain immigrants in county detention facilities 
//3) Restriction or refusal to hold individuals after their release date on the basis of ICE detainers (“ICE holds”)
//4) Policy against notifying ICE of release dates and times or other information about inmate status (“ICE alerts”)
//5) Prohibition against ICE in jails or requirement of detainee consent before ICE is allowed to interrogate 
//6) Prohibition against asking about immigration status
//7) General prohibition on providing assistance and resources to ICE to enforce civil immigration laws
//ILRC assigns a "1" for each category above for which the county is implementing the policy. Aggregates total. Lists total in "ILRC Total" category.

destring *, replace
destring *, replace ignore(",")

replace ilrctotal=. if ilrctotal==8 //Elimiate when ilrctotal is 8 and 31
//Per Dr. Adam: or use replace ilrctotal = 3 if jailorprisonc=="Dyersburg" //this is more bullet proof; 811 obs would change if you change sth little
replace ilrctotal=. if ilrctotal==31
replace ilrctotal = 3 in 811 //Correct addition error
drop if ilrctotal==0 //Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==. //Eliminate misisng values
drop if state=="Puerto Rico" | state=="Guam" 
tab ilrctotal, mi //I want to see the range of sanctuary levels. Over 75% of counties have anti-sanctuary in place.
graph hbar (mean) no287g (mean) noicedetentioncontract (mean) noiceholds (mean) noicealerts (mean) limitsoniceinterrogationsinjail (mean) prohibitiononaskingaboutimmigrat (mean) generalprohibitiononassistanceto, title(Types and frequency of sanctuary status policies) bar(1, fcolor(gs10))bar(1, fcolor(gs10)) bar(2, fcolor(gs10))bar(3, fcolor(gs10))bar(4, fcolor(gs10)) bar(5, fcolor(gs10)) bar(6, fcolor(gs10)) bar(7, fcolor(gs10)) blabel(name, position(base)) legend(off)
//Interesting graph because we can observe the most and least used county policies for collaboration with immigration enforcement. Highly skewed.
keep ilrctotal state county jurisdiction //I only want to analyze these variables.
tab state ilrctotal //I want to see the breakdowns 
tabstat ilrctotal //National mean of sanctuary status is 2.37.

///Visualize ILRC data
histogram ilrctotal, percent ytitle (Percentage of US Counties) xtitle("Sanctuary" Status) title(National Sanctuary Distribution) legend(on) clegend(on)note(The mean of sanctuary status nationwide is 2.4)
collapse ilrctotal, by(state) //I want a state average of ILRC totals.
l
save ILRCforHappinessClass, replace //could return to this data and create bar chart comparing sanctuary status with other variables

//Now look at region-level sanctuary status
sort state
count if state==state[_n-1]
l if state==state[_n-1]

//Use the regional classification information from GSS  
/*1  new england
2  middle atlantic
3  e. nor. central
4  w. nor. central
5  south atlantic
6  e. sou. central
7  w. sou. central
8  mountain
9  pacific
*/

generate region=.
//replace region= 1 if inlist(state, "CT","ME","RI","MA","NH","VT") 
replace region= 1 if state == "CT" | state == "ME" | state == "RI" | state == "MA" | state == "NH" | state=="VT"
replace region= 2 if state == "NY" | state == "NJ" | state == "PA"
replace region= 3 if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
replace region= 4 if state == "IA" | state == "KS" | state == "MO" | state == "NE" | state == "SD" | state=="ND"| state=="MN"
replace region= 5 if state == "DE" | state == "DC" | state == "MD" | state == "VA" | state == "WV" | state=="NC"| state=="SC" | state=="GA"| state=="FL"
replace region= 6 if state == "AL" | state == "KY" | state == "MS" | state == "TN" 
replace region= 7 if state == "AR" | state == "LA" | state == "OK" | state == "TX" 
replace region= 8 if state == "CO" | state == "MT" | state == "UT" | state == "WY" | state == "NM" | state=="ID"| state=="NV" | state=="AZ"
replace region= 9 if state == "CA" | state == "HI" | state == "AK" | state == "OR" | state == "WA" 

count if region==.
sort region //checking for errors 
l //everything appears to check out 
label define reg_label 1 "New England" 2 "MidAtlantic" 3 "NE Central" 4 "NW Central" 5 "South Atlantic" 6 "SE Central" 7 "SW Central"  8 "Mountain" 9 "Pacific"
label values region reg_label
graph hbar (mean) ilrctotal if region, over(region) ytitle(Mean of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
save ILRC_Region_forHappinessClass, replace

tabstat ilrctotal, by(region) //Mean of sanctuary status by region is 2.5. NE and Pacific have highest status. SW Central and NW Central have lowest.
tabstat ilrctotal, by(region) stat(mean sd) //Note level of variability in NE and Pacific.
graph hbox ilrctotal, over(region) title(Variability of Santuary Status by Region)

/********************/
/***import/export***/
/******clean*******/
/*****visualize*****/
/*******************/
// DATA SET 2
//Now look at GSS for attitudes towards immigrants and government  
//This data looks at region, not state-level.
clear
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download"
set more off  
d //Scan the data.  Also review variables in Data Explorer.
//Contains data from GSS2014.DTA
//I could use the entire GSS data set over the years.  Ask Dr Adam for help. It is too big to download to github or google and I am having trouble with sampling.
//I used tab, mi below but could also use tab to look only at respondents
//I choose a few variables to review quickly.
tab govdook, mi //we can trust people in govt--10% agree or strongly agree; 13% neither agree not disagree; 24% disagree or disagree strongly; 50% no information
tab conleg, mi //confidence in congress--25% had some or lots; 35% had hardly any; 34% no answer
tab confed, mi //confidence in executive branch--36% had some or lots; 29% had hardly any; 34% no anwers
tab immcrime, mi //immigrants increase crime--8% agree; 12% neither; 25% disagree; 50% not polled
tab affctlaw, mi // congress gives serious attention to r's demands: 10% likely; 35% not likely; 50% no answer
//keep a number of other variables of interest like...see below
keep region excldimm immjobs immameco immcrime happy govdook conleg confed affctlaw uscitzn voteelec vote08 vote12 polint1 relig race dem10fut dem10pst demtoday attrally amgovt
rename excldimm too_tough //How much do you agree or disagree with the following statement? 
//America should take stronger measures to exclude illegal immigrants. 1=agree strongly to 5=disagree strongly
rename immjobs take_jobs //There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//Immigrants take jobs away from people who were born in America. 1=agree strongly to 5=disagree strongly.
rename immameco eco_plus // There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//B. Immigrants are generally good for America''s economy. 1=Agree strongly to 5=disagree strongly
rename govdook little_trust_in_govt // To what extent do you agree or disagree with the following statements? 
//A. Most of the time we can trust people in government to do what is right. 1=strongly agree to 5=strongly disagree
rename conleg confidence_in_leg
rename confed confidence_in_exec
rename affctlaw Congress_cares //If you made such an effort, how likely is it that the Congress would give serious attention to your demands?. 1=very likely to 4=not very likely
rename polint1 political_interest
rename amgovt notkeytorespect_USlaw //Some people say the following things are important for being truly American. Others say they are not important. How important do you think each of the following is... 
//F. To respect America's political institutions and laws. 1=very important to 4=not at all important 
rename attrally attend_political_event
//Consider relabeling these here, too
rename immcrime less_crime

tab region, mi //To get a clearer idea of regional distribution. Same regional categories as above.
//NE: Connecticut, Maine, Massachusetts, New Hampshire, Rhode Island, Vermont
//Mid Atlantic: New Jersey, New York, PA
//South Atlantic: Delaware, District of Columbia, Maryland, Virginia, West Virginia, NC, SC, GA, FL
//East South Central: AL, Kentucky, Mississippi, Tennessee
//East North Central: Illinois, Indiana, Michigan, Ohio, Wisconsin
//West South Central: Arkansas, Louisiana, Oklahoma, Texas
//West North Central: Iowa, Kansas, Missouri, Nebraska, SD, ND, MN
//Mountain: Colorado, Montana, Utah, Wyoming, New Mexico, Idaho, Nevada, Arizona
//Pacific: California, Hawaii, Alaska, Oregon, Washington

save AttitudesImmigandGovt_GSSforHappinessClass, replace
//use AttitudesImmigandGovt_GSSforHappinessClass, clear
/*review below explores happiness and govt trust and satisfaction variables
tab Congress_cares, mi //only about 47% of total survey r responded. 
//Out of those who responded, only 24% thought it was likely that Congress would "give serious attention to demands"
//1 = very likely...4 = not at all likely
tab happy, mi //99% of surveyed responded to this question
tab happy Congress_cares, row column
tab trust_in_govt, mi //only about 49% of total survey responded.
//Out of those who did, only about 21% "trust people in govt." About 26% neither agreed nor disagreed. Over 50% disagreed.
tab happy trust_in_govt, row column
tabstat happy trust_in_govt, by(region)
*/very happy is a 1. should I reverse the order and make very happy a 3?

//Merge ILRC Sanctuary with GSS Trust and Confidence
use ILRC_Region_forHappinessClass, clear
ta region
d
collapse ilrctotal, by(region)
save ILRC_Region_forHappinessClass-alt, replace

///Merge to look at Perceptions of Congressional attentiveness to consistuent demands
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse Congress_cares, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
l
save ILRC_RegionandCongressCaresforHappinessClassMERGE, replace
twoway (scatter Congress_cares ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Cares about constituent demands) xtitle(Sanctuary Status) title(Sanctuary Status and Congressional Attentiveness), lfit Congress_cares ilrctotal, jitter(1)ms(Oh)

reg Congress_cares ilrctotal, robust //ran a regression
//Stat insignificant. Coeff is -.009., R2 is 1.8, and P is greater than .05, ie is 0.19.

//Merge to look at trust_in_govt
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse little_trust_in_govt, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge 
sort little_trust_in_govt 
l //highest levels of trust are in Middle At and NE. Lowest are in W Nor
//How much do you agree or disagree with each of the following statements? 1=strongly agree to 5=strongly disagree
//Most government administrators can be trusted to do what is best for the country
save ILRC_RegionandTrustinGovtforHappinessClassMERGE, replace
twoway (scatter little_trust_in_govt ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Little Trust in Government to Do What's Right) xtitle(Sanctuary Status) title(Sanctuary Status and Trust in Government), lfit little_trust_in_govt ilrctotal, jitter(1)ms(Oh)

reg little_trust_in_govt ilrctotal, robust //ran a regression 
//Stat insignificant. Coeff is .0085. R2= 0.1 and P is greater than .05 ie is 0.235.

//Merge to look at democracy
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse demtoday, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort demtoday 
l //highest levels are in W Nor and E Nor. Lowest in NE.
// On the whole, on a scale of 0 to 10 where 0 is very poorly and 10 is very well. How well does democracy work in America today?
save ILRC_RegionandDemTodayforHappinessClassMERGE, replace
twoway (scatter demtoday ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Democracy works well in America today) xtitle(Sanctuary Status) title(Sanctuary Status and American Democracy), lfit demtoday ilrctotal, jitter(1)ms(Oh)

//Merge to look at democracy 10 years ago
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse dem10pst, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort dem10pst 
l //highest levels are in W Nor and E Nor. Lowest levels in MidAt and NE.
// On the whole, on a scale of 0 to 10 where 0 is very poorly and 10 is very well. How well does democracy work in America today?
save ILRC_RegionandDem10pstforHappinessClassMERGE, replace
twoway (scatter dem10pst ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Democracy worked well in America 10 years ago) xtitle(Sanctuary Status) title(Sanctuary Status and Past American Democracy), lfit dem10pst ilrctotal, jitter(1)ms(Oh)

reg dem10pst ilrctotal //ran a regression 
//These results explan slightly more ie coef is -0.077 and R2 = 5.1 and P values is .12. Still insig but more predictive than trust and demtoday variables above.

//Merge to look at democracy in 10 years
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse dem10fut, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort dem10fut 
l //highest levels are in W Nor and Mountain. Lowest are in NE, W South. 
// On the whole, on a scale of 0 to 10 where 0 is very poorly and 10 is very well. How well does democracy work in America today?
save ILRC_RegionandDemin10YrsforHappinessClassMERGE, replace
twoway (scatter dem10fut ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Democracy will work well in America in 10 years) xtitle(Sanctuary Status) title(Sanctuary Status and Future American Democracy), lfit dem10fut ilrctotal, jitter(1)ms(Oh)

reg dem10fut ilrctotal //ran a regression 
//These results explain less than dem10pst ie coef is -0.015 and R2=2.8 and P value is 0.72. Still insig.


//run some more regressions on American democracy 
findit outreg2
use ILRC_RegionandDemTodayforHappinessClassMERGE, clear
xi: ologit demtoday  ilrctotal      , robust
use ILRC_RegionandDem10pstforHappinessClassMERGE, clear
xi: ologit dem10pst  ilrctotal      , robust
use ILRC_RegionandDemin10YrsforHappinessClassMERGE, clear
xi: ologit dem10fut  ilrctotal      , robust

//create a table for regression results 
use ILRC_RegionandDemTodayforHappinessClassMERGE, clear
regress demtoday  ilrctotal
outreg2 using ILRC_RegionandDemTodayforHappinessClassMERGE, replace ctitle(model 1)

use ILRC_RegionandDem10pstforHappinessClassMERGE, clear
reg dem10pst  ilrctotal
outreg2 using ILRC_RegionandDem10pstforHappinessClassMERGE, append ctitle(model 2)

use ILRC_RegionandDemin10YrsforHappinessClassMERGE, clear
reg dem10fut ilrctotal 
outreg2 using ILRC_RegionandDemin10YrsforHappinessClassMERGE, append ctitle(model 3)


//I may decide to merge to look at "Immigration is big problem" from YouGov
use ImmBigProbforHappinessClassRegion, clear
tab region
collapse imm_big_problem, by(region)
merge 1:m region using ILRC_RegionandTakeJobsforHappinessClassMERGE
drop _merge
l
save ILRC_RegionandTakeJobsforHappinessClassandImmBigProbMERGE, replace
tabstat imm_big_problem take_jobs ilrctotal, by(region)
graph hbar (mean) imm_big_problem (mean) take_jobs, over(region) title(Anxiety over Immigration) legend(on)
//need to REVERSE this so that bar makes sense!!!


///IF I DECIDE TO MERGE WITH GENERAL HAPPINESS DATA
//Merge to look at happy
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse happy, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort happy 
l
save ILRC_RegionandHappyforHappinessClassMERGE, replace
twoway (scatter happy ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(General happiness) xtitle(Sanctuary Status) title(Sanctuary Status and General Happiness), lfit happy ilrctotal, jitter(1)ms(Oh)note(Sanctuary jurisdictions enjoy greater general happiness.)
twoway (scatter happy ilrctotal), ytitle(General happiness) xtitle(Sanctuary Status) title(Sanctuary Status and General Happiness), lfit happy ilrctotal, jitter(1)ms(Oh)note(Sanctuary jurisdictions enjoy greater general happiness.)
//or should I keep the state labels and hollow circles?
//will need to control for other factors such as income, education and race

************************
*******NEXT STEPS********
************************
************************
//Explore DATA SET 3
//Harvard YouGov data for attitudes on immigration
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
tab inputstate, plot sort //To view participation by state. No data for Alaska.
//A question related to immigration
//Question CC16_301d: most important problem is immigration
//Question reads: How important is each of these issues (a variety of issues were provided) to you? Very High/Somewhat High/Somewhat Low/Very Low/None. Immigration is one of the choices.
tab CC16_301d, mi //about 20% of participants responded to question (255 out of 1292)
//of this 255, about 75% identified this issue as somewhat high or very high importance
rename CC16_301d imm_big_problem
la varimm_big_problem "most important problem is immigration"
rename inputstate state
keep imm_big_problem state
collapse imm_big_problem, by(state) //I want a state average
l
sort imm_big_problem
l //gives a nice range of means from 1-5
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
replace state2="NE"		if state=="Nebraska"
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
save ImmBigProbforHappinessClass, replace //this is data that shows the mean response to "immigration is big problem" by state
histogram imm_big_problem, bin(10) percent ytitle(Percentage) xtitle("Immigration is a Big Problem") title(Immigration is "Big Problem") legend(on)note(Lower numbers indicate immigration is #1 social issue for respondents.)

//next step--collapse by region
sort state
count if state==state[_n-1]
l if state==state[_n-1]

//regional breakdown information from GSS  
/*1  new england
2  middle atlantic
3  e. nor. central
4  w. nor. central
5  south atlantic
6  e. sou. central
7  w. sou. central
8  mountain
9  pacific
*/

generate region=.
//replace region= 1 if inlist(state, "CT","ME","RI","MA","NH","VT") 
replace region= 1 if state == "CT" | state == "ME" | state == "RI" | state == "MA" | state == "NH" | state=="VT"
replace region= 2 if state == "NY" | state == "NJ" | state == "PA"
replace region= 3 if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
replace region= 4 if state == "IA" | state == "KS" | state == "MO" | state == "NE" | state == "SD" | state=="ND"| state=="MN"
replace region= 5 if state == "DE" | state == "DC" | state == "MD" | state == "VA" | state == "WV" | state=="NC"| state=="SC" | state=="GA"| state=="FL"
replace region= 6 if state == "AL" | state == "KY" | state == "MS" | state == "TN" 
replace region= 7 if state == "AR" | state == "LA" | state == "OK" | state == "TX" 
replace region= 8 if state == "CO" | state == "MT" | state == "UT" | state == "WY" | state == "NM" | state=="ID"| state=="NV" | state=="AZ"
replace region= 9 if state == "CA" | state == "HI" | state == "AK" | state == "OR" | state == "WA" 

count if region==.
sort region //checking for errors 
l //everything appears to check out 
label define reg_label 1 "new england" 2 "middle atlantic" 3 "e. nor. central" 4 "w. nor. central" 5 "south atlantic" 6 "e. sou. central" 7 "w. sou. central"  8 "mountain" 9 "pacific"
label values region reg_label
save ImmBigProbforHappinessClassRegion, replace 

/********************/
/*****manipulate*****/
/*******************/

use ILRCforHappinessClass, clear
l
merge 1:1 state using ImmBigProbforHappinessClass // 48 matched. DE is in using only. AK and ND are in master only.
drop _merge
save ILRCandImmBigProbforHappinessClassMERGE, replace

use ILRCandImmBigProbforHappinessClassMERGE, clear

tabstat ilrctotal imm_big_problem
tabstat ilrctotal imm_big_problem, by(state)
corr ilrctotal imm_big_problem

//dependent var (ilrtotal) on Y axis and indep (imm big problem) on x axis 

scatter imm_big_problem ilrctotal, jitter(1)ms(Oh)mlab(state) mlabsize(vsmall) //thisincludes state names

twoway (scatter imm_big_problem ilrctotal, sort), title(Sanctuary Status and Views on Immigration by State)

twoway (scatter imm_big_problem ilrctotal, msize(small) msymbol(circle_hollow) sort), title(Sanctuary Status and Views on Immigration by State)

twoway (scatter imm_big_problem ilrctotal, msize(small) msymbol(circle_hollow) mlab(state) mlabsize(vsmall) sort), title(Sanctuary Status and Views on Immigration by State)note(We see that states higher than 3 on seriousness of immigration have lower sanctuary score than expected.)

twoway (lfit imm_big_problem ilrctotal) (scatter imm_big_problem ilrctotal), ytitle(Immigration is Big Problem) xtitle(Sanctuary Status) title(Sanctuary Status and Views on Immigration by State) legend(on)

twoway (scatter imm_big_problem ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Immigration is Big Problem) xtitle(Sanctuary Status) title(Sanctuary Status and Views on Immigration by State), lfit imm_big_problem ilrctotal, jitter(10)note(States higher than 3 on seriousness of immigration problem have lower sanctuary status than expected.)

twoway (lfit imm_big_problem ilrctotal), title(Sanctuary Status and Views on Immigration by State) //could add titles and legand here


************************
*******FOR LATER********
************************
//DATA SET 4
//Now look at Correlates of State Policy data
//this is too big for home version of Stata, have to wait to back to campus
use https://github.com/taradcarrlemke/dm/raw/master/MI%20Correlates%20of%20State%20Policy.dta, clear
//From Correlates of State Policy from MI State
d
keep year state immig_laws_total immig_laws_accom immig_laws_restrict immig_laws_neut
tab immig_laws_total, mi //According to this data, only 5.6% of states passed immigration laws  
tab year //See the historical data on immigration laws from 1900-2017. For this paper, only interested in charting laws passed between 2007 and today. But this information is fascinating and I would like to review and match up to historical events and trends. 
keep immig_laws_total state
collapse (count) immig_laws_total, by(state)
//or collapse (sum) immig_laws_total, by(state)
edit
replace state = "AL" in 1
replace state = "AK" in 2
replace state = "AR" in 3
replace state = "AZ" in 4
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
replace state = "IA" in 16
replace state = "KS" in 17
replace state = "KY" in 18
replace state = "LA" in 19
replace state = "ME" in 20
replace state = "MD" in 21
replace state = "MA" in 22
replace state = "MI" in 23
replace state = "MN" in 24
replace state = "MS" in 25
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
replace state = "VY" in 46
replace state = "VT" in 46
replace state = "VA" in 47
replace state = "WA" in 48
replace state = "WV" in 49
replace state = "WI" in 50
replace state = "WY" in 51

save StateImmLaws_forHappinessClass, replace
l
//would eventually like to merge this with ILRC and HarvardYouGov data at the state level 


