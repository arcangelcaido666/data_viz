# Línea del tiempo básica

# libraries
library(ggplot2)
library(dplyr)
library(grid)
library(png)  # o jpeg si la imagen es .jpg
library(jpeg)

# Datos
timeline_data <- tibble::tibble(
  autor = c("Adam Smith", "David Ricardo", "Karl Marx",
            "Alfred Marshall", "Keynes", "Becker", "Becker", 
            "Mincer", "Heckman", "Card & Krueger", "Goldin"),
  año   = c(1776, 1817, 1867, 1890, 1936, 1957, 1964, 1974, 1979, 1992, 2021),
  idea  = c(
    "The Wealth of Nations (1776)",
    "Principles of Political Economy and Taxation (1817)",
    "Das Kapital (1867)",
    "Priniples of Economics (1890)", 
    "The General Theory of Employment, Interest and Money (1936)",
    "The Economics of Discrimination (1957)",
    "Human Capital (1964)",
    "Schooling, Experience, and Earnings (1974)",
    "Sample Selection Bias as a Specification Error (1979)",
    "Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania (1992)",
    "Career and Faimly (2021)"
  ),
  y_text = c(1, -1, 1, -1, 1, 1.5, 1.75, -1.5, -1, 1.2, 1.5)  # algunos desplazados para evitar solapamiento
)

# Eras únicas con duración
eras_data <- tibble::tibble(
  era = c("Classics", "Neoclassical Economy", "Keynesianism and unemployment", 
          "Human Capital, Discrimination, supply of work", "Applied microeconometrics & Causal Inference",
          "Gender, inequality"),
  inicio_era = c(1770, 1870, 1930, 1960, 1980, 2000),
  fin_era = c(1870, 1930, 1960, 1980, 2000, 2025)
)

# Datos de Nobel (añades más si quieres)
nobel_data <- tibble::tibble(
  autor = c("Becker", "Heckman", "Card", "Goldin"),
  año = c(1992, 2000, 2021, 2023),
  motivo = c("Nobel 1992", "Nobel 2000", "Nobel 2021", "Nobel 2023"),
  y_text = c(-2, -2, -2, -2)
)

# Paleta de colores para las eras
colores_era <- c(
  "Classics" = "#ffb482",
  "Neoclassical Econommy" = "#9d9dc7",
  "Keynesianism and unemployment" = "#a1c9f4",
  "Human Capital, Discrimination, supply of work" = "#ffb482",
  "Applied microeconometrics & Causal Inference" = "#ff9f9b",
  "Gender, inequality" = "#9d9dc7"
)


# Imagenes
img_becker <- readPNG("becker.png")  # Asegúrate de tener el archivo en tu directorio de trabajo
g_becker <- rasterGrob(img_becker, interpolate = TRUE)

# Primer gráfico
ggplot(timeline_data, aes(x = año, y = 0)) +
  geom_segment(aes(xend = año, ymin=-2, ymax=2), color = "grey") + # Rango de los ejes
  geom_point(size = 2, color = "#E63946") + # Puntos y tamaño
  geom_text(aes(label = autor), vjust = -1, size = 3, fontface = "bold") + # Autores
  geom_text(aes(label = idea), vjust = 2.5, size = 2, color = "grey20") + # Comentarios
  theme_minimal() + # Theme minimal (Sin colores)
  theme( #Eliminar loe ejes, texto y grid
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Labour economics",
    subtitle = "History of main authors", 
    x = "Year"
  )


# Gráfico # 3
ggplot(timeline_data, aes(x = año, y = 0)) +
  geom_segment(aes(xend = año, ymin = -2, ymax = 2), color = "grey") + #Rango de los ejes
  geom_rect(data = eras_data,
            aes(xmin = inicio_era, xmax = fin_era, ymin = 0.3, ymax = -0.3, fill = era),
            inherit.aes = FALSE) + # Bloques linea investigación
  geom_segment(aes(x = año, xend = año, y = 0, yend = y_text * 0.8), 
               color = "black", linewidth = 0.2, linetype = "solid") + #Línea que conecta los autores con el tiempo
  geom_point(size = 2, color = "#E63946") +  #Puntos y tamaño
  geom_text(aes(y = y_text, label = autor), size = 3, fontface = "bold") +
  geom_text(aes(y = y_text, label = idea), vjust = 2.5, size = 2, color = "grey20") +
  geom_point(data = nobel_data, aes(x = año, y = y_text), color = "#1f77b4", size = 2) +
  geom_text(data = nobel_data, aes(x = año, y = y_text, label = motivo), 
            vjust = 1.5, size = 2.5, color = "#1f77b4") +
  annotation_custom(g_becker, xmin = 1960, xmax = 1968, ymin = 1.78, ymax = 2) + # Imagenes
  theme_minimal() + # Theme minimal (sin colores)
  theme( #Eliminar ejes, grid, títulos
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  scale_fill_manual(values = colores_era) + #Colores bloques
  labs(
    title = "Labour economics",
    subtitle = "History of main authors", 
    x = "Year"
  )

# Gráfico desde Becker
