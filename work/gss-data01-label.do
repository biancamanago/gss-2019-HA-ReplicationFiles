capture log close

log using "gss-data01-label", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-data02-examine.do
 local dte   2019-04-12
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 

 
***************************************
* Load
***************************************

 use "_data/gss-data00-import", clear

****************************************************************
// Label Variables
**************************************************************** 

label var ed_gths "Earned greater than a high school degree? (1=yes)"
label var vigver  "Vignette Condition"

local out "mentlillR imbalnceR geneticsR neurob"
local out "`out' upsdownsR charactrR wayraiseR"
local out "`out' meddocR mentldocR mentlhosR rxmedR"
local out "`out' vigworkR vigneiR vigsocR vigfrndR vigmarR"
local out "`out' hurtselfR hurtothR"

foreach v in `out' {
	fre `v'
	}

label var mentlillR "...experiencing mental illness"
label var imbalnceR "...situation caused by imbalance in brain"
label var geneticsR "...situation caused by genetic problem"
label var upsdownsR "...experiencing normal ups and downs"
label var neurob    "...likely situation has neurobiological cause (chemical imbalance or genetics)"
label var charactrR "...likely situation is caused by bad behavior"
label var wayraiseR "...likely situation is caused by way raised"
label var mustmedR  "...should be forced to take prescribed medication by law"
label var musthospR "...should be admitted to be hospitalized for treatment by law"
label var mustdocR  "...should be forced to be examined at a clinic by law"
label var meddocR   "...should be forced to be examined at a clinic by law"
label var mentldocR "...should be forced to be examined at a clinic by law"
label var mentlhosR "...should be forced to be examined at a clinic by law"
label var rxmedR    "...should be forced to be examined at a clinic by law"
label var vigworkR  "...willing to work closely with x on a job?"
label var vigneiR   "...willing to have x as a neighbor?"
label var vigsocR   "...willing to spend time socializing with x?"
label var vigfrndR  "...willing to make friends with x?"
label var vigmarR   "...willing to have x marry into family?"
label var hurtselfR "...likely that x will hurt self?"
label var hurtothR  "...likely that x will hurt others?"


la def coercion 0 "no coercion" 1 "coercion"
la val mustmedR  coercion
la val musthospR coercion
la val mustdocR  coercion


 revrs seriousp, replace
 revrs viglabel, replace
 
 
la var hurtselfR "Probability of Hurting Self"
la var hurtothR  "Probability of Hurting Others"
la var dectreatR "Ability to Make Own Treatment Decisions"
la var decmoneyR "Ability to Make Own Financial Decisions"
la var mustmedR  "Agreement with Legal Enforcement of Medication Regimine"
la var mustdocR  "Agreement with Legal Enforcement of Doctors Visits"
la var musthospR "Agreement with Legal Enforcement of Hospitalization"

local controls "i.female i.black i.ed_gths c.age"
local att      "i.neurob i.mentlillR i.stressesR i.wayraiseR i.charactrR"
local percept  "c.seriousp i.competenceR i.hurtselfR i.hurtothR"

la def female 1 " - Female"
la val female female
fre female


la def ed_gths 1 " - Greater than High School Education"
la val ed_gths ed_gths
fre ed_gths 

la var age " - Age"
la var seriousp " - Perceived Severity"

la def neurob 1 " - Neurobiological cause"
la val neurob neurob
fre neurob

la def mentlillR 1 " - Mental illness"
la val mentlillR mentlillR
fre mentlillR

la def stressesR 1 " - Caused by stress"
la val stressesR stressesR
fre stressesR

la def wayraiseR 1 " - Way x was raised"
la val wayraiseR wayraiseR
fre wayraiseR

la def charactrR 1 " - Bad character"
la val charactrR charactrR
fre charactrR

la def hurtselfR 1 " - Likely to hurt self"
la val hurtselfR hurtselfR
fre hurtselfR

la def hurtothR 1 " - Likely to hurt others"
la val hurtothR hurtothR
fre hurtothR

la def year 0 " - 1996" 1 " - 2006" 2 " - 2018"
la val year year
fre year

la def decmoneyR 1 " - Financial Decisions"
la val decmoneyR decmoneyR

la def dectreatR 1 " - Treatment Decisions"
la val dectreatR dectreatR


****************************************************************
//  #: Exit
****************************************************************

save "_data/gss-data01-label", replace
log close
exit
