* Problem Set 5 Do File
* Tara Carr-Lemke
* Data Management Class
* November 15, 2018

version 15
set more off  //will run everything
cap log close //to suppress error
sysdir //to see where stata saves
ssc install revrs//will need to use the reverse order command so install now

/**************/
/***navigate***/
/**************/

pwd //to see where we are
ls //to list what we have

/*******************/
/*****DATA SET 1****/
/***import/export***/
/******clean********/
/*******************/
//Look at and clean ILRC data
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
lookfor county
tab county //3,018 total counties 
lookfor state
tab state //Note that DE is only state missing 
tab ilrctotal //Overall look at ilrctotal variable. Note that there are observations at 0, 8 and 31 that need to be cleaned.
//Not sure if destring is necessary. 
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

rename no287g No_287g
la var No_287g "No 287g agreement"
rename noicedetentio~t No_ICE_detention_contract
la var No_ICE_detention_contract "No ICE dentention contract"
rename noiceholds No_ICE_holds
la var No_ICE_holds "No ICE holds"
rename noicealerts No_ICE_alerts
la var No_ICE_alerts "No ICE alerts"
rename limitsoniceinterrogationsinjail Limits_ICE_jail_interrogations
la var Limits_ICE_jail_interrogations "Limits on ICE jail interrogations"
rename prohibitiononaskingaboutimmigrat Prohibition_on_status_questions
la var Prohibition_on_status_questions "Prohibition on questions about status"
rename generalprohibitiononassistanceto General_ICE_prohibitions
la var General_ICE_prohibitions "General prohibitions on ICE"
rename geoidfips FIPS
save ILRCforDirectedStudy, replace
collapse ilrctotal, by(state) //I want a state average of ILRC totals.
tabstat ilrctotal, by(state) 
save ILRCforDirectedStudyState, replace

//Now look at region-level sanctuary status--if continue to want to look at regional level 
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
graph hbar (mean) ilrctotal if region, over(region) ytitle(Mean of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
graph hbar (median) ilrctotal if region, over(region) ytitle(Median of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of sanctuary policy in New England and the Pacific.)
graph hbar (sd) ilrctotal if region, over(region) ytitle(SD of Sanctuary Status) title(Sanctuary Status by Region) legend(on)note(There are higher levels of standrad deviation of sanctuary policy in XXX.)
save ILRCRegionforDirectedStudy, replace //could return to this data and create bar chart comparing sanctuary status with other variables

/**************/
/***visualize**/
/**************/
///Visualize ILRC data at the state level  
use ILRCforDirectedStudy, clear
graph hbar (mean) No_287g (mean) No_ICE_detention_contract (mean) No_ICE_holds (mean) No_ICE_alerts (mean) Limits_ICE_jail_interrogations (mean) Prohibition_on_status_questions (mean) General_ICE_prohibitions, title(Types and frequency of sanctuary status policies) bar(1, fcolor(gs10))bar(1, fcolor(gs10)) bar(2, fcolor(gs10))bar(3, fcolor(gs10))bar(4, fcolor(gs10)) bar(5, fcolor(gs10)) bar(6, fcolor(gs10)) bar(7, fcolor(gs10)) blabel(name, position(base)) legend(off)
//Labels are not the way I want them. Return to this.
keep ilrctotal state county jurisdiction FIPS //Ultimately, I only want to analyze these variables in regard to public perceptions.
graph hbar (mean) ilrctotal, over(state, label(labsize(vsmall))) title(Mean of Sanctuary Policies by State)
graph hbar (median) ilrctotal, over(state, label(labsize(vsmall))) title(Median of Sanctuary Policies by State)
graph hbar (sd) ilrctotal, over(state, label(labsize(vsmall))) title(Standard Deviation of Sanctuary Policies by State)
histogram ilrctotal, percent ytitle (Percentage of US Counties) xtitle("Sanctuary" Status) title(National Sanctuary Distribution) legend(on) clegend(on)note(The mean of sanctuary status nationwide is 2.4)
graph box ilrctotal, over(state, label(labsize(vsmall))) title(Variability of Santuary Status by State)
//But this last one is so hard to hard I'm not sure it's worth including

///Visualize ILRC data at the regional level
use ILRCRegionforDirectedStudy, clear
tabstat ilrctotal, by(region) //Mean of sanctuary status by region is 2.5. NE and Pacific have highest status. SW Central and NW Central have lowest.
tabstat ilrctotal, by(region) stat(mean sd) //Note level of variability in NE and Pacific.
graph hbox ilrctotal, over(region) title(Variability of Santuary Status by Region)

*******************/
/*****DATA SET 2****/
/***import/export***/
/******clean********/
/*******************/
//Harvard YouGov data for attitudes on immigration
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
//If I have time, I'd like to pull a slightly larger sample for analysis.
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
tab inputstate, plot sort //To view participation by state. No data for Alaska.
//Surveys asks r to respond to a variety of issues and respond How important is each of these issues to you?
//Rank Very Important=1, Somewhat High=2, Somewhat Low=3, Very Low=4, None=5
//Immigration is one of these questions (CC16_301d). I use this as a key output variable.
tab CC16_301d, mi //in this subsample, about 20% of participants were asked and responded to question (255 out of 1292)
//of this 255, about 75% identified this issue as somewhat high or very high importance
//I am curious about what this means: do people who rank immigration as an important issue trend anti- or pro-immigrant?
//Questions related to immigration and their variables follow. For closer analysis, I selected 4 questions about perceptions of immigration issues.
//I also selected variables related to party registration, immigration status, income, and importance of religion.
//Rename and label these variables
rename CC16_301d imm_imp_issue
la var imm_imp_issue "immigration is important issue"
rename CC16_331_1 grant_status //Yes=1, No=2
la var grant_status "grant status to illegal immigrants who have held jobs"
rename CC16_331_7 id_and_deport //Yes=1, No=2
rename CC16_331_3  support_dreamers //Yes=1, No=2
la var support_dreamers "grant status to dreamers"
la var id_and_deport "identify and deport illegal immigrants"
rename CC16_331_2 increase_borderpatrol //1=YES and 2=NO
la var increase_borderpatrol "increase border patrol"
rename CC16_360 party
la var party "party registration"
rename immstat imm_status //Which describes you? 1=immigrant citizen; 2=immigrant non-citizen; 3=first gen; 4=second gen; 5=third gen
la var imm_status "immigration status"
rename faminc family_income
la var family_income "family income"
rename pew_religimp religion_important //How important is rel in your life? 1=very to 4=not at all
la var religion_important "importance of religion"
rename inputstate state
rename countyfips county_fibs
rename countyname county_name
save YouGov, replace

keep imm_imp_issue state religion_important increase_borderpatrol countyfips countyname race hispanic imm_status party family_income support_dreamers id_and_deport grant_status
save YouGovKeyVariables, replace

//Eliminate missing values
replace imm_imp_issue=. if imm_imp_issue==. 
drop if imm_imp_issue==.
replace grant_status=. if grant_status==. 
drop if grant_status==.
replace id_and_deport=. if id_and_deport==. 
drop if id_and_deport==.
replace support_dreamers=. if support_dreamers==. 
drop if support_dreamers==.
replace increase_borderpatrol=. if increase_borderpatrol==. 
drop if increase_borderpatrol==.
replace imm_status=. if imm_status==. 
drop if imm_status==.
replace family_income=. if family_income==. 
drop if family_income==.
replace religion_important=. if religion_important==. 
drop if religion_important==.
save YouGovKeyVariables, replace

//Fix scales/order
codebook imm_imp_issue //first have a look at each variable, then reverse as needed
revrs imm_imp_issue, replace 
codebook imm_imp_issue //looks good
save YouGovKeyVariables, replace

//Create dummies for perceptions. These variables are 1=YES and 2=NO 
// No need to reverse the binary responses that follow, correct? 
//Should I code pro imm responses always as 0 and anti as 1? of keep yes and no coding consistent?
use YouGovKeyVariables, clear
codebook id_and_deport //1=yes and 2=no
replace id_and_deport=0 if id_and_deport==1
codebook increase_borderpatrol //1=yes and 2=no 
replace increase_borderpatrol=0 if increase_borderpatrol==1
codebook grant_status //1=yes and 2=no 
replace grant_status=0 if grant_status==1
codebook support_dreamers //1=yes and 2=no
replace support_dreamers=0 if support_dreamers==1
save YouGovKeyVariables, replace

//Create dummies for immigration/citizenship status. 
codebook imm_status
/*
1=Immigrant citizen
2=Immigrant non-citizen
3=First gen
4=Second gen
5=Third gen
*/
recode imm_status (1=2) (2=1), gen(y)
ta imm_status, gen(im)
d im*
save YouGovKeyVariables, replace
                         
//Create dummies for party.
use YouGovKeyVariables, clear
codebook party 
/* 
1=no party/indep/decline
2=Dem 
3=GOP 
4=other
*/
generate None_Indep = (party==1)
generate Dem = (party==2)
generate GOP = (party==3)
save YouGovKeyVariables, replace

//Create dummies for Hispanic status. 
codebook hispanic //1=yes and 2=no
replace hispanic=0 if hispanic==1
save YouGovKeyVariables, replace

//Create dummies for family income??
use YouGovKeyVariables, clear
save YouGovKeyVariables, replace

//Collapse by state
tab state
collapse imm_imp_issue grant_status id_and_deport support_dreamers increase_borderpatrol imm_status family_income religion_important hispanic party, by(state)
save YouGovKeyVariablesState, replace

//Look at YouGov data 
use YouGovKeyVariables, clear
tab imm_imp_issue grant_status, mi //Interesting. Looks as though respondents who say that imm is "very high importance" lean anti-immigrant. "Somewhat high" are mixed. Less importance lean pro.
tab imm_imp_issue support_dreamers, mi //This same as above.
tab imm_imp_issue id_and_deport, mi //This reflects same as one above.
tab imm_imp_issue increase_borderpatrol, mi //Reflects trend above.
tab imm_imp_issue imm_status, mi //As length of time in US increases, "very high" importance increases. 
tab imm_imp_issue religion_important, mi // The more religious believe immigration to be an important issue.
table imm_imp_issue grant_status support_dreamers
table imm_imp_issue id_and_deport increase_borderpatrol

/**************/
/**regressions*/
/**************/ 
//Run regressions on YouGov data
//IV are various. DV is "imm is important issue."
//Hypo: respondents who rank immigration as an important issue lean anti-immigrant.
//Does it make sense to look closely at these via regressions?
//Because these are YES or NOs, can I do this? I think so because they are aggregates and means.
logit grant_status imm_imp_issue, ro //Looks to be stat sig. R2 of only 6. 
logit support_dreamers imm_imp_issue, ro //Looks to be stat sig. R2 of only 6.
logit id_and_deport imm_imp_issue, ro //Looks to be stat sig. R2 of 13.
logit increase_borderpatrol imm_imp_issue, ro //Looks to be stat sig. R2 of 7.

//Creating a table for regression results for grant immigration staus to some immigrants 
//Hypo: This variable appears to predict low levels for the "immig is important issue" question.
use YouGovKeyVariables, clear
//does this table make sense?
logit grant_status imm_imp_issue
outreg2 using grantstatus.doc, replace ctitle(model 1)

logit grant_status imm_imp_issue imm_status
outreg2 using grantstatus.doc, append ctitle(model 2)

logit grant_status imm_imp_issue imm_status family_income
outreg2 using grantstatus.doc, append ctitle(model 3)

logit grant_status imm_imp_issue imm_status family_income party
outreg2 using grantstatus.doc, append ctitle(model 4)

//Creating a table for regression results for id and deport  
//Hypo: This variable appears to predict high levels for the "immig is important issue" question.
use YouGovKeyVariables, clear
logit id_and_deport imm_imp_issue
outreg2 using id_and_deport.doc, replace ctitle(model 1)

logit id_and_deport imm_imp_issue imm_status
outreg2 using id_and_deport.doc, append ctitle(model 2)

logit id_and_deport imm_imp_issue imm_status family_income
outreg2 using id_and_deport.doc, append ctitle(model 3)

logit id_and_deport imm_imp_issue imm_status family_income party
outreg2 using id_and_deport.doc, append ctitle(model 4)

/***************/
/*visualization*/
/***************/ 
use YouGovKeyVariables, clear
graph hbar (mean) id_and_deport if state, over(state,label(labsize(tiny))) title(Immigration Importance: Should US ID and Deport?)
//Id and Deport is a 1=YES or 2=NO
graph hbar (mean) increase_borderpatrol if state, over(state,label(labsize(tiny))) title(Immigration Importance: Should US Up Border Patrol?)
//Increase BP is a 1=YES or 2=NO 
graph hbar (mean) grant_status if state, over(state,label(labsize(tiny))) title(Immigration Importance: Grant Immigration Status)
//Grant status to certain immigrants is a 1=YES or 2=NO
graph hbar (mean) support_dreamers, over(state,label(labsize(tiny))) title(Immigration Importance: Support Dreamers)
//Dreamers is a 1=YES or 2=NO

/*use YouGovKeyVariablesState, clear
twoway (scatter grant_status imm_imp_issue), ytitle(US should grant immigration status) xtitle(Immigration is an important issue) title(Immigration Importance and Grant Status), lfit grant_status imm_imp_issue
twoway (scatter support_dreamers imm_imp_issue), ytitle(US shouldsupport Dreamers) xtitle(Immigration is an important issue) title(Immigration Importance and Support for Dreamers), lfit support_dreamers imm_imp_issue
twoway (scatter id_and_deport imm_imp_issue), ytitle(US should deport undocumented) xtitle(Immigration is an important issue) title(Immigration Importance and Support for Deportation), lfit support_dreamers imm_imp_issue
//Id and Deport result surprises me
twoway (scatter increase_borderpatrol imm_imp_issue), ytitle(US should increase border patrol) xtitle(Immigration is an important issue) title(Immigration Importance and Increase Border Patrol), lfit increase_borderpatrol imm_imp_issue
//make sense? twoway (scatter increase_borderpatrol id_and_deport imm_imp_issue), ytitle(Anti-Immigrant Sentiment) xtitle(Immigration is an important issue) title(Immigration Importance and Increase Border Patrol)
*/

/**************/
/*****merge****/
/**************/
use ILRCforDirectedStudy, clear
encode state, gen(state3) //to create numerical storage type from string 
drop state
ren state3 state
d
save ILRCforDirectedStudyDestring, replace
collapse ilrctotal, by(state)
merge 1:m state using YouGovKeyVariablesState //10 not merged because they are missing values
save ILRCforDirectedStudyDestringYouGov, replace

/*****************/
/***regressions***/
/***using merge**/
/****************/
use ILRCforDirectedStudyDestringYouGov, clear
//Now that I have established that those who rank immigration as an important issue lean anti-immigrant, I would like to see if sanctuary policy in a jurisdiction reflects the pro- or anti-immigration opinion of respondents there.
reg imm_imp_issue ilrctotal, ro //appears to be stat insignificant with a P=0.094 and a R2=85.
//not sure next line makes sense: using imm status, party and family income make sense as expressed here. Do I need to code as dummy variables? 
reg imm_imp_issue ilrctotal imm_status party family_income 

/********************/
/***visualizations***/
/********************/
use ILRCforDirectedStudyDestringYouGov, clear
graph hbar (mean) imm_imp_issue ilrctotal, over(state, label(labsize(tiny))) title(Immigration is an Important Issue)
graph hbar (mean) id_and_deport ilrctotal, over(state, label(labsize(tiny))) title(Importance of Identifying and Deporting Undocumented)
graph bar (mean) imm_imp_issue (mean) id_and_deport, over(state)
graph hbar (mean) grant_status, over(state, label(labsize(tiny))) title(US Should Grant Certain Immigrants Status)

histogram imm_imp_issue, bin(10) percent xtitle(Immigration is an Important Issue) title(Immigration is an Important Issue)
twoway (scatter grant_status ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(US should grant status) xtitle(Sanctuary Status) title(Sanctuary Status and Legal Status), lfit grant_status ilrctotal, jitter(1)ms(Oh)
twoway (scatter grant_status ilrctotal, msize(small) msymbol(circle_hollow) mlabel (state) mlabsize(vsmall)), ytitle(US should grant status to certain immigrants) xtitle(Sanctuary Status) title(Sanctuary Status and Granting of Status), lfit grant_status ilrctotal
twoway (scatter id_and_deport ilrctotal) (scatter imm_imp_issue ilrctotal, sort), ytitle(Perceptions on immigration) xtitle(Sanctuary Status) title(Immigration is Important Issue and Border Patrol) 


/**************/
/***FUTURE?****/
/**************/
//If interested in regions...
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

