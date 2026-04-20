# Multivariate-Regression-Using-BRFSS-2016

Research Motivation:

This code was developed as part of a Final Project for PHEB 603: Biostatistics II at Texas A&M University's School of Public Health. My group was prompted to use the provided data to build a clean multivariate linear regression model in STATA v. 19. We were given data from the 2016 Behavioral Risk Factor Surveillance Survey (BRFSS), subsetted to Alabama. My particular group was interested in building a model to predict BMI utilizing drinking frequency and other related comorbidities. I was tasked with wrangling the data to produce results that my group could then analyze. 

Primary Objective: 

Assess how the frequency of drinking alcohol predicts BMI in non-sober populations.

Secondary Objective: 

Examine how comorbidities related to drinking alcohol and their interactions predict BMI in non-sober populations.

Source Data:

2016 Alabama Behavioral Risk Factor Surveillance Survey

N=4,999
Inclusion Variables: ID, Sex, BMI, Number of Days had 1+ Alcoholic Drink in Past 30, Depression Status, Veteran Status, Smoked Over/Under 100 Cigarettes in Life, Education Level, Marital Status, Employment Status, Income Level, Health Coverage, Diabetes Status, Number of Teeth Removed, & Exercise in the Past 30 Days

Exclusion Criteria for Observations: Missing Values, "Don't Know" Responses, "Refused" Responses, and Diabetes history consisting of only Gestational Diabetes.

Limitations: All respondents were confirmed to be over 18 years old, but no continuous value for age was recorded. Having this variable to adjust for would have significantly impacted this regression model and potentially resolved the unmeasured variability (adj. R^2).

Variable Coding


Methods


