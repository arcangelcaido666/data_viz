##############################################################################
# WAGE GAP (2004–2025)
##############################################################################

# 
# 
# 

# - Datos: LAP_2FTM_NOC_RT
#   Brecha de ingresos por género, relación entre el ingreso laboral de las mujeres y el de los hombres

# VARIABLES:
# - País: Argentina (ref_area = 'ARG').
# - Periodo: 2004-2025.
# - X01: World

# libraries
library(showtext)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(ggtext)
require(Rilostat)

toc <- get_ilostat_toc(search = 'LAP_2FTM')

dat <- get_ilostat(id = toc, segment = 'indicator', quiet = TRUE) 
unique(dat$indicator)
unique(dat$time)

# Filter World
dat <- get_ilostat(id = toc,
                   segment = 'indicator',
                   time_format = 'num', 
                   filters = list(ref_area = 'X01', 
                                  timefrom = 2004, 
                                  timeto = 2025))

caption_text <- "**Data:** ILO (SDG_0852_SEX_AGE_RT)  **Plot:** @Angel_SnchzDnl  \n **Notes:** Gender income gap (%): ratio of women’s to men’s labor earnings. Reflects gender disparities in labor income.<br>Values < 100: women earn less than men; 100: parity; values > 100: men earn less than women."

graph <- ggplot(dat, aes(x = time, y = obs_value)) +
  geom_line(color = "#2c3e50", size = 1.2) +
  geom_point(color = "#2c3e50", size = 2) +
  scale_x_continuous(breaks = seq(min(dat$time), max(dat$time), by = 2)) +
  labs(
    title = "Evolution of Gender Wage Ratio (Women/Men) - World",
    subtitle = paste0("Annual data from ", min(dat$time), " to ", max(dat$time)),
    x = "Year",
    y = "Wage Ratio (Women / Men)",
    caption = caption_text,
  ) +
  theme_minimal() +
  theme(
    plot.caption = ggtext::element_markdown(size = 9, color = "grey30"),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )

print(graph)