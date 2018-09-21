* Problem Set 1 Do File
* Tara Carr-Lemke
* September 21, 2018

version 15

//import/export//

use "https://docs.google.com/uc?id=1g9U3gG9ssuU4V0dR0AmYCoNMv-0AcFI&export=download",clear
//this doesnt run--pls see instructions in the ps!

//do I need the next 3 lines??? yes if you load data here, no if you load in the line above
//Copy http://gss.norc.org/documents/stata/2014_stata.zip ./
//unzipfile 2014_stata.zip
//use GSS2014.DTA, clear

set more off 

//looking//

d

//Contains data from GSS2014.DTA
// obs:         2,538                          
// vars:           896                          
// size:     2,776,572//
 
keep excldimm immjobs immameco
//I want to observe only three variables related to public opinion regarding immigration.

rename immjobs take_jobs

rename immameco eco_plus

rename excldimm tougher 
//I wanto to rename variables.

sample 100, count
//(2,438 observations deleted)
 
sum

//more efficient to do block comment here
//Table shows that about half of respondents think that a) the US should be stronger on excluding unauthorized immigration and b) that immigrants benefit the economy. There were a significant number of missing values (about half) in total. 
//Table shows that over half of respondents believe that immigrants take jobs from US citizens.
//I decided to take a slightly larger sample (100 instead of 50) due to the amount of missing info.
//There are three missing values in the data:
//.i: Inapplicable (IAP). Respondents who are not asked to answer a specific question are assigned to IAP.
//.d: Don't know (DK)
//.n: No answer (NA)


tab take_jobs

//have to comment these out!!
//immigrants take jobs away |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |          4        8.51        8.51
                     agree |         15       31.91       40.43
neither agree nor disagree |          4        8.51       48.94
                  disagree |         19       40.43       89.36
         disagree strongly |          5       10.64      100.00
---------------------------+-----------------------------------
//                     Total |         47      100.00

tab eco_plus

//       immigrants good for |
                   america |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |          3        6.38        6.38
                     agree |         18       38.30       44.68
neither agree nor disagree |         18       38.30       82.98
                  disagree |          8       17.02      100.00
---------------------------+-----------------------------------
                     Total |         47      100.00
//

tab tougher

//    america should exclude |
        illegal immigrants |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |         13       26.53       26.53
                     agree |         16       32.65       59.18
neither agree nor disagree |         10       20.41       79.59
                  disagree |          7       14.29       93.88
         disagree strongly |          3        6.12      100.00
---------------------------+-----------------------------------
                     Total |         49      100.00

					 
//manipulate//
//first use generate and replace//

generate antiimmigrant=.
//(100 missing values generated)

replace antiimmigrant=1 if take_jobs==1

replace antiimmigrant=1 if take_jobs==2

replace antiimmigrant=0 if take_jobs>3 & take_jobs<6
ta antiimmigrant take_jobs, mi //double check!
tab antiimmigrant

//antiimmigra |
         nt |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         24       55.81       55.81
          1 |         19       44.19      100.00
------------+-----------------------------------
      Total |         43      100.00			 
//

//now use recode//

recode take_jobs(1/2 =1) (4/5=0), gen(antiimmigrant)

//now use recode x2//
use GSS2014.DTA, clear
keep excldimm immjobs immameco
rename immjobs take_jobs
rename immameco eco_plus
rename excldimm tougher 
sample 100, count
recode take_jobs (1/2=1), gen(antiimmigrant) //need to add sth like nonm=0; and can label like "yes" "no"
tab take_jobs antiimmigrant, mi //to check for missing//
