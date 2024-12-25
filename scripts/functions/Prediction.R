# Hard-coded parameters at threshold one hour and a half
get_pars_1.5 <- function() read_csv("data/parameters/parameters_1_5.csv")

# Hard-coded parameters at threshold two hours
get_pars_2.0 <- function() read_csv("data/parameters/parameters_2_0.csv")

# Hard-coded parameters at threshold three hours
get_pars_3.0 <- function() read_csv("data/parameters/parameters_3_0.csv")

# Function to predict how much insulin to inject
predict_insulin <- function(
    
  glucose, delta = 0, state = "normal", target = NA, start = NA,
  time = 2, pars = NULL
  
) {
  
  # glucose: how much glucose to absorb?
  # delta: target change in glycemia
  # activity, alcohol, sick: whether or not any of those applies
  # target: target glycemia (overwrites delta if supplied)
  # start: starting glycemia
  # time: which time threshold to use for stability (1.5, 2 or 3)?
  # pars: parameters to use (will overwrite time if supplied)
  
  # If a target glycemia is supplied
  if (!is.na(target)) {
    
    # Check that a starting point is supplied
    if (is.na(start)) 
      stop("Target was supplied without a starting point.")
    
    # Compute the desired change in glycemia
    delta <- target - start
    
  }
  
  # If no parameters are supplied...
  if (is.null(pars)) {
    
    # Retrieve hard-coded parameters
    pars <- switch(
      time, 
      "1.5" = get_pars_1.5(),
      "2" = get_pars_2.0(),
      "3" = get_pars_3.0(),
      { stop("Time threshold not available") }
    )
    
  }
  
  # Find the right state
  i <- which(tolower(state) == tolower(pars$State))
  
  # Sanity check
  if (length(i) == 0L) stop("Unknown state supplied.")
  
  # Extract relevant parameters
  intercept <- pars$Intercept[i]
  slope <- pars$Slope[i]
  
  # Compute insulin needed
  insulin <- (delta - intercept * glucose) / slope
  
  return(insulin)
  
}
