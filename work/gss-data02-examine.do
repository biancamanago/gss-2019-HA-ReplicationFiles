capture log close

log using "gss-data02-examine", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-data02-examine.do
 local dte   2019-04-12
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
**********
/// Import Data
**********
 
 use "_data/gss-data01-label", clear
 
***************************************
* Missing Data
***************************************

local out "mentlillR imbalnceR geneticsR neurob"
local out "`out' upsdownsR charactrR wayraiseR"
local out "`out' meddocR mentldocR mentlhosR rxmedR"
local out "`out' vigworkR vigneiR vigsocR vigfrndR vigmarR"
local out "`out' hurtself hurtoth dectreat decmoney mustmedR mustdocR musthospR"
local controls "female white ed_gths"

/*
local att      "neurob mentlillR stressesR wayraiseR charactrR"
local percept  "seriousp imprvtrtR imprvownR hurtselfR hurtothR" */

* drop if vigver==5	

recode vigver (1=3 " - Alcoholism")     ///
              (2=2 " - Depression")     ///
			  (4=1 " - Daily Troubles") ///
			  (3=4 " - Schizophrenia") ///
			  (5=5 " - Drug Problems"), gen(vigver2)

mark nomiss
markout nomiss `out' `controls' `att' `percept'
drop if nomiss==0


save "_data/gss-data02-examine", replace
log close
exit
