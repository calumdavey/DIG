* =============================================================================================== *
* =============================================================================================== *
* DIG First Endline analysis 																	  *
* OCT 2022 	 																	  				  *
* LSHTM + BIGD 																	  				  *
* =============================================================================================== *
* =============================================================================================== *
/*

	Title: 		<name>.do


 	Outline: 	This do-file cleans the Uganda DIG data section:
				- Label variables and values
				- Fix "other, specify", if applicable
				- Create variables
				- Logic checks and assertions

 	Input: 		<name>.dta

	Output:		<name>_<date>.dta


	Created by: Elijah Kipchumba on 10 Oct 2022
	Modified:	Elijah Kipchumba on 10 Oct 2022

*/

* =============================================================================================== *

	clear all
	clear matrix

	set maxvar 32000
	set matsize 11000

	set more off
	set varabbrev on

	* ssc install ***

* =============================================================================================== *
* [ Set path globals]
* =============================================================================================== *

* Set directory and filepaths 
if c(username)==			"Munshi" {
	cd 						"C:/Dropbox/DIG Uganda//DIG Panel/DIG Endline 1" /*Munshi's Folder*/
	}
	else if c(username)== 	"macbookair" {
	cd 						"/Users/macbookair/Dropbox/Brac Projects/DIG Uganda/DIG Panel/DIG Endline 1" //Elijah's Folder
	}
* Import data
use "Data/DIG Household Panel Wide.dta", clear

* =============================================================================================== *
* DEMOGRAPHIC VARIABLE CREATION
* =============================================================================================== *

* Respondent Characteristics 
* --------------------------

	* Keep required variables 
	keep s23_* s24_* s25_* s26_* s27_* s28_* s29_* s210_* s211_* s212_* s213_* s102_* s105_* hhmemindex_* bhhmemindex_* m_panel_* bmemname_* lino* hhid s215 follow
	* Drop empty and unneeded variables 
	foreach var of varlist _all {
		 capture assert mi(`var')
		 if !_rc { // checking that the variable exists
			drop `var'
		 }
	 }
	drop *_level_* *_check_* // dropping the check

	* Reshape the data so that each line is a separate person at either baseline or endline  
	reshape long s23_ s24_ s25_ s26_ s27_ s28_ s29_ s210_ s211_ s212_ s213_ s102_ s105_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_ lino, i(hhid follow) j(resp_lino)
	replace resp_lino=lino if follow==0 // Order was randomized after baseline, so recovering baseline order
	keep if s215==resp_lino //s215 is who is the respondent, as a line number 

	replace s213_=22 if s213_==18 //PhD. 
	replace s213_=18 if s213_==17 //Masters
	replace s213_=. if s213_==99 //Dont know

	* Create new resp_ var for all the vars, that are only populated if s215 = resp_lino 
	foreach var of varlist s23_ s24_ s25_ s26_ s27_ s28_ s29_ s210_ s211_ s212_ s213_ s102_ s105_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_  {
		gen resp_`var'=`var' if s215==resp_lino
		drop `var'
	}
	
	* Label the new resp_ variables 
	rename *_ *
	label var resp_s23  "Respondent is male or female?"
	label var resp_s24  "Respondent's age"
	label var resp_s25  "Respondent's dificulty seeing"
	label var resp_s26  "Respondent's difficulty hearing"
	label var resp_s27  "Respondent's difficulty walking"
	label var resp_s28  "Respondent's difficulty remembering"
	label var resp_s29  "Respondent's difficulty with self-care"
	label var resp_s210 "Respondent's difficulty communicating"
	label var resp_s211 "Respondent's marital status"
	label var resp_s212 "Respondent's is able to read and write"
	label var resp_s213 "Respondent's highest level of education"
	label var resp_s102 "Respondent experienced an illness/injury"
	label var resp_s105 "Respondent sought treatment"
	
	
	* Save this resp file as a temp file 
	tempfile rough
	save `rough'

* Household Head Characteristics -- same as above, but different line-number 
* ------------------------------
	use "Data/DIG Household Panel Wide.dta", clear
	keep s23_* s24_* s25_* s26_* s27_* s28_* s29_* s210_* s211_* s212_* s213_* s102_* s105_* hhmemindex_* bhhmemindex_* m_panel_* bmemname_* lino* hhid s214 follow
	* Drop empty and unneeded variables 
	foreach var of varlist _all {
		 capture assert mi(`var')
		 if !_rc {
			drop `var'
		 }
	 }

	drop *_level_* *_check_*

	reshape long s23_ s24_ s25_ s26_ s27_ s28_ s29_ s210_ s211_ s212_ s213_ s102_ s105_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_ lino, i(hhid follow) j(hhh_lino)
	replace hhh_lino=lino if follow==0 // Order was randomized after baseline, so am recovering baseline order
	keep if s214==hhh_lino

	replace s213_=22 if s213_==18 //PhD
	replace s213_=18 if s213_==17 //Masters
	replace s213_=. if s213_==99 //Dont know

	 foreach var of varlist s23_ s24_ s25_ s26_ s27_ s28_ s29_ s210_ s211_ s212_ s213_ s102_ s105_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_  {
	 gen hhh_`var'=`var' if s214==hhh_lino
	 drop `var'
	 }

	rename *_ *
	label var hhh_s23  "HH head is male or female?"
	label var hhh_s24  "HH head's age"
	label var hhh_s25  "HH head's dificulty seeing"
	label var hhh_s26  "HH head's difficulty hearing"
	label var hhh_s27  "HH head's difficulty walking"
	label var hhh_s28  "HH head's difficulty remembering"
	label var hhh_s29  "HH head's difficulty with self-care"
	label var hhh_s210 "HH head's difficulty communicating"
	label var hhh_s211 "HH head's marital status"
	label var hhh_s212 "HH head's is able to read and write"
	label var hhh_s213 "HH head's highest level of education"
	label var hhh_s102 "HH head experienced an illness/injury"
	label var hhh_s105 "HH head sought treatment"

	quietly merge 1:1 hhid follow using `rough', nogen
	tempfile rough
	save `rough'

* Index PWD Characteristics -- same as above, but different line-number 
* -------------------------
	use "Data/DIG Household Panel Wide.dta", clear
	keep s23_* s24_* s211_* s212_* s213_* s102_* s105_* s106_* hhmemindex_* bhhmemindex_* m_panel_* bmemname_* lino* hhid s216_index follow
	* Drop empty and unneeded variables 
	foreach var of varlist _all {
		 capture assert mi(`var')
		 if !_rc {
			drop `var'
		 }
	 }
	drop *_check_*

	reshape long s23_ s24_ s211_ s212_ s213_ s102_ s105_ s106_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_ lino, i(hhid follow) j(index_lino)
	replace index_lino=lino if follow==0 // Order was randomized after baseline, so am recovering baseline order
	keep if s216_index==index_lino & s216_index!=.

	replace s213_=22 if s213_==18 //PhD
	replace s213_=18 if s213_==17 //Masters
	replace s213_=. if s213_==99 //Dont know

	 foreach var of varlist s23_ s24_ s211_ s212_ s213_ s102_ s105_ s106_ hhmemindex_ bhhmemindex_ m_panel_ bmemname_  {
	 gen index_`var'=`var' if s216_index==index_lino
	 drop `var'
	 }

	rename *_ *
	label var index_s23  "Index PWD is male or female?"
	label var index_s24  "Index PWD's age"
	label var index_s211 "Index PWD's marital status"
	label var index_s212 "Index PWD's is able to read and write"
	label var index_s213 "Index PWD's highest level of education"
	label var index_s102 "Index PWD experienced an illness/injury"
	label var index_s105 "Index PWD sought treatment"
	label var index_s106 "Reason for index PWD not seeking treatment"

	quietly merge 1:1 hhid follow using `rough', nogen


	quietly merge 1:1 hhid follow using "Data/DIG Household Panel Wide.dta", nogen

	* For the Index person PWD: coding the Washington group extended set 
		gen index_diff_vision=(vision_combined==3 | vision_combined==4)
		gen index_diff_hearing=(hearing_combined==3 | hearing_combined==4)
		gen index_diff_walk=(walking_combined==3 | walking_combined==4)
		*gen index_diff_remember=(s2_18==3 | s2_18==4)  ----!> WHAT IS THIS?
		gen index_diff_selfcare=(s2_11==3 | s2_11==4)
		gen index_diff_communication=(s2_10==3 | s2_10==4)

		gen upper_body_combined=0
		replace upper_body_combined=4 if s2_12==4 | s2_13==4
		replace upper_body_combined=3 if upper_body_combined!=4 & (s2_12==3 | s2_13==3)
		replace upper_body_combined=2 if upper_body_combined!=4 & upper_body_combined!=3 & (s2_12==2 | s2_13==2)
		replace upper_body_combined=1 if upper_body_combined!=4 & upper_body_combined!=3 & upper_body_combined!=2 & (s2_12==1 | s2_13==1)
		gen index_diff_upper_body=(upper_body_combined==3 | upper_body_combined==4)

		gen anxiety_combined=0 if s2_14==. & s2_15==.
		replace anxiety_combined=1 if s2_14==4 | s2_14==5
		replace anxiety_combined=4 if s2_14==1 & s2_15==2
		replace anxiety_combined=3 if ((s2_14==1 & s2_15==3) | (s2_14==2 & s2_15==2))
		replace anxiety_combined=2 if anxiety_combined==.
		gen index_diff_anxiety=(anxiety_combined==4)

		gen depression_combined=0 if s2_16==. & s2_17==.
		replace depression_combined=1 if s2_16==4 | s2_16==5
		replace depression_combined=4 if s2_16==1 & s2_17==2
		replace depression_combined=3 if ((s2_16==1 & s2_17==3) | (s2_16==2 & s2_17==2))
		replace depression_combined=2 if depression_combined==.
		gen index_diff_depression=(depression_combined==4)

		drop indexpwd upper_body_combined anxiety_combined depression_combined
		egen indexpwd=anymatch(index_diff_*), values(1)

	* Other PWD in the household
		drop hhpwd
		destring noadultpwd noadultpwd_b, replace
		recode noadultpwd (0=0) (1/max=1), gen(hhpwd) // As reported by main female
		replace hhpwd=1 if indexpwd==1 // From self-report extended Washington Group

		egen hhsize=rownonmiss(s23*)
		replace tot_hhmem_num=hhsize if follow==0
		drop hhsize
		egen hhsize=rowtotal(curhhmem_*)
		replace tot_hhmem_num=hhsize if follow==1
		drop hhsize

* =============================================================================================== *
* OUTCOME VARIABLE CREATION
* =============================================================================================== *
		
* Primary outcome : Household Expenditure
* ---------------------------------------

* Food consumption coding:
	local i=1
		while `i'<=33{
		gen buy_s42e_`i'=0
		replace buy_s42e_`i' = s42e_`i' * s42c_`i' if s42a_`i' == 1
		local i=`i'+1
		}

	egen food_expenses = rowtotal(buy_s42e_*) // sum all of the food spending cols
	drop buy_s42e_* // drops all of the specific food spending vars
	label var food_expenses "Monthly food expenditure"

* Non-food recurrent and infrequent expenses
	egen recurrent_expenses    = rowtotal(s43_b_*) // sum the recurrent non-food expenses
	label var recurrent_expenses "Monthly non-food recurrent expenditure"

	egen infrequent_expenses = rowtotal(s44_b_*) // sum the infrequent non-food expenses, measured over the year 
	replace infrequent_expenses = infrequent_expenses / 12 // Monthly infrequent expenses
	label var infrequent_expenses "Annual infrequent expenditure"

	egen hh_expenditure = rowtotal(food_expenses recurrent_expenses infrequent_expenses) // --!> Where does home improvements fit? s318
	label var hh_expenditure "Annual household consumption expenditure" 

	gen percapitaexpenditure = hh_expenditure / tot_hhmem_num // divide by the number of people in the household
	label var percapitaexpenditure "Per-capita annual household consumption expenditure"

	* Recode 5% extremes to less extreme values 
	foreach var of varlist food_expenses recurrent_expenses infrequent_expenses hh_expenditure percapitaexpenditure {
		winsor `var', gen(`var'_w) highonly p(0.05)
		local label : variable label `var'
		label variable `var'_w "Winsorized - `label'"
		order `var'_w, before(`var')
	}

* Secondary outcome : Farm investment [NEW]
* ------------------------------------------------------------------
egen farm_expenses = rowtotal(s58b_* s57i_* s510b_*)
label var hh_expenditure "Annual farm expenditure"


* Secondary outcome : Monthly household income from agricultural 
*      				  and non-agricultural sources (household level)
* ------------------------------------------------------------------

* Non-farm employment
	egen wage_salary = anymatch(s63* s64*), values(1) 
	egen nonfarmbusiness = anymatch(s65* s66* s67*), values(1)
	label var wage_salary "Household earns wages/salaries"
	label var nonfarmbusiness "Household has non-farm business"

	foreach var of varlist s622* {
		gen annual_`var' = 12 * `var'  // --!> DO WE WANT TO ANNUALISE? 
		local label : variable label `var'
		label variable annual_`var' "Annual - `label'"
	}

	egen paid_wage = rowtotal(annual_s622_*)
	drop annual_s622_*

* Animal and animal products sales  --!> I DON'T REALLY UNDERSTAND THIS PART 
	foreach var of varlist numan chicken sheep goat pig cow anidex* {
		quietly destring `var', replace force
		}
	egen numan_n = rownonmiss(anidex*) // number of animals
	replace numan = numan_n
	drop numan_n 

	replace chicken=0
	replace sheep  =0
	replace goat   =0
	replace pig    =0
	replace cow    =0
	label var chicken "Household kept poultry"
	label var sheep   "Household kept from sheep"
	label var goat    "Household kept from goats"
	label var pig     "Household kept from pigs"
	label var cow     "Household kept from cows"

	gen sale_chicken=0
	gen sale_sheep  =0
	gen sale_goat   =0
	gen sale_pig    =0
	gen sale_cow    =0
	label var sale_chicken "Household earned from poultry sales"
	label var sale_sheep   "Household earned from sheep sales"
	label var sale_goat    "Household earned from goat sales"
	label var sale_pig     "Household earned from pig sales"
	label var sale_cow     "Household earned from cow sales"

	quietly sum numan
	local i = 1
		while `i' <= r(max){
		gen sale_s59j_`i' = 0
		replace sale_s59j_`i' = s59i_`i' * s59j_`i' if s59j_`i' != .
		order sale_s59j_`i', after(s59j_`i')
		local i = `i' + 1
		}

	gen sale_chicken1 = 0
	gen sale_chicken7 = 0
	gen sale_chicken8 = 0
	gen sale_chicken9 = 0

	quietly sum numan
	local i=1
		while `i'<=r(max){
		replace chicken = 1 if anidex_`i' == 1 & s59a_`i' != . & s59a_`i' > 0
		replace chicken = 1 if anidex_`i' == 7 & s59a_`i' != . & s59a_`i' > 0
		replace chicken = 1 if anidex_`i' == 8 & s59a_`i' != . & s59a_`i' > 0
		replace chicken = 1 if anidex_`i' == 9 & s59a_`i' != . & s59a_`i' > 0
		replace sale_chicken1 = sale_s59j_`i' if anidex_`i' == 1
		replace sale_chicken7 = sale_s59j_`i' if anidex_`i' == 7
		replace sale_chicken8 = sale_s59j_`i' if anidex_`i' == 8
		replace sale_chicken9 = sale_s59j_`i' if anidex_`i' == 9
		local i=`i'+1
		}

	egen sale_chicken0=rowtotal(sale_chicken1 sale_chicken7 sale_chicken8 sale_chicken9)
	replace sale_chicken=sale_chicken0
	drop sale_chicken0 sale_chicken1 sale_chicken7 sale_chicken8 sale_chicken9

	quietly sum numan
	local i=1
		while `i'<=r(max){
		replace sheep=1 if anidex_`i'==2 & s59a_`i'!=. & s59a_`i'>0
		replace sale_sheep=sale_s59j_`i' if anidex_`i'==2
		local i=`i'+1
		}

	quietly sum numan
	local i=1
		while `i'<=r(max){
		replace goat=1 if anidex_`i'==3 & s59a_`i'!=. & s59a_`i'>0
		replace sale_goat=sale_s59j_`i' if anidex_`i'==3
		local i=`i'+1
		}

	quietly sum numan
	local i=1
		while `i'<=r(max){
		replace pig=1 if anidex_`i'==4 & s59a_`i'!=. & s59a_`i'>0
		replace sale_pig=sale_s59j_`i' if anidex_`i'==4
		local i=`i'+1
		}

	quietly sum numan
	local i=1
		while `i'<=r(max){
		replace cow=1 if anidex_`i'==5 & s59a_`i'!=. & s59a_`i'>0
		replace sale_cow=sale_s59j_`i' if anidex_`i'==5
		local i=`i'+1
		}

	drop sale_s59j_*

	gen sale_milk=0
	gen sale_eggs=0
	label var sale_milk "Household earned from milk sales"
	label var sale_eggs "Household earned from eggs sales"


	local i=1
		while `i'<=3{
		gen sale_s511g_`i'=0
		replace sale_s511g_`i'=s511g_`i' * s511f_`i'  if s511g_`i'!=.
		order sale_s511g_`i', after(s511g_`i')	
		local i=`i'+1
		}

	local i=1
		while `i'<=3{
		replace sale_milk=sale_s511g_`i' if pos_6j_`i'==1
		local i=`i'+1
		}

	local i=1
		while `i'<=3{
		replace sale_eggs=sale_s511g_`i' if pos_6j_`i'==3 & follow==0
		replace sale_eggs=sale_s511g_`i' if pos_6j_`i'==2 & follow==1
		local i=`i'+1
		}

	drop sale_s511g*

	egen animal_sales = rowtotal(sale_chicken- sale_cow sale_milk sale_eggs)

	egen livestock_farmer = anymatch(chicken-cow), values(1)
	label var livestock_farmer "Household kept livestock or poultry"

* Crop cultivation and sales
	foreach var of varlist *crop_index_alone* *s52a_count* {
		quietly destring `var', replace force
		}
	egen s52a_count_n=rownonmiss(crop_index_alone*)
	replace s52a_count=s52a_count_n
	drop s52a_count_n 

	egen crop_sales=rowtotal(s52h*)

	gen crop_farmer=(s51==1)
	label var crop_farmer "Household farms crops"
	
* Per capita income
	egen hh_annual_income=rowtotal(animal_sales crop_sales paid_wage)
	label var hh_annual_income "Household total annual income"

	gen percapitaincome=hh_annual_income/tot_hhmem_num
	label var percapitaincome "Per-capita annual household income"

	foreach var of varlist animal_sales crop_sales paid_wage hh_annual_income percapitaincome {
		winsor `var', gen(`var'_w) highonly p(0.05)
		local label : variable label `var'
		label variable `var'_w "Winsorized - `label'"
		order `var'_w, before(`var')
	}
	tempfile rough
	save `rough'

* Secondary outcome : Index person participation in livelihood activities
* -----------------------------------------------------------------------
use "Data/DIG Household Panel Wide.dta", clear

* Keep the required vars
	keep s62_hmid_* s63_hmid_* s64_hmid_* s65_hmid_* s66_hmid_* s67_hmid_* s611_hmid_* s612_hmid_* s613_hmid_* s614_hmid_* s614a_* iga_count_* hhid s216_index follow		
	reshape long s62_hmid_ s63_hmid_ s64_hmid_ s65_hmid_ s66_hmid_ s67_hmid_ s611_hmid_ s612_hmid_ s613_hmid_ s614_hmid_ s614a_ iga_count_, i(hhid follow) j(igahh_lino)

	keep if s216_index==igahh_lino & s216_index!=. // Should we need participation of all household members (individual panel) igahh_lino or pos_7_ corresponds to lino

	gen workforpay    =(s63_hmid_==1 | s64_hmid_==1)
	gen businessself  =(s65_hmid_==1 | s66_hmid_==1)
	gen businesshh    =(s67_hmid_==1)
	gen farmhh        =(s611_hmid_==1 | s612_hmid_==1)
	gen jobsearch     =(s613_hmid_==1)
	gen startbusiness =(s614_hmid_==1)
	egen iga =anymatch(workforpay businessself businesshh farmhh), values(1)

	label var workforpay "Worked for pay"   
	label var businessself "Ran business for himself or herself"
	label var businesshh "Helped in household non-farm business"
	label var farmhh "Helped in household farm"
	label var jobsearch "Sought for a job"
	label var startbusiness "Tried starting up business  for himself or herself"
	label var iga "Engaged in income generating activity"

	foreach var of varlist s62_hmid_ - iga  {
		gen index_`var'=`var' if s216_index==igahh_lino
		local label : variable label `var'
		label variable index_`var'"Index Person - `label'"
		drop `var'
	}

	rename *_ *
	drop igahh_lino

	quietly merge 1:1 hhid follow s216_index using `rough', nogen
	tempfile rough
	save `rough'

* Index person participation in social activities
* -----------------------------------------------
* Training
	gen index_train=0 if s216_index!=.
	local i=1
		while `i'<=6 {
			local j=1
				while `j'<= 27 {
				quietly destring s814b_`j'_`i', replace
				quietly replace index_train=1 if s814b_`j'_`i'==1 & s216_index==`j'
				local j=`j'+1
				}
		local i=`i'+1
		}
* Social Empowerment Index
	* Difficulty to undertaking educational, productive and/or social due to PWD
		recode s219 (1/2 = 1) (3/4 = 0) (. = .), gen(sei1)
		label var sei1 "Has difficulty to undertaking educational, productive and/or social due to PWD"
	* Equal equal opportunity as your peers (people similar to you) to find work or labor
		recode s4_19 (4 = 1) (1/3 = 0) (. = .), gen(sei2)
		label var sei2 "Has equal opportunity as peers in finding work"
	* work a similar number of hours and engage similar types of work compared to your peers?
		recode s4_20 (4 = 1) (1/3 = 0) (. = .), gen(sei3)
		label var sei3 "Works similar hours and engage in similar work as peers"
	* Feels confident about abilities
		foreach var of varlist s4_16_* {
			recode `var' (4 = 1) (. = .) (else = 0), gen(d_`var' )
			}
		egen sei4 = rowmean(d_s4_16_*)
		drop d_s4_16_*
		recode sei4 (0.5/1=1) (else=0)
		replace sei4 = . if s4_16_1 == .
		label var sei4 "Confident about own abilities"

	* Comfortable sharing own opinion in family discussions
		recode s4_15_2 (4 = 1) (1/3 = 0) (. = .), gen(sei5)
		label var sei5 "Comfortable sharing own opinion in family discussions"
	* Helps other people 
		recode s4_17 (4 = 1) (1/3 = 0) (. = .), gen(sei6)
		label var sei6 "Helps other people"
	* Comfortable meeting new people
		recode s4_18 (4 = 1) (1/3 = 0) (. = .), gen(sei7)
		label var sei7 "Comfortable meeting new people"
	* Feel confident to try to learn new things
	* Participate in decision-making in household finance
		foreach var of varlist s4_14_* {
			recode `var' (3/4=1) (.=.) (else=0) , gen(d_`var' )
			}
		egen sei9=rowmean(d_s4_14_*)
		drop d_s4_14_*
		recode sei9 (0.5/1=1) (else=0)
		replace sei9=. if s4_1==. | pwd==0
		label var sei9 "Participates in decision-making on household finance"
	* Participate in social, cultural, religious, political events in the community
		local i = 1
			while `i' <= 8{
			replace s8a2_`i' = 0 if s8a2_`i' == . & s8a1_`i' < 4 & s8a1_`i' != .
			replace s8a1_`i' = 3 if s8a1_`i' == 4 & s8a2_`i' == 0
			local i = `i'+1
			}
	egen sei10 = anymatch(s8a2_*), values(1)
	replace sei10 = . if s8a1_1 == .
	label var sei10 "Participates in social, cultural, religious, political events in the community"

	* Take in casual recreational/social activities as peers
		recode s4_21 (3/4 = 1) (1/2 = 0) (. = .), gen(sei11)
		label var sei11 "Take in casual recreational/social activities as peers"
	* Treated by other people the same way as peers
		recode s4_22 (3/4 = 1) (1/2 = 0) (. = .), gen(sei12)
		label var sei12 "Treated by other people the same way as peers"
	* Have access to hygienic latrine
		gen sei13 = ((s39 == 3 | s39 == 4) & s323a == 1 & s323d == 0)
		label var sei13 "Have access to hygienic latrine with or without support"
		replace sei13 = . if follow == 0 
	* Have access to hand washing station, with or without support
		gen sei14 = (s323e == 1 & s324 == 0)
		label var sei14 "Have access to hand washing station, with or without support"
		replace sei14 = . if follow == 0

	egen sei_score = rowtotal(sei2 sei3 sei4 sei5 sei6 sei7 sei9 sei10 sei11 sei12 sei13 sei14) // Excluding the first and fourth SEI score 
	replace sei_score = . if sei12 == .

* Index person health and wellbeing
* ---------------------------------

* Violence and prejudice
	recode s5_10 (1 = 1) (.=.) (else=0), gen(domestic_violence)
	label var domestic_violence "Experienced domestic violence"

	recode s5_11 (1 = 1) (.=.) (else=0), gen(work_violence)
	label var work_violence "Experienced violence at work or school"

	recode s5_12 (1/4 = 1) (.=.) (else=0), gen(prejudice)
	label var prejudice "Experienced prejudice"

	recode s5_13 (1/4 = 1) (.=.) (else=0), gen(prejudice_disability)
	label var prejudice_disability "Experienced prejudice due to disability"

* Seeking healthcare
	recode index_s102 (1 = 1) (.=.) (else=0), gen(index_sick)
	label var index_sick "Index PWD experienced an illness/injury"

	recode index_s105 (1 = 1) (.=.) (else=0), gen(index_sought_treat)
	label var index_sought_treat "Index PWD sought treatment"

* Household welfare
* -----------------			

* Monthly saving
	egen monthly_saving=anymatch(s714*), values(1,2,3)
	egen totalsavings=rowtotal(s715*)
	winsor totalsavings, gen(totalsavings_w) highonly p(0.05)

* Welfare
	egen water_source=anymatch(s35),value(3 5 6 7)
	egen toilet_type=anymatch(s39),value(1 2)
	egen fuel_used=anymatch(s310),value(4 5)
	egen lighting_sources=anymatch(s311),value(5 6)
	egen own_rent=anymatch(s314),value(1 3)
	egen training=anymatch(s814a*), values(1)
	egen home_improve=anymatch(s316),value(1)
	egen improvement_cost=rowtotal(s318)
	gen borrowed_loan=s71>0
	egen total_loan=rowtotal(s77*)
	egen remaining_loan=rowtotal(s79*)
	foreach var of varlist improvement_cost total_loan remaining_loan {
		winsor `var', gen(`var'_w) highonly p(0.05)
		local label : variable label `var'
		label variable `var'_w "Winsorized - `label'"
		order `var'_w, before(`var')
		drop `var'
	}

* Dietary diversity
	egen cereals=anymatch(s42g_1 s42g_2 s42g_3 s42g_4 s42g_5), values(1)
	egen other_fuits=anymatch(s42g_6 s42g_19 s42g_20 s42g_21 s42g_22), values(1)
	egen white_roots=anymatch(s42g_7 s42g_8 s42g_9 s42g_10), values(1)
	egen vitamin_a_tuber=anymatch(s42g_11 s42g_12), values(1)
	egen dark_green=anymatch(s42g_13 s42g_14), values(1)
	egen other_vegetables=anymatch(s42g_15 s42g_16), values(1)
	egen vitamin_a_fruits=anymatch(s42g_16 s42g_17), values(1)
	egen organ_meat=anymatch(s42g_23), values(1)
	egen flesh_meat=anymatch(s42g_24), values(1)
	egen fresh_dried_fish=anymatch(s42g_25), values(1)
	egen eggs=anymatch(s42g_26), values(1)
	egen milk_products=anymatch(s42g_27), values(1)
	egen legumes_nut_seed=anymatch(s42g_28 s42g_29), values(1)
	egen oil_fat=anymatch(s42g_30), values(1)
	egen sweet=anymatch(s42g_31), values(1)
	egen spice_condiment_beverages=anymatch(s42g_31 s42g_32), values(1)
	egen vegetables=anymatch(vitamin_a_tuber dark_green other_vegetables),value(1)
	egen fruits=anymatch(vitamin_a_fruits other_fuits),value(1)
	egen meat=anymatch(organ_meat flesh_meat),value(1)
	egen hdds=rowtotal(cereals white_roots vegetables fruits meat fresh_dried_fish eggs milk_products legumes_nut_seed oil_fat sweet spice_condiment_beverages)

* Household Food Insecurity Access Scale (HFIAS)
	egen hfias=rowtotal(s81b_*)
	label var hfias "HFIAS"

* Meals Per Day
	gen dailymeals=s41/7
	label var dailymeals "Meals per day"

* Support received
	gen gift=(s87a_1==1)
	gen remittance=(s87a_2==1)
	gen food=(s87a_3==1)
	gen govt_cash=(s87a_4==1)
	gen ngo_cash=(s87a_6==1)
	gen ngo_noncash=(s87a_7==1)

* =============================================================================================== *
* Treatment status
* =============================================================================================== *

* !! SCRAMBLED FOR PRE-SPECIFICATION !! *

	*gen treat = (assign == 1)
	set seed 180922
	gen treat = runiformint(0, 1)
	label var treat "DIG"

	gen pwd_hh=(hhpwd==1)
	label var hhpwd "HH has PWD" // as per baseline survey

	gen treatXpwd_hh=treat*pwd_hh
	label var treatXpwd_hh "DIG X HH PWD"

	gen pwd_s = (eligible_pwd == 1)
	gen treatXpwd_s = treat * pwd_s
	label var pwd_s "HH has PWD" // as per beneficiary selection

save "Data/DIG Household Panel Wide Clean.dta", replace
