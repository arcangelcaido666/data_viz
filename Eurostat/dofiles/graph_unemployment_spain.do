* GRAPH UNEMPLOYMENT 

*ei_lmhr_m

clear
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"
global master_folder "$project_root\master"
global graphs_folder "$project_root\graphs"


cd "$master_folder"
*cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\master"    // the path to the Eurostat folder

u ei_lmhr_m_long


* Convert year variable (YYYYMM format) to proper date format
gen year_num = floor(year/100)
gen month_num = year - year_num*100

* Create proper date variable
gen date = ym(year_num, month_num)
format date %tm

preserve
* GRAPH TOTAL UNEMPLOYMENT AND YOUTH UNEMPLOYMENT SPAIN
*preserve

keep if s_adj == "SA"
keep if geo == "ES"
keep if indic == "LM-UN-T-TOT" | indic == "LM-UN-T-LE25"

* Load and prepare the data
* Assuming your data is already loaded in Stata



/*
* Create quarter variable
gen quarter = qofd(dofm(date))
format quarter %tq
*/

* Clean the indic variable to remove hyphens (replace with underscores)
replace indic = subinstr(indic, "-", "_", .)

* Reshape data to have unemployment types in separate variables
reshape wide y, i(geo year date) j(indic) string
*reshape wide y, i(geo year quarter date) j(indic) string

* Rename variables for clarity
rename yLM_UN_T_TOT unemployment_total
rename yLM_UN_T_LE25 unemployment_youth

* Create the graph
twoway (line unemployment_total date, lcolor(blue) lwidth(medium)) ///
       (line unemployment_youth date, lcolor(red) lwidth(medium)), ///
       title("Unemployment Rates in Spain") ///
       subtitle("Total vs Youth (≤25 years) Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       legend(label(1 "Total Unemployment") label(2 "Youth Unemployment (≤25)")) ///
       xlabel(, angle(45)) ///
       ylabel(0(10)50) ///
       graphregion(color(white)) ///
       plotregion(color(white))

* DESDE QUE GOBIERNA PEDRO SANCHEZ
* Filter data from June 2018 onwards (201806)
keep if date >= tm(2018m6)

twoway (line unemployment_total date, lcolor(blue) lwidth(medium)) ///
       (line unemployment_youth date, lcolor(red) lwidth(medium)), ///
       title("Unemployment Rates in Spain") ///
       subtitle("Total vs Youth (≤25 years) Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       legend(label(1 "Total Unemployment") label(2 "Youth Unemployment (≤25)")) ///
       xlabel(, angle(45)) ///
       ylabel(10(5)45) ///
       graphregion(color(white)) ///
       plotregion(color(white))

* SEPARATED 

line unemployment_total date, lcolor(blue) lwidth(medium) ///
       title("Unemployment Rate in Spain") ///
       subtitle("Total Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       xlabel(, angle(45)) ///
       ylabel(10(1)17) ///
       graphregion(color(white)) ///
       plotregion(color(white))

line unemployment_youth date, lcolor(blue) lwidth(medium) ///
       title("Unemployment Rate in Spain") ///
       subtitle("Youth (≤25 years) Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       xlabel(, angle(45)) ///
       ylabel(25(5)40) ///
       graphregion(color(white)) ///
       plotregion(color(white))  

*restore

* GRAPH FOR YOUTH UNEMPLOYMENT FORMATTED

*preserve

* Find the earliest matching date close to 2018m6
gen is2018m6 = abs(date - tm(2018m6))
sort is2018m6
list date unemployment_youth in 1   // check the closest
local base = date[1]

* Find the latest available date
summarize date, meanonly
local latest = r(max)

local today = c(current_date)
local updated : display %tdCCYY-NN-DD daily("`today'", "YMD")

* Now extract the values
summarize unemployment_youth if date == `base', meanonly
local youth_2018 = r(mean)

summarize unemployment_youth if date == `latest', meanonly
local youth_2025 = r(mean)

* Difference
local diff_youth = `youth_2025' - `youth_2018'

* Display
display "Youth 2018: `youth_2018'"
display "Youth 2025: `youth_2025'"
display "Diff: `diff_youth'"

* Crea versiones con formato ya aplicado
local youth_2018_fmt : display %4.2f `youth_2018'
local youth_2025_fmt : display %4.2f `youth_2025'
local diff_youth_fmt : display %4.2f `diff_youth'

twoway (line unemployment_youth date, lcolor(blue) lwidth(medium) xline(`=tm(2018m6)') xline(`=tm(2020m1)') xline(`=tm(2020m3)') xline(`=tm(2023m11)')), ///
       title("Unemployment Rate in Spain") ///
       subtitle("Youth (≤25 years) Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       xlabel(, angle(45)) ///
       ylabel(25(5)40) ///
	   text(25 `=tm(2018m6)' "Perro Sanxe" "1st term" "(Jun 2018)", size(small) placement(n)) ///
	   text(10 `=tm(2023m11)' "Perro Sanxe" "3nd term" "(Nov 2023)", size(small) placement(n)) ///
       text(25 `=tm(2019m8)' "Perro Sanxe" "2nd term" "(Jan 2020)", size(small) placement(n)) ///
       text(25 `=tm(2020m7)' "COVID-19" "(Mar 2020)", size(small) placement(n)) /// // This is the "box" text in top-right
       text(39 `=tm(2024m6)' ///
       "Youth Unemployment (%)" ///
       "---------------------------" ///
       "June 2018: `youth_2018_fmt' %" ///
       "March 2025: `youth_2025_fmt' %" ///
	   "---------------------------" ///
       "Δ Diff.: `diff_youth_fmt' %") ///
	  note("Source: Eurostat (ei_lmhr_m). Last updated: `today'", size(vsmall)) ///
	   graphregion(color(white)) ///
       plotregion(color(white))

cd "$graphs_folder"
*"C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\graphs"
graph export "unemployment_youth_PSOE.png", width(2400) height(1800) replace
	   
	   
*restore

/*	   
* GRAPH FOR TOTAL UNEMPLOYMENT FORMATTED
* Find the earliest matching date close to 2018m6
gen is2018m6 = abs(date - tm(2018m6))
sort is2018m6
list date unemployment_total in 1   // check the closest
local base = date[1]
*/
* Find the latest available date
summarize date, meanonly
local latest = r(max)

local today = c(current_date)
local updated : display %tdCCYY-NN-DD daily("`today'", "YMD")

* Now extract the values
summarize unemployment_total if date == `base', meanonly
local total_2018 = r(mean)

summarize unemployment_total if date == `latest', meanonly
local total_2025 = r(mean)

* Difference
local diff_total = `total_2025' - `total_2018'

* Display
display "Total 2018: `total_2018'"
display "Total 2025: `total_2025'"
display "Diff: `diff_total'"

* Crea versiones con formato ya aplicado
local total_2018_fmt : display %4.2f `total_2018'
local total_2025_fmt : display %4.2f `total_2025'
local diff_total_fmt : display %4.2f `diff_total'

twoway (line unemployment_total date, lcolor(red) lwidth(medium) xline(`=tm(2018m6)') xline(`=tm(2020m1)') xline(`=tm(2020m3)') xline(`=tm(2023m11)')), ///
       title("Unemployment Rate in Spain") ///
       subtitle("Total Unemployment") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
       xlabel(, angle(45)) ///
       ylabel(10(1)17) ///
	   text(10 `=tm(2018m6)' "Perro Sanxe" "1st term" "(Jun 2018)", size(small) placement(n)) ///
       text(10 `=tm(2019m8)' "Perro Sanxe" "2nd term" "(Jan 2020)", size(small) placement(n)) ///
	   text(10 `=tm(2023m11)' "Perro Sanxe" "3nd term" "(Nov 2023)", size(small) placement(n)) ///
       text(10 `=tm(2020m7)' "COVID-19" "(Mar 2020)", size(small) placement(n)) /// // This is the "box" text in top-right
       text(16 `=tm(2024m6)' ///
       "Total Unemployment (%)" ///
       "---------------------------" ///
       "June 2018: `total_2018_fmt' %" ///
       "March 2025: `total_2025_fmt' %" ///
	   "---------------------------" ///
       "Δ Diff.: `diff_total_fmt' %") ///
	  note("Source: Eurostat (ei_lmhr_m). Last updated: `today'", size(vsmall)) ///
	   graphregion(color(white)) ///
       plotregion(color(white))

cd "$graphs_folder"
graph export "unemployment_total_PSOE.png", width(2400) height(1800) replace


restore


* GRAPH RACE SPAIN V. SWEEDEN

drop if geo == "IS" | geo == "NO" | geo == "LI"| geo == "CH" // Drorp EFTA bosnia herzegov not ue
drop if geo == "BA" | geo == "ME" | geo == "MD" | geo == "MK" | geo == "GE" | geo == "AL" | geo == "RS" | geo == "TR" | geo == "UA" // drop EU candidates
keep if s_adj == "SA"
*keep if geo == "ES" | geo == "SE"
keep if indic == "LM-UN-T-TOT" | indic == "LM-UN-T-LE25"

* Clean the indic variable to remove hyphens (replace with underscores)
replace indic = subinstr(indic, "-", "_", .)

* Reshape data to have unemployment types in separate variables
reshape wide y, i(geo year date) j(indic) string
*reshape wide y, i(geo year quarter date) j(indic) string

* Rename variables for clarity
rename yLM_UN_T_TOT unemployment_total
rename yLM_UN_T_LE25 unemployment_youth


* Filter data from June 2018 onwards (201806)
keep if date >= tm(2020m3)

twoway (line unemployment_total date if geo == "ES") ///
	   (line unemployment_total date if geo == "SE") ///
	   (line unemployment_total date if geo != "ES" & geo != "SE", ///
        lcolor(gs14) lwidth(thin))


* 1. Guardamos los países "otros"
levelsof geo if geo != "ES" & geo != "SE" & geo != "EL", local(other_countries)
		
twoway (line unemployment_youth date if geo == "ES") ///
	   (line unemployment_youth date if geo == "SE") ///
	  (line unemployment_youth date if geo == "EL") ///
	   (line unemployment_youth date if geo != "ES" & geo != "SE" & geo != "EL", ///
        lcolor(gs14) lwidth(thin)), ///
		title("The Race for the Youth Unemployment Throne") ///
       subtitle("Youth Unemployment (European Union)") ///
       xtitle("Month") ///
       ytitle("Unemployment Rate (%)") ///
	    legend(label(1 "Spain") label(2 "Sweeden") label(3 "Greece") label(4 "EU countries")) ///
	  note("Source: Eurostat (ei_lmhr_m). Last updated: `today'", size(vsmall)) ///
	   graphregion(color(white)) ///
       plotregion(color(white))
	
*cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\graphs"
cd "$graphs_folder"
graph export "unemployment_youth_race.png", width(2400) height(1800) replace
