* Final Do File
* Tara Carr-Lemke
* Happiness Class
* December 14, 2018

version 15
set more off  //will run everything
cap log close //to suppress error
sysdir //to see where stata saves
ssc install revrs //will need to use the reverse order command so install now
ssc install estout, replace //will use this command for table making

/**************/
/***navigate***/
/**************/

pwd //to see where we are
ls //to list what we have
//cd C:\Users\tdc57\Desktop

/********************/
/***import/export***/
/******clean*******/
/*****visualize*****/
/*******************/
// DATA SET 1
//Look at and clean ILRC data
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
lookfor county
ta county //3,018 total listed
lookfor state
ta state //note that DE is only state missing 
ta ilrctotal //To observe what the valid categories are. 
//ILRC assigns a "1" for each category for which the county is implementing the policy. Aggregates total. Lists total in "ILRC Total" category.

//Need to clean the data as follows
destring *, replace
destring *, replace ignore(",")
replace ilrctotal=. if ilrctotal==8 //Eliminate when ilrctotal is 8 and 31
replace ilrctotal=. if ilrctotal==31
replace ilrctotal = 3 if jailorprisonc=="Dyersburg" 
drop if ilrctotal==0 //Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==. //Eliminate missing values
drop if state=="Puerto Rico" | state=="Guam" 
tab ilrctotal, mi plot //I want to see the range of sanctuary levels. Over 75% of counties have anti-sanctuary in place.
tab ilrctotal //Observe data.  Appeares to be correct and cleaned of errors. Now have 2,912 counties.
tabstat ilrctotal //National mean of sanctuary status is 2.37.
sum ilrctotal //I want to see a clear summary. 

//Rename and label variables 
rename no287g No_287g
la var No_287g "No 287g agreement"
rename noicedetentio~t No_ICE_detention_contract
la var No_ICE_detention_contract "No ICE detention contract"
rename noiceholds No_ICE_holds
la var No_ICE_holds "No ICE holds"
rename noicealerts No_ICE_alerts
la var No_ICE_alerts "No ICE alerts"
rename limitsoniceinterrogationsinjail Limits_ICE_in_jail
la var Limits_ICE_in_jail "Limits ICE jail questioning"
rename prohibitiononaskingaboutimmigrat Prohibits_status_questions
la var Prohibits_status_questions "Prohibits questions on status"
rename generalprohibitiononassistanceto General_ICE_prohibitions
la var General_ICE_prohibitions "General ICE prohibitions"
rename geoidfips FIPS
save ILRCforHappiness, replace

//I added the next 15 lines to preserve the labels.
keep ilrctotal state county jurisdiction FIPS No_287g No_ICE_detention_contract General_ICE_prohibitions No_ICE_holds No_ICE_alerts Limits_ICE_in_jail Prohibits_status_questions
save ILRCforHappinessLABELS, replace
foreach var of varlist * {
    local vlab`var': var label `var'
    }

collapse ilrctotal No_287g No_ICE_detention_contract General_ICE_prohibitions No_ICE_holds No_ICE_alerts Limits_ICE_in_jail Prohibits_status_questions, by(state)

foreach var of varlist * {
    label var `var' "`vlab`var''"
    } 
save ILRCforHappinessLABELS, replace

//Collapse by state
use ILRCforHappiness, clear
collapse ilrctotal No_287g No_ICE_detention_contract General_ICE_prohibitions No_ICE_holds No_ICE_alerts Limits_ICE_in_jail Prohibits_status_questions, by(state) //I want a state average of ILRC totals.
l
tabstat ilrctotal, by(state) 
save ILRCforHappinessState, replace

//Look at region-level sanctuary status
//Use the regional classification information from GSS to sort states into regions
sort state
count if state==state[_n-1]
l if state==state[_n-1]
generate region=. //or replace region= 1 if inlist(state, "CT","ME","RI","MA","NH","VT") 
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
sort region //Checking for errors 
l //Everything appears to check out. DE is missing.
label define reg_label 1 "New England" 2 "MidAtlantic" 3 "NE Central" 4 "NW Central" 5 "South Atlantic" 6 "SE Central" 7 "SW Central"  8 "Mountain" 9 "Pacific"
label values region reg_label
keep ilrctotal state region //Ultimately, I only want to analyze these variables in regard to public perceptions.
tabstat ilrctotal, by(region) //Mean of sanctuary status by region is 2.5. NE and Pacific have highest status. SW Central and NW Central have lowest.
tabstat ilrctotal, by(region) stat(mean sd) //Note level of variability in NE and Pacific.
save ILRCRegionforHappiness, replace

///Visualize ILRC data
use ILRCforHappinessLABELS, clear
graph hbar (mean) No_287g (mean) No_ICE_detention_contract (mean) No_ICE_holds (mean) No_ICE_alerts (mean) Limits_ICE_in_jail (mean) Prohibits_status_questions (mean) General_ICE_prohibitions, title(Types and frequency of sanctuary status policies) 
graph hbar (mean) No_287g No_ICE_detention_contract No_ICE_holds No_ICE_alerts Limits_ICE_in_jail Prohibits_status_questions General_ICE_prohibitions, ascategory blabel(bar) yvar(relabel(1 "`: var label No_287g'" 2 "`: var label No_ICE_detention_contract'" 3 "`: var label No_ICE_holds'" 4 "`: var label No_ICE_alerts'" 5 "`: var label Limits_ICE_in_jail'" 6 "`: var label Prohibits_status_questions'" 7 "`: var label General_ICE_prohibitions'"))title(Types and Proportion of Sanctuary Policies)note(Types of sanctuary policies of all counties nationwide.) 
//Interesting graph because we can observe the most and least used county policies for collaboration with immigration enforcement. Highly skewed.
pwcorr No_287g No_ICE_detention_contract No_ICE_holds No_ICE_alerts Limits_ICE_in_jail Prohibits_status_questions General_ICE_prohibitions, obs sig 

use ILRCRegionforHappiness, clear
graph hbar (mean) ilrctotal if region, over(region) ytitle(Mean of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
graph hbar (median) ilrctotal if region, over(region) ytitle(Median of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
graph hbar (sd) ilrctotal if region, over(region) ytitle(SD of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of standrad deviation of sanctuary policy in XXX.)
histogram ilrctotal, percent ytitle (Percentage of US Counties) xtitle("Sanctuary" Status) title(National Sanctuary Distribution) legend(on) clegend(on)note(The mean of sanctuary status nationwide is 2.4)
graph hbox ilrctotal, over(region) title(Variability of Santuary Status by Region)
//future step: look at state and county-level policy, means, and variability.

/********************/
/***import/export***/
/******clean*******/
/*****visualize*****/
/*******************/
// DATA SET 2
//Now look at GSS for attitudes towards immigrants, happiness and government  
//This data looks at region, not state-level.
clear
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download"
set more off  
d //Scan the data.  Also review variables in Data Explorer.
//Contains data from GSS2014.DTA
//I could use the entire GSS data set over the years to observe changes over time.
//I used tab, mi below but could also use tab to look only at respondents..
//I choose a few interesting variables to review quickly.
tab govdook, mi //we can trust people in govt--10% agree or strongly agree; 13% neither agree not disagree; 24% disagree or disagree strongly; 50% no information
tab conleg, mi //confidence in congress--25% had some or lots; 35% had hardly any; 34% no answer
tab confed, mi //confidence in executive branch--36% had some or lots; 29% had hardly any; 34% no anwers
tab immcrime, mi //immigrants increase crime--8% agree; 12% neither; 25% disagree; 50% not polled
tab affctlaw, mi // congress gives serious attention to r's demands: 10% likely; 35% not likely; 50% no answer
tab income06, mi //In which of these groups did your total family income, from all sources, fall last year before taxes, that is. 25 different groups.
tab income, mi //Again, about groups.  Looks old/outdated. SO use income06 variable.
//Keep a number of other variables of interest like...see below
tab region, mi //To get a clearer idea of regional distribution. Same regional categories as above.
tab partyid, mi
/*political party |
       affiliation |      Freq.     Percent        Cum.
-------------------+-----------------------------------
   strong democrat |        419       16.51       16.51
  not str democrat |        406       16.00       32.51
      ind,near dem |        337       13.28       45.78
       independent |        502       19.78       65.56
      ind,near rep |        249        9.81       75.37
not str republican |        292       11.51       86.88
 strong republican |        245        9.65       96.53
       other party |         62        2.44       98.98
                DK |          1        0.04       99.01
                NA |         25        0.99      100.00
-------------------+-----------------------------------
             Total |      2,538      100.00
*/
tab partyid, gen(PID)
d PID*
tab polview, mi
tab polview, gen(PolView)
d PolView*
/*

    think of self as |
          liberal or |
        conservative |      Freq.     Percent        Cum.
---------------------+-----------------------------------
   extremely liberal |         94        3.70        3.70
             liberal |        304       11.98       15.68
    slightly liberal |        263       10.36       26.04
            moderate |        989       38.97       65.01
slghtly conservative |        334       13.16       78.17
        conservative |        358       14.11       92.28
extrmly conservative |        107        4.22       96.49
                  DK |         65        2.56       99.05
                  NA |         24        0.95      100.00
---------------------+-----------------------------------
               Total |      2,538      100.00

*/

keep PID1 PID2 PID3 PID4 PID5 PID6 PID7 PID8 PolView1 PolView2 PolView3 PolView4 PolView5 PolView6 PolView7 region size xnorcsiz srcbelt educ income income06 partyid polview excldimm immjobs immameco immcrime happy govdook conleg confed affctlaw uscitzn voteelec vote08 vote12 polint1 relig race dem10fut dem10pst demtoday attrally amgovt
rename polview political_view 
rename xnorcsiz norc_size_code 
rename srcbelt beltcode
rename excldimm tougher //How much do you agree or disagree with the following statement? 
//America should take stronger measures to exclude illegal immigrants. 1=agree strongly to 5=disagree strongly
rename immjobs take_jobs //There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//Immigrants take jobs away from people who were born in America. 1=agree strongly to 5=disagree strongly.
rename immameco eco_benefit // There are different opinions about immigrants from other countries living in America. (By "immigrants" we mean people who come to settle in America.) How much do you agree or disagree with each of the following statements? 
//B. Immigrants are generally good for America''s economy. 1=Agree strongly to 5=disagree strongly
rename govdook trust_in_govt // To what extent do you agree or disagree with the following statements? 
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

//to fix scales 
revrs trust_in_govt, replace
revrs confidence_in_leg, replace
revrs confidence_in_exec, replace
revrs Congress_cares, replace 
revrs happy, replace

save AttitudesImmigandGovt_GSSforHappinessClass, replace

//Prepare ILRC Sanctuary for merge with GSS 
use ILRCRegionforHappiness, clear
ta region
d
collapse ilrctotal, by(region)
save ILRCRegionforHappiness-alt, replace

///Merge to look at sanctuary and GSS responses  
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse PID1 PID2 PID3 PID4 PID5 PID6 PID7 PID8 PolView1 PolView2 PolView3 PolView4 PolView5 PolView6 PolView7 happy size educ income partyid norc_size_code beltcode confidence_in_leg demtoday dem10pst dem10fut political_view tougher less_crime notkeytorespect_USlaw take_jobs eco_benefit confidence_in_exec trust_in_govt Congress_cares political_interest attend_political_event, by(region) 
merge 1:m region using ILRC_Region_forHappinessClass-alt
drop _merge
l
save ILRC_RegionandGSSforHappinessClassMERGE, replace

//Visualize GSS and sanctuary 
tabstat happy, by(region)
graph hbar (mean) happy if region, over(region, label(labsize(small))) title(Happiness by Region)
twoway (scatter ilrctotal happy, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Sanctuary Status) xtitle(Happiness) title(Sanctuary Status and Happiness), lfit ilrctotal happy, jitter(1)ms(Oh)
twoway (scatter Congress_cares ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Cares about constituent demands) xtitle(Sanctuary Status) title(Sanctuary Status and Congressional Attentiveness), lfit Congress_cares ilrctotal, jitter(1)ms(Oh)
//Interesting. Why would people with less faith in federal govt think that Congess would be attentive?
twoway (scatter happy ilrctotal, sort), title(Sanctuary Status and Happiness)
twoway (scatter happy ilrctotal, msize(small) msymbol(circle_hollow) sort), title(Sanctuary Status and Happiness)
twoway (scatter happy ilrctotal), title(Sanctuary Status and Happiness)note(XXX.)
twoway (lfit happy ilrctotal) (scatter happy ilrctotal), ytitle(Happiness) xtitle(Sanctuary Status) title(Sanctuary Status and Happiness) legend(on)
twoway (scatter political_view ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Level of conservatism) xtitle(Sanctuary Status) title(Sanctuary Status and Conservatism), lfit political_view ilrctotal, jitter(1)ms(Oh) //currently including in paper
twoway (scatter happy ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Happiness) xtitle(Sanctuary Status) title(Sanctuary Status and Happiness), lfit happy ilrctotal, jitter(1)ms(Oh) //currently including in paper
twoway (scatter trust_in_govt ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Trust in Gov't) xtitle(Sanctuary Status) title(Sanctuary Status and Trust in Government), lfit trust_in_govt  ilrctotal, jitter(1)ms(Oh) //currently including in paper
twoway (scatter trust_in_govt ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Trust in gov't) xtitle(Sanctary Status) title(Sanctuary Status and Trust in Government), lfit trust_in_govt ilrctotal, ylabel(, labsize(medsmall) angle(horizontal) format(%9.2f)) //currently in paper
twoway (scatter trust_in_govt ilrctotal), ylabel(, labsize(medsmall) angle(horizontal) format(%9.2f))
twoway (scatter confidence_in_exec ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Confidence in Executive Branch) xtitle(Sanctuary Status) title(Sanctuary Status and Confidence in Executive), lfit confidence_in_exec ilrctotal, jitter(1)ms(Oh)
twoway (scatter confidence_in_leg ilrctotal, msize(small) msymbol(circle_hollow) mlabel(region) mlabsize(vsmall)), ytitle(Confidence in Legislative Branch) xtitle(Sanctuary Status) title(Sanctuary Status and Confidence in Legislative), lfit confidence_in_leg ilrctotal, jitter(1)ms(Oh)

//Regressions
reg ilrctotal happy, ro //Stat insignificant. Coeff is -2.9, R2 is 8.6 and P is greater than .05.
reg ilrctotal Congress_cares, ro //Stat insignificant. Coeff is 2.7, R2 is 12, and P is greater than .05, ie is 0.19.
reg ilrctotal trust_in_govt, ro //Stat insignificant. Coeff is -1.04. R2= 2.5 and P is greater than .05 ie is 0.235.
reg ilrctotal confidence_in_exec, ro //Stat significant. Coeff is 7.5. R2= 57 and P is .029.
reg ilrctotal confidence_in_leg, ro //Stat significant. Coeff is -5.7. R2= 41 and P is .036.
//Following are not statistically significant
reg confidence_in_exec happy, ro 
reg confidence_in_leg happy, ro 
reg Congress_cares happy, ro 
reg trust_in_govt happy, ro 
//using dummies 
reg ilrctotal PID2-PID8
reg ilrctotal PolView2-PolView7

//Given stat sig, focus in on ILRC relationship with confidence_in_exec
reg ilrctotal confidence_in_exec 
estimates store m1, title(Model 1)
reg ilrctotal confidence_in_exec edu income
estimates store m2, title(Model 2)
reg ilrctotal confidence_in_exec educ income norc_size_code
estimates store m3, title(Model 3)
reg ilrctotal confidence_in_exec educ income norc_size_code partyid
estimates store m4, title(Model 4)
estout m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2))) ///
legend label varlabels (_cons Constant) ///
stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

//Now look at happiness 
reg happy ilrctotal 
estimates store m1, title(Model 1)
reg happy ilrctotal confidence_in_exec edu income
estimates store m2, title(Model 2)
reg happy ilrctotal confidence_in_exec educ income norc_size_code
estimates store m3, title(Model 3)
reg happy ilrctotal confidence_in_exec educ income norc_size_code partyid
estimates store m4, title(Model 4)
estout m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2))) ///
legend label varlabels (_cons Constant) ///
stats(r2 df_r, fmt(3 0 1) label(R-sqr dfres))

************************
*******FOR LATER********
************************
//DATA SET 3
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


