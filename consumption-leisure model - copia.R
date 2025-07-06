# Labor Economics: Consumption-Leisure Trade-off Graph

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

# Budget constraint: C = wL + Y, where L = total_time - leisure
# Rearranged: C = w(total_time - leisure) + Y = w*total_time + Y - w*leisure
max_consumption <- wage_rate * total_time + non_labor_income
slope_budget <- -wage_rate

# Create data for budget constraint
leisure <- seq(0, total_time, 0.001)
consumption_budget <- max_consumption + slope_budget * leisure

budget_data <- data.frame(
  leisure = leisure,
  consumption = consumption_budget
) %>%
  filter(consumption >= 0)  # Only positive consumption

# Create indifference curves
create_indifference_curve <- function(utility_level, alpha, beta, leisure_range) {
  leisure_vals <- seq(0.5, max(leisure_range), 0.001)
  # From U = C^α * L^β, we get C = (U / L^β)^(1/α)
  consumption_vals <- (utility_level / (leisure_vals^beta))^(1/alpha)
  
  data.frame(
    leisure = leisure_vals,
    consumption = consumption_vals,
    utility = utility_level
  ) %>%
    filter(consumption > 0, consumption < max_consumption * 1.2)
}

# Find optimal point (tangency condition)
# At optimum: MRS = wage rate
# MRS = (∂U/∂L)/(∂U/∂C) = (β*C)/(α*L) = wage_rate
# Combined with budget constraint: C = w*(total_time - L) + Y
# Solving: optimal_leisure = (β*(w*total_time + Y))/(α*w + β*w)
optimal_leisure <- (beta * max_consumption) / (wage_rate * (alpha + beta))
optimal_consumption <- max_consumption + slope_budget * optimal_leisure
optimal_utility <- (optimal_consumption^alpha) * (optimal_leisure^beta)

# Create indifference curves
utility_levels <- c(optimal_utility * 0.75, optimal_utility, optimal_utility * 1.2)
indiff_curves <- map_dfr(utility_levels, ~create_indifference_curve(.x, alpha, beta, leisure))

# Create the plot
p <- ggplot() +
  # Custom axes with large arrows
  geom_segment(aes(x = 0, y = 0, xend = total_time + 2, yend = 0), 
               arrow = arrow(length = unit(0.5, "cm"), type = "closed"), 
               color = "black", linewidth = 1.2) +
  geom_segment(aes(x = 0, y = 0, xend = 0, yend = max_consumption + 60), 
               arrow = arrow(length = unit(0.5, "cm"), type = "closed"), 
               color = "black", linewidth = 1.2) +
  # Budget constraint
  geom_line(data = budget_data, aes(x = leisure, y = consumption), 
            color = "red", linewidth = 1.2, linetype = "solid") +
  
  # Indifference curves
  geom_line(data = indiff_curves, aes(x = leisure, y = consumption, group = utility), 
            color = "blue", linewidth = 0.8, alpha = 0.8) +
  
  # Optimal point
  geom_point(aes(x = optimal_leisure, y = optimal_consumption), 
             color = "darkgreen", size = 4, shape = 19) +
  
  # Axis labels (X and Y)
  annotate("text", x = total_time + 1.5, y = -20, label = "X", 
           size = 8, fontface = "bold", color = "black") +
  annotate("text", x = -1.5, y = max_consumption + 45, label = "Y", 
           size = 8, fontface = "bold", color = "black") +
  
  # Axes intercepts points
  geom_point(aes(x = 0, y = max_consumption), color = "red", size = 3, shape = 17) +
  geom_point(aes(x = total_time, y = non_labor_income), color = "red", size = 3, shape = 17) +
  
  # Labels and annotations
  annotate("text", x = optimal_leisure + 1.5, y = optimal_consumption + 20, 
           label = "Optimal Choice\n(Tangency Point)", 
           hjust = 0, vjust = 0, size = 3.5, color = "darkgreen", fontface = "bold") +
  
  annotate("text", x = 2, y = max_consumption - 30, 
           label = paste("Budget Constraint\nC = ", max_consumption, " - ", wage_rate, "L"), 
           hjust = 0, vjust = 1, size = 3, color = "red") +
  
  annotate("text", x = 18, y = 50, 
           label = "Indifference Curves\n(Higher utility →)", 
           hjust = 0, vjust = 0, size = 3, color = "blue") +
  
  # annotate("text", x = 1, y = max_consumption + 10, 
  #          label = paste("Max consumption\n(", max_consumption, ")"), 
  #          hjust = 0, vjust = 0, size = 2.5, color = "red") +
  # 
  # annotate("text", x = total_time - 1, y = non_labor_income + 15, 
  #          label = paste("Pure leisure\n(", non_labor_income, ")"), 
  #          hjust = 1, vjust = 0, size = 2.5, color = "red") +
  # 
  # Arrow pointing to higher utility
  annotate("segment", x = 16, y = 80, xend = 14, yend = 120, 
           arrow = arrow(length = unit(0.3, "cm")), color = "blue", alpha = 0.7) +
  
  # Formatting
  labs(
    title = "Labour Economics: Consumption-Leisure Model",
    # subtitle = paste("Wage rate = $", wage_rate, "/hour, Non-labor income = $", non_labor_income),
    x = "Leisure (hours)",
    y = "Consumption ($)",
    # caption = "The optimal choice occurs where the indifference curve is tangent to the budget constraint"
  ) +
  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.title = element_text(size = 11, face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.5)
  ) +
  
  xlim(0, total_time + 1) +
  ylim(0, max_consumption + 50)

# Display the plot
print(p)

# Print optimal values
cat("\n=== OPTIMAL SOLUTION ===\n")
cat("Optimal leisure hours:", round(optimal_leisure, 2), "\n")
cat("Optimal labor hours:", round(total_time - optimal_leisure, 2), "\n")
cat("Optimal consumption: $", round(optimal_consumption, 2), "\n")
cat("Labor income: $", round(wage_rate * (total_time - optimal_leisure), 2), "\n")
cat("Total income: $", round(wage_rate * (total_time - optimal_leisure) + non_labor_income, 2), "\n")
cat("Utility level:", round(optimal_utility, 2), "\n")

# Additional analysis: Effect of wage changes
cat("\n=== SENSITIVITY ANALYSIS ===\n")
wage_rates <- c(10, 15, 20, 25)
for(w in wage_rates) {
  max_c <- w * total_time + non_labor_income
  opt_l <- (beta * max_c) / (w * (alpha + beta))
  opt_c <- max_c - w * opt_l
  cat("Wage $", w, ": Leisure =", round(opt_l, 2), 
      "hrs, Labor =", round(total_time - opt_l, 2), 
      "hrs, Consumption = $", round(opt_c, 2), "\n")
}