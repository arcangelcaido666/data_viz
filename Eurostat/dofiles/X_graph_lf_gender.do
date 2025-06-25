*lfsi_emp_a

clear
cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT\master"    // the path to the Eurostat folder

* Start with labor force data
use lfsi_emp_a_long, clear

* Keep only labor force and prepare
keep if indic_em == "ACT" & unit == "PC_POP" & age == "Y15-64" & geo == "EU27_2020"
gen variable = "labor_force"

twoway (line y year if geo == "EU27_2020" & sex == "T", ///
        lcolor(black)) ///
       (line y year if geo == "EU27_2020" & sex == "M", ///
        lcolor(blue)) ///
	   (line y year if geo == "EU27_2020" & sex == "F", ///
        lcolor(red)), ///
       title("EU27 Working Age Labor Force by gender") ///
       subtitle("2009-2024") ///
       ytitle("Millions of Persons") ///
       xtitle("Year") ///
       xlabel(2009(1)2024) ///
	   legend(label(1 "Total") label(2 "Males") label(3 "Females") ///
       size(small) position(5) ring(0) region(color(none))) ///
       note("Source: Eurostat (lfsi_emp_a)")
