//this is great! still may want to reorganize code a bit and clean up; eg print it out and see what is repetetive and esspecially
//what can be moved and fitted better elsewhere

//next step is to visualize and strat inserting key ouput into paper and discussing it there in depth
//and move on to test your research hypotheses

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
/*******************/
// DATA SET 1
//Look at ILRC data
//Source is The Rise of Sanctuary from the Immigrant Legal Resource Center January 2018. ILRC was able to access the data via a FOIA. 
insheet using "https://docs.google.com/uc?id=0B2oGmpM5JAVJZ0NzcVN5QVJlXzN3TVd2T3M1NDBQd3V6bGpR&export=download",clear
d
lookfor county
ta county
lookfor state
ta state
sort county state //note that there is no information on DE

destring *, replace
destring *, replace ignore(",")

//Eliminate categories of 8 and 31
replace ilrctotal=. if ilrctotal==8
replace ilrctotal=. if ilrctotal==31

//Correct addition error
replace ilrctotal = 3 if jailorprisonc=="Dyersburg" //this is more bullet proof; 811 obs would change if you change sth little

//Eliminate 0 values. It is unclear what real value should be. 
drop if ilrctotal==0

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
hist ilrctotal, percent //to check and see if data looks cleaned and to get visual
keep ilrctotal state county jurisdiction //I only want to analyze these variables.
tab state ilrctotal 
drop if state=="Puerto Rico" | state=="Guam" //again like earlier! this is safer, and easy see what is the condition for dropping
//why couldn't I use drop if state==Puerto_Rico command??? yes you can just put in quotes

histogram ilrctotal, percent title(Nationwide Sanctuary Rankings) legend(on) clegend(on) //better visual
collapse ilrctotal, by(state) //I want a state average of ILRC totals.
//for later: with collapse can aslo specify sd, median etc, all in one command--see help collapse
l
save ILRCforHappinessClass, replace

//DATA SET 2
//Now look at Harvard YouGov data
//Note: I had to take several samples before getting the file down to a manageable size. Command was "sample 20." 
use "https://docs.google.com/uc?id=1zkstWJAK2OPfOT-dm2x4eMq56NX3-_jT&export=download", clear
sum
tab inputstate //To view participation by state. No data for Alaska.
tab inputstate,plot //Tbetter visual
tab inputstate,plot sort //another visiual from lo to high
//A question related to immigration
//Question CC16_301d: most important problem is immigration
//Question reads: How important is each of these issues (a variety of issues were provided) to you? Very High/Somewhat High/Somewhat Low/Very Low/None. Immigration is one of the choices.
tab CC16_301d //76% of participants id issue as high or very high importance
rename CC16_301d imm_big_problem
//just replabel and can then droop from comments:) same for others
la var imm_big_problem "most important problem is immigration"

rename inputstate state
keep imm_big_problem state
tab imm_big_problem, mi  //about 25% of total respondents identified immigration as one of their top issue
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
save ImmBigProbforHappinessClass, replace
l

/********************/
/*****manipulate*****/
/*******************/

use ILRCforHappinessClass, clear
l
merge 1:1 state using ImmBigProbforHappinessClass // 48 matched. DE is in using only. AK and ND are in master only.
drop _merge
save ILRCandImmBigProbforHappinessClassMERGE, replace

use ILRCandImmBigProbforHappinessClassMERGE, clear
//yep tables and graphs make sense, and totally fie to have a lot of them
//but put quick comments what you found in them interesting as a comment as a note in graph
//that way when you write paper you wont forget it
//and put in the body of the paper only the most important ones
//othgers are just for you or perhaps into the appendix or supplementry online material

tabstat ilrctotal imm_big_problem
tabstat ilrctotal imm_big_problem, by(state)
corr ilrctotal imm_big_problem

//dependent var (immi big problem) on Y axis and indep (ilrctotal) on x axis 

scatter ilrctotal imm_big_problem, jitter(1)ms(Oh)
scatter ilrctotal imm_big_problem, jitter(1)ms(Oh)mlab(state) mlabsize(vsmall)

twoway (scatter imm_big_problem ilrctotal, sort), title(Sanctuary Rankings and Views on Immigration by State)

twoway (scatter imm_big_problem ilrctotal, msize(small) msymbol(circle_hollow) mlab(state) mlabsize(vsmall) sort), title(Sanctuary Rankings and Views on Immigration by State)note(we see that state x and y are higher on z than expected etc)

twoway (lfit imm_big_problem ilrctotal) (scatter imm_big_problem ilrctotal), ytitle(Immigration is Big Problem) xtitle(Sanctuary Level) title(Sanctuary Rankings and Views on Immigration by State) legend(on)

twoway (scatter imm_big_problem ilrctotal, msize(small) msymbol(circle_hollow) mlabel(state) mlabsize(vsmall)), ytitle(Immigration is Big Problem) xtitle(Sanctuary Level) title(Sanctuary Rankings and Views on Immigration by State), lfit imm_big_problem ilrctotal, jitter(10)

twoway (lfit imm_big_problem ilrctotal), title(Sanctuary Rankings and Views on Immigration by State) //could add titles and legand here


/********************/
/***import/export***/
/****MORE DATA****/

//DATA SET 3
//Now look at GSS for attutudes towards immigrants and government  
//this looks at region, not state
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download"
set more off  
d
//Contains data from GSS2014.DTA
//I could use the entire GSS data set over the years.  Ask Dr Adam for help. It is too big to download to github or google and I am having trouble with sampling.
//I used tab, mi below but could also use tab to look only at respondents
tab govdook, mi //we can trust people in govt--10% agree or strongly agree; 13% neither agree not disagree; 24% disagree or disagree strongly; 50% no information
tab conleg, mi //confidence in congress--25% had some or lots; 35% had hardly any; 34% no answer
tab confed, mi //confidence in executive branch--36% had some or lots; 29% had hardly any; 34% no anwers
tab immcrime, mi //immigrants increase crime--8% agree; 12% neither; 25% disagree; 50% not polled
tab affctlaw, mi // congress gives serious attention to r's demands: 10% likely; 35% not likely; 50% no answer
//keep a number of other variables of interest like...

keep region excldimm immjobs immameco immcrime happy govdook conleg confed affctlaw uscitzn voteelec vote08 vote12 polint1 relig race dem10fut dem10pst demtoday attrally amgovt
rename excldimm tougher
rename immjobs take_jobs
rename immameco eco_plus
rename govdook trust_in_govt
rename conleg confidence_in_leg
rename confed confidence_in_exec
rename affctlaw Congress_cares
rename polint1 political_interest
rename amgovt respect_USlaw
rename attrally attend_political_event

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

tab happy tougher
tab happy take_jobs, row
histogram tougher, by(region)
//when I merge the ILRC total data, can I look at happiness in states with or without sanctuary policies
save AttitudesImmigandGovt_GSSforHappinessClass, replace
//can't merge this with state-level--must merge with regional level 

//this chunk here could just move to the to where you did that dataset--would be cleaner :)
use ILRCforHappinessClass, clear 
l
sort state
count if state==state[_n-1]
l if state==state[_n-1]

//information from previous GSS file 
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
sort region 
l

label define reg_label 1 "new england" 2 "middle atlantic" 3 "e. nor. central" 4 "w. nor. central" 5 "south atlantic" 6 "e. sou. central" 7 "w. sou. central"  8 "mountain" 9 "pacific"

label values region reg_label

save ILRC_Region_forHappinessClass, replace


*******************************
*******Manipulate and Merge****
*******************************
//so looks like everything has at least state, except gss
//so i would merger everything on state, and then on region with gss (m:1)

use ILRC_Region_forHappinessClass, clear
ta region
d
collapse ilrctotal, by(region)
save ILRC_Region_forHappinessClass-alt, replace
l
use AttitudesImmigandGovt_GSSforHappinessClass, clear
tab region
collapse tougher, by(region)
merge 1:m region using ILRC_Region_forHappinessClass //just the other way round :) 1:m
//issue with using data and unique values again--getting error 
//once I have this figured out, I would also like to use a number of variables from GSS on merge.  Do I need to do so separately?
save ILRC_RegionandAttitudesImmigandGovtforHappinessClassMERGE, replace

************************
*******Visualization****
************************
//once I get the above merged, I'll start graphing 


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


