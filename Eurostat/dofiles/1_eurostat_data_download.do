***************************************************************************
* File: 1_eurostat_data_download.do
* Purpose: Download and extract Eurostat datasets from API endpoints
* Author: Ángel Sánchez Daniel
* Date: 10/06/2025
* Description: Downloads specified Eurostat datasets in TSV format, extracts
*              compressed files, and prepares raw data for subsequent *              processing
***************************************************************************


* DATASET

local dataset "lfsq_ewhuis"          // Define dataset to download


*****************************************************************************
* SETTING UP THE DATA
*****************************************************************************

clear

// Set up flexible paths
global project_root "C:\Users\angel\Documents\data_viz\Eurostat"
global raw_folder "$project_root\raw"
global zip_path "C:\Program Files\7-Zip\7zG.exe"

// Change to raw data directory
cd "$raw_folder"  

// Check if 7-Zip exists
capture confirm file "C:\Program Files\7-Zip\7zG.exe"
if _rc != 0 {
    display as error "7-Zip not found. Please install or update path."
    exit _rc
}


*****************************************************************************
* SINGLE FILE DOWNLIAD SECTION
*****************************************************************************
// EUROSTAT API STRUCTURE:
// Base URL: https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/
// Format: [BASE_URL][DATASET_CODE]/?format=TSV&compressed=true
// Replace DATASET_CODE with the specific Eurostat dataset identifier


display "Attempting to download `dataset'..."

// Download dataset with error handling
capture copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/`dataset'/?format=TSV&compressed=true" "`dataset'.tsv.gz", replace
if _rc != 0 {
    display as error "Failed to download `dataset' data. Check internet connection and dataset code."
    exit _rc
}
else {
    display as result "✓ Successfully downloaded `dataset'.tsv.gz"
}

// Extract the compressed file
display "Extracting `dataset'.tsv.gz..."
capture shell "$zip_path" e -y "`dataset'.tsv.gz"
if _rc != 0 {
    display as error "Failed to extract `dataset'.tsv.gz"
    exit _rc  
}
else {
    display as result "✓ Successfully extracted `dataset'.tsv"
}


*****************************************************************************
* BATCH DOWNLOAD LOOP (CURRENTLY DISABLED)
*****************************************************************************

/*
// Define list of Eurostat datasets to download
// Add or remove datasets as needed for your project
global eurostat_datasets ///
    nama_10_gdp   /// GDP and main components (ESA10)
    nama_10_a10   /// GDP for 10 industry classifications  
    demo_r_d2jan     // Population on 1 January by age, sex

// Loop through each dataset in the list
foreach dataset of global eurostat_datasets {
    display "Downloading `dataset'..."
    
    // Attempt to download dataset
    capture copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/`dataset'/?format=TSV&compressed=true" "`dataset'.tsv.gz", replace
    
    if _rc == 0 {
        display as result "✓ Download successful for `dataset'"
        
        // Attempt to extract if download succeeded
        capture shell "$zip_path" e -y "`dataset'.tsv.gz"
        if _rc == 0 {
            display as result "✓ `dataset' downloaded and extracted successfully"
            // Optional: Clean up compressed file
            // quietly erase "`dataset'.tsv.gz"
        }
        else {
            display as error "✗ Failed to extract `dataset'.tsv.gz"
        }
    }
    else {
        display as error "✗ Failed to download `dataset' - check dataset code and connection"
    }
    
    // Brief pause between downloads to be respectful to Eurostat servers
    sleep 1000  // 1 second pause
}

display "Batch download process completed."
*/


***************************************************************************
* NEXT STEPS
***************************************************************************
// Data formatting and cleaning will be handled in separate do-file
// Raw TSV files are now ready for processing
display "Raw data download completed. Ready for data formatting stage."


***************************************************************************
* END OF DOWNLOAD SCRIPT
***************************************************************************


/*
* STABLE LINK:
*copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/`x'/?format=TSV&compressed=true" "`x'.tsv.gz", replace
* Replace `x' with the name of the variable in EUROSTAT

* Example: we download nama_10_gdp (GDP and main components)
copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/nama_10_gdp/?format=TSV&compressed=true" "nama_10_gdp.tsv.gz", replace

// Add error handling
capture copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/nama_10_gdp/?format=TSV&compressed=true" "nama_10_gdp.tsv.gz", replace
if _rc != 0 {
    display as error "Failed to download nama_10_gdp data"
    exit _rc
}

* Extract the data
shell "C:\Program Files\7-Zip\7zG.exe" e -y "nama_10_gdp.tsv.gz"

// Check if 7-Zip exists
capture confirm file "C:\Program Files\7-Zip\7zG.exe"
if _rc != 0 {
    display as error "7-Zip not found. Please install or update path."
    exit _rc
}

* LOOP
/*
global eurostat_datasets ///
 nama_10_gdp   /// // GDP and main components (ESA10)
 nama_10_a10   /// // GDP for 10 industry classifications
 demo_r_d2jan      // Population on 1 January by age, sex

foreach dataset of global eurostat_datasets {
	display "Downloading `dataset'..."    // just show the file on the screen
	capture copy "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/`x'/?format=TSV&compressed=true" "`dataset'.tsv.gz", replace

 if _rc == 0 {
        capture shell "$zip_path" e -y "`dataset'.tsv.gz"
        if _rc == 0 {
            display "✓ `dataset' downloaded and extracted successfully"
        }
        else {
            display as error "Failed to extract `dataset'"
        }
    }
    else {
        display as error "Failed to download `dataset'"
    }
}
*/

*****************************************************************************
* FORMATTING DATA FILES
*****************************************************************************
* CLEAN UP THE FILES
* Names of variables
* Getting rid of tect fields in numeric fields
* Getting the data structure right


* NEW DO FILE