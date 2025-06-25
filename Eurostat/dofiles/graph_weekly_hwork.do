***************************************************************************
* File: graph_weekly_hwork.do | Author: Ángel Sánchez Daniel | Date: 12/06/2025
* Purpose: GDP growth rate visualizations (focus Spain and Germany)
***************************************************************************
* DATASET: lfsq_ewhuis - Weekly hours of work (Eurostat)
* TIME: 2013-2025 (Quarterly)
* UNIT: Hour
* VARS: CLV_PCH_PRE (GDP growth)
*		CLV_PCH_PRE_HAB (GDP per capita growth)
***************************************************************************
* worktime: TOTAL - Total
*			PT - Part time
*			FT - Full time
*			NRP - No response
* sex: M - Male
*	   F - Female
*      T - Total
* isco08: Industry code - International occupation classification
* wstatus: EMP - Employed persons
*			SAL - Employees
*			NSAL - Employed persons except employees
*			SELF - Self-employed persons
*			SELF_S - Self-employed persons with employees (employers)
*			SELF_NS - Self-employed persons without employees (own-account workers)
*			CFAM - Contributing family workers
*			NCFAM - Contributing family workers
*			NRP - No response
* age: Y15-24 - From 15 to 24 years
*	   Y15-34 - From 15 to 34 years
*      Y15-64 - From 15 to 64 years
*      Y_GE15 - 15 years or over
*      Y20-64 - From 20 to 64 years
*      Y25-54 - From 25 to 54 years
*      Y25-64 - From 25 to 64 years
*      Y35-49 - From 35 to 49 years
*      YGE50 - 50 years or over
*      Y55-64 - From 55 to 64 years



clear
cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\master"    // the path to the Eurostat folder

u lfsq_ewhuis_long

*****************************************************************************
* CONVERT QUARTERLY FORMAT (19991, 19992, etc.) TO STATA QUARTERLY DATE
*****************************************************************************

* Method 1: Create proper Stata quarterly date variable (RECOMMENDED)
gen year_num = floor(year/10)        // Extract year: 19991 -> 1999
gen quarter_num = mod(year, 10)      // Extract quarter: 19991 -> 1
gen date_q = yq(year_num, quarter_num)     // Create Stata quarterly date
format date_q %tq                          // Format as 1999q1, 2000q2, etc.
lab var date_q "Quarterly Date"

*****************************************************************************
* FILTERS
*****************************************************************************

keep if worktime == "TOTAL"
keep if sex == "T"
keep if isco08 == "TOTAL"
keep if wstatus == "EMP"
keep if age == "Y15-64"


*****************************************************************************
* FIND AND KEEP LAST AVAILABLE QUARTER
*****************************************************************************

* Method 1: Find the maximum quarter across all countries
sum date_q
local last_quarter = r(max)
keep if date_q == `last_quarter'

* Alternative Method: Find last quarter with non-missing data
* (use this if some countries have missing data in the very last quarter)
/*
bysort date_q: egen has_data = count(y) if !missing(y)
sum date_q if has_data > 0
local last_quarter = r(max)
keep if date_q == `last_quarter'
drop has_data
*/

* Display which quarter we're using
di "Using data from: " %tq `last_quarter'


*****************************************************************************
* PREPARE DATA FOR BAR GRAPH
*****************************************************************************

* Sort countries by value (optional - makes graph more readable)
gsort -y  // Descending order (highest values first)
* Alternative: gsort y  // Ascending order (lowest values first)

* Create rank variable for ordering (optional)
gen rank = _n

* Check data before graphing
list geo y in 1/10  // Show top 10 countries

*****************************************************************************
* CREATE BAR GRAPH
*****************************************************************************

* Basic bar graph
graph bar y, over(geo, sort(y) descending label(angle(45) labsize(small))) ///
    title("GDP Growth Rate - Last Available Quarter") ///
    subtitle("`: display %tq `last_quarter''") ///
    ytitle("Growth Rate (%)") ///
    note("Source: Eurostat") ///
    scheme(s1color)

gen is_eu27 = (geo == "EU27_2020")

/*
graph bar y, over(geo, sort(y) label(labsize(vsmall))) over(is_eu27, gap(0)) ///
    title("GDP Growth Rate by Country", size(medium)) ///
    subtitle("`: display %tq `last_quarter''", size(small)) 
	///
    xtitle("Growth Rate (%)") ytitle("") ///
    note("Source: Eurostat", size(vsmall)) ///
    bar(1, color(navy)) bar(2, color(red)) ///
    legend(order(1 "Countries" 2 "EU27 Average") size(small)) ///
    scheme(s1mono) graphregion(color(white))
*/
encode geo, gen(geo_num)
* First sort the data by value
gsort -y  // Sort by y in descending order (highest first)
gen order = _n  // Create position variable

twoway (bar y order if geo != "EU27_2020", barwidth(0.8) color(navy)) ///
       (bar y order if geo == "EU27_2020", barwidth(0.8) color(red)), ///
    xlabel(1(1)`=_N', valuelabel angle(45) labsize(vsmall)) ///
    title("GDP Growth Rate by Country") ///
    subtitle("`: display %tq `last_quarter''") ///
    ytitle("Growth Rate (%)") xtitle("") ///
    legend(order(1 "Countries" 2 "EU27 Average")) ///
    scheme(s1mono)

	
	
* Create custom labels showing country codes in sorted order
levelsof geo, local(countries)
local label_list ""
forval i = 1/`=_N' {
    local country = geo[`i']
    local label_list `"`label_list' `i' "`country'""'
}

twoway (bar y order if geo != "EU27_2020", barwidth(0.8) color(navy)) ///
       (bar y order if geo == "EU27_2020", barwidth(0.8) color(red)), ///
    xlabel(`label_list', angle(45) labsize(vsmall)) ///
    title("GDP Growth Rate by Country") ///
    subtitle("`: display %tq `last_quarter''") ///
    ytitle("Growth Rate (%)") xtitle("") ///
    legend(order(1 "Countries" 2 "EU27 Average")) ///
    scheme(s1mono)
	
*****************************************************************************
* METHODS TO ADD COUNTRY FLAGS TO STATA GRAPHS
*****************************************************************************

*****************************************************************************
* METHOD 1: UNICODE FLAG EMOJIS (EASIEST)
*****************************************************************************

* Create flag variable using Unicode
gen flag = ""
replace flag = "🇪🇸" if geo == "ES"  // Spain
replace flag = "🇫🇷" if geo == "FR"  // France  
replace flag = "🇩🇪" if geo == "DE"  // Germany
replace flag = "🇮🇹" if geo == "IT"  // Italy
replace flag = "🇵🇹" if geo == "PT"  // Portugal
replace flag = "🇳🇱" if geo == "NL"  // Netherlands
replace flag = "🇧🇪" if geo == "BE"  // Belgium
replace flag = "🇦🇹" if geo == "AT"  // Austria
replace flag = "🇸🇪" if geo == "SE"  // Sweden
replace flag = "🇩🇰" if geo == "DK"  // Denmark
replace flag = "🇫🇮" if geo == "FI"  // Finland
replace flag = "🇳🇴" if geo == "NO"  // Norway
replace flag = "🇮🇪" if geo == "IE"  // Ireland
replace flag = "🇬🇷" if geo == "EL"  // Greece (EL = Hellenic Republic)
replace flag = "🇵🇱" if geo == "PL"  // Poland
replace flag = "🇨🇿" if geo == "CZ"  // Czech Republic
replace flag = "🇸🇰" if geo == "SK"  // Slovakia
replace flag = "🇭🇺" if geo == "HU"  // Hungary
replace flag = "🇸🇮" if geo == "SI"  // Slovenia
replace flag = "🇭🇷" if geo == "HR"  // Croatia
replace flag = "🇷🇴" if geo == "RO"  // Romania
replace flag = "🇧🇬" if geo == "BG"  // Bulgaria
replace flag = "🇱🇹" if geo == "LT"  // Lithuania
replace flag = "🇱🇻" if geo == "LV"  // Latvia
replace flag = "🇪🇪" if geo == "EE"  // Estonia
replace flag = "🇨🇾" if geo == "CY"  // Cyprus
replace flag = "🇲🇹" if geo == "MT"  // Malta
replace flag = "🇱🇺" if geo == "LU"  // Luxembourg
replace flag = "🇪🇺" if geo == "EU27_2020"  // EU flag

* Create combined label with flag + country code
gen flag_label = flag + " " + geo

* Update your graph with flags
* First sort the data by value
gsort -y  
drop order
gen order = _n  

* Create custom labels with flags
local label_list ""
forval i = 1/`=_N' {
    local country_flag = flag_label[`i']
    local label_list `"`label_list' `i' "`country_flag'""'
}

twoway (bar y order if geo != "EU27_2020", barwidth(0.8) color(navy)) ///
       (bar y order if geo == "EU27_2020", barwidth(0.8) color(red)), ///
    xlabel(`label_list', angle(45) labsize(vsmall)) ///
    title("GDP Growth Rate by Country") ///
    subtitle("`: display %tq `last_quarter''") ///
    ytitle("Growth Rate (%)") xtitle("") ///
    legend(order(1 "Countries" 2 "EU27 Average")) ///
    scheme(s1mono)

	
* IS NOT POSSIBLE TO PUT FLAGS IN STATA EASILY, I SHOULD MOVE TO R
	