

* 
* PC_POP
* Y15-64
* T
* ACT: Persons in the labour force
* EMP_LFS: Total employment

* 

clear
cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\master"    // the path to the Eurostat folder

* Start with labor force data
use lfsi_emp_a_long, clear

* Keep only labor force and prepare
keep if indic_em == "ACT" & unit == "THS_PER" & sex == "T" & age == "Y15-64" & geo == "EU27_2020"
gen variable = "labor_force"

* Append population data
append using demo_pjan_long
replace variable = "total_population" if missing(variable)

keep if sex == "T"
* T: Total F: Female M: Male
drop if variable == "total_population" & unit != "NR" 
drop if variable == "total_population" & age != "TOTAL" 
drop if variable == "total_population" & geo != "EU27_2020"


* Convert total population from numbers to thousands
replace y = y / 1000 if variable == "total_population"

* Convert population from thousands to millions  
replace y = y / 1000

drop if year <2009
* Create graph with specified y-axis range
twoway (line y year if variable == "total_population" & geo == "EU27_2020", ///
        lcolor(blue)) ///
       (line y year if variable == "labor_force" & geo == "EU27_2020", ///
        lcolor(red)), ///
       title("EU27 Total Population vs Working Age Labor Force") ///
       subtitle("2009-2024") ///
       ytitle("Millions of Persons") ///
       xtitle("Year") ///
       xlabel(2009(1)2024) ///
       ylabel(150(50)500) ///
	   legend(label(1 "Total Population") label(2 "Labor Force (15-64)") ///
       size(small) position(3) ring(0) region(color(none))) ///
       note("Source: Eurostat (lfsi_emp_a demo_pjan)")
	   
	   
* TODO: data for labour force older than 2009 (why just 2009?)