capture log close

log using "gss-data00-import", replace text
 
 version 15.1
 set linesize 80
 clear all
 macro drop _all

 
 local pgm   gss-data00-import.do
 local dte   2019-04-12
 local who   bianca manago 
 local tag   "`pgm'.do `who' `dte'"
 
 di "`tag'"
 
 global      data "_data/1972-2018 Cumulative-Downloaded-from-NORC-2019-03-20"
 
***************************************
* STEP 1: Select variables and sample *
***************************************

local vars "year id ballot version form issp formwt cohort sampcode sample"
local vars "`vars' oversamp phase wtss wtssnr wtssall vstrat vpsu"
local vars "`vars' sex age race educ degree"
local vars "`vars' seriousp charactr imbalnce wayraise stresses genetics godswill"
local vars "`vars' upsdowns breakdwn mentlill physill viglabel"
local vars "`vars' vignei vigsoc vigfrnd vigwork viggrp vigmar"
local vars "`vars' hurtoth hurtself meddoc mentldoc mentloth imprvown imprvtrt "
local vars "`vars' selfhelp otcmed rxmed mentlhos ortlkfm ortlkclr ormeddoc"
local vars "`vars' mustdoc mustmed musthosp dangrslf dangroth medcare1 medcare2"
local vars "`vars' vigversn dectreat decmoney diagnosd mhdiagno"
local contact "evmhp mhdiagno diagnosd mhtreatd"
local contact "`contact' knwmhosp knwpatnt"
local vars    "`vars' `contact'"

** disabld5 mhtrtot2 mhtrtslf 

local year "year == 1996 | year == 2006 | year == 2018"

// Read in select vars

use `vars' if `year' using "$data/GSS7218_R1", clear


// Keep Rs who received the mental health module
// In 2018, the module was included on Ballot B (form Y only) and Ballot C 
// (both forms)


keep if (year == 1996 & version<=6 & version >= 4) | ///
        (year == 2006 & version<=3 & version >= 1) | ///
		(year == 2018 & version==3) | (year == 2018 & ballot==2 & form == 2 ) 
		
***************************************
* STEP 2: Replicate 2006 AJP recodes  *
***************************************

// Recode vignettes (first individually by year, and then across years)
	
g vigver96 = vigversn if year == 1996
recode vigver96 (1/18=1) (19/36=2) (37/54=3) (73/90=4) (55/72=5)
	la var vigver96 "Vignette? (1996)"
	la de vigver96 1 "Alcohol" 2 "Depression" ///
		3 "Schizophrenia" 4 "Daily Troubles" 5 "Drug Problem" `miss'
	la val vigver96 vigver96
ta vigver96 , m

g vigver06 = vigversn if year == 2006
recode vigver06 (1/18=1) (19/36=2) (37/54=3) (73/90=4) (55/72=.)
	la var vigver06 "Vignette? (2006)"
	la de vigver06 1 "Alcohol" 2 "Depression" ///
		3 "Schizophrenia" 4 "Daily Troubles" `miss'
	la val vigver06 vigver06
ta vigver06 , m

g vigver18 = vigversn if year == 2018
recode vigver18 (1/18=1) (19/36=2) (37/54=3) (73/90=4) (55/72=5)
	la var vigver18 "Vignette? (2018)"
	la de vigver18 1 "Alcohol" 2 "Depression" ///
		3 "Schizophrenia" 4 "Daily Troubles" 5 "Drug Problem" `miss'
	la value vigver18 vigver18
ta vigver18 , m

g vigver = .
replace vigver = vigver96 if year == 1996
replace vigver = vigver06 if year == 2006
replace vigver = vigver18 if year == 2018
	la val vigver vigver18
	la var vigver "Vignette? (96, 06, 18)"
	
recode year (1996=0 "1996") (2006=1 "2006") (2018=2 "2018"), gen(year1)
drop year
rename year1 year	

label var year "Year of GSS"

recode vigversn (1/9 19/27 37/45 55/63 73/81=1   " - Male") ///
                (10/18 28/36 46/54 64/72 82/90=0 " - Female"), gen(vigmale)
				
	label var vigmale "Vignette is Male"				
				
recode 	vigversn (1 4 7 10 13 16 19 22 25 28 31 34 37 40 ///
                  43 46 49 52 55 58 61 64 67 70 73 76 79 ///
				  82 85 88=0 " - White") ///
                 (2 5 8 11 14 17 20 23 26 29 32 35 38 41 ///
				 44 47 50 53 56 59 62 65 68 71 74 77 80  ///
				 83 86 89=1 " - Black") ///	
				 (3 6 9 12 15 18 21 24 27 30 33 36 39 42 ///
				 45 48 51 54 57 60 63 66 69 72 75 78 81  ///
				 84 87 90=2 " - Hispanic"), gen(vigrace)
				 
	label var vigrace "Vignette Race (white omit)"
	
recode vigversn (1/3 10/12 19/21 28/30 37/39 46/48 55/57 ///
                64/66 73/75 82/84=0 " - Less than H.S.")	 ///
                (4/6 13/15 22/24 31/33 40/42 49/51 58/60 ///
				67/69 76/78 85/87=1 " - High School")       ///
				(7/9 16/18 25/27 34/36 43/45 52/54 61/63 ///
				70/72 79/81 88/90=2 " - College"), gen(viged)
	
	label var viged "Vignette Education (Less than H.S. omit)"

// Recode VIGNETTES into dummies

ta vigver , gen(vig)
la define yesno 0 "0=no" 1 "1=yes" `miss'
rename vig1 vigalc
la var vigalc "Alcohol"
rename vig2 vigdep
la var vigdep "Depression"
rename vig3 vigschiz
la var vigschiz "Schizophrenia"
rename vig4 vignorm
la var vignorm "Daily Troubles"
rename vig5 vigdrug
la var vigdrug "Drug Problem"

unab vars: vigalc-vigdrug
foreach v in `vars' {
    la value `v' yesno
    ta vigver `v' , m
}

// Recode ATTRIBUTIONS
// Very likely / somewhat likely = 1
// Not very likely / not at all likely / don't know = 0

unab vars:  upsdowns breakdwn mentlill physill imbalnce genetics ///
            stresses wayraise charactr godswill imprvown imprvtrt 
			
foreach v in `vars' {
    g `v'R = `v'
    recode `v'R (1/2=1) (3/4=0) (.d=0)
    la value `v'R likely
    local varlbl : variable label `v' 
    la variable `v'R "Bin: `varlbl'"  
    ta `v' `v'R , m
   } 
   
// Generate indicator of NEUROBIOLOGICAL CONCEPTION of mental illness
// As per the 2010 paper: "Coded 1 if the respondent labeled the problem 
// as mental illness and attributed cause to a chemical imbalance or a 
// genetic problem, coded 0 otherwise"
 
g neurob = 1 if mentlillR == 1 & (imbalnceR == 1 | geneticsR == 1)
replace neurob = 0 if mentlillR == 0 | (imbalnceR == 0 & geneticsR == 0)
	la var neurob "Neurobiological conception" 

// recode TREATMENT ENDORSEMENT 
// Yes = 1, no / don't know = 0

unab vars: meddoc mentldoc mentlhos rxmed mustdoc mustmed musthosp dangroth dangrslf
foreach v in `vars' {
	g `v'R = `v'
	recode `v'R (1=1) (2=0) (.d=0)
	}
	
// recode PUBLIC STIGMA
// Definitely unwilling/probably unwilling = 1, 
// definitely unwilling, don't know = 0

la de unwilling 1 "1=Unwilling" 0 "0=Willing" `miss'
unab vars: vignei vigsoc vigfrnd vigwork viggrp vigmar
foreach v in `vars' {
    g `v'R = `v'
    recode `v'R (1/2=0) (3/4=1) (.d=0)
    la val `v'R unwilling
    local varlbl : variable label `v' 
    la var `v'R "Bin: `varlbl'" 
    ta `v' `v'R , m
   }  

unab vars: hurtself hurtoth
foreach v in `vars' {
	g `v'R = `v'
	recode `v'R (1/2=1) (3/4=0) (.d=0)
	}
	
// recode CONTACT
local contact "evmhp mhdiagno diagnosd mhtreatd"
local contact "`contact' knwmhosp knwpatnt"

fre `contact'

foreach v in `contact' {
	di in red ". tab year `v', m"
	tab year `v', m
	}
	
// recode COMPETENCE

la de comp 1 "able" 0 "unable"

local vars "dectreat decmoney"
foreach v in `vars' {
    g `v'R = `v'
    recode `v'R (1/2=1) (3/4=0) (.d=0)
    la val `v'R comp
    local varlbl : variable label `v' 
    la var `v'R "Bin: `varlbl'" 
    ta `v' `v'R , m
   } 	

// Recode DEMOGRAPHICS

// Sex

g female = (sex==2) if sex < .
la var female "Female?"
la value female yesno
ta sex female , m
  
// Race

g white = (race == 1) if race < .
la var white "White?"
la val white yesno
ta race white, m
 
// Education 
// The piece in AJP is a bit vague on the coding (in one place it says
// "at least a high school degree" and in another it says "greater than
// a high school degree". The descriptives suggest the latter is correct.
  
g ed_gths = 1 if degree > 1 & degree <= 4 
replace ed_gths = 0 if degree <= 1 & degree >= 0


// The original paper DID NOT make adjustments for sample design, other
// than correcting for differential sampling probabilities. It's likely the 
// SEs are too small as a result.
	
svyset [pw=wtssall]

g y96 = year == 1996
g y06 = year == 2006
g y18 = year == 2018



****************************************************************
// 
// close out
**************************************************************** 
	save "_data/gss-data00-import.dta", replace
	log close
	exit
		
