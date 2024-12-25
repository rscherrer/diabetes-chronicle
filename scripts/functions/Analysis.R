# Functions to extract relevant intercepts and slopes
get_intercept <- function(fit) coef(fit) %>% {.[1] + ifelse(length(.) > 2L, .[3], 0)} 
get_slope <- function(fit) coef(fit) %>% {.[2] + ifelse(length(.) > 2L, .[4], 0)} 

# Function to compute the key parameters
compute_parameters <- function(data) {
  
  # Filter out what we do not want in our analyses
  data <- filter_dataset(data)
  
  # Fit models
  fits <- with(data, list(
    lm(ScaledGlycemiaChange ~ Ratio),
    lm(ScaledGlycemiaChange ~ Ratio * Activity),
    lm(ScaledGlycemiaChange ~ Ratio * Alcohol),
    lm(ScaledGlycemiaChange ~ Ratio * Sick)
  ))
  
  # Extract relevant intercepts and slopes
  intercepts <- map_dbl(fits, get_intercept)
  slopes <- map_dbl(fits, get_slope)
  
  # Deduce conversion parameters
  betas <- intercepts
  alphas <- -slopes / intercepts
  
  # Make parameters into a table
  parameters <- tibble(
    State = c("Normal", "Activity", "Alcohol", "Sick"),
    Intercept = intercepts,
    Slope = slopes,
    Beta = betas,
    Alpha = alphas
  )
  
}