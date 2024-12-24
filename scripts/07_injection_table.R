## This script creates an injection table giving the predicted amount of
## insulin to inject based on glucose intake and desired change in glycemia.

rm(list = ls())

library(tidyverse)

source("scripts/functions/Prediction.R")

# Create a table
data <- expand_grid(
  Glucose = seq(0, 100, 5),
  Delta = seq(-300, 300, 50),
  State = c("normal", "activity", "alcohol", "sick"),
  Time = c("1.5", "2.0", "3.0")
)

# Load the parameters
pars1.5 <- read_csv("data/parameters/parameters_1_5.csv")
pars2.0 <- read_csv("data/parameters/parameters_2_0.csv")
pars3.0 <- read_csv("data/parameters/parameters_3_0.csv")

# Compute insulin needed
data <- data %>% 
  mutate(
    Insulin = pmap_dbl(
      list(Glucose, Delta, State, Time), 
      function(glucose, delta, state, time) {
      
        # Predict insulin needed
        predict_insulin(glucose, delta, state = state, pars = get(str_c("pars", time)))
      
      }
    )
  )

# Plot
plot <- data %>%
  mutate(TimeLab = str_c("Threshold = ", str_remove(Time, ".0"), "hr")) %>%
  ggplot(aes(x = Glucose, y = Insulin, color = Delta)) +
  geom_point() +
  facet_grid(State ~ TimeLab) +
  scale_color_gradient2(low = "blue", mid = "black", high = "red", guide = "legend", name = "Change in\nglycemia\n(mg/dL)") +
  ylim(c(0, NA)) +
  xlab("Glucose (g)") +
  ylab("Insulin (units)")

# Note: it looks like three hours gives the most reasonable estimates of how
# much insulin to inject (based on personal experience).

# Plot
plot_3hr <- data %>%
  filter(Time == "3.0") %>%
  ggplot(aes(x = Glucose, y = Insulin, color = Delta)) +
  geom_point() +
  facet_wrap(State ~ .) +
  scale_color_gradient2(low = "blue", mid = "black", high = "red", guide = "legend", name = "Change in\nglycemia\n(mg/dL)") +
  ylim(c(0, NA)) +
  xlab("Glucose (g)") +
  ylab("Insulin (units)") +
  ggtitle("Threshold = 3hr")

# Note: plus, there is no big difference between the states.

# Save the plots of the injection table
ggsave("plots/injection_table.png", plot, width = 5, height = 5, dpi = 300)
ggsave("plots/injection_table_3hr.png", plot_3hr, width = 5, height = 5, dpi = 300)

# Make final injection table
injection_table <- data %>% 
  filter(Time == "3.0", State == "normal") %>% 
  select(Glucose, Delta, Insulin) %>%
  mutate(Insulin = if_else(Insulin < 0, NA, Insulin)) %>%
  pivot_wider(names_from = Delta, values_from = Insulin)

# Save
write_csv(injection_table, "data/injection_table.csv")
