# Labor Supply curve: Backward Bending effect

library(ggplot2)
library(dplyr)
library(purrr)

# Parameters
total_time <- 24  # Total time available (hours)
wage_rate <- 15   # Hourly wage rate
non_labor_income <- 100  # Non-labor income (e.g., benefits, transfers)
# Utility function parameters (Cobb-Douglas: U = C^α * L^β)
alpha <- 0.6  # Weight on consumption
beta <- 0.4   # Weight on leisure

# Different wage rates to show backward bending
wage_rates <- c(5, 10, 15, 20, 25, 35, 50)
colors <- c("#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FECA57", "#FF9FF3", "#6C5CE7")

# Function to create budget constraint data
create_budget_data <- function(wage, total_time, non_labor_income) {
  leisure <- seq(0, total_time, 0.01)
  max_consumption <- wage * total_time + non_labor_income
  consumption <- max_consumption - wage * leisure
  
  return(list(
    leisure = optimal_leisure,
    consumption = optimal_consumption,
    labor = optimal_labor,
    utility = optimal_utility,
    wage = wage
  ))
}

# Function to create indifference curve for specific utility level
create_indifference_curve <- function(utility_level, alpha, beta, leisure_range) {
  leisure_vals <- seq(0.5, max(leisure_range) * 0.9, 0.01)
  consumption_vals <- (utility_level / (leisure_vals^beta))^(1/alpha)
  
  data.frame(
    leisure = leisure_vals,
    consumption = consumption_vals,
    utility = utility_level
  ) %>%
    filter(consumption > 0, consumption < 1000, leisure > 0)
}

# Generate all budget constraints using base R
budget_list <- lapply(wage_rates, function(w) create_budget_data(w, total_time, non_labor_income))
all_budgets <- do.call(rbind, budget_list)

# Find all optimal points
optimal_points <- map_dfr(wage_rates, function(w) {
  opt <- find_optimal_point(w, total_time, non_labor_income, alpha, beta)
  data.frame(
    leisure = opt$leisure,
    consumption = opt$consumption,
    labor = opt$labor,
    utility = opt$utility,
    wage = opt$wage
  )
})

# Create indifference curves for each optimal point
all_indiff_curves <- map_dfr(1:nrow(optimal_points), function(i) {
  utility_level <- optimal_points$utility[i]
  wage <- optimal_points$wage[i]
  curve <- create_indifference_curve(utility_level, alpha, beta, c(0, total_time))
  curve$wage <- wage
  return(curve)
})

# Create the main consumption-leisure plot
p1 <- ggplot() +
  # Custom axes with arrows
  geom_segment(aes(x = 0, y = 0, xend = total_time + 1, yend = 0), 
               arrow = arrow(length = unit(0.4, "cm"), type = "closed"), 
               color = "black", linewidth = 1) +
  geom_segment(aes(x = 0, y = 0, xend = 0, yend = max(all_budgets$consumption) + 100), 
               arrow = arrow(length = unit(0.4, "cm"), type = "closed"), 
               color = "black", linewidth = 1) +
  
  # Budget constraints
  geom_line(data = all_budgets, aes(x = leisure, y = consumption, color = factor(wage)), 
            linewidth = 1.2, alpha = 0.8) +
  
  # Indifference curves
  geom_line(data = all_indiff_curves, aes(x = leisure, y = consumption, color = factor(wage)), 
            linewidth = 0.8, alpha = 0.6, linetype = "dashed") +
  
  # Optimal points
  geom_point(data = optimal_points, aes(x = leisure, y = consumption, color = factor(wage)), 
             size = 4, alpha = 0.9) +
  
  # Connect optimal points to show income-consumption curve
  geom_path(data = optimal_points, aes(x = leisure, y = consumption), 
            color = "black", linewidth = 1.5, alpha = 0.7, linetype = "dotdash") +
  
  # Axis labels
  annotate("text", x = total_time + 0.5, y = -30, label = "Leisure", 
           size = 5, fontface = "bold") +
  annotate("text", x = -1, y = max(all_budgets$consumption) + 80, label = "Consumption", 
           size = 5, fontface = "bold") +
  
  # Annotations
  annotate("text", x = 18, y = 800, 
           label = "Higher wages →", 
           size = 4, fontface = "bold", color = "darkblue") +
  annotate("text", x = 12, y = 400, 
           label = "Income-Consumption\nCurve", 
           size = 3.5, fontface = "bold", color = "black") +
  
  scale_color_manual(values = colors, name = "Wage Rate", 
                     labels = paste("$", wage_rates)) +
  
  labs(title = "Consumption-Leisure Choice at Different Wage Rates",
       subtitle = "Multiple Budget Constraints and Utility Maximization") +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  ) +
  
  xlim(-1.5, total_time + 1) +
  ylim(-50, max(all_budgets$consumption) + 100)

# Create labor supply curve (showing backward bending)
p2 <- ggplot(optimal_points, aes(x = labor, y = wage)) +
  # Custom axes with arrows
  geom_segment(aes(x = 0, y = 0, xend = max(optimal_points$labor) + 2, yend = 0), 
               arrow = arrow(length = unit(0.4, "cm"), type = "closed"), 
               color = "black", linewidth = 1) +
  geom_segment(aes(x = 0, y = 0, xend = 0, yend = max(wage_rates) + 5), 
               arrow = arrow(length = unit(0.4, "cm"), type = "closed"), 
               color = "black", linewidth = 1) +
  
  # Labor supply curve
  geom_path(color = "red", linewidth = 2.5, alpha = 0.8) +
  geom_point(size = 4, color = "darkred", alpha = 0.8) +
  
  # Highlight backward bending part
  geom_path(data = optimal_points[optimal_points$wage >= 20,], 
            aes(x = labor, y = wage), color = "purple", linewidth = 3, alpha = 0.9) +
  
  # Axis labels
  annotate("text", x = max(optimal_points$labor) + 1, y = -2, label = "Labor Hours", 
           size = 5, fontface = "bold") +
  annotate("text", x = -0.8, y = max(wage_rates) + 3, label = "Wage Rate", 
           size = 5, fontface = "bold") +
  
  # Annotations
  annotate("text", x = max(optimal_points$labor) - 3, y = 40, 
           label = "Backward\nBending\nRegion", 
           size = 4, fontface = "bold", color = "purple", hjust = 0.5) +
  annotate("text", x = 8, y = 15, 
           label = "Normal\nUpward\nSloping", 
           size = 4, fontface = "bold", color = "red", hjust = 0.5) +
  
  # Arrow pointing to backward bending region
  annotate("segment", x = max(optimal_points$labor) - 1, y = 35, 
           xend = max(optimal_points$labor) - 0.5, yend = 45, 
           arrow = arrow(length = unit(0.3, "cm")), color = "purple", linewidth = 1.2) +
  
  labs(title = "Derived Labor Supply Curve",
       subtitle = "Shows Backward Bending at High Wages") +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  ) +
  
  xlim(-1, max(optimal_points$labor) + 2.5) +
  ylim(-3, max(wage_rates) + 5)

# Display both plots
print(p1)
cat("\n\nPress Enter to see the derived labor supply curve...")
readline()
print(p2)

# Print analysis
cat("\n=== LABOR SUPPLY ANALYSIS ===\n")
cat("Wage Rate | Labor Hours | Leisure Hours | Effect\n")
cat("----------|-------------|---------------|---------\n")
for(i in 1:nrow(optimal_points)) {
  effect <- if(i == 1) "Initial" else {
    if(optimal_points$labor[i] > optimal_points$labor[i-1]) "Substitution dominates" else "Income effect dominates"
  }
  cat(sprintf("$%-8.0f | %-11.2f | %-13.2f | %s\n", 
              optimal_points$wage[i], optimal_points$labor[i], 
              optimal_points$leisure[i], effect))
}

cat("\n=== KEY INSIGHTS ===\n")
cat("1. At low wages: Substitution effect dominates → More work\n")
cat("2. At high wages: Income effect dominates → Less work (more leisure)\n")
cat("3. Backward bending occurs when income effect > substitution effect\n")
cat("4. This explains why very high earners may work fewer hours\n")

