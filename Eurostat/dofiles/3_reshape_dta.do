***************************************************************************
* File: 3_reshape.do EUROSTAT DATA RESHAPER (Step 3/3)
* Purpose: Reshape Eurostat datasets
* Author: Ángel Sánchez Daniel
* Date: 12/06/2025
* Description: Reshape wide-format Eurostat data to long format for
*              visualization
* Input:   [dataset]_wide.dta (from data management step)
* Output:  [dataset]_long.dta (ready for graphing)
***************************************************************************


* DATASET

local dataset "lfsq_ewhuis"


*****************************************************************************
* SETTING UP THE DATA
*****************************************************************************

clear


// Set up flexible paths
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"

// Change to raw data directory
cd "$project_root"  


// Use dataset
u ./master/`dataset'_wide.dta


* Preserve original year column names as variable labels before reshape
foreach x of varlist y* {  
lab var `x' "`x'"
}

* Identify non-year variables to use as reshape identifiers
ds, not(varl y*)   // pick variables labels that don't have y
local ivars `r(varlist)'

* Reshape from wide to long format (y2020, y2021... -> year, y)
reshape long y, i(`ivars') j(year) string
* if there is an error here check strings in the years and come back to cleaning

* Clean missing observations and standardize data types
drop if y==.   // Remove missing values
destring _all, replace  // Convert string numbers to numeric

* Finalize dataset structure
lab var year "Year"
compress
order geo year
sort geo year

* Save dataset
save ./master/`dataset'_long.dta, replace  // save the final file