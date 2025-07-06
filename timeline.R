# Línea del tiempo básica

# libraries
library(ggplot2)
library(dplyr)

# Datos

timeline_data <- tibble::tibble(
  autor = c("Keynes", "Friedman", "Becker", "Lucas", "Card & Krueger", "Pissarides"),
  año   = c(1936, 1968, 1973, 1976, 1994, 2000),
  idea  = c(
    "Demanda efectiva y empleo",
    "Curva de Phillips con expectativas",
    "Capital humano y teoría del hogar",
    "Expectativas racionales",
    "Salario mínimo y empleo",
    "Modelos de búsqueda y emparejamiento"
  ),
  era = c("Keynesiana", "Monetarista", "Chicago / Neoclásica", "Neoclásica", "Nueva economía laboral", "Matching models"),
  y_text = c(0.03, 0.03, 0.025, 0.02, 0.03, 0.02)  # algunos desplazados para evitar solapamiento
)

# Paleta de colores para eras (puedes ajustarla)
colores_era <- c(
  "Keynesiana" = "#a1c9f4",
  "Monetarista" = "#ffb482",
  "Neoclásica" = "#8de5a1",
  "Empírica moderna" = "#ff9f9b"
)

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


# Primer gráfico
ggplot(timeline_data, aes(x = año, y = 0)) +
  geom_segment(aes(xend = año, ymin = -2, ymax = 2), color = "grey") + # Rango de los ejes
  geom_rect(aes(xmin = año - 1, xmax = año + 1, ymin = 0.3, ymax = -0.3, fill = era)) + # Rectangulos
  geom_point(size = 2, color = "#E63946") + #Puntos y tamaño
  
  # Texto autor y comentario
  geom_text(aes(y = y_text, label = autor), vjust = -1, size = 3, fontface = "bold") +
  geom_text(aes(y = y_text, label = idea), vjust = 2.5, size = 2, color = "grey20") +
  
  # Tema y etiquetas
  theme_minimal() +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none"  # Sin leyenda
  ) +
  scale_fill_manual(values = colores_era) +
  labs(
    title = "Labour economics",
    subtitle = "History of main authors", 
    x = "Year"
  )

