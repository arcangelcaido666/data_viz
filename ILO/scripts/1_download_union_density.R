# DOWNLOAD UNION DENSITY

install.packages("tidyverse") 
library(tidyverse)

# RUN RILOSTAT
require(Rilostat)

# SEARCH FOR DATABASE
toc <- get_ilostat_toc(search = 'union')

# ACCESS DATABASE
dat <- get_ilostat(id = toc, segment = 'indicator', quiet = TRUE) 
#ILR_TUMT_NOC_RT

#CHECK TIME FORMAT
# Better without changing the format
# dat <- get_ilostat(id = toc, segment = 'indicator', quiet = TRUE, time_format = 'date') 

# FILTER DATA

require(ggplot2, quiet = TRUE)
require(dplyr, quiet = TRUE)

get_ilostat(id = toc,
            segment = 'indicator',
            time_format = 'num', 
            filters = list(ref_area = c('DEU', 'USA', 'ESP'), 
                          timefrom = 2005, timeto = 2019))  %>% 
  select(ref_area, time, obs_value) %>% 
  ggplot(aes(x = time, y = obs_value, colour = ref_area)) + 
  geom_line() + 
  ggtitle('Union density') + 
  scale_x_continuous(breaks = seq(2005, 2017, 3)) +
  labs(x="Year", y="Union density (%)", colour="Country:") +  
  theme(legend.position = "top", plot.title = element_text(hjust = 0.5))
