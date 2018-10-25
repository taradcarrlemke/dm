//merge m:m almost never make sense!!


* Problem Set 4 Do File PREP
* Tara Carr-Lemke
* October 25, 2018

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
/******* visualize *******/
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
//note that there is no informtaion on DE

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


collapse ilrctotal, by(state) //I want a state average of ILRC totals.
l
drop in 11 //drop Guam
drop in 39 //drop PR
save ILRC-alt, replace

use ILRC-alt, clear
l
sort state
count if state==state[_n-1]
l if state==state[_n-1]

//information from previous file AttitudesImm_GSS
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

label define region_label 1 "New England" 2 "Mid Atlantic" 3 "NE Central" 4 "NW Central" 5 "South Atlantic" 6 "SE Central" 7 "SW Central"  8 "Mt" 9 "Pacific"

label values region region_label

save ILRC_Region, replace

tabstat ilrctotal, by(state)

tabstat ilrctotal, by(region)
tabstat ilrctotal, by(region) stat(mean sd)
graph hbar ilrctotal, over(region) //make the region labels smaller !

scatter ilrctotal region
graph hbox ilrctotal, over(region)
l if region==9 & ilrctotal>4
d ilrctotal
d region
codebook region



insheet using "https://docs.google.com/uc?id=1JUm0pf7QkwQViJqOAspO-0Cd8EK8mgse&export=download", clear

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
replace state = "IA" in 18
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
//I might want to go back and transform into percentages rather than counts. This would be easier to interpret later. 
rename v4 Total_Population //easier to read if I clean the variable name
drop in 1/2
save PerHisLat, replace
drop in 8 //to eliminate DE for merging purposes--it does not appear in ILRC list 
save PerHisLat-alt, replace

use PerHisLat-alt, clear
generate region=.
//replace region= 1 if inlist(state, "CT","ME","RI","MA","NH","VT") 
replace region= 1 if state == "CT" | state == "ME" | state == "RI" | state == "MA" | state == "NH" | state=="VT"
replace region= 2 if state == "NY" | state == "NJ" | state == "PA"
replace region= 3 if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
replace region= 4 if state == "IA" | state == "KS" | state == "MO" | state == "NE" | state == "SD" | state=="ND"| state=="MN"
replace region= 5 if state == "DE" | state == "DC" | state == "MD" | state == "VA" | state == "WV" | state=="NC"| state=="SC" | state=="GA"| state=="FL"
replace region= 6 if state == "Al" | state == "KY" | state == "MS" | state == "TN" 
replace region= 7 if state == "AR" | state == "LA" | state == "OK" | state == "TX" 
replace region= 8 if state == "CO" | state == "MT" | state == "UT" | state == "WY" | state == "NM" | state=="ID"| state=="NV" | state=="AZ"
replace region= 9 if state == "CA" | state == "HI" | state == "AK" | state == "OR" | state == "WA" 

count if region==.
sort region
l //PR is on the list 
save PerHisLat_Region, replace
merge m:m region using PerHisLat_Region //PR still there and only one that did not match 

tab ilrctotal region
tab Total_HisLat ilrctotal //still need to calculate %

//NEW 
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download" 
//decided to look at GSS for attitudes towards immigrants 
keep region excldimm immjobs immameco
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
// findit revrs
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
save AttitudesImm_GSS, replace

use ILRC_Region, clear
l
//m:m almost never make sense!!
merge m:m region using AttitudesImm_GSS
//m:1 on state???
save ILRCRegion_AttitudesImm_GSSMERGE, replace 


//then tables and tabs and grapghs 
tab ilrctotal tougher, row
tw(lfit ilrctotal tougher)
corr ilrctotal tougher
graph hbar ilrctotal tougher, over(region)
tw(lfit ilrctotal eco_plus)
table ilrctotal tougher
table ilrctotal tougher region //better if catergorical
hist ilrctotal, by(region)
scatter ilrctotal tougher

/*sysuse  nlsw88 , clear
tab married collgrad 
table collgrad union married  //nice!
table collgrad union married, 
