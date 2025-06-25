*****************************************************************************
* File: 04_adding_labels.do  
* Purpose: 
* Author: Ángel Sánchez Daniel
* Date: 10/06/2025
* Description:
*****************************************************************************

clear

global project_root "C:\Users\angel\Documents\data_viz\Eurostat"

cd "$projectroot" // the path to the Eurostat folder

use ./master/nama_10_gdp_wide.dta, clear

 ds
   local mylist  `r(varlist)'
   local droplist  year y     
   local mylist : list mylist - droplist
   
   di "`mylist'"
   
  
 copy "https://ec.europa.eu/eurostat/api/dissemination/files/inventory?type=codelist" metadata.txt, replace
 
 
 import delim using metadata.txt, clear  // master file
 
 
replace code = lower(code)
gen seq = _n                 // counter for pick rows