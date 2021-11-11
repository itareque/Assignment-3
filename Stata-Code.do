*set working directory

cd "/Users/ist2118/Documents/Research Methods II/Assignment 3"


* Install the "estout" package: 

ssc install estout


* Read in data: 

insheet using sports-and-education.csv, comma names clear


* Labeling variables

label variable academicquality "Academic Quality"
label variable athleticquality "Athletic Quality"
label variable nearbigmarket "Near Big Market"
label variable ranked2017 "Ranked (2017)"
label variable alumnidonations2018 "Alumni Donations (2018) ('000 dollars)"

    
* Balance table

global balanceopts "bf(%15.2gc) sfmt(%15.2gc) se noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) "
estpost ttest  academicquality athleticquality nearbigmarket, by(ranked2017) unequal welch
esttab . using balancetable.rtf, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide label collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) replace mgroups(none)


*Calculating propensity_score:

logit ranked2017 academicquality athleticquality nearbigmarket 
predict propensity_score, pr

* Stacked histogram

twoway (histogram propensity_score if ranked2017==1, start(0) width(0.1) color(red%30)) ///        
(histogram propensity_score if ranked2017==0, start(0) width(0.1) color(blue%30)), /// 
xtitle("Propensity Score (Ranked)")  legend(order(1 "Ranked" 2 "Unranked" ))

* Restricting the overlapping set to propensity_score <= 0.8 

drop if propensity_score>0.8

* Blocking

sort propensity_score
gen block = floor(_n/4)


* Regression

reg alumnidonations2018 ranked2017 academicquality athleticquality nearbigmarket i.block


* Store regression

eststo regression_one


**********************************
* Exporting table 
global tableoptions "bf(%15.2gc) sfmt(%15.2gc) se label noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01) replace r2 "
esttab regression_one  using assignment3-Table2.rtf, $tableoptions keep(ranked2017 academicquality athleticquality nearbigmarket)

