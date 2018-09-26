* Problem Set 1 Do File
* Tara Carr-Lemke
* September 21, 2018

version 15

//*import/export*//

use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download"
set more off 

//*looking*//

d

//Contains data from GSS2014.DTA
// obs:         2,538                          
// vars:           896                          
// size:     2,776,572//
 
//*manipulate*//
//*variables*//

keep excldimm immjobs immameco
//I want to observe only three variables related to public opinion regarding immigration.

rename immjobs take_jobs

rename immameco eco_plus

rename excldimm tougher 
//I want to to rename variables.

sample 100, count
//(2,438 observations deleted)

sum

//Table shows that about half of respondents think that a) the US should be stronger on excluding unauthorized immigration and b) that immigrants benefit the economy. There were a significant number of missing values (about half) in total. 
//Table shows that over half of respondents believe that immigrants take jobs from US citizens.
//I decided to take a slightly larger sample (100 instead of 50) due to the amount of missing info.
//There are three missing values in the data:
//.i: Inapplicable (IAP). Respondents who are not asked to answer a specific question are assigned to IAP.
//.d: Don't know (DK)
//.n: No answer (NA)

//I now tab to take a closer look at the three variables

tab take_jobs 

//see that roughly 40% agree that immigrants take jobs, 49% disagree, and 9% neither agree nor disagree.

tab take_jobs, mi
//To view the missing values. Note that over half have the IAP code.

tab eco_plus

//roughly 40% do not agree that immigrants are good for economy, 46% believe that they are. 

tab eco_plus, mi
//Note the same number of IAP values as last variable.

tab tougher

//to observe perceptions on whether or not America should be tougher to exclude unauthorized immigrants

tab tougher, mi
//Note the same number of IAP values as other two variables.

					 
//first use generate and replace//

generate antiimmigrant=. //generate empty variable
//(100 missing values generated)

replace antiimmigrant=1 if take_jobs==1

replace antiimmigrant=1 if take_jobs==2
//could I use the following code instead? replace antiimmigrant=1 if take_jobs>1 & take_jobs<3

replace antiimmigrant=0 if take_jobs==4 

replace antiimmigrant=0 if take_jobs==5

//or could use replace antiimmigrant=0 if take_jobs>3 & take_jobs<6

//need to consider how can I code for neither agree nor disagree or value of 3

tab antiimmigrant

//to view antiimmigrant perceptions

codebook take_jobs
//I want to look at values and meanings.			 
//8 neither agree not disagree responses not reflected in the table

//now use recode//
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear
keep excldimm immjobs immameco
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
sample 100, count

recode take_jobs(1/2 =1) (4/5=0), gen(antiimmigrant)
tab antiimmigrant

// look at recode of immigrants take jobs away 
codebook antiimmigrant //numbers are consistent--there are 40 missing values.

//----------------------------------------------------------------------------------------
//now use recode x2//
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear
keep excldimm immjobs immameco
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
sample 100, count

recode take_jobs (1/2=1 "yes") (4/5=0 "no"), gen(antiimmigrant)
tab antiimmigrant //observe antiimmigrant sentiments 
//
  RECODE of |
  take_jobs |
(immigrants |
  take jobs |
      away) |      Freq.     Percent        Cum.
------------+-----------------------------------
         no |         21       46.67       46.67
        yes |         16       35.56       82.22
          3 |          8       17.78      100.00
------------+-----------------------------------
      Total |         45      100.00
//how to code 3s?

tab take_jobs antiimmigrant, mi //to check for missing values

//----------------------------------------------------------------------------------------
//now use rename, generate and replace for additional variables// 
//I want to look at those respondents who are both college educated as well as anti-immigrant as classified by responses to immigrants take jobs
use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear
keep excldimm immjobs immameco educ
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
rename educ education
sample 100, count

generate antiimmigrant=. 
replace antiimmigrant=1 if take_jobs==1
replace antiimmigrant=1 if take_jobs==2
replace antiimmigrant=0 if take_jobs==4 
replace antiimmigrant=0 if take_jobs==5

generate college=.
replace college=1 if educ>=16

generate edAntiimmigrant=.
replace edAntiimmigrant=1 if take_jobs==1/2 & college>=16

// now use egen 

use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI_&export=download", clear 
egen avg_educ=mean(educ)
sum avg_educ //average level of education is 13.38 years
sum educ
gen dev_educ=educ-avg_educ //generating standard deviation equation 
l educ avg_educ dev_educ in 1/10, nola //to create a table with 10 examples

bys take_jobs: egen avgm_educ=mean(educ)

l  *educ* *take_jobs*  if take_jobs==1/2 | take_jobs==4/5

sort take_jobs
l  *educ* *take_jobs* , nola sepby(take_jobs) //note that avg_educ is constant at 13.38 years, but avgm_edu varies by responses to take_jobs question ie level of anti-immigrant sentiment
//. is dropped when calculating egen stats 

