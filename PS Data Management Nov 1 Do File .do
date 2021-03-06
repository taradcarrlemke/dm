/*
not neseccarily the best way to do it, but i always merge first and then do graphs and descriptive stats
on the final merged file; and again could organize a bit better--move chunks of code around, may even print this out to do it
interesting data and lots of information--now time to start writing this up and include results in youyr writeup! good job!
*/
* Problem Set 4 Do File
* Tara Carr-Lemke
* Data Management Class
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
//Merge ILRC Sanctuary with GSS Attitudes about Immigration
//DATA SET 1
//Look at and clean ILRC data
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
d
lookfor county
ta county
lookfor state
ta state //note that DE is only state missing 
ta ilrctotal
destring *, replace
destring *, replace ignore(",")
replace ilrctotal=. if ilrctotal==8 //Elimiate when ilrctotal is 8 and 31
//Per Dr. Adam: or use replace ilrctotal = 3 if jailorprisonc=="Dyersburg" //this is more bullet proof; 811 obs would change if you change sth little
replace ilrctotal=. if ilrctotal==31
replace ilrctotal = 3 in 811 //Correct addition error
drop if ilrctotal==0 //Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==. //Eliminate misisng values
drop if state=="Puerto Rico" | state=="Guam" 
tab ilrctotal, mi plot //I want to see the range of sanctuary levels. Over 75% of counties have anti-sanctuary in place.
graph hbar (mean) no287g (mean) noicedetentioncontract (mean) noiceholds (mean) noicealerts (mean) limitsoniceinterrogationsinjail (mean) prohibitiononaskingaboutimmigrat (mean) generalprohibitiononassistanceto, title(Types and frequency of sanctuary status policies) bar(1, fcolor(gs10))bar(1, fcolor(gs10)) bar(2, fcolor(gs10))bar(3, fcolor(gs10))bar(4, fcolor(gs10)) bar(5, fcolor(gs10)) bar(6, fcolor(gs10)) bar(7, fcolor(gs10)) blabel(name, position(base)) legend(off)
//could beutify it, notably add nice labels for bars--play with GUI
//Interesting graph because we can observe the most and least used county policies for collaboration with immigration enforcement. Highly skewed.
keep ilrctotal state county jurisdiction //I only want to analyze these variables.
tab state ilrctotal //I want to see the breakdowns kind of difficult to comprehend, maybe better summarize:
gr hbar (mean) ilrctotal, over(state) //just make labels smaller, say figure out the code through GUI
gr hbar (median) ilrctotal, over(state)
gr hbar (sd) ilrctotal, over(state)
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
graph hbar (median) ilrctotal if region, over(region) ytitle(Mean of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
graph hbar (sd) ilrctotal if region, over(region) ytitle(Mean of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)

save ILRC_Region_forHappinessClass, replace

tabstat ilrctotal, by(region) //Mean of sanctuary status by region is 2.5. NE and Pacific have highest status. SW Central and NW Central have lowest.
tabstat ilrctotal, by(region) stat(mean sd) //Note level of variability in NE and Pacific.
graph hbox ilrctotal, over(region) title(Variability of Santuary Status by Region)

//Now merge with GSS data on perceptions of immigrants 
//Merge to look at tough imm laws
use ILRC_Region_forHappinessClass, clear
ta region
d
collapse ilrctotal, by(region)
save ILRC_Region_forHappinessClass-alt, replace

use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse too_tough, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
l
save ILRC_RegionandTooToughforHappinessClassMERGE, replace
use ILRC_RegionandTooToughforHappinessClassMERGE, clear
//seems like missing some vars below
twoway (scatter too_tough ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(US should not be tougher on immigration) xtitle(Sanctuary Status) title(Sanctuary Status and Immigration Policy), lfit too_tough ilrctotal, jitter(1)ms(Oh)

//Merge to look at immcrime
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse less_crime, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort less_crime 
l //highest levels are in W Nor and E South. Lowest levels in MidAt and NE.
// There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//Immigrants increase crime rates. 1==agree strongly to 5=disagree strongly
save ILRC_RegionandImmIncreaseCrimeforHappinessClassMERGE, replace
twoway (scatter less_crime ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Immigrants do not increase crime) xtitle(Sanctuary Status) title(Sanctuary Status and Perceptions of Reduction of Crime), lfit less_crime ilrctotal, jitter(1)ms(Oh)
corr ilrctotal less_crime

///Merge to look at respect_USlaw
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse notkeytorespect_USlaw, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort notkeytorespect_USlaw
l // Some people say the following things are important for being truly American. Others say they are not important. How important do you think each of the following is...To respect America's political institutions and laws.
//1==very important to 4=not important
//E South and Mountain thought most important. Pacific thought least.
save ILRC_RegionandRespectLawforHappinessClassMERGE, replace
twoway (scatter notkeytorespect_USlaw ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Not important to respect laws) xtitle(Sanctuary Status) title(Sanctuary Status Lack of Emphasis for Respect of Laws), lfit notkeytorespect_USlaw ilrctotal, jitter(1)ms(Oh)

reg notkeytorespect_USlaw ilrctotal, robust //ran a regression 
//stat insignificant. coeff is 0.28., R2 is 9.8,and P is less than .05, ie is 0.02.

///Merge to look at eco_plus
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse eco_plus, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
sort eco_plus
l //There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//B. Immigrants are generally good for America''s economy
//1==agree strongly to 5=disgree strongly
//E South and W Nor disagreed most strongly. Pacific agreed most strongly.
save ILRC_ImmGoodforEcoforHappinessClassMERGE, replace
twoway (scatter eco_plus ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Perceptions of immigrants as negative for economy) xtitle(Sanctuary Status) title(Sanctuary Status and Immigrants Bad for Economy), lfit eco_plus ilrctotal, jitter(1)ms(Oh)

reg eco_plus ilrctotal, robust //ran a regression 
//stat sigificant. coeff is -0.05., R2 is 9.4,and P is less than .05, ie is 0.02.

//Merge to look at imm take jobs
/*There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
C. Immigrants take jobs away from people who were born in America. 1=agree strongly to 5 disagree strongly.
*/
use ILRC_Region_forHappinessClass-alt, clear
l
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse take_jobs, by(region)
merge 1:m region using ILRC_Region_forHappinessClass
drop _merge
l
save ILRC_RegionandTakeJobsforHappinessClassMERGE, replace
twoway (scatter take_jobs ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Immigrants do not take jobs) xtitle(Sanctuary Status) title(Sanctuary Status and No Economic Threats), lfit take_jobs ilrctotal, jitter(1)ms(Oh)

//create a table for regression results 
//something is not working here! what's wrong with the code?
use ILRC_RegionandTooToughforHappinessClassMERGE, clear
regress too_tough ilrctotal
outreg2 using ILRC_RegionandTooToughforHappinessClassMERGE, replace ctitle(model 1)

use ILRC_RegionandImmIncreaseCrimeforHappinessClassMERGE, clear
reg less_crime  ilrctotal
outreg2 using ILRC_RegionandImmIncreaseCrimeforHappinessClassMERGE, append ctitle(model 2)

use ILRC_RegionandRespectLawforHappinessClassMERGE, clear
reg notkeytorespect_USlaw ilrctotal 
outreg2 using ILRC_RegionandRespectLawforHappinessClassMERGE, append ctitle(model 3)

use ILRC_ImmGoodforEcoforHappinessClassMERGE, clear
reg eco_plus  ilrctotal
outreg2 using ILRC_ImmGoodforEcoforHappinessClassMERGE, append ctitle(model 4)

use ILRC_RegionandTakeJobsforHappinessClassMERGE, clear
reg take_jobs  ilrctotal
outreg2 using ILRC_RegionandTakeJobsforHappinessClassMERGE, append ctitle(model 5)
