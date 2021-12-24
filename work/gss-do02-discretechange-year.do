capture log close

log using "gss-do02-discretechange-year", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-do02-discretechange-year
 local dte   2019-08-10
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 use "_data/gss-data03-scales.dta", clear 

***************************************
* STEP 1: Analyses        *
***************************************

//label define year alcohol "alcohol dependence" depression "depression" schizophrenia "schizophrenia"
//label val year year

recode year (2=0 "2018") (0=1 "1996") (1=2 "2006"), gen(year1)

svyset [pw=wtssall]
	
** Hurt Others
** Coefficient Plot	
	
local depvars "hurtothR hurtselfR" 	

foreach dv in `depvars' {	
** Support doccion
** Coefficient Plot	
svyset [pw=wtssall]
local controls "i.female i.black i.ed_gths c.age"
local vig      "i.vigmale i.vigrace i.viged"
local att      "i.mentlillR i.neurob i.stressesR i.wayraiseR i.charactrR"
local percept  "c.seriousp i.dectreatR i.decmoneyR"

	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==1"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'dt1: margins, at(vigver2=1) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==2"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'dep1: margins, at(vigver2=2) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==3"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'alc1: margins, at(vigver2=3) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==4"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'schiz1: margins, at(vigver2=4) dydx(year) post
	}

local depvars "mustmedR mustdocR musthospR" 	

foreach dv in `depvars' {	
** Support doccion
** Coefficient Plot	
svyset [pw=wtssall]
local controls "i.female i.black i.ed_gths c.age"
local vig      "i.vigmale i.vigrace i.viged"
local att      "i.mentlillR i.neurob i.stressesR i.wayraiseR i.charactrR"
local percept  "c.seriousp i.dectreatR i.decmoneyR i.hurtothR i.hurtselfR"

	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==1"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'dt1: margins, at(vigver2=1) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==2"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'dep1: margins, at(vigver2=2) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==3"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'alc1: margins, at(vigver2=3) dydx(year) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==4"
	qui svy: logit `dv' i.year i.vigver2 `controls' `vig' `att' `percept' i.year#i.vigver2, or
	eststo `dv'schiz1: margins, at(vigver2=4) dydx(year) post
	}
	
	coefplot(hurtothRdt1, label("daily troubles") mc(midgreen))              ///
			(hurtothRdep1, label("depression") mc(blue))                     ///
			(hurtothRalc1, label("alcohol dependence") mc(gs0) msym(d))      ///
			(hurtothRschiz1, label("schizophrenia") mc(cranberry))           ///
			, bylabel("A: Likely to Hurt Others")                               ///
			|| (hurtselfRdt1, label("daily troubles") mc(midgreen))          ///
			(hurtselfRdep1, label("depression") mc(blue))                  	 ///
			(hurtselfRalc1, label("alcohol dependence") mc(gs0) msym(d))     ///
			(hurtselfRschiz1, label("schizophrenia") mc(cranberry))        	 ///
			, bylabel("B: Likely to Hurt Self") 								 ///
			|| (mustmedRdt1, label("daily troubles") mc(midgreen))           ///
	        (mustmedRdep1, label("depression") mc(blue))                     ///
	        (mustmedRalc1, label("alcohol dependence") mc(gs0) msym(d))      ///
			(mustmedRschiz1, label("schizophrenia") mc(cranberry))           ///
			, bylabel("C: Coercion to take Medication")						 ///	
			||  (mustdocRdt1, label("daily troubles") mc(midgreen))          ///
			(mustdocRdep1, label("depression") mc(blue))                     ///
	        (mustdocRalc1, label("alcohol dependence") mc(gs0) msym(d))      ///
			(mustdocRschiz1, label("schizophrenia") mc(cranberry))           ///
			, bylabel("D: Coercion to see MD")                                  ///	
			|| (musthospRdt1, label("daily troubles") mc(midgreen))          ///
			(musthospRdep1, label("depression") mc(blue))                    ///
	        (musthospRalc1, label("alcohol dependence") mc(gs0) msym(d))     ///
			(musthospRschiz1, label("schizophrenia") mc(cranberry))          ///
			, bylabel("E: Coercion to be Hospitalized")                         ///
			|| , drop(1.female 1.black 1.ed_gths age 1.vigmale               ///
			 1.vigrace 2.vigrace 1.viged 2.viged 1.neurob 1.mentlillR        ///
			 1.vigver2 2.vigver2 3.vigver2 4.vigver2                         ///
			 1.stressesR 1.wayraiseR 1.charactrR seriousp                    ///
			 1.dectreatR 1.decmoneyR)  horizontal xline(0) recast(scatter)   ///
			 xline(0) xlab(-.5(.1).5) ciop(col(gs12)) ysize(14) xsize(9)     ///
			 legend(order(2 4 6 8) row(1) margin(none))                          ///
			 subtitle(, size(medsmall) margin(tiny) justification(left)      ///
             color(white) bcolor(black))                                     ///
			 byopts(compact cols(1)) ///
			 name(a32)                               
			 

	graph combine a32, xsize(15) ysize(20) imargin(tiny) ///
	 title("Exhibit 2. Marginal effects of mental disorders on perceived potential" ///
	       "for violence and endorsement of coerced treatment," ///
		   "2006 and 2018 vs. 1996", size(medsmall)) ///
	 note("NOTE: Adjusted average marginal effect in predicted probability of dependent variable in the years listed"  ///
	      "on the side compared to omitted year. Positive values indicate an outcome was more likely for each" ///
		  "year compared to omitted, negative values indicate the reverse. Lines indicate 95% confidence interval" ///
		  "around the average marginal effect. Values are derived from logistic regression in Appendix Exhibit A3," ///
		  "available online." ///
		  "SOURCE: Authors’ analysis of data from the National Stigma Studies, 1996, 2006, and 2018.", size(vsmall) ///
		  justification(left))
	

graph export "-graphs/gss-do02-Exhibit2-note.tif", replace
 
			 

**********
///
**********
	
local depvars "hurtothR hurtselfR" 	

foreach dv in `depvars' {	
** Support doccion
** Coefficient Plot	
svyset [pw=wtssall]
local controls "i.female i.black i.ed_gths c.age"
local vig      "i.vigmale i.vigrace i.viged"
local att      "i.mentlillR i.neurob i.stressesR i.wayraiseR i.charactrR"
local percept  "c.seriousp i.dectreatR i.decmoneyR"

	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==1"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'dt2: margins, at(vigver2=1) dydx(year1) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==2"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'dep2: margins, at(vigver2=2) dydx(year1) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==3"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'alc2: margins, at(vigver2=3) dydx(year1) post
	
	di in red "logit `dv' i.year `controls' `att' `percept' if vigver2==4"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'schiz2: margins, at(vigver2=4) dydx(year1) post
	}		
	
local depvars "mustmedR mustdocR musthospR dangrothR dangrslfR" 	

foreach dv in `depvars' {	
** Support doccion
** Coefficient Plot	
svyset [pw=wtssall]
local controls "i.female i.black i.ed_gths c.age"
local vig      "i.vigmale i.vigrace i.viged"
local att      "i.mentlillR i.neurob i.stressesR i.wayraiseR i.charactrR"
local percept  "c.seriousp i.dectreatR i.decmoneyR i.hurtothR i.hurtselfR"

	di in red "logit `dv' i.year1 `controls' `att' `percept' if vigver2==1"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'dt2: margins, at(vigver2=1) dydx(year1) post
	
	di in red "logit `dv' i.year1 `controls' `att' `percept' if vigver2==2"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'dep2: margins, at(vigver2=2) dydx(year1) post
	
	di in red "logit `dv' i.year1 `controls' `att' `percept' if vigver2==3"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'alc2: margins, at(vigver2=3) dydx(year1) post
	
	di in red "logit `dv' i.year1 `controls' `att' `percept' if vigver2==4"
	svy: logit `dv' i.year1 i.vigver2 `controls' `vig' `att' `percept' i.year1#i.vigver2, or
	eststo `dv'schiz2: margins, at(vigver2=4) dydx(year1) post
	}
	
	
	coefplot(hurtothRdt2, label("daily troubles") mc(midgreen))              ///
			(hurtothRdep2, label("depression") mc(blue))                     ///
			(hurtothRalc2, label("alcohol dependence") mc(gs0) msym(d))      ///
			(hurtothRschiz2, label("schizophrenia") mc(cranberry))           ///
			, bylabel("A: Likely to Hurt Others")                               ///
			|| (hurtselfRdt2, label("daily troubles") mc(midgreen))          ///
			(hurtselfRdep2, label("depression") mc(blue))                  	 ///
			(hurtselfRalc2, label("alcohol dependence") mc(gs0) msym(d))     ///
			(hurtselfRschiz2, label("schizophrenia") mc(cranberry))        	 ///
			, bylabel("B: Likely to Hurt Self") 								 ///
		    || (mustmedRdt2, label("daily troubles") mc(midgreen))           ///
	        (mustmedRdep2, label("depression") mc(blue))                     ///
	        (mustmedRalc2, label("alcohol dependence") mc(gs0) msym(d))      ///
			(mustmedRschiz2, label("schizophrenia") mc(cranberry))           ///
			, bylabel("C: Coercion to take Medication")                         ///	
			||  (mustdocRdt2, label("daily troubles") mc(midgreen))          ///
			(mustdocRdep2, label("depression") mc(blue))                     ///
	        (mustdocRalc2, label("alcohol dependence") mc(gs0) msym(d))      ///
			(mustdocRschiz2, label("schizophrenia") mc(cranberry))           ///
			, bylabel("D: Coercion to see MD")                                  ///	
			|| (musthospRdt2, label("daily troubles") mc(midgreen))          ///
			(musthospRdep2, label("depression") mc(blue))                    ///
	        (musthospRalc2, label("alcohol dependence") mc(gs0) msym(d))     ///
			(musthospRschiz2, label("schizophrenia") mc(cranberry))          ///
			, bylabel("E: Coercion to be Hospitalized")                         ///		 				
			|| , drop(1.female 1.black 1.ed_gths age 1.vigmale               ///
			 1.vigrace 2.vigrace 1.viged 2.viged 1.neurob 1.mentlillR        ///
			 1.vigver2 2.vigver2 3.vigver2 4.vigver2                         ///
			 1.stressesR 1.wayraiseR 1.charactrR seriousp                    ///
			 1.dectreatR 1.decmoneyR)      horizontal xline(0) recast(scatter)   ///
			 xline(0) xlab(-.5(.1).5) ciop(col(gs12)) ysize(14) xsize(9)     ///
			 legend(order(6 8) row(1) margin(none))                          ///
			 subtitle(, size(medsmall) margin(tiny) justification(left)      ///
             color(white) bcolor(black))                                     ///
			 byopts(compact cols(1) title("AMEs 1996 and 2006 vs 2018", size(medsmall))) ///
			 name(b4)                         
			                               
			 
	
	
	graph combine a5 b4, xsize(20) ysize(20) imargin(tiny) ///
	         title("Appendix Exhibit A5. Marginal effects of mental disorders on perceived potential" ///
			       "for violence and endorsement of coerced treatment, 1996, 2006, and 2018", size(small)) ///
		     note("NOTE: Adjusted average marginal effect in predicted probability of dependent variable in the years listed"  ///
			      "on the side compared to omitted year. Positive values indicate an outcome was more likely for each" ///
				  "year compared to omitted, negative values indicate the reverse. Lines indicate 95% confidence interval" ///
				  "around the average marginal effect. Values are derived from logistic regression in Appendix Exhibit A3," ///
				  "available online." ///
				  " " ///
				  "SOURCE: Authors’ analysis of data from the National Stigma Studies, 1996, 2006, and 2018.", size(vsmall) justification(left))
	
	

	graph export "-graphs/gss-do02-Appendix-note.tif", replace



****************************************************************
// 
**************************************************************** 


log close 
exit	


	
