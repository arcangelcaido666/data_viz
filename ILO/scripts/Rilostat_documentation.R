# ILOSTAT BULK DOWNLOAD

# RILOSTAT PACKAGE

# This R package provides tools to access, download and work with the data contained in ILOSTAT, the ILO Department of Statistics’ online database. ILOSTAT’s data and related metadata are also directly available through ILOSTAT’s website.
# For more information on ILOSTAT’s R package, including contact details and source code, refer to its github page.
install.packages("ggplot2")
install.packages("dplyr")
#############################################################
# INSTALLATION
###########################################################

# Install package
# install.packages("Rilostat")

# Developers version
# if(!require(devtools)){install.packages('devtools')}
# install_github("ilostat/Rilostat")

###################################################
# RUN PACKAGE
######################################################

# The ilostat R package ('Rilostat') includes the following functions:
require(Rilostat)

###################################
##  Basic commands
########################################

as.data.frame(ls("package:Rilostat"))

# Essential functionality
# get_ilostat_toc()
# 
# Read Ilostat Table of Contents
# get_ilostat()
# 
# Read Ilostat Data
# get_ilostat_dic()
# 
# Read Ilostat Dictionary
# label_ilostat()
# 
# Switch Ilostat codes and labels
# clean_ilostat_cache()
# 
# Clean Ilostat Cache
# distribution_ilostat()
# 
# Switch ilostat to distribution
# dataexplorer()
# 
# Play with ilostat data explorer
# Rilostat

###########################################3
# SEARCH FOR DATA
#############################################33
# get_ilostat_toc() provides grep style searching of all available indicators from ILOSTAT’s bulk download facility and returns the indicators matching your query. get_ilostat_toc(segment = 'ref_area') returns the datasets available by ref_area (‘country’ and ‘region’).
toc <- get_ilostat_toc()

# All settings are available in the 3 official languages of the ILO: English ('en'), French ('fr') and Spanish ('es'). The default is 'en'.
#For instance, to access the table of contents of all available datasets by reference area in ILOSTAT in Spanish:
toc <- get_ilostat_toc(segment = 'ref_area', lang = 'es')


#You can search for words or expressions within the table of contents listing all of ILOSTAT’s indicators.
#For example, searching for the word “bargaining” will return the indicators containing that word somewhere in the indicator information:
toc <- get_ilostat_toc(search = 'bargaining')

#What about union?
toc <- get_ilostat_toc(search = 'union')
# Just trade union density, perfect

# More specifications
toc <- get_ilostat_toc(segment = 'ref_area', search = c('France|Albania', 'Annual'), 
                       fixed = FALSE)

#
#You can also manipulate ILOSTAT’s table of contents’ dataframe using the basic R filter. If you are already familiar with ILOSTAT data and the way it is structured, you can easily filter what you want.
#For example, if you know beforehand you want data only from ILOSTAT’s Short Term Indicators dataset (code “STI”) and you are only interested in monthly data (code “M”) you can simply do:
  
toc <-  dplyr::filter(get_ilostat_toc(), collection == 'STI', freq == 'M')


###########################################################################
# DOWNLOAD DATA
##############################################################################3
#The function get_ilostat() explores ILOSTAT’s datasets and returns datasets by indicator (default, segment indicator) or by reference area (segment ref_area). The id of each dataset is made up by the code of the segment chosen (indicator code or reference area code) and the code of the data frequency required (annual, quarterly or monthly), joined by an underscore.

# SINGLE DATASET
#  As stated above, you can easily access the single dataset of your choice through the get_ilostat() function, by indicating the code of the dataset desired (indicator_frequency or ref_area_frequency).

#If you want to access annual data for indicator code UNE_2UNE_SEX_AGE_NB, you should type:
dat <- get_ilostat(id = 'UNE_2UNE_SEX_AGE_NB_A', segment = 'indicator') 

#If you want to access all annual data available in ILOSTATfor Armenia:
dat <- get_ilostat(id = 'ARM_A', segment = 'ref_area') 

# MULTIPLE DATASETS

dat <- get_ilostat(id = c('AFG_A', 'TTO_A'), segment = 'ref_area') 

dplyr::count(dat, ref_area)
toc <- get_ilostat_toc(search = 'CPI_')
dat <- get_ilostat(id = toc, segment = 'indicator', quiet = TRUE) 
dplyr::count(dat, indicator)

#########################################################################
# TIME FORMAT
##########################################################################
# The function get_ilostat() will return time period information by default in a raw time format (time_format = 'raw'), which is a character vector with the following syntax:
#   
#   Yearly data: 'YYYY' where YYYY is the year.
#   Quarterly data: 'YYYYqQ' where YYYY is the year and Q is the quarter (the number corresponding to the quarter from 1 to 4).
#   Monthly data: 'YYYYmMM' where YYYY is the year and MM is the month (the number corresponding to the month from 01 to 12).
# 
# To ease the use of data for plotting or time-series analysis techniques, the function can also return POSIXct dates (using time_format = 'date') or numeric dates (using time_format = 'num').
# For instance, the following will return quarterly unemployment data by sex and age, with the time dimension in numeric format:
  
dat <- get_ilostat(id = 'UNE_TUNE_SEX_AGE_NB_Q', time_format = 'num') 

# The following will return monthly time-related underemployment data by sex and age, with the time dimension in POSIXct date format:
dat <- get_ilostat(id = 'TRU_TTRU_SEX_AGE_NB_M', time_format = 'date') 


##############################################################################
# SAVE DATA
###############################################################################
# the function get_ilostat() stores cached data by default at file.path(tempdir(), "ilostat") in rds binary format.
# 
# However, via the cache_dir arguments, it is also possible to choose a different work directory to store data in, and via the cache_format arguments you can save it in other formats, such as csv, dta, sav, and sas7bdat.
dat <- get_ilostat(id = 'TRU_TTRU_SEX_AGE_NB_M', cache_dir = 'c:/temp', cache_format = 'dta') 


# hese arguments can also be set using options(ilostat_cache_dir = 'C:/temp') and options(ilostat_cache_format = 'dta').
# 
# The name of the cache file is built using paste0(segment, "-", id, "-", type,"-",time_format, "-", last_toc_update ,paste0(".", cache_format)), with ‘last_toc_update’ being the latest update of the dataset from the table of contents.
# 
# With the argument back = FALSE, datasets are downloaded and cached without being returned in R. This quiet setting is convenient particularly when downloading large amounts of data or datasets.
# 
get_ilostat(id = get_ilostat_toc(search = 'SDG'),   cache_dir = 'c:/temp', cache_format = 'dta', 
            back = FALSE) 

# CONCLUSION IS NOT NECESSARY TO DOWNLOAD THE DATA BUT YOU CAN DO IT
# EVEN YOU CAN DO IT IN A .DTA FORMAT (READEABLE IN STATA)

###############################################################################
# FILTER DATA
##############################################################################3
# Once you have retrieved and/or cached the dataset(s) you need, advanced filters can help you refine your data selection and facilitate reproducible analysis. You can apply several different filters to your datasets, to filter the data by reference area, sex, classification item, etc.
# 
# options(ilostat_cache_dir = 'C:/temp')
dat <- get_ilostat(id = 'UNE_2EAP_SEX_AGE_RT_A', filters = list(
  ref_area = c('BRA', 'ZAF'), 
  sex = 'T', 
  classif1 = 'AGE_YTHADULT_Y15-24'))
dplyr::count(dat, ref_area, sex, classif1)

################################################################################
# PLOT DATA
################################################################################

require(ggplot2, quiet = TRUE)
require(dplyr, quiet = TRUE)


get_ilostat(id = 'EAP_DWAP_SEX_AGE_RT_A', 
            time_format = 'num', 
            filters = list( ref_area = c('FRA', 'USA', 'DEU'), 
                            sex = 'SEX_M',
                            classif1 = 'AGE_AGGREGATE_TOTAL',
                            timefrom = 2005, timeto = 2019))  %>% 
  select(ref_area, time, obs_value) %>% 
  ggplot(aes(x = time, y = obs_value, colour = ref_area)) + 
  geom_line() + 
  ggtitle('Male labour force participation rate in selected countries, 2005-2019') + 
  scale_x_continuous(breaks = seq(2005, 2017, 3)) +
  labs(x="Year", y="Male LFPR (%)", colour="Country:") +  
  theme(legend.position = "top", plot.title = element_text(hjust = 0.5))