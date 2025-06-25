* GRAPH une_rt_m

clear all

local dataset "une_rt_m"

clear
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"
global master_folder "$project_root\master"
global graphs_folder "$project_root\graphs"


cd "$master_folder"


u ./`dataset'_long.dta


* Convert year (YYYY_MM format) to a date variable
gen date_str = subinstr(year, "_", "m", .)
gen date = monthly(date_str, "YM")
format date %tm

preserve
keep if sex == "T"  // TOTAL
keep if geo == "IT" | geo == "ES" | geo == "PT" | geo == "EL" | geo =="EU27_2020" // COUNTRIES NEEDED (EU19, SPAIN, GREECE, PORTUGAL, ITALY)
keep if age == "TOTAL"
keep if s_adj == "SA" // SEASONALLY ADJUSTED
keep if unit == "PC_ACT"
	

*Basic line graph
twoway (line y date if geo == "IT", lcolor(green)) ///
       (line y date if geo == "ES", lcolor(red)) ///
       (line y date if geo == "PT", lcolor(black)) ///
	   (line y date if geo == "EL", lcolor(blue)) ///
	   (line y date if geo == "EU27_2020", lcolor(yellow)), ///
		title("Time Series Plot") xtitle("Date") ytitle("Value")

		
keep if date >= tm(2007m1)
* FROM 2007		
twoway (line y date if geo == "IT", lcolor(green)) ///
       (line y date if geo == "ES", lcolor(red)) ///
       (line y date if geo == "PT", lcolor(black)) ///
	   (line y date if geo == "EL", lcolor(blue)) ///
	   (line y date if geo == "EU27_2020", lcolor(yellow)), ///
		title("Time Series Plot") xtitle("Date") ytitle("Value")	///
    legend(label(1 "Italy") label(2 "Spain") label(3 "Portugal") label(4 "Greece") label(5 "EU27_2020"))
	
	
* Formatted
twoway (line y date if geo == "IT", lcolor(green)) ///
       (line y date if geo == "ES", lcolor(red)) ///
       (line y date if geo == "PT", lcolor(black)) ///
	   (line y date if geo == "EL", lcolor(blue)) ///
	   (line y date if geo == "EU27_2020", lcolor(yellow)), ///
title("Monthly Unemployment Rate - EA-19 & Southern European Countries") subtitle("(seasonally adjusted, not calendar adjusted data)") xtitle("Date") ytitle("Percentage (%)") ///
legend(label(1 "Italy") label(2 "Spain") label(3 "Portugal") label(4 "Greece") label(5 "EU27_2020")) 

cd "$graphs_folder"
graph export "unemployment.png", replace

restore