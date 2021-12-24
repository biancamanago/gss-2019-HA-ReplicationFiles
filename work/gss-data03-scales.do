capture log close

log using "gss-data03-scales", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-data03-scales
 local dte   2019-04-30
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 use "_data/gss-data02-examine.dta", clear 

***************************************
* STEP 1: Descriptive analyses        *
***************************************
	gen black = .
	replace black=1 if race==2
	replace black=0 if race!=2 & race!=.
	la def black 1 "black" 0 "white/other"
	la val black black
	fre black
	
		
fre hurtself hurtoth
fre dectreat decmoney
fre mustmedR mustdocR musthospR

gen age65 = 1 if age>=65
replace age65=0 if age<65
la def age65 1 "Adults 65 and older" 0 "Under 65"
la val age65 age65

**********
/// Coercion
**********
gen coercion=mustmedR+mustdocR+musthospR 
gen coercionR = .
replace coercionR=1 if coercion!=0
replace coercionR=0 if coercion==0

*label define coercion 0 "no coercion" 1 "coercion"
label val coercionR coercion

tab coercionR coercion, m

**********
/// Hurt
**********
bysort vigver: pwcorr hurtself hurtoth
gen hurt_x = hurtself + hurtoth if hurtselfR!=. & hurtselfR!=.

gen hurt = hurtselfR + hurtothR if hurtselfR!=. & hurtselfR!=.
fre hurt
*revrs hurt, replace

gen hurtR = .
replace hurtR=1 if hurt!=0
replace hurtR=0 if hurt==0
fre hurtR

**********
/// Competence
**********
bysort vigver: pwcorr dectreat decmoney
gen incompetence_x = dectreatR + decmoneyR if dectreatR!=. & decmoneyR!=.

gen incompetenceR = .
replace incompetenceR=0 if incompetence_x==2
replace incompetenceR=1 if incompetence_x<2
fre incompetenceR

label define incomp 0 "Competent" 1 "Incompetent"
label val incompetenceR incomp
fre incompetenceR

gen competence = dectreat + decmoney if dectreat!=. & decmoney!=.
revrs competence, replace
hist competence

gen competence_x = dectreatR + decmoneyR if dectreatR!=. & decmoneyR!=.
gen competenceR = .
replace competenceR=1 if competence_x==2
replace competenceR=0 if competence_x<2
fre competenceR

label define compR 1 "Competent" 0 "Incompetent"
label val competenceR compR
fre competenceR


tab competence incompetenceR, m

****************************************************************
// 
****************************************************************
 alpha vigsoc vignei vigfrnd vigwork viggrp vigmar, gen(socdist)

 gen viglabelR = .
 replace viglabelR=0 if viglabel==1 | viglabel==2
 replace viglabelR=1 if viglabel==3 | viglabel==4
 
****************************************************************
// 
// 
**************************************************************** 

save "_data/gss-data03-scales", replace

log close
exit


