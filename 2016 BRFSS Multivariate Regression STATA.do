*
*	Author: Clemence Alexia Fichet
*
*	Project: Modeling BMI as an Outcome of Comorbidities Associated with Drinking
* 	Alcohol in Alabama: A Multiple Linear Regression Study 
*
*	Date: April 2026
*
*	Description:
*	This is code written for a Multiple Linear Regression Final Project for PHEB
*	603: Biostatistics II at Texas A&M University's School of Public Health. The
*	source data is from the 2016 Behavioral Risk Factor Surveillance Survey
*	(BRFSS), subsetted to only include data from Alabama.
*
*		Copyright (c) 2026 Clemence Alexia Fichet
*		Licensed under the MIT License
*

**# Start
* Import Dataset *
use "\\storage.it.tamu.edu\TAMU\OAL\Homes\clemence.fichet\Downloads\PHEB 603 Spring 2026 Final Project\BRFSS2016a.dta"

* Subset 1 Outcome Variable and 15 Predictor Variables *
keep seqno _bmi5 addepev2 diabete3 rmvteth3 income2 smoke100 marital educa exerany2 numadult hlthpln1 sleptim1 sex veteran3 employ1 alcday5

**# Cleaning

* Drop all non-numeric data rows *
drop if _bmi5==. | addepev2==. | diabete3==. | rmvteth3==. | income2==. | smoke100==. | marital==. | educa==. | exerany2==. | numadult==. | hlthpln1==. | sleptim1==. | sex==. | veteran3==. | employ1==. | employ1==. | alcday5==.
* Brings us to 2,134 observations *

codebook 
	* to explore observation levels *

* Drop all "Don't Know" or "Refused" *
	drop if hlthpln1==7 | hlthpln1==9
	drop if exerany2==7 | exerany2==9
	drop if sleptim1==77 | sleptim1==99
	drop if addepev2==7 | addepev2==9
	drop if diabete3==2 | diabete3==7 | diabete==9 
	* ==2 is uniquely gestational diabetes *
	drop if rmvteth3==7 | rmvteth3==9
	drop if marital==9
	drop if educa==9
	drop if veteran3==7 | veteran3==9
	drop if employ1==9
	drop if income2==77 | income2==99
	drop if smoke100==7 | smoke==9
	drop if alcday5==777 | alcday5==999
	* numadult, sex, and _bmi5 were fine to begin with *
	* ended with 1,511 observations *

**# Variable Fixing ######################################################
* make numeric ID variable
gen id = real(substr(seqno, 5, .))

generate double _bmi5_new = _bmi5/100
	*_bmi5 has two "implied" decimals, create new variable that has exact decimals *

codebook 
	* check descriptive statistics for variables *
sum numadult, detail
	* descriptive statistics for numadult *

* Make a new variable for alcoholic drink days/month 
gen alc_month = .
	* monthly respondents=
	replace alc_month = mod(alcday5, 100) if inrange(alcday5, 201, 231)
	* weekly respondents → convert to monthly (~4.33 weeks/month)=
	replace alc_month = mod(alcday5, 100) * 4.33 if inrange(alcday5, 101, 107)
	* sober=
	replace alc_month = . if alcday5 == 888 
		* made sober missing on purpose so 'sum' functions would not include sober

		* Make this dataset exclusive to a stochastic alcohol process*
		drop if alc_month == .
		*now at 525 observations 

* Collapse levels of obervation for Income, Employment, Marital, and Education*
gen income_cat = .
	replace income_cat = 2 if inrange(income2, 1, 3)
	replace income_cat = 1 if inrange(income2, 4, 6)
	replace income_cat = 0 if inrange(income2, 7, 8)
	* low income = 2, middle income = 1, high income = 0 for reference
	*low income = [X < 20k] 
	* middle income = [20k =< X < 50k] 
	* high income = [50k =< X]

gen educa_cat = .
	replace educa_cat = 1 if inrange(educa, 1, 3)
	replace educa_cat = 0 if inrange(educa, 4, 5)
	replace educa_cat = 2 if educa == 6
	* less than high school = 1 
	* high school or some college = 0 REFERENCE
	* college degree or above = 2

gen employ_cat = .
	replace employ_cat = 0 if inrange(employ1, 1, 2)
	replace employ_cat = 1 if inrange(employ1, 3, 8)
	* employed = 0 REFERENCE
	* not employed = 1
	
gen marital_cat = .
	replace marital_cat = 1 if marital == 1 | marital == 6
	replace marital_cat = 0 if inrange(marital, 2, 5)
	* married/partnered = 1 (married people and people in partnerships)
	* unmarried/single = 0 REFERENCE (divorced/widowed/separated/never married)

* Making Reference Levels
	* recode var (old = new) (old = new)
	recode hlthpln1 (1 = 0) (2 = 1)
	recode exerany (1 = 0) (2 = 1)
	recode addepev2 (1 = 1) (2 = 0)
	recode diabete3 (1 = 2) (3 = 0) (4 = 1)
	recode rmvteth3 (8 = 0)
	recode sex (2 = 0)
	recode veteran3 (2 = 0)
	recode smoke100 (2 = 0)

**# Checking Distributions ####################################################
* only keep my new variables
keep id _bmi5_new addepev2 diabete3 rmvteth3 income_cat smoke100 marital_cat educa_cat exerany2 numadult hlthpln1 sleptim1 sex veteran3 employ_cat alc_month

graph box _bmi5_new
	* no biologically impossible outliers (all <70 kg/m^2) *
	
foreach var of varlist _all {
    histogram `var', name("`var'", replace) title("Distribution of `var'")
}
	* Create Histograms for each variable to check distribution *
	
**# Preliminary Analysis #######################################################
* oberservation frequencies per variable *
codebook

*Check Variance, Skewness, and Kurtosis of Each Variable*
	sum numadult, detail
	sum addepev2, detail
	sum alc_month, detail
	sum diabete3, detail
	sum exerany2, detail
	sum hlthpln1, detail
	sum rmvteth3, detail
	sum sex, detail
	sum sleptim1, detail
	sum smoke100, detail
	sum veteran3, detail
	sum _bmi5_new, detail
	sum income_cat, detail
	sum educa_cat, detail
	sum employ_cat, detail
	sum marital_cat, detail

* Frequency Tables of Categorical Variables
	tab sex
	tab smoke100
	tab veteran3
	tab rmvteth3
	tab diabete3
	tab addepev2
	tab exerany2
	tab hlthpln1
	tab income_cat
	tab educa_cat
	tab employ_cat
	tab marital_cat

**# Bivariate Analysis #############################################*
* Bivariate Regression *
	reg _bmi5_new i.sex
	reg _bmi5_new i.veteran3
	reg _bmi5_new i.smoke100
	reg _bmi5_new sleptim1
	reg _bmi5_new i.rmvteth3
	reg _bmi5_new numadult
	reg _bmi5_new i.marital_cat
	reg _bmi5_new i.income_cat
	reg _bmi5_new i.hlthpln1
	reg _bmi5_new i.exerany2
	reg _bmi5_new i.employ_cat
	reg _bmi5_new i.educa_cat
	reg _bmi5_new i.diabete3
	reg _bmi5_new alc_month
	reg _bmi5_new i.addepev2

* Box Plots for Categorical Variables *
	graph box _bmi5_new, over(sex) title("BMI by Sex")
	graph box _bmi5_new, over(veteran3) title("BMI by Veteran Status")
	graph box _bmi5_new, over(smoke100) title("BMI by 100+ Cigarettes Smoked")
	graph box _bmi5_new, over(rmvteth3) title("BMI by Teeth Removed")
	graph box _bmi5_new, over(marital_cat) title("BMI by Marital Status")
	graph box _bmi5_new, over(income_cat) title("BMI by Income Category")
	graph box _bmi5_new, over(hlthpln1) title("BMI by Health Coverage")
	graph box _bmi5_new, over(exerany2) title("BMI by Exercise in Past 30 Days")
	graph box _bmi5_new, over(employ_cat) title("BMI by Employment Category")
	graph box _bmi5_new, over(educa_cat) title("BMI by Education Category")
	graph box _bmi5_new, over(diabete3) title("BMI by Diabetes Status")
	graph box _bmi5_new, over(addepev2) title("BMI by Depression Status")

* Scatter Plot for Continuous Variables*
twoway (scatter _bmi5_new numadult) || lfit _bmi5_new numadult || lowess _bmi5_new numadult
twoway (scatter _bmi5_new alc_month) || lfit _bmi5_new alc_month || lowess _bmi5_new alc_month
twoway (scatter _bmi5_new sleptim1) || lfit _bmi5_new sleptim1 || lowess _bmi5_new sleptim1

**# Model Building###############################################
*best subset does not work well in this instance with so many predictors, we dont have computing capacity

* stepwise with pe(0.05) and pr(0.15) to build preliminary model
sw, pe(0.05) pr(0.15): regress _bmi5_new i.addepev2 c.alc_month i.diabete3 i.educa_cat i.employ_cat i.exerany2 i.hlthpln1 i.income_cat i.marital_cat c.numadult i.rmvteth3 i.sex c.sleptim1 i.smoke100 i.veteran3

* preliminary model
regress _bmi5_new i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex 

* multicollinearity checking
vif

* assessing interaction terms:
sw, pe(0.05) pr(0.10) lockterm1: regress _bmi5_new (i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex) i.addepev2#c.alc_month i.addepev2#i.diabete3 i.addepev2#i.smoke100 i.addepev2#i.employ_cat i.addepev2#i.exerany2 i.addepev2#i.sex c.alc_month#i.diabete3 c.alc_month#i.smoke100 c.alc_month#i.employ_cat c.alc_month#i.exerany2 c.alc_month#i.sex i.diabete3#i.smoke100 i.diabete3#i.employ_cat i.diabete3#i.exerany2 i.diabete3#i.sex i.smoke100#i.employ_cat i.smoke100#i.exerany2 i.smoke100#i.sex i.employ_cat#i.exerany2 i.employ_cat#i.sex i.exerany2#i.sex

* final model regression statement
regress _bmi5_new i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2

**# Model Checking and Transformations ##########################################
* Linearity------------------------------------------------------
cprplot alc_month, rlopts(clpat(solid)) lsopts(bw(0.5) clpat(longdash))
	* perfect, no need to fix

* Normality------------------------------------------------------
	* create graph program "eda"
	capture program drop eda
	program define eda
	set graphics off
	set scheme s1mono
	quietly histogram `1', name(eda1, replace)
	quietly graph box `1', name(eda2, replace)
	quietly kdensity `1', ep normal name(eda3, replace)
	quietly qnorm `1', name(eda4, replace)
	set graphics on
	set scheme s1mono
	graph combine eda1 eda2 eda3 eda4
	end
* Checking residual plots after fitting a multiple linear regression
quietly regress _bmi5_new i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2
predict resid, resid
predict fitted, xb
eda resid
	* kind of off from normal distribution
	sum resid, detail
	* skewness and kurtosis are not ideal
	
	*Log Transformation of Outcome
	gen log_bmi = .
	replace log_bmi = ln(_bmi5_new)

* check again
quietly regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2
predict logresid, resid
eda logresid
	*looks much better than before
	sum logresid, detail
	* skewness and kurtosis are much improved

* Homoscedasticity-------------------------------------------
* create fitted values of log transformed model 
quietly regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2
predict lfitted, xb

* Check Categorical Variance (Original vs LOG)
	tab sex, sum(resid)
	tab sex, sum(logresid)
	tab addepev2, sum(resid)
	tab addepev2, sum(logresid)
	tab diabete3, sum(resid)
	tab diabete3, sum(logresid)
	tab smoke100, sum(resid)
	tab smoke100, sum(logresid)
	tab employ_cat, sum(resid)
	tab employ_cat, sum(logresid)
	tab exerany2, sum(resid)
	tab exerany2, sum(logresid)

* Check Continuous Variance (Original vs Log)
twoway (scatter resid fitted) (lowess resid fitted), yline(0) title("Residuals vs Fitted with Lowess - Original Model")
twoway (scatter logresid lfitted) (lowess logresid lfitted), yline(0) title("Residuals vs Fitted with Lowess - Log Transformed Model")

* Outliers / Influential Points / Leverage Points -------------------------------
* check outlying residuals by ID
twoway (scatter logresid id, sort mcolor(green) mlabel(id) mlabcolor(green)), title("Residuals by ID")

list if id == 2095
list if id == 1226
	* only thing weird about these is how high their BMI's are
	* BMI must be influenced by external, unmeasured factors

**# Final Model After Checking ###############################################
regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2
	*used excel to quickly exponentiate values
	
**# Unused Code ###############################################################

* create dfbeta values and investigate outliers on boxplot
quietly regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2
dfbeta
graph box _dfbeta_1 _dfbeta_2 _dfbeta_3 _dfbeta_4 _dfbeta_5 _dfbeta_6 _dfbeta_7 _dfbeta_8 _dfbeta_9 _dfbeta_10 _dfbeta_11 _dfbeta_12 _dfbeta_13 _dfbeta_14 _dfbeta_15 _dfbeta_16

* create cutoff point and flag value checkers
	gen cutoff = 2/sqrt(525)
	gen n_flags = 0
	foreach var of varlist _dfbeta_* {
		replace n_flags = n_flags + (abs(`var') > cutoff)
	}
* list flags
	sort n_flags
	tab n_flags
	
* sensitiity anavlysis of dropping values if flags = 5+

	* regress original
	regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2

	* check for changes in regression
	 regress log_bmi i.addepev2 c.alc_month i.diabete3 i.smoke100 i.employ_cat i.exerany2 i.sex i.smoke100##i.exerany2 i.diabete3##i.smoke100 i.diabete3##i.sex i.addepev2##i.smoke100 i.diabete3##i.exerany2 if n_flags < 5