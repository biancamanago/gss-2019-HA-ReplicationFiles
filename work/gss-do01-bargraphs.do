capture log close

log using "gss-do01-bargraphs", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-do03-analyses
 local dte   2019-04-12
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 use "_data/gss-data03-scales.dta", clear 
 
***************************************
* STEP 1: Descriptive analyses        *
***************************************

	label variable year   "Year of GSS"
	label variable vigver "Mental Illness"
	
set scheme cleanplots	
graph set window fontface avenir
		
	graph bar (mean) hurtselfR hurtothR incompetenceR coercionR if vigver2!=5, ///
	      over(year) over(vigver) bargap(-30)  ///
		  ytitle("Predicted Probability") ///
		  title("Predicted Probabilities by Year and Mental Illness") ///
		  legend( label(1 "Likely to Hurt Self") ///
		          label(2 "Likely to Hurt Others") ///
				  label(3 "Perceived Competence") ///
				  label(4 "Support for Coercion") row(2) pos(6)) 
		
		graph export "-graphs/gss-do01-bargraph.tif", replace 


		log close
		exit
