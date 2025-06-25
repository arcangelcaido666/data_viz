*****************************************************************************
* File: 02_eurostat_data_cleaning.do  
* Purpose: Clean and format downloaded Eurostat TSV files 
*          into analysis-ready format
* Author: Ángel Sánchez Daniel
* Date: 10/06/2025
* Description: Processes raw Eurostat TSV structure, separates metadata from 
*              time series, handles data flags, and creates wide-format 
*              datasets
*****************************************************************************


clear all
set more off


*****************************************************************************
* CONFIGURATION - CHANGE DATASET NAME HERE
*****************************************************************************
global dataset "lfsq_ewhuis"  // Main dataset identifier - CHANGE THIS


*****************************************************************************
* PROJECT PATHS SETUP
*****************************************************************************
// Set up project paths (consistent with download script)
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"
global raw_folder "$project_root\raw"
global master_folder "$project_root\master"

// Change to project root directory
cd "$raw_folder"


*****************************************************************************
* DATA IMPORT
*****************************************************************************

// Import TSV file with comprehensive error handling
display "Processing dataset: ${dataset}"

// Change name 
import delimited using $dataset.tsv , delim(tab) clear

cd "$project_root"


*****************************************************************************
* EUROSTAT DATA STRUCTURE ANALYSIS AND PROCESSING
*****************************************************************************

/* UNDERSTANDING EUROSTAT TSV STRUCTURE:
   - Column 1 (v1): Metadata string with comma-separated dimensions
     Format: "dimension1,dimension2,dimension3,geo\TIME_PERIOD"
     Example: "B1GQ,CP_MEUR,NSA,AT\TIME_PERIOD"
   - Columns 2+ (v2, v3, ...): Time series data by year/period
   - Row 1: Contains headers (dimension names + year labels)
   - Rows 2+: Actual data values with Eurostat quality flags
*/

display "Processing Eurostat metadata structure..."

// Split metadata column by comma separator
quietly split v1, parse(,) generate(meta)
local meta_vars = r(nvars)  // Store number of metadata variables created



// Clean up and reorganize
drop v1
order meta* v*

display "✓ Metadata processing complete"
display "- Metadata dimensions found: {res}`meta_vars'"


*****************************************************************************
* METADATA COLUMN PROCESSING AND STANDARDIZATION
*****************************************************************************

display "Standardizing metadata column names..."

foreach var of varlist meta* {
quietly replace `var' = "geo" if `var' == "geo\TIME_PERIOD" in 1
    
	// Extract header name from first observation
    local header = `var'[1]
	
	// Rename variable with error handling
    capture rename `var' `header'
    display "  - Renamed `var' → `header'"
}

display "✓ Metadata column processing complete"


*****************************************************************************
* TIME SERIES DATA COLUMN PROCESSING AND VALIDATION
*****************************************************************************

/* EUROSTAT DATA QUALITY FLAGS REFERENCE:
   : = not available / no data
   e = estimated value
   p = provisional value
   r = revised value  
   s = Eurostat estimate
   @ = confidential data
   Additional symbols may include combinations like "ep", "pr", etc.
*/

 foreach i of varlist v* {
 cap replace `i' = ustrregexra(`i', "[a-z]", "")
 cap replace `i' = ustrregexra(`i', "[A-Z]", "")
 cap replace `i' = ustrregexra(`i', ":", "")
 cap replace `i' = ustrregexra(`i', "@", "")
 cap replace `i' = ustrregexra(`i', "-", "") in 1 // replace in the first obs
 cap replace `i' = ustrregexra(`i', "_", "")
 cap replace `i' = ustrregexra(`i', "e", "")
 cap replace `i' = ustrregexra(`i', "p", "")
 cap replace `i' = ustrregexra(`i', "r", "")
 cap replace `i' = ustrregexra(`i', "s", "")
}

display "Processing time series data columns..."

// Initialize counters for validation
local valid_years = 0
local invalid_years = 0
local year_list = ""

// Process each data column (v2, v3, etc.)
foreach var of varlist v* {
    // Extract potential year from first row
    local potential_year = `var'[1]
    
	// Handle non-year columns (quarterly data, etc.)
    local clean_name = subinstr("`potential_year'", " ", "_", .)
    local clean_name = subinstr("`clean_name'", "-", "_", .)
	
    capture rename `var' y`clean_name'
        if _rc == 0 {
            display "  - Renamed `var' → y`clean_name'"
        }
        else {
            display as error "  - Warning: Could not rename `var' to y`clean_name'"

        }
    }

// Validation summary
display "✓ Time series column processing complete"


*****************************************************************************
* DATA FINALIZATION AND NUMERIC CONVERSION
*****************************************************************************

* VARIABLE NAMES FROM THE FIRST ROW
// fixing the v columns
foreach k of varlist y* {
  local header = `k'[1]
  ren `k' y`header'
  }

drop in 1  // drop the first row
destring _all, replace


*****************************************************************************
* OUTPUT PREPARATION AND SAVING
*****************************************************************************

save "./master/${dataset}_wide.dta", replace  // save the final file

*****************************************************************************
* END OF CLEANING SCRIPT
*****************************************************************************