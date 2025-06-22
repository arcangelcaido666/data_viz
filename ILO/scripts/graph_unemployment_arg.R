##############################################################################
# UNEMPLOYMENT IN ARGENTINA (2000–2025)
##############################################################################

# Evolución de la tasa de desempleo en Argentina para la población de 15 años o más,
# Datos anuales de desempleo (indicador SDG 8.5.2 de la OIT)
# Cambios de gobierno y la evolución del desempleo

# - Datos: SDG_0852_SEX_AGE_RT 
#   Tasa de desempleo (%) según el indicador 8.5.2 de los ODS.
# - Frecuencia: Anual.

# VARIABLES:
# - Edad (classif1):
#   "AGE_YTHADULT_YGE15"  -> Jóvenes y adultos de 15 años o más.
#   "AGE_YTHADULT_Y15-24" -> Jóvenes de 15 a 24 años.
#   "AGE_YTHADULT_YGE25"  -> Adultos de 25 años o más.
# - Sexo (sex):
#   "SEX_T" -> Total (se utiliza esta categoría en el gráfico).
#   "SEX_M" -> Hombres.
#   "SEX_F" -> Mujeres.
# - País: Argentina (ref_area = 'ARG').
# - Periodo: 2000-2025.


# libraries
library(showtext)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(ggtext)
require(Rilostat)


# BUSCAR EL INDICADOR EN LA BASE DE DATOS DE LA OIT
# --------------------------------------------------
# First I search for unemployment
# toc <- get_ilostat_toc(search = 'unemployment rate')
# SDG - Sustainability Development Goals
# toc <- get_ilostat_toc(search = 'SDG indicator')
# I keep the database I need

toc <- get_ilostat_toc(search = 'SDG_0852_SEX_AGE_RT')

# ACCESS DATABASE
# dat <- get_ilostat(id = toc, segment = 'indicator', quiet = TRUE) 
# UNIQUE VALUES
# unique(dat$classif1)
# Keep 15+
# data <- get_ilostat(id = toc,
#                    segment = 'indicator',
#                    time_format = 'num', 
#                    filters = list(ref_area = 'ARG', 
#                                   classif1 = 'AGE_YTHADULT_YGE15',
#                                   sex = 'SEX_T',
#                                   timefrom = 2000, timeto = 2025))

# DESCARGAR LOS DATOS PARA ARGENTINA (2000–2025)
# ----------------------------------------------
# Filters: age 15+, sex total, and period 2000-2025

dat <- get_ilostat(id = toc,
        segment = 'indicator',
        time_format = 'num', 
        filters = list(ref_area = 'ARG', 
                       timefrom = 2000, 
                       timeto = 2025))

# DEFINIR LOS PERÍODOS DE GOBIERNO
# --------------------------------
# Incluye nombre del presidente, partido, sigla, orientación y color para el fondo del gráfico

gov_periods <- data.frame(
  start = c(2000, 2002.01, 2003.41, 2007.94, 2015.94, 2019.94, 2023.94),
  end   = c(2001.97, 2003.41, 2007.94, 2015.94, 2019.94, 2023.94, 2025),
  gov   = c("De la Rúa", "Duhalde", "N. Kirchner", "CF. Kirchner",
            "M. Macri", "A. Fernández", "J. Milei"),
  party = c("Alianza", "PJ", "PJ", "FpV", "Cambiemos", "FdT", "LLA"),
  sigla = c("Alianza", "PJ", "FpV", "FpV", "Cambiemos", "FdT", "LLA"),
  orientation = c("centro-derecha", "centro-izquierda", "centro-izquierda", 
                  "centro-izquierda", "centro-derecha", "centro-izquierda", "derecha libertaria"),
  color = c("#ADD8E6", "#FFCCCC", "#FFCCCC", "#FFCCCC", "#ADD8E6", "#FFCCCC", "#D8BFD8") # azul claro, rojo claro, morado claro
) %>%
  mutate(label = paste(gov, sigla, sep = "\n"))


# Calcula el mínimo y máximo del área coloreada (la tasa de desempleo)
y_min <- min(data$obs_value, na.rm = TRUE)
y_max <- max(data$obs_value, na.rm = TRUE)

gov_periods <- gov_periods %>%
  mutate(y_pos = y_max)  # (dentro área coloreada)

gov_periods <- gov_periods %>%
  mutate( # Posición horizontal con desplazamientos para el primer y último gobierno
    x_pos = case_when(
      row_number() == 1 ~ (start + end) / 2 - 0.6,  # mover a la izquierda
      row_number() == n() ~ (start + end) / 2 + 0.6, # mover a la derecha
      TRUE ~ (start + end) / 2
    )
  )

# GRAPH
# ----------------
graph <- ggplot(data, aes(x = time, y = obs_value)) +
  # Fondo coloreado según orientación política
  geom_rect(data = gov_periods, inherit.aes = FALSE,
            aes(xmin = start, xmax = end, ymin = -Inf, ymax = Inf, fill = gov),
            alpha = 0.25) +
  # Línea de desempleo
  geom_line(color = "#2c3e50", size = 1) +
  # Líneas verticales en cambios de gobierno (excepto el primero)
  geom_vline(xintercept = gov_periods$start[-1], linetype = "dashed", color = "grey30", size = 0.5) +
  # Anotaciones con el nombre del partido
  geom_text(data = gov_periods, inherit.aes = FALSE,
            aes(x = x_pos, y = y_pos + 1, label = label),
            size = 3, angle = 0, vjust = 1, hjust = 0.5, color = "black") + 
  coord_cartesian(clip = "off") +
  # Escala de colores personalizada
  scale_fill_manual(values = setNames(gov_periods$color, gov_periods$gov)) +
  # Ejes y etiquetas
  scale_x_continuous(breaks = seq(2000, 2025, 5)) +
  labs(
    title = "Unemployment Rate in Argentina (Age 15+)",
    subtitle = "Annual series from 2000 to 2025",
    x = "Year", y = "Unemployment Rate (%)",
    caption = "**Data:** ILO (SDG_0852_SEX_AGE_RT)  **Plot:** @Angel_SnchzDnl  **Notes:** Colors by political orientation"
  ) +
  theme_minimal()+
  theme(legend.position = "none",
        plot.caption = ggtext::element_markdown(size = 9, color = "grey30"),
        plot.margin = margin(t = 10, r = 10, b = 10, l = 10)  # top, right, bottom, left (en puntos)
  )

print(graph)

# GUARDAR COMO IMAGEN
# -------------------
ruta <- "C:/Users/angel/Documents/data_viz/ILO/graphs/grah_unemployment_arg.png"

# Guardar como PNG
ggsave(filename = ruta, plot = graph, width = 10, height = 6, units = "in", dpi = 300,
       bg = "white"  # ✅ Fondo blanco
)
