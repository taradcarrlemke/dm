//good preamble
* Problem Set 1 Do File
* Tara Carr-Lemke
* September 21, 2018

version 15

//import/export//

//no! i odnt have this path! must load from online
use "C:\Users\tdc57\AppData\Local\Temp\Temp1_2014_stata-1.zip\GSS2014.DTA"

//yes!
copy http://gss.norc.org/documents/stata/2014_stata.zip ./
unzipfile 2014_stata.zip
use GSS2014.DTA, clear
set more off 

//looking//

d

//no! it must be block comment!
//Contains data from GSS2014.DTA
  obs:         2,538                          
 vars:           896                          
 size:     2,776,572//
 
keep excldimm immjobs immameco
//I want to observe only three variables related to public opinion regarding immigration.

//good, though var names should be little shorter and can label them with 
// la var mpg "miles per gallon"
rename immjobs Immigrants_Take_Jobs

rename immameco Immigrants_Good_for_Economy

rename excldimm Stronger_on_Immigration
//I wanto to rename variables.

sample 100, count
//(2,438 observations deleted)
 
//again, need to have block comment! 
sum
//
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
Stronger_o~n |         40         2.7    1.202561          1          5
Immigrants~y |         41    2.512195    .9778024          1          5
Immigrant_~s |         42    3.119048    1.086556          1          5
//

//good
//There are three missing values in the data:
//.i: Inapplicable (IAP). Respondents who are not asked to answer a specific question are assigned to IAP.
//.d: Don't know (DK)
//.n: No answer (NA)

//Table shows that about half of respondents think that a) the US should be stronger on excluding unauthorized immigration and b) that immigrants benefit the economy. There were a significant number of missing values (about half) in total. 
//Table shows that over half of respondents believe that immigrants take jobs from US citizens.
//I decided to take a slightly larger sample (100 instead of 50) due to the amount of missing info.

tab Immigrants_Good_for_Economy

 //      immigrants good for |
                   america |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |          4        9.76        9.76
                     agree |         20       48.78       58.54
neither agree nor disagree |         11       26.83       85.37
                  disagree |          4        9.76       95.12
         disagree strongly |          2        4.88      100.00
---------------------------+-----------------------------------
                     Total |         41      100.00//

tab Stronger_on_Immigration

//
    america should exclude |
        illegal immigrants |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |          5       12.50       12.50
                     agree |         17       42.50       55.00
neither agree nor disagree |          7       17.50       72.50
                  disagree |          7       17.50       90.00
         disagree strongly |          4       10.00      100.00
---------------------------+-----------------------------------
                     Total |         40      100.00
//

tab Immigrant_Take_Jobs

//
 immigrants take jobs away |      Freq.     Percent        Cum.
---------------------------+-----------------------------------
            agree strongly |          2        4.76        4.76
                     agree |         13       30.95       35.71
neither agree nor disagree |          8       19.05       54.76
                  disagree |         16       38.10       92.86
         disagree strongly |          3        7.14      100.00
---------------------------+-----------------------------------
                     Total |         42      100.00
//
					 
//need egen etc!					 
