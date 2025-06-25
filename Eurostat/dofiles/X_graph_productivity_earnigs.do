* GRAPH productivity and wages

// --- 0. Preliminaries ---
clear all
set more off // So output doesn't pause
cd "C:\Users\angel\OneDrive - Universidad de Salamanca\7.- EUROSTAT"    // the path to the Eurostat folder

// --- 1. Load the first dataset (earnings) and prepare it ---
use ".\master\earn_nt_net_long.dta", clear

append using  ".\master\nama_10_lp_ulc_long.dta"

* filters earnings
keep if estruct ==  "TOTAL" | estruct == ""
keep if ecase == "P1_NCH_AW100" | ecase == "" // Single person without children earning 100% of the average earning
keep if currency == "EUR" | currency == ""
keep if geo == "EA19"


* FILTER PRODUCTIVITY
keep if unit == "I15" | unit == "" // Indes:2015=100
keep if na_item == "RLPR_HW" | na_item == "" // Real labour productivity per person
*RLPR_PER // Real labour productivity per hour

// --- 1. Crear una variable identificadora de serie ---
// Asumiremos que "P1_NCH_AW100" son ganancias y "RLPR_HW" es productividad
// Si tienes otros valores en ecase o na_item, necesitarás ajustar esto o filtrar.

gen str15 series_id = "" // String variable para el ID de la serie

// Usamos `missing()` para verificar strings vacíos, que es como Stata representa
// los campos "" que pegaste para na_item en la primera serie, y ecase/currency/estruct en la segunda.
replace series_id = "earnings" if ecase == "P1_NCH_AW100" & !missing(ecase)
replace series_id = "productivity" if na_item == "RLPR_HW" & !missing(na_item)

// Verificar que se hayan asignado los IDs correctamente
tab series_id

// Eliminar observaciones que no correspondan a ninguna de nuestras series de interés (si las hubiera)
// En este caso, todas las filas deberían tener un series_id
drop if missing(series_id)




	
* Basic graph

twoway ///
(line value year if series_id == "earnings", yaxis(1) legend(label(1 "Earnings (EA19)"))) ///	
(line value year if series_id == "productivity", yaxis(2) legend(label(2 "Productivity (EA19)"))),  ///
title("Earnings vs. Productivity for EA19", size(medium)) ///
    xtitle("Year", size(small)) ///
    ytitle("Earnings Value", axis(1) size(small)) ///
    ytitle("Productivity Index", axis(2) size(small)) ///
    legend(position(6) ring(0) rows(1) size(small))

	