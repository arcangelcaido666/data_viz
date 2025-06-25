***************************************************************************
* File: graph_gdp_growth.do | Author: Ángel Sánchez Daniel | Date: 12/06/2025
* Purpose: GDP growth rate visualizations (focus Spain and Germany)
***************************************************************************
* DATASET: tec00115 - Real GDP growth rate (Eurostat)
* TIME: 2013-2025 (Yearly)
* UNIT: Percentage
* VARS: CLV_PCH_PRE (GDP growth)
*		CLV_PCH_PRE_HAB (GDP per capita growth)
***************************************************************************


clear
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"
global master_folder "$project_root\master"
global graphs_folder "$project_root\graphs"


cd "$master_folder"

u tec00115_long


preserve
* GRAPH GDP GROWTH SPAIN GERMANY
*preserve

keep if geo == "BE" | geo == "BG" | geo == "CZ" | geo == "DK" | geo == "DE" | geo == "EE" | geo == "IE" | geo == "EL" | geo == "ES" | geo == "FR" | geo == "HR" | geo == "IT" | geo == "CY" | geo == "LV" | geo == "LT" | geo == "LU" | geo == "HU" | geo == "MT" | geo == "NL" | geo == "AT" | geo == "PL" | geo == "PT" | geo == "RO" | geo == "SI" | geo == "SK" | geo == "FI" | geo == "SE"  | geo == "EU27_2020" // 26 eu countries + eu27
*"EA19" "EA20"
keep if unit == "CLV_PCH_PRE"

* Find the latest available date
local today = c(current_date)
local updated : display %tdCCYY-NN-DD daily("`today'", "YMD")


levelsof geo if geo != "ES" & geo != "SE", local(other_countries)

local plotlist ""
foreach country in `other_countries' {
    local plotlist "`plotlist' (line y year if geo == "`country'", lcolor(gs14) lwidth(thin))"
}

			  
* GRAPH
* HE TENIDO QUE DUPLICAR LAS LINEAS QUE QUIERO PARA QUE SALGAN BIEN			  
twoway (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)) ///
       `plotlist' ///
	   (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)), ///
       legend(order(1 "Spain" 2 "Germany" 3 "EU Countries") ///
              rows(1) position(6))

			  
twoway (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)) ///
       `plotlist' ///
	   (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)), ///
       legend(order(1 "Spain" 2 "Germany" 3 "EU Countries")) ///
		title("Justicia poética") ///
       subtitle("GDP Growth") ///
       xtitle("Year") ///
       ytitle("GDP Growth (%)") ///
	  note("Source: Eurostat tec00115 (from nama_10_gdp)). Last updated: `today'", size(vsmall)) ///
	   graphregion(color(white)) ///
       plotregion(color(white))

* GRAPH AFTER PANDEMIC
keep if year >= 2020

	   
twoway (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)) ///
       `plotlist' ///
	   (line y year if geo == "ES", ///
        lcolor(red) lwidth(medium)) ///
       (line y year if geo == "DE", ///
        lcolor(blue) lwidth(medium)), ///
       legend(order(1 "Spain" 2 "Germany" 3 "EU Countries")) ///
		title("Poetic Justice: Spain Rises as Germany Falls Behind") ///
       subtitle("GDP Growth") ///
       xtitle("Year") ///
	   xlabel(2020(1)2024) ///
       ytitle("GDP Growth (%)") ///
	   note("Source: Eurostat tec00115 (from nama_10_gdp)). Last updated: `today'", size(vsmall) position(6)) ///
	   graphregion(color(white)) ///
       plotregion(color(white))	   
	  
	  
cd "$graphs_folder"
graph export "gdp_growth_justice.png", width(2400) height(1800) replace
	  
